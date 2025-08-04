import mongoose, { Schema } from 'mongoose';
import { IRoom, IPlayer, ISubmission } from '@/types';

// Room Schema
const roomSchema = new Schema<IRoom>({
  roomCode: { 
    type: String, 
    unique: true, 
    required: true,
    index: true 
  },
  mentorName: { 
    type: String, 
    required: true 
  },
  roomName: { 
    type: String, 
    required: true 
  },
  isActive: { 
    type: Boolean, 
    default: true 
  },
  createdAt: { 
    type: Date, 
    default: Date.now 
  },
  tasks: [{
    id: { type: String, required: true },
    title: { type: String, required: true },
    description: { type: String, required: true },
    points: { type: Number, required: true },
    createdAt: { type: Date, default: Date.now }
  }],
  maxPlayers: { 
    type: Number, 
    default: 20 
  }
});

// Player Schema
const playerSchema = new Schema<IPlayer>({
  name: { 
    type: String, 
    required: true 
  },
  roomCode: { 
    type: String, 
    required: true,
    index: true 
  },
  joinedAt: { 
    type: Date, 
    default: Date.now 
  },
  totalPoints: { 
    type: Number, 
    default: 0 
  },
  completedTasks: { 
    type: Number, 
    default: 0 
  }
});

// Submission Schema
const submissionSchema = new Schema<ISubmission>({
  playerId: { 
    type: Schema.Types.ObjectId, 
    ref: 'Player', 
    required: true,
    index: true 
  },
  taskId: { 
    type: String, 
    required: true,
    index: true 
  },
  roomCode: { 
    type: String, 
    required: true,
    index: true 
  },
  photoPath: { 
    type: String, 
    required: true 
  },
  submittedAt: { 
    type: Date, 
    default: Date.now 
  },
  status: { 
    type: String, 
    enum: ['pending', 'approved', 'rejected'], 
    default: 'pending',
    index: true 
  },
  mentorFeedback: { 
    type: String 
  },
  points: { 
    type: Number, 
    default: 0 
  }
});

// Compound indexes for better query performance
playerSchema.index({ name: 1, roomCode: 1 }, { unique: true });
submissionSchema.index({ playerId: 1, taskId: 1, roomCode: 1 }, { unique: true });
submissionSchema.index({ roomCode: 1, status: 1 });

// Export models
export const Room = mongoose.model<IRoom>('Room', roomSchema);
export const Player = mongoose.model<IPlayer>('Player', playerSchema);
export const Submission = mongoose.model<ISubmission>('Submission', submissionSchema);