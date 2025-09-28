import '../../../core/network/api_service.dart';
import '../models/leaderboard_model.dart';

class LeaderboardService {
  final ApiService apiService;

  LeaderboardService(this.apiService);

  Future<List<LeaderboardEntry>> getRoomLeaderboard(String roomCode) async {
    final response = await apiService.get('/api/rooms/$roomCode/leaderboard');
    return (response.data as List)
        .map((entry) => LeaderboardEntry.fromJson(entry))
        .toList();
  }

  Future<Map<String, dynamic>> getPlayerStats(String playerId) async {
    final response = await apiService.get('/api/players/$playerId/stats');
    return response.data;
  }

  Future<Map<String, dynamic>> getRoomAnalytics(String roomCode) async {
    final response = await apiService.get('/api/mentor/$roomCode/analytics');
    return response.data;
  }
}