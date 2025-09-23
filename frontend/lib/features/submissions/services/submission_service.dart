import '../../../core/network/api_service.dart';
import '../models/submission_model.dart';

class SubmissionService {
  final DioClient _dioClient;

  SubmissionService(this._dioClient);

  Future<Submission> submitTaskPhoto(String roomCode, String playerId, String taskId, String photoPath) async {
    final response = await _dioClient.post('/api/submissions/$roomCode/$playerId/$taskId', data: {
      'photoPath': photoPath,
    });
    return Submission.fromJson(response.data);
  }

  Future<List<Submission>> getMentorSubmissions(String roomCode) async {
    final response = await _dioClient.get('/api/mentor/$roomCode/submissions');
    return (response.data as List).map((submission) => Submission.fromJson(submission)).toList();
  }

  Future<Submission> reviewSubmission(String submissionId, String status, String? feedback) async {
    final response = await _dioClient.put('/api/mentor/submissions/$submissionId', data: {
      'status': status,
      'feedback': feedback,
    });
    return Submission.fromJson(response.data);
  }

  Future<String> getSubmissionPhoto(String submissionId) async {
    final response = await _dioClient.get('/api/submissions/$submissionId/photo');
    return response.data['photoUrl'];
  }

  Future<List<Submission>> getPlayerSubmissions(String playerId) async {
    final response = await _dioClient.get('/api/players/$playerId/submissions');
    return (response.data as List).map((submission) => Submission.fromJson(submission)).toList();
  }
}