class InterviewQuestion {
  final String id;
  final String question;
  final String difficulty; // Easy, Medium, Hard
  final String category;
  final List<String> expectedKeywords;

  InterviewQuestion({
    required this.id,
    required this.question,
    required this.difficulty,
    required this.category,
    required this.expectedKeywords,
  });

  factory InterviewQuestion.fromJson(Map<String, dynamic> json) {
    return InterviewQuestion(
      id: json['id'] ?? '',
      question: json['question'] ?? '',
      difficulty: json['difficulty'] ?? 'Easy',
      category: json['category'] ?? '',
      expectedKeywords: List<String>.from(json['expectedKeywords'] ?? []),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'question': question,
      'difficulty': difficulty,
      'category': category,
      'expectedKeywords': expectedKeywords,
    };
  }
}

class InterviewAnswer {
  final String questionId;
  final String answer;
  final DateTime timestamp;
  final bool isVoiceInput;
  final double? confidenceScore;

  InterviewAnswer({
    required this.questionId,
    required this.answer,
    required this.timestamp,
    this.isVoiceInput = false,
    this.confidenceScore,
  });

  factory InterviewAnswer.fromJson(Map<String, dynamic> json) {
    return InterviewAnswer(
      questionId: json['questionId'] ?? '',
      answer: json['answer'] ?? '',
      timestamp: DateTime.parse(json['timestamp']),
      isVoiceInput: json['isVoiceInput'] ?? false,
      confidenceScore: json['confidenceScore']?.toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'questionId': questionId,
      'answer': answer,
      'timestamp': timestamp.toIso8601String(),
      'isVoiceInput': isVoiceInput,
      'confidenceScore': confidenceScore,
    };
  }
}

class InterviewFeedback {
  final String questionId;
  final double correctnessScore; // 0-10
  final double clarityScore; // 0-10
  final double confidenceScore; // 0-10
  final double fluencyScore; // 0-10
  final double overallScore; // 0-10
  final String feedback;
  final List<String> strengths;
  final List<String> weaknesses;
  final List<String> improvementTips;

  InterviewFeedback({
    required this.questionId,
    required this.correctnessScore,
    required this.clarityScore,
    required this.confidenceScore,
    required this.fluencyScore,
    required this.overallScore,
    required this.feedback,
    required this.strengths,
    required this.weaknesses,
    required this.improvementTips,
  });

  factory InterviewFeedback.fromJson(Map<String, dynamic> json) {
    return InterviewFeedback(
      questionId: json['questionId'] ?? '',
      correctnessScore: (json['correctnessScore'] ?? 0).toDouble(),
      clarityScore: (json['clarityScore'] ?? 0).toDouble(),
      confidenceScore: (json['confidenceScore'] ?? 0).toDouble(),
      fluencyScore: (json['fluencyScore'] ?? 0).toDouble(),
      overallScore: (json['overallScore'] ?? 0).toDouble(),
      feedback: json['feedback'] ?? '',
      strengths: List<String>.from(json['strengths'] ?? []),
      weaknesses: List<String>.from(json['weaknesses'] ?? []),
      improvementTips: List<String>.from(json['improvementTips'] ?? []),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'questionId': questionId,
      'correctnessScore': correctnessScore,
      'clarityScore': clarityScore,
      'confidenceScore': confidenceScore,
      'fluencyScore': fluencyScore,
      'overallScore': overallScore,
      'feedback': feedback,
      'strengths': strengths,
      'weaknesses': weaknesses,
      'improvementTips': improvementTips,
    };
  }
}

class InterviewSession {
  final String id;
  final String jobRole;
  final DateTime startTime;
  final DateTime? endTime;
  final List<InterviewQuestion> questions;
  final List<InterviewAnswer> answers;
  final List<InterviewFeedback> feedbacks;
  final double? averageScore;
  final InterviewStatus status;

  InterviewSession({
    required this.id,
    required this.jobRole,
    required this.startTime,
    this.endTime,
    required this.questions,
    required this.answers,
    required this.feedbacks,
    this.averageScore,
    required this.status,
  });

  factory InterviewSession.fromJson(Map<String, dynamic> json) {
    return InterviewSession(
      id: json['id'] ?? '',
      jobRole: json['jobRole'] ?? '',
      startTime: DateTime.parse(json['startTime']),
      endTime: json['endTime'] != null ? DateTime.parse(json['endTime']) : null,
      questions: (json['questions'] as List? ?? [])
          .map((q) => InterviewQuestion.fromJson(q))
          .toList(),
      answers: (json['answers'] as List? ?? [])
          .map((a) => InterviewAnswer.fromJson(a))
          .toList(),
      feedbacks: (json['feedbacks'] as List? ?? [])
          .map((f) => InterviewFeedback.fromJson(f))
          .toList(),
      averageScore: json['averageScore']?.toDouble(),
      status: InterviewStatus.values.firstWhere(
        (s) => s.name == json['status'],
        orElse: () => InterviewStatus.notStarted,
      ),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'jobRole': jobRole,
      'startTime': startTime.toIso8601String(),
      'endTime': endTime?.toIso8601String(),
      'questions': questions.map((q) => q.toJson()).toList(),
      'answers': answers.map((a) => a.toJson()).toList(),
      'feedbacks': feedbacks.map((f) => f.toJson()).toList(),
      'averageScore': averageScore,
      'status': status.name,
    };
  }
}

enum InterviewStatus {
  notStarted,
  inProgress,
  completed,
  paused,
}

enum InputMode {
  text,
  voice,
}

class JobRole {
  final String id;
  final String title;
  final String description;
  final List<String> skills;
  final String level; // Entry, Mid, Senior

  JobRole({
    required this.id,
    required this.title,
    required this.description,
    required this.skills,
    required this.level,
  });

  factory JobRole.fromJson(Map<String, dynamic> json) {
    return JobRole(
      id: json['id'] ?? '',
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      skills: List<String>.from(json['skills'] ?? []),
      level: json['level'] ?? 'Entry',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'skills': skills,
      'level': level,
    };
  }
}
