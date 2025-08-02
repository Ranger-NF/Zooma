import mongoose, { Document, Schema, Types } from 'mongoose';

// ---------- Interfaces ----------

// Interface for a task submission (can be expanded)
export interface ISubmission {
  playerId: string;
  photoUrl?: string;
  submittedAt: Date;
}

// Interface for a task
export interface ITask {
  _id: string;
  title: string;
  description: string;
  points: number;
  requiresPhoto: boolean;
  submissions: ISubmission[];
}

// Interface for a player
export interface IPlayer {
  _id: string;
  name: string;
  avatar: string;
  score: number;
  completedTasks: string[]; // Array of task IDs
  joinedAt: Date;
}

// Interface for a room document
export interface IRoom extends Document {
  code: string;
  mentorId: string;
  mentorName: string;
  players: IPlayer[];
  tasks: ITask[];
  isActive: boolean;
}

// ---------- Schemas ----------

// Submission schema
const SubmissionSchema = new Schema<ISubmission>({
  playerId: { type: String, required: true },
  photoUrl: { type: String },
  submittedAt: { type: Date, default: Date.now }
});

// Task schema
const TaskSchema = new Schema<ITask>({
  _id: { type: String, required: true },
  title: { type: String, required: true },
  description: { type: String, required: true },
  points: { type: Number, required: true },
  requiresPhoto: { type: Boolean, required: true },
  submissions: { type: [SubmissionSchema], default: [] }
});

// Player schema
const PlayerSchema = new Schema<IPlayer>({
  _id: { type: String, required: true },
  name: { type: String, required: true },
  avatar: { type: String, required: true },
  score: { type: Number, required: true },
  completedTasks: { type: [String], default: [] },
  joinedAt: { type: Date, default: Date.now }
});

// Room schema
const RoomSchema = new Schema<IRoom>({
  code: { type: String, required: true, unique: true },
  mentorId: { type: String, required: true },
  mentorName: { type: String, required: true },
  players: { type: [PlayerSchema], default: [] },
  tasks: { type: [TaskSchema], default: [] },
  isActive: { type: Boolean, default: true }
}, { timestamps: true });

// Create and export model
export const Room = mongoose.model<IRoom>('Room', RoomSchema);
