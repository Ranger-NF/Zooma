import { Server as SocketServer } from 'socket.io';
import { Server as HttpServer } from 'http';
import {
  ServerToClientEvents,
  ClientToServerEvents,
  InterServerEvents,
  SocketData,
  IPlayer,
  ISubmission,
  LeaderboardEntry
} from '../types';

export class SocketManager {
  private static instance: SocketManager;
  private io: SocketServer<ClientToServerEvents, ServerToClientEvents, InterServerEvents, SocketData> | null = null;

  private constructor() {}

  public static getInstance(): SocketManager {
    if (!SocketManager.instance) {
      SocketManager.instance = new SocketManager();
    }
    return SocketManager.instance;
  }

  public initialize(server: HttpServer): void {
    this.io = new SocketServer(server, {
      cors: {
        origin: "*",
        methods: ["GET", "POST"],
        credentials: true
      },
      transports: ['websocket', 'polling']
    });

    this.setupEventHandlers();
    console.log('Socket.IO server initialized');
  }

  private setupEventHandlers(): void {
    if (!this.io) return;

    this.io.on('connection', (socket) => {
      console.log(`Client connected: ${socket.id}`);

      // Handle player joining a room
      socket.on('joinRoom', (roomCode: string) => {
        socket.join(roomCode);
        socket.data.roomCode = roomCode;
        socket.data.isMentor = false;
        console.log(`Socket ${socket.id} joined room: ${roomCode}`);
      });

      // Handle mentor joining a room
      socket.on('joinMentorRoom', (roomCode: string) => {
        socket.join(`mentor-${roomCode}`);
        socket.data.roomCode = roomCode;
        socket.data.isMentor = true;
        console.log(`Socket ${socket.id} joined mentor room: ${roomCode}`);
      });

      // Handle leaving room
      socket.on('leaveRoom', (roomCode: string) => {
        socket.leave(roomCode);
        console.log(`Socket ${socket.id} left room: ${roomCode}`);
      });

      // Handle leaving mentor room
      socket.on('leaveMentorRoom', (roomCode: string) => {
        socket.leave(`mentor-${roomCode}`);
        console.log(`Socket ${socket.id} left mentor room: ${roomCode}`);
      });

      // Handle disconnection
      socket.on('disconnect', () => {
        console.log(`Client disconnected: ${socket.id}`);
      });
    });
  }

  // Emit when a player joins a room
  public emitPlayerJoined(roomCode: string, player: IPlayer, playerCount: number): void {
    if (!this.io) return;
    
    this.io.to(roomCode).emit('playerJoined', { player, playerCount });
    this.io.to(`mentor-${roomCode}`).emit('playerJoined', { player, playerCount });
  }

  // Emit when a task is submitted
  public emitTaskSubmitted(roomCode: string, submission: ISubmission, playerName: string): void {
    if (!this.io) return;
    
    this.io.to(`mentor-${roomCode}`).emit('taskSubmitted', { submission, playerName });
  }

  // Emit when a submission is reviewed
  public emitSubmissionReviewed(roomCode: string, submission: ISubmission, taskTitle: string): void {
    if (!this.io) return;
    
    this.io.to(roomCode).emit('submissionReviewed', { submission, taskTitle });
  }

  // Emit leaderboard updates
  public emitLeaderboardUpdated(roomCode: string, leaderboard: LeaderboardEntry[]): void {
    if (!this.io) return;
    
    this.io.to(roomCode).emit('leaderboardUpdated', { leaderboard });
    this.io.to(`mentor-${roomCode}`).emit('leaderboardUpdated', { leaderboard });
  }

  // Emit room status changes
  public emitRoomStatusChanged(roomCode: string, isActive: boolean): void {
    if (!this.io) return;
    
    this.io.to(roomCode).emit('roomStatusChanged', { isActive });
    this.io.to(`mentor-${roomCode}`).emit('roomStatusChanged', { isActive });
  }

  // Emit when tasks are added
  public emitTaskAdded(roomCode: string, tasks: any[]): void {
    if (!this.io) return;
    
    this.io.to(roomCode).emit('taskAdded', { tasks });
  }

  // Emit when a task is deleted
  public emitTaskDeleted(roomCode: string, taskId: string): void {
    if (!this.io) return;
    
    this.io.to(roomCode).emit('taskDeleted', { taskId });
    this.io.to(`mentor-${roomCode}`).emit('taskDeleted', { taskId });
  }

  // Get connected clients count for a room
  public getRoomClientCount(roomCode: string): number {
    if (!this.io) return 0;
    
    const room = this.io.sockets.adapter.rooms.get(roomCode);
    return room ? room.size : 0;
  }

  // Get connected mentor clients count for a room
  public getMentorRoomClientCount(roomCode: string): number {
    if (!this.io) return 0;
    
    const room = this.io.sockets.adapter.rooms.get(`mentor-${roomCode}`);
    return room ? room.size : 0;
  }

  // Broadcast to all clients in a room
  public broadcastToRoom(roomCode: string, event: keyof ServerToClientEvents, data: any): void {
    if (!this.io) return;
    
    this.io.to(roomCode).emit(event as any, data);
  }

  // Broadcast to all mentor clients in a room
  public broadcastToMentorRoom(roomCode: string, event: keyof ServerToClientEvents, data: any): void {
    if (!this.io) return;
    
    this.io.to(`mentor-${roomCode}`).emit(event as any, data);
  }

  // Get socket server instance
  public getIO(): SocketServer<ClientToServerEvents, ServerToClientEvents, InterServerEvents, SocketData> | null {
    return this.io;
  }

  // Check if socket server is initialized
  public isInitialized(): boolean {
    return this.io !== null;
  }
}