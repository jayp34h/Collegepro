class DoubtAnswer {
  final String id;
  final String doubtId;
  final String userId;
  final String userName;
  final String userAvatar;
  final String content;
  final DateTime timestamp;
  final int upvotes;
  final int downvotes;
  final List<String> upvotedBy;
  final List<String> downvotedBy;
  final bool isBestAnswer;
  final bool isReported;
  final List<String> reportedBy;
  final List<String> attachments;
  final int helpfulCount;
  final List<String> markedHelpfulBy;

  DoubtAnswer({
    required this.id,
    required this.doubtId,
    required this.userId,
    required this.userName,
    required this.userAvatar,
    required this.content,
    required this.timestamp,
    this.upvotes = 0,
    this.downvotes = 0,
    this.upvotedBy = const [],
    this.downvotedBy = const [],
    this.isBestAnswer = false,
    this.isReported = false,
    this.reportedBy = const [],
    this.attachments = const [],
    this.helpfulCount = 0,
    this.markedHelpfulBy = const [],
  });

  factory DoubtAnswer.fromJson(Map<String, dynamic> json) {
    return DoubtAnswer(
      id: json['id'] ?? '',
      doubtId: json['doubtId'] ?? '',
      userId: json['userId'] ?? '',
      userName: json['userName'] ?? '',
      userAvatar: json['userAvatar'] ?? '',
      content: json['content'] ?? '',
      timestamp: DateTime.fromMillisecondsSinceEpoch(json['timestamp'] ?? 0),
      upvotes: json['upvotes'] ?? 0,
      downvotes: json['downvotes'] ?? 0,
      upvotedBy: List<String>.from(json['upvotedBy'] ?? []),
      downvotedBy: List<String>.from(json['downvotedBy'] ?? []),
      isBestAnswer: json['isBestAnswer'] ?? false,
      isReported: json['isReported'] ?? false,
      reportedBy: List<String>.from(json['reportedBy'] ?? []),
      attachments: List<String>.from(json['attachments'] ?? []),
      helpfulCount: json['helpfulCount'] ?? 0,
      markedHelpfulBy: List<String>.from(json['markedHelpfulBy'] ?? []),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'doubtId': doubtId,
      'userId': userId,
      'userName': userName,
      'userAvatar': userAvatar,
      'content': content,
      'timestamp': timestamp.millisecondsSinceEpoch,
      'upvotes': upvotes,
      'downvotes': downvotes,
      'upvotedBy': upvotedBy,
      'downvotedBy': downvotedBy,
      'isBestAnswer': isBestAnswer,
      'isReported': isReported,
      'reportedBy': reportedBy,
      'attachments': attachments,
      'helpfulCount': helpfulCount,
      'markedHelpfulBy': markedHelpfulBy,
    };
  }

  DoubtAnswer copyWith({
    String? id,
    String? doubtId,
    String? userId,
    String? userName,
    String? userAvatar,
    String? content,
    DateTime? timestamp,
    int? upvotes,
    int? downvotes,
    List<String>? upvotedBy,
    List<String>? downvotedBy,
    bool? isBestAnswer,
    bool? isReported,
    List<String>? reportedBy,
    List<String>? attachments,
    int? helpfulCount,
    List<String>? markedHelpfulBy,
  }) {
    return DoubtAnswer(
      id: id ?? this.id,
      doubtId: doubtId ?? this.doubtId,
      userId: userId ?? this.userId,
      userName: userName ?? this.userName,
      userAvatar: userAvatar ?? this.userAvatar,
      content: content ?? this.content,
      timestamp: timestamp ?? this.timestamp,
      upvotes: upvotes ?? this.upvotes,
      downvotes: downvotes ?? this.downvotes,
      upvotedBy: upvotedBy ?? this.upvotedBy,
      downvotedBy: downvotedBy ?? this.downvotedBy,
      isBestAnswer: isBestAnswer ?? this.isBestAnswer,
      isReported: isReported ?? this.isReported,
      reportedBy: reportedBy ?? this.reportedBy,
      attachments: attachments ?? this.attachments,
      helpfulCount: helpfulCount ?? this.helpfulCount,
      markedHelpfulBy: markedHelpfulBy ?? this.markedHelpfulBy,
    );
  }
}
