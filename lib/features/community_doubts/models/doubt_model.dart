class CommunityDoubt {
  final String id;
  final String userId;
  final String userName;
  final String userAvatar;
  final String title;
  final String description;
  final List<String> tags;
  final String subject;
  final String difficulty; // Easy, Medium, Hard
  final DateTime timestamp;
  final DateTime createdAt;
  final bool isUrgent;
  final int upvotes;
  final int downvotes;
  final List<String> upvotedBy;
  final List<String> downvotedBy;
  final int answersCount;
  final bool isResolved;
  final String? bestAnswerId;
  final List<String> attachments; // URLs to images/files
  final bool isReported;
  final List<String> reportedBy;
  final int views;
  final int viewsCount;

  CommunityDoubt({
    required this.id,
    required this.userId,
    required this.userName,
    required this.userAvatar,
    required this.title,
    required this.description,
    required this.tags,
    required this.subject,
    required this.difficulty,
    required this.timestamp,
    required this.createdAt,
    this.isUrgent = false,
    this.upvotes = 0,
    this.downvotes = 0,
    this.upvotedBy = const [],
    this.downvotedBy = const [],
    this.answersCount = 0,
    this.isResolved = false,
    this.bestAnswerId,
    this.attachments = const [],
    this.isReported = false,
    this.reportedBy = const [],
    this.views = 0,
    this.viewsCount = 0,
  });

  factory CommunityDoubt.fromJson(Map<String, dynamic> json) {
    return CommunityDoubt(
      id: json['id'] ?? '',
      userId: json['userId'] ?? '',
      userName: json['userName'] ?? '',
      userAvatar: json['userAvatar'] ?? '',
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      tags: List<String>.from(json['tags'] ?? []),
      subject: json['subject'] ?? '',
      difficulty: json['difficulty'] ?? 'Easy',
      timestamp: DateTime.fromMillisecondsSinceEpoch(json['timestamp'] ?? 0),
      createdAt: DateTime.fromMillisecondsSinceEpoch(json['createdAt'] ?? 0),
      isUrgent: json['isUrgent'] ?? false,
      upvotes: json['upvotes'] ?? 0,
      downvotes: json['downvotes'] ?? 0,
      upvotedBy: List<String>.from(json['upvotedBy'] ?? []),
      downvotedBy: List<String>.from(json['downvotedBy'] ?? []),
      answersCount: json['answersCount'] ?? 0,
      isResolved: json['isResolved'] ?? false,
      bestAnswerId: json['bestAnswerId'],
      attachments: List<String>.from(json['attachments'] ?? []),
      isReported: json['isReported'] ?? false,
      reportedBy: List<String>.from(json['reportedBy'] ?? []),
      views: json['views'] ?? 0,
      viewsCount: json['viewsCount'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'userName': userName,
      'userAvatar': userAvatar,
      'title': title,
      'description': description,
      'tags': tags,
      'subject': subject,
      'difficulty': difficulty,
      'timestamp': timestamp.millisecondsSinceEpoch,
      'createdAt': createdAt.millisecondsSinceEpoch,
      'isUrgent': isUrgent,
      'upvotes': upvotes,
      'downvotes': downvotes,
      'upvotedBy': upvotedBy,
      'downvotedBy': downvotedBy,
      'answersCount': answersCount,
      'isResolved': isResolved,
      'bestAnswerId': bestAnswerId,
      'attachments': attachments,
      'isReported': isReported,
      'reportedBy': reportedBy,
      'views': views,
    };
  }

  CommunityDoubt copyWith({
    String? id,
    String? userId,
    String? userName,
    String? userAvatar,
    String? title,
    String? description,
    List<String>? tags,
    String? subject,
    String? difficulty,
    DateTime? timestamp,
    DateTime? createdAt,
    bool? isUrgent,
    int? upvotes,
    int? downvotes,
    List<String>? upvotedBy,
    List<String>? downvotedBy,
    int? answersCount,
    bool? isResolved,
    String? bestAnswerId,
    List<String>? attachments,
    bool? isReported,
    List<String>? reportedBy,
    int? views,
  }) {
    return CommunityDoubt(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      userName: userName ?? this.userName,
      userAvatar: userAvatar ?? this.userAvatar,
      title: title ?? this.title,
      description: description ?? this.description,
      tags: tags ?? this.tags,
      subject: subject ?? this.subject,
      difficulty: difficulty ?? this.difficulty,
      timestamp: timestamp ?? this.timestamp,
      createdAt: createdAt ?? this.createdAt,
      isUrgent: isUrgent ?? this.isUrgent,
      upvotes: upvotes ?? this.upvotes,
      downvotes: downvotes ?? this.downvotes,
      upvotedBy: upvotedBy ?? this.upvotedBy,
      downvotedBy: downvotedBy ?? this.downvotedBy,
      answersCount: answersCount ?? this.answersCount,
      isResolved: isResolved ?? this.isResolved,
      bestAnswerId: bestAnswerId ?? this.bestAnswerId,
      attachments: attachments ?? this.attachments,
      isReported: isReported ?? this.isReported,
      reportedBy: reportedBy ?? this.reportedBy,
      views: views ?? this.views,
    );
  }
}
