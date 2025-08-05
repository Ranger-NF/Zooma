class Room {
  final String roomCode;
  final String mentorName;
  final String roomName;
  final bool isActive;
  final DateTime createdAt;
  final int maxPlayers;
  //final String status;
  // final List<Player> players;

  Room({
    required this.roomCode,
    required this.mentorName,
    required this.roomName,
    required this.isActive,
    required this.createdAt,
    required this.maxPlayers
  });

  factory Room.fromJson(Map<String, dynamic> json) {
    return Room(
      roomCode: json['roomCode'] ?? '',
      mentorName: json['mentorName'] ?? '',
      roomName: json['roomName'] ?? '',
      isActive: json['isActive'],
      createdAt: DateTime.parse(json['createdAt'] ?? DateTime.now().toIso8601String()),
      maxPlayers: json['maxPlayers']
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'roomCode': roomCode,
      'mentorName': mentorName,
      'roomName': roomName,
      'isActive': isActive,
      'createdAt': createdAt.toIso8601String(),
      'maxPlayers': maxPlayers
    };
  }
}

class Player {
  final String id;
  final String name;
  final String roomCode;
  final DateTime joinedAt;
  final int totalPoints;
  final int completedTasks;

  Player({
    required this.id,
    required this.name,
    required this.roomCode,
    required this.joinedAt,
    required this.totalPoints,
    required this.completedTasks
  });

  factory Player.fromJson(Map<String, dynamic> json) {
    return Player(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      roomCode: json['roomCode'] ?? '',
      joinedAt: DateTime.parse(json['joinedAt'] ?? DateTime.now().toIso8601String()),
      totalPoints: json['totalPoints'] ?? 0,
      completedTasks: json['completedTasks'] ?? 0
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'roomCode': roomCode,
      'joinedAt': joinedAt,
      'totalPoints': totalPoints,
      'completedTasks': completedTasks
    };
  }
}