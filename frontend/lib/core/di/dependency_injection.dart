import 'package:frontend/features/register/controller/register_controller.dart';
import 'package:frontend/features/register/service/register_service.dart';
import 'package:get_it/get_it.dart';
import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../network/api_service.dart';
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
    getIt.registerSingleton<ApiService>(ApiService());

    // Services
    getIt.registerSingleton<RoomService>(RoomService(getIt<ApiService>()));
    getIt.registerSingleton<LeaderboardService>(LeaderboardService(getIt<ApiService>()));
    getIt.registerSingleton<TaskService>(TaskService(getIt<ApiService>()));
    getIt.registerSingleton<SubmissionService>(SubmissionService(getIt<ApiService>()));
    getIt.registerSingleton<RegisterService>(RegisterService(getIt<ApiService>()));

    // Controllers
    getIt.registerFactory<RoomController>(() => RoomController(getIt<RoomService>()));
    getIt.registerFactory<LeaderboardController>(() => LeaderboardController(getIt<LeaderboardService>()));
    getIt.registerFactory<TaskController>(() => TaskController(getIt<TaskService>()));
    getIt.registerFactory<SubmissionController>(() => SubmissionController(getIt<SubmissionService>()));
    getIt.registerFactory<RegisterController>(() => RegisterController(getIt<RegisterService>()));
  }
}