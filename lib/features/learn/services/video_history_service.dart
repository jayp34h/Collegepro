import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import '../models/video_history.dart';
import '../services/youtube_service.dart';

class VideoHistoryService {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  static const String _videoHistoryCollection = 'video_history';
  static const String _watchSessionsCollection = 'video_watch_sessions';

  /// Start tracking a video watch session
  static Future<void> startWatchSession({
    required String userId,
    required YouTubeVideo video,
    required String category,
    List<String>? tags,
  }) async {
    try {
      final sessionId = '${userId}_${video.id}_${DateTime.now().millisecondsSinceEpoch}';
      final now = DateTime.now();

      // Create or update video history record
      final historyId = '${userId}_${video.id}';
      final existingHistory = await getVideoHistory(userId, video.id);

      VideoHistory history;
      if (existingHistory != null) {
        // Update existing history
        history = existingHistory.copyWith(
          lastWatchedAt: now,
        );
      } else {
        // Create new history record
        history = VideoHistory(
          id: historyId,
          userId: userId,
          videoId: video.id,
          videoTitle: video.title,
          videoUrl: video.url,
          thumbnailUrl: video.thumbnailUrl,
          channelName: video.channelTitle,
          videoDuration: video.duration,
          watchedDuration: Duration.zero,
          watchPercentage: 0.0,
          startedAt: now,
          lastWatchedAt: now,
          isCompleted: false,
          category: category,
          tags: tags ?? [],
        );
      }

      // Save history to Firestore
      await _firestore
          .collection(_videoHistoryCollection)
          .doc(historyId)
          .set(history.toJson());

      // Create watch session
      final session = VideoWatchSession(
        sessionId: sessionId,
        userId: userId,
        videoId: video.id,
        startTime: now,
        watchedDuration: Duration.zero,
        segments: [],
      );

      await _firestore
          .collection(_watchSessionsCollection)
          .doc(sessionId)
          .set(session.toJson());

      if (kDebugMode) {
        print('📺 Started video watch session: ${video.title}');
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error starting watch session: $e');
      }
    }
  }

  /// Update video watch progress
  static Future<void> updateWatchProgress({
    required String userId,
    required String videoId,
    required Duration currentPosition,
    required Duration totalDuration,
  }) async {
    try {
      final historyId = '${userId}_$videoId';
      final watchPercentage = totalDuration.inSeconds > 0 
          ? (currentPosition.inSeconds / totalDuration.inSeconds) * 100 
          : 0.0;
      
      final isCompleted = watchPercentage >= 90.0; // Consider 90% as completed

      await _firestore
          .collection(_videoHistoryCollection)
          .doc(historyId)
          .update({
        'watchedDurationSeconds': currentPosition.inSeconds,
        'watchPercentage': watchPercentage,
        'lastWatchedAt': DateTime.now().toIso8601String(),
        'isCompleted': isCompleted,
      });

      if (kDebugMode) {
        print('📊 Updated watch progress: ${watchPercentage.toStringAsFixed(1)}%');
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error updating watch progress: $e');
      }
    }
  }

  /// End video watch session
  static Future<void> endWatchSession({
    required String userId,
    required String videoId,
    required Duration finalPosition,
    required Duration totalDuration,
  }) async {
    try {
      // Update final progress
      await updateWatchProgress(
        userId: userId,
        videoId: videoId,
        currentPosition: finalPosition,
        totalDuration: totalDuration,
      );

      // Find and update the latest session
      final sessionsQuery = await _firestore
          .collection(_watchSessionsCollection)
          .where('userId', isEqualTo: userId)
          .where('videoId', isEqualTo: videoId)
          .where('endTime', isNull: true)
          .orderBy('startTime', descending: true)
          .limit(1)
          .get();

      if (sessionsQuery.docs.isNotEmpty) {
        final sessionDoc = sessionsQuery.docs.first;
        await sessionDoc.reference.update({
          'endTime': DateTime.now().toIso8601String(),
          'watchedDurationSeconds': finalPosition.inSeconds,
        });
      }

      if (kDebugMode) {
        print('🏁 Ended video watch session');
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error ending watch session: $e');
      }
    }
  }

  /// Get user's video history
  static Future<List<VideoHistory>> getUserVideoHistory(String userId, {int limit = 50}) async {
    try {
      final querySnapshot = await _firestore
          .collection(_videoHistoryCollection)
          .where('userId', isEqualTo: userId)
          .orderBy('lastWatchedAt', descending: true)
          .limit(limit)
          .get();

      return querySnapshot.docs
          .map((doc) => VideoHistory.fromJson({...doc.data(), 'id': doc.id}))
          .toList();
    } catch (e) {
      if (kDebugMode) {
        print('Error fetching video history: $e');
      }
      return [];
    }
  }

  /// Get specific video history
  static Future<VideoHistory?> getVideoHistory(String userId, String videoId) async {
    try {
      final historyId = '${userId}_$videoId';
      final doc = await _firestore
          .collection(_videoHistoryCollection)
          .doc(historyId)
          .get();

      if (doc.exists) {
        return VideoHistory.fromJson({...doc.data()!, 'id': doc.id});
      }
      return null;
    } catch (e) {
      if (kDebugMode) {
        print('Error fetching video history: $e');
      }
      return null;
    }
  }

  /// Get user's watch statistics
  static Future<Map<String, dynamic>> getUserWatchStats(String userId) async {
    try {
      final history = await getUserVideoHistory(userId, limit: 1000);
      
      final totalVideos = history.length;
      final completedVideos = history.where((h) => h.isCompleted).length;
      final totalWatchTime = history.fold<Duration>(
        Duration.zero,
        (sum, h) => sum + h.watchedDuration,
      );
      
      final categoryStats = <String, int>{};
      for (final video in history) {
        categoryStats[video.category] = (categoryStats[video.category] ?? 0) + 1;
      }

      return {
        'totalVideos': totalVideos,
        'completedVideos': completedVideos,
        'completionRate': totalVideos > 0 ? (completedVideos / totalVideos) * 100 : 0.0,
        'totalWatchTimeHours': totalWatchTime.inHours,
        'totalWatchTimeMinutes': totalWatchTime.inMinutes,
        'categoryStats': categoryStats,
        'averageWatchPercentage': history.isNotEmpty 
            ? history.map((h) => h.watchPercentage).reduce((a, b) => a + b) / history.length
            : 0.0,
      };
    } catch (e) {
      if (kDebugMode) {
        print('Error calculating watch stats: $e');
      }
      return {};
    }
  }

  /// Get trending videos based on watch history
  static Future<List<Map<String, dynamic>>> getTrendingVideos({int limit = 10}) async {
    try {
      final querySnapshot = await _firestore
          .collection(_videoHistoryCollection)
          .where('lastWatchedAt', isGreaterThan: DateTime.now().subtract(Duration(days: 7)).toIso8601String())
          .get();

      final videoStats = <String, Map<String, dynamic>>{};
      
      for (final doc in querySnapshot.docs) {
        final data = doc.data();
        final videoId = data['videoId'];
        
        if (videoStats.containsKey(videoId)) {
          videoStats[videoId]!['watchCount'] += 1;
          videoStats[videoId]!['totalWatchTime'] += data['watchedDurationSeconds'] ?? 0;
        } else {
          videoStats[videoId] = {
            'videoId': videoId,
            'videoTitle': data['videoTitle'],
            'thumbnailUrl': data['thumbnailUrl'],
            'channelName': data['channelName'],
            'category': data['category'],
            'watchCount': 1,
            'totalWatchTime': data['watchedDurationSeconds'] ?? 0,
          };
        }
      }

      final trendingList = videoStats.values.toList();
      trendingList.sort((a, b) => b['watchCount'].compareTo(a['watchCount']));
      
      return trendingList.take(limit).toList();
    } catch (e) {
      if (kDebugMode) {
        print('Error fetching trending videos: $e');
      }
      return [];
    }
  }

  /// Delete user's video history
  static Future<void> deleteVideoHistory(String userId, String videoId) async {
    try {
      final historyId = '${userId}_$videoId';
      await _firestore
          .collection(_videoHistoryCollection)
          .doc(historyId)
          .delete();

      // Also delete related watch sessions
      final sessionsQuery = await _firestore
          .collection(_watchSessionsCollection)
          .where('userId', isEqualTo: userId)
          .where('videoId', isEqualTo: videoId)
          .get();

      for (final doc in sessionsQuery.docs) {
        await doc.reference.delete();
      }

      if (kDebugMode) {
        print('🗑️ Deleted video history for $videoId');
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error deleting video history: $e');
      }
    }
  }

  /// Clear all user's video history
  static Future<void> clearAllHistory(String userId) async {
    try {
      // Delete all video history
      final historyQuery = await _firestore
          .collection(_videoHistoryCollection)
          .where('userId', isEqualTo: userId)
          .get();

      for (final doc in historyQuery.docs) {
        await doc.reference.delete();
      }

      // Delete all watch sessions
      final sessionsQuery = await _firestore
          .collection(_watchSessionsCollection)
          .where('userId', isEqualTo: userId)
          .get();

      for (final doc in sessionsQuery.docs) {
        await doc.reference.delete();
      }

      if (kDebugMode) {
        print('🧹 Cleared all video history for user');
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error clearing video history: $e');
      }
    }
  }
}
