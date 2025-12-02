import 'dart:async';
import 'dart:developer';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/notification_model.dart';
import 'fcm_service.dart';

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FirebaseDatabase _database = FirebaseDatabase.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FCMService _fcmService = FCMService();
  
  StreamSubscription<DatabaseEvent>? _notificationSubscription;
  final StreamController<List<NotificationModel>> _notificationsController = 
      StreamController<List<NotificationModel>>.broadcast();

  // Stream of notifications for current user
  Stream<List<NotificationModel>> get notificationsStream => _notificationsController.stream;

  // Initialize notification listening for current user
  Future<void> initialize() async {
    final user = _auth.currentUser;
    if (user == null) return;

    await _startListening(user.uid);
    log('NotificationService: Initialized for user ${user.uid}');
  }

  // Start listening to notifications for a specific user
  Future<void> _startListening(String userId) async {
    try {
      _notificationSubscription?.cancel();
      
      final notificationsRef = _database
          .ref('notifications')
          .child(userId)
          .orderByChild('timestamp');

      _notificationSubscription = notificationsRef.onValue.listen(
        (DatabaseEvent event) {
          final data = event.snapshot.value;
          if (data != null && data is Map) {
            final notifications = <NotificationModel>[];
            
            data.forEach((key, value) {
              if (value is Map) {
                try {
                  final notification = NotificationModel.fromJson(
                    Map<String, dynamic>.from(value),
                  );
                  
                  // Filter out expired notifications
                  if (!notification.isExpired) {
                    notifications.add(notification);
                  }
                } catch (e) {
                  log('NotificationService: Error parsing notification: $e');
                }
              }
            });

            // Sort by timestamp (newest first)
            notifications.sort((a, b) => b.timestamp.compareTo(a.timestamp));
            _notificationsController.add(notifications);
            
            log('NotificationService: Loaded ${notifications.length} notifications');
          } else {
            _notificationsController.add([]);
          }
        },
        onError: (error) {
          log('NotificationService: Error listening to notifications: $error');
          _notificationsController.addError(error);
        },
      );
    } catch (e) {
      log('NotificationService: Error starting notification listener: $e');
    }
  }

  // Send a notification to a specific user
  Future<bool> sendNotification(NotificationModel notification) async {
    try {
      final notificationRef = _database
          .ref('notifications')
          .child(notification.recipientId)
          .child(notification.id);

      await notificationRef.set(notification.toJson());
      
      // Also store in global notifications for admin purposes
      await _database
          .ref('all_notifications')
          .child(notification.id)
          .set(notification.toJson());
      
      // Also send push notification
      await _fcmService.sendPushNotification(
        recipientId: notification.recipientId,
        title: notification.title,
        body: notification.message,
        data: {
          'type': notification.type.toString().split('.').last,
          'notificationId': notification.id,
          'actionUrl': notification.actionUrl ?? '',
          ...notification.data,
        },
      );
      
      log('NotificationService: Sent notification ${notification.id} to ${notification.recipientId}');
      return true;
    } catch (e) {
      log('NotificationService: Error sending notification: $e');
      return false;
    }
  }

  // Create and send doubt posted notification
  Future<bool> sendDoubtPostedNotification({
    required String doubtId,
    required String doubtTitle,
    required String authorId,
    required String authorName,
    required List<String> interestedUsers, // Users following similar topics
  }) async {
    try {
      final notifications = <Future<bool>>[];
      
      for (final userId in interestedUsers) {
        if (userId == authorId) continue; // Don't notify the author
        
        final notification = NotificationModel(
          id: '${DateTime.now().millisecondsSinceEpoch}_doubt_$doubtId',
          recipientId: userId,
          senderId: authorId,
          senderName: authorName,
          type: NotificationType.doubtPosted,
          priority: NotificationPriority.medium,
          title: '🤔 New Doubt Posted',
          message: '$authorName posted a new doubt: "$doubtTitle"',
          data: {
            'doubtId': doubtId,
            'doubtTitle': doubtTitle,
            'authorId': authorId,
            'authorName': authorName,
          },
          timestamp: DateTime.now(),
          actionUrl: '/community-doubts/details/$doubtId',
        );
        
        notifications.add(sendNotification(notification));
      }
      
      // Also send FCM push notifications
      await _fcmService.sendDoubtPostedPush(
        recipientIds: interestedUsers.where((id) => id != authorId).toList(),
        doubtTitle: doubtTitle,
        authorName: authorName,
        doubtId: doubtId,
      );
      
      final results = await Future.wait(notifications);
      final successCount = results.where((result) => result).length;
      
      log('NotificationService: Sent doubt notifications to $successCount users');
      return successCount > 0;
    } catch (e) {
      log('NotificationService: Error sending doubt posted notifications: $e');
      return false;
    }
  }

  // Create and send mentor reply notification
  Future<bool> sendMentorReplyNotification({
    required String doubtId,
    required String doubtTitle,
    required String studentId,
    required String mentorId,
    required String mentorName,
    required String replyPreview,
  }) async {
    try {
      final notification = NotificationModel(
        id: '${DateTime.now().millisecondsSinceEpoch}_mentor_reply_$doubtId',
        recipientId: studentId,
        senderId: mentorId,
        senderName: mentorName,
        type: NotificationType.doubtAnswered,
        priority: NotificationPriority.high,
        title: '🎓 Mentor Replied to Your Doubt!',
        message: '$mentorName replied to your doubt: "$doubtTitle"',
        data: {
          'doubtId': doubtId,
          'doubtTitle': doubtTitle,
          'mentorId': mentorId,
          'mentorName': mentorName,
          'replyPreview': replyPreview,
        },
        timestamp: DateTime.now(),
        actionUrl: '/mentor/doubts/$doubtId',
      );
      
      final result = await sendNotification(notification);
      
      // Also send FCM push notification
      if (result) {
        await _fcmService.sendPushNotification(
          recipientId: studentId,
          title: '🎓 Mentor Reply',
          body: '$mentorName replied to your doubt: "$doubtTitle"',
          data: {
            'type': 'mentor_reply',
            'doubtId': doubtId,
            'mentorId': mentorId,
          },
        );
      }
      
      return result;
    } catch (e) {
      log('NotificationService: Error sending mentor reply notification: $e');
      return false;
    }
  }

  // Create and send doubt answered notification
  Future<bool> sendDoubtAnsweredNotification({
    required String doubtId,
    required String doubtTitle,
    required String doubtAuthorId,
    required String answerId,
    required String answererId,
    required String answererName,
    required String answerPreview,
  }) async {
    try {
      final notification = NotificationModel(
        id: '${DateTime.now().millisecondsSinceEpoch}_answer_$answerId',
        recipientId: doubtAuthorId,
        senderId: answerId,
        senderName: answererName,
        type: NotificationType.doubtAnswered,
        priority: NotificationPriority.high,
        title: '💡 Your Doubt Got Answered!',
        message: '$answererName answered your doubt: "$doubtTitle"',
        data: {
          'doubtId': doubtId,
          'doubtTitle': doubtTitle,
          'answerId': answerId,
          'answererId': answerId,
          'answererName': answererName,
          'answerPreview': answerPreview,
        },
        timestamp: DateTime.now(),
        actionUrl: '/community-doubts/details/$doubtId#answer-$answerId',
      );
      
      final result = await sendNotification(notification);
      
      // Also send FCM push notification
      if (result) {
        await _fcmService.sendDoubtAnsweredPush(
          recipientId: doubtAuthorId,
          doubtTitle: doubtTitle,
          answererName: answererName,
          doubtId: doubtId,
          answerId: answerId,
        );
      }
      
      return result;
    } catch (e) {
      log('NotificationService: Error sending doubt answered notification: $e');
      return false;
    }
  }

  // Create and send feedback received notification
  Future<bool> sendFeedbackReceivedNotification({
    required String projectId,
    required String projectTitle,
    required String projectAuthorId,
    required String feedbackId,
    required String feedbackerId,
    required String feedbackerName,
    required double rating,
    required String feedbackPreview,
  }) async {
    try {
      final notification = NotificationModel(
        id: '${DateTime.now().millisecondsSinceEpoch}_feedback_$feedbackId',
        recipientId: projectAuthorId,
        senderId: feedbackerId,
        senderName: feedbackerName,
        type: NotificationType.feedbackReceived,
        priority: NotificationPriority.medium,
        title: '⭐ New Feedback on Your Project!',
        message: '$feedbackerName gave ${rating.toStringAsFixed(1)} stars on "$projectTitle"',
        data: {
          'projectId': projectId,
          'projectTitle': projectTitle,
          'feedbackId': feedbackId,
          'feedbackerId': feedbackerId,
          'feedbackerName': feedbackerName,
          'rating': rating,
          'feedbackPreview': feedbackPreview,
        },
        timestamp: DateTime.now(),
        actionUrl: '/project-details/$projectId#feedback-$feedbackId',
      );
      
      final result = await sendNotification(notification);
      
      // Also send FCM push notification
      if (result) {
        await _fcmService.sendFeedbackReceivedPush(
          recipientId: projectAuthorId,
          projectTitle: projectTitle,
          feedbackerName: feedbackerName,
          rating: rating,
          projectId: projectId,
          feedbackId: feedbackId,
        );
      }
      
      return result;
    } catch (e) {
      log('NotificationService: Error sending feedback received notification: $e');
      return false;
    }
  }

  // Create and send feedback reply notification
  Future<bool> sendFeedbackReplyNotification({
    required String projectId,
    required String projectTitle,
    required String feedbackId,
    required String feedbackAuthorId,
    required String replyId,
    required String replierId,
    required String replierName,
    required String replyPreview,
  }) async {
    try {
      final notification = NotificationModel(
        id: '${DateTime.now().millisecondsSinceEpoch}_reply_$replyId',
        recipientId: feedbackAuthorId,
        senderId: replierId,
        senderName: replierName,
        type: NotificationType.feedbackReply,
        priority: NotificationPriority.high,
        title: '💬 Reply to Your Feedback!',
        message: '$replierName replied to your feedback on "$projectTitle"',
        data: {
          'projectId': projectId,
          'projectTitle': projectTitle,
          'feedbackId': feedbackId,
          'replyId': replyId,
          'replierId': replierId,
          'replierName': replierName,
          'replyPreview': replyPreview,
        },
        timestamp: DateTime.now(),
        actionUrl: '/project-details/$projectId#feedback-$feedbackId-reply-$replyId',
      );
      
      final result = await sendNotification(notification);
      
      // Also send FCM push notification
      if (result) {
        await _fcmService.sendFeedbackReplyPush(
          recipientId: feedbackAuthorId,
          projectTitle: projectTitle,
          replierName: replierName,
          projectId: projectId,
          feedbackId: feedbackId,
          replyId: replyId,
        );
      }
      
      return result;
    } catch (e) {
      log('NotificationService: Error sending feedback reply notification: $e');
      return false;
    }
  }

  // Mark notification as read
  Future<bool> markAsRead(String notificationId) async {
    try {
      final user = _auth.currentUser;
      if (user == null) return false;

      await _database
          .ref('notifications')
          .child(user.uid)
          .child(notificationId)
          .child('isRead')
          .set(true);

      log('NotificationService: Marked notification $notificationId as read');
      return true;
    } catch (e) {
      log('NotificationService: Error marking notification as read: $e');
      return false;
    }
  }

  // Mark all notifications as read
  Future<bool> markAllAsRead() async {
    try {
      final user = _auth.currentUser;
      if (user == null) return false;

      final snapshot = await _database
          .ref('notifications')
          .child(user.uid)
          .get();

      if (snapshot.exists && snapshot.value is Map) {
        final updates = <String, dynamic>{};
        final data = snapshot.value as Map;
        
        data.forEach((key, value) {
          updates['notifications/${user.uid}/$key/isRead'] = true;
        });

        await _database.ref().update(updates);
        log('NotificationService: Marked all notifications as read');
        return true;
      }
      
      return false;
    } catch (e) {
      log('NotificationService: Error marking all notifications as read: $e');
      return false;
    }
  }

  // Delete notification
  Future<bool> deleteNotification(String notificationId) async {
    try {
      final user = _auth.currentUser;
      if (user == null) return false;

      await _database
          .ref('notifications')
          .child(user.uid)
          .child(notificationId)
          .remove();

      log('NotificationService: Deleted notification $notificationId');
      return true;
    } catch (e) {
      log('NotificationService: Error deleting notification: $e');
      return false;
    }
  }

  // Get unread notification count
  Future<int> getUnreadCount() async {
    try {
      final user = _auth.currentUser;
      if (user == null) return 0;

      final snapshot = await _database
          .ref('notifications')
          .child(user.uid)
          .orderByChild('isRead')
          .equalTo(false)
          .get();

      if (snapshot.exists && snapshot.value is Map) {
        return (snapshot.value as Map).length;
      }
      
      return 0;
    } catch (e) {
      log('NotificationService: Error getting unread count: $e');
      return 0;
    }
  }

  // Clean up expired notifications
  Future<void> cleanupExpiredNotifications() async {
    try {
      final user = _auth.currentUser;
      if (user == null) return;

      final snapshot = await _database
          .ref('notifications')
          .child(user.uid)
          .get();

      if (snapshot.exists && snapshot.value is Map) {
        final data = snapshot.value as Map;
        final expiredIds = <String>[];
        
        data.forEach((key, value) {
          if (value is Map) {
            try {
              final notification = NotificationModel.fromJson(
                Map<String, dynamic>.from(value),
              );
              
              if (notification.isExpired) {
                expiredIds.add(key.toString());
              }
            } catch (e) {
              log('NotificationService: Error checking expiry for notification: $e');
            }
          }
        });

        // Delete expired notifications
        for (final id in expiredIds) {
          await deleteNotification(id);
        }
        
        log('NotificationService: Cleaned up ${expiredIds.length} expired notifications');
      }
    } catch (e) {
      log('NotificationService: Error cleaning up expired notifications: $e');
    }
  }

  // Stop listening and cleanup
  Future<void> dispose() async {
    await _notificationSubscription?.cancel();
    await _notificationsController.close();
    log('NotificationService: Disposed');
  }

  // Restart listening when user changes
  Future<void> restart() async {
    await dispose();
    await initialize();
  }
}
