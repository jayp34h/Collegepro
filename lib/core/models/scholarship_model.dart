import 'package:cloud_firestore/cloud_firestore.dart';

class ScholarshipModel {
  final String id;
  final String title;
  final String organizer;
  final String description;
  final String amount;
  final String deadline;
  final String link;
  final String status;
  final List<String> eligibility;
  final List<String> tags;
  final DateTime? createdAt;

  ScholarshipModel({
    required this.id,
    required this.title,
    required this.organizer,
    required this.description,
    required this.amount,
    required this.deadline,
    required this.link,
    this.status = 'Active',
    this.eligibility = const [],
    this.tags = const [],
    this.createdAt,
  });

  factory ScholarshipModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return ScholarshipModel(
      id: doc.id,
      title: data['title'] ?? '',
      organizer: data['organizer'] ?? '',
      description: data['description'] ?? '',
      amount: data['amount'] ?? '',
      deadline: data['deadline'] ?? '',
      link: data['link'] ?? '',
      status: data['status'] ?? 'Active',
      eligibility: List<String>.from(data['eligibility'] ?? []),
      tags: List<String>.from(data['tags'] ?? []),
      createdAt: data['created_at'] != null 
          ? (data['created_at'] as Timestamp).toDate()
          : null,
    );
  }

  factory ScholarshipModel.fromMap(Map<String, dynamic> data) {
    return ScholarshipModel(
      id: data['id'] ?? '',
      title: data['title'] ?? '',
      organizer: data['organizer'] ?? '',
      description: data['description'] ?? '',
      amount: data['amount'] ?? '',
      deadline: data['deadline'] ?? '',
      link: data['link'] ?? '',
      status: data['status'] ?? 'Active',
      eligibility: List<String>.from(data['eligibility'] ?? []),
      tags: List<String>.from(data['tags'] ?? []),
      createdAt: data['created_at'] != null 
          ? DateTime.parse(data['created_at'])
          : null,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'organizer': organizer,
      'description': description,
      'amount': amount,
      'deadline': deadline,
      'link': link,
      'status': status,
      'eligibility': eligibility,
      'tags': tags,
      'created_at': createdAt?.toIso8601String(),
    };
  }

  // Helper methods for UI display
  String get displayTitle => title.isNotEmpty ? title : 'Scholarship Opportunity';
  
  String get displayDeadline {
    if (deadline.isEmpty) return 'No deadline specified';
    return deadline;
  }

  String get displayAmount {
    if (amount.isEmpty) return 'Amount varies';
    return amount;
  }

  bool get hasValidLink => link.isNotEmpty && link.startsWith('http');
  
  bool get isExpired => status.toLowerCase() == 'expired';
  bool get isActive => status.toLowerCase() == 'active';
  
  String get statusColor {
    switch (status.toLowerCase()) {
      case 'active':
        return 'green';
      case 'expired':
        return 'red';
      case 'upcoming':
        return 'blue';
      default:
        return 'orange';
    }
  }

  // Generate category based on tags or title keywords
  String get category {
    if (tags.isNotEmpty) return tags.first;
    
    final titleLower = title.toLowerCase();
    if (titleLower.contains('merit') || titleLower.contains('academic')) return 'Merit Based';
    if (titleLower.contains('minority')) return 'Minority';
    if (titleLower.contains('sc') || titleLower.contains('st') || titleLower.contains('obc')) return 'Reserved Category';
    if (titleLower.contains('girl') || titleLower.contains('women')) return 'Women';
    if (titleLower.contains('research')) return 'Research';
    if (titleLower.contains('engineering')) return 'Engineering';
    return 'General';
  }

  String get eligibilityText {
    if (eligibility.isEmpty) return 'Check official website for eligibility';
    return eligibility.take(3).join(', ') + (eligibility.length > 3 ? '...' : '');
  }

  String get tagsText {
    if (tags.isEmpty) return 'General';
    return tags.take(3).join(', ') + (tags.length > 3 ? '...' : '');
  }
}
