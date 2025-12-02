import 'package:hive/hive.dart';

part 'leaderboard_entry.g.dart';

@HiveType(typeId: 1)
class LeaderboardEntry extends HiveObject {
  @HiveField(0)
  final String studentId;

  @HiveField(1)
  final String studentName;

  @HiveField(2)
  final int totalScore;

  @HiveField(3)
  final int problemsSolved;

  @HiveField(4)
  final String title;

  @HiveField(5)
  final String funnyNote;

  @HiveField(6)
  final DateTime lastActivity;

  @HiveField(7)
  final Map<String, int> languageStats;

  @HiveField(8)
  final double averageScore;

  LeaderboardEntry({
    required this.studentId,
    required this.studentName,
    required this.totalScore,
    required this.problemsSolved,
    required this.title,
    required this.funnyNote,
    required this.lastActivity,
    required this.languageStats,
    required this.averageScore,
  });

  static String getFunnyTitle(int score, int problemsSolved) {
    if (score >= 90 && problemsSolved >= 20) {
      return "Code Wizard 🧙‍♂️";
    } else if (score >= 80 && problemsSolved >= 15) {
      return "Bug Slayer 🐞";
    } else if (score >= 70 && problemsSolved >= 10) {
      return "Syntax Samurai ⚔️";
    } else if (score >= 60 && problemsSolved >= 8) {
      return "Indentation King 👑";
    } else if (score >= 50 && problemsSolved >= 5) {
      return "Loop Master 🔄";
    } else if (problemsSolved >= 3) {
      return "Code Rookie 🌱";
    } else {
      return "Future Coder 🚀";
    }
  }

  static String getFunnyNote(String name, int score, int problemsSolved) {
    final notes = [
      "$name is coding faster than my WiFi disconnects 😜",
      "$name just debugged their way to the top 🚀",
      "$name's code is cleaner than my room (which isn't saying much) 🧹",
      "$name found more bugs than a pest control service 🐛",
      "$name's loops are tighter than my jeans after Diwali 🍰",
      "$name writes code smoother than butter on hot paratha 🧈",
      "$name's functions are more reliable than Indian trains 🚂",
      "$name handles exceptions better than I handle Monday mornings ☕",
    ];
    return notes[score % notes.length];
  }

  Map<String, dynamic> toJson() {
    return {
      'studentId': studentId,
      'studentName': studentName,
      'totalScore': totalScore,
      'problemsSolved': problemsSolved,
      'title': title,
      'funnyNote': funnyNote,
      'lastActivity': lastActivity.toIso8601String(),
      'languageStats': languageStats,
      'averageScore': averageScore,
    };
  }

  factory LeaderboardEntry.fromJson(Map<String, dynamic> json) {
    return LeaderboardEntry(
      studentId: json['studentId'],
      studentName: json['studentName'],
      totalScore: json['totalScore'],
      problemsSolved: json['problemsSolved'],
      title: json['title'],
      funnyNote: json['funnyNote'],
      lastActivity: DateTime.parse(json['lastActivity']),
      languageStats: Map<String, int>.from(json['languageStats']),
      averageScore: json['averageScore'],
    );
  }
}
