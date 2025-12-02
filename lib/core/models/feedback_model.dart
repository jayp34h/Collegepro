class FeedbackModel {
  final String id;
  final String projectId;
  final String userId;
  final String userName;
  final String userEmail;
  final String feedback;
  final double rating; // 1-5 stars
  final String category; // 'technical', 'design', 'implementation', 'general'
  final DateTime timestamp;
  final List<String> tags;
  final bool isHelpful;
  final int helpfulCount;
  final List<String> helpfulUsers;
  final List<FeedbackReply> replies;

  FeedbackModel({
    required this.id,
    required this.projectId,
    required this.userId,
    required this.userName,
    required this.userEmail,
    required this.feedback,
    required this.rating,
    required this.category,
    required this.timestamp,
    this.tags = const [],
    this.isHelpful = false,
    this.helpfulCount = 0,
    this.helpfulUsers = const [],
    this.replies = const [],
  });

  factory FeedbackModel.fromMap(Map<String, dynamic> map) {
    List<FeedbackReply> replies = [];
    if (map['replies'] != null) {
      final repliesData = Map<String, dynamic>.from(map['replies'] as Map);
      replies = repliesData.values
          .map((replyData) => FeedbackReply.fromMap(Map<String, dynamic>.from(replyData as Map)))
          .toList();
      replies.sort((a, b) => a.timestamp.compareTo(b.timestamp)); // Sort by timestamp
    }
    
    return FeedbackModel(
      id: map['id'] ?? '',
      projectId: map['projectId'] ?? '',
      userId: map['userId'] ?? '',
      userName: map['userName'] ?? '',
      userEmail: map['userEmail'] ?? '',
      feedback: map['feedback'] ?? '',
      rating: (map['rating'] ?? 0.0).toDouble(),
      category: map['category'] ?? 'general',
      timestamp: DateTime.fromMillisecondsSinceEpoch(map['timestamp'] ?? 0),
      tags: List<String>.from(map['tags'] ?? []),
      isHelpful: map['isHelpful'] ?? false,
      helpfulCount: map['helpfulCount'] ?? 0,
      helpfulUsers: List<String>.from(map['helpfulUsers'] ?? []),
      replies: replies,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'projectId': projectId,
      'userId': userId,
      'userName': userName,
      'userEmail': userEmail,
      'feedback': feedback,
      'rating': rating,
      'category': category,
      'timestamp': timestamp.millisecondsSinceEpoch,
      'tags': tags,
      'isHelpful': isHelpful,
      'helpfulCount': helpfulCount,
      'helpfulUsers': helpfulUsers,
      'replies': replies.map((reply) => reply.toMap()).toList(),
    };
  }

  FeedbackModel copyWith({
    String? id,
    String? projectId,
    String? userId,
    String? userName,
    String? userEmail,
    String? feedback,
    double? rating,
    String? category,
    DateTime? timestamp,
    List<String>? tags,
    bool? isHelpful,
    int? helpfulCount,
    List<String>? helpfulUsers,
    List<FeedbackReply>? replies,
  }) {
    return FeedbackModel(
      id: id ?? this.id,
      projectId: projectId ?? this.projectId,
      userId: userId ?? this.userId,
      userName: userName ?? this.userName,
      userEmail: userEmail ?? this.userEmail,
      feedback: feedback ?? this.feedback,
      rating: rating ?? this.rating,
      category: category ?? this.category,
      timestamp: timestamp ?? this.timestamp,
      tags: tags ?? this.tags,
      isHelpful: isHelpful ?? this.isHelpful,
      helpfulCount: helpfulCount ?? this.helpfulCount,
      helpfulUsers: helpfulUsers ?? this.helpfulUsers,
      replies: replies ?? this.replies,
    );
  }

  @override
  String toString() {
    return 'FeedbackModel(id: $id, projectId: $projectId, userName: $userName, rating: $rating, category: $category)';
  }
}

enum FeedbackCategory {
  technical('Technical Implementation'),
  design('UI/UX Design'),
  implementation('Code Quality'),
  general('General Feedback'),
  suggestion('Suggestions'),
  improvement('Improvements');

  const FeedbackCategory(this.displayName);
  final String displayName;
}

class FeedbackReply {
  final String id;
  final String reply;
  final String userId;
  final String userName;
  final DateTime timestamp;

  FeedbackReply({
    required this.id,
    required this.reply,
    required this.userId,
    required this.userName,
    required this.timestamp,
  });

  factory FeedbackReply.fromMap(Map<String, dynamic> map) {
    return FeedbackReply(
      id: map['id'] ?? '',
      reply: map['reply'] ?? '',
      userId: map['userId'] ?? '',
      userName: map['userName'] ?? '',
      timestamp: DateTime.fromMillisecondsSinceEpoch(map['timestamp'] ?? 0),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'reply': reply,
      'userId': userId,
      'userName': userName,
      'timestamp': timestamp.millisecondsSinceEpoch,
    };
  }
}

class FeedbackStats {
  final double averageRating;
  final int totalFeedbacks;
  final Map<String, int> categoryCount;
  final Map<int, int> ratingDistribution;

  FeedbackStats({
    required this.averageRating,
    required this.totalFeedbacks,
    required this.categoryCount,
    required this.ratingDistribution,
  });

  factory FeedbackStats.empty() {
    return FeedbackStats(
      averageRating: 0.0,
      totalFeedbacks: 0,
      categoryCount: {},
      ratingDistribution: {},
    );
  }

  factory FeedbackStats.fromFeedbacks(List<FeedbackModel> feedbacks) {
    if (feedbacks.isEmpty) return FeedbackStats.empty();

    final totalRating = feedbacks.fold<double>(0.0, (sum, feedback) => sum + feedback.rating);
    final averageRating = totalRating / feedbacks.length;

    final categoryCount = <String, int>{};
    final ratingDistribution = <int, int>{};

    for (final feedback in feedbacks) {
      categoryCount[feedback.category] = (categoryCount[feedback.category] ?? 0) + 1;
      final ratingKey = feedback.rating.round();
      ratingDistribution[ratingKey] = (ratingDistribution[ratingKey] ?? 0) + 1;
    }

    return FeedbackStats(
      averageRating: averageRating,
      totalFeedbacks: feedbacks.length,
      categoryCount: categoryCount,
      ratingDistribution: ratingDistribution,
    );
  }
}
