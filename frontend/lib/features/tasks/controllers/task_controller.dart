import 'package:flutter/foundation.dart';
import '../models/task_model.dart';
import '../services/task_service.dart';

class TaskController extends ChangeNotifier {
  final TaskService _taskService;

  TaskController(this._taskService);

  List<Task> _tasks = [];
  bool _isLoading = false;
  String? _error;

  List<Task> get tasks => _tasks;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> loadPlayerTasks(String roomCode, String playerId) async {
    _setLoading(true);
    try {
      _tasks = await _taskService.getPlayerTasks(roomCode, playerId);
      _error = null;
    } catch (e) {
      _error = e.toString();
    } finally {
      _setLoading(false);
    }
  }

  Future<void> loadAllRoomTasks(String roomCode) async {
    _setLoading(true);
    try {
      _tasks = await _taskService.getAllRoomTasks(roomCode);
      _error = null;
    } catch (e) {
      _error = e.toString();
    } finally {
      _setLoading(false);
    }
  }

  Future<void> addTasksToRoom(String roomCode, List<Map<String, dynamic>> tasks) async {
    _setLoading(true);
    try {
      await _taskService.addTasksToRoom(roomCode, tasks);
      await loadAllRoomTasks(roomCode);
      _error = null;
    } catch (e) {
      _error = e.toString();
      _setLoading(false);
    }
  }

  Future<void> updateTask(String roomCode, String taskId, Map<String, dynamic> updates) async {
    try {
      await _taskService.updateTask(roomCode, taskId, updates);
      await loadAllRoomTasks(roomCode);
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }

  Future<void> deleteTask(String roomCode, String taskId) async {
    try {
      await _taskService.deleteTask(roomCode, taskId);
      _tasks.removeWhere((task) => task.id == taskId);
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }

  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }
}
