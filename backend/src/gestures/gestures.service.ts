import { Injectable } from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { Repository } from 'typeorm';
import { GestureHistory } from './gesture-history.entity';
import { CreateGestureHistoryDto } from './dto/create-gesture-history.dto';

@Injectable()
export class GesturesService {
  constructor(
    @InjectRepository(GestureHistory)
    private gestureHistoryRepository: Repository<GestureHistory>,
  ) {}

  async create(createDto: CreateGestureHistoryDto): Promise<GestureHistory> {
    const history = this.gestureHistoryRepository.create(createDto);
    return this.gestureHistoryRepository.save(history);
  }

  async findByUser(userId: string, limit: number = 100): Promise<GestureHistory[]> {
    return this.gestureHistoryRepository.find({
      where: { userId },
      order: { createdAt: 'DESC' },
      take: limit,
    });
  }

  async getStats(userId: string): Promise<any> {
    const histories = await this.findByUser(userId, 1000);
    
    const gestureCounts: Record<string, number> = {};
    let totalConfidence = 0;
    
    histories.forEach((h) => {
      gestureCounts[h.gesture] = (gestureCounts[h.gesture] || 0) + 1;
      totalConfidence += h.confidence;
    });
    
    return {
      totalGestures: histories.length,
      averageConfidence: histories.length > 0 ? totalConfidence / histories.length : 0,
      gestureCounts,
    };
  }

  async remove(id: string): Promise<void> {
    await this.gestureHistoryRepository.delete(id);
  }
}

