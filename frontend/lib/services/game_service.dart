import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:socket_io_client/socket_io_client.dart' as IO;
import 'dart:convert';
import '../models/game_models.dart';

class GameService extends ChangeNotifier {
  static const String baseUrl = 'http://localhost:3000/api';
  IO.Socket? socket;
  Room? currentRoom;
  Player? currentPlayer;
  bool isLoading = false;

  void initSocket() {
    socket = IO.io('http://localhost:3000', <String, dynamic>{
      'transports': ['websocket'],
      'autoConnect': false,
    });
    
    socket!.connect();
    
    socket!.on('roomUpdated', (data) {
      currentRoom = Room.fromJson(data);
      notifyListeners();
    });
    
    socket!.on('taskCompleted', (data) {
      // Handle task completion updates
      notifyListeners();
    });
  }

  Future<String?> createRoom(String mentorName) async {
    isLoading = true;
    notifyListeners();
    
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/rooms'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({'mentorName': mentorName}),
      );
      
      if (response.statusCode == 201) {
        final data = json.decode(response.body);
        currentRoom = Room.fromJson(data['room']);
        currentPlayer = Player.fromJson(data['mentor']);
        initSocket();
        socket!.emit('joinRoom', currentRoom!.code);
        return currentRoom!.code;
      }
    } catch (e) {
      print('Error creating room: $e');
    }
    
    isLoading = false;
    notifyListeners();
    return null;
  }

  Future<bool> joinRoom(String roomCode, String playerName) async {
    isLoading = true;
    notifyListeners();
    
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/rooms/$roomCode/join'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({'playerName': playerName}),
      );
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        currentRoom = Room.fromJson(data['room']);
        currentPlayer = Player.fromJson(data['player']);
        initSocket();
        socket!.emit('joinRoom', roomCode);
        isLoading = false;
        notifyListeners();
        return true;
      }
    } catch (e) {
      print('Error joining room: $e');
    }
    
    isLoading = false;
    notifyListeners();
    return false;
  }

  Future<bool> submitTaskPhoto(String taskId, String imagePath) async {
    try {
      var request = http.MultipartRequest(
        'POST',
        Uri.parse('$baseUrl/tasks/$taskId/submit'),
      );
      
      request.fields['playerId'] = currentPlayer!.id;
      request.fields['roomCode'] = currentRoom!.code;
      request.files.add(await http.MultipartFile.fromPath('photo', imagePath));
      
      var response = await request.send();
      return response.statusCode == 200;
    } catch (e) {
      print('Error submitting task: $e');
      return false;
    }
  }

  void dispose() {
    socket?.disconnect();
    super.dispose();
  }
}
