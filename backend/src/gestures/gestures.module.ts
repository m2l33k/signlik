import { Module } from '@nestjs/common';
import { TypeOrmModule } from '@nestjs/typeorm';
import { GesturesService } from './gestures.service';
import { GesturesController } from './gestures.controller';
import { GestureHistory } from './gesture-history.entity';

@Module({
  imports: [TypeOrmModule.forFeature([GestureHistory])],
  controllers: [GesturesController],
  providers: [GesturesService],
  exports: [GesturesService],
})
export class GesturesModule {}

