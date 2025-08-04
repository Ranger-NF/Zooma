class Task {
  final String id;
  final String title;
  final String description;
  final int points;
  final String status;
  final DateTime createdAt;

  Task({
    required this.id,
    required this.title,
    required this.description,
    required this.points,
    required this.status,
    required this.createdAt,
  });

  factory Task.fromJson(Map<String, dynamic> json) {
    return Task(
      id: json['id'] ?? '',
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      points: json['points'] ?? 0,
      status: json['status'] ?? 'pending',
      createdAt: DateTime.parse(json['createdAt'] ?? DateTime.now().toIso8601String()),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'points': points,
      'status': status,
      'createdAt': createdAt.toIso8601String(),
    };
  }
}