import { IsString, IsNumber, IsArray, Min, Max, IsOptional } from 'class-validator';

export class CreateGestureHistoryDto {
  @IsString()
  gesture: string;

  @IsNumber()
  @Min(0)
  @Max(1)
  confidence: number;

  @IsOptional()
  @IsArray()
  landmarks?: number[];
}

