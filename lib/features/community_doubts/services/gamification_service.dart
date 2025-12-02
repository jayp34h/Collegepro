import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/foundation.dart';
import '../models/badge_model.dart';

class GamificationService {
  static final DatabaseReference _database = FirebaseDatabase.instance.ref();
  static const Duration _timeout = Duration(seconds: 15);

  // Points system
  static const int POINTS_ASK_QUESTION = 5;
  static const int POINTS_ANSWER_QUESTION = 10;
  static const int POINTS_BEST_ANSWER = 25;
  static const int POINTS_UPVOTE_RECEIVED = 2;
  static const int POINTS_HELPFUL_MARK = 5;
  static const int POINTS_DAILY_LOGIN = 1;
  static const int POINTS_STREAK_BONUS = 5;

  // Get user progress
  static Future<UserProgress> getUserProgress(String userId, {String? userName}) async {
    try {
      final snapshot = await _database
          .child('user_progress')
          .child(userId)
          .get()
          .timeout(_timeout);
      
      if (!snapshot.exists) {
        // Create new progress for user
        final newProgress = UserProgress(
          userId: userId,
          userName: userName ?? 'Anonymous',
          lastActivity: DateTime.now(),
        );
        await updateUserProgress(newProgress);
        return newProgress;
      }
      
      final progress = UserProgress.fromJson(Map<String, dynamic>.from(snapshot.value as Map));
      
      // Update userName if provided and different
      if (userName != null && userName.isNotEmpty && progress.userName != userName) {
        final updatedProgress = progress.copyWith(userName: userName);
        await updateUserProgress(updatedProgress);
        return updatedProgress;
      }
      
      return progress;
    } catch (e) {
      if (kDebugMode) {
        print('❌ Error getting user progress: $e');
      }
      throw Exception('Failed to get user progress: $e');
    }
  }

  // Update user progress
  static Future<void> updateUserProgress(UserProgress progress) async {
    try {
      await _database
          .child('user_progress')
          .child(progress.userId)
          .set(progress.toJson())
          .timeout(_timeout);
    } catch (e) {
      if (kDebugMode) {
        print('❌ Error updating user progress: $e');
      }
      throw Exception('Failed to update user progress: $e');
    }
  }

  // Award points for activity
  static Future<UserProgress> awardPoints(
    String userId, 
    int points, 
    String activity, 
    {String? subject, String? userName}
  ) async {
    try {
      final progress = await getUserProgress(userId, userName: userName);
      final now = DateTime.now();
      
      // Calculate streak
      int newStreak = progress.currentStreak;
      final daysSinceLastActivity = now.difference(progress.lastActivity).inDays;
      
      if (daysSinceLastActivity == 1) {
        newStreak += 1; // Continue streak
      } else if (daysSinceLastActivity > 1) {
        newStreak = 1; // Reset streak
      }
      
      // Add streak bonus
      int bonusPoints = 0;
      if (newStreak > 1 && newStreak % 7 == 0) {
        bonusPoints = POINTS_STREAK_BONUS * (newStreak ~/ 7);
      }
      
      // Update subject points
      Map<String, int> subjectPoints = Map.from(progress.subjectPoints);
      if (subject != null) {
        subjectPoints[subject] = (subjectPoints[subject] ?? 0) + points;
      }
      
      // Update activity counters based on activity type
      int questionsAsked = progress.questionsAsked;
      int answersGiven = progress.answersGiven;
      int bestAnswers = progress.bestAnswers;
      int helpfulMarks = progress.helpfulMarks;
      int upvotesReceived = progress.upvotesReceived;
      int doubtsSolved = progress.doubtsSolved;
      
      switch (activity) {
        case 'question_asked':
          questionsAsked++;
          break;
        case 'answer_given':
          answersGiven++;
          break;
        case 'best_answer':
          bestAnswers++;
          doubtsSolved++;
          break;
        case 'upvote_received':
          upvotesReceived++;
          break;
        case 'helpful_mark':
          helpfulMarks++;
          break;
      }
      
      final updatedProgress = progress.copyWith(
        totalPoints: progress.totalPoints + points + bonusPoints,
        experiencePoints: progress.experiencePoints + points + bonusPoints,
        questionsAsked: questionsAsked,
        answersGiven: answersGiven,
        bestAnswers: bestAnswers,
        helpfulMarks: helpfulMarks,
        upvotesReceived: upvotesReceived,
        doubtsSolved: doubtsSolved,
        subjectPoints: subjectPoints,
        currentStreak: newStreak,
        longestStreak: newStreak > progress.longestStreak ? newStreak : progress.longestStreak,
        lastActivity: now,
        level: progress.copyWith(experiencePoints: progress.experiencePoints + points + bonusPoints).calculateLevel(),
      );
      
      await updateUserProgress(updatedProgress);
      
      // Check for new badges
      await checkAndAwardBadges(userId, updatedProgress);
      
      if (kDebugMode) {
        print('✅ Awarded $points points (+$bonusPoints bonus) to $userId for $activity');
      }
      
      return updatedProgress;
    } catch (e) {
      if (kDebugMode) {
        print('❌ Error awarding points: $e');
      }
      throw Exception('Failed to award points: $e');
    }
  }

  // Check and award badges
  static Future<void> checkAndAwardBadges(String userId, UserProgress progress) async {
    try {
      final availableBadges = _getAvailableBadges();
      final newBadges = <String>[];
      
      for (final badge in availableBadges) {
        if (!progress.unlockedBadges.contains(badge.id) && _checkBadgeCriteria(badge, progress)) {
          newBadges.add(badge.id);
          
          // Save badge unlock
          await _database
              .child('user_badges')
              .child(userId)
              .child(badge.id)
              .set({
                'badgeId': badge.id,
                'unlockedAt': ServerValue.timestamp,
                'userId': userId,
              }).timeout(_timeout);
        }
      }
      
      if (newBadges.isNotEmpty) {
        // Update user progress with new badges
        final updatedBadges = List<String>.from(progress.unlockedBadges)..addAll(newBadges);
        final updatedProgress = progress.copyWith(unlockedBadges: updatedBadges);
        await updateUserProgress(updatedProgress);
        
        if (kDebugMode) {
          print('🏆 New badges awarded to $userId: $newBadges');
        }
      }
    } catch (e) {
      if (kDebugMode) {
        print('❌ Error checking badges: $e');
      }
    }
  }

  // Get available badges
  static List<Badge> _getAvailableBadges() {
    return [
      // Questioner badges
      Badge(
        id: 'first_question',
        name: 'Curious Mind',
        description: 'Asked your first question',
        type: BadgeType.questioner,
        level: BadgeLevel.bronze,
        iconPath: 'assets/badges/curious_mind.png',
        requiredPoints: 0,
        criteria: 'Ask 1 question',
      ),
      Badge(
        id: 'active_questioner',
        name: 'Active Learner',
        description: 'Asked 10 questions',
        type: BadgeType.questioner,
        level: BadgeLevel.silver,
        iconPath: 'assets/badges/active_learner.png',
        requiredPoints: 0,
        criteria: 'Ask 10 questions',
      ),
      Badge(
        id: 'question_master',
        name: 'Question Master',
        description: 'Asked 50 questions',
        type: BadgeType.questioner,
        level: BadgeLevel.gold,
        iconPath: 'assets/badges/question_master.png',
        requiredPoints: 0,
        criteria: 'Ask 50 questions',
      ),
      
      // Answerer badges
      Badge(
        id: 'first_answer',
        name: 'Helper',
        description: 'Gave your first answer',
        type: BadgeType.answerer,
        level: BadgeLevel.bronze,
        iconPath: 'assets/badges/helper.png',
        requiredPoints: 0,
        criteria: 'Give 1 answer',
      ),
      Badge(
        id: 'helpful_contributor',
        name: 'Helpful Contributor',
        description: 'Gave 25 answers',
        type: BadgeType.answerer,
        level: BadgeLevel.silver,
        iconPath: 'assets/badges/helpful_contributor.png',
        requiredPoints: 0,
        criteria: 'Give 25 answers',
      ),
      Badge(
        id: 'answer_expert',
        name: 'Answer Expert',
        description: 'Gave 100 answers',
        type: BadgeType.answerer,
        level: BadgeLevel.gold,
        iconPath: 'assets/badges/answer_expert.png',
        requiredPoints: 0,
        criteria: 'Give 100 answers',
      ),
      
      // Best answer badges
      Badge(
        id: 'first_best_answer',
        name: 'Problem Solver',
        description: 'Got your first best answer',
        type: BadgeType.expert,
        level: BadgeLevel.bronze,
        iconPath: 'assets/badges/problem_solver.png',
        requiredPoints: 0,
        criteria: 'Get 1 best answer',
      ),
      Badge(
        id: 'solution_expert',
        name: 'Solution Expert',
        description: 'Got 10 best answers',
        type: BadgeType.expert,
        level: BadgeLevel.silver,
        iconPath: 'assets/badges/solution_expert.png',
        requiredPoints: 0,
        criteria: 'Get 10 best answers',
      ),
      Badge(
        id: 'master_solver',
        name: 'Master Solver',
        description: 'Got 50 best answers',
        type: BadgeType.expert,
        level: BadgeLevel.gold,
        iconPath: 'assets/badges/master_solver.png',
        requiredPoints: 0,
        criteria: 'Get 50 best answers',
      ),
      
      // Point-based badges
      Badge(
        id: 'rising_star',
        name: 'Rising Star',
        description: 'Earned 100 points',
        type: BadgeType.contributor,
        level: BadgeLevel.bronze,
        iconPath: 'assets/badges/rising_star.png',
        requiredPoints: 100,
        criteria: 'Earn 100 points',
      ),
      Badge(
        id: 'community_champion',
        name: 'Community Champion',
        description: 'Earned 500 points',
        type: BadgeType.contributor,
        level: BadgeLevel.silver,
        iconPath: 'assets/badges/community_champion.png',
        requiredPoints: 500,
        criteria: 'Earn 500 points',
      ),
      Badge(
        id: 'knowledge_guru',
        name: 'Knowledge Guru',
        description: 'Earned 1000 points',
        type: BadgeType.contributor,
        level: BadgeLevel.gold,
        iconPath: 'assets/badges/knowledge_guru.png',
        requiredPoints: 1000,
        criteria: 'Earn 1000 points',
      ),
      
      // Streak badges
      Badge(
        id: 'consistent_learner',
        name: 'Consistent Learner',
        description: '7-day activity streak',
        type: BadgeType.scholar,
        level: BadgeLevel.bronze,
        iconPath: 'assets/badges/consistent_learner.png',
        requiredPoints: 0,
        criteria: 'Maintain 7-day streak',
      ),
      Badge(
        id: 'dedicated_student',
        name: 'Dedicated Student',
        description: '30-day activity streak',
        type: BadgeType.scholar,
        level: BadgeLevel.silver,
        iconPath: 'assets/badges/dedicated_student.png',
        requiredPoints: 0,
        criteria: 'Maintain 30-day streak',
      ),
    ];
  }

  // Check if user meets badge criteria
  static bool _checkBadgeCriteria(Badge badge, UserProgress progress) {
    switch (badge.id) {
      case 'first_question':
        return progress.questionsAsked >= 1;
      case 'active_questioner':
        return progress.questionsAsked >= 10;
      case 'question_master':
        return progress.questionsAsked >= 50;
      case 'first_answer':
        return progress.answersGiven >= 1;
      case 'helpful_contributor':
        return progress.answersGiven >= 25;
      case 'answer_expert':
        return progress.answersGiven >= 100;
      case 'first_best_answer':
        return progress.bestAnswers >= 1;
      case 'solution_expert':
        return progress.bestAnswers >= 10;
      case 'master_solver':
        return progress.bestAnswers >= 50;
      case 'rising_star':
        return progress.totalPoints >= 100;
      case 'community_champion':
        return progress.totalPoints >= 500;
      case 'knowledge_guru':
        return progress.totalPoints >= 1000;
      case 'consistent_learner':
        return progress.longestStreak >= 7;
      case 'dedicated_student':
        return progress.longestStreak >= 30;
      default:
        return false;
    }
  }

  // Get leaderboard
  static Future<List<UserProgress>> getLeaderboard({int limit = 50}) async {
    try {
      final snapshot = await _database
          .child('user_progress')
          .get()
          .timeout(_timeout);
      
      if (!snapshot.exists) {
        if (kDebugMode) {
          print('📝 No user progress data found, returning empty leaderboard');
        }
        return [];
      }
      
      final leaderboard = <UserProgress>[];
      final data = snapshot.value as Map<dynamic, dynamic>;
      
      data.forEach((key, value) {
        try {
          final progress = UserProgress.fromJson(Map<String, dynamic>.from(value));
          // Only include users who have given at least 1 answer
          if (progress.answersGiven > 0) {
            leaderboard.add(progress);
          }
        } catch (e) {
          if (kDebugMode) {
            print('⚠️ Error parsing user progress for $key: $e');
          }
        }
      });
      
      // Sort by answers given (highest first), then by total points as tiebreaker
      leaderboard.sort((a, b) {
        final answerComparison = b.answersGiven.compareTo(a.answersGiven);
        if (answerComparison != 0) {
          return answerComparison;
        }
        return b.totalPoints.compareTo(a.totalPoints);
      });
      
      // Return top users up to limit
      return leaderboard.take(limit).toList();
    } catch (e) {
      if (kDebugMode) {
        print('❌ Error getting leaderboard: $e');
      }
      
      // Check if it's a permission error
      if (e.toString().contains('permission') || e.toString().contains('PERMISSION_DENIED')) {
        if (kDebugMode) {
          print('🔒 Permission denied for leaderboard, returning mock data');
        }
        // Return mock leaderboard data for development/testing
        return _getMockLeaderboardData();
      }
      
      // For other errors, return empty list instead of throwing
      return [];
    }
  }

  /// Generate mock leaderboard data for testing when Firebase permissions are not set
  static List<UserProgress> _getMockLeaderboardData() {
    return [
      UserProgress(
        userId: 'mock_user_1',
        userName: 'Top Helper',
        totalPoints: 250,
        answersGiven: 15,
        bestAnswers: 8,
        questionsAsked: 5,
        level: 3,
        experiencePoints: 250,
        lastActivity: DateTime.now(),
        unlockedBadges: ['first_answer', 'helpful_contributor'],
      ),
      UserProgress(
        userId: 'mock_user_2',
        userName: 'Expert Solver',
        totalPoints: 180,
        answersGiven: 12,
        bestAnswers: 6,
        questionsAsked: 3,
        level: 2,
        experiencePoints: 180,
        lastActivity: DateTime.now(),
        unlockedBadges: ['first_answer'],
      ),
      UserProgress(
        userId: 'mock_user_3',
        userName: 'Rising Star',
        totalPoints: 120,
        answersGiven: 8,
        bestAnswers: 3,
        questionsAsked: 4,
        level: 2,
        experiencePoints: 120,
        lastActivity: DateTime.now(),
        unlockedBadges: ['first_question', 'first_answer'],
      ),
    ];
  }

  // Get user badges
  static Future<List<Badge>> getUserBadges(String userId) async {
    try {
      final progress = await getUserProgress(userId);
      final allBadges = _getAvailableBadges();
      
      return allBadges.where((badge) => progress.unlockedBadges.contains(badge.id)).toList();
    } catch (e) {
      if (kDebugMode) {
        print('❌ Error getting user badges: $e');
      }
      throw Exception('Failed to get user badges: $e');
    }
  }

  // Track app activity for learning progress
  static Future<void> trackActivity(String userId, String activityType, {Map<String, dynamic>? metadata}) async {
    try {
      await _database
          .child('activity_logs')
          .child(userId)
          .push()
          .set({
            'userId': userId,
            'activityType': activityType,
            'timestamp': ServerValue.timestamp,
            'metadata': metadata ?? {},
          }).timeout(_timeout);
      
      // Award points based on activity
      int points = 0;
      String activity = '';
      
      switch (activityType) {
        case 'login':
          points = POINTS_DAILY_LOGIN;
          activity = 'daily_login';
          break;
        case 'coding_practice':
          points = 3;
          activity = 'coding_practice';
          break;
        case 'project_view':
          points = 1;
          activity = 'project_view';
          break;
        case 'hackathon_participation':
          points = 15;
          activity = 'hackathon_participation';
          break;
        case 'internship_application':
          points = 5;
          activity = 'internship_application';
          break;
        case 'ai_interview':
          points = 10;
          activity = 'ai_interview';
          break;
      }
      
      if (points > 0) {
        await awardPoints(userId, points, activity, subject: metadata?['subject']);
      }
      
    } catch (e) {
      if (kDebugMode) {
        print('❌ Error tracking activity: $e');
      }
    }
  }
}
