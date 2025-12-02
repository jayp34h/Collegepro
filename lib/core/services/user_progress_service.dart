import 'package:firebase_database/firebase_database.dart';
import '../models/user_progress_model.dart';

class UserProgressService {
  static final UserProgressService _instance = UserProgressService._internal();
  factory UserProgressService() => _instance;
  UserProgressService._internal();

  final DatabaseReference _database = FirebaseDatabase.instance.ref();

  // Activity types and their point values
  static const Map<String, int> activityPoints = {
    'login': 2,
    'quiz_completed': 10,
    'project_viewed': 3,
    'project_tapped': 2,
    'dashboard_visited': 1,
    'note_downloaded': 5,
    'note_shared': 4,
    'doubt_posted': 8,
    'doubt_answered': 12,
    'answer_given': 12,
    'best_answer': 20,
    'upvote_received': 3,
    'hackathon_joined': 20,
    'project_saved': 3,
    'project_unsaved': 1,
    'profile_completed': 25,
    'resume_created': 30,
    'study_streak_day': 5,
    'community_interaction': 7,
    'search_performed': 1,
    'filter_applied': 1,
  };

  /// Get user progress from Firebase
  Future<UserProgressModel> getUserProgress(String userId) async {
    try {
      final snapshot = await _database.child('user_progress').child(userId).get();
      
      if (snapshot.exists && snapshot.value != null) {
        final data = Map<String, dynamic>.from(snapshot.value as Map);
        return UserProgressModel.fromMap(data);
      } else {
        // Return initial progress if no data exists
        return UserProgressModel.initial(userId);
      }
    } catch (e) {
      print('Error getting user progress: $e');
      return UserProgressModel.initial(userId);
    }
  }

  /// Update user progress in Firebase
  Future<void> updateUserProgress(UserProgressModel progress) async {
    try {
      await _database
          .child('user_progress')
          .child(progress.userId)
          .set(progress.toMap());
    } catch (e) {
      print('Error updating user progress: $e');
      throw Exception('Failed to update progress: $e');
    }
  }

  /// Track a specific activity and update progress
  Future<UserProgressModel> trackActivity(String userId, String activityType) async {
    try {
      print('🔄 Tracking activity: $activityType for user: $userId');
      
      final currentProgress = await getUserProgress(userId);
      final points = activityPoints[activityType] ?? 1;
      
      print('📊 Current progress: ${currentProgress.progressPercentage}% (${currentProgress.totalActivities} points)');
      print('⭐ Activity points for $activityType: $points');
      
      // Update activity counts
      final updatedActivityCounts = Map<String, int>.from(currentProgress.activityCounts);
      updatedActivityCounts[activityType] = (updatedActivityCounts[activityType] ?? 0) + 1;
      
      // Calculate new totals
      final newCompletedActivities = currentProgress.completedActivities + 1;
      final newTotalActivities = currentProgress.totalActivities + points;
      
      // Calculate progress percentage (out of 1000 total points for 100%)
      final maxPoints = 1000.0;
      final newProgressPercentage = (newTotalActivities / maxPoints * 100).clamp(0.0, 100.0);
      
      print('📈 New progress: ${newProgressPercentage.toStringAsFixed(1)}% (${newTotalActivities} points)');
      
      final updatedProgress = currentProgress.copyWith(
        totalActivities: newTotalActivities,
        completedActivities: newCompletedActivities,
        activityCounts: updatedActivityCounts,
        lastUpdated: DateTime.now(),
        progressPercentage: newProgressPercentage,
      );
      
      await updateUserProgress(updatedProgress);
      print('✅ Progress updated successfully in Firebase');
      return updatedProgress;
    } catch (e) {
      print('❌ Error tracking activity: $e');
      throw Exception('Failed to track activity: $e');
    }
  }

  /// Get real-time progress stream
  Stream<UserProgressModel> getUserProgressStream(String userId) {
    return _database
        .child('user_progress')
        .child(userId)
        .onValue
        .map((event) {
      if (event.snapshot.exists && event.snapshot.value != null) {
        final data = Map<String, dynamic>.from(event.snapshot.value as Map);
        return UserProgressModel.fromMap(data);
      } else {
        return UserProgressModel.initial(userId);
      }
    });
  }

  /// Get activity summary for display
  Map<String, dynamic> getActivitySummary(UserProgressModel progress) {
    final totalProjects = progress.activityCounts['project_saved'] ?? 0;
    final codingProblems = progress.activityCounts['coding_problem_solved'] ?? 0;
    final interviews = progress.activityCounts['ai_interview_completed'] ?? 0;
    final doubts = (progress.activityCounts['doubt_posted'] ?? 0) + 
                   (progress.activityCounts['doubt_answered'] ?? 0);
    
    return {
      'totalProjects': totalProjects,
      'codingProblems': codingProblems,
      'interviews': interviews,
      'doubts': doubts,
      'totalActivities': progress.completedActivities,
      'progressPercentage': progress.progressPercentage,
    };
  }

  /// Initialize progress for new user
  Future<void> initializeUserProgress(String userId) async {
    try {
      final existingProgress = await getUserProgress(userId);
      if (existingProgress.totalActivities == 0 && existingProgress.completedActivities == 0) {
        final initialProgress = UserProgressModel.initial(userId);
        await updateUserProgress(initialProgress);
      }
    } catch (e) {
      print('Error initializing user progress: $e');
    }
  }

  /// Bulk track multiple activities (for initial setup or imports)
  Future<UserProgressModel> trackMultipleActivities(
    String userId, 
    Map<String, int> activities
  ) async {
    try {
      UserProgressModel currentProgress = await getUserProgress(userId);
      
      for (final entry in activities.entries) {
        final activityType = entry.key;
        final count = entry.value;
        
        for (int i = 0; i < count; i++) {
          currentProgress = await trackActivity(userId, activityType);
        }
      }
      
      return currentProgress;
    } catch (e) {
      print('Error tracking multiple activities: $e');
      throw Exception('Failed to track multiple activities: $e');
    }
  }
}
