class QuizQuestion {
  final String id;
  final String question;
  final List<String> options;
  final int correctAnswer;
  final String? explanation;
  final String subject;
  final String topic;
  final String difficulty;

  QuizQuestion({
    required this.id,
    required this.question,
    required this.options,
    required this.correctAnswer,
    this.explanation,
    required this.subject,
    required this.topic,
    required this.difficulty,
  });

  factory QuizQuestion.fromJson(Map<String, dynamic> json) {
    return QuizQuestion(
      id: json['id'] ?? '',
      question: json['question'] ?? '',
      options: List<String>.from(json['options'] ?? []),
      correctAnswer: json['correctAnswer'] ?? 0,
      explanation: json['explanation'],
      subject: json['subject'] ?? '',
      topic: json['topic'] ?? '',
      difficulty: json['difficulty'] ?? 'medium',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'question': question,
      'options': options,
      'correctAnswer': correctAnswer,
      'explanation': explanation,
      'subject': subject,
      'topic': topic,
      'difficulty': difficulty,
    };
  }
}

class QuizResult {
  final String id;
  final String userId;
  final String subject;
  final int totalQuestions;
  final int correctAnswers;
  final int score;
  final DateTime completedAt;
  final Map<String, dynamic> topicScores;

  QuizResult({
    required this.id,
    required this.userId,
    required this.subject,
    required this.totalQuestions,
    required this.correctAnswers,
    required this.score,
    required this.completedAt,
    required this.topicScores,
  });

  factory QuizResult.fromJson(Map<String, dynamic> json) {
    return QuizResult(
      id: json['id'] ?? '',
      userId: json['userId'] ?? '',
      subject: json['subject'] ?? '',
      totalQuestions: json['totalQuestions'] ?? 0,
      correctAnswers: json['correctAnswers'] ?? 0,
      score: json['score'] ?? 0,
      completedAt: DateTime.tryParse(json['completedAt'] ?? '') ?? DateTime.now(),
      topicScores: Map<String, dynamic>.from(json['topicScores'] ?? {}),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'subject': subject,
      'totalQuestions': totalQuestions,
      'correctAnswers': correctAnswers,
      'score': score,
      'completedAt': completedAt.toIso8601String(),
      'topicScores': topicScores,
    };
  }

  double get percentage => totalQuestions > 0 ? (correctAnswers / totalQuestions) * 100 : 0;
}

class QuizSubject {
  final String id;
  final String name;
  final String description;
  final String icon;
  final List<String> topics;
  final int totalQuestions;

  QuizSubject({
    required this.id,
    required this.name,
    required this.description,
    required this.icon,
    required this.topics,
    required this.totalQuestions,
  });

  static List<QuizSubject> getAllSubjects() {
    return [
      QuizSubject(
        id: 'programming',
        name: 'Programming Fundamentals',
        description: 'C / Python basics, Data types, loops, functions, pointers',
        icon: '💻',
        topics: ['Data Types', 'Loops', 'Functions', 'Pointers', 'Variables'],
        totalQuestions: 20,
      ),
      QuizSubject(
        id: 'dsa',
        name: 'Data Structures & Algorithms',
        description: 'Arrays, Linked lists, Stacks & Queues, Trees, Graphs, Sorting & Searching',
        icon: '🔗',
        topics: ['Arrays', 'Linked Lists', 'Stacks & Queues', 'Trees', 'Graphs', 'Sorting', 'Searching'],
        totalQuestions: 25,
      ),
      QuizSubject(
        id: 'dbms',
        name: 'Database Management Systems',
        description: 'SQL queries, Normalization, Transactions, Indexing',
        icon: '🗄️',
        topics: ['SQL Queries', 'Normalization', 'Transactions', 'Indexing', 'ACID Properties'],
        totalQuestions: 20,
      ),
      QuizSubject(
        id: 'os',
        name: 'Operating Systems',
        description: 'Processes, Threads, Scheduling, Memory management',
        icon: '⚙️',
        topics: ['Processes', 'Threads', 'Scheduling', 'Memory Management', 'File Systems'],
        totalQuestions: 22,
      ),
      QuizSubject(
        id: 'cn',
        name: 'Computer Networks',
        description: 'OSI model, TCP/IP, Routing, Protocols',
        icon: '🌐',
        topics: ['OSI Model', 'TCP/IP', 'Routing', 'Protocols', 'Network Security'],
        totalQuestions: 18,
      ),
      QuizSubject(
        id: 'se_oop',
        name: 'Software Engineering & OOP',
        description: 'SDLC, UML, Inheritance, Polymorphism',
        icon: '🏗️',
        topics: ['SDLC', 'UML', 'Inheritance', 'Polymorphism', 'Design Patterns'],
        totalQuestions: 20,
      ),
    ];
  }
}
