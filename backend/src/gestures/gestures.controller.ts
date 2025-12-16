import { Controller, Get, Post, Body, Param, Delete, UseGuards, Request } from '@nestjs/common';
import { GesturesService } from './gestures.service';
import { CreateGestureHistoryDto } from './dto/create-gesture-history.dto';
import { JwtAuthGuard } from '../auth/guards/jwt-auth.guard';

@Controller('gestures')
@UseGuards(JwtAuthGuard)
export class GesturesController {
  constructor(private readonly gesturesService: GesturesService) {}

  @Post('history')
  create(@Body() createDto: CreateGestureHistoryDto, @Request() req) {
    return this.gesturesService.create({
      ...createDto,
      userId: req.user.userId,
    });
  }

  @Get('history')
  findHistory(@Request() req) {
    return this.gesturesService.findByUser(req.user.userId);
  }

  @Get('stats')
  getStats(@Request() req) {
    return this.gesturesService.getStats(req.user.userId);
  }

  @Delete('history/:id')
  remove(@Param('id') id: string) {
    return this.gesturesService.remove(id);
  }
}

