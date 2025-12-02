import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/providers/notification_provider.dart';
import '../../core/providers/auth_provider.dart';

class TestNotificationsScreen extends StatelessWidget {
  const TestNotificationsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Test Notifications'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Test Real-Time Notifications',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 16),
            Text(
              'Use these buttons to test different notification types:',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () => _testDoubtPostedNotification(context),
              icon: const Icon(Icons.help_outline),
              label: const Text('Test Doubt Posted'),
            ),
            const SizedBox(height: 12),
            ElevatedButton.icon(
              onPressed: () => _testDoubtAnsweredNotification(context),
              icon: const Icon(Icons.lightbulb_outline),
              label: const Text('Test Doubt Answered'),
            ),
            const SizedBox(height: 12),
            ElevatedButton.icon(
              onPressed: () => _testFeedbackReceivedNotification(context),
              icon: const Icon(Icons.feedback_outlined),
              label: const Text('Test Feedback Received'),
            ),
            const SizedBox(height: 12),
            ElevatedButton.icon(
              onPressed: () => _testFeedbackReplyNotification(context),
              icon: const Icon(Icons.reply_outlined),
              label: const Text('Test Feedback Reply'),
            ),
            const SizedBox(height: 32),
            const Divider(),
            const SizedBox(height: 16),
            Consumer<NotificationProvider>(
              builder: (context, notificationProvider, child) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Notification Stats:',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 8),
                    Text('Total: ${notificationProvider.notifications.length}'),
                    Text('Unread: ${notificationProvider.unreadCount}'),
                    const SizedBox(height: 16),
                    if (notificationProvider.notifications.isNotEmpty)
                      ElevatedButton(
                        onPressed: () => notificationProvider.clearAllNotifications(),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red,
                          foregroundColor: Colors.white,
                        ),
                        child: const Text('Clear All Notifications'),
                      ),
                  ],
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  void _testDoubtPostedNotification(BuildContext context) {
    final notificationProvider = context.read<NotificationProvider>();
    final authProvider = context.read<AuthProvider>();
    
    if (authProvider.user == null) {
      _showLoginRequiredDialog(context);
      return;
    }

    notificationProvider.sendDoubtPostedNotification(
      doubtId: 'test_doubt_${DateTime.now().millisecondsSinceEpoch}',
      doubtTitle: 'How to implement Firebase real-time notifications?',
      authorId: 'test_author_123',
      authorName: 'John Doe',
      interestedUsers: [authProvider.user!.uid],
    );

    _showSuccessSnackBar(context, 'Doubt posted notification sent!');
  }

  void _testDoubtAnsweredNotification(BuildContext context) {
    final notificationProvider = context.read<NotificationProvider>();
    final authProvider = context.read<AuthProvider>();
    
    if (authProvider.user == null) {
      _showLoginRequiredDialog(context);
      return;
    }

    notificationProvider.sendDoubtAnsweredNotification(
      doubtId: 'test_doubt_${DateTime.now().millisecondsSinceEpoch}',
      doubtTitle: 'How to implement Firebase real-time notifications?',
      doubtAuthorId: authProvider.user!.uid,
      answerId: 'test_answer_${DateTime.now().millisecondsSinceEpoch}',
      answererId: 'test_answerer_456',
      answererName: 'Jane Smith',
      answerPreview: 'You can use Firebase Realtime Database with StreamBuilder to implement real-time notifications...',
    );

    _showSuccessSnackBar(context, 'Doubt answered notification sent!');
  }

  void _testFeedbackReceivedNotification(BuildContext context) {
    final notificationProvider = context.read<NotificationProvider>();
    final authProvider = context.read<AuthProvider>();
    
    if (authProvider.user == null) {
      _showLoginRequiredDialog(context);
      return;
    }

    notificationProvider.sendFeedbackReceivedNotification(
      feedbackId: 'test_feedback_${DateTime.now().millisecondsSinceEpoch}',
      projectId: 'test_project_789',
      projectTitle: 'CollegePro Mobile App',
      projectAuthorId: authProvider.user!.uid,
      feedbackerId: 'test_feedbacker_101',
      feedbackerName: 'Alex Johnson',
      feedbackPreview: 'Great work on the notification system! The UI is very intuitive and user-friendly...',
      rating: 4.5,
    );

    _showSuccessSnackBar(context, 'Feedback received notification sent!');
  }

  void _testFeedbackReplyNotification(BuildContext context) {
    final notificationProvider = context.read<NotificationProvider>();
    final authProvider = context.read<AuthProvider>();
    
    if (authProvider.user == null) {
      _showLoginRequiredDialog(context);
      return;
    }

    notificationProvider.sendFeedbackReplyNotification(
      feedbackId: 'test_feedback_${DateTime.now().millisecondsSinceEpoch}',
      feedbackAuthorId: authProvider.user!.uid,
      projectId: 'test_project_789',
      projectTitle: 'CollegePro Mobile App',
      replyId: 'test_reply_${DateTime.now().millisecondsSinceEpoch}',
      replierId: 'test_replier_202',
      replierName: 'Mike Wilson',
      replyPreview: 'Thank you for the feedback! I\'ll work on improving the performance aspects you mentioned...',
    );

    _showSuccessSnackBar(context, 'Feedback reply notification sent!');
  }

  void _showLoginRequiredDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Login Required'),
        content: const Text('Please login to test notifications.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  void _showSuccessSnackBar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.green,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
}
