import 'package:flutter/material.dart';
import 'package:frontend/core/util/token_storage.dart';
import 'package:frontend/features/room/views/create_room_widget.dart';
import '../services/room_service.dart';

class RoomController extends ChangeNotifier {
  final RoomService _roomService;

  RoomController(this._roomService);

  int _numberOfQuestion = 1;
  int _roomSize = 1;
  bool _isLoading = false;
  String? _error;


  int get numberOfQuestion => _numberOfQuestion;
  int get roomSize => _roomSize;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> createRoom(int numberOfQuestion, int roomSize, BuildContext ctx) async {
    _setLoading(true);
    try {
      String? id = await TokenStorage.getToken("id");
      print(id);
      if(id != null){
        String code = await _roomService.createRoom(
          id: id,
          maxPlayers: roomSize,
          numberOfQuestion: numberOfQuestion
        );
        _error = null;
        showCodePopup(ctx, code);
      }
    } catch (e) {
      _error = e.toString();
    } finally {
      _setLoading(false);
    }
  }

  // Future<void> joinRoom(String roomCode, String playerName) async {
  //   _setLoading(true);
  //   try {
  //     _currentRoom = await _roomService.joinRoom(roomCode, playerName);
  //     _error = null;
  //   } catch (e) {
  //     _error = e.toString();
  //   } finally {
  //     _setLoading(false);
  //   }
  // }

  // Future<void> getRoomDetails(String roomCode) async {
  //   _setLoading(true);
  //   try {
  //     _currentRoom = await _roomService.getRoomDetails(roomCode);
  //     _error = null;
  //   } catch (e) {
  //     _error = e.toString();
  //   } finally {
  //     _setLoading(false);
  //   }
  // }

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

  void roomSizeIncrement(){
    if (_roomSize < 10) {
      _roomSize++;
      notifyListeners();
    }
  }

  void numberOfQuestionIncrement(){
    if (_numberOfQuestion < 7) {
      _numberOfQuestion++;
      notifyListeners();
    }
  }

  void roomSizeDecrement() {
    if (_roomSize > 1) {
      _roomSize--;
      notifyListeners();
    }
  }

  void numberOfQuestionDecrement() {
    if (_numberOfQuestion > 1) {
      _numberOfQuestion--;
      notifyListeners();
    }
  }
  
}