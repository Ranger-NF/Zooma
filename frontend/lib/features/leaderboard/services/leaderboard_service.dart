import '../../../core/network/dio_client.dart';
import '../models/leaderboard_model.dart';

class LeaderboardService {
  final DioClient _dioClient;

  LeaderboardService(this._dioClient);

  Future<List<LeaderboardEntry>> getRoomLeaderboard(String roomCode) async {
    final response = await _dioClient.get('/api/rooms/$roomCode/leaderboard');
    return (response.data as List)
        .map((entry) => LeaderboardEntry.fromJson(entry))
        .toList();
  }

  Future<Map<String, dynamic>> getPlayerStats(String playerId) async {
    final response = await _dioClient.get('/api/players/$playerId/stats');
    return response.data;
  }

  Future<Map<String, dynamic>> getRoomAnalytics(String roomCode) async {
    final response = await _dioClient.get('/api/mentor/$roomCode/analytics');
    return response.data;
  }
}