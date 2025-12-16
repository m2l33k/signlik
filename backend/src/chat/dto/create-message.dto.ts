import { IsString, IsOptional, IsNumber, Min, Max } from 'class-validator';

export class CreateMessageDto {
  @IsString()
  conversationId: string;

  @IsString()
  senderId: string;

  @IsString()
  text: string;

  @IsOptional()
  @IsString()
  gestureSign?: string;

  @IsOptional()
  @IsNumber()
  @Min(0)
  @Max(1)
  gestureConfidence?: number;
}

