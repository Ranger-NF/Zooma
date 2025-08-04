import { Document, Types } from 'mongoose';

export interface ITask {
  id: string;
  title: string;
  description: string;
  points: number;
  createdAt: Date;
}

export interface IRoom extends Document {
  roomCode: string;
  mentorName: string;
  roomName: string;
  isActive: boolean;
  createdAt: Date;
  tasks: ITask[];
  maxPlayers: number;
}

export interface IPlayer extends Document {
  name: string;
  roomCode: string;
  joinedAt: Date;
  totalPoints: number;
  completedTasks: number;
}

export interface ISubmission extends Document {
  playerId: Types.ObjectId;
  taskId: string;
  roomCode: string;
  photoPath: string;
  submittedAt: Date;
  status: 'pending' | 'approved' | 'rejected';
  mentorFeedback?: string;
  points: number;
}

export interface ApiResponse<T = any> {
  success: boolean;
  message?: string;
  data?: T;
  error?: string;
}

export interface CreateRoomRequest {
  mentorName: string;
  roomName: string;
  tasks?: ITask[];
}

export interface JoinRoomRequest {
  roomCode: string;
  playerName: string;
}

export interface AddTasksRequest {
  tasks: Omit<ITask, 'id' | 'createdAt'>[];
}

export interface ReviewSubmissionRequest {
  status: 'approved' | 'rejected';
  feedback?: string;
  points?: number;
}

export interface TaskWithStatus extends ITask {
  completed: boolean;
  submissionStatus: string | null;
}

export interface SubmissionWithDetails extends ISubmission {
  taskDetails?: ITask;
  playerName?: string;
}

export interface LeaderboardEntry {
  rank: number;
  playerId: string;
  name: string;
  points: number;
  completedTasks: number;
  joinedAt: Date;
}

export interface PlayerStats {
  totalPoints: number;
  completedTasks: number;
  totalSubmissions: number;
  approvedSubmissions: number;
  pendingSubmissions: number;
  rejectedSubmissions: number;
}

export interface RoomAnalytics {
  totalPlayers: number;
  totalTasks: number;
  totalSubmissions: number;
  pendingReviews: number;
  approvedSubmissions: number;
  rejectedSubmissions: number;
  averagePointsPerPlayer: number;
  topPerformer: IPlayer | null;
}

export interface RoomUpdates {
  newSubmissions: number;
  newPlayers: number;
  timestamp: Date;
}

// Socket.IO Event Types
export interface ServerToClientEvents {
  playerJoined: (data: { player: IPlayer; playerCount: number }) => void;
  taskSubmitted: (data: { submission: ISubmission; playerName: string }) => void;
  submissionReviewed: (data: { submission: ISubmission; taskTitle: string }) => void;
  leaderboardUpdated: (data: { leaderboard: LeaderboardEntry[] }) => void;
  roomStatusChanged: (data: { isActive: boolean }) => void;
  taskAdded: (data: { tasks: ITask[] }) => void;
  taskDeleted: (data: { taskId: string }) => void;
}

export interface ClientToServerEvents {
  joinRoom: (roomCode: string) => void;
  leaveRoom: (roomCode: string) => void;
  joinMentorRoom: (roomCode: string) => void;
  leaveMentorRoom: (roomCode: string) => void;
}

export interface InterServerEvents {
  ping: () => void;
}

export interface SocketData {
  roomCode?: string;
  isMentor?: boolean;
}