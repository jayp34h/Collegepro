import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/foundation.dart';
import '../models/feedback_model.dart';
import '../providers/notification_provider.dart';

class FeedbackService {
  static final FeedbackService _instance = FeedbackService._internal();
  factory FeedbackService() => _instance;
  FeedbackService._internal();

  final DatabaseReference _database = FirebaseDatabase.instance.ref();

  /// Submit feedback for a project
  Future<bool> submitFeedback(FeedbackModel feedback) async {
    try {
      debugPrint('🔄 Attempting to submit feedback for project: ${feedback.projectId}');
      
      final feedbackRef = _database.child('project_feedbacks').child(feedback.projectId).child(feedback.id);
      
      await feedbackRef.set(feedback.toMap()).timeout(
        const Duration(seconds: 15),
        onTimeout: () {
          debugPrint('⏰ Feedback submission timeout');
          throw Exception('Request timeout. Please check your internet connection.');
        },
      );
      
      // Update project feedback stats
      await _updateProjectFeedbackStats(feedback.projectId);
      
      debugPrint('✅ Feedback submitted successfully: ${feedback.id}');
      return true;
    } catch (e) {
      debugPrint('❌ Error submitting feedback: $e');
      if (e.toString().contains('permission') || e.toString().contains('PERMISSION_DENIED')) {
        throw Exception('Permission denied. Please check Firebase database rules.');
      } else if (e.toString().contains('timeout')) {
        throw Exception('Request timeout. Please check your internet connection.');
      } else {
        throw Exception('Failed to submit feedback: ${e.toString()}');
      }
    }
  }

  /// Get all feedbacks for a project
  Future<List<FeedbackModel>> getProjectFeedbacks(String projectId) async {
    try {
      debugPrint('🔄 Loading feedbacks for project: $projectId');
      
      // Add timeout to prevent infinite loading
      final snapshot = await _database
          .child('project_feedbacks')
          .child(projectId)
          .get()
          .timeout(
            const Duration(seconds: 15),
            onTimeout: () {
              debugPrint('⏰ Feedback loading timeout for project: $projectId');
              throw Exception('Timeout loading feedbacks');
            },
          );
      
      debugPrint('📊 Snapshot exists: ${snapshot.exists}');
      debugPrint('📊 Snapshot value: ${snapshot.value}');
      
      if (!snapshot.exists) {
        debugPrint('📭 No feedbacks found for project: $projectId');
        return [];
      }

      final feedbacksData = Map<String, dynamic>.from(snapshot.value as Map);
      final feedbacks = <FeedbackModel>[];

      debugPrint('📊 Raw feedbacks data keys: ${feedbacksData.keys.toList()}');

      for (final entry in feedbacksData.entries) {
        try {
          final feedbackData = Map<String, dynamic>.from(entry.value as Map);
          debugPrint('📊 Processing feedback ${entry.key}: ${feedbackData.keys.toList()}');
          
          final feedback = FeedbackModel.fromMap(feedbackData);
          feedbacks.add(feedback);
          debugPrint('✅ Successfully parsed feedback: ${feedback.id}');
        } catch (e) {
          debugPrint('❌ Error parsing feedback ${entry.key}: $e');
          debugPrint('📊 Feedback data: ${entry.value}');
        }
      }

      // Sort by timestamp (newest first)
      feedbacks.sort((a, b) => b.timestamp.compareTo(a.timestamp));
      
      debugPrint('✅ Retrieved ${feedbacks.length} feedbacks for project $projectId');
      return feedbacks;
    } catch (e) {
      debugPrint('❌ Error getting project feedbacks: $e');
      
      // Check for permission errors
      if (e.toString().contains('permission') || e.toString().contains('PERMISSION_DENIED')) {
        debugPrint('🔒 Permission denied for project feedbacks');
        // Return empty list for permission errors
        return [];
      }
      
      // For other errors, return empty list to prevent UI crashes
      return [];
    }
  }

  /// Get feedbacks stream for real-time updates
  Stream<List<FeedbackModel>> getProjectFeedbacksStream(String projectId) {
    return _database.child('project_feedbacks').child(projectId).onValue.map((event) {
      if (!event.snapshot.exists) {
        return <FeedbackModel>[];
      }

      final feedbacksData = Map<String, dynamic>.from(event.snapshot.value as Map);
      final feedbacks = <FeedbackModel>[];

      for (final entry in feedbacksData.entries) {
        try {
          final feedbackData = Map<String, dynamic>.from(entry.value as Map);
          feedbacks.add(FeedbackModel.fromMap(feedbackData));
        } catch (e) {
          debugPrint('Error parsing feedback ${entry.key}: $e');
        }
      }

      // Sort by timestamp (newest first)
      feedbacks.sort((a, b) => b.timestamp.compareTo(a.timestamp));
      return feedbacks;
    });
  }

  /// Mark feedback as helpful
  Future<bool> markFeedbackHelpful(String projectId, String feedbackId, String userId) async {
    try {
      final feedbackRef = _database.child('project_feedbacks').child(projectId).child(feedbackId);
      
      // Get current feedback
      final snapshot = await feedbackRef.get();
      if (!snapshot.exists) return false;

      final feedbackData = Map<String, dynamic>.from(snapshot.value as Map);
      final feedback = FeedbackModel.fromMap(feedbackData);

      // Check if user already marked as helpful
      if (feedback.helpfulUsers.contains(userId)) {
        // Remove helpful mark
        final updatedHelpfulUsers = List<String>.from(feedback.helpfulUsers)..remove(userId);
        await feedbackRef.update({
          'helpfulUsers': updatedHelpfulUsers,
          'helpfulCount': updatedHelpfulUsers.length,
        });
      } else {
        // Add helpful mark
        final updatedHelpfulUsers = List<String>.from(feedback.helpfulUsers)..add(userId);
        await feedbackRef.update({
          'helpfulUsers': updatedHelpfulUsers,
          'helpfulCount': updatedHelpfulUsers.length,
        });
      }

      debugPrint('✅ Feedback helpful status updated');
      return true;
    } catch (e) {
      debugPrint('❌ Error updating feedback helpful status: $e');
      return false;
    }
  }

  /// Delete feedback (only by the author)
  Future<bool> deleteFeedback(String projectId, String feedbackId, String userId) async {
    try {
      final feedbackRef = _database.child('project_feedbacks').child(projectId).child(feedbackId);
      
      // Verify ownership
      final snapshot = await feedbackRef.get();
      if (!snapshot.exists) return false;

      final feedbackData = Map<String, dynamic>.from(snapshot.value as Map);
      if (feedbackData['userId'] != userId) {
        debugPrint('❌ User not authorized to delete this feedback');
        return false;
      }

      await feedbackRef.remove();
      
      // Update project feedback stats
      await _updateProjectFeedbackStats(projectId);
      
      debugPrint('✅ Feedback deleted successfully');
      return true;
    } catch (e) {
      debugPrint('❌ Error deleting feedback: $e');
      return false;
    }
  }

  /// Get feedback statistics for a project
  Future<FeedbackStats> getProjectFeedbackStats(String projectId) async {
    try {
      final feedbacks = await getProjectFeedbacks(projectId);
      return FeedbackStats.fromFeedbacks(feedbacks);
    } catch (e) {
      debugPrint('❌ Error getting feedback stats: $e');
      return FeedbackStats.empty();
    }
  }

  /// Update project feedback statistics
  Future<void> _updateProjectFeedbackStats(String projectId) async {
    try {
      final feedbacks = await getProjectFeedbacks(projectId);
      final stats = FeedbackStats.fromFeedbacks(feedbacks);
      
      final statsRef = _database.child('project_feedback_stats').child(projectId);
      await statsRef.set({
        'averageRating': stats.averageRating,
        'totalFeedbacks': stats.totalFeedbacks,
        'categoryCount': stats.categoryCount,
        'ratingDistribution': stats.ratingDistribution,
        'lastUpdated': DateTime.now().millisecondsSinceEpoch,
      });
      
      debugPrint('✅ Project feedback stats updated');
    } catch (e) {
      debugPrint('❌ Error updating project feedback stats: $e');
    }
  }

  /// Edit reply content
  Future<bool> editReply(String projectId, String feedbackId, String replyId, String newContent, String userId) async {
    try {
      debugPrint('🔄 Editing reply: $replyId in feedback: $feedbackId');
      
      // Get the entire feedback to access replies
      final feedbackRef = _database
          .child('project_feedbacks')
          .child(projectId)
          .child(feedbackId);
      
      final feedbackSnapshot = await feedbackRef.get().timeout(
        const Duration(seconds: 15),
        onTimeout: () {
          debugPrint('⏰ Feedback fetch timeout');
          throw Exception('Request timeout. Please check your internet connection.');
        },
      );
      
      if (!feedbackSnapshot.exists) {
        debugPrint('❌ Feedback not found: $feedbackId');
        return false;
      }
      
      final feedbackData = Map<String, dynamic>.from(feedbackSnapshot.value as Map);
      final repliesData = feedbackData['replies'] as Map<dynamic, dynamic>?;
      
      if (repliesData == null || !repliesData.containsKey(replyId)) {
        debugPrint('❌ Reply not found: $replyId');
        return false;
      }
      
      // Verify ownership before editing
      final replyData = Map<String, dynamic>.from(repliesData[replyId] as Map);
      debugPrint('🔍 Reply data: $replyData');
      debugPrint('🔍 Current user ID: $userId');
      debugPrint('🔍 Reply author ID: ${replyData['userId']}');
      
      if (replyData['userId'] != userId) {
        debugPrint('❌ User not authorized to edit this reply');
        return false;
      }
      
      // Update only the specific reply using direct path
      final replyRef = feedbackRef.child('replies').child(replyId);
      
      debugPrint('🔍 Attempting to update reply at path: project_feedbacks/$projectId/$feedbackId/replies/$replyId');
      debugPrint('🔍 Update data: reply=$newContent, editedAt=${DateTime.now().millisecondsSinceEpoch}, isEdited=true');
      
      // Use set() instead of update() to ensure proper ownership validation
      final updatedReplyData = Map<String, dynamic>.from(replyData);
      updatedReplyData['reply'] = newContent;
      updatedReplyData['editedAt'] = DateTime.now().millisecondsSinceEpoch;
      updatedReplyData['isEdited'] = true;
      
      await replyRef.set(updatedReplyData).timeout(
        const Duration(seconds: 15),
        onTimeout: () {
          debugPrint('⏰ Reply edit timeout');
          throw Exception('Request timeout. Please check your internet connection.');
        },
      );
      
      debugPrint('✅ Reply edited successfully: $replyId');
      return true;
    } catch (e) {
      debugPrint('❌ Error editing reply: $e');
      if (e.toString().contains('permission') || e.toString().contains('PERMISSION_DENIED')) {
        debugPrint('🔒 Permission denied for reply editing');
        return false;
      } else if (e.toString().contains('timeout')) {
        debugPrint('⏰ Timeout during reply editing');
        return false;
      } else {
        debugPrint('💥 Unexpected error during reply editing: ${e.toString()}');
        return false;
      }
    }
  }

  /// Delete reply from feedback
  Future<bool> deleteReply(String projectId, String feedbackId, String replyId, String userId) async {
    try {
      debugPrint('🔄 Deleting reply: $replyId from feedback: $feedbackId');
      
      // First, get the feedback to access its replies
      final feedbackRef = _database
          .child('project_feedbacks')
          .child(projectId)
          .child(feedbackId);
      
      final feedbackSnapshot = await feedbackRef.get().timeout(
        const Duration(seconds: 15),
        onTimeout: () {
          debugPrint('⏰ Feedback fetch timeout');
          throw Exception('Request timeout. Please check your internet connection.');
        },
      );
      
      if (!feedbackSnapshot.exists) {
        debugPrint('❌ Feedback not found: $feedbackId');
        return false;
      }
      
      final feedbackData = Map<String, dynamic>.from(feedbackSnapshot.value as Map);
      final repliesData = feedbackData['replies'] as Map<dynamic, dynamic>?;
      
      if (repliesData == null || !repliesData.containsKey(replyId)) {
        debugPrint('❌ Reply not found: $replyId');
        return false;
      }
      
      // Verify ownership before deletion
      final replyData = Map<String, dynamic>.from(repliesData[replyId] as Map);
      debugPrint('🔍 Delete - Reply data: $replyData');
      debugPrint('🔍 Delete - Current user ID: $userId');
      debugPrint('🔍 Delete - Reply author ID: ${replyData['userId']}');
      
      if (replyData['userId'] != userId) {
        debugPrint('❌ User not authorized to delete this reply');
        return false;
      }
      
      // Delete the specific reply using direct path
      final replyRef = feedbackRef.child('replies').child(replyId);
      
      debugPrint('🔍 Attempting to delete reply at path: project_feedbacks/$projectId/$feedbackId/replies/$replyId');
      
      await replyRef.remove().timeout(
        const Duration(seconds: 15),
        onTimeout: () {
          debugPrint('⏰ Reply deletion timeout');
          throw Exception('Request timeout. Please check your internet connection.');
        },
      );
      
      debugPrint('✅ Reply deleted successfully: $replyId');
      return true;
    } catch (e) {
      debugPrint('❌ Error deleting reply: $e');
      if (e.toString().contains('permission') || e.toString().contains('PERMISSION_DENIED')) {
        // Return false instead of throwing to prevent UI crashes
        debugPrint('🔒 Permission denied for reply deletion');
        return false;
      } else if (e.toString().contains('timeout')) {
        debugPrint('⏰ Timeout during reply deletion');
        return false;
      } else {
        debugPrint('💥 Unexpected error during reply deletion: ${e.toString()}');
        return false;
      }
    }
  }

  /// Get user's feedback for a specific project
  Future<FeedbackModel?> getUserFeedbackForProject(String projectId, String userId) async {
    try {
      final feedbacks = await getProjectFeedbacks(projectId);
      return feedbacks.where((feedback) => feedback.userId == userId).firstOrNull;
    } catch (e) {
      debugPrint('❌ Error getting user feedback: $e');
      return null;
    }
  }

  /// Update existing feedback
  Future<bool> updateFeedback(FeedbackModel feedback) async {
    try {
      debugPrint('🔄 Attempting to update feedback: ${feedback.id}');
      
      final feedbackRef = _database.child('project_feedbacks').child(feedback.projectId).child(feedback.id);
      
      await feedbackRef.update(feedback.toMap()).timeout(
        const Duration(seconds: 15),
        onTimeout: () {
          debugPrint('⏰ Feedback update timeout');
          throw Exception('Request timeout. Please check your internet connection.');
        },
      );
      
      // Update project feedback stats
      await _updateProjectFeedbackStats(feedback.projectId);
      
      debugPrint('✅ Feedback updated successfully');
      return true;
    } catch (e) {
      debugPrint('❌ Error updating feedback: $e');
      if (e.toString().contains('permission') || e.toString().contains('PERMISSION_DENIED')) {
        throw Exception('Permission denied. Please check Firebase database rules.');
      } else if (e.toString().contains('timeout')) {
        throw Exception('Request timeout. Please check your internet connection.');
      } else {
        throw Exception('Failed to update feedback: ${e.toString()}');
      }
    }
  }

  /// Get feedbacks by category
  Future<List<FeedbackModel>> getFeedbacksByCategory(String projectId, String category) async {
    try {
      final allFeedbacks = await getProjectFeedbacks(projectId);
      return allFeedbacks.where((feedback) => feedback.category == category).toList();
    } catch (e) {
      debugPrint('❌ Error getting feedbacks by category: $e');
      return [];
    }
  }

  /// Search feedbacks by text
  Future<List<FeedbackModel>> searchFeedbacks(String projectId, String query) async {
    try {
      final allFeedbacks = await getProjectFeedbacks(projectId);
      final lowercaseQuery = query.toLowerCase();
      
      return allFeedbacks.where((feedback) {
        return feedback.feedback.toLowerCase().contains(lowercaseQuery) ||
               feedback.userName.toLowerCase().contains(lowercaseQuery) ||
               feedback.tags.any((tag) => tag.toLowerCase().contains(lowercaseQuery));
      }).toList();
    } catch (e) {
      debugPrint('❌ Error searching feedbacks: $e');
      return [];
    }
  }

  /// Add reply to feedback
  Future<bool> addReplyToFeedback(String projectId, String feedbackId, String replyId, String content, String userId, String userName, {NotificationProvider? notificationProvider}) async {
    try {
      debugPrint('🔄 Adding reply to feedback: $feedbackId');
      
      final replyRef = _database
          .child('project_feedbacks')
          .child(projectId)
          .child(feedbackId)
          .child('replies')
          .child(replyId);  // Use the provided replyId instead of push()
      
      final replyData = {
        'id': replyId,
        'reply': content,
        'userId': userId,
        'userName': userName,
        'timestamp': DateTime.now().millisecondsSinceEpoch,
      };
      
      debugPrint('🔍 Creating reply with data: $replyData');
      debugPrint('🔍 Reply path: project_feedbacks/$projectId/$feedbackId/replies/$replyId');
      
      // Set the reply with the generated key
      await replyRef.set(replyData).timeout(
        const Duration(seconds: 15),
        onTimeout: () {
          debugPrint('⏰ Reply submission timeout');
          throw Exception('Request timeout. Please check your internet connection.');
        },
      );
      
      // Send notification to feedback author
      if (notificationProvider != null) {
        final feedbackSnapshot = await _database
            .child('project_feedbacks')
            .child(projectId)
            .child(feedbackId)
            .get()
            .timeout(const Duration(seconds: 15));
        
        if (feedbackSnapshot.exists) {
          final feedbackData = Map<String, dynamic>.from(feedbackSnapshot.value as Map);
          final feedback = FeedbackModel.fromMap(feedbackData);
          
          await notificationProvider.sendFeedbackReplyNotification(
            feedbackId: feedbackId,
            feedbackAuthorId: feedback.userId,
            projectId: projectId,
            projectTitle: 'Project Feedback',
            replyId: replyData['id'] as String,
            replierId: userId,
            replierName: userName,
            replyPreview: content.length > 100 
                ? '${content.substring(0, 100)}...'
                : content,
          );
        }
      }
      
      debugPrint('✅ Reply added successfully to feedback: $feedbackId');
      return true;
    } catch (e) {
      debugPrint('❌ Error adding reply to feedback: $e');
      if (e.toString().contains('permission') || e.toString().contains('PERMISSION_DENIED')) {
        throw Exception('Permission denied. Please check Firebase database rules.');
      } else if (e.toString().contains('timeout')) {
        throw Exception('Request timeout. Please check your internet connection.');
      } else {
        throw Exception('Failed to add reply: ${e.toString()}');
      }
    }
  }
}
