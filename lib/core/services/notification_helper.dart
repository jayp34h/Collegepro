import 'dart:developer';
import 'package:firebase_auth/firebase_auth.dart';
import 'onesignal_service.dart';
import 'firestore_listener_service.dart';

/// Helper class to manage notification operations across the app
class NotificationHelper {
  static final NotificationHelper _instance = NotificationHelper._internal();
  factory NotificationHelper() => _instance;
  NotificationHelper._internal();

  final OneSignalService _oneSignalService = OneSignalService();
  final FirestoreListenerService _firestoreListenerService = FirestoreListenerService();
  final FirebaseAuth _auth = FirebaseAuth.instance;

  /// Initialize all notification services
  Future<void> initialize() async {
    try {
      await _oneSignalService.initialize();
      await _firestoreListenerService.initialize();
      log('NotificationHelper: All services initialized');
    } catch (e) {
      log('NotificationHelper: Initialization error: $e');
    }
  }

  /// Send mentor reply notification to student
  Future<bool> notifyMentorReply({
    required String studentUid,
    required String mentorName,
    required String doubtTitle,
    required String doubtId,
  }) async {
    try {
      return await _oneSignalService.sendMentorReplyNotification(
        studentFirebaseUid: studentUid,
        mentorName: mentorName,
        doubtTitle: doubtTitle,
        doubtId: doubtId,
      );
    } catch (e) {
      log('NotificationHelper: Error sending mentor reply notification: $e');
      return false;
    }
  }

  /// Send new internship notification to all users
  Future<bool> notifyNewInternship({
    required String title,
    required String company,
    required String internshipId,
  }) async {
    try {
      return await _oneSignalService.sendNewInternshipNotification(
        title: title,
        company: company,
        internshipId: internshipId,
      );
    } catch (e) {
      log('NotificationHelper: Error sending internship notification: $e');
      return false;
    }
  }

  /// Send new hackathon notification to all users
  Future<bool> notifyNewHackathon({
    required String title,
    required String organizer,
    required String hackathonId,
  }) async {
    try {
      return await _oneSignalService.sendNewHackathonNotification(
        title: title,
        organizer: organizer,
        hackathonId: hackathonId,
      );
    } catch (e) {
      log('NotificationHelper: Error sending hackathon notification: $e');
      return false;
    }
  }

  /// Send new scholarship notification to all users
  Future<bool> notifyNewScholarship({
    required String title,
    required String provider,
    required String scholarshipId,
  }) async {
    try {
      return await _oneSignalService.sendNewScholarshipNotification(
        title: title,
        provider: provider,
        scholarshipId: scholarshipId,
      );
    } catch (e) {
      log('NotificationHelper: Error sending scholarship notification: $e');
      return false;
    }
  }

  /// Send custom notification to specific user
  Future<bool> sendCustomNotification({
    required String firebaseUid,
    required String title,
    required String message,
    Map<String, dynamic>? data,
    String? actionUrl,
  }) async {
    try {
      return await _oneSignalService.sendNotificationToUser(
        firebaseUid: firebaseUid,
        title: title,
        message: message,
        data: data,
        actionUrl: actionUrl,
      );
    } catch (e) {
      log('NotificationHelper: Error sending custom notification: $e');
      return false;
    }
  }

  /// Send broadcast notification to all users
  Future<bool> sendBroadcastNotification({
    required String title,
    required String message,
    Map<String, dynamic>? data,
    String? actionUrl,
  }) async {
    try {
      return await _oneSignalService.sendNotificationToAll(
        title: title,
        message: message,
        data: data,
        actionUrl: actionUrl,
      );
    } catch (e) {
      log('NotificationHelper: Error sending broadcast notification: $e');
      return false;
    }
  }

  /// Test notifications (for development/debugging)
  Future<void> testNotifications() async {
    final user = _auth.currentUser;
    if (user == null) {
      log('NotificationHelper: No user logged in for testing');
      return;
    }

    log('NotificationHelper: Starting notification tests...');

    // Test mentor reply notification
    await _firestoreListenerService.triggerMentorReplyNotification(
      studentUid: user.uid,
      mentorName: 'Dr. Smith',
      doubtTitle: 'How to implement binary search?',
    );

    // Test internship notification
    await _firestoreListenerService.triggerInternshipNotification(
      title: 'Software Developer Intern',
      company: 'Google',
    );

    // Test hackathon notification
    await _firestoreListenerService.triggerHackathonNotification(
      title: 'HackTech 2024',
      organizer: 'TechCorp',
    );

    // Test scholarship notification
    await _firestoreListenerService.triggerScholarshipNotification(
      title: 'Merit Scholarship 2024',
      provider: 'Education Foundation',
    );

    log('NotificationHelper: Test notifications sent');
  }

  /// Get OneSignal player ID for current user
  String? get playerId => _oneSignalService.playerId;

  /// Check if services are initialized
  bool get isInitialized => 
      _oneSignalService.isInitialized && 
      _firestoreListenerService.isInitialized;

  /// Restart all services
  Future<void> restart() async {
    try {
      await _firestoreListenerService.restart();
      await _oneSignalService.initialize();
      log('NotificationHelper: Services restarted');
    } catch (e) {
      log('NotificationHelper: Error restarting services: $e');
    }
  }

  /// Dispose all services
  Future<void> dispose() async {
    await _firestoreListenerService.dispose();
    _oneSignalService.dispose();
    log('NotificationHelper: Services disposed');
  }
}
