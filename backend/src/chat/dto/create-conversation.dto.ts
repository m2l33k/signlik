import { IsString, IsArray, IsOptional, IsBoolean } from 'class-validator';

export class CreateConversationDto {
  @IsOptional()
  @IsString()
  name?: string;

  @IsOptional()
  @IsBoolean()
  isGroup?: boolean;

  @IsArray()
  @IsString({ each: true })
  participantIds: string[];
}

