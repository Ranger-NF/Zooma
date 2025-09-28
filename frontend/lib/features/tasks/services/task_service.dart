import '../../../core/network/api_service.dart';
import '../models/task_model.dart';

class TaskService {
  final ApiService apiService;

  TaskService(this.apiService);

  Future<List<Task>> addTasksToRoom(String roomCode, List<Map<String, dynamic>> tasks) async {
    final response = await apiService.post('/api/rooms/$roomCode/tasks', data: {
      'tasks': tasks,
    });
    return (response.data as List).map((task) => Task.fromJson(task)).toList();
  }

  Future<List<Task>> getPlayerTasks(String roomCode, String playerId) async {
    final response = await apiService.get('/api/rooms/$roomCode/tasks/$playerId');
    return (response.data as List).map((task) => Task.fromJson(task)).toList();
  }

  Future<List<Task>> getAllRoomTasks(String roomCode) async {
    final response = await apiService.get('/api/mentor/$roomCode/tasks');
    return (response.data as List).map((task) => Task.fromJson(task)).toList();
  }

  // Future<Task> updateTask(String roomCode, String taskId, Map<String, dynamic> updates) async {
  //   final response = await apiService.put('/api/rooms/$roomCode/tasks/$taskId', data: updates);
  //   return Task.fromJson(response.data);
  // }

  // Future<void> deleteTask(String roomCode, String taskId) async {
  //   await apiService.delete('/api/rooms/$roomCode/tasks/$taskId');
  // }
}