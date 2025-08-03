import express from 'express';
import { Room } from '../models/Room';
import { v4 as uuidv4 } from 'uuid';

// Type definitions to avoid conflicts
type Req = any;
type Res = any;

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
router.post('/', async (req: Req, res: Res) => {
  try {
    const { mentorName } = req.body;

    if (!mentorName || typeof mentorName !== 'string' || mentorName.trim().length === 0) {
      return res.status(400).json({ error: 'Mentor name is required and must be a valid string' });
    }

    let roomCode: string;
    let existingRoom;

    // Generate unique room code
    do {
      roomCode = generateRoomCode();
      existingRoom = await Room.findOne({ code: roomCode });
    } while (existingRoom);

    const mentorId = uuidv4();
    const mentor = {
      _id: mentorId,
      name: mentorName.trim(),
      avatar: '👨‍🏫',
      score: 0,
      completedTasks: [],
      joinedAt: new Date()
    };

    const room = new Room({
      code: roomCode,
      mentorId,
      mentorName: mentorName.trim(),
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
router.post('/:code/join', async (req: Req, res: Res) => {
  try {
    const { code } = req.params;
    const { playerName } = req.body;

    if (!playerName || typeof playerName !== 'string' || playerName.trim().length === 0) {
      return res.status(400).json({ error: 'Player name is required and must be a valid string' });
    }

    if (!code || typeof code !== 'string') {
      return res.status(400).json({ error: 'Valid room code is required' });
    }

    const room = await Room.findOne({ code: code.toUpperCase(), isActive: true });

    if (!room) {
      return res.status(404).json({ error: 'Room not found or not active' });
    }

    // Check if player name already exists (case-insensitive)
    const existingPlayer = room.players.find(p => 
      p.name.toLowerCase() === playerName.trim().toLowerCase()
    );
    if (existingPlayer) {
      return res.status(400).json({ error: 'Player name already taken' });
    }

    // Check room capacity (optional - add max players limit)
    const MAX_PLAYERS = 20;
    if (room.players.length >= MAX_PLAYERS) {
      return res.status(400).json({ error: 'Room is full' });
    }

    const playerId = uuidv4();
    const avatars = ['👤', '👨', '👩', '🧑', '👦', '👧', '🙂', '😊', '🎮', '🌟'];
    const newPlayer = {
      _id: playerId,
      name: playerName.trim(),
      avatar: avatars[Math.floor(Math.random() * avatars.length)],
      score: 0,
      completedTasks: [],
      joinedAt: new Date()
    };

    room.players.push(newPlayer);
    await room.save();

    // Emit room update via Socket.IO (with null check)
    try {
      const io = req.app.get('io');
      if (io) {
        io.to(code.toUpperCase()).emit('roomUpdated', room);
        io.to(code.toUpperCase()).emit('playerJoined', {
          player: newPlayer,
          totalPlayers: room.players.length
        });
      }
    } catch (socketError) {
      console.warn('Socket.IO emit failed:', socketError);
      // Continue execution - room was still created successfully
    }

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
router.get('/:code', async (req: Req, res: Res) => {
  try {
    const { code } = req.params;

    if (!code || typeof code !== 'string') {
      return res.status(400).json({ error: 'Valid room code is required' });
    }

    const room = await Room.findOne({ code: code.toUpperCase() });

    if (!room) {
      return res.status(404).json({ error: 'Room not found' });
    }

    // Don't send sensitive mentor information to non-mentors
    const sanitizedRoom = {
      ...room.toObject(),
      // Remove sensitive fields if needed
    };

    res.json(sanitizedRoom);
  } catch (error) {
    console.error('Error fetching room:', error);
    res.status(500).json({ error: 'Internal server error' });
  }
});

// Get leaderboard
router.get('/:code/leaderboard', async (req: Req, res: Res) => {
  try {
    const { code } = req.params;

    if (!code || typeof code !== 'string') {
      return res.status(400).json({ error: 'Valid room code is required' });
    }

    const room = await Room.findOne({ code: code.toUpperCase() });

    if (!room) {
      return res.status(404).json({ error: 'Room not found' });
    }

    const sortedPlayers = room.players
      .sort((a, b) => {
        // Sort by score descending, then by joinedAt ascending (earlier players first for ties)
        if (b.score !== a.score) {
          return b.score - a.score;
        }
        return new Date(a.joinedAt).getTime() - new Date(b.joinedAt).getTime();
      })
      .map((player, index) => ({
        _id: player._id,
        name: player.name,
        avatar: player.avatar,
        score: player.score,
        completedTasks: player.completedTasks?.length || 0,
        rank: index + 1,
        joinedAt: player.joinedAt
      }));

    res.json({
      leaderboard: sortedPlayers,
      totalPlayers: room.players.length,
      roomCode: room.code,
      isActive: room.isActive
    });
  } catch (error) {
    console.error('Error fetching leaderboard:', error);
    res.status(500).json({ error: 'Internal server error' });
  }
});

// Leave room (player)
router.post('/:code/leave', async (req: Req, res: Res) => {
  try {
    const { code } = req.params;
    const { playerId } = req.body;

    if (!playerId || typeof playerId !== 'string') {
      return res.status(400).json({ error: 'Player ID is required' });
    }

    const room = await Room.findOne({ code: code.toUpperCase() });

    if (!room) {
      return res.status(404).json({ error: 'Room not found' });
    }

    // Don't allow mentor to leave
    if (room.mentorId === playerId) {
      return res.status(400).json({ error: 'Mentor cannot leave the room' });
    }

    const playerIndex = room.players.findIndex(p => p._id.toString() === playerId);
    if (playerIndex === -1) {
      return res.status(404).json({ error: 'Player not found in room' });
    }

    const leavingPlayer = room.players[playerIndex];
    room.players.splice(playerIndex, 1);
    await room.save();

    // Emit room update via Socket.IO
    try {
      const io = req.app.get('io');
      if (io) {
        io.to(code.toUpperCase()).emit('roomUpdated', room);
        io.to(code.toUpperCase()).emit('playerLeft', {
          playerId: playerId,
          playerName: leavingPlayer.name,
          totalPlayers: room.players.length
        });
      }
    } catch (socketError) {
      console.warn('Socket.IO emit failed:', socketError);
    }

    res.json({
      message: 'Left room successfully',
      totalPlayers: room.players.length
    });
  } catch (error) {
    console.error('Error leaving room:', error);
    res.status(500).json({ error: 'Internal server error' });
  }
});

// End room (mentor only)
router.post('/:code/end', async (req: express.Request, res: express.Response) => {
  try {
    const { code } = req.params;
    const { mentorId } = req.body;

    if (!mentorId || typeof mentorId !== 'string') {
      return res.status(400).json({ error: 'Mentor ID is required' });
    }

    const room = await Room.findOne({ code: code.toUpperCase() });

    if (!room) {
      return res.status(404).json({ error: 'Room not found' });
    }

    // Verify mentor
    if (room.mentorId !== mentorId) {
      return res.status(403).json({ error: 'Only the mentor can end the room' });
    }

    room.isActive = false;
    room.endedAt = new Date();
    await room.save();

    // Emit room ended event
    try {
      const io = req.app.get('io');
      if (io) {
        io.to(code.toUpperCase()).emit('roomEnded', {
          message: 'Room has been ended by the mentor',
          finalLeaderboard: room.players.sort((a, b) => b.score - a.score)
        });
      }
    } catch (socketError) {
      console.warn('Socket.IO emit failed:', socketError);
    }

    res.json({
      message: 'Room ended successfully',
      finalLeaderboard: room.players.sort((a, b) => b.score - a.score)
    });
  } catch (error) {
    console.error('Error ending room:', error);
    res.status(500).json({ error: 'Internal server error' });
  }
});

export default router;