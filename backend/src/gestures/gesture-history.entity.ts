import { Entity, Column, PrimaryGeneratedColumn, CreateDateColumn, ManyToOne, JoinColumn } from 'typeorm';
import { User } from '../users/user.entity';

@Entity('gesture_history')
export class GestureHistory {
  @PrimaryGeneratedColumn('uuid')
  id: string;

  @ManyToOne(() => User)
  @JoinColumn({ name: 'userId' })
  user: User;

  @Column()
  userId: string;

  @Column()
  gesture: string; // e.g., "Hello", "Yes", "No", etc.

  @Column('float')
  confidence: number;

  @Column('json', { nullable: true })
  landmarks: number[]; // Store normalized landmarks (42 features)

  @CreateDateColumn()
  createdAt: Date;
}

