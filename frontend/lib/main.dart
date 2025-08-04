import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'core/di/dependency_injection.dart';
import 'core/routes/app_routes.dart';
import 'core/theme/app_theme.dart';
import 'features/room/controllers/room_controller.dart';
import 'features/leaderboard/controllers/leaderboard_controller.dart';
import 'features/tasks/controllers/task_controller.dart';
import 'features/submissions/controllers/submission_controller.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await DependencyInjection.init();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => getIt<RoomController>()),
        ChangeNotifierProvider(create: (_) => getIt<LeaderboardController>()),
        ChangeNotifierProvider(create: (_) => getIt<TaskController>()),
        ChangeNotifierProvider(create: (_) => getIt<SubmissionController>()),
      ],
      child: MaterialApp(
        title: 'Bingo Game',
        theme: AppTheme.lightTheme,
        initialRoute: AppRoutes.home,
        onGenerateRoute: AppRoutes.generateRoute,
        debugShowCheckedModeBanner: false,
      ),
    );
  }
}