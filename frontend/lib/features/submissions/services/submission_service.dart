import '../../../core/network/api_service.dart';
import '../models/submission_model.dart';

class SubmissionService {
  final ApiService apiService;

  SubmissionService(this.apiService);

  Future<Submission> submitTaskPhoto(String roomCode, String playerId, String taskId, String photoPath) async {
    final response = await apiService.post('/api/submissions/$roomCode/$playerId/$taskId', data: {
      'photoPath': photoPath,
    });
    return Submission.fromJson(response.data);
  }

  Future<List<Submission>> getMentorSubmissions(String roomCode) async {
    final response = await apiService.get('/api/mentor/$roomCode/submissions');
    return (response.data as List).map((submission) => Submission.fromJson(submission)).toList();
  }

  // Future<Submission> reviewSubmission(String submissionId, String status, String? feedback) async {
  //   final response = await apiService.put('/api/mentor/submissions/$submissionId', data: {
  //     'status': status,
  //     'feedback': feedback,
  //   });
  //   return Submission.fromJson(response.data);
  // }

  Future<String> getSubmissionPhoto(String submissionId) async {
    final response = await apiService.get('/api/submissions/$submissionId/photo');
    return response.data['photoUrl'];
  }

  Future<List<Submission>> getPlayerSubmissions(String playerId) async {
    final response = await apiService.get('/api/players/$playerId/submissions');
    return (response.data as List).map((submission) => Submission.fromJson(submission)).toList();
  }
}