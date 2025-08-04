import 'package:flutter/foundation.dart';
import '../models/submission_model.dart';
import '../services/submission_service.dart';

class SubmissionController extends ChangeNotifier {
  final SubmissionService _submissionService;

  SubmissionController(this._submissionService);

  List<Submission> _submissions = [];
  bool _isLoading = false;
  String? _error;

  List<Submission> get submissions => _submissions;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> submitTaskPhoto(String roomCode, String playerId, String taskId, String photoPath) async {
    _setLoading(true);
    try {
      await _submissionService.submitTaskPhoto(roomCode, playerId, taskId, photoPath);
      _error = null;
    } catch (e) {
      _error = e.toString();
    } finally {
      _setLoading(false);
    }
  }

  Future<void> loadMentorSubmissions(String roomCode) async {
    _setLoading(true);
    try {
      _submissions = await _submissionService.getMentorSubmissions(roomCode);
      _error = null;
    } catch (e) {
      _error = e.toString();
    } finally {
      _setLoading(false);
    }
  }

  Future<void> reviewSubmission(String submissionId, String status, String? feedback) async {
    try {
      await _submissionService.reviewSubmission(submissionId, status, feedback);
      // Update the local submission
      final index = _submissions.indexWhere((s) => s.id == submissionId);
      if (index != -1) {
        _submissions[index] = Submission(
          id: _submissions[index].id,
          roomCode: _submissions[index].roomCode,
          playerId: _submissions[index].playerId,
          taskId: _submissions[index].taskId,
          photoUrl: _submissions[index].photoUrl,
          status: status,
          submittedAt: _submissions[index].submittedAt,
          feedback: feedback,
        );
      }
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }

  Future<void> loadPlayerSubmissions(String playerId) async {
    _setLoading(true);
    try {
      _submissions = await _submissionService.getPlayerSubmissions(playerId);
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