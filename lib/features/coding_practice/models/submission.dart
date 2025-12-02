import 'package:hive/hive.dart';

part 'submission.g.dart';

@HiveType(typeId: 0)
class Submission extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String studentId;

  @HiveField(2)
  final String questionId;

  @HiveField(3)
  final String code;

  @HiveField(4)
  final String language;

  @HiveField(5)
  final int languageId;

  @HiveField(6)
  final String executionResult;

  @HiveField(7)
  final String status;

  @HiveField(8)
  final int score;

  @HiveField(9)
  final String feedback;

  @HiveField(10)
  final String suggestion;

  @HiveField(11)
  final DateTime timestamp;

  @HiveField(12)
  final bool isCorrect;

  @HiveField(13)
  final double executionTime;

  Submission({
    required this.id,
    required this.studentId,
    required this.questionId,
    required this.code,
    required this.language,
    required this.languageId,
    required this.executionResult,
    required this.status,
    required this.score,
    required this.feedback,
    required this.suggestion,
    required this.timestamp,
    required this.isCorrect,
    required this.executionTime,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'studentId': studentId,
      'questionId': questionId,
      'code': code,
      'language': language,
      'languageId': languageId,
      'executionResult': executionResult,
      'status': status,
      'score': score,
      'feedback': feedback,
      'suggestion': suggestion,
      'timestamp': timestamp.toIso8601String(),
      'isCorrect': isCorrect,
      'executionTime': executionTime,
    };
  }

  factory Submission.fromJson(Map<String, dynamic> json) {
    return Submission(
      id: json['id'],
      studentId: json['studentId'],
      questionId: json['questionId'],
      code: json['code'],
      language: json['language'],
      languageId: json['languageId'],
      executionResult: json['executionResult'],
      status: json['status'],
      score: json['score'],
      feedback: json['feedback'],
      suggestion: json['suggestion'],
      timestamp: DateTime.parse(json['timestamp']),
      isCorrect: json['isCorrect'],
      executionTime: json['executionTime'],
    );
  }
}
