import 'package:flutter/foundation.dart';
import '../models/user_progress_model.dart';
import '../services/user_progress_service.dart';
import 'dart:async';

class UserProgressProvider extends ChangeNotifier {
  final UserProgressService _progressService = UserProgressService();
  
  UserProgressModel? _userProgress;
  bool _isLoading = false;
  String? _errorMessage;
  StreamSubscription<UserProgressModel>? _progressSubscription;

  UserProgressModel? get userProgress => _userProgress;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  
  double get progressPercentage => _userProgress?.progressPercentage ?? 0.0;
  int get totalProjects => _userProgress?.activityCounts['project_saved'] ?? 0;
  int get completedActivities => _userProgress?.completedActivities ?? 0;

  /// Initialize progress tracking for a user
  Future<void> initializeProgress(String userId) async {
    if (userId.isEmpty) return;
    
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      // Initialize user progress if needed
      await _progressService.initializeUserProgress(userId);
      
      // Start listening to real-time updates
      _progressSubscription?.cancel();
      _progressSubscription = _progressService.getUserProgressStream(userId).listen(
        (progress) {
          _userProgress = progress;
          _isLoading = false;
          notifyListeners();
        },
        onError: (error) {
          _errorMessage = 'Failed to load progress: $error';
          _isLoading = false;
          notifyListeners();
        },
      );
    } catch (e) {
      _errorMessage = 'Failed to initialize progress: $e';
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Track a specific activity
  Future<void> trackActivity(String userId, String activityType) async {
    if (userId.isEmpty) return;
    
    try {
      await _progressService.trackActivity(userId, activityType);
      // Progress will be updated automatically via stream
    } catch (e) {
      _errorMessage = 'Failed to track activity: $e';
      notifyListeners();
    }
  }

  /// Get activity summary for display
  Map<String, dynamic> getActivitySummary() {
    if (_userProgress == null) {
      return {
        'totalProjects': 0,
        'codingProblems': 0,
        'interviews': 0,
        'doubts': 0,
        'totalActivities': 0,
        'progressPercentage': 0.0,
      };
    }
    
    return _progressService.getActivitySummary(_userProgress!);
  }

  /// Clear error message
  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  /// Dispose resources
  @override
  void dispose() {
    _progressSubscription?.cancel();
    super.dispose();
  }

  /// Reset progress (for testing or admin purposes)
  Future<void> resetProgress(String userId) async {
    if (userId.isEmpty) return;
    
    try {
      final initialProgress = UserProgressModel.initial(userId);
      await _progressService.updateUserProgress(initialProgress);
    } catch (e) {
      _errorMessage = 'Failed to reset progress: $e';
      notifyListeners();
    }
  }

  /// Manually refresh progress
  Future<void> refreshProgress(String userId) async {
    if (userId.isEmpty) return;
    
    _isLoading = true;
    notifyListeners();

    try {
      final progress = await _progressService.getUserProgress(userId);
      _userProgress = progress;
      _errorMessage = null;
    } catch (e) {
      _errorMessage = 'Failed to refresh progress: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
