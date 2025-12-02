class Hackathon {
  final String id;
  final String title;
  final String description;
  final DateTime startDatetime;
  final DateTime endDatetime;
  final String location;
  final String url;
  final String? imageUrl;
  final String? organizerName;
  final List<String> tags;
  final bool isOnline;

  Hackathon({
    required this.id,
    required this.title,
    required this.description,
    required this.startDatetime,
    required this.endDatetime,
    required this.location,
    required this.url,
    this.imageUrl,
    this.organizerName,
    this.tags = const [],
    this.isOnline = false,
  });

  factory Hackathon.fromJson(Map<String, dynamic> json) {
    return Hackathon(
      id: json['id']?.toString() ?? '',
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      startDatetime: DateTime.tryParse(json['start_datetime'] ?? '') ?? DateTime.now(),
      endDatetime: DateTime.tryParse(json['end_datetime'] ?? '') ?? DateTime.now(),
      location: json['location'] ?? '',
      url: json['url'] ?? '',
      imageUrl: json['image_url'],
      organizerName: json['organizer_name'],
      tags: List<String>.from(json['tags'] ?? []),
      isOnline: json['is_online'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'start_datetime': startDatetime.toIso8601String(),
      'end_datetime': endDatetime.toIso8601String(),
      'location': location,
      'url': url,
      'image_url': imageUrl,
      'organizer_name': organizerName,
      'tags': tags,
      'is_online': isOnline,
    };
  }

  // Helper method to check if hackathon is in India
  bool get isInIndia {
    return location.toLowerCase().contains('india') ||
           location.toLowerCase().contains('mumbai') ||
           location.toLowerCase().contains('delhi') ||
           location.toLowerCase().contains('bangalore') ||
           location.toLowerCase().contains('chennai') ||
           location.toLowerCase().contains('hyderabad') ||
           location.toLowerCase().contains('pune') ||
           location.toLowerCase().contains('kolkata') ||
           location.toLowerCase().contains('ahmedabad') ||
           location.toLowerCase().contains('jaipur');
  }

  // Helper method to check if hackathon is upcoming
  bool get isUpcoming {
    return startDatetime.isAfter(DateTime.now());
  }

  // Helper method to get formatted date range
  String get formattedDateRange {
    final startDate = "${startDatetime.day}/${startDatetime.month}/${startDatetime.year}";
    final endDate = "${endDatetime.day}/${endDatetime.month}/${endDatetime.year}";
    
    if (startDate == endDate) {
      return startDate;
    }
    return "$startDate - $endDate";
  }

  // Helper method to get days remaining
  int get daysRemaining {
    final now = DateTime.now();
    if (startDatetime.isBefore(now)) return 0;
    return startDatetime.difference(now).inDays;
  }
}

class HackathonResponse {
  final List<Hackathon> hackathons;
  final int count;
  final String? next;
  final String? previous;

  HackathonResponse({
    required this.hackathons,
    required this.count,
    this.next,
    this.previous,
  });

  factory HackathonResponse.fromJson(Map<String, dynamic> json) {
    return HackathonResponse(
      hackathons: (json['results'] as List<dynamic>?)
          ?.map((item) => Hackathon.fromJson(item as Map<String, dynamic>))
          .toList() ?? [],
      count: json['count'] ?? 0,
      next: json['next'],
      previous: json['previous'],
    );
  }
}
