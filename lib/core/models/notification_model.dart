enum NotificationType {
  doubtPosted('doubt_posted'),
  doubtAnswered('doubt_answered'),
  feedbackReceived('feedback_received'),
  feedbackReply('feedback_reply'),
  doubtUpvoted('doubt_upvoted'),
  feedbackHelpful('feedback_helpful'),
  mentorResponse('mentor_response'),
  systemAlert('system_alert');

  const NotificationType(this.value);
  final String value;

  static NotificationType fromString(String value) {
    return NotificationType.values.firstWhere(
      (type) => type.value == value,
      orElse: () => NotificationType.systemAlert,
    );
  }
}

enum NotificationPriority {
  low('low'),
  medium('medium'),
  high('high'),
  urgent('urgent');

  const NotificationPriority(this.value);
  final String value;

  static NotificationPriority fromString(String value) {
    return NotificationPriority.values.firstWhere(
      (priority) => priority.value == value,
      orElse: () => NotificationPriority.medium,
    );
  }
}

class NotificationModel {
  final String id;
  final String recipientId;
  final String senderId;
  final String senderName;
  final String senderAvatar;
  final NotificationType type;
  final NotificationPriority priority;
  final String title;
  final String message;
  final Map<String, dynamic> data; // Additional data like doubtId, projectId, etc.
  final DateTime timestamp;
  final bool isRead;
  final bool isDelivered;
  final String? actionUrl; // Deep link or navigation route
  final String? imageUrl;
  final DateTime? expiresAt;

  NotificationModel({
    required this.id,
    required this.recipientId,
    required this.senderId,
    required this.senderName,
    this.senderAvatar = '',
    required this.type,
    this.priority = NotificationPriority.medium,
    required this.title,
    required this.message,
    this.data = const {},
    required this.timestamp,
    this.isRead = false,
    this.isDelivered = false,
    this.actionUrl,
    this.imageUrl,
    this.expiresAt,
  });

  factory NotificationModel.fromJson(Map<String, dynamic> json) {
    return NotificationModel(
      id: json['id'] ?? '',
      recipientId: json['recipientId'] ?? '',
      senderId: json['senderId'] ?? '',
      senderName: json['senderName'] ?? '',
      senderAvatar: json['senderAvatar'] ?? '',
      type: NotificationType.fromString(json['type'] ?? 'system_alert'),
      priority: NotificationPriority.fromString(json['priority'] ?? 'medium'),
      title: json['title'] ?? '',
      message: json['message'] ?? '',
      data: Map<String, dynamic>.from(json['data'] ?? {}),
      timestamp: DateTime.fromMillisecondsSinceEpoch(json['timestamp'] ?? 0),
      isRead: json['isRead'] ?? false,
      isDelivered: json['isDelivered'] ?? false,
      actionUrl: json['actionUrl'],
      imageUrl: json['imageUrl'],
      expiresAt: json['expiresAt'] != null 
          ? DateTime.fromMillisecondsSinceEpoch(json['expiresAt'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'recipientId': recipientId,
      'senderId': senderId,
      'senderName': senderName,
      'senderAvatar': senderAvatar,
      'type': type.value,
      'priority': priority.value,
      'title': title,
      'message': message,
      'data': data,
      'timestamp': timestamp.millisecondsSinceEpoch,
      'isRead': isRead,
      'isDelivered': isDelivered,
      'actionUrl': actionUrl,
      'imageUrl': imageUrl,
      'expiresAt': expiresAt?.millisecondsSinceEpoch,
    };
  }

  NotificationModel copyWith({
    String? id,
    String? recipientId,
    String? senderId,
    String? senderName,
    String? senderAvatar,
    NotificationType? type,
    NotificationPriority? priority,
    String? title,
    String? message,
    Map<String, dynamic>? data,
    DateTime? timestamp,
    bool? isRead,
    bool? isDelivered,
    String? actionUrl,
    String? imageUrl,
    DateTime? expiresAt,
  }) {
    return NotificationModel(
      id: id ?? this.id,
      recipientId: recipientId ?? this.recipientId,
      senderId: senderId ?? this.senderId,
      senderName: senderName ?? this.senderName,
      senderAvatar: senderAvatar ?? this.senderAvatar,
      type: type ?? this.type,
      priority: priority ?? this.priority,
      title: title ?? this.title,
      message: message ?? this.message,
      data: data ?? this.data,
      timestamp: timestamp ?? this.timestamp,
      isRead: isRead ?? this.isRead,
      isDelivered: isDelivered ?? this.isDelivered,
      actionUrl: actionUrl ?? this.actionUrl,
      imageUrl: imageUrl ?? this.imageUrl,
      expiresAt: expiresAt ?? this.expiresAt,
    );
  }

  bool get isExpired => expiresAt != null && DateTime.now().isAfter(expiresAt!);
  
  String get timeAgo {
    final now = DateTime.now();
    final difference = now.difference(timestamp);
    
    if (difference.inMinutes < 1) {
      return 'Just now';
    } else if (difference.inMinutes < 60) {
      return '${difference.inMinutes}m ago';
    } else if (difference.inHours < 24) {
      return '${difference.inHours}h ago';
    } else if (difference.inDays < 7) {
      return '${difference.inDays}d ago';
    } else {
      return '${(difference.inDays / 7).floor()}w ago';
    }
  }

  @override
  String toString() {
    return 'NotificationModel(id: $id, type: ${type.value}, title: $title, isRead: $isRead)';
  }
}

class NotificationSettings {
  final bool doubtNotifications;
  final bool feedbackNotifications;
  final bool mentorNotifications;
  final bool systemNotifications;
  final bool pushNotifications;
  final bool emailNotifications;
  final bool soundEnabled;
  final bool vibrationEnabled;
  final String quietHoursStart; // "22:00"
  final String quietHoursEnd; // "07:00"
  final List<String> mutedUsers;
  final List<String> mutedTopics;

  NotificationSettings({
    this.doubtNotifications = true,
    this.feedbackNotifications = true,
    this.mentorNotifications = true,
    this.systemNotifications = true,
    this.pushNotifications = true,
    this.emailNotifications = false,
    this.soundEnabled = true,
    this.vibrationEnabled = true,
    this.quietHoursStart = '22:00',
    this.quietHoursEnd = '07:00',
    this.mutedUsers = const [],
    this.mutedTopics = const [],
  });

  factory NotificationSettings.fromJson(Map<String, dynamic> json) {
    return NotificationSettings(
      doubtNotifications: json['doubtNotifications'] ?? true,
      feedbackNotifications: json['feedbackNotifications'] ?? true,
      mentorNotifications: json['mentorNotifications'] ?? true,
      systemNotifications: json['systemNotifications'] ?? true,
      pushNotifications: json['pushNotifications'] ?? true,
      emailNotifications: json['emailNotifications'] ?? false,
      soundEnabled: json['soundEnabled'] ?? true,
      vibrationEnabled: json['vibrationEnabled'] ?? true,
      quietHoursStart: json['quietHoursStart'] ?? '22:00',
      quietHoursEnd: json['quietHoursEnd'] ?? '07:00',
      mutedUsers: List<String>.from(json['mutedUsers'] ?? []),
      mutedTopics: List<String>.from(json['mutedTopics'] ?? []),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'doubtNotifications': doubtNotifications,
      'feedbackNotifications': feedbackNotifications,
      'mentorNotifications': mentorNotifications,
      'systemNotifications': systemNotifications,
      'pushNotifications': pushNotifications,
      'emailNotifications': emailNotifications,
      'soundEnabled': soundEnabled,
      'vibrationEnabled': vibrationEnabled,
      'quietHoursStart': quietHoursStart,
      'quietHoursEnd': quietHoursEnd,
      'mutedUsers': mutedUsers,
      'mutedTopics': mutedTopics,
    };
  }

  bool get isInQuietHours {
    final now = DateTime.now();
    
    final startHour = int.parse(quietHoursStart.split(':')[0]);
    final endHour = int.parse(quietHoursEnd.split(':')[0]);
    final currentHour = now.hour;
    
    if (startHour < endHour) {
      return currentHour >= startHour && currentHour < endHour;
    } else {
      return currentHour >= startHour || currentHour < endHour;
    }
  }

  // Convenience getters for backwards compatibility
  bool get doubtPosted => doubtNotifications;
  bool get doubtAnswered => doubtNotifications;
  bool get feedbackReceived => feedbackNotifications;
  bool get feedbackReply => feedbackNotifications;

  NotificationSettings copyWith({
    bool? doubtNotifications,
    bool? feedbackNotifications,
    bool? mentorNotifications,
    bool? systemNotifications,
    bool? pushNotifications,
    bool? emailNotifications,
    bool? soundEnabled,
    bool? vibrationEnabled,
    String? quietHoursStart,
    String? quietHoursEnd,
    List<String>? mutedUsers,
    List<String>? mutedTopics,
    // Backwards compatibility parameters
    bool? doubtPosted,
    bool? doubtAnswered,
    bool? feedbackReceived,
    bool? feedbackReply,
  }) {
    return NotificationSettings(
      doubtNotifications: doubtPosted ?? doubtAnswered ?? doubtNotifications ?? this.doubtNotifications,
      feedbackNotifications: feedbackReceived ?? feedbackReply ?? feedbackNotifications ?? this.feedbackNotifications,
      mentorNotifications: mentorNotifications ?? this.mentorNotifications,
      systemNotifications: systemNotifications ?? this.systemNotifications,
      pushNotifications: pushNotifications ?? this.pushNotifications,
      emailNotifications: emailNotifications ?? this.emailNotifications,
      soundEnabled: soundEnabled ?? this.soundEnabled,
      vibrationEnabled: vibrationEnabled ?? this.vibrationEnabled,
      quietHoursStart: quietHoursStart ?? this.quietHoursStart,
      quietHoursEnd: quietHoursEnd ?? this.quietHoursEnd,
      mutedUsers: mutedUsers ?? this.mutedUsers,
      mutedTopics: mutedTopics ?? this.mutedTopics,
    );
  }
}
