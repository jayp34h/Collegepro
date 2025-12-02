import 'dart:async';
import 'dart:developer';
import 'package:flutter/material.dart';
import '../models/notification_model.dart';
import '../services/notification_service.dart';

class NotificationProvider extends ChangeNotifier {
  final NotificationService _notificationService = NotificationService();
  
  List<NotificationModel> _notifications = [];
  bool _isLoading = false;
  String? _error;
  StreamSubscription<List<NotificationModel>>? _notificationSubscription;
  NotificationSettings _settings = NotificationSettings();

  // Getters
  List<NotificationModel> get notifications => _notifications;
  List<NotificationModel> get unreadNotifications => 
      _notifications.where((n) => !n.isRead).toList();
  int get unreadCount => unreadNotifications.length;
  bool get isLoading => _isLoading;
  String? get error => _error;
  NotificationSettings get settings => _settings;
  bool get hasUnread => unreadCount > 0;

  // Filtered notifications by type
  List<NotificationModel> get doubtNotifications => 
      _notifications.where((n) => 
          n.type == NotificationType.doubtPosted || 
          n.type == NotificationType.doubtAnswered).toList();
  
  List<NotificationModel> get feedbackNotifications => 
      _notifications.where((n) => 
          n.type == NotificationType.feedbackReceived || 
          n.type == NotificationType.feedbackReply).toList();

  List<NotificationModel> get mentorNotifications => 
      _notifications.where((n) => 
          n.type == NotificationType.mentorResponse).toList();

  // Initialize provider
  Future<void> initialize() async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      await _notificationService.initialize();
      await _startListening();
      await _loadSettings();
      
      log('NotificationProvider: Initialized successfully');
    } catch (e) {
      _error = 'Failed to initialize notifications: $e';
      log('NotificationProvider: Initialization error: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Start listening to notification stream
  Future<void> _startListening() async {
    try {
      _notificationSubscription?.cancel();
      
      _notificationSubscription = _notificationService.notificationsStream.listen(
        (notifications) {
          _notifications = notifications;
          _error = null;
          notifyListeners();
          
          // Show local notification for new unread notifications
          _handleNewNotifications(notifications);
        },
        onError: (error) {
          _error = 'Error receiving notifications: $error';
          log('NotificationProvider: Stream error: $error');
          notifyListeners();
        },
      );
    } catch (e) {
      _error = 'Failed to start listening: $e';
      log('NotificationProvider: Listen error: $e');
    }
  }

  // Handle new notifications (show local notifications, play sounds, etc.)
  void _handleNewNotifications(List<NotificationModel> notifications) {
    final newUnreadNotifications = notifications
        .where((n) => !n.isRead && !n.isDelivered)
        .toList();

    for (final notification in newUnreadNotifications) {
      _showLocalNotification(notification);
    }
  }

  // Show local notification (you can integrate with flutter_local_notifications)
  void _showLocalNotification(NotificationModel notification) {
    // For now, just log. You can integrate flutter_local_notifications here
    log('NotificationProvider: New notification - ${notification.title}: ${notification.message}');
    
    // Mark as delivered
    _notificationService.sendNotification(
      notification.copyWith(isDelivered: true),
    );
  }

  // Send doubt posted notification
  Future<bool> sendDoubtPostedNotification({
    required String doubtId,
    required String doubtTitle,
    required String authorId,
    required String authorName,
    required List<String> interestedUsers,
  }) async {
    try {
      if (!_settings.doubtNotifications) return false;

      return await _notificationService.sendDoubtPostedNotification(
        doubtId: doubtId,
        doubtTitle: doubtTitle,
        authorId: authorId,
        authorName: authorName,
        interestedUsers: interestedUsers,
      );
    } catch (e) {
      log('NotificationProvider: Error sending doubt notification: $e');
      return false;
    }
  }

  // Send doubt answered notification
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
      if (!_settings.doubtNotifications) return false;

      return await _notificationService.sendDoubtAnsweredNotification(
        doubtId: doubtId,
        doubtTitle: doubtTitle,
        doubtAuthorId: doubtAuthorId,
        answerId: answerId,
        answererId: answererId,
        answererName: answererName,
        answerPreview: answerPreview,
      );
    } catch (e) {
      log('NotificationProvider: Error sending doubt answered notification: $e');
      return false;
    }
  }

  // Send feedback received notification
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
      if (!_settings.feedbackNotifications) return false;

      return await _notificationService.sendFeedbackReceivedNotification(
        projectId: projectId,
        projectTitle: projectTitle,
        projectAuthorId: projectAuthorId,
        feedbackId: feedbackId,
        feedbackerId: feedbackerId,
        feedbackerName: feedbackerName,
        rating: rating,
        feedbackPreview: feedbackPreview,
      );
    } catch (e) {
      log('NotificationProvider: Error sending feedback notification: $e');
      return false;
    }
  }

  // Send feedback reply notification
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
      if (!_settings.feedbackNotifications) return false;

      return await _notificationService.sendFeedbackReplyNotification(
        projectId: projectId,
        projectTitle: projectTitle,
        feedbackId: feedbackId,
        feedbackAuthorId: feedbackAuthorId,
        replyId: replyId,
        replierId: replierId,
        replierName: replierName,
        replyPreview: replyPreview,
      );
    } catch (e) {
      log('NotificationProvider: Error sending feedback reply notification: $e');
      return false;
    }
  }

  // Mark notification as read
  Future<bool> markAsRead(String notificationId) async {
    try {
      final success = await _notificationService.markAsRead(notificationId);
      if (success) {
        // Update local state immediately for better UX
        final index = _notifications.indexWhere((n) => n.id == notificationId);
        if (index != -1) {
          _notifications[index] = _notifications[index].copyWith(isRead: true);
          notifyListeners();
        }
      }
      return success;
    } catch (e) {
      log('NotificationProvider: Error marking notification as read: $e');
      return false;
    }
  }

  // Mark all notifications as read
  Future<bool> markAllAsRead() async {
    try {
      final success = await _notificationService.markAllAsRead();
      if (success) {
        // Update local state immediately
        _notifications = _notifications.map((n) => n.copyWith(isRead: true)).toList();
        notifyListeners();
      }
      return success;
    } catch (e) {
      log('NotificationProvider: Error marking all as read: $e');
      return false;
    }
  }

  // Delete notification
  Future<bool> deleteNotification(String notificationId) async {
    try {
      final success = await _notificationService.deleteNotification(notificationId);
      if (success) {
        // Update local state immediately
        _notifications.removeWhere((n) => n.id == notificationId);
        notifyListeners();
      }
      return success;
    } catch (e) {
      log('NotificationProvider: Error deleting notification: $e');
      return false;
    }
  }

  // Clear all notifications
  Future<bool> clearAllNotifications() async {
    try {
      final deleteResults = await Future.wait(
        _notifications.map((n) => _notificationService.deleteNotification(n.id)),
      );
      
      final success = deleteResults.every((result) => result);
      if (success) {
        _notifications.clear();
        notifyListeners();
      }
      
      return success;
    } catch (e) {
      log('NotificationProvider: Error clearing all notifications: $e');
      return false;
    }
  }

  // Load notification settings
  Future<void> _loadSettings() async {
    try {
      // Load from SharedPreferences or Firebase
      // For now, using default settings
      _settings = NotificationSettings();
      log('NotificationProvider: Settings loaded');
    } catch (e) {
      log('NotificationProvider: Error loading settings: $e');
    }
  }

  // Update notification settings
  Future<bool> updateSettings(NotificationSettings newSettings) async {
    try {
      _settings = newSettings;
      // Save to SharedPreferences or Firebase
      notifyListeners();
      log('NotificationProvider: Settings updated');
      return true;
    } catch (e) {
      log('NotificationProvider: Error updating settings: $e');
      return false;
    }
  }

  // Get notifications by type
  List<NotificationModel> getNotificationsByType(NotificationType type) {
    return _notifications.where((n) => n.type == type).toList();
  }

  // Get notifications by priority
  List<NotificationModel> getNotificationsByPriority(NotificationPriority priority) {
    return _notifications.where((n) => n.priority == priority).toList();
  }

  // Search notifications
  List<NotificationModel> searchNotifications(String query) {
    if (query.isEmpty) return _notifications;
    
    final lowerQuery = query.toLowerCase();
    return _notifications.where((n) =>
        n.title.toLowerCase().contains(lowerQuery) ||
        n.message.toLowerCase().contains(lowerQuery) ||
        n.senderName.toLowerCase().contains(lowerQuery)
    ).toList();
  }

  // Get recent notifications (last 24 hours)
  List<NotificationModel> get recentNotifications {
    final yesterday = DateTime.now().subtract(const Duration(days: 1));
    return _notifications.where((n) => n.timestamp.isAfter(yesterday)).toList();
  }

  // Get high priority notifications
  List<NotificationModel> get highPriorityNotifications {
    return _notifications.where((n) => 
        n.priority == NotificationPriority.high || 
        n.priority == NotificationPriority.urgent
    ).toList();
  }

  // Cleanup expired notifications
  Future<void> cleanupExpiredNotifications() async {
    try {
      await _notificationService.cleanupExpiredNotifications();
      log('NotificationProvider: Cleaned up expired notifications');
    } catch (e) {
      log('NotificationProvider: Error cleaning up notifications: $e');
    }
  }

  // Refresh notifications
  Future<void> refresh() async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      await _notificationService.restart();
      await _startListening();
    } catch (e) {
      _error = 'Failed to refresh notifications: $e';
      log('NotificationProvider: Refresh error: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  @override
  void dispose() {
    _notificationSubscription?.cancel();
    _notificationService.dispose();
    super.dispose();
  }
}
