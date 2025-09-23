
import '../../../core/network/dio_client.dart';
import '../models/room_model.dart';

class RoomService {
  final DioClient _dioClient;

  RoomService(this._dioClient);

  Future<Room> createRoom(String roomName, int roomSize, String mentorName) async {
    final response = await _dioClient.post(
      '/api/rooms/create', 
      data: {
        'mentorName': mentorName,
        'roomName': roomName,
      }
    );
    return Room.fromJson(response.data);
  }

  Future<Room> joinRoom(String roomCode, String playerName) async {
    final response = await _dioClient.post('/api/rooms/join', data: {
      'roomCode': roomCode,
      //'roomName': roomName
    });
    return Room.fromJson(response.data);
  }

  Future<Room> getRoomDetails(String roomCode) async {
    final response = await _dioClient.get('/api/rooms/$roomCode');
    return Room.fromJson(response.data);
  }

  Future<void> updateRoomStatus(String roomCode, String status) async {
    await _dioClient.put('/api/rooms/$roomCode/status', data: {
      'status': status,
    });
  }

  Future<Room> getRoomUpdates(String roomCode) async {
    final response = await _dioClient.get('/api/rooms/$roomCode/updates');
    return Room.fromJson(response.data);
  }
}