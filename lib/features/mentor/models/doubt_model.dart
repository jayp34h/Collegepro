class DoubtModel {
  final String id;
  final String userId;
  final String title;
  final String description;
  final String category;
  final DateTime timestamp;
  final String status;
  final String? mentorResponse;
  final DateTime? responseTimestamp;
  final String mentorId;
  final String mentorName;

  DoubtModel({
    required this.id,
    required this.userId,
    required this.title,
    required this.description,
    required this.category,
    required this.timestamp,
    this.status = 'Pending',
    this.mentorResponse,
    this.responseTimestamp,
    required this.mentorId,
    required this.mentorName,
  });

  factory DoubtModel.fromJson(Map<String, dynamic> json) {
    return DoubtModel(
      id: json['id'] ?? '',
      userId: json['userId'] ?? '',
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      category: json['category'] ?? '',
      timestamp: DateTime.parse(json['timestamp']),
      status: json['status'] ?? 'Pending',
      mentorResponse: json['mentorResponse'],
      responseTimestamp: json['responseTimestamp'] != null 
          ? DateTime.parse(json['responseTimestamp'])
          : null,
      mentorId: json['mentorId'] ?? '',
      mentorName: json['mentorName'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'title': title,
      'description': description,
      'category': category,
      'timestamp': timestamp.toIso8601String(),
      'status': status,
      'mentorResponse': mentorResponse,
      'responseTimestamp': responseTimestamp?.toIso8601String(),
      'mentorId': mentorId,
      'mentorName': mentorName,
    };
  }

  DoubtModel copyWith({
    String? id,
    String? userId,
    String? title,
    String? description,
    String? category,
    DateTime? timestamp,
    String? status,
    String? mentorResponse,
    DateTime? responseTimestamp,
    String? mentorId,
    String? mentorName,
  }) {
    return DoubtModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      title: title ?? this.title,
      description: description ?? this.description,
      category: category ?? this.category,
      timestamp: timestamp ?? this.timestamp,
      status: status ?? this.status,
      mentorResponse: mentorResponse ?? this.mentorResponse,
      responseTimestamp: responseTimestamp ?? this.responseTimestamp,
      mentorId: mentorId ?? this.mentorId,
      mentorName: mentorName ?? this.mentorName,
    );
  }
}
