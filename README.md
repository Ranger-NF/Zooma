# 🎮 Bingo Game - Real-time Photo Challenge App

[![Flutter](https://img.shields.io/badge/Flutter-3.0+-blue.svg)](https://flutter.dev/)
[![Node.js](https://img.shields.io/badge/Node.js-18+-green.svg)](https://nodejs.org/)
[![TypeScript](https://img.shields.io/badge/TypeScript-5.0+-blue.svg)](https://www.typescriptlang.org/)
[![MongoDB](https://img.shields.io/badge/MongoDB-6.0+-green.svg)](https://www.mongodb.com/)
[![Socket.IO](https://img.shields.io/badge/Socket.IO-4.7+-black.svg)](https://socket.io/)

A modern, real-time multiplayer Bingo game where players complete photo-based tasks in teams, with mentors reviewing submissions and managing leaderboards.

## 📱 Screenshots

<div align="center">
  <img src="screenshots/home.png" width="200" alt="Home Screen"/>
  <img src="screenshots/tasks.png" width="200" alt="Tasks Screen"/>
  <img src="screenshots/leaderboard.png" width="200" alt="Leaderboard"/>
  <img src="screenshots/mentor.png" width="200" alt="Mentor Dashboard"/>
</div>

## ✨ Features

### 🎯 Core Gameplay
- **Room-based multiplayer** - Mentors create rooms, players join with codes
- **Photo-based tasks** - Players complete challenges by taking photos
- **Real-time updates** - Live scoring, leaderboards, and notifications
- **Mentor approval system** - Review and approve/reject task submissions
- **Dynamic scoring** - Points awarded based on task difficulty

### 🚀 Technical Features
- **Cross-platform mobile app** - Built with Flutter
- **Real-time communication** - Socket.IO for instant updates
- **Image processing** - Automatic photo optimization and compression
- **Secure file handling** - Validated uploads with size/type restrictions
- **RESTful API** - Clean, documented backend endpoints
- **MongoDB integration** - Scalable NoSQL database


## 🚀 Quick Start

### Prerequisites
- Node.js 18+
- Flutter 3.0+
- MongoDB (local or Atlas)
- Android Studio/Xcode for mobile development

### 📦 Installation

1. **Clone the repository**
```bash
git clone https://github.com/yourusername/bingo-game.git
cd bingo-game
```

2. **Backend Setup**
```bash
cd backend
npm install
cp .env.example .env
# Configure your MongoDB URI in .env
npm run dev
```

3. **Frontend Setup**
```bash
cd frontend
flutter pub get
flutter run
```



## 🎮 How to Play

### For Mentors (Game Masters):
1. **Create Room** - Generate a unique 6-character room code
2. **Share Code** - Give the code to players to join
3. **Monitor Players** - Watch real-time player activity
4. **Review Submissions** - Approve or reject photo submissions
5. **Manage Leaderboard** - View final scores and rankings

### For Players:
1. **Join Room** - Enter the room code provided by mentor
2. **Complete Tasks** - Take photos for assigned challenges
3. **Submit Photos** - Upload images for mentor review
4. **Earn Points** - Get scored based on approved submissions
5. **Climb Leaderboard** - Compete with other players

## 📊 API Documentation

### 🏠 Room Management

| Method | Endpoint | Description |
|--------|----------|-------------|
| `POST` | `/api/rooms` | Create new room (mentor) |
| `POST` | `/api/rooms/:code/join` | Join existing room (player) |
| `GET` | `/api/rooms/:code` | Get room details |
| `GET` | `/api/rooms/:code/leaderboard` | Get current leaderboard |

### 📸 Task Management

| Method | Endpoint | Description |
|--------|----------|-------------|
| `POST` | `/api/tasks/:taskId/submit` | Submit task photo |
| `POST` | `/api/tasks/:taskId/review` | Approve/reject submission |
| `GET` | `/api/tasks/submissions/:roomCode` | Get pending submissions |

### 🔄 Real-time Events

| Event | Direction | Description |
|-------|-----------|-------------|
| `joinRoom` | Client → Server | Join room for updates |
| `roomUpdated` | Server → Client | Room state changed |
| `taskSubmitted` | Server → Client | New task submission |
| `taskReviewed` | Server → Client | Submission approved/rejected |

## 🗂️ Project Structure

```
bingo-game/
├── 📱 frontend/                 # Flutter mobile app
│   ├── lib/
│   │   ├── models/             # Data models
│   │   ├── screens/            # UI screens
│   │   ├── services/           # API & business logic
│   │   └── main.dart           # App entry point
│   └── pubspec.yaml            # Flutter dependencies
├── 🚀 backend/                 # Express.js API server
│   ├── src/
│   │   ├── models/             # MongoDB schemas
│   │   ├── routes/             # API endpoints
│   │   └── server.ts           # Server entry point
│   ├── uploads/                # Image storage
│   └── package.json            # Node.js dependencies
└── 📚 docs/                    # Documentation
```

## 🔧 Development

### Running in Development Mode

**Backend:**
```bash
cd backend
npm run dev  # Runs with nodemon for auto-restart
```

**Frontend:**
```bash
cd frontend
flutter run  # Hot reload enabled
```

### Building for Production

**Backend:**
```bash
npm run build  # Compile TypeScript
npm start      # Run compiled JavaScript
```

**Frontend:**
```bash
flutter build apk              # Android
flutter build ios              # iOS
flutter build web              # Web (if needed)
```

## 🧪 Testing

```bash
# Backend tests
cd backend
npm test

# Frontend tests
cd frontend
flutter test

# Integration tests
flutter integration_test
```

## 🚀 Deployment

### Backend Deployment (Heroku Example)

```bash
# Install Heroku CLI
heroku create your-app-name
heroku config:set MONGODB_URI=your_mongodb_atlas_uri
git push heroku main
```

### Mobile App Deployment

1. **Android**: Build APK and upload to Google Play Store
2. **iOS**: Build IPA and upload to App Store Connect

## 🛠️ Tech Stack

### Frontend
- **Flutter** - Cross-platform mobile framework
- **Dart** - Programming language
- **Provider** - State management
- **Socket.IO Client** - Real-time communication
- **Image Picker** - Camera integration
- **HTTP** - API communication

### Backend
- **Node.js** - Runtime environment
- **Express.js** - Web framework
- **TypeScript** - Type-safe JavaScript
- **Socket.IO** - WebSocket communication
- **MongoDB** - NoSQL database
- **Mongoose** - MongoDB object modeling
- **Multer** - File upload handling
- **Sharp** - Image processing

## 🤝 Contributing

We welcome contributions! Please see our [Contributing Guide](CONTRIBUTING.md) for details.

### Development Workflow
1. Fork the repository
2. Create a feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes (`git commit -m 'Add amazing feature'`)
4. Push to the branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

### Code Style
- **Backend**: ESLint + Prettier
- **Frontend**: Dart formatter
- **Commits**: Conventional Commits format

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## 🙏 Acknowledgments

- **Flutter Team** - For the amazing cross-platform framework
- **Express.js Community** - For the robust web framework
- **MongoDB** - For the flexible database solution
- **Socket.IO** - For real-time communication capabilities

## 📞 Support
- 🐛 **Issues**: [GitHub Issues](https://github.com/Muflih-uk/Bingo/issues)

## 🔮 Roadmap

- [ ] **Web Dashboard** - Browser-based mentor interface
- [ ] **Custom Tasks** - Mentors can create custom challenges
- [ ] **Team Mode** - Multiple teams competing
- [ ] **Achievement System** - Badges and rewards
- [ ] **Analytics Dashboard** - Game statistics and insights
- [ ] **Offline Mode** - Play without internet connection
- [ ] **Video Tasks** - Support for video submissions
- [ ] **AR Integration** - Augmented reality challenges

---

<div align="center">
  <strong>Built with ❤️ for fun and learning</strong>
  <br>
  <a href="#top">⬆️ Back to top</a>
</div>
