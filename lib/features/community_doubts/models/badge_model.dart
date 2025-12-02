enum BadgeType {
  questioner,
  answerer,
  helpful,
  expert,
  mentor,
  scholar,
  contributor,
  moderator,
}

enum BadgeLevel {
  bronze,
  silver,
  gold,
  platinum,
  diamond,
}

class Badge {
  final String id;
  final String name;
  final String description;
  final BadgeType type;
  final BadgeLevel level;
  final String iconPath;
  final int requiredPoints;
  final String criteria;
  final DateTime? unlockedAt;
  final bool isUnlocked;

  Badge({
    required this.id,
    required this.name,
    required this.description,
    required this.type,
    required this.level,
    required this.iconPath,
    required this.requiredPoints,
    required this.criteria,
    this.unlockedAt,
    this.isUnlocked = false,
  });

  factory Badge.fromJson(Map<String, dynamic> json) {
    return Badge(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      description: json['description'] ?? '',
      type: BadgeType.values.firstWhere(
        (e) => e.toString() == 'BadgeType.${json['type']}',
        orElse: () => BadgeType.contributor,
      ),
      level: BadgeLevel.values.firstWhere(
        (e) => e.toString() == 'BadgeLevel.${json['level']}',
        orElse: () => BadgeLevel.bronze,
      ),
      iconPath: json['iconPath'] ?? '',
      requiredPoints: json['requiredPoints'] ?? 0,
      criteria: json['criteria'] ?? '',
      unlockedAt: json['unlockedAt'] != null 
          ? DateTime.fromMillisecondsSinceEpoch(json['unlockedAt'])
          : null,
      isUnlocked: json['isUnlocked'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'type': type.toString().split('.').last,
      'level': level.toString().split('.').last,
      'iconPath': iconPath,
      'requiredPoints': requiredPoints,
      'criteria': criteria,
      'unlockedAt': unlockedAt?.millisecondsSinceEpoch,
      'isUnlocked': isUnlocked,
    };
  }
}

class UserProgress {
  final String userId;
  final String userName;
  final int totalPoints;
  final int questionsAsked;
  final int answersGiven;
  final int bestAnswers;
  final int helpfulMarks;
  final int upvotesReceived;
  final int doubtsSolved;
  final List<String> unlockedBadges;
  final Map<String, int> subjectPoints; // Subject-wise points
  final int currentStreak;
  final int longestStreak;
  final DateTime lastActivity;
  final int level;
  final int experiencePoints;

  UserProgress({
    required this.userId,
    this.userName = 'Anonymous',
    this.totalPoints = 0,
    this.questionsAsked = 0,
    this.answersGiven = 0,
    this.bestAnswers = 0,
    this.helpfulMarks = 0,
    this.upvotesReceived = 0,
    this.doubtsSolved = 0,
    this.unlockedBadges = const [],
    this.subjectPoints = const {},
    this.currentStreak = 0,
    this.longestStreak = 0,
    required this.lastActivity,
    this.level = 1,
    this.experiencePoints = 0,
  });

  factory UserProgress.fromJson(Map<String, dynamic> json) {
    return UserProgress(
      userId: json['userId'] ?? '',
      userName: json['userName'] ?? 'Anonymous',
      totalPoints: json['totalPoints'] ?? 0,
      questionsAsked: json['questionsAsked'] ?? 0,
      answersGiven: json['answersGiven'] ?? 0,
      bestAnswers: json['bestAnswers'] ?? 0,
      helpfulMarks: json['helpfulMarks'] ?? 0,
      upvotesReceived: json['upvotesReceived'] ?? 0,
      doubtsSolved: json['doubtsSolved'] ?? 0,
      unlockedBadges: List<String>.from(json['unlockedBadges'] ?? []),
      subjectPoints: Map<String, int>.from(json['subjectPoints'] ?? {}),
      currentStreak: json['currentStreak'] ?? 0,
      longestStreak: json['longestStreak'] ?? 0,
      lastActivity: DateTime.fromMillisecondsSinceEpoch(
        json['lastActivity'] ?? DateTime.now().millisecondsSinceEpoch,
      ),
      level: json['level'] ?? 1,
      experiencePoints: json['experiencePoints'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'userId': userId,
      'userName': userName,
      'totalPoints': totalPoints,
      'questionsAsked': questionsAsked,
      'answersGiven': answersGiven,
      'bestAnswers': bestAnswers,
      'helpfulMarks': helpfulMarks,
      'upvotesReceived': upvotesReceived,
      'doubtsSolved': doubtsSolved,
      'unlockedBadges': unlockedBadges,
      'subjectPoints': subjectPoints,
      'currentStreak': currentStreak,
      'longestStreak': longestStreak,
      'lastActivity': lastActivity.millisecondsSinceEpoch,
      'level': level,
      'experiencePoints': experiencePoints,
    };
  }

  UserProgress copyWith({
    String? userId,
    String? userName,
    int? totalPoints,
    int? questionsAsked,
    int? answersGiven,
    int? bestAnswers,
    int? helpfulMarks,
    int? upvotesReceived,
    int? doubtsSolved,
    List<String>? unlockedBadges,
    Map<String, int>? subjectPoints,
    int? currentStreak,
    int? longestStreak,
    DateTime? lastActivity,
    int? level,
    int? experiencePoints,
  }) {
    return UserProgress(
      userId: userId ?? this.userId,
      userName: userName ?? this.userName,
      totalPoints: totalPoints ?? this.totalPoints,
      questionsAsked: questionsAsked ?? this.questionsAsked,
      answersGiven: answersGiven ?? this.answersGiven,
      bestAnswers: bestAnswers ?? this.bestAnswers,
      helpfulMarks: helpfulMarks ?? this.helpfulMarks,
      upvotesReceived: upvotesReceived ?? this.upvotesReceived,
      doubtsSolved: doubtsSolved ?? this.doubtsSolved,
      unlockedBadges: unlockedBadges ?? this.unlockedBadges,
      subjectPoints: subjectPoints ?? this.subjectPoints,
      currentStreak: currentStreak ?? this.currentStreak,
      longestStreak: longestStreak ?? this.longestStreak,
      lastActivity: lastActivity ?? this.lastActivity,
      level: level ?? this.level,
      experiencePoints: experiencePoints ?? this.experiencePoints,
    );
  }

  // Calculate level based on experience points
  int calculateLevel() {
    if (experiencePoints < 100) return 1;
    if (experiencePoints < 300) return 2;
    if (experiencePoints < 600) return 3;
    if (experiencePoints < 1000) return 4;
    if (experiencePoints < 1500) return 5;
    if (experiencePoints < 2100) return 6;
    if (experiencePoints < 2800) return 7;
    if (experiencePoints < 3600) return 8;
    if (experiencePoints < 4500) return 9;
    return 10; // Max level
  }

  // Get points needed for next level
  int getPointsForNextLevel() {
    final currentLevel = calculateLevel();
    if (currentLevel >= 10) return 0; // Max level reached
    
    final levelThresholds = [0, 100, 300, 600, 1000, 1500, 2100, 2800, 3600, 4500];
    return levelThresholds[currentLevel] - experiencePoints;
  }
}
