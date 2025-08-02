class Room {
  final String id;
  final String code;
  final String mentorId;
  final List<Player> players;
  final List<Task> tasks;
  final bool isActive;

  Room({
    required this.id,
    required this.code,
    required this.mentorId,
    required this.players,
    required this.tasks,
    required this.isActive,
  });

  factory Room.fromJson(Map<String, dynamic> json) {
    return Room(
      id: json['_id'],
      code: json['code'],
      mentorId: json['mentorId'],
      players: (json['players'] as List).map((p) => Player.fromJson(p)).toList(),
      tasks: (json['tasks'] as List).map((t) => Task.fromJson(t)).toList(),
      isActive: json['isActive'],
    );
  }
}

class Player {
  final String id;
  final String name;
  final String avatar;
  final int score;
  final List<String> completedTasks;

  Player({
    required this.id,
    required this.name,
    required this.avatar,
    required this.score,
    required this.completedTasks,
  });

  factory Player.fromJson(Map<String, dynamic> json) {
    return Player(
      id: json['_id'],
      name: json['name'],
      avatar: json['avatar'] ?? '👤',
      score: json['score'] ?? 0,
      completedTasks: List<String>.from(json['completedTasks'] ?? []),
    );
  }
}

class Task {
  final String id;
  final String title;
  final String description;
  final int points;
  final bool requiresPhoto;

  Task({
    required this.id,
    required this.title,
    required this.description,
    required this.points,
    required this.requiresPhoto,
  });

  factory Task.fromJson(Map<String, dynamic> json) {
    return Task(
      id: json['_id'],
      title: json['title'],
      description: json['description'],
      points: json['points'],
      requiresPhoto: json['requiresPhoto'] ?? true,
    );
  }
}
