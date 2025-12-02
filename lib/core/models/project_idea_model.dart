class ProjectIdeaModel {
  final String id;
  final String title;
  final String description;
  final String domain;
  final String difficulty;
  final List<String> techStack;
  final String problemStatement;
  final List<String> expectedOutcomes;
  final String estimatedDuration;
  final String authorId;
  final String authorName;
  final String authorEmail;
  final DateTime createdAt;
  final DateTime updatedAt;
  final int likes;
  final int views;
  final List<String> likedBy;
  final bool isApproved;
  final String status; // 'pending', 'approved', 'rejected'

  ProjectIdeaModel({
    required this.id,
    required this.title,
    required this.description,
    required this.domain,
    required this.difficulty,
    required this.techStack,
    required this.problemStatement,
    required this.expectedOutcomes,
    required this.estimatedDuration,
    required this.authorId,
    required this.authorName,
    required this.authorEmail,
    required this.createdAt,
    required this.updatedAt,
    this.likes = 0,
    this.views = 0,
    this.likedBy = const [],
    this.isApproved = false,
    this.status = 'pending',
  });

  factory ProjectIdeaModel.fromMap(Map<String, dynamic> map) {
    return ProjectIdeaModel(
      id: map['id'] ?? '',
      title: map['title'] ?? '',
      description: map['description'] ?? '',
      domain: map['domain'] ?? '',
      difficulty: map['difficulty'] ?? '',
      techStack: List<String>.from(map['techStack'] ?? []),
      problemStatement: map['problemStatement'] ?? '',
      expectedOutcomes: List<String>.from(map['expectedOutcomes'] ?? []),
      estimatedDuration: map['estimatedDuration'] ?? '',
      authorId: map['authorId'] ?? '',
      authorName: map['authorName'] ?? '',
      authorEmail: map['authorEmail'] ?? '',
      createdAt: DateTime.fromMillisecondsSinceEpoch(map['createdAt'] ?? 0),
      updatedAt: DateTime.fromMillisecondsSinceEpoch(map['updatedAt'] ?? 0),
      likes: map['likes'] ?? 0,
      views: map['views'] ?? 0,
      likedBy: List<String>.from(map['likedBy'] ?? []),
      isApproved: map['isApproved'] ?? false,
      status: map['status'] ?? 'pending',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'domain': domain,
      'difficulty': difficulty,
      'techStack': techStack,
      'problemStatement': problemStatement,
      'expectedOutcomes': expectedOutcomes,
      'estimatedDuration': estimatedDuration,
      'authorId': authorId,
      'authorName': authorName,
      'authorEmail': authorEmail,
      'createdAt': createdAt.millisecondsSinceEpoch,
      'updatedAt': updatedAt.millisecondsSinceEpoch,
      'likes': likes,
      'views': views,
      'likedBy': likedBy,
      'isApproved': isApproved,
      'status': status,
    };
  }

  ProjectIdeaModel copyWith({
    String? id,
    String? title,
    String? description,
    String? domain,
    String? difficulty,
    List<String>? techStack,
    String? problemStatement,
    List<String>? expectedOutcomes,
    String? estimatedDuration,
    String? authorId,
    String? authorName,
    String? authorEmail,
    DateTime? createdAt,
    DateTime? updatedAt,
    int? likes,
    int? views,
    List<String>? likedBy,
    bool? isApproved,
    String? status,
  }) {
    return ProjectIdeaModel(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      domain: domain ?? this.domain,
      difficulty: difficulty ?? this.difficulty,
      techStack: techStack ?? this.techStack,
      problemStatement: problemStatement ?? this.problemStatement,
      expectedOutcomes: expectedOutcomes ?? this.expectedOutcomes,
      estimatedDuration: estimatedDuration ?? this.estimatedDuration,
      authorId: authorId ?? this.authorId,
      authorName: authorName ?? this.authorName,
      authorEmail: authorEmail ?? this.authorEmail,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      likes: likes ?? this.likes,
      views: views ?? this.views,
      likedBy: likedBy ?? this.likedBy,
      isApproved: isApproved ?? this.isApproved,
      status: status ?? this.status,
    );
  }
}
