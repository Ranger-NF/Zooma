class LeaderboardEntry {
  final String playerId;
  final String playerName;
  final String playerColor;
  final int score;
  final int rank;

  LeaderboardEntry({
    required this.playerId,
    required this.playerName,
    required this.playerColor,
    required this.score,
    required this.rank,
  });

  factory LeaderboardEntry.fromJson(Map<String, dynamic> json) {
    return LeaderboardEntry(
      playerId: json['playerId'] ?? '',
      playerName: json['playerName'] ?? '',
      playerColor: json['playerColor'] ?? '#000000',
      score: json['score'] ?? 0,
      rank: json['rank'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'playerId': playerId,
      'playerName': playerName,
      'playerColor': playerColor,
      'score': score,
      'rank': rank,
    };
  }
}
