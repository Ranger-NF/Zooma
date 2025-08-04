import { Request, Response } from 'express';
import { Room, Player, Submission } from '../models';
import { ApiResponse, TaskWithStatus } from '../types';
import { isValidRoomCode, createApiResponse } from '../utils/helpers';
import { CustomError } from '../middleware/errorHandler';

export class TaskController {

  // Get Tasks for Player
  public getPlayerTasks = async (req: Request, res: Response<ApiResponse>): Promise<void> => {
    const { roomCode, playerId } = req.params;

    if (!isValidRoomCode(roomCode)) {
      throw new CustomError('Invalid room code format', 400);
    }

    if (!playerId?.trim()) {
      throw new CustomError('Player ID is required', 400);
    }

    const room = await Room.findOne({ roomCode });
    const player = await Player.findById(playerId);

    if (!room) {
      throw new CustomError('Room not found', 404);
    }

    if (!player) {
      throw new CustomError('Player not found', 404);
    }

    if (player.roomCode !== roomCode) {
      throw new CustomError('Player does not belong to this room', 403);
    }

    // Get player's submissions to mark completed tasks
    const playerSubmissions = await Submission.find({ 
      playerId, 
      roomCode 
    });

    const submissionMap = new Map();
    playerSubmissions.forEach(sub => {
      submissionMap.set(sub.taskId, sub);
    });

    const tasksWithStatus: TaskWithStatus[] = room.tasks.map(task => {
      const submission = submissionMap.get(task.id);
      return {
        ...task,
        completed: submission?.status === 'approved',
        submissionStatus: submission?.status || null
      };
    });

    res.json(createApiResponse(
      true,
      {
        tasks: tasksWithStatus,
        playerPoints: player.totalPoints,
        completedTasks: player.completedTasks
      }
    ));
  };

  // Get Task Statistics
  public getTaskStatistics = async (req: Request, res: Response<ApiResponse>): Promise<void> => {
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

    const task = room.tasks.find(t => t.id === taskId);
    if (!task) {
      throw new CustomError('Task not found', 404);
    }

    // Get submission statistics for this task
    const totalPlayers = await Player.countDocuments({ roomCode });
    const totalSubmissions = await Submission.countDocuments({ roomCode, taskId });
    const approvedSubmissions = await Submission.countDocuments({ 
      roomCode, 
      taskId, 
      status: 'approved' 
    });
    const pendingSubmissions = await Submission.countDocuments({ 
      roomCode, 
      taskId, 
      status: 'pending' 
    });
    const rejectedSubmissions = await Submission.countDocuments({ 
      roomCode, 
      taskId, 
      status: 'rejected' 
    });

    const completionRate = totalPlayers > 0 
      ? Math.round((approvedSubmissions / totalPlayers) * 100) 
      : 0;

    const submissionRate = totalPlayers > 0 
      ? Math.round((totalSubmissions / totalPlayers) * 100) 
      : 0;

    res.json(createApiResponse(
      true,
      {
        task,
        statistics: {
          totalPlayers,
          totalSubmissions,
          approvedSubmissions,
          pendingSubmissions,
          rejectedSubmissions,
          completionRate,
          submissionRate
        }
      }
    ));
  };

  // Get All Tasks for Room (Mentor view)
  public getRoomTasks = async (req: Request, res: Response<ApiResponse>): Promise<void> => {
    const { roomCode } = req.params;

    if (!isValidRoomCode(roomCode)) {
      throw new CustomError('Invalid room code format', 400);
    }

    const room = await Room.findOne({ roomCode });
    if (!room) {
      throw new CustomError('Room not found', 404);
    }

    // Get submission counts for each task
    const tasksWithStats = await Promise.all(
      room.tasks.map(async (task) => {
        const totalSubmissions = await Submission.countDocuments({ roomCode, taskId: task.id });
        const approvedSubmissions = await Submission.countDocuments({ 
          roomCode, 
          taskId: task.id, 
          status: 'approved' 
        });
        const pendingSubmissions = await Submission.countDocuments({ 
          roomCode, 
          taskId: task.id, 
          status: 'pending' 
        });

        return {
          ...task,
          stats: {
            totalSubmissions,
            approvedSubmissions,
            pendingSubmissions
          }
        };
      })
    );

    res.json(createApiResponse(
      true,
      {
        tasks: tasksWithStats,
        totalTasks: room.tasks.length
      }
    ));
  };

  // Update Task (Mentor)
  public updateTask = async (req: Request, res: Response<ApiResponse>): Promise<void> => {
    const { roomCode, taskId } = req.params;
    const { title, description, points } = req.body;

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

    const taskIndex = room.tasks.findIndex(task => task.id === taskId);
    if (taskIndex === -1) {
      throw new CustomError('Task not found', 404);
    }

    // Update task fields if provided
    if (title !== undefined) {
      if (!title.trim()) {
        throw new CustomError('Task title cannot be empty', 400);
      }
      room.tasks[taskIndex].title = title.trim();
    }

    if (description !== undefined) {
      if (!description.trim()) {
        throw new CustomError('Task description cannot be empty', 400);
      }
      room.tasks[taskIndex].description = description.trim();
    }

    if (points !== undefined) {
      if (typeof points !== 'number' || points <= 0) {
        throw new CustomError('Points must be a positive number', 400);
      }
      room.tasks[taskIndex].points = points;
    }

    await room.save();

    res.json(createApiResponse(
      true,
      { task: room.tasks[taskIndex] },
      'Task updated successfully'
    ));
  };
}