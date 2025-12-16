import { Injectable } from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { Repository } from 'typeorm';
import { Message } from './message.entity';
import { Conversation } from './conversation.entity';
import { CreateMessageDto } from './dto/create-message.dto';
import { CreateConversationDto } from './dto/create-conversation.dto';

@Injectable()
export class ChatService {
  constructor(
    @InjectRepository(Message)
    private messageRepository: Repository<Message>,
    @InjectRepository(Conversation)
    private conversationRepository: Repository<Conversation>,
  ) {}

  async createConversation(createDto: CreateConversationDto): Promise<Conversation> {
    const conversation = this.conversationRepository.create(createDto);
    return this.conversationRepository.save(conversation);
  }

  async getConversation(conversationId: string, userId: string): Promise<Conversation | null> {
    return this.conversationRepository
      .createQueryBuilder('conversation')
      .leftJoinAndSelect('conversation.participants', 'participants')
      .where('conversation.id = :conversationId', { conversationId })
      .andWhere('participants.id = :userId', { userId })
      .getOne();
  }

  async getUserConversations(userId: string): Promise<Conversation[]> {
    return this.conversationRepository
      .createQueryBuilder('conversation')
      .leftJoinAndSelect('conversation.participants', 'participants')
      .where('participants.id = :userId', { userId })
      .orderBy('conversation.lastMessageTime', 'DESC')
      .getMany();
  }

  async saveMessage(createDto: CreateMessageDto): Promise<Message> {
    const message = this.messageRepository.create({
      ...createDto,
      type: createDto.gestureSign ? 'gesture' : 'text',
    });
    return this.messageRepository.save(message);
  }

  async getConversationMessages(conversationId: string, userId: string, limit: number = 50): Promise<Message[]> {
    // Verify user is part of conversation
    const conversation = await this.getConversation(conversationId, userId);
    if (!conversation) {
      return [];
    }

    return this.messageRepository.find({
      where: { conversationId },
      relations: ['sender'],
      order: { createdAt: 'ASC' },
      take: limit,
    });
  }

  async updateConversationLastMessage(conversationId: string, lastMessage: string): Promise<void> {
    await this.conversationRepository.update(conversationId, {
      lastMessage,
      lastMessageTime: new Date(),
    });
  }

  async markMessageAsRead(messageId: string, userId: string): Promise<void> {
    await this.messageRepository
      .createQueryBuilder()
      .update(Message)
      .set({ isRead: true, readAt: new Date() })
      .where('id = :messageId', { messageId })
      .andWhere('senderId != :userId', { userId })
      .execute();
  }

  async getUnreadCount(conversationId: string, userId: string): Promise<number> {
    return this.messageRepository
      .createQueryBuilder('message')
      .where('message.conversationId = :conversationId', { conversationId })
      .andWhere('message.senderId != :userId', { userId })
      .andWhere('message.isRead = :isRead', { isRead: false })
      .getCount();
  }
}

