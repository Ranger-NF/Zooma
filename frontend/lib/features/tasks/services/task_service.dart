import '../../../core/network/dio_client.dart';
import '../models/task_model.dart';

class TaskService {
  final DioClient _dioClient;

  TaskService(this._dioClient);

  Future<List<Task>> addTasksToRoom(String roomCode, List<Map<String, dynamic>> tasks) async {
    final response = await _dioClient.post('/api/rooms/$roomCode/tasks', data: {
      'tasks': tasks,
    });
    return (response.data as List).map((task) => Task.fromJson(task)).toList();
  }

  Future<List<Task>> getPlayerTasks(String roomCode, String playerId) async {
    final response = await _dioClient.get('/api/rooms/$roomCode/tasks/$playerId');
    return (response.data as List).map((task) => Task.fromJson(task)).toList();
  }

  Future<List<Task>> getAllRoomTasks(String roomCode) async {
    final response = await _dioClient.get('/api/mentor/$roomCode/tasks');
    return (response.data as List).map((task) => Task.fromJson(task)).toList();
  }

  Future<Task> updateTask(String roomCode, String taskId, Map<String, dynamic> updates) async {
    final response = await _dioClient.put('/api/rooms/$roomCode/tasks/$taskId', data: updates);
    return Task.fromJson(response.data);
  }

  Future<void> deleteTask(String roomCode, String taskId) async {
    await _dioClient.delete('/api/rooms/$roomCode/tasks/$taskId');
  }
}