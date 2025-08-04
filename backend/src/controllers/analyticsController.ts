import { Request, Response } from 'express';
import { Room, Player, Submission } from '../models';
import { 
  ApiResponse, 
  LeaderboardEntry, 
  PlayerStats, 
  RoomAnalytics 
} from '../types';
import { 
  isValidRoomCode, 
  createApiResponse 
} from '../utils/helpers';
import { CustomError } from '../middleware/errorHandler';

export class AnalyticsController {

  // Get Leaderboard
  public getLeaderboard = async (req: Request, res: Response<ApiResponse>): Promise<void> => {
    const { roomCode } = req.params;
    const { limit = '50' } = req.query;

    if (!isValidRoomCode(roomCode)) {
      throw new CustomError('Invalid room code format', 400);
    }

    const limitNum = parseInt(limit as string, 10);
    if (limitNum < 1 || limitNum > 100) {
      throw new CustomError('Limit must be between 1 and 100', 400);
    }

    // Verify room exists
    const room = await Room.findOne({ roomCode });
    if (!room) {
      throw new CustomError('Room not found', 404);
    }

    const players = await Player.find({ roomCode })
      .sort({ totalPoints: -1, completedTasks: -1, joinedAt: 1 })
      .limit(limitNum)
      .lean();

    const leaderboard: LeaderboardEntry[] = players.map((player, index) => ({
      rank: index + 1,
      playerId: player._id.toString(),
      name: player.name,
      points: player.totalPoints,
      completedTasks: player.completedTasks,
      joinedAt: player.joinedAt
    }));

    res.json(createApiResponse(
      true,
      { 
        leaderboard,
        totalPlayers: await Player.countDocuments({ roomCode })
      }
    ));
  };

  // Get Player Statistics
  public getPlayerStats = async (req: Request, res: Response<ApiResponse>): Promise<void> => {
    const { playerId } = req.params;

    if (!playerId?.trim()) {
      throw new CustomError('Player ID is required', 400);
    }

    const player = await Player.findById(playerId);
    if (!player) {
      throw new CustomError('Player not found', 404);
    }

    const [
      submissions,
      roomData,
      playerRank
    ] = await Promise.all([
      Submission.find({ playerId }),
      Room.findOne({ roomCode: player.roomCode }),
      Player.countDocuments({
        roomCode: player.roomCode,
        $or: [
          { totalPoints: { $gt: player.totalPoints } },
          { 
            totalPoints: player.totalPoints,
            completedTasks: { $gt: player.completedTasks }
          },
          {
            totalPoints: player.totalPoints,
            completedTasks: player.completedTasks,
            joinedAt: { $lt: player.joinedAt }
          }
        ]
      })
    ]);

    const approvedSubmissions = submissions.filter(sub => sub.status === 'approved');
    const pendingSubmissions = submissions.filter(sub => sub.status === 'pending');
    const rejectedSubmissions = submissions.filter(sub => sub.status === 'rejected');

    const stats: PlayerStats = {
      totalPoints: player.totalPoints,
      completedTasks: player.completedTasks,
      totalSubmissions: submissions.length,
      approvedSubmissions: approvedSubmissions.length,
      pendingSubmissions: pendingSubmissions.length,
      rejectedSubmissions: rejectedSubmissions.length
    };

    const totalTasks = roomData?.tasks.length || 0;
    const completionRate = totalTasks > 0 
      ? Math.round((player.completedTasks / totalTasks) * 100) 
      : 0;

    res.json(createApiResponse(
      true,
      {
        player: {
          id: player._id,
          name: player.name,
          roomCode: player.roomCode,
          joinedAt: player.joinedAt
        },
        stats,
        rank: playerRank + 1,
        completionRate,
        roomInfo: {
          roomName: roomData?.roomName,
          totalTasks
        }
      }
    ));
  };

  // Get Room Analytics (Mentor)
  public getRoomAnalytics = async (req: Request, res: Response<ApiResponse>): Promise<void> => {
    const { roomCode } = req.params;
    const { period = '7d' } = req.query;

    if (!isValidRoomCode(roomCode)) {
      throw new CustomError('Invalid room code format', 400);
    }

    const validPeriods = ['1d', '7d', '30d', 'all'];
    if (!validPeriods.includes(period as string)) {
      throw new CustomError('Invalid period. Must be 1d, 7d, 30d, or all', 400);
    }

    const room = await Room.findOne({ roomCode });
    if (!room) {
      throw new CustomError('Room not found', 404);
    }

    // Calculate date filter based on period
    let dateFilter = {};
    if (period !== 'all') {
      const days = parseInt(period as string);
      const startDate = new Date();
      startDate.setDate(startDate.getDate() - days);
      dateFilter = { createdAt: { $gte: startDate } };
    }

    const [
      players,
      submissions,
      recentSubmissions,
      recentPlayers
    ] = await Promise.all([
      Player.find({ roomCode }),
      Submission.find({ roomCode }),
      period !== 'all' ? Submission.find({ roomCode, ...dateFilter }) : [],
      period !== 'all' ? Player.find({ roomCode, ...dateFilter }) : []
    ]);

    // Calculate top performer
    const topPerformer = players.length > 0 
      ? players.reduce((top, player) => 
          player.totalPoints > top.totalPoints ? player : top
        )
      : null;

    // Calculate task completion rates
    const taskCompletionRates = room.tasks.map(task => {
      const taskSubmissions = submissions.filter(sub => sub.taskId === task.id);
      const approvedSubmissions = taskSubmissions.filter(sub => sub.status === 'approved');
      
      return {
        taskId: task.id,
        taskTitle: task.title,
        totalSubmissions: taskSubmissions.length,
        approvedSubmissions: approvedSubmissions.length,
        completionRate: players.length > 0 
          ? Math.round((approvedSubmissions.length / players.length) * 100)
          : 0
      };
    });

    // Activity trends (for the specified period)
    const activityTrends = [];
    if (period !== 'all') {
      const days = period === '1d' ? 1 : period === '7d' ? 7 : 30;
      for (let i = days - 1; i >= 0; i--) {
        const date = new Date();
        date.setDate(date.getDate() - i);
        date.setHours(0, 0, 0, 0);
        
        const nextDate = new Date(date);
        nextDate.setDate(nextDate.getDate() + 1);

        const daySubmissions = submissions.filter(sub => 
          sub.submittedAt >= date && sub.submittedAt < nextDate
        );

        const dayPlayers = players.filter(player => 
          player.joinedAt >= date && player.joinedAt < nextDate
        );

        activityTrends.push({
          date: date.toISOString().split('T')[0],
          submissions: daySubmissions.length,
          newPlayers: dayPlayers.length
        });
      }
    }

    const analytics: RoomAnalytics & { 
      taskCompletionRates: any[], 
      activityTrends: any[],
      period: string 
    } = {
      totalPlayers: players.length,
      totalTasks: room.tasks.length,
      totalSubmissions: submissions.length,
      pendingReviews: submissions.filter(sub => sub.status === 'pending').length,
      approvedSubmissions: submissions.filter(sub => sub.status === 'approved').length,
      rejectedSubmissions: submissions.filter(sub => sub.status === 'rejected').length,
      averagePointsPerPlayer: players.length > 0 
        ? Math.round(players.reduce((sum, player) => sum + player.totalPoints, 0) / players.length)
        : 0,
      topPerformer,
      taskCompletionRates,
      activityTrends,
      period: period as string
    };

    res.json(createApiResponse(
      true,
      { analytics }
    ));
  };

  // Get Submission Trends
  public getSubmissionTrends = async (req: Request, res: Response<ApiResponse>): Promise<void> => {
    const { roomCode } = req.params;
    const { days = '7' } = req.query;

    if (!isValidRoomCode(roomCode)) {
      throw new CustomError('Invalid room code format', 400);
    }

    const daysNum = parseInt(days as string, 10);
    if (daysNum < 1 || daysNum > 90) {
      throw new CustomError('Days must be between 1 and 90', 400);
    }

    // Verify room exists
    const room = await Room.findOne({ roomCode });
    if (!room) {
      throw new CustomError('Room not found', 404);
    }

    const startDate = new Date();
    startDate.setDate(startDate.getDate() - daysNum);
    startDate.setHours(0, 0, 0, 0);

    const submissions = await Submission.find({
      roomCode,
      submittedAt: { $gte: startDate }
    });

    const trends = [];
    for (let i = daysNum - 1; i >= 0; i--) {
      const date = new Date();
      date.setDate(date.getDate() - i);
      date.setHours(0, 0, 0, 0);
      
      const nextDate = new Date(date);
      nextDate.setDate(nextDate.getDate() + 1);

      const daySubmissions = submissions.filter(sub => 
        sub.submittedAt >= date && sub.submittedAt < nextDate
      );

      trends.push({
        date: date.toISOString().split('T')[0],
        total: daySubmissions.length,
        approved: daySubmissions.filter(sub => sub.status === 'approved').length,
        pending: daySubmissions.filter(sub => sub.status === 'pending').length,
        rejected: daySubmissions.filter(sub => sub.status === 'rejected').length
      });
    }

    res.json(createApiResponse(
      true,
      {
        trends,
        period: `${daysNum} days`,
        totalSubmissions: submissions.length
      }
    ));
  };

  // Get Player Activity Summary
  public getPlayerActivity = async (req: Request, res: Response<ApiResponse>): Promise<void> => {
    const { roomCode } = req.params;

    if (!isValidRoomCode(roomCode)) {
      throw new CustomError('Invalid room code format', 400);
    }

    // Verify room exists
    const room = await Room.findOne({ roomCode });
    if (!room) {
      throw new CustomError('Room not found', 404);
    }

    const players = await Player.find({ roomCode }).lean();
    
    const playerActivity = await Promise.all(
      players.map(async (player) => {
        const submissions = await Submission.find({ playerId: player._id });
        const lastSubmission = submissions.length > 0 
          ? submissions.sort((a, b) => b.submittedAt.getTime() - a.submittedAt.getTime())[0]
          : null;

        return {
          playerId: player._id,
          playerName: player.name,
          totalPoints: player.totalPoints,
          completedTasks: player.completedTasks,
          totalSubmissions: submissions.length,
          lastActivity: lastSubmission?.submittedAt || player.joinedAt,
          joinedAt: player.joinedAt,
          isActive: lastSubmission 
            ? (new Date().getTime() - lastSubmission.submittedAt.getTime()) < (24 * 60 * 60 * 1000) // Active if submitted in last 24 hours
            : false
        };
      })
    );

    // Sort by last activity
    playerActivity.sort((a, b) => b.lastActivity.getTime() - a.lastActivity.getTime());

    const activePlayersCount = playerActivity.filter(p => p.isActive).length;
    const averageCompletionRate = players.length > 0 
      ? Math.round((players.reduce((sum, p) => sum + p.completedTasks, 0) / players.length / room.tasks.length) * 100)
      : 0;

    res.json(createApiResponse(
      true,
      {
        playerActivity,
        summary: {
          totalPlayers: players.length,
          activePlayers: activePlayersCount,
          averageCompletionRate,
          totalTasks: room.tasks.length
        }
      }
    ));
  };
}