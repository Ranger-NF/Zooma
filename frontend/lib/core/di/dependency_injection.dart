import 'package:get_it/get_it.dart';
import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../network/dio_client.dart';
import '../../features/room/services/room_service.dart';
import '../../features/room/controllers/room_controller.dart';
import '../../features/leaderboard/services/leaderboard_service.dart';
import '../../features/leaderboard/controllers/leaderboard_controller.dart';
import '../../features/tasks/services/task_service.dart';
import '../../features/tasks/controllers/task_controller.dart';
import '../../features/submissions/services/submission_service.dart';
import '../../features/submissions/controllers/submission_controller.dart';

final getIt = GetIt.instance;

class DependencyInjection {
  static Future<void> init() async {
    // External dependencies
    final sharedPreferences = await SharedPreferences.getInstance();
    getIt.registerSingleton<SharedPreferences>(sharedPreferences);

    // Network
    getIt.registerSingleton<Dio>(Dio());
    getIt.registerSingleton<DioClient>(DioClient(getIt<Dio>()));

    // Services
    getIt.registerSingleton<RoomService>(RoomService(getIt<DioClient>()));
    getIt.registerSingleton<LeaderboardService>(LeaderboardService(getIt<DioClient>()));
    getIt.registerSingleton<TaskService>(TaskService(getIt<DioClient>()));
    getIt.registerSingleton<SubmissionService>(SubmissionService(getIt<DioClient>()));

    // Controllers
    getIt.registerFactory<RoomController>(() => RoomController(getIt<RoomService>()));
    getIt.registerFactory<LeaderboardController>(() => LeaderboardController(getIt<LeaderboardService>()));
    getIt.registerFactory<TaskController>(() => TaskController(getIt<TaskService>()));
    getIt.registerFactory<SubmissionController>(() => SubmissionController(getIt<SubmissionService>()));
  }
}