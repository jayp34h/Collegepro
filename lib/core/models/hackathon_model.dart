class HackathonModel {
  final String id;
  final String title;
  final String organizer;
  final String description;
  final String prize;
  final String registrationUrl;
  final DateTime? startDate;
  final DateTime? endDate;
  final DateTime? registrationEndDate;
  final List<String> tags;
  final String difficulty;
  final String? location;
  final bool isOnline;
  final String? logoUrl;
  final int? participantCount;

  HackathonModel({
    required this.id,
    required this.title,
    required this.organizer,
    required this.description,
    required this.prize,
    required this.registrationUrl,
    this.startDate,
    this.endDate,
    this.registrationEndDate,
    this.tags = const [],
    this.difficulty = 'All Levels',
    this.location,
    this.isOnline = false,
    this.logoUrl,
    this.participantCount,
  });

  factory HackathonModel.fromJson(Map<String, dynamic> json) {
    return HackathonModel(
      id: json['id']?.toString() ?? json['event_id']?.toString() ?? '',
      title: json['name'] ?? json['title'] ?? json['challenge_name'] ?? '',
      organizer: json['organizer'] ?? json['organization'] ?? json['host'] ?? 'HackerEarth',
      description: json['description'] ?? json['problem_statement'] ?? json['summary'] ?? '',
      prize: _parsePrize(json['prize'] ?? json['total_prize'] ?? json['prize_money']),
      registrationUrl: json['url'] ?? json['registration_url'] ?? json['event_url'] ?? '',
      startDate: _parseDate(json['start_date'] ?? json['start_datetime'] ?? json['start_time']),
      endDate: _parseDate(json['end_date'] ?? json['end_datetime'] ?? json['end_time']),
      registrationEndDate: _parseDate(json['registration_end_date'] ?? json['registration_deadline']),
      tags: _parseTags(json['tags'] ?? json['skills'] ?? json['technologies']),
      difficulty: json['difficulty'] ?? json['level'] ?? 'All Levels',
      location: json['location'] ?? json['venue'] ?? json['city'],
      isOnline: json['is_online'] ?? json['online'] ?? (json['location']?.toString().toLowerCase().contains('online') ?? false),
      logoUrl: json['logo'] ?? json['image_url'],
      participantCount: json['participant_count'],
    );
  }

  static String _parsePrize(dynamic prize) {
    if (prize == null) return 'Recognition';
    
    if (prize is Map) {
      final amount = prize['amount'] ?? prize['value'];
      final currency = prize['currency'] ?? '\$';
      if (amount != null) {
        return '$currency$amount';
      }
    }
    
    if (prize is String) {
      if (prize.isEmpty) return 'Recognition';
      return prize;
    }
    
    return prize.toString();
  }

  static List<String> _parseTags(dynamic tags) {
    if (tags == null) return [];
    
    if (tags is List) {
      return tags.map((tag) => tag.toString()).toList();
    }
    
    if (tags is String) {
      return tags.split(',').map((s) => s.trim()).toList();
    }
    
    return [];
  }

  static DateTime? _parseDate(dynamic date) {
    if (date == null) return null;
    
    try {
      if (date is String) {
        return DateTime.parse(date);
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  // Helper getters for UI
  String get displayPrize {
    if (prize.isEmpty || prize.toLowerCase() == 'recognition') {
      return 'Recognition & Certificates';
    }
    return prize;
  }

  String get displayLocation {
    if (isOnline) return 'Online';
    return location ?? 'Location TBD';
  }

  String get displayDifficulty {
    return difficulty;
  }

  bool get isRegistrationOpen {
    if (registrationEndDate == null) return true;
    return DateTime.now().isBefore(registrationEndDate!);
  }

  bool get isUpcoming {
    if (startDate == null) return true;
    return DateTime.now().isBefore(startDate!);
  }

  bool get isActive {
    if (startDate == null || endDate == null) return false;
    final now = DateTime.now();
    return now.isAfter(startDate!) && now.isBefore(endDate!);
  }

  String get status {
    if (!isRegistrationOpen) return 'Registration Closed';
    if (isActive) return 'Active';
    if (isUpcoming) return 'Upcoming';
    return 'Ended';
  }

  String get timeRemaining {
    if (registrationEndDate == null) return '';
    
    final now = DateTime.now();
    if (now.isAfter(registrationEndDate!)) return 'Registration Closed';
    
    final difference = registrationEndDate!.difference(now);
    if (difference.inDays > 0) {
      return '${difference.inDays} days left';
    } else if (difference.inHours > 0) {
      return '${difference.inHours} hours left';
    } else {
      return 'Ending soon';
    }
  }

  String get tagsText {
    if (tags.isEmpty) return 'General';
    return tags.take(3).join(', ') + (tags.length > 3 ? '...' : '');
  }

  bool get isValidUrl {
    return registrationUrl.isNotEmpty && 
           (registrationUrl.startsWith('http://') || registrationUrl.startsWith('https://'));
  }

  // Check if hackathon is in 2025
  bool get is2025 {
    if (startDate == null) return false;
    return startDate!.year == 2025;
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'organizer': organizer,
      'description': description,
      'prize': prize,
      'registrationUrl': registrationUrl,
      'startDate': startDate?.toIso8601String(),
      'endDate': endDate?.toIso8601String(),
      'registrationEndDate': registrationEndDate?.toIso8601String(),
      'tags': tags,
      'difficulty': difficulty,
      'location': location,
      'isOnline': isOnline,
      'logoUrl': logoUrl,
      'participantCount': participantCount,
    };
  }

  /// Create HackathonModel from Firestore document
  factory HackathonModel.fromFirestore(Map<String, dynamic> doc) {
    return HackathonModel(
      id: doc['id'] ?? '',
      title: doc['title'] ?? '',
      organizer: doc['organizer'] ?? '',
      description: doc['description'] ?? '',
      prize: doc['prize'] ?? 'Recognition',
      registrationUrl: doc['registrationUrl'] ?? '',
      startDate: doc['startDate'] != null ? DateTime.parse(doc['startDate']) : null,
      endDate: doc['endDate'] != null ? DateTime.parse(doc['endDate']) : null,
      registrationEndDate: doc['registrationEndDate'] != null ? DateTime.parse(doc['registrationEndDate']) : null,
      tags: List<String>.from(doc['tags'] ?? []),
      difficulty: doc['difficulty'] ?? 'All Levels',
      location: doc['location'],
      isOnline: doc['isOnline'] ?? false,
      logoUrl: doc['logoUrl'],
      participantCount: doc['participantCount'],
    );
  }

  /// Convert to Firestore document format
  Map<String, dynamic> toFirestore() {
    return {
      'id': id,
      'title': title,
      'organizer': organizer,
      'description': description,
      'prize': prize,
      'registrationUrl': registrationUrl,
      'startDate': startDate?.toIso8601String(),
      'endDate': endDate?.toIso8601String(),
      'registrationEndDate': registrationEndDate?.toIso8601String(),
      'tags': tags,
      'difficulty': difficulty,
      'location': location,
      'isOnline': isOnline,
      'logoUrl': logoUrl,
      'participantCount': participantCount,
      'created_at': DateTime.now().toIso8601String(),
      'updated_at': DateTime.now().toIso8601String(),
    };
  }
}
