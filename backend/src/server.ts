import express from 'express';
import http from 'http';
import { Server } from 'socket.io';
import cors from 'cors';
import mongoose from 'mongoose';
import dotenv from 'dotenv';
import roomRoutes from './routes/rooms';
import taskRoutes from './routes/tasks';
import path from 'path';
import fs from 'fs'; 


dotenv.config();

const corsOptions = {
  origin: process.env.NODE_ENV === 'production' 
    ? ['https://your-flutter-app.com'] // Add your Flutter app domains
    : "*",
  methods: ["GET", "POST", "PUT", "DELETE"],
  credentials: true
};


const app = express();
const server = http.createServer(app);
const io = new Server(server, {
  cors: {
    origin: "*",
    methods: ["GET", "POST"]
  }
});

const uploadsDir = path.join(__dirname, '..', 'uploads');
if (!fs.existsSync(uploadsDir)) {
  fs.mkdirSync(uploadsDir, { recursive: true });
}

// Middleware
app.use(cors(corsOptions));
app.use(cors());
app.use(express.json());
app.use('/uploads', express.static('uploads'));

// Routes
app.use('/api/rooms', roomRoutes);
app.use('/api/tasks', taskRoutes);

// Socket.IO connection handling
io.on('connection', (socket) => {
  console.log('User connected:', socket.id);

  socket.on('joinRoom', (roomCode: string) => {
    socket.join(roomCode);
    console.log(`User ${socket.id} joined room: ${roomCode}`);
  });

  socket.on('leaveRoom', (roomCode: string) => {
    socket.leave(roomCode);
    console.log(`User ${socket.id} left room: ${roomCode}`);
  });

  socket.on('disconnect', () => {
    console.log('User disconnected:', socket.id);
  });
});

app.get('/health', (req, res) => {
  res.status(200).json({ status: 'OK', timestamp: new Date().toISOString() });
});

// Make io accessible to routes
app.set('io', io);

// MongoDB connection
const MONGODB_URI = process.env.MONGODB_URI || 'mongodb://localhost:27017/bingo-game';

mongoose.connect(MONGODB_URI)
  .then(() => {
    console.log('Connected to MongoDB');
  })
  .catch((error) => {
    console.error('MongoDB connection error:', error);
  });

const PORT = process.env.PORT || 3000;

server.listen(PORT, () => {
  console.log(`Server running on port ${PORT}`);
});

export { io };