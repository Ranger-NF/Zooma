import mongoose, { Document, Schema } from 'mongoose';

// -----------------------------
// Interfaces
// -----------------------------

export interface ISubmission {
  playerId: string;
  photoUrl: string;
  submittedAt: Date;
  approved?: boolean; // Optional: used for mentor approval
}

export interface ITask {
  _id: string;
  title: string;
  description: string;
  points: number;
  requiresPhoto: boolean;
  submissions: ISubmission[];
}

export interface IPlayer {
  _id: string;
  name: string;
  avatar: string;
  score: number;
  completedTasks: string[];
  joinedAt: Date;
}

export interface IRoom extends Document {
  code: string;
  mentorId: string;
  mentorName: string;
  players: IPlayer[];
  tasks: ITask[];
  isActive: boolean;
}

// -----------------------------
// Schemas
// -----------------------------

const SubmissionSchema = new Schema<ISubmission>({
  playerId: { type: String, required: true },
  photoUrl: { type: String, required: true },
  submittedAt: { type: Date, required: true },
  approved: { type: Boolean, default: false }
});

const TaskSchema = new Schema<ITask>({
  _id: { type: String, required: true },
  title: { type: String, required: true },
  description: { type: String, required: true },
  points: { type: Number, required: true },
  requiresPhoto: { type: Boolean, required: true },
  submissions: { type: [SubmissionSchema], default: [] }
});

const PlayerSchema = new Schema<IPlayer>({
  _id: { type: String, required: true },
  name: { type: String, required: true },
  avatar: { type: String, required: true },
  score: { type: Number, required: true },
  completedTasks: { type: [String], default: [] },
  joinedAt: { type: Date, required: true }
});

const RoomSchema = new Schema<IRoom>({
  code: { type: String, required: true, unique: true },
  mentorId: { type: String, required: true },
  mentorName: { type: String, required: true },
  players: { type: [PlayerSchema], default: [] },
  tasks: { type: [TaskSchema], default: [] },
  isActive: { type: Boolean, required: true }
});

export const Room = mongoose.model<IRoom>('Room', RoomSchema);
