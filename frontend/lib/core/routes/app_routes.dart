import 'package:flutter/material.dart';
import 'package:frontend/features/home/views/home_page.dart';
import 'package:frontend/features/register/view/register.dart';
// import 'package:frontend/features/introduction/views/introduction_page.dart';
// import 'package:frontend/features/splash/views/splash_screen.dart';
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
  static const String register = '/register';

  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case home:
        return MaterialPageRoute(builder: (_) => RegisterScreen());
      case joinRoom:
        return MaterialPageRoute(builder: (_) => JoinRoomScreen());
      case createRoom:
        return MaterialPageRoute(builder: (_) => HomeScreen());
      case leaderboard:
        final args = settings.arguments as Map<String, dynamic>?;
        return MaterialPageRoute(
          builder: (_) => LeaderboardPage(roomCode: args?['roomCode'] ?? ''),
        );
      case tasks:
        return MaterialPageRoute(
          builder: (_) => TasksScreen(),
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