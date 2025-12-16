import { Controller, Get, Post, Body, Param, UseGuards, Request } from '@nestjs/common';
import { ChatService } from './chat.service';
import { JwtAuthGuard } from '../auth/guards/jwt-auth.guard';
import { CreateConversationDto } from './dto/create-conversation.dto';
import { CreateMessageDto } from './dto/create-message.dto';

@Controller('chat')
@UseGuards(JwtAuthGuard)
export class ChatController {
  constructor(private readonly chatService: ChatService) {}

  @Post('conversations')
  async createConversation(@Body() createDto: CreateConversationDto, @Request() req) {
    return this.chatService.createConversation(createDto);
  }

  @Get('conversations')
  async getConversations(@Request() req) {
    return this.chatService.getUserConversations(req.user.userId);
  }

  @Get('conversations/:id')
  async getConversation(@Param('id') id: string, @Request() req) {
    return this.chatService.getConversation(id, req.user.userId);
  }

  @Get('conversations/:id/messages')
  async getMessages(@Param('id') id: string, @Request() req) {
    return this.chatService.getConversationMessages(id, req.user.userId);
  }

  @Post('messages')
  async createMessage(@Body() createDto: CreateMessageDto, @Request() req) {
    return this.chatService.saveMessage({
      ...createDto,
      senderId: req.user.userId,
    });
  }

  @Post('messages/:id/read')
  async markAsRead(@Param('id') id: string, @Request() req) {
    await this.chatService.markMessageAsRead(id, req.user.userId);
    return { success: true };
  }
}

