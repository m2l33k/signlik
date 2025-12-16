import {
  WebSocketGateway,
  WebSocketServer,
  SubscribeMessage,
  OnGatewayConnection,
  OnGatewayDisconnect,
  MessageBody,
  ConnectedSocket,
} from '@nestjs/websockets';
import { Server, Socket } from 'socket.io';
import { Logger } from '@nestjs/common';
import { JwtService } from '@nestjs/jwt';
import { ChatService } from './chat.service';
import { MlService } from '../ml/ml.service';

@WebSocketGateway({
  cors: {
    origin: '*',
    credentials: true,
  },
  namespace: '/chat',
})
export class ChatGateway implements OnGatewayConnection, OnGatewayDisconnect {
  @WebSocketServer()
  server: Server;

  private readonly logger = new Logger(ChatGateway.name);
  private readonly connectedUsers = new Map<string, string>(); // socketId -> userId

  constructor(
    private readonly chatService: ChatService,
    private readonly mlService: MlService,
    private readonly jwtService: JwtService,
  ) {}

  async handleConnection(client: Socket) {
    try {
      // Extract token from handshake
      const token = client.handshake.auth?.token || client.handshake.headers?.authorization?.replace('Bearer ', '');
      
      if (!token) {
        this.logger.warn(`Client ${client.id} connected without token`);
        client.disconnect();
        return;
      }

      // Verify JWT token
      const payload = this.jwtService.verify(token);
      const userId = payload.sub || payload.userId;

      if (!userId) {
        this.logger.warn(`Client ${client.id} connected with invalid token`);
        client.disconnect();
        return;
      }

      // Store user connection
      this.connectedUsers.set(client.id, userId);
      client.data.userId = userId;

      // Join user's personal room
      await client.join(`user_${userId}`);

      this.logger.log(`User ${userId} connected (socket: ${client.id})`);

      // Notify user of successful connection
      client.emit('connected', { userId, socketId: client.id });
    } catch (error) {
      this.logger.error(`Connection error for ${client.id}:`, error);
      client.disconnect();
    }
  }

  async handleDisconnect(client: Socket) {
    const userId = this.connectedUsers.get(client.id);
    if (userId) {
      this.connectedUsers.delete(client.id);
      this.logger.log(`User ${userId} disconnected (socket: ${client.id})`);
    }
  }

  @SubscribeMessage('join')
  async handleJoin(@ConnectedSocket() client: Socket, @MessageBody() data: { userId: string }) {
    const userId = client.data.userId;
    this.logger.log(`User ${userId} joined`);
    client.emit('joined', { userId });
  }

  @SubscribeMessage('join_conversation')
  async handleJoinConversation(
    @ConnectedSocket() client: Socket,
    @MessageBody() data: { conversationId: string },
  ) {
    const userId = client.data.userId;
    const { conversationId } = data;

    await client.join(`conversation_${conversationId}`);
    this.logger.log(`User ${userId} joined conversation ${conversationId}`);

    // Load and send conversation history
    const messages = await this.chatService.getConversationMessages(conversationId, userId);
    client.emit('conversation_history', { conversationId, messages });
  }

  @SubscribeMessage('predict_gesture')
  async handlePredictGesture(
    @ConnectedSocket() client: Socket,
    @MessageBody() data: { landmarks: number[] },
  ) {
    try {
      const prediction = await this.mlService.predictFromLandmarks(data.landmarks);
      client.emit('gesture_prediction', prediction);
    } catch (error) {
      this.logger.error(`Gesture prediction error:`, error);
      client.emit('error', { message: 'Failed to predict gesture' });
    }
  }

  @SubscribeMessage('send_message')
  async handleSendMessage(
    @ConnectedSocket() client: Socket,
    @MessageBody() data: { conversationId: string; message: any },
  ) {
    const userId = client.data.userId;
    const { conversationId, message } = data;

    try {
      // Save message to database
      const savedMessage = await this.chatService.saveMessage({
        conversationId,
        senderId: userId,
        text: message.text,
        gestureSign: message.gestureSign,
        gestureConfidence: message.gestureConfidence,
      });

      // Broadcast to all users in the conversation
      this.server.to(`conversation_${conversationId}`).emit('message', savedMessage);

      // Update conversation last message
      await this.chatService.updateConversationLastMessage(conversationId, savedMessage.text);

      this.logger.log(`Message sent in conversation ${conversationId} by user ${userId}`);
    } catch (error) {
      this.logger.error(`Error sending message:`, error);
      client.emit('error', { message: 'Failed to send message' });
    }
  }

  @SubscribeMessage('typing')
  async handleTyping(
    @ConnectedSocket() client: Socket,
    @MessageBody() data: { conversationId: string; isTyping: boolean },
  ) {
    const userId = client.data.userId;
    const { conversationId, isTyping } = data;

    // Broadcast typing status to other users in conversation
    client.to(`conversation_${conversationId}`).emit('typing', {
      userId,
      conversationId,
      isTyping,
    });
  }
}
