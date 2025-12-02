class MentorModel {
  final String id;
  final String name;
  final String title;
  final String description;
  final String expertise;
  final String avatarColor;
  final bool isOnline;
  final double rating;
  final int responseTime; // in hours
  final List<String> specializations;

  MentorModel({
    required this.id,
    required this.name,
    required this.title,
    required this.description,
    required this.expertise,
    required this.avatarColor,
    required this.isOnline,
    required this.rating,
    required this.responseTime,
    required this.specializations,
  });

  // Static list of mentors
  static List<MentorModel> getMentors() {
    return [
      MentorModel(
        id: 'mentor_1',
        name: 'Jagdish Bhawar',
        title: 'CSE Student 2026',
        description: 'Passionate about helping students with career guidance and technical skills',
        expertise: 'Full Stack Development, Career Guidance',
        avatarColor: '6366F1',
        isOnline: true,
        rating: 4.8,
        responseTime: 2,
        specializations: ['Career Guidance', 'Technical Skills', 'Project Ideas', 'Interview Preparation'],
      ),
      MentorModel(
        id: 'mentor_2',
        name: 'Priya Sharma',
        title: 'Software Engineer at Google',
        description: 'Experienced software engineer specializing in algorithms and system design',
        expertise: 'System Design, Algorithms, Data Structures',
        avatarColor: 'EC4899',
        isOnline: true,
        rating: 4.9,
        responseTime: 1,
        specializations: ['Technical Skills', 'Interview Preparation', 'Industry Trends', 'Academic Advice'],
      ),
      MentorModel(
        id: 'mentor_3',
        name: 'Rahul Kolte',
        title: 'Senior Software Developer at Genpact',
        description: 'Senior developer with 5+ years experience in cloud technologies and mentoring',
        expertise: 'Cloud Computing, DevOps, Mentoring',
        avatarColor: '10B981',
        isOnline: true,
        rating: 4.7,
        responseTime: 4,
        specializations: ['Technical Skills', 'Industry Trends', 'Internship', 'Job Search'],
      ),
      MentorModel(
        id: 'mentor_4',
        name: 'Ananya Patel',
        title: 'Data Scientist at Amazon',
        description: 'Passionate data scientist with expertise in machine learning and AI. Loves helping students understand complex algorithms',
        expertise: 'Machine Learning, Data Science, AI',
        avatarColor: 'F59E0B',
        isOnline: true,
        rating: 4.8,
        responseTime: 3,
        specializations: ['Machine Learning', 'Data Science', 'Research', 'Academic Projects'],
      ),
      MentorModel(
        id: 'mentor_5',
        name: 'Arjun Singh',
        title: 'Mobile App Developer at Flipkart',
        description: 'Mobile app development expert with 6+ years in Android and iOS. Mentor for app development and startup guidance',
        expertise: 'Mobile Development, Flutter, React Native',
        avatarColor: '8B5CF6',
        isOnline: true,
        rating: 4.6,
        responseTime: 2,
        specializations: ['Mobile Development', 'App Design', 'Startup Guidance', 'Technical Skills'],
      ),
    ];
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'title': title,
      'description': description,
      'expertise': expertise,
      'avatarColor': avatarColor,
      'isOnline': isOnline,
      'rating': rating,
      'responseTime': responseTime,
      'specializations': specializations,
    };
  }

  factory MentorModel.fromJson(Map<String, dynamic> json) {
    return MentorModel(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      expertise: json['expertise'] ?? '',
      avatarColor: json['avatarColor'] ?? '6366F1',
      isOnline: json['isOnline'] ?? false,
      rating: (json['rating'] ?? 0.0).toDouble(),
      responseTime: json['responseTime'] ?? 24,
      specializations: List<String>.from(json['specializations'] ?? []),
    );
  }
}
