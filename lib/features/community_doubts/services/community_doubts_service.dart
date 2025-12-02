import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/foundation.dart';
import '../models/doubt_model.dart';
import '../models/answer_model.dart';
import '../../../core/providers/notification_provider.dart';

class CommunityDoubtsService {
  static final DatabaseReference _database = FirebaseDatabase.instance.ref();
  static const Duration _timeout = Duration(seconds: 15);

  // Post a new doubt
  static Future<String> postDoubt(CommunityDoubt doubt, {NotificationProvider? notificationProvider}) async {
    try {
      final doubtRef = _database.child('community_doubts').push();
      final doubtWithId = doubt.copyWith(id: doubtRef.key!);
      
      await doubtRef.set(doubtWithId.toJson()).timeout(_timeout);
      
      // Send notifications to interested users
      if (notificationProvider != null) {
        final interestedUsers = await _getInterestedUsers(doubt.subject, doubt.tags);
        await notificationProvider.sendDoubtPostedNotification(
          doubtId: doubtRef.key!,
          doubtTitle: doubt.title,
          authorId: doubt.userId,
          authorName: doubt.userName,
          interestedUsers: interestedUsers,
        );
      }
      
      if (kDebugMode) {
        print('✅ Doubt posted successfully: ${doubtRef.key}');
      }
      
      return doubtRef.key!;
    } catch (e) {
      if (kDebugMode) {
        print('❌ Error posting doubt: $e');
      }
      throw Exception('Failed to post doubt: $e');
    }
  }

  // Get all doubts with pagination
  static Future<List<CommunityDoubt>> getDoubts({
    int limit = 20,
    String? lastKey,
    String? subject,
    String? difficulty,
    bool? isResolved,
  }) async {
    try {
      Query query = _database.child('community_doubts').orderByChild('timestamp');
      
      if (lastKey != null) {
        query = query.endBefore(lastKey);
      }
      
      query = query.limitToLast(limit);
      
      final snapshot = await query.get().timeout(_timeout);
      
      if (!snapshot.exists) return [];
      
      final doubts = <CommunityDoubt>[];
      final data = snapshot.value as Map<dynamic, dynamic>;
      
      data.forEach((key, value) {
        final doubt = CommunityDoubt.fromJson(Map<String, dynamic>.from(value));
        
        // Apply filters
        bool shouldInclude = true;
        if (subject != null && doubt.subject != subject) shouldInclude = false;
        if (difficulty != null && doubt.difficulty != difficulty) shouldInclude = false;
        if (isResolved != null && doubt.isResolved != isResolved) shouldInclude = false;
        
        if (shouldInclude) {
          doubts.add(doubt);
        }
      });
      
      // Sort by timestamp (newest first)
      doubts.sort((a, b) => b.timestamp.compareTo(a.timestamp));
      
      return doubts;
    } catch (e) {
      if (kDebugMode) {
        print('❌ Error getting doubts: $e');
      }
      throw Exception('Failed to get doubts: $e');
    }
  }

  // Get doubt by ID
  static Future<CommunityDoubt?> getDoubtById(String doubtId) async {
    try {
      final snapshot = await _database
          .child('community_doubts')
          .child(doubtId)
          .get()
          .timeout(_timeout);
      
      if (!snapshot.exists) return null;
      
      return CommunityDoubt.fromJson(Map<String, dynamic>.from(snapshot.value as Map));
    } catch (e) {
      if (kDebugMode) {
        print('❌ Error getting doubt by ID: $e');
      }
      throw Exception('Failed to get doubt: $e');
    }
  }

  // Search doubts
  static Future<List<CommunityDoubt>> searchDoubts(String query) async {
    try {
      final snapshot = await _database
          .child('community_doubts')
          .orderByChild('timestamp')
          .limitToLast(100)
          .get()
          .timeout(_timeout);
      
      if (!snapshot.exists) return [];
      
      final doubts = <CommunityDoubt>[];
      final data = snapshot.value as Map<dynamic, dynamic>;
      
      data.forEach((key, value) {
        final doubt = CommunityDoubt.fromJson(Map<String, dynamic>.from(value));
        
        // Search in title, description, and tags
        final searchQuery = query.toLowerCase();
        if (doubt.title.toLowerCase().contains(searchQuery) ||
            doubt.description.toLowerCase().contains(searchQuery) ||
            doubt.tags.any((tag) => tag.toLowerCase().contains(searchQuery))) {
          doubts.add(doubt);
        }
      });
      
      doubts.sort((a, b) => b.timestamp.compareTo(a.timestamp));
      return doubts;
    } catch (e) {
      if (kDebugMode) {
        print('❌ Error searching doubts: $e');
      }
      throw Exception('Failed to search doubts: $e');
    }
  }

  // Vote on doubt
  static Future<void> voteOnDoubt(String doubtId, String userId, bool isUpvote) async {
    try {
      final doubtRef = _database.child('community_doubts').child(doubtId);
      final snapshot = await doubtRef.get().timeout(_timeout);
      
      if (!snapshot.exists) throw Exception('Doubt not found');
      
      final doubt = CommunityDoubt.fromJson(Map<String, dynamic>.from(snapshot.value as Map));
      
      List<String> upvotedBy = List.from(doubt.upvotedBy);
      List<String> downvotedBy = List.from(doubt.downvotedBy);
      
      // Remove from opposite list if exists
      if (isUpvote) {
        downvotedBy.remove(userId);
        if (upvotedBy.contains(userId)) {
          upvotedBy.remove(userId); // Remove upvote
        } else {
          upvotedBy.add(userId); // Add upvote
        }
      } else {
        upvotedBy.remove(userId);
        if (downvotedBy.contains(userId)) {
          downvotedBy.remove(userId); // Remove downvote
        } else {
          downvotedBy.add(userId); // Add downvote
        }
      }
      
      await doubtRef.update({
        'upvotes': upvotedBy.length,
        'downvotes': downvotedBy.length,
        'upvotedBy': upvotedBy,
        'downvotedBy': downvotedBy,
      }).timeout(_timeout);
      
    } catch (e) {
      if (kDebugMode) {
        print('❌ Error voting on doubt: $e');
      }
      throw Exception('Failed to vote on doubt: $e');
    }
  }

  // Post answer to doubt
  static Future<String> postAnswer(DoubtAnswer answer, {NotificationProvider? notificationProvider}) async {
    try {
      final answerRef = _database.child('doubt_answers').push();
      final answerWithId = answer.copyWith(id: answerRef.key!);
      
      await answerRef.set(answerWithId.toJson()).timeout(_timeout);
      
      // Update doubt's answer count
      await _database
          .child('community_doubts')
          .child(answer.doubtId)
          .child('answersCount')
          .set(ServerValue.increment(1))
          .timeout(_timeout);
      
      // Send notification to doubt author
      if (notificationProvider != null) {
        final doubtSnapshot = await _database
            .child('community_doubts')
            .child(answer.doubtId)
            .get()
            .timeout(_timeout);
        
        if (doubtSnapshot.exists) {
          final doubtData = Map<String, dynamic>.from(doubtSnapshot.value as Map);
          final doubt = CommunityDoubt.fromJson(doubtData);
          
          await notificationProvider.sendDoubtAnsweredNotification(
            doubtId: answer.doubtId,
            doubtTitle: doubt.title,
            doubtAuthorId: doubt.userId,
            answerId: answerRef.key!,
            answererId: answer.userId,
            answererName: answer.userName,
            answerPreview: answer.content.length > 100 
                ? '${answer.content.substring(0, 100)}...'
                : answer.content,
          );
        }
      }
      
      if (kDebugMode) {
        print('✅ Answer posted successfully: ${answerRef.key}');
      }
      
      return answerRef.key!;
    } catch (e) {
      if (kDebugMode) {
        print('❌ Error posting answer: $e');
      }
      throw Exception('Failed to post answer: $e');
    }
  }

  // Get answers for a doubt
  static Future<List<DoubtAnswer>> getAnswersForDoubt(String doubtId) async {
    try {
      final snapshot = await _database
          .child('doubt_answers')
          .orderByChild('doubtId')
          .equalTo(doubtId)
          .get()
          .timeout(_timeout);
      
      if (!snapshot.exists) return [];
      
      final answers = <DoubtAnswer>[];
      final data = snapshot.value as Map<dynamic, dynamic>;
      
      data.forEach((key, value) {
        answers.add(DoubtAnswer.fromJson(Map<String, dynamic>.from(value)));
      });
      
      // Sort by upvotes and best answer first
      answers.sort((a, b) {
        if (a.isBestAnswer && !b.isBestAnswer) return -1;
        if (!a.isBestAnswer && b.isBestAnswer) return 1;
        return b.upvotes.compareTo(a.upvotes);
      });
      
      return answers;
    } catch (e) {
      if (kDebugMode) {
        print('❌ Error getting answers: $e');
      }
      throw Exception('Failed to get answers: $e');
    }
  }

  // Check for similar answers
  static Future<List<DoubtAnswer>> checkSimilarAnswers(String doubtId, String content) async {
    try {
      final answers = await getAnswersForDoubt(doubtId);
      final similarAnswers = <DoubtAnswer>[];
      
      final contentWords = content.toLowerCase().split(' ');
      
      for (final answer in answers) {
        final answerWords = answer.content.toLowerCase().split(' ');
        int commonWords = 0;
        
        for (final word in contentWords) {
          if (word.length > 3 && answerWords.contains(word)) {
            commonWords++;
          }
        }
        
        // If more than 30% words are common, consider it similar
        if (commonWords > contentWords.length * 0.3) {
          similarAnswers.add(answer);
        }
      }
      
      return similarAnswers;
    } catch (e) {
      if (kDebugMode) {
        print('❌ Error checking similar answers: $e');
      }
      return [];
    }
  }

  // Vote on answer
  static Future<void> voteOnAnswer(String answerId, String userId, bool isUpvote) async {
    try {
      final answerRef = _database.child('doubt_answers').child(answerId);
      final snapshot = await answerRef.get().timeout(_timeout);
      
      if (!snapshot.exists) throw Exception('Answer not found');
      
      final answer = DoubtAnswer.fromJson(Map<String, dynamic>.from(snapshot.value as Map));
      
      List<String> upvotedBy = List.from(answer.upvotedBy);
      List<String> downvotedBy = List.from(answer.downvotedBy);
      
      if (isUpvote) {
        downvotedBy.remove(userId);
        if (upvotedBy.contains(userId)) {
          upvotedBy.remove(userId);
        } else {
          upvotedBy.add(userId);
        }
      } else {
        upvotedBy.remove(userId);
        if (downvotedBy.contains(userId)) {
          downvotedBy.remove(userId);
        } else {
          downvotedBy.add(userId);
        }
      }
      
      await answerRef.update({
        'upvotes': upvotedBy.length,
        'downvotes': downvotedBy.length,
        'upvotedBy': upvotedBy,
        'downvotedBy': downvotedBy,
      }).timeout(_timeout);
      
    } catch (e) {
      if (kDebugMode) {
        print('❌ Error voting on answer: $e');
      }
      throw Exception('Failed to vote on answer: $e');
    }
  }

  // Mark answer as best
  static Future<void> markAsBestAnswer(String doubtId, String answerId, String doubtOwnerId, String currentUserId) async {
    try {
      // Only doubt owner can mark best answer
      if (doubtOwnerId != currentUserId) {
        throw Exception('Only the doubt owner can mark the best answer');
      }
      
      // Update doubt with best answer
      await _database
          .child('community_doubts')
          .child(doubtId)
          .update({
            'bestAnswerId': answerId,
            'isResolved': true,
          }).timeout(_timeout);
      
      // Mark answer as best
      await _database
          .child('doubt_answers')
          .child(answerId)
          .update({'isBestAnswer': true})
          .timeout(_timeout);
      
    } catch (e) {
      if (kDebugMode) {
        print('❌ Error marking best answer: $e');
      }
      throw Exception('Failed to mark best answer: $e');
    }
  }

  // Report content
  static Future<void> reportContent(String contentId, String contentType, String userId, String reason) async {
    try {
      final reportRef = _database.child('reports').push();
      
      await reportRef.set({
        'contentId': contentId,
        'contentType': contentType, // 'doubt' or 'answer'
        'reportedBy': userId,
        'reason': reason,
        'timestamp': ServerValue.timestamp,
        'status': 'pending',
      }).timeout(_timeout);
      
      // Update content as reported
      final contentPath = contentType == 'doubt' ? 'community_doubts' : 'doubt_answers';
      await _database
          .child(contentPath)
          .child(contentId)
          .update({
            'isReported': true,
            'reportedBy': ServerValue.increment(1), // Note: Firebase Realtime DB doesn't have arrayUnion, will need different approach
          }).timeout(_timeout);
      
    } catch (e) {
      if (kDebugMode) {
        print('❌ Error reporting content: $e');
      }
      throw Exception('Failed to report content: $e');
    }
  }

  // Increment view count
  static Future<void> incrementViewCount(String doubtId) async {
    try {
      await _database
          .child('community_doubts')
          .child(doubtId)
          .child('views')
          .set(ServerValue.increment(1))
          .timeout(_timeout);
    } catch (e) {
      if (kDebugMode) {
        print('❌ Error incrementing view count: $e');
      }
    }
  }

  // Get user's doubts
  static Future<List<CommunityDoubt>> getUserDoubts(String userId) async {
    try {
      final snapshot = await _database
          .child('community_doubts')
          .orderByChild('userId')
          .equalTo(userId)
          .get()
          .timeout(_timeout);
      
      if (!snapshot.exists) return [];
      
      final doubts = <CommunityDoubt>[];
      final data = snapshot.value as Map<dynamic, dynamic>;
      
      data.forEach((key, value) {
        doubts.add(CommunityDoubt.fromJson(Map<String, dynamic>.from(value)));
      });
      
      doubts.sort((a, b) => b.timestamp.compareTo(a.timestamp));
      return doubts;
    } catch (e) {
      if (kDebugMode) {
        print('❌ Error getting user doubts: $e');
      }
      throw Exception('Failed to get user doubts: $e');
    }
  }

  // Get user's answers
  static Future<List<DoubtAnswer>> getUserAnswers(String userId) async {
    try {
      final snapshot = await _database
          .child('doubt_answers')
          .orderByChild('userId')
          .equalTo(userId)
          .get()
          .timeout(_timeout);
      
      if (!snapshot.exists) return [];
      
      final answers = <DoubtAnswer>[];
      final data = snapshot.value as Map<dynamic, dynamic>;
      
      data.forEach((key, value) {
        answers.add(DoubtAnswer.fromJson(Map<String, dynamic>.from(value)));
      });
      
      answers.sort((a, b) => b.timestamp.compareTo(a.timestamp));
      return answers;
    } catch (e) {
      if (kDebugMode) {
        print('❌ Error getting user answers: $e');
      }
      throw Exception('Failed to get user answers: $e');
    }
  }

  // Get interested users for notifications
  static Future<List<String>> _getInterestedUsers(String subject, List<String> tags) async {
    try {
      // Get users who have posted doubts in the same subject or with similar tags
      final snapshot = await _database
          .child('community_doubts')
          .orderByChild('subject')
          .equalTo(subject)
          .limitToLast(50)
          .get()
          .timeout(_timeout);
      
      final interestedUsers = <String>{};
      
      if (snapshot.exists) {
        final data = snapshot.value as Map<dynamic, dynamic>;
        data.forEach((key, value) {
          final doubt = CommunityDoubt.fromJson(Map<String, dynamic>.from(value));
          interestedUsers.add(doubt.userId);
        });
      }
      
      // Also get users who have answered questions with similar tags
      for (final tag in tags) {
        final tagSnapshot = await _database
            .child('community_doubts')
            .orderByChild('tags')
            .startAt([tag])
            .endAt([tag + '\uf8ff'])
            .limitToLast(20)
            .get()
            .timeout(_timeout);
        
        if (tagSnapshot.exists) {
          final tagData = tagSnapshot.value as Map<dynamic, dynamic>;
          tagData.forEach((key, value) {
            final doubt = CommunityDoubt.fromJson(Map<String, dynamic>.from(value));
            interestedUsers.add(doubt.userId);
          });
        }
      }
      
      return interestedUsers.toList();
    } catch (e) {
      if (kDebugMode) {
        print('❌ Error getting interested users: $e');
      }
      return [];
    }
  }
}
