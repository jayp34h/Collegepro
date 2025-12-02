import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/widgets/notification_list.dart';
import '../../core/providers/notification_provider.dart';
import '../../core/models/notification_model.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 5, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Notifications'),
        bottom: TabBar(
          controller: _tabController,
          isScrollable: true,
          tabs: const [
            Tab(text: 'All'),
            Tab(text: 'Doubts'),
            Tab(text: 'Answers'),
            Tab(text: 'Feedback'),
            Tab(text: 'Replies'),
          ],
        ),
        actions: [
          Consumer<NotificationProvider>(
            builder: (context, notificationProvider, child) {
              return PopupMenuButton<String>(
                onSelected: (value) {
                  switch (value) {
                    case 'mark_all_read':
                      notificationProvider.markAllAsRead();
                      break;
                    case 'clear_all':
                      _showClearAllDialog(context, notificationProvider);
                      break;
                    case 'settings':
                      _showNotificationSettings(context, notificationProvider);
                      break;
                  }
                },
                itemBuilder: (context) => [
                  const PopupMenuItem(
                    value: 'mark_all_read',
                    child: ListTile(
                      leading: Icon(Icons.mark_email_read),
                      title: Text('Mark all as read'),
                      contentPadding: EdgeInsets.zero,
                    ),
                  ),
                  const PopupMenuItem(
                    value: 'clear_all',
                    child: ListTile(
                      leading: Icon(Icons.clear_all),
                      title: Text('Clear all'),
                      contentPadding: EdgeInsets.zero,
                    ),
                  ),
                  const PopupMenuItem(
                    value: 'settings',
                    child: ListTile(
                      leading: Icon(Icons.settings),
                      title: Text('Settings'),
                      contentPadding: EdgeInsets.zero,
                    ),
                  ),
                ],
              );
            },
          ),
        ],
      ),
      body: TabBarView(
        controller: _tabController,
        children: const [
          NotificationList(),
          NotificationList(filterType: NotificationType.doubtPosted),
          NotificationList(filterType: NotificationType.doubtAnswered),
          NotificationList(filterType: NotificationType.feedbackReceived),
          NotificationList(filterType: NotificationType.feedbackReply),
        ],
      ),
    );
  }

  void _showClearAllDialog(BuildContext context, NotificationProvider provider) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Clear All Notifications'),
        content: const Text(
          'Are you sure you want to clear all notifications? This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              provider.clearAllNotifications();
              Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text('Clear All'),
          ),
        ],
      ),
    );
  }

  void _showNotificationSettings(BuildContext context, NotificationProvider provider) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => Container(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Notification Settings',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 16),
            Consumer<NotificationProvider>(
              builder: (context, notificationProvider, child) {
                final settings = notificationProvider.settings;
                return Column(
                  children: [
                    SwitchListTile(
                      title: const Text('Doubt Posted'),
                      subtitle: const Text('Get notified when new doubts are posted'),
                      value: settings.doubtPosted,
                      onChanged: (value) {
                        notificationProvider.updateSettings(
                          settings.copyWith(doubtPosted: value),
                        );
                      },
                    ),
                    SwitchListTile(
                      title: const Text('Doubt Answered'),
                      subtitle: const Text('Get notified when your doubts are answered'),
                      value: settings.doubtAnswered,
                      onChanged: (value) {
                        notificationProvider.updateSettings(
                          settings.copyWith(doubtAnswered: value),
                        );
                      },
                    ),
                    SwitchListTile(
                      title: const Text('Feedback Received'),
                      subtitle: const Text('Get notified when you receive feedback'),
                      value: settings.feedbackReceived,
                      onChanged: (value) {
                        notificationProvider.updateSettings(
                          settings.copyWith(feedbackReceived: value),
                        );
                      },
                    ),
                    SwitchListTile(
                      title: const Text('Feedback Replies'),
                      subtitle: const Text('Get notified when someone replies to your feedback'),
                      value: settings.feedbackReply,
                      onChanged: (value) {
                        notificationProvider.updateSettings(
                          settings.copyWith(feedbackReply: value),
                        );
                      },
                    ),
                    const Divider(),
                    SwitchListTile(
                      title: const Text('Push Notifications'),
                      subtitle: const Text('Receive push notifications on your device'),
                      value: settings.pushNotifications,
                      onChanged: (value) {
                        notificationProvider.updateSettings(
                          settings.copyWith(pushNotifications: value),
                        );
                      },
                    ),
                    SwitchListTile(
                      title: const Text('Email Notifications'),
                      subtitle: const Text('Receive notifications via email'),
                      value: settings.emailNotifications,
                      onChanged: (value) {
                        notificationProvider.updateSettings(
                          settings.copyWith(emailNotifications: value),
                        );
                      },
                    ),
                  ],
                );
              },
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Done'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
