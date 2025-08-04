import { Request, Response } from 'express';
import { Room, Player } from '@/models';
import { 
  CreateRoomRequest, 
  JoinRoomRequest, 
  AddTasksRequest,
  ApiResponse,
  ITask 
} from '@/types';
import { 
  generateRoomCode, 
  generateTaskId, 
  isValidRoomCode, 
  isValidPlayerName,
  sanitizeString,
  validateTaskData,
  createApiResponse 
} from '@/utils/helpers';
import { CustomError } from '@/middleware/errorHandler';
import { SocketManager } from '@/socket/socketManager';

export class RoomController {
  private socketManager: SocketManager;

  constructor() {
    this.socketManager = SocketManager.getInstance();
  }

  // Create Room (Mentor)
  public createRoom = async (req: Request<{}, ApiResponse, CreateRoomRequest>, res: Response<ApiResponse>): Promise<void> => {
    const { mentorName, roomName, tasks = [] } = req.body;

    if (!mentorName?.trim() || !roomName?.trim()) {
      throw new CustomError('Mentor name and room name are required', 400);
    }

    // Validate tasks if provided
    if (tasks.length > 0) {
      for (const task of tasks) {
        if (!validateTaskData(task)) {
          throw new CustomError('Invalid task data provided', 400);
        }
      }
    }

    const roomCode = await generateRoomCode();

    // Prepare tasks with IDs
    const tasksWithIds: ITask[] = tasks.map(task => ({
      id: generateTaskId(),
      title: sanitizeString(task.title),
      description: sanitizeString(task.description),
      points: task.points,
      createdAt: new Date()
    }));

    const newRoom = new Room({
      roomCode,
      mentorName: sanitizeString(mentorName),
      roomName: sanitizeString(roomName),
      tasks: tasksWithIds
    });

    await newRoom.save();

    res.status(201).json(createApiResponse(
      true,
      { 
        roomCode,
        room: newRoom 
      },
      'Room created successfully'
    ));
  };

  // Join Room (Player)
  public joinRoom = async (req: Request<{}, ApiResponse, JoinRoomRequest>, res: Response<ApiResponse>): Promise<void> => {
    const { roomCode, playerName } = req.body;

    if (!isValidRoomCode(roomCode)) {
      throw new CustomError('Invalid room code format', 400);
    }

    if (!isValidPlayerName(playerName)) {
      throw new CustomError('Player name must be between 2 and 50 characters', 400);
    }

    const room = await Room.findOne({ roomCode, isActive: true });
    if (!room) {
      throw new CustomError('Room not found or inactive', 404);
    }

    // Check if player already exists in this room
    const existingPlayer = await Player.findOne({ 
      name: sanitizeString(playerName), 
      roomCode 
    });
    
    if (existingPlayer) {
      throw new CustomError('Player name already exists in this room', 400);
    }

    // Check room capacity
    const currentPlayers = await Player.countDocuments({ roomCode });
    if (currentPlayers >= room.maxPlayers) {
      throw new CustomError('Room is full', 400);
    }

    const newPlayer = new Player({
      name: sanitizeString(playerName),
      roomCode
    });

    await newPlayer.save();

    // Emit socket event
    this.socketManager.emitPlayerJoined(roomCode, newPlayer, currentPlayers + 1);

    res.status(201).json(createApiResponse(
      true,
      {
        player: newPlayer,
        room: {
          roomName: room.roomName,
          mentorName: room.mentorName,
          tasks: room.tasks
        }
      },
      'Successfully joined room'
    ));
  };

  // Get Room Details
  public getRoomDetails = async (req: Request, res: Response<ApiResponse>): Promise<void> => {
    const { roomCode } = req.params;

    if (!isValidRoomCode(roomCode)) {
      throw new CustomError('Invalid room code format', 400);
    }

    const room = await Room.findOne({ roomCode });
    if (!room) {
      throw new CustomError('Room not found', 404);
    }

    const players = await Player.find({ roomCode }).sort({ totalPoints: -1 });

    res.json(createApiResponse(
      true,
      {
        room,
        players,
        playerCount: players.length
      }
    ));
  };

  // Add Tasks to Room (Mentor)
  public addTasks = async (req: Request<{ roomCode: string }, ApiResponse, AddTasksRequest>, res: Response<ApiResponse>): Promise<void> => {
    const { roomCode } = req.params;
    const { tasks } = req.body;

    if (!isValidRoomCode(roomCode)) {
      throw new CustomError('Invalid room code format', 400);
    }

    if (!Array.isArray(tasks) || tasks.length === 0) {
      throw new CustomError('Tasks array is required and must not be empty', 400);
    }

    // Validate all tasks
    for (const task of tasks) {
      if (!validateTaskData(task)) {
        throw new CustomError('Invalid task data provided', 400);
      }
    }

    const room = await Room.findOne({ roomCode });
    if (!room) {
      throw new CustomError('Room not found', 404);
    }

    // Add tasks with unique IDs
    const newTasks: ITask[] = tasks.map(task => ({
      id: generateTaskId(),
      title: sanitizeString(task.title),
      description: sanitizeString(task.description),
      points: task.points,
      createdAt: new Date()
    }));

    room.tasks.push(...newTasks);
    await room.save();

    // Emit socket event
    this.socketManager.emitTaskAdded(roomCode, room.tasks);

    res.json(createApiResponse(
      true,
      { tasks: room.tasks },
      'Tasks added successfully'
    ));
  };

  // Update Room Status (Mentor)
  public updateRoomStatus = async (req: Request, res: Response<ApiResponse>): Promise<void> => {
    const { roomCode } = req.params;
    const { isActive } = req.body;

    if (!isValidRoomCode(roomCode)) {
      throw new CustomError('Invalid room code format', 400);
    }

    if (typeof isActive !== 'boolean') {
      throw new CustomError('isActive must be a boolean value', 400);
    }

    const room = await Room.findOneAndUpdate(
      { roomCode },
      { isActive },
      { new: true }
    );

    if (!room) {
      throw new CustomError('Room not found', 404);
    }

    // Emit socket event
    this.socketManager.emitRoomStatusChanged(roomCode, isActive);

    res.json(createApiResponse(
      true,
      { room },
      `Room ${isActive ? 'activated' : 'deactivated'} successfully`
    ));
  };

  // Delete Task (Mentor)
  public deleteTask = async (req: Request, res: Response<ApiResponse>): Promise<void> => {
    const { roomCode, taskId } = req.params;

    if (!isValidRoomCode(roomCode)) {
      throw new CustomError('Invalid room code format', 400);
    }

    if (!taskId?.trim()) {
      throw new CustomError('Task ID is required', 400);
    }

    const room = await Room.findOne({ roomCode });
    if (!room) {
      throw new CustomError('Room not found', 404);
    }

    const taskExists = room.tasks.some(task => task.id === taskId);
    if (!taskExists) {
      throw new CustomError('Task not found', 404);
    }

    room.tasks = room.tasks.filter(task => task.id !== taskId);
    await room.save();

    // Also remove related submissions
    const { Submission } = require('@/models');
    await Submission.deleteMany({ roomCode, taskId });

    // Emit socket event
    this.socketManager.emitTaskDeleted(roomCode, taskId);

    res.json(createApiResponse(
      true,
      undefined,
      'Task deleted successfully'
    ));
  };

  // Get Room Updates (for polling fallback)
  public getRoomUpdates = async (req: Request, res: Response<ApiResponse>): Promise<void> => {
    const { roomCode } = req.params;
    const { lastCheck } = req.query;

    if (!isValidRoomCode(roomCode)) {
      throw new CustomError('Invalid room code format', 400);
    }

    const checkTime = lastCheck 
      ? new Date(lastCheck as string) 
      : new Date(Date.now() - 60000); // Last minute if no timestamp

    const { Submission } = require('@/models');
    
    const recentSubmissions = await Submission.find({
      roomCode,
      submittedAt: { $gte: checkTime }
    }).populate('playerId', 'name');

    const recentPlayers = await Player.find({
      roomCode,
      joinedAt: { $gte: checkTime }
    });

    res.json(createApiResponse(
      true,
      {
        updates: {
          newSubmissions: recentSubmissions.length,
          newPlayers: recentPlayers.length,
          timestamp: new Date()
        }
      }
    ));
  };
}