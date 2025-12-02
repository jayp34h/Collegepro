class SummaryModel {
  final String id;
  final String title;
  final String originalContent;
  final String summarizedContent;
  final String sourceType; // 'text', 'file'
  final String? fileName;
  final DateTime createdAt;
  final int wordCount;
  final List<String> keyPoints;

  SummaryModel({
    required this.id,
    required this.title,
    required this.originalContent,
    required this.summarizedContent,
    required this.sourceType,
    this.fileName,
    required this.createdAt,
    required this.wordCount,
    required this.keyPoints,
  });

  factory SummaryModel.fromJson(Map<String, dynamic> json) {
    return SummaryModel(
      id: json['id'] ?? '',
      title: json['title'] ?? '',
      originalContent: json['originalContent'] ?? '',
      summarizedContent: json['summarizedContent'] ?? '',
      sourceType: json['sourceType'] ?? 'text',
      fileName: json['fileName'],
      createdAt: DateTime.parse(json['createdAt'] ?? DateTime.now().toIso8601String()),
      wordCount: json['wordCount'] ?? 0,
      keyPoints: List<String>.from(json['keyPoints'] ?? []),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'originalContent': originalContent,
      'summarizedContent': summarizedContent,
      'sourceType': sourceType,
      'fileName': fileName,
      'createdAt': createdAt.toIso8601String(),
      'wordCount': wordCount,
      'keyPoints': keyPoints,
    };
  }

  SummaryModel copyWith({
    String? id,
    String? title,
    String? originalContent,
    String? summarizedContent,
    String? sourceType,
    String? fileName,
    DateTime? createdAt,
    int? wordCount,
    List<String>? keyPoints,
  }) {
    return SummaryModel(
      id: id ?? this.id,
      title: title ?? this.title,
      originalContent: originalContent ?? this.originalContent,
      summarizedContent: summarizedContent ?? this.summarizedContent,
      sourceType: sourceType ?? this.sourceType,
      fileName: fileName ?? this.fileName,
      createdAt: createdAt ?? this.createdAt,
      wordCount: wordCount ?? this.wordCount,
      keyPoints: keyPoints ?? this.keyPoints,
    );
  }
}
