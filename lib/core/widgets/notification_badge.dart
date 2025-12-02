import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/notification_provider.dart';
import 'notification_list.dart';

class NotificationBadge extends StatelessWidget {
  final Widget child;
  final bool showZero;
  final Color? badgeColor;
  final Color? textColor;
  final double? fontSize;
  final EdgeInsets? padding;

  const NotificationBadge({
    super.key,
    required this.child,
    this.showZero = false,
    this.badgeColor,
    this.textColor,
    this.fontSize,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    return Consumer<NotificationProvider>(
      builder: (context, notificationProvider, _) {
        final unreadCount = notificationProvider.unreadCount;
        
        if (unreadCount == 0 && !showZero) {
          return child;
        }

        return Stack(
          clipBehavior: Clip.none,
          children: [
            child,
            Positioned(
              right: -6,
              top: -6,
              child: Container(
                padding: padding ?? const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: badgeColor ?? Colors.red,
                  borderRadius: BorderRadius.circular(10),
                ),
                constraints: const BoxConstraints(
                  minWidth: 16,
                  minHeight: 16,
                ),
                child: Text(
                  unreadCount > 99 ? '99+' : unreadCount.toString(),
                  style: TextStyle(
                    color: textColor ?? Colors.white,
                    fontSize: fontSize ?? 10,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}

class NotificationIcon extends StatelessWidget {
  final VoidCallback? onTap;
  final Color? iconColor;
  final double? iconSize;

  const NotificationIcon({
    super.key,
    this.onTap,
    this.iconColor,
    this.iconSize,
  });

  @override
  Widget build(BuildContext context) {
    return NotificationBadge(
      child: IconButton(
        onPressed: onTap ?? () => _showNotificationsBottomSheet(context),
        icon: Icon(
          Icons.notifications_outlined,
          color: iconColor,
          size: iconSize,
        ),
      ),
    );
  }

  void _showNotificationsBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.7,
        minChildSize: 0.5,
        maxChildSize: 0.95,
        builder: (context, scrollController) => Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  border: Border(
                    bottom: BorderSide(
                      color: Colors.grey[200]!,
                      width: 1,
                    ),
                  ),
                ),
                child: Row(
                  children: [
                    const Text(
                      'Notifications',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const Spacer(),
                    IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(Icons.close),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: NotificationList(),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

