class CodingQuestion {
  final String id;
  final String title;
  final String description;
  final String difficulty;
  final List<String> tags;
  final String sampleInput;
  final String expectedOutput;
  final String solutionCode;
  final String solutionExplanation;
  final int timeLimit; // in seconds
  final int memoryLimit; // in KB

  CodingQuestion({
    required this.id,
    required this.title,
    required this.description,
    required this.difficulty,
    required this.tags,
    required this.sampleInput,
    required this.expectedOutput,
    required this.solutionCode,
    required this.solutionExplanation,
    this.timeLimit = 5,
    this.memoryLimit = 128000,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'difficulty': difficulty,
      'tags': tags,
      'sampleInput': sampleInput,
      'expectedOutput': expectedOutput,
      'solutionCode': solutionCode,
      'solutionExplanation': solutionExplanation,
      'timeLimit': timeLimit,
      'memoryLimit': memoryLimit,
    };
  }

  factory CodingQuestion.fromJson(Map<String, dynamic> json) {
    return CodingQuestion(
      id: json['id'],
      title: json['title'],
      description: json['description'],
      difficulty: json['difficulty'],
      tags: List<String>.from(json['tags']),
      sampleInput: json['sampleInput'],
      expectedOutput: json['expectedOutput'],
      solutionCode: json['solutionCode'],
      solutionExplanation: json['solutionExplanation'],
      timeLimit: json['timeLimit'] ?? 5,
      memoryLimit: json['memoryLimit'] ?? 128000,
    );
  }
}
