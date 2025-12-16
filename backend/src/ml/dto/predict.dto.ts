import { IsArray, ArrayMinSize, ArrayMaxSize } from 'class-validator';

export class PredictDto {
  @IsArray()
  @ArrayMinSize(42)
  @ArrayMaxSize(42)
  landmarks: number[];
}

