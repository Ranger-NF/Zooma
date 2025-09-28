
import '../../../core/network/api_service.dart';
import '../models/room_model.dart';

class RoomService {
  final ApiService apiService;

  RoomService(this.apiService);

  Future<Room> createRoom(String roomName, int roomSize, String mentorName) async {
    final response = await apiService.post(
      '/api/rooms/create', 
      data: {
        'mentorName': mentorName,
        'roomName': roomName,
      }
    );
    return Room.fromJson(response.data);
  }

  Future<Room> joinRoom(String roomCode, String playerName) async {
    final response = await apiService.post('/api/rooms/join', data: {
      'roomCode': roomCode,
      //'roomName': roomName
    });
    return Room.fromJson(response.data);
  }

  Future<Room> getRoomDetails(String roomCode) async {
    final response = await apiService.get('/api/rooms/$roomCode');
    return Room.fromJson(response.data);
  }

  // Future<void> updateRoomStatus(String roomCode, String status) async {
  //   await apiService.put('/api/rooms/$roomCode/status', data: {
  //     'status': status,
  //   });
  // }

  Future<Room> getRoomUpdates(String roomCode) async {
    final response = await apiService.get('/api/rooms/$roomCode/updates');
    return Room.fromJson(response.data);
  }
}