import 'package:flutter/foundation.dart';
import '../models/leaderboard_model.dart';
import '../services/leaderboard_service.dart';

class LeaderboardController extends ChangeNotifier {
  final LeaderboardService _leaderboardService;

  LeaderboardController(this._leaderboardService);

  List<LeaderboardEntry> _leaderboard = [];
  Map<String, dynamic>? _playerStats;
  bool _isLoading = false;
  String? _error;

  List<LeaderboardEntry> get leaderboard => _leaderboard;
  Map<String, dynamic>? get playerStats => _playerStats;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> loadLeaderboard(String roomCode) async {
    _setLoading(true);
    try {
      _leaderboard = await _leaderboardService.getRoomLeaderboard(roomCode);
      _error = null;
    } catch (e) {
      _error = e.toString();
    } finally {
      _setLoading(false);
    }
  }

  Future<void> loadPlayerStats(String playerId) async {
    _setLoading(true);
    try {
      _playerStats = await _leaderboardService.getPlayerStats(playerId);
      _error = null;
    } catch (e) {
      _error = e.toString();
    } finally {
      _setLoading(false);
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