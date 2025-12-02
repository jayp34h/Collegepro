class VideoHistory {
  final String id;
  final String userId;
  final String videoId;
  final String videoTitle;
  final String videoUrl;
  final String thumbnailUrl;
  final String channelName;
  final Duration videoDuration;
  final Duration watchedDuration;
  final double watchPercentage;
  final DateTime startedAt;
  final DateTime lastWatchedAt;
  final bool isCompleted;
  final String category;
  final List<String> tags;

  VideoHistory({
    required this.id,
    required this.userId,
    required this.videoId,
    required this.videoTitle,
    required this.videoUrl,
    required this.thumbnailUrl,
    required this.channelName,
    required this.videoDuration,
    required this.watchedDuration,
    required this.watchPercentage,
    required this.startedAt,
    required this.lastWatchedAt,
    required this.isCompleted,
    required this.category,
    required this.tags,
  });

  factory VideoHistory.fromJson(Map<String, dynamic> json) {
    return VideoHistory(
      id: json['id'] ?? '',
      userId: json['userId'] ?? '',
      videoId: json['videoId'] ?? '',
      videoTitle: json['videoTitle'] ?? '',
      videoUrl: json['videoUrl'] ?? '',
      thumbnailUrl: json['thumbnailUrl'] ?? '',
      channelName: json['channelName'] ?? '',
      videoDuration: Duration(seconds: json['videoDurationSeconds'] ?? 0),
      watchedDuration: Duration(seconds: json['watchedDurationSeconds'] ?? 0),
      watchPercentage: (json['watchPercentage'] ?? 0.0).toDouble(),
      startedAt: DateTime.parse(json['startedAt'] ?? DateTime.now().toIso8601String()),
      lastWatchedAt: DateTime.parse(json['lastWatchedAt'] ?? DateTime.now().toIso8601String()),
      isCompleted: json['isCompleted'] ?? false,
      category: json['category'] ?? '',
      tags: List<String>.from(json['tags'] ?? []),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'videoId': videoId,
      'videoTitle': videoTitle,
      'videoUrl': videoUrl,
      'thumbnailUrl': thumbnailUrl,
      'channelName': channelName,
      'videoDurationSeconds': videoDuration.inSeconds,
      'watchedDurationSeconds': watchedDuration.inSeconds,
      'watchPercentage': watchPercentage,
      'startedAt': startedAt.toIso8601String(),
      'lastWatchedAt': lastWatchedAt.toIso8601String(),
      'isCompleted': isCompleted,
      'category': category,
      'tags': tags,
    };
  }

  VideoHistory copyWith({
    String? id,
    String? userId,
    String? videoId,
    String? videoTitle,
    String? videoUrl,
    String? thumbnailUrl,
    String? channelName,
    Duration? videoDuration,
    Duration? watchedDuration,
    double? watchPercentage,
    DateTime? startedAt,
    DateTime? lastWatchedAt,
    bool? isCompleted,
    String? category,
    List<String>? tags,
  }) {
    return VideoHistory(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      videoId: videoId ?? this.videoId,
      videoTitle: videoTitle ?? this.videoTitle,
      videoUrl: videoUrl ?? this.videoUrl,
      thumbnailUrl: thumbnailUrl ?? this.thumbnailUrl,
      channelName: channelName ?? this.channelName,
      videoDuration: videoDuration ?? this.videoDuration,
      watchedDuration: watchedDuration ?? this.watchedDuration,
      watchPercentage: watchPercentage ?? this.watchPercentage,
      startedAt: startedAt ?? this.startedAt,
      lastWatchedAt: lastWatchedAt ?? this.lastWatchedAt,
      isCompleted: isCompleted ?? this.isCompleted,
      category: category ?? this.category,
      tags: tags ?? this.tags,
    );
  }
}

class VideoWatchSession {
  final String sessionId;
  final String userId;
  final String videoId;
  final DateTime startTime;
  final DateTime? endTime;
  final Duration watchedDuration;
  final List<VideoWatchSegment> segments;

  VideoWatchSession({
    required this.sessionId,
    required this.userId,
    required this.videoId,
    required this.startTime,
    this.endTime,
    required this.watchedDuration,
    required this.segments,
  });

  factory VideoWatchSession.fromJson(Map<String, dynamic> json) {
    return VideoWatchSession(
      sessionId: json['sessionId'] ?? '',
      userId: json['userId'] ?? '',
      videoId: json['videoId'] ?? '',
      startTime: DateTime.parse(json['startTime'] ?? DateTime.now().toIso8601String()),
      endTime: json['endTime'] != null ? DateTime.parse(json['endTime']) : null,
      watchedDuration: Duration(seconds: json['watchedDurationSeconds'] ?? 0),
      segments: (json['segments'] as List<dynamic>? ?? [])
          .map((segment) => VideoWatchSegment.fromJson(segment))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'sessionId': sessionId,
      'userId': userId,
      'videoId': videoId,
      'startTime': startTime.toIso8601String(),
      'endTime': endTime?.toIso8601String(),
      'watchedDurationSeconds': watchedDuration.inSeconds,
      'segments': segments.map((segment) => segment.toJson()).toList(),
    };
  }
}

class VideoWatchSegment {
  final Duration startPosition;
  final Duration endPosition;
  final DateTime timestamp;

  VideoWatchSegment({
    required this.startPosition,
    required this.endPosition,
    required this.timestamp,
  });

  factory VideoWatchSegment.fromJson(Map<String, dynamic> json) {
    return VideoWatchSegment(
      startPosition: Duration(seconds: json['startPositionSeconds'] ?? 0),
      endPosition: Duration(seconds: json['endPositionSeconds'] ?? 0),
      timestamp: DateTime.parse(json['timestamp'] ?? DateTime.now().toIso8601String()),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'startPositionSeconds': startPosition.inSeconds,
      'endPositionSeconds': endPosition.inSeconds,
      'timestamp': timestamp.toIso8601String(),
    };
  }
}
