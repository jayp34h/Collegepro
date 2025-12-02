class ProjectModel {
  final String id;
  final String title;
  final String description;
  final String problemStatement;
  final List<String> techStack;
  final String domain;
  final String difficulty;
  final int industryRelevanceScore;
  final List<String> realWorldApplications;
  final List<String> possibleExtensions;
  final String careerRelevance;
  final DateTime createdAt;
  final DateTime updatedAt;
  final int upvotes;
  final int downvotes;
  final List<String> upvotedBy;
  final List<String> downvotedBy;
  final String? imageUrl;
  final List<String> tags;
  
  // GitHub specific fields
  final String? githubUrl;
  final int? stars;
  final bool isGitHubProject;
  final List<String>? categories;
  final String? estimatedDuration;
  final List<String>? technologies;

  ProjectModel({
    required this.id,
    required this.title,
    required this.description,
    this.problemStatement = '',
    this.techStack = const [],
    this.domain = '',
    this.difficulty = 'Beginner',
    this.industryRelevanceScore = 0,
    this.realWorldApplications = const [],
    this.possibleExtensions = const [],
    this.careerRelevance = '',
    required this.createdAt,
    required this.updatedAt,
    this.upvotes = 0,
    this.downvotes = 0,
    this.upvotedBy = const [],
    this.downvotedBy = const [],
    this.imageUrl,
    this.tags = const [],
    this.githubUrl,
    this.stars,
    this.isGitHubProject = false,
    this.categories,
    this.estimatedDuration,
    this.technologies,
  });

  factory ProjectModel.fromJson(Map<String, dynamic> json) {
    return ProjectModel(
      id: json['id'] ?? '',
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      problemStatement: json['problemStatement'] ?? '',
      techStack: List<String>.from(json['techStack'] ?? []),
      domain: json['domain'] ?? '',
      difficulty: json['difficulty'] ?? 'Beginner',
      industryRelevanceScore: json['industryRelevanceScore'] ?? 0,
      realWorldApplications: List<String>.from(json['realWorldApplications'] ?? []),
      possibleExtensions: List<String>.from(json['possibleExtensions'] ?? []),
      careerRelevance: json['careerRelevance'] ?? '',
      createdAt: DateTime.parse(json['createdAt'] ?? DateTime.now().toIso8601String()),
      updatedAt: DateTime.parse(json['updatedAt'] ?? DateTime.now().toIso8601String()),
      upvotes: json['upvotes'] ?? 0,
      downvotes: json['downvotes'] ?? 0,
      upvotedBy: List<String>.from(json['upvotedBy'] ?? []),
      downvotedBy: List<String>.from(json['downvotedBy'] ?? []),
      imageUrl: json['imageUrl'],
      tags: List<String>.from(json['tags'] ?? []),
      githubUrl: json['githubUrl'],
      stars: json['stars'],
      isGitHubProject: json['isGitHubProject'] ?? false,
      categories: json['categories'] != null ? List<String>.from(json['categories']) : null,
      estimatedDuration: json['estimatedDuration'],
      technologies: json['technologies'] != null ? List<String>.from(json['technologies']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'problemStatement': problemStatement,
      'techStack': techStack,
      'domain': domain,
      'difficulty': difficulty,
      'industryRelevanceScore': industryRelevanceScore,
      'realWorldApplications': realWorldApplications,
      'possibleExtensions': possibleExtensions,
      'careerRelevance': careerRelevance,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'upvotes': upvotes,
      'downvotes': downvotes,
      'upvotedBy': upvotedBy,
      'downvotedBy': downvotedBy,
      'imageUrl': imageUrl,
      'tags': tags,
      'githubUrl': githubUrl,
      'stars': stars,
      'isGitHubProject': isGitHubProject,
      'categories': categories,
      'estimatedDuration': estimatedDuration,
      'technologies': technologies,
    };
  }

  ProjectModel copyWith({
    String? id,
    String? title,
    String? description,
    String? problemStatement,
    List<String>? techStack,
    String? domain,
    String? difficulty,
    int? industryRelevanceScore,
    List<String>? realWorldApplications,
    List<String>? possibleExtensions,
    String? careerRelevance,
    DateTime? createdAt,
    DateTime? updatedAt,
    int? upvotes,
    int? downvotes,
    List<String>? upvotedBy,
    List<String>? downvotedBy,
    String? imageUrl,
    List<String>? tags,
    String? githubUrl,
    int? stars,
    bool? isGitHubProject,
    List<String>? categories,
    String? estimatedDuration,
    List<String>? technologies,
  }) {
    return ProjectModel(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      problemStatement: problemStatement ?? this.problemStatement,
      techStack: techStack ?? this.techStack,
      domain: domain ?? this.domain,
      difficulty: difficulty ?? this.difficulty,
      industryRelevanceScore: industryRelevanceScore ?? this.industryRelevanceScore,
      realWorldApplications: realWorldApplications ?? this.realWorldApplications,
      possibleExtensions: possibleExtensions ?? this.possibleExtensions,
      careerRelevance: careerRelevance ?? this.careerRelevance,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      upvotes: upvotes ?? this.upvotes,
      downvotes: downvotes ?? this.downvotes,
      upvotedBy: upvotedBy ?? this.upvotedBy,
      downvotedBy: downvotedBy ?? this.downvotedBy,
      imageUrl: imageUrl ?? this.imageUrl,
      tags: tags ?? this.tags,
      githubUrl: githubUrl ?? this.githubUrl,
      stars: stars ?? this.stars,
      isGitHubProject: isGitHubProject ?? this.isGitHubProject,
      categories: categories ?? this.categories,
      estimatedDuration: estimatedDuration ?? this.estimatedDuration,
      technologies: technologies ?? this.technologies,
    );
  }
}

enum ProjectDomain {
  ai('AI & Machine Learning'),
  web('Web Development'),
  mobile('Mobile Development'),
  cybersecurity('Cybersecurity'),
  cloud('Cloud Computing'),
  iot('Internet of Things'),
  blockchain('Blockchain'),
  gamedev('Game Development'),
  datascience('Data Science'),
  devops('DevOps');

  const ProjectDomain(this.displayName);
  final String displayName;
}

enum ProjectDifficulty {
  beginner('Beginner'),
  intermediate('Intermediate'),
  advanced('Advanced'),
  expert('Expert');

  const ProjectDifficulty(this.displayName);
  final String displayName;
}

enum CareerPath {
  fullstack('Full Stack Developer'),
  frontend('Frontend Developer'),
  backend('Backend Developer'),
  mobile('Mobile Developer'),
  datascientist('Data Scientist'),
  mlEngineer('ML Engineer'),
  devops('DevOps Engineer'),
  cybersecurity('Cybersecurity Specialist'),
  cloudArchitect('Cloud Architect'),
  productManager('Product Manager');

  const CareerPath(this.displayName);
  final String displayName;
}
