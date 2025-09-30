import 'package:flutter/foundation.dart';
import 'package:frontend/features/introduction/controllers/username_controller.dart';
import '../models/room_model.dart';
import '../services/room_service.dart';

class RoomController extends ChangeNotifier {
  final RoomService _roomService;

  RoomController(this._roomService);

  Room? _currentRoom;
  bool _isLoading = false;
  String? _error;

  Room? get currentRoom => _currentRoom;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> createRoom(String roomName, int roomSize) async {
    _setLoading(true);
    try {
      String? username = await UsernameController.getUsername();
      if(username != null){
        _currentRoom = await _roomService.createRoom(roomName, roomSize, username);
        _error = null;
      }
    } catch (e) {
      _error = e.toString();
    } finally {
      _setLoading(false);
    }
  }

  Future<void> joinRoom(String roomCode, String playerName) async {
    _setLoading(true);
    try {
      _currentRoom = await _roomService.joinRoom(roomCode, playerName);
      _error = null;
    } catch (e) {
      _error = e.toString();
    } finally {
      _setLoading(false);
    }
  }

  Future<void> getRoomDetails(String roomCode) async {
    _setLoading(true);
    try {
      _currentRoom = await _roomService.getRoomDetails(roomCode);
      _error = null;
    } catch (e) {
      _error = e.toString();
    } finally {
      _setLoading(false);
    }
  }

  // Future<void> updateRoomStatus(String roomCode, String status) async {
  //   try {
  //     await _roomService.updateRoomStatus(roomCode, status);
  //     if (_currentRoom != null) {
  //       await getRoomDetails(roomCode);
  //     }
  //   } catch (e) {
  //     _error = e.toString();
  //     notifyListeners();
  //   }
  // }

  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }

  
}