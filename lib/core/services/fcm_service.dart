import 'dart:async';
import 'dart:convert';
import 'dart:developer';
import 'dart:io';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:permission_handler/permission_handler.dart';

// Top-level function for background message handling
@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  log('FCMService: Handling background message: ${message.messageId}');
  
  // Handle background notification here if needed
  // This runs when app is terminated or in background
}

class FCMService {
  static final FCMService _instance = FCMService._internal();
  factory FCMService() => _instance;
  FCMService._internal();

  final FirebaseMessaging _messaging = FirebaseMessaging.instance;
  final FlutterLocalNotificationsPlugin _localNotifications = 
      FlutterLocalNotificationsPlugin();
  final FirebaseDatabase _database = FirebaseDatabase.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  String? _fcmToken;
  StreamSubscription<String>? _tokenSubscription;

  // Initialize FCM service
  Future<void> initialize() async {
    try {
      // Request notification permissions
      await _requestPermissions();
      
      // Initialize local notifications
      await _initializeLocalNotifications();
      
      // Get and store FCM token
      await _initializeFCMToken();
      
      // Set up message handlers
      _setupMessageHandlers();
      
      log('FCMService: Initialized successfully');
    } catch (e) {
      log('FCMService: Error during initialization: $e');
    }
  }

  // Request notification permissions
  Future<void> _requestPermissions() async {
    try {
      // For Android 13+ (API level 33+), we need to request POST_NOTIFICATIONS permission
      if (Platform.isAndroid) {
        final androidInfo = await _getAndroidVersion();
        
        if (androidInfo >= 33) {
          // Request Android notification permission first
          final status = await Permission.notification.request();
          log('FCMService: Android notification permission status: $status');
          
          if (status.isDenied || status.isPermanentlyDenied) {
            log('FCMService: ⚠️ Android notification permission denied');
            // Show dialog to user explaining why notifications are important
            await _showPermissionDialog();
            return;
          }
        }
      }
      
      // Request Firebase messaging permissions
      final settings = await _messaging.requestPermission(
        alert: true,
        announcement: false,
        badge: true,
        carPlay: false,
        criticalAlert: false,
        provisional: false,
        sound: true,
      );

      log('FCMService: Firebase permission status: ${settings.authorizationStatus}');
      
      // Check if permissions are granted
      if (settings.authorizationStatus == AuthorizationStatus.denied) {
        log('FCMService: ⚠️ Firebase notification permission denied');
        await _showPermissionDialog();
      } else if (settings.authorizationStatus == AuthorizationStatus.authorized) {
        log('FCMService: ✅ All notification permissions granted');
      }
    } catch (e) {
      log('FCMService: Error requesting permissions: $e');
    }
  }

  // Initialize local notifications
  Future<void> _initializeLocalNotifications() async {
    const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosSettings = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    const initSettings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    await _localNotifications.initialize(
      initSettings,
      onDidReceiveNotificationResponse: _onNotificationTapped,
    );

    // Create notification channels for Android
    await _createNotificationChannels();
  }

  // Create notification channels for different types
  Future<void> _createNotificationChannels() async {
    const channels = [
      AndroidNotificationChannel(
        'doubt_notifications',
        'Doubt Notifications',
        description: 'Notifications for doubt-related activities',
        importance: Importance.high,
        sound: RawResourceAndroidNotificationSound('notification'),
      ),
      AndroidNotificationChannel(
        'feedback_notifications',
        'Feedback Notifications',
        description: 'Notifications for feedback-related activities',
        importance: Importance.high,
        sound: RawResourceAndroidNotificationSound('notification'),
      ),
      AndroidNotificationChannel(
        'general_notifications',
        'General Notifications',
        description: 'General app notifications',
        importance: Importance.defaultImportance,
      ),
    ];

    for (final channel in channels) {
      await _localNotifications
          .resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin>()
          ?.createNotificationChannel(channel);
    }
  }

  // Initialize FCM token
  Future<void> _initializeFCMToken() async {
    try {
      _fcmToken = await _messaging.getToken();
      log('FCMService: FCM Token: $_fcmToken');

      // Store token in database for current user
      await _storeFCMToken();

      // Listen for token refresh
      _tokenSubscription = _messaging.onTokenRefresh.listen((token) {
        _fcmToken = token;
        _storeFCMToken();
        log('FCMService: Token refreshed: $token');
      });
    } catch (e) {
      log('FCMService: Error getting FCM token: $e');
    }
  }

  // Store FCM token in database
  Future<void> _storeFCMToken() async {
    try {
      final user = _auth.currentUser;
      if (user != null && _fcmToken != null) {
        await _database
            .ref('user_fcm_tokens')
            .child(user.uid)
            .set({
          'token': _fcmToken,
          'updatedAt': ServerValue.timestamp,
          'platform': 'android', // You can detect platform dynamically
        }).timeout(
          const Duration(seconds: 10),
          onTimeout: () {
            log('⏰ FCM token storage timeout');
            throw Exception('Token storage timeout');
          },
        );
        
        log('✅ FCMService: Token stored for user ${user.uid}');
      }
    } catch (e) {
      log('❌ FCMService: Error storing FCM token: $e');
      
      if (e.toString().contains('permission') || e.toString().contains('PERMISSION_DENIED')) {
        log('🔒 Permission denied for FCM token storage');
      }
    }
  }

  // Setup message handlers
  void _setupMessageHandlers() {
    // Handle foreground messages
    FirebaseMessaging.onMessage.listen(_handleForegroundMessage);
    
    // Handle notification taps when app is in background
    FirebaseMessaging.onMessageOpenedApp.listen(_handleNotificationTap);
    
    // Handle notification tap when app is terminated
    _messaging.getInitialMessage().then((message) {
      if (message != null) {
        _handleNotificationTap(message);
      }
    });
  }

  // Handle foreground messages
  Future<void> _handleForegroundMessage(RemoteMessage message) async {
    log('FCMService: Foreground message received: ${message.messageId}');
    
    // Show local notification when app is in foreground
    await _showLocalNotification(message);
  }

  // Handle notification tap
  Future<void> _handleNotificationTap(RemoteMessage message) async {
    log('FCMService: Notification tapped: ${message.messageId}');
    
    // Handle navigation based on notification data
    final data = message.data;
    if (data.containsKey('actionUrl')) {
      // Navigate to specific screen
      // You can implement navigation logic here
      log('FCMService: Navigate to: ${data['actionUrl']}');
    }
  }

  // Handle local notification tap
  void _onNotificationTapped(NotificationResponse response) {
    log('FCMService: Local notification tapped: ${response.payload}');
    
    if (response.payload != null) {
      try {
        final data = jsonDecode(response.payload!);
        if (data['actionUrl'] != null) {
          // Navigate to specific screen
          log('FCMService: Navigate to: ${data['actionUrl']}');
        }
      } catch (e) {
        log('FCMService: Error parsing notification payload: $e');
      }
    }
  }

  // Show local notification
  Future<void> _showLocalNotification(RemoteMessage message) async {
    try {
      final notification = message.notification;
      if (notification == null) return;

      final channelId = _getChannelId(message.data);
      final notificationId = DateTime.now().millisecondsSinceEpoch ~/ 1000;

      final androidDetails = AndroidNotificationDetails(
        channelId,
        _getChannelName(channelId),
        channelDescription: _getChannelDescription(channelId),
        importance: Importance.high,
        priority: Priority.high,
        showWhen: true,
        icon: '@mipmap/ic_launcher',
      );

      const iosDetails = DarwinNotificationDetails(
        presentAlert: true,
        presentBadge: true,
        presentSound: true,
      );

      final details = NotificationDetails(
        android: androidDetails,
        iOS: iosDetails,
      );

      await _localNotifications.show(
        notificationId,
        notification.title,
        notification.body,
        details,
        payload: jsonEncode(message.data),
      );

      log('FCMService: Local notification shown');
    } catch (e) {
      log('FCMService: Error showing local notification: $e');
    }
  }

  // Get appropriate channel ID based on notification type
  String _getChannelId(Map<String, dynamic> data) {
    final type = data['type'] as String?;
    
    switch (type) {
      case 'doubt_posted':
      case 'doubt_answered':
        return 'doubt_notifications';
      case 'feedback_received':
      case 'feedback_reply':
        return 'feedback_notifications';
      default:
        return 'general_notifications';
    }
  }

  // Get channel name based on channel ID
  String _getChannelName(String channelId) {
    switch (channelId) {
      case 'doubt_notifications':
        return 'Doubt Notifications';
      case 'feedback_notifications':
        return 'Feedback Notifications';
      default:
        return 'General Notifications';
    }
  }

  // Get channel description based on channel ID
  String _getChannelDescription(String channelId) {
    switch (channelId) {
      case 'doubt_notifications':
        return 'Notifications for doubt-related activities';
      case 'feedback_notifications':
        return 'Notifications for feedback-related activities';
      default:
        return 'General app notifications';
    }
  }

  // Send push notification to specific user
  Future<bool> sendPushNotification({
    required String recipientId,
    required String title,
    required String body,
    required Map<String, dynamic> data,
  }) async {
    try {
      // Get recipient's FCM token
      final tokenSnapshot = await _database
          .ref('user_fcm_tokens')
          .child(recipientId)
          .get();

      if (!tokenSnapshot.exists) {
        log('FCMService: No FCM token found for user $recipientId');
        return false;
      }

      final tokenData = tokenSnapshot.value as Map<dynamic, dynamic>;
      final token = tokenData['token'] as String;

      // Create FCM message
      final message = {
        'to': token,
        'notification': {
          'title': title,
          'body': body,
          'sound': 'default',
        },
        'data': data,
        'android': {
          'notification': {
            'icon': '@mipmap/ic_launcher',
            'color': '#7C3AED',
            'channel_id': _getChannelId(data),
          },
        },
        'apns': {
          'payload': {
            'aps': {
              'badge': 1,
              'sound': 'default',
            },
          },
        },
      };

      // Note: In production, you would send this via your backend server
      // using Firebase Admin SDK or FCM HTTP v1 API
      // For now, we'll log the message structure
      log('FCMService: Push notification prepared for $recipientId');
      log('FCMService: Message: ${jsonEncode(message)}');
      
      return true;
    } catch (e) {
      log('FCMService: Error sending push notification: $e');
      return false;
    }
  }

  // Send notification for doubt posted
  Future<bool> sendDoubtPostedPush({
    required List<String> recipientIds,
    required String doubtTitle,
    required String authorName,
    required String doubtId,
  }) async {
    try {
      final futures = recipientIds.map((recipientId) => 
        sendPushNotification(
          recipientId: recipientId,
          title: '🤔 New Doubt Posted',
          body: '$authorName posted: "$doubtTitle"',
          data: {
            'type': 'doubt_posted',
            'doubtId': doubtId,
            'actionUrl': '/community-doubts/details/$doubtId',
          },
        ),
      );

      final results = await Future.wait(futures);
      final successCount = results.where((result) => result).length;
      
      log('FCMService: Sent doubt push notifications to $successCount users');
      return successCount > 0;
    } catch (e) {
      log('FCMService: Error sending doubt posted push notifications: $e');
      return false;
    }
  }

  // Send notification for doubt answered
  Future<bool> sendDoubtAnsweredPush({
    required String recipientId,
    required String doubtTitle,
    required String answererName,
    required String doubtId,
    required String answerId,
  }) async {
    return await sendPushNotification(
      recipientId: recipientId,
      title: '💡 Your Doubt Got Answered!',
      body: '$answererName answered: "$doubtTitle"',
      data: {
        'type': 'doubt_answered',
        'doubtId': doubtId,
        'answerId': answerId,
        'actionUrl': '/community-doubts/details/$doubtId#answer-$answerId',
      },
    );
  }

  // Send notification for feedback received
  Future<bool> sendFeedbackReceivedPush({
    required String recipientId,
    required String projectTitle,
    required String feedbackerName,
    required double rating,
    required String projectId,
    required String feedbackId,
  }) async {
    return await sendPushNotification(
      recipientId: recipientId,
      title: '⭐ New Feedback on Your Project!',
      body: '$feedbackerName gave ${rating.toStringAsFixed(1)} stars on "$projectTitle"',
      data: {
        'type': 'feedback_received',
        'projectId': projectId,
        'feedbackId': feedbackId,
        'actionUrl': '/project-details/$projectId#feedback-$feedbackId',
      },
    );
  }

  // Send notification for feedback reply
  Future<bool> sendFeedbackReplyPush({
    required String recipientId,
    required String projectTitle,
    required String replierName,
    required String projectId,
    required String feedbackId,
    required String replyId,
  }) async {
    return await sendPushNotification(
      recipientId: recipientId,
      title: '💬 Reply to Your Feedback!',
      body: '$replierName replied to your feedback on "$projectTitle"',
      data: {
        'type': 'feedback_reply',
        'projectId': projectId,
        'feedbackId': feedbackId,
        'replyId': replyId,
        'actionUrl': '/project-details/$projectId#feedback-$feedbackId-reply-$replyId',
      },
    );
  }

  // Get Android SDK version
  Future<int> _getAndroidVersion() async {
    try {
      if (Platform.isAndroid) {
        final deviceInfo = await _getDeviceInfo();
        return deviceInfo['sdkInt'] ?? 0;
      }
      return 0;
    } catch (e) {
      log('FCMService: Error getting Android version: $e');
      return 0;
    }
  }
  
  // Get device info (simplified version)
  Future<Map<String, dynamic>> _getDeviceInfo() async {
    // This is a simplified implementation
    // In a real app, you might want to use device_info_plus package
    return {'sdkInt': 33}; // Assume Android 13+ for safety
  }
  
  // Show permission dialog to educate user
  Future<void> _showPermissionDialog() async {
    log('FCMService: 📱 User should be shown permission explanation dialog');
    // Note: In a real implementation, you would show a dialog here
    // explaining why notifications are important for the educational app
  }
  
  // Check if notifications are enabled
  Future<bool> areNotificationsEnabled() async {
    try {
      if (Platform.isAndroid) {
        final androidInfo = await _getAndroidVersion();
        
        if (androidInfo >= 33) {
          final status = await Permission.notification.status;
          if (!status.isGranted) {
            return false;
          }
        }
      }
      
      // Check Firebase messaging settings
      final settings = await _messaging.getNotificationSettings();
      return settings.authorizationStatus == AuthorizationStatus.authorized;
    } catch (e) {
      log('FCMService: Error checking notification status: $e');
      return false;
    }
  }
  
  // Request permissions again (for settings screen)
  Future<bool> requestPermissionsAgain() async {
    try {
      await _requestPermissions();
      return await areNotificationsEnabled();
    } catch (e) {
      log('FCMService: Error requesting permissions again: $e');
      return false;
    }
  }

  // Get current FCM token
  String? get fcmToken => _fcmToken;

  // Dispose resources
  Future<void> dispose() async {
    await _tokenSubscription?.cancel();
    log('FCMService: Disposed');
  }
}
