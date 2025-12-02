import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:timeago/timeago.dart' as timeago;
import '../models/notification_model.dart';
import '../providers/notification_provider.dart';

class NotificationList extends StatefulWidget {
  final NotificationType? filterType;
  final bool showMarkAllAsRead;

  const NotificationList({
    super.key,
    this.filterType,
    this.showMarkAllAsRead = true,
  });

  @override
  State<NotificationList> createState() => _NotificationListState();
}

class _NotificationListState extends State<NotificationList> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<NotificationProvider>().initialize();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<NotificationProvider>(
      builder: (context, notificationProvider, child) {
        final notifications = widget.filterType != null
            ? notificationProvider.getNotificationsByType(widget.filterType!)
            : notificationProvider.notifications;

        if (notificationProvider.isLoading) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }

        if (notificationProvider.error?.isNotEmpty == true) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.error_outline,
                  size: 64,
                  color: Colors.grey[400],
                ),
                const SizedBox(height: 16),
                Text(
                  'Error loading notifications',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: Colors.grey[600],
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  notificationProvider.error ?? 'Unknown error',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Colors.grey[500],
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () => notificationProvider.initialize(),
                  child: const Text('Retry'),
                ),
              ],
            ),
          );
        }

        if (notifications.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.notifications_none,
                  size: 64,
                  color: Colors.grey[400],
                ),
                const SizedBox(height: 16),
                Text(
                  'No notifications',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: Colors.grey[600],
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'You\'ll see notifications here when there\'s activity',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Colors.grey[500],
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          );
        }

        return Column(
          children: [
            if (widget.showMarkAllAsRead && notifications.any((n) => !n.isRead))
              Container(
                padding: const EdgeInsets.all(16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '${notifications.where((n) => !n.isRead).length} unread notifications',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Colors.grey[600],
                      ),
                    ),
                    TextButton(
                      onPressed: () => notificationProvider.markAllAsRead(),
                      child: const Text('Mark all as read'),
                    ),
                  ],
                ),
              ),
            Expanded(
              child: ListView.builder(
                itemCount: notifications.length,
                itemBuilder: (context, index) {
                  final notification = notifications[index];
                  return NotificationTile(
                    notification: notification,
                    onTap: () => _handleNotificationTap(context, notification),
                    onMarkAsRead: () => notificationProvider.markAsRead(notification.id),
                    onDelete: () => notificationProvider.deleteNotification(notification.id),
                  );
                },
              ),
            ),
          ],
        );
      },
    );
  }

  void _handleNotificationTap(BuildContext context, NotificationModel notification) {
    final notificationProvider = context.read<NotificationProvider>();
    
    // Mark as read if not already read
    if (!notification.isRead) {
      notificationProvider.markAsRead(notification.id);
    }

    // Navigate based on notification type
    switch (notification.type) {
      case NotificationType.doubtPosted:
      case NotificationType.doubtAnswered:
      case NotificationType.doubtUpvoted:
        if (notification.data['doubtId'] != null) {
          Navigator.pushNamed(
            context,
            '/doubt-details',
            arguments: {'doubtId': notification.data['doubtId']},
          );
        }
        break;
      case NotificationType.feedbackReceived:
      case NotificationType.feedbackReply:
      case NotificationType.feedbackHelpful:
        if (notification.data['projectId'] != null) {
          Navigator.pushNamed(
            context,
            '/project-details',
            arguments: {'projectId': notification.data['projectId']},
          );
        }
        break;
      case NotificationType.mentorResponse:
        if (notification.data['mentorId'] != null) {
          Navigator.pushNamed(
            context,
            '/mentor-chat',
            arguments: {'mentorId': notification.data['mentorId']},
          );
        }
        break;
      case NotificationType.systemAlert:
        // Handle system alerts - could show a dialog or navigate to settings
        if (notification.actionUrl != null) {
          Navigator.pushNamed(context, notification.actionUrl!);
        }
        break;
    }
  }
}

class NotificationTile extends StatelessWidget {
  final NotificationModel notification;
  final VoidCallback? onTap;
  final VoidCallback? onMarkAsRead;
  final VoidCallback? onDelete;

  const NotificationTile({
    super.key,
    required this.notification,
    this.onTap,
    this.onMarkAsRead,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isUnread = !notification.isRead;

    return Dismissible(
      key: Key(notification.id),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        color: Colors.red,
        child: const Icon(
          Icons.delete,
          color: Colors.white,
        ),
      ),
      onDismissed: (_) => onDelete?.call(),
      child: InkWell(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: isUnread ? theme.primaryColor.withValues(alpha: 0.05) : null,
            border: Border(
              bottom: BorderSide(
                color: Colors.grey[200]!,
                width: 0.5,
              ),
            ),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: _getNotificationColor(notification.type).withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Icon(
                  _getNotificationIcon(notification.type),
                  color: _getNotificationColor(notification.type),
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            notification.title,
                            style: theme.textTheme.titleSmall?.copyWith(
                              fontWeight: isUnread ? FontWeight.w600 : FontWeight.normal,
                            ),
                          ),
                        ),
                        if (isUnread)
                          Container(
                            width: 8,
                            height: 8,
                            decoration: BoxDecoration(
                              color: theme.primaryColor,
                              borderRadius: BorderRadius.circular(4),
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      notification.message,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: Colors.grey[600],
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          timeago.format(notification.timestamp),
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: Colors.grey[500],
                          ),
                        ),
                        if (isUnread && onMarkAsRead != null)
                          InkWell(
                            onTap: onMarkAsRead,
                            child: Padding(
                              padding: const EdgeInsets.all(4),
                              child: Text(
                                'Mark as read',
                                style: theme.textTheme.bodySmall?.copyWith(
                                  color: theme.primaryColor,
                                ),
                              ),
                            ),
                          ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  IconData _getNotificationIcon(NotificationType type) {
    switch (type) {
      case NotificationType.doubtPosted:
        return Icons.help_outline;
      case NotificationType.doubtAnswered:
        return Icons.lightbulb_outline;
      case NotificationType.feedbackReceived:
        return Icons.feedback_outlined;
      case NotificationType.feedbackReply:
        return Icons.reply_outlined;
      case NotificationType.doubtUpvoted:
        return Icons.thumb_up_outlined;
      case NotificationType.feedbackHelpful:
        return Icons.favorite_outline;
      case NotificationType.mentorResponse:
        return Icons.person_outline;
      case NotificationType.systemAlert:
        return Icons.info_outline;
    }
  }

  Color _getNotificationColor(NotificationType type) {
    switch (type) {
      case NotificationType.doubtPosted:
        return Colors.blue;
      case NotificationType.doubtAnswered:
        return Colors.green;
      case NotificationType.feedbackReceived:
        return Colors.orange;
      case NotificationType.feedbackReply:
        return Colors.purple;
      case NotificationType.doubtUpvoted:
        return Colors.indigo;
      case NotificationType.feedbackHelpful:
        return Colors.pink;
      case NotificationType.mentorResponse:
        return Colors.teal;
      case NotificationType.systemAlert:
        return Colors.red;
    }
  }
}
