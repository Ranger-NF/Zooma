import express, { Request, Response } from 'express';
import type { File as MulterFile } from 'multer';
import multer from 'multer';
import sharp from 'sharp';
import path from 'path';
import fs from 'fs';
import { Room } from '../models/Room';

const router = express.Router();

// Configure multer for file uploads
const storage = multer.diskStorage({
  destination: (_req, _file, cb) => {
    cb(null, 'uploads/tasks');
  },
  filename: (_req, file, cb) => {
    cb(null, Date.now() + '-' + file.originalname);
  }

  // destination: (
  //   req: Request, 
  //   file: Express.Multer.File, 
  //   cb: (error: Error | null, destination: string) => void) => {
  //   const uploadDir = 'uploads/tasks';
  //   if (!fs.existsSync(uploadDir)) {
  //     fs.mkdirSync(uploadDir, { recursive: true });
  //   }
  //   cb(null, uploadDir);
  // },
  // filename: (req, file, cb) => {
  //   const uniqueSuffix = Date.now() + '-' + Math.round(Math.random() * 1E9);
  //   cb(null, `task-${uniqueSuffix}${path.extname(file.originalname)}`);
  // }
});

const upload = multer({
  storage: storage,
  limits: {
    fileSize: 10 * 1024 * 1024 // 10MB limit
  },
  fileFilter: (
  req: Request,
  file: Express.Multer.File,
  cb: multer.FileFilterCallback
  ) => {
    if (file.mimetype.startsWith('image/')) {
      cb(null, true);
    } else {
      cb(new Error('Only image files are allowed'));
    }
  }
})


// Submit task with photo
router.post('/:taskId/submit', upload.single('photo'), async (req: Request, res: Response) => {
  try {
    const { taskId } = req.params;
    const { playerId, roomCode } = req.body;
    
    if (!playerId || !roomCode) {
      return res.status(400).json({ error: 'Player ID and room code are required' });
    }

    if (!req.file) {
      return res.status(400).json({ error: 'Photo is required' });
    }

    const room = await Room.findOne({ code: roomCode.toUpperCase() });
    if (!room) {
      return res.status(404).json({ error: 'Room not found' });
    }

    const task = room.tasks.find(t => t._id.toString() === taskId);
    if (!task) {
      return res.status(404).json({ error: 'Task not found' });
    }

    const player = room.players.find(p => p._id.toString() === playerId);
    if (!player) {
      return res.status(404).json({ error: 'Player not found' });
    }

    // Check if task already submitted by this player
    const existingSubmission = task.submissions.find(s => s.playerId === playerId);
    if (existingSubmission) {
      return res.status(400).json({ error: 'Task already submitted' });
    }

    // Optimize and save the image
    const optimizedImagePath = `uploads/tasks/optimized-${req.file.filename}`;
    await sharp(req.file.path)
      .resize(800, 600, { fit: 'inside', withoutEnlargement: true })
      .jpeg({ quality: 80 })
      .toFile(optimizedImagePath);

    // Remove original file
    fs.unlinkSync(req.file.path);

    // Add submission to task
    task.submissions.push({
      playerId: playerId,
      photoUrl: optimizedImagePath,
      submittedAt: new Date(),
      approved: false // Mentor needs to approve
    });

    await room.save();

    // Emit task submission to mentor
    const io = req.app.get('io');
    io.to(roomCode).emit('taskSubmitted', {
      taskId: taskId,
      playerId: playerId,
      playerName: player.name,
      photoUrl: optimizedImagePath
    });

    res.json({
      message: 'Task submitted successfully',
      submission: task.submissions[task.submissions.length - 1]
    });
  } catch (error) {
    console.error('Error submitting task:', error);
    res.status(500).json({ error: 'Internal server error' });
  }
});

// Approve/reject task submission (mentor only)
router.post('/:taskId/review', async (req: Request, res: Response) => {
  try {
    const { taskId } = req.params;
    const { playerId, roomCode, approved, mentorId } = req.body;

    const room = await Room.findOne({ code: roomCode.toUpperCase() });
    if (!room) {
      return res.status(404).json({ error: 'Room not found' });
    }

    // Verify mentor
    if (room.mentorId !== mentorId) {
      return res.status(403).json({ error: 'Only mentor can review submissions' });
    }

    const task = room.tasks.find(t => t._id.toString() === taskId);
    if (!task) {
      return res.status(404).json({ error: 'Task not found' });
    }

    const submission = task.submissions.find(s => s.playerId === playerId);
    if (!submission) {
      return res.status(404).json({ error: 'Submission not found' });
    }

    submission.approved = approved;

    if (approved) {
      // Add points to player
      const player = room.players.find(p => p._id.toString() === playerId);
      if (player) {
        player.score += task.points;
        player.completedTasks.push(taskId);
      }
    }

    await room.save();

    // Emit update to all room members
    const io = req.app.get('io');
    io.to(roomCode).emit('roomUpdated', room);
    io.to(roomCode).emit('taskReviewed', {
      taskId: taskId,
      playerId: playerId,
      approved: approved,
      points: approved ? task.points : 0
    });

    res.json({
      message: approved ? 'Task approved successfully' : 'Task rejected',
      room: room
    });
  } catch (error) {
    console.error('Error reviewing task:', error);
    res.status(500).json({ error: 'Internal server error' });
  }
});

// Get task submissions for mentor review
router.get('/submissions/:roomCode', async (req: Request, res: Response) => {
  try {
    const { roomCode } = req.params;
    
    const room = await Room.findOne({ code: roomCode.toUpperCase() });
    if (!room) {
      return res.status(404).json({ error: 'Room not found' });
    }

    const pendingSubmissions = [];
    
    for (const task of room.tasks) {
      for (const submission of task.submissions) {
        if (!submission.approved) {
          const player = room.players.find(p => p._id.toString() === submission.playerId);
          pendingSubmissions.push({
            taskId: task._id,
            taskTitle: task.title,
            taskPoints: task.points,
            playerId: submission.playerId,
            playerName: player?.name,
            photoUrl: submission.photoUrl,
            submittedAt: submission.submittedAt
          });
        }
      }
    }

    res.json({
      pendingSubmissions: pendingSubmissions,
      totalPending: pendingSubmissions.length
    });
  } catch (error) {
    console.error('Error fetching submissions:', error);
    res.status(500).json({ error: 'Internal server error' });
  }
});

export default router;