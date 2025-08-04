import { Request, Response } from 'express';
import path from 'path';
import fs from 'fs';
import { Room, Player, Submission } from '../models';
import { 
  ApiResponse, 
  ReviewSubmissionRequest, 
  SubmissionWithDetails 
} from '../types';
import { 
  isValidRoomCode, 
  createApiResponse, 
  fileExists 
} from '../utils/helpers';
import { CustomError } from '../middleware/errorHandler';
import { SocketManager } from '../socket/socketManager';

export class SubmissionController {
  private socketManager: SocketManager;

  constructor() {
    this.socketManager = SocketManager.getInstance();
  }

  // Submit Task Photo (Player)
  public submitTaskPhoto = async (req: Request, res: Response<ApiResponse>): Promise<void> => {
    const { roomCode, playerId, taskId } = req.params;

    if (!isValidRoomCode(roomCode)) {
      throw new CustomError('Invalid room code format', 400);
    }

    if (!playerId?.trim() || !taskId?.trim()) {
      throw new CustomError('Player ID and Task ID are required', 400);
    }

    if (!req.file) {
      throw new CustomError('No photo uploaded', 400);
    }

    // Verify room exists and is active
    const room = await Room.findOne({ roomCode, isActive: true });
    if (!room) {
      throw new CustomError('Room not found or inactive', 404);
    }

    // Verify player exists and belongs to room
    const player = await Player.findById(playerId);
    if (!player || player.roomCode !== roomCode) {
      throw new CustomError('Player not found or does not belong to this room', 404);
    }

    // Verify task exists
    const task = room.tasks.find(t => t.id === taskId);
    if (!task) {
      throw new CustomError('Task not found', 404);
    }

    // Check if already submitted
    const existingSubmission = await Submission.findOne({
      playerId,
      taskId,
      roomCode
    });

    if (existingSubmission) {
      // Remove uploaded file since submission already exists
      if (await fileExists(req.file.path)) {
        fs.unlinkSync(req.file.path);
      }
      throw new CustomError('Task already submitted', 400);
    }

    const submission = new Submission({
      playerId,
      taskId,
      roomCode,
      photoPath: req.file.path
    });

    await submission.save();

    // Emit socket event to mentors
    this.socketManager.emitTaskSubmitted(roomCode, submission, player.name);

    res.json(createApiResponse(
      true,
      { submission },
      'Photo submitted successfully'
    ));
  };

  // Get Submissions for Mentor Review
  public getSubmissionsForReview = async (req: Request, res: Response<ApiResponse>): Promise<void> => {
    const { roomCode } = req.params;
    const { status = 'pending', page = '1', limit = '10' } = req.query;

    if (!isValidRoomCode(roomCode)) {
      throw new CustomError('Invalid room code format', 400);
    }

    const validStatuses = ['pending', 'approved', 'rejected'];
    if (!validStatuses.includes(status as string)) {
      throw new CustomError('Invalid status. Must be pending, approved, or rejected', 400);
    }

    const pageNum = parseInt(page as string, 10);
    const limitNum = parseInt(limit as string, 10);

    if (pageNum < 1 || limitNum < 1 || limitNum > 50) {
      throw new CustomError('Invalid pagination parameters', 400);
    }

    const skip = (pageNum - 1) * limitNum;

    const [submissions, totalCount, room] = await Promise.all([
      Submission.find({ roomCode, status })
        .populate('playerId', 'name')
        .sort({ submittedAt: -1 })
        .skip(skip)
        .limit(limitNum),
      Submission.countDocuments({ roomCode, status }),
      Room.findOne({ roomCode })
    ]);

    if (!room) {
      throw new CustomError('Room not found', 404);
    }

    // Enhance submissions with task details
    const submissionsWithDetails: SubmissionWithDetails[] = submissions.map(submission => {
        const task = room.tasks.find(t => t.id === submission.taskId);
        return {
            ...submission.toObject(),
            taskDetails: task,
            playerName: (submission.playerId as any).name
        } as SubmissionWithDetails;
    });


    const totalPages = Math.ceil(totalCount / limitNum);

    res.json(createApiResponse(
      true,
      {
        submissions: submissionsWithDetails,
        pagination: {
          currentPage: pageNum,
          totalPages,
          totalCount,
          hasNext: pageNum < totalPages,
          hasPrev: pageNum > 1
        }
      }
    ));
  };

  // Approve/Reject Submission (Mentor)
  public reviewSubmission = async (req: Request<{ submissionId: string }, ApiResponse, ReviewSubmissionRequest>, res: Response<ApiResponse>): Promise<void> => {
    const { submissionId } = req.params;
    const { status, feedback, points = 0 } = req.body;

    if (!submissionId?.trim()) {
      throw new CustomError('Submission ID is required', 400);
    }

    if (!['approved', 'rejected'].includes(status)) {
      throw new CustomError('Status must be either approved or rejected', 400);
    }

    if (status === 'approved' && (typeof points !== 'number' || points < 0)) {
      throw new CustomError('Points must be a non-negative number for approved submissions', 400);
    }

    const submission = await Submission.findById(submissionId).populate('playerId');
    if (!submission) {
      throw new CustomError('Submission not found', 404);
    }

    // Get room and task details
    const room = await Room.findOne({ roomCode: submission.roomCode });
    if (!room) {
      throw new CustomError('Room not found', 404);
    }

    const task = room.tasks.find(t => t.id === submission.taskId);
    if (!task) {
      throw new CustomError('Task not found', 404);
    }

    const previousStatus = submission.status;
    
    submission.status = status;
    submission.mentorFeedback = feedback?.trim() || '';
    submission.points = status === 'approved' ? points : 0;

    await submission.save();

    // Update player points and completed tasks
    const player = await Player.findById(submission.playerId);
    if (player) {
      if (status === 'approved' && previousStatus !== 'approved') {
        // First time approval
        player.totalPoints += points;
        player.completedTasks += 1;
      } else if (status === 'rejected' && previousStatus === 'approved') {
        // Previously approved, now rejected
        player.totalPoints = Math.max(0, player.totalPoints - (submission.points || 0));
        player.completedTasks = Math.max(0, player.completedTasks - 1);
      } else if (status === 'approved' && previousStatus === 'approved') {
        // Re-approval with different points
        const oldPoints = submission.points || 0;
        player.totalPoints = player.totalPoints - oldPoints + points;
      }
      
      await player.save();
    }

    // Emit socket events
    this.socketManager.emitSubmissionReviewed(submission.roomCode, submission, task.title);

    // Update leaderboard
    const players = await Player.find({ roomCode: submission.roomCode })
      .sort({ totalPoints: -1, completedTasks: -1 })
      .lean();

    const leaderboard = players.map((player, index) => ({
      rank: index + 1,
      playerId: player._id.toString(),
      name: player.name,
      points: player.totalPoints,
      completedTasks: player.completedTasks,
      joinedAt: player.joinedAt
    }));

    this.socketManager.emitLeaderboardUpdated(submission.roomCode, leaderboard);

    res.json(createApiResponse(
      true,
      { submission },
      `Submission ${status} successfully`
    ));
  };

  // Get Submission Photo
  public getSubmissionPhoto = async (req: Request, res: Response): Promise<void> => {
    const { submissionId } = req.params;

    if (!submissionId?.trim()) {
      throw new CustomError('Submission ID is required', 400);
    }

    const submission = await Submission.findById(submissionId);
    if (!submission) {
      throw new CustomError('Submission not found', 404);
    }

    const photoPath = path.resolve(submission.photoPath);

    if (!await fileExists(photoPath)) {
      throw new CustomError('Photo file not found', 404);
    }

    // Set appropriate headers
    res.setHeader('Content-Type', 'image/jpeg');
    res.setHeader('Cache-Control', 'public, max-age=3600'); // Cache for 1 hour

    res.sendFile(photoPath);
  };

  // Get Player Submissions
  public getPlayerSubmissions = async (req: Request, res: Response<ApiResponse>): Promise<void> => {
    const { playerId } = req.params;
    const { status, page = '1', limit = '10' } = req.query;

    if (!playerId?.trim()) {
      throw new CustomError('Player ID is required', 400);
    }

    const player = await Player.findById(playerId);
    if (!player) {
      throw new CustomError('Player not found', 404);
    }

    const pageNum = parseInt(page as string, 10);
    const limitNum = parseInt(limit as string, 10);

    if (pageNum < 1 || limitNum < 1 || limitNum > 50) {
      throw new CustomError('Invalid pagination parameters', 400);
    }

    const filter: any = { playerId };
    if (status && ['pending', 'approved', 'rejected'].includes(status as string)) {
      filter.status = status;
    }

    const skip = (pageNum - 1) * limitNum;

    const [submissions, totalCount] = await Promise.all([
      Submission.find(filter)
        .sort({ submittedAt: -1 })
        .skip(skip)
        .limit(limitNum),
      Submission.countDocuments(filter)
    ]);

    // Get room and task details for each submission
    const submissionsWithDetails = await Promise.all(
      submissions.map(async (submission) => {
        const room = await Room.findOne({ roomCode: submission.roomCode });
        const task = room?.tasks.find(t => t.id === submission.taskId);
        
        return {
          ...submission.toObject(),
          taskDetails: task,
          roomName: room?.roomName
        };
      })
    );

    const totalPages = Math.ceil(totalCount / limitNum);

    res.json(createApiResponse(
      true,
      {
        submissions: submissionsWithDetails,
        pagination: {
          currentPage: pageNum,
          totalPages,
          totalCount,
          hasNext: pageNum < totalPages,
          hasPrev: pageNum > 1
        }
      }
    ));
  };

  // Delete Submission (Player - only pending submissions)
  public deleteSubmission = async (req: Request, res: Response<ApiResponse>): Promise<void> => {
    const { submissionId } = req.params;

    if (!submissionId?.trim()) {
      throw new CustomError('Submission ID is required', 400);
    }

    const submission = await Submission.findById(submissionId);
    if (!submission) {
      throw new CustomError('Submission not found', 404);
    }

    if (submission.status !== 'pending') {
      throw new CustomError('Only pending submissions can be deleted', 400);
    }

    // Delete the photo file
    if (await fileExists(submission.photoPath)) {
      fs.unlinkSync(submission.photoPath);
    }

    await Submission.findByIdAndDelete(submissionId);

    res.json(createApiResponse(
      true,
      undefined,
      'Submission deleted successfully'
    ));
  };
}