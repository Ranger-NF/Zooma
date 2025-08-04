import { Router } from 'express';
import { upload, handleUploadError } from '../middleware/upload';
import { asyncHandler } from '../middleware/errorHandler';
import { RoomController } from '../controllers/roomController';
import { TaskController } from '../controllers/taskController';
import { SubmissionController } from '../controllers/submissionController';
import { AnalyticsController } from '../controllers/analyticsController';

const router = Router();

// Initialize controllers
const roomController = new RoomController();
const taskController = new TaskController();
const submissionController = new SubmissionController();
const analyticsController = new AnalyticsController();

// Room Routes
router.post('/rooms/create', asyncHandler(roomController.createRoom));
router.post('/rooms/join', asyncHandler(roomController.joinRoom));
router.get('/rooms/:roomCode', asyncHandler(roomController.getRoomDetails));
router.post('/rooms/:roomCode/tasks', asyncHandler(roomController.addTasks));
router.put('/rooms/:roomCode/status', asyncHandler(roomController.updateRoomStatus));
router.delete('/rooms/:roomCode/tasks/:taskId', asyncHandler(roomController.deleteTask));
router.get('/rooms/:roomCode/updates', asyncHandler(roomController.getRoomUpdates));

// Task Routes
router.get('/rooms/:roomCode/tasks/:playerId', asyncHandler(taskController.getPlayerTasks));
router.get('/rooms/:roomCode/tasks/:taskId/stats', asyncHandler(taskController.getTaskStatistics));
router.get('/mentor/:roomCode/tasks', asyncHandler(taskController.getRoomTasks));
router.put('/rooms/:roomCode/tasks/:taskId', asyncHandler(taskController.updateTask));

// Submission Routes
router.post(
  '/submissions/:roomCode/:playerId/:taskId',
  upload.single('photo'),
  handleUploadError,
  asyncHandler(submissionController.submitTaskPhoto)
);
router.get('/mentor/:roomCode/submissions', asyncHandler(submissionController.getSubmissionsForReview));
router.put('/mentor/submissions/:submissionId', asyncHandler(submissionController.reviewSubmission));
router.get('/submissions/:submissionId/photo', asyncHandler(submissionController.getSubmissionPhoto));
router.get('/players/:playerId/submissions', asyncHandler(submissionController.getPlayerSubmissions));
router.delete('/submissions/:submissionId', asyncHandler(submissionController.deleteSubmission));

// Analytics Routes
router.get('/rooms/:roomCode/leaderboard', asyncHandler(analyticsController.getLeaderboard));
router.get('/players/:playerId/stats', asyncHandler(analyticsController.getPlayerStats));
router.get('/mentor/:roomCode/analytics', asyncHandler(analyticsController.getRoomAnalytics));
router.get('/mentor/:roomCode/submission-trends', asyncHandler(analyticsController.getSubmissionTrends));
router.get('/mentor/:roomCode/player-activity', asyncHandler(analyticsController.getPlayerActivity));

// Health check route
router.get('/health', (req, res) => {
  res.json({
    success: true,
    message: 'Bingo Game API is running',
    timestamp: new Date(),
    uptime: process.uptime()
  });
});

export default router;