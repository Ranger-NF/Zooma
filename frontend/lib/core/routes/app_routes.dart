import 'package:flutter/material.dart';
import '../../features/home/views/home_page.dart';
import '../../features/room/views/join_room_page.dart';
import '../../features/room/views/create_room_page.dart';
import '../../features/leaderboard/views/leaderboard_page.dart';
import '../../features/tasks/views/tasks_page.dart';
import '../../features/submissions/views/submit_page.dart';

class AppRoutes {
  static const String home = '/';
  static const String joinRoom = '/join-room';
  static const String createRoom = '/create-room';
  static const String leaderboard = '/leaderboard';
  static const String tasks = '/tasks';
  static const String submit = '/submit';

  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case home:
        return MaterialPageRoute(builder: (_) => const HomePage());
      case joinRoom:
        return MaterialPageRoute(builder: (_) => const JoinRoomPage());
      case createRoom:
        return MaterialPageRoute(builder: (_) => const CreateRoomPage());
      case leaderboard:
        final args = settings.arguments as Map<String, dynamic>?;
        return MaterialPageRoute(
          builder: (_) => LeaderboardPage(roomCode: args?['roomCode'] ?? ''),
        );
      case tasks:
        final args = settings.arguments as Map<String, dynamic>?;
        return MaterialPageRoute(
          builder: (_) => TasksPage(
            roomCode: args?['roomCode'] ?? '',
            playerId: args?['playerId'] ?? '',
          ),
        );
      case submit:
        final args = settings.arguments as Map<String, dynamic>?;
        return MaterialPageRoute(
          builder: (_) => SubmitPage(
            roomCode: args?['roomCode'] ?? '',
            playerId: args?['playerId'] ?? '',
            taskId: args?['taskId'] ?? '',
          ),
        );
      default:
        return MaterialPageRoute(
          builder: (_) => const Scaffold(
            body: Center(child: Text('Route not found')),
          ),
        );
    }
  }
}