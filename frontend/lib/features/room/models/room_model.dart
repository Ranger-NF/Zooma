class Room {
  final String roomCode;
  final String roomName;
  final int roomSize;
  final String status;
  final List<Player> players;
  final DateTime createdAt;

  Room({
    required this.roomCode,
    required this.roomName,
    required this.roomSize,
    required this.status,
    required this.players,
    required this.createdAt,
  });

  factory Room.fromJson(Map<String, dynamic> json) {
    return Room(
      roomCode: json['roomCode'] ?? '',
      roomName: json['roomName'] ?? '',
      roomSize: json['roomSize'] ?? 0,
      status: json['status'] ?? '',
      players: (json['players'] as List<dynamic>?)
          ?.map((player) => Player.fromJson(player))
          .toList() ?? [],
      createdAt: DateTime.parse(json['createdAt'] ?? DateTime.now().toIso8601String()),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'roomCode': roomCode,
      'roomName': roomName,
      'roomSize': roomSize,
      'status': status,
      'players': players.map((player) => player.toJson()).toList(),
      'createdAt': createdAt.toIso8601String(),
    };
  }
}

class Player {
  final String id;
  final String name;
  final String color;
  final int score;

  Player({
    required this.id,
    required this.name,
    required this.color,
    required this.score,
  });

  factory Player.fromJson(Map<String, dynamic> json) {
    return Player(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      color: json['color'] ?? '#000000',
      score: json['score'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'color': color,
      'score': score,
    };
  }
}