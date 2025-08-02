import express, { Request, Response } from 'express';
import { Room } from '../models/Room';
import { v4 as uuidv4 } from 'uuid';

const router = express.Router();

// Generate random room code
const generateRoomCode = (): string => {
  const characters = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';
  let result = '';
  for (let i = 0; i < 6; i++) {
    result += characters.charAt(Math.floor(Math.random() * characters.length));
  }
  return result;
};

// Create default tasks
const createDefaultTasks = () => [
  {
    _id: uuidv4(),
    title: 'Team Photo',
    description: 'Take a photo with your entire team',
    points: 15,
    requiresPhoto: true,
    submissions: []
  },
  {
    _id: uuidv4(),
    title: 'Find Something Red',
    description: 'Find and photograph something red in your environment',
    points: 10,
    requiresPhoto: true,
    submissions: []
  },
  {
    _id: uuidv4(),
    title: 'Creative Pose',
    description: 'Strike a creative pose and take a photo',
    points: 12,
    requiresPhoto: true,
    submissions: []
  },
  {
    _id: uuidv4(),
    title: 'Nature Shot',
    description: 'Take a photo of something from nature',
    points: 8,
    requiresPhoto: true,
    submissions: []
  },
  {
    _id: uuidv4(),
    title: 'Action Shot',
    description: 'Capture an action moment in a photo',
    points: 20,
    requiresPhoto: true,
    submissions: []
  }
];

// Create room (mentor)
router.post('/', async (req: Request, res: Response) => {
  try {
    const { mentorName } = req.body;

    if (!mentorName) {
      return res.status(400).json({ error: 'Mentor name is required' });
    }

    let roomCode: string;
    let existingRoom;

    do {
      roomCode = generateRoomCode();
      existingRoom = await Room.findOne({ code: roomCode });
    } while (existingRoom);

    const mentorId = uuidv4();
    const mentor = {
      _id: mentorId,
      name: mentorName,
      avatar: '👨‍🏫',
      score: 0,
      completedTasks: [],
      joinedAt: new Date()
    };

    const room = new Room({
      code: roomCode,
      mentorId,
      mentorName,
      players: [mentor],
      tasks: createDefaultTasks(),
      isActive: true
    });

    await room.save();

    res.status(201).json({
      message: 'Room created successfully',
      room,
      mentor
    });
  } catch (error) {
    console.error('Error creating room:', error);
    res.status(500).json({ error: 'Internal server error' });
  }
});

// Join room (player)
router.post('/:code/join', async (req: Request, res: Response) => {
  try {
    const { code } = req.params;
    const { playerName } = req.body;

    if (!playerName) {
      return res.status(400).json({ error: 'Player name is required' });
    }

    const room = await Room.findOne({ code: code.toUpperCase(), isActive: true });

    if (!room) {
      return res.status(404).json({ error: 'Room not found or not active' });
    }

    const existingPlayer = room.players.find(p => p.name === playerName);
    if (existingPlayer) {
      return res.status(400).json({ error: 'Player name already taken' });
    }

    const playerId = uuidv4();
    const avatars = ['👤', '👨', '👩', '🧑', '👦', '👧', '🙂', '😊'];
    const newPlayer = {
      _id: playerId,
      name: playerName,
      avatar: avatars[Math.floor(Math.random() * avatars.length)],
      score: 0,
      completedTasks: [],
      joinedAt: new Date()
    };

    room.players.push(newPlayer);
    await room.save();

    const io = req.app.get('io');
    io.to(code.toUpperCase()).emit('roomUpdated', room);

    res.json({
      message: 'Joined room successfully',
      room,
      player: newPlayer
    });
  } catch (error) {
    console.error('Error joining room:', error);
    res.status(500).json({ error: 'Internal server error' });
  }
});

// Get room details
router.get('/:code', async (req: Request, res: Response) => {
  try {
    const { code } = req.params;

    const room = await Room.findOne({ code: code.toUpperCase() });

    if (!room) {
      return res.status(404).json({ error: 'Room not found' });
    }

    res.json(room);
  } catch (error) {
    console.error('Error fetching room:', error);
    res.status(500).json({ error: 'Internal server error' });
  }
});

// Get leaderboard
router.get('/:code/leaderboard', async (req: Request, res: Response) => {
  try {
    const { code } = req.params;

    const room = await Room.findOne({ code: code.toUpperCase() });

    if (!room) {
      return res.status(404).json({ error: 'Room not found' });
    }

    const sortedPlayers = room.players
    .sort((a, b) => b.score - a.score)
    .map((player, index) => ({
        ...player,
        rank: index + 1
    }));


    res.json({
      leaderboard: sortedPlayers,
      totalPlayers: room.players.length
    });
  } catch (error) {
    console.error('Error fetching leaderboard:', error);
    res.status(500).json({ error: 'Internal server error' });
  }
});

export default router;
