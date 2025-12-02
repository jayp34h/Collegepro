import 'dart:developer';
import 'package:hive_flutter/hive_flutter.dart';
import '../models/submission.dart';
import '../models/leaderboard_entry.dart';

class CodingStorageService {
  static const String _submissionsBoxName = 'coding_submissions';
  static const String _leaderboardBoxName = 'coding_leaderboard';
  static const String _progressBoxName = 'coding_progress';

  static Box<Submission>? _submissionsBox;
  static Box<LeaderboardEntry>? _leaderboardBox;
  static Box<Map<dynamic, dynamic>>? _progressBox;

  static Future<void> initialize() async {
    try {
      log('CodingStorageService: Initializing Hive boxes');
      
      // Register adapters if not already registered
      if (!Hive.isAdapterRegistered(0)) {
        Hive.registerAdapter(SubmissionAdapter());
      }
      if (!Hive.isAdapterRegistered(1)) {
        Hive.registerAdapter(LeaderboardEntryAdapter());
      }

      // Open boxes
      _submissionsBox = await Hive.openBox<Submission>(_submissionsBoxName);
      _leaderboardBox = await Hive.openBox<LeaderboardEntry>(_leaderboardBoxName);
      _progressBox = await Hive.openBox<Map<dynamic, dynamic>>(_progressBoxName);

      log('CodingStorageService: All boxes initialized successfully');
    } catch (e) {
      log('CodingStorageService: Error initializing: $e');
      rethrow;
    }
  }

  // Submission operations
  static Future<void> saveSubmission(Submission submission) async {
    try {
      await _submissionsBox?.put(submission.id, submission);
      log('CodingStorageService: Saved submission ${submission.id}');
      
      // Update leaderboard after saving submission
      await _updateLeaderboard(submission);
    } catch (e) {
      log('CodingStorageService: Error saving submission: $e');
    }
  }

  static List<Submission> getSubmissions({String? studentId, String? questionId}) {
    try {
      final submissions = _submissionsBox?.values.toList() ?? [];
      
      return submissions.where((submission) {
        if (studentId != null && submission.studentId != studentId) {
          return false;
        }
        if (questionId != null && submission.questionId != questionId) {
          return false;
        }
        return true;
      }).toList()
        ..sort((a, b) => b.timestamp.compareTo(a.timestamp));
    } catch (e) {
      log('CodingStorageService: Error getting submissions: $e');
      return [];
    }
  }

  static Submission? getLatestSubmission(String studentId, String questionId) {
    try {
      final submissions = getSubmissions(studentId: studentId, questionId: questionId);
      return submissions.isNotEmpty ? submissions.first : null;
    } catch (e) {
      log('CodingStorageService: Error getting latest submission: $e');
      return null;
    }
  }

  static Future<void> deleteSubmission(String submissionId) async {
    try {
      await _submissionsBox?.delete(submissionId);
      log('CodingStorageService: Deleted submission $submissionId');
    } catch (e) {
      log('CodingStorageService: Error deleting submission: $e');
    }
  }

  // Leaderboard operations
  static Future<void> _updateLeaderboard(Submission submission) async {
    try {
      final studentId = submission.studentId;
      final existingEntry = _leaderboardBox?.get(studentId);
      
      final studentSubmissions = getSubmissions(studentId: studentId);
      final totalScore = studentSubmissions.fold<int>(0, (sum, sub) => sum + sub.score);
      final problemsSolved = studentSubmissions
          .where((sub) => sub.isCorrect)
          .map((sub) => sub.questionId)
          .toSet()
          .length;
      
      final averageScore = studentSubmissions.isNotEmpty 
          ? totalScore / studentSubmissions.length 
          : 0.0;

      // Count language usage
      final languageStats = <String, int>{};
      for (final sub in studentSubmissions) {
        languageStats[sub.language] = (languageStats[sub.language] ?? 0) + 1;
      }

      // Get student name (you might want to get this from user provider)
      final studentName = existingEntry?.studentName ?? 'Student $studentId';
      
      final title = LeaderboardEntry.getFunnyTitle(averageScore.round(), problemsSolved);
      final funnyNote = LeaderboardEntry.getFunnyNote(studentName, totalScore, problemsSolved);

      final updatedEntry = LeaderboardEntry(
        studentId: studentId,
        studentName: studentName,
        totalScore: totalScore,
        problemsSolved: problemsSolved,
        title: title,
        funnyNote: funnyNote,
        lastActivity: DateTime.now(),
        languageStats: languageStats,
        averageScore: averageScore,
      );

      await _leaderboardBox?.put(studentId, updatedEntry);
      log('CodingStorageService: Updated leaderboard for $studentId');
    } catch (e) {
      log('CodingStorageService: Error updating leaderboard: $e');
    }
  }

  static List<LeaderboardEntry> getLeaderboard({int limit = 50}) {
    try {
      final entries = _leaderboardBox?.values.toList() ?? [];
      entries.sort((a, b) {
        // Sort by total score first, then by problems solved
        final scoreComparison = b.totalScore.compareTo(a.totalScore);
        if (scoreComparison != 0) return scoreComparison;
        return b.problemsSolved.compareTo(a.problemsSolved);
      });
      
      return entries.take(limit).toList();
    } catch (e) {
      log('CodingStorageService: Error getting leaderboard: $e');
      return [];
    }
  }

  static LeaderboardEntry? getStudentRank(String studentId) {
    try {
      return _leaderboardBox?.get(studentId);
    } catch (e) {
      log('CodingStorageService: Error getting student rank: $e');
      return null;
    }
  }

  // Progress tracking
  static Future<void> saveProgress(String studentId, Map<String, dynamic> progress) async {
    try {
      await _progressBox?.put(studentId, progress);
      log('CodingStorageService: Saved progress for $studentId');
    } catch (e) {
      log('CodingStorageService: Error saving progress: $e');
    }
  }

  static Map<String, dynamic>? getProgress(String studentId) {
    try {
      final progress = _progressBox?.get(studentId);
      return progress != null ? Map<String, dynamic>.from(progress) : null;
    } catch (e) {
      log('CodingStorageService: Error getting progress: $e');
      return null;
    }
  }

  // Statistics
  static Map<String, dynamic> getStudentStats(String studentId) {
    try {
      final submissions = getSubmissions(studentId: studentId);
      final correctSubmissions = submissions.where((s) => s.isCorrect).toList();
      
      final languageStats = <String, int>{};
      final difficultyStats = <String, int>{};
      
      for (final submission in submissions) {
        languageStats[submission.language] = (languageStats[submission.language] ?? 0) + 1;
      }

      final totalAttempts = submissions.length;
      final successfulAttempts = correctSubmissions.length;
      final successRate = totalAttempts > 0 ? (successfulAttempts / totalAttempts * 100) : 0.0;
      
      final averageScore = submissions.isNotEmpty 
          ? submissions.fold<int>(0, (sum, s) => sum + s.score) / submissions.length 
          : 0.0;

      final averageExecutionTime = submissions.isNotEmpty
          ? submissions.fold<double>(0, (sum, s) => sum + s.executionTime) / submissions.length
          : 0.0;

      return {
        'totalAttempts': totalAttempts,
        'successfulAttempts': successfulAttempts,
        'successRate': successRate,
        'averageScore': averageScore,
        'averageExecutionTime': averageExecutionTime,
        'languageStats': languageStats,
        'difficultyStats': difficultyStats,
        'problemsSolved': correctSubmissions.map((s) => s.questionId).toSet().length,
        'lastActivity': submissions.isNotEmpty ? submissions.first.timestamp : null,
      };
    } catch (e) {
      log('CodingStorageService: Error getting student stats: $e');
      return {};
    }
  }

  // Cleanup operations
  static Future<void> clearOldSubmissions({int daysToKeep = 30}) async {
    try {
      final cutoffDate = DateTime.now().subtract(Duration(days: daysToKeep));
      final submissions = _submissionsBox?.values.toList() ?? [];
      
      for (final submission in submissions) {
        if (submission.timestamp.isBefore(cutoffDate)) {
          await _submissionsBox?.delete(submission.id);
        }
      }
      
      log('CodingStorageService: Cleaned up old submissions');
    } catch (e) {
      log('CodingStorageService: Error cleaning up submissions: $e');
    }
  }

  static Future<void> clearAllData() async {
    try {
      await _submissionsBox?.clear();
      await _leaderboardBox?.clear();
      await _progressBox?.clear();
      log('CodingStorageService: Cleared all data');
    } catch (e) {
      log('CodingStorageService: Error clearing data: $e');
    }
  }

  // Export/Import functionality
  static Map<String, dynamic> exportData() {
    try {
      final submissions = _submissionsBox?.values.map((s) => s.toJson()).toList() ?? [];
      final leaderboard = _leaderboardBox?.values.map((l) => l.toJson()).toList() ?? [];
      final progress = _progressBox?.toMap() ?? {};

      return {
        'submissions': submissions,
        'leaderboard': leaderboard,
        'progress': progress,
        'exportDate': DateTime.now().toIso8601String(),
      };
    } catch (e) {
      log('CodingStorageService: Error exporting data: $e');
      return {};
    }
  }

  static Future<void> importData(Map<String, dynamic> data) async {
    try {
      // Import submissions
      if (data['submissions'] is List) {
        for (final submissionData in data['submissions']) {
          final submission = Submission.fromJson(submissionData);
          await _submissionsBox?.put(submission.id, submission);
        }
      }

      // Import leaderboard
      if (data['leaderboard'] is List) {
        for (final entryData in data['leaderboard']) {
          final entry = LeaderboardEntry.fromJson(entryData);
          await _leaderboardBox?.put(entry.studentId, entry);
        }
      }

      // Import progress
      if (data['progress'] is Map) {
        for (final entry in (data['progress'] as Map).entries) {
          await _progressBox?.put(entry.key, entry.value);
        }
      }

      log('CodingStorageService: Data imported successfully');
    } catch (e) {
      log('CodingStorageService: Error importing data: $e');
    }
  }
}
