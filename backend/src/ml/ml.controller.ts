import { Controller, Post, Body, Get, UseGuards } from '@nestjs/common';
import { MlService } from './ml.service';
import { JwtAuthGuard } from '../auth/guards/jwt-auth.guard';
import { PredictDto } from './dto/predict.dto';

@Controller('ml')
export class MlController {
  constructor(private readonly mlService: MlService) {}

  @Post('predict')
  @UseGuards(JwtAuthGuard)
  async predict(@Body() predictDto: PredictDto) {
    const result = await this.mlService.predictFromLandmarks(predictDto.landmarks);
    return {
      success: true,
      ...result,
    };
  }

  @Get('status')
  async getStatus() {
    return {
      success: true,
      ...this.mlService.getModelStatus(),
    };
  }

  @Get('classes')
  async getClasses() {
    return {
      success: true,
      classes: this.mlService.getClassLabels(),
    };
  }
}

