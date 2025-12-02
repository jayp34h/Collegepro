class InternshipModel {
  final String id;
  final String title;
  final String company;
  final String location;
  final String stipend;
  final String duration;
  final String applyLink;
  final String? logoUrl;
  final List<String> skills;
  final String? description;
  final String? type; // Full-time, Part-time, etc.
  final DateTime? startDate;
  final DateTime? lastDate;

  InternshipModel({
    required this.id,
    required this.title,
    required this.company,
    required this.location,
    required this.stipend,
    required this.duration,
    required this.applyLink,
    this.logoUrl,
    this.skills = const [],
    this.description,
    this.type,
    this.startDate,
    this.lastDate,
  });

  factory InternshipModel.fromJson(Map<String, dynamic> json) {
    return InternshipModel(
      id: json['id']?.toString() ?? '',
      title: json['title'] ?? json['profile_name'] ?? '',
      company: json['company_name'] ?? '',
      location: json['location_names']?.join(', ') ?? json['location'] ?? 'Remote',
      stipend: _parseStipend(json['stipend'] ?? json['salary']),
      duration: json['duration'] ?? '',
      applyLink: json['detail_url'] ?? json['apply_link'] ?? '',
      logoUrl: json['company_logo'] ?? json['logo_url'],
      skills: _parseSkills(json['skills_required'] ?? json['skills']),
      description: json['job_description'] ?? json['description'],
      type: json['job_type'] ?? json['type'],
      startDate: _parseDate(json['start_date']),
      lastDate: _parseDate(json['last_date'] ?? json['application_deadline']),
    );
  }

  static String _parseStipend(dynamic stipend) {
    if (stipend == null) return 'Not disclosed';
    
    if (stipend is Map) {
      final salary = stipend['salary'];
      final currency = stipend['currency'] ?? '₹';
      if (salary != null) {
        return '$currency $salary';
      }
    }
    
    if (stipend is String) {
      if (stipend.toLowerCase().contains('unpaid')) {
        return 'Unpaid';
      }
      return stipend;
    }
    
    return stipend.toString();
  }

  static List<String> _parseSkills(dynamic skills) {
    if (skills == null) return [];
    
    if (skills is List) {
      return skills.map((skill) => skill.toString()).toList();
    }
    
    if (skills is String) {
      return skills.split(',').map((s) => s.trim()).toList();
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
  String get displayStipend {
    if (stipend.isEmpty || stipend.toLowerCase() == 'not disclosed') {
      return 'Stipend not disclosed';
    }
    return stipend;
  }

  String get displayLocation {
    if (location.isEmpty) return 'Remote';
    return location;
  }

  String get displayDuration {
    if (duration.isEmpty) return 'Duration not specified';
    return duration;
  }

  bool get isValidApplyLink {
    return applyLink.isNotEmpty && 
           (applyLink.startsWith('http://') || applyLink.startsWith('https://'));
  }

  String get skillsText {
    if (skills.isEmpty) return 'No specific skills mentioned';
    return skills.take(3).join(', ') + (skills.length > 3 ? '...' : '');
  }

  bool get isRecent {
    if (lastDate == null) return true;
    return DateTime.now().isBefore(lastDate!);
  }

  String get urgencyLevel {
    if (lastDate == null) return 'normal';
    
    final daysLeft = lastDate!.difference(DateTime.now()).inDays;
    if (daysLeft <= 3) return 'urgent';
    if (daysLeft <= 7) return 'moderate';
    return 'normal';
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'company': company,
      'location': location,
      'stipend': stipend,
      'duration': duration,
      'applyLink': applyLink,
      'logoUrl': logoUrl,
      'skills': skills,
      'description': description,
      'type': type,
      'startDate': startDate?.toIso8601String(),
      'lastDate': lastDate?.toIso8601String(),
    };
  }
}
