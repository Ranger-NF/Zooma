class Submission {
  final String id;
  final String roomCode;
  final String playerId;
  final String taskId;
  final String photoUrl;
  final String status;
  final DateTime submittedAt;
  final String? feedback;

  Submission({
    required this.id,
    required this.roomCode,
    required this.playerId,
    required this.taskId,
    required this.photoUrl,
    required this.status,
    required this.submittedAt,
    this.feedback,
  });

  factory Submission.fromJson(Map<String, dynamic> json) {
    return Submission(
      id: json['id'] ?? '',
      roomCode: json['roomCode'] ?? '',
      playerId: json['playerId'] ?? '',
      taskId: json['taskId'] ?? '',
      photoUrl: json['photoUrl'] ?? '',
      status: json['status'] ?? 'pending',
      submittedAt: DateTime.parse(json['submittedAt'] ?? DateTime.now().toIso8601String()),
      feedback: json['feedback'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'roomCode': roomCode,
      'playerId': playerId,
      'taskId': taskId,
      'photoUrl': photoUrl,
      'status': status,
      'submittedAt': submittedAt.toIso8601String(),
      'feedback': feedback,
    };
  }
}