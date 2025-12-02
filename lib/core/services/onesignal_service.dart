import 'dart:convert';
import 'dart:developer';
import 'package:http/http.dart' as http;
import 'package:onesignal_flutter/onesignal_flutter.dart';
import 'package:firebase_auth/firebase_auth.dart';

class OneSignalService {
  static final OneSignalService _instance = OneSignalService._internal();
  factory OneSignalService() => _instance;
  OneSignalService._internal();

  // OneSignal Configuration
  static const String _appId = 'aed12992-90e1-43f5-9e37-c74e256e7b29';
  static const String _restApiKey = 'manwvd3ulujtfsj5yplcipbuo'; // Replace with your actual REST API key
  static const String _baseUrl = 'https://onesignal.com/api/v1';

  final FirebaseAuth _auth = FirebaseAuth.instance;
  String? _playerId;
  bool _isInitialized = false;

  /// Initialize OneSignal SDK (lightweight, no permission request)
  Future<void> initialize() async {
    try {
      if (_isInitialized) return;

      log('OneSignalService: Starting lightweight initialization...');
      
      // Initialize OneSignal with minimal logging for faster startup
      OneSignal.Debug.setLogLevel(OSLogLevel.warn);
      OneSignal.initialize(_appId);
      log('OneSignalService: OneSignal.initialize() called');

      // Set up notification handlers
      _setupNotificationHandlers();

      // Don't request permission or get player ID during startup
      // This will be done later when user actually needs notifications
      
      _isInitialized = true;
      log('OneSignalService: ✅ Lightweight initialization completed');
      
    } catch (e) {
      log('OneSignalService: ❌ Initialization error: $e');
    }
  }

  /// Full initialization with permission request (called when needed)
  Future<void> initializeWithPermission() async {
    try {
      if (!_isInitialized) {
        await initialize();
      }

      log('OneSignalService: Starting full initialization with permission...');

      // Request notification permission
      final permissionGranted = await OneSignal.Notifications.requestPermission(true);
      log('OneSignalService: Permission granted: $permissionGranted');

      if (permissionGranted) {
        // Get player ID only if permission granted
        await _getPlayerId();

        // Tag user with Firebase UID for targeting
        final user = _auth.currentUser;
        if (user != null) {
          await tagUser(user.uid);
        }

        log('OneSignalService: ✅ Full initialization completed - Player ID: $_playerId');
      } else {
        log('OneSignalService: Permission denied - notifications disabled');
      }
      
    } catch (e) {
      log('OneSignalService: ❌ Full initialization error: $e');
    }
  }

  /// Set up notification event handlers
  void _setupNotificationHandlers() {
    // Handle notification received while app is in foreground
    OneSignal.Notifications.addForegroundWillDisplayListener((event) {
      log('OneSignalService: Notification received in foreground: ${event.notification.title}');
      // Allow notification to display in foreground
      // Remove preventDefault() to show notifications
      event.notification.display();
    });

    // Handle notification clicked
    OneSignal.Notifications.addClickListener((event) {
      log('OneSignalService: Notification clicked: ${event.notification.title}');
      _handleNotificationClick(event.notification);
    });

    // Handle permission changes
    OneSignal.Notifications.addPermissionObserver((state) {
      log('OneSignalService: Permission state changed: $state');
    });

    // Handle subscription changes
    OneSignal.User.pushSubscription.addObserver((state) {
      log('OneSignalService: Subscription state changed: ${state.current.id}');
      _playerId = state.current.id;
    });
  }

  /// Get OneSignal Player ID with retry logic
  Future<void> _getPlayerId() async {
    try {
      int retryCount = 0;
      const maxRetries = 10;
      const retryDelay = Duration(seconds: 2);

      while (retryCount < maxRetries) {
        await Future.delayed(retryDelay);
        
        try {
          final subscription = OneSignal.User.pushSubscription;
          log('OneSignalService: Checking subscription - ID: ${subscription.id}, Token: ${subscription.token}');
          
          if (subscription.id != null && subscription.id!.isNotEmpty) {
            _playerId = subscription.id;
            log('OneSignalService: Player ID obtained: $_playerId (attempt ${retryCount + 1})');
            return;
          }
          
          // Also check OneSignal User state
          log('OneSignalService: OneSignal User state check completed');
          
        } catch (subscriptionError) {
          log('OneSignalService: Subscription check error: $subscriptionError');
        }
        
        retryCount++;
        log('OneSignalService: Player ID not available, retry $retryCount/$maxRetries');
      }
      
      log('OneSignalService: Failed to get Player ID after $maxRetries attempts');
      _playerId = null;
    } catch (e) {
      log('OneSignalService: Error getting player ID: $e');
      _playerId = null;
    }
  }


  /// Tag user with Firebase UID for targeting
  Future<void> tagUser(String userId) async {
    try {
      await OneSignal.User.addTagWithKey('firebase_uid', userId);
      await OneSignal.User.addTagWithKey('user_type', 'student');
      log('OneSignalService: Tagged user: $userId');
    } catch (e) {
      log('OneSignalService: Error tagging user: $e');
    }
  }

  /// Handle notification click and navigation
  void _handleNotificationClick(OSNotification notification) {
    final additionalData = notification.additionalData;
    if (additionalData != null) {
      final type = additionalData['type'] as String?;
      final actionUrl = additionalData['actionUrl'] as String?;

      switch (type) {
        case 'mentor_reply':
          _navigateToDoubtDetails(additionalData['doubtId'] as String?);
          break;
        case 'new_internship':
          _navigateToInternships();
          break;
        case 'new_hackathon':
          _navigateToHackathons();
          break;
        case 'new_scholarship':
          _navigateToScholarships();
          break;
        default:
          if (actionUrl != null) {
            _navigateToUrl(actionUrl);
          }
      }
    }
  }

  /// Navigation helpers
  void _navigateToDoubtDetails(String? doubtId) {
    if (doubtId != null) {
      // Navigate to doubt details screen
      log('OneSignalService: Navigate to doubt: $doubtId');
      // Implement navigation logic here
    }
  }

  void _navigateToInternships() {
    log('OneSignalService: Navigate to internships');
    // Implement navigation to internships screen
  }

  void _navigateToHackathons() {
    log('OneSignalService: Navigate to hackathons');
    // Implement navigation to hackathons screen
  }

  void _navigateToScholarships() {
    log('OneSignalService: Navigate to scholarships');
    // Implement navigation to scholarships screen
  }

  void _navigateToUrl(String url) {
    log('OneSignalService: Navigate to URL: $url');
    // Implement URL navigation logic
  }

  /// Send notification to specific user by Firebase UID
  Future<bool> sendNotificationToUser({
    required String firebaseUid,
    required String title,
    required String message,
    Map<String, dynamic>? data,
    String? actionUrl,
  }) async {
    try {
      // Check if OneSignal is properly initialized
      if (!_isInitialized) {
        log('OneSignalService: Not initialized, cannot send notification');
        return false;
      }

      final payload = {
        'app_id': _appId,
        'filters': [
          {
            'field': 'tag',
            'key': 'firebase_uid',
            'relation': '=',
            'value': firebaseUid,
          }
        ],
        'headings': {'en': title},
        'contents': {'en': message},
        'data': {
          ...?data,
          if (actionUrl != null) 'actionUrl': actionUrl,
        },
        'android_channel_id': 'default',
        'priority': 10,
        'ttl': 86400, // 24 hours
        'android_accent_color': 'FF6C5CE7',
        'android_visibility': 1,
        'content_available': true,
      };

      final response = await http.post(
        Uri.parse('$_baseUrl/notifications'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Basic $_restApiKey',
        },
        body: jsonEncode(payload),
      );

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        log('OneSignalService: Notification sent successfully: ${responseData['id']}');
        return true;
      } else {
        log('OneSignalService: Failed to send notification: ${response.statusCode} - ${response.body}');
        return false;
      }
    } catch (e) {
      log('OneSignalService: Error sending notification: $e');
      return false;
    }
  }

  /// Send notification to all users
  Future<bool> sendNotificationToAll({
    required String title,
    required String message,
    Map<String, dynamic>? data,
    String? actionUrl,
  }) async {
    try {
      // Check if OneSignal is properly initialized
      if (!_isInitialized) {
        log('OneSignalService: Not initialized, cannot send broadcast notification');
        return false;
      }

      final payload = {
        'app_id': _appId,
        'included_segments': ['All'],
        'headings': {'en': title},
        'contents': {'en': message},
        'data': {
          ...?data,
          if (actionUrl != null) 'actionUrl': actionUrl,
        },
        'android_channel_id': 'default',
        'priority': 10,
        'ttl': 86400, // 24 hours
        'android_accent_color': 'FF6C5CE7',
        'android_visibility': 1,
        'content_available': true,
      };

      final response = await http.post(
        Uri.parse('$_baseUrl/notifications'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Basic $_restApiKey',
        },
        body: jsonEncode(payload),
      );

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        log('OneSignalService: Broadcast notification sent: ${responseData['id']}');
        return true;
      } else {
        log('OneSignalService: Failed to send broadcast notification: ${response.statusCode} - ${response.body}');
        return false;
      }
    } catch (e) {
      log('OneSignalService: Error sending broadcast notification: $e');
      return false;
    }
  }

  /// Send mentor reply notification
  Future<bool> sendMentorReplyNotification({
    required String studentFirebaseUid,
    required String mentorName,
    required String doubtTitle,
    required String doubtId,
  }) async {
    return await sendNotificationToUser(
      firebaseUid: studentFirebaseUid,
      title: '🎓 Mentor Reply',
      message: '$mentorName replied to your doubt: "$doubtTitle"',
      data: {
        'type': 'mentor_reply',
        'doubtId': doubtId,
        'mentorName': mentorName,
      },
      actionUrl: '/mentor/doubts/$doubtId',
    );
  }

  /// Send new internship notification
  Future<bool> sendNewInternshipNotification({
    required String title,
    required String company,
    required String internshipId,
  }) async {
    return await sendNotificationToAll(
      title: '💼 New Internship Available!',
      message: '$company is offering: $title',
      data: {
        'type': 'new_internship',
        'internshipId': internshipId,
        'company': company,
      },
      actionUrl: '/internships/$internshipId',
    );
  }

  /// Send new hackathon notification
  Future<bool> sendNewHackathonNotification({
    required String title,
    required String organizer,
    required String hackathonId,
  }) async {
    return await sendNotificationToAll(
      title: '🏆 New Hackathon Alert!',
      message: '$organizer presents: $title',
      data: {
        'type': 'new_hackathon',
        'hackathonId': hackathonId,
        'organizer': organizer,
      },
      actionUrl: '/hackathons/$hackathonId',
    );
  }

  /// Send new scholarship notification
  Future<bool> sendNewScholarshipNotification({
    required String title,
    required String provider,
    required String scholarshipId,
  }) async {
    return await sendNotificationToAll(
      title: '🎓 New Scholarship Opportunity!',
      message: '$provider offers: $title',
      data: {
        'type': 'new_scholarship',
        'scholarshipId': scholarshipId,
        'provider': provider,
      },
      actionUrl: '/scholarships/$scholarshipId',
    );
  }

  /// Get current player ID
  String? get playerId => _playerId;

  /// Check if OneSignal is initialized
  bool get isInitialized => _isInitialized;

  /// Test notification functionality
  Future<bool> sendTestNotification() async {
    try {
      log('OneSignalService: Sending test notification...');
      
      final result = await sendNotificationToAll(
        title: '🧪 Test Notification',
        message: 'This is a test notification from CollegePro app!',
        data: {
          'type': 'test',
          'timestamp': DateTime.now().millisecondsSinceEpoch.toString(),
        },
      );
      
      log('OneSignalService: Test notification result: $result');
      return result;
    } catch (e) {
      log('OneSignalService: Test notification error: $e');
      return false;
    }
  }

  /// Check notification permission status
  Future<bool> checkPermissionStatus() async {
    try {
      final permission = await OneSignal.Notifications.permission;
      log('OneSignalService: Permission status: $permission');
      return permission;
    } catch (e) {
      log('OneSignalService: Error checking permission: $e');
      return false;
    }
  }

  /// Get detailed OneSignal status for debugging
  Future<Map<String, dynamic>> getDebugStatus() async {
    try {
      final permission = await checkPermissionStatus();
      final subscription = OneSignal.User.pushSubscription;
      
      final status = {
        'isInitialized': _isInitialized,
        'playerId': _playerId,
        'hasPermission': permission,
        'subscriptionId': subscription.id,
        'subscriptionToken': subscription.token,
        'appId': _appId,
        'currentUser': _auth.currentUser?.uid,
      };
      
      log('OneSignalService: Debug status: $status');
      return status;
    } catch (e) {
      log('OneSignalService: Error getting debug status: $e');
      return {'error': e.toString()};
    }
  }

  /// Dispose resources
  void dispose() {
    log('OneSignalService: Disposed');
  }
}
