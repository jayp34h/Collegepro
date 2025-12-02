class UserProgressModel {
  final String userId;
  final int totalActivities;
  final int completedActivities;
  final Map<String, int> activityCounts;
  final DateTime lastUpdated;
  final double progressPercentage;

  const UserProgressModel({
    required this.userId,
    required this.totalActivities,
    required this.completedActivities,
    required this.activityCounts,
    required this.lastUpdated,
    required this.progressPercentage,
  });

  factory UserProgressModel.initial(String userId) {
    return UserProgressModel(
      userId: userId,
      totalActivities: 0,
      completedActivities: 0,
      activityCounts: {},
      lastUpdated: DateTime.now(),
      progressPercentage: 0.0,
    );
  }

  UserProgressModel copyWith({
    String? userId,
    int? totalActivities,
    int? completedActivities,
    Map<String, int>? activityCounts,
    DateTime? lastUpdated,
    double? progressPercentage,
  }) {
    return UserProgressModel(
      userId: userId ?? this.userId,
      totalActivities: totalActivities ?? this.totalActivities,
      completedActivities: completedActivities ?? this.completedActivities,
      activityCounts: activityCounts ?? Map.from(this.activityCounts),
      lastUpdated: lastUpdated ?? this.lastUpdated,
      progressPercentage: progressPercentage ?? this.progressPercentage,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'totalActivities': totalActivities,
      'completedActivities': completedActivities,
      'activityCounts': activityCounts,
      'lastUpdated': lastUpdated.millisecondsSinceEpoch,
      'progressPercentage': progressPercentage,
    };
  }

  factory UserProgressModel.fromMap(Map<String, dynamic> map) {
    return UserProgressModel(
      userId: map['userId'] ?? '',
      totalActivities: map['totalActivities'] ?? 0,
      completedActivities: map['completedActivities'] ?? 0,
      activityCounts: Map<String, int>.from(map['activityCounts'] ?? {}),
      lastUpdated: DateTime.fromMillisecondsSinceEpoch(map['lastUpdated'] ?? 0),
      progressPercentage: (map['progressPercentage'] ?? 0.0).toDouble(),
    );
  }

  @override
  String toString() {
    return 'UserProgressModel(userId: $userId, totalActivities: $totalActivities, completedActivities: $completedActivities, progressPercentage: $progressPercentage)';
  }
}
