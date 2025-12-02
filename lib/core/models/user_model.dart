class UserModel {
  final String id;
  final String email;
  final String displayName;
  final String? photoUrl;
  final List<String> skills;
  final String careerGoal;
  final List<String> savedProjectIds;
  final List<String> completedProjectIds;
  final DateTime createdAt;
  final DateTime updatedAt;
  final Map<String, dynamic> preferences;
  final bool isEmailVerified;
  final DateTime? emailVerifiedAt;
  final String? phoneNumber;
  final String? institution;
  final String? course;
  final String? yearOfStudy;
  final String registrationMethod; // 'email', 'google', 'apple'
  final DateTime? lastLoginAt;
  final bool isProfileComplete;

  UserModel({
    required this.id,
    required this.email,
    required this.displayName,
    this.photoUrl,
    this.skills = const [],
    this.careerGoal = '',
    this.savedProjectIds = const [],
    this.completedProjectIds = const [],
    required this.createdAt,
    required this.updatedAt,
    this.preferences = const {},
    this.isEmailVerified = false,
    this.emailVerifiedAt,
    this.phoneNumber,
    this.institution,
    this.course,
    this.yearOfStudy,
    this.registrationMethod = 'email',
    this.lastLoginAt,
    this.isProfileComplete = false,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] ?? '',
      email: json['email'] ?? '',
      displayName: json['displayName'] ?? '',
      photoUrl: json['photoUrl'],
      skills: List<String>.from(json['skills'] ?? []),
      careerGoal: json['careerGoal'] ?? '',
      savedProjectIds: List<String>.from(json['savedProjectIds'] ?? []),
      completedProjectIds: List<String>.from(json['completedProjectIds'] ?? []),
      createdAt: DateTime.parse(json['createdAt'] ?? DateTime.now().toIso8601String()),
      updatedAt: DateTime.parse(json['updatedAt'] ?? DateTime.now().toIso8601String()),
      preferences: Map<String, dynamic>.from(json['preferences'] ?? {}),
      isEmailVerified: json['isEmailVerified'] ?? false,
      emailVerifiedAt: json['emailVerifiedAt'] != null 
          ? DateTime.parse(json['emailVerifiedAt']) 
          : null,
      phoneNumber: json['phoneNumber'],
      institution: json['institution'],
      course: json['course'],
      yearOfStudy: json['yearOfStudy'],
      registrationMethod: json['registrationMethod'] ?? 'email',
      lastLoginAt: json['lastLoginAt'] != null 
          ? DateTime.parse(json['lastLoginAt']) 
          : null,
      isProfileComplete: json['isProfileComplete'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'displayName': displayName,
      'photoUrl': photoUrl,
      'skills': skills,
      'careerGoal': careerGoal,
      'savedProjectIds': savedProjectIds,
      'completedProjectIds': completedProjectIds,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'preferences': preferences,
      'isEmailVerified': isEmailVerified,
      'emailVerifiedAt': emailVerifiedAt?.toIso8601String(),
      'phoneNumber': phoneNumber,
      'institution': institution,
      'course': course,
      'yearOfStudy': yearOfStudy,
      'registrationMethod': registrationMethod,
      'lastLoginAt': lastLoginAt?.toIso8601String(),
      'isProfileComplete': isProfileComplete,
    };
  }

  UserModel copyWith({
    String? id,
    String? email,
    String? displayName,
    String? photoUrl,
    List<String>? skills,
    String? careerGoal,
    List<String>? savedProjectIds,
    List<String>? completedProjectIds,
    DateTime? createdAt,
    DateTime? updatedAt,
    Map<String, dynamic>? preferences,
    bool? isEmailVerified,
    DateTime? emailVerifiedAt,
    String? phoneNumber,
    String? institution,
    String? course,
    String? yearOfStudy,
    String? registrationMethod,
    DateTime? lastLoginAt,
    bool? isProfileComplete,
  }) {
    return UserModel(
      id: id ?? this.id,
      email: email ?? this.email,
      displayName: displayName ?? this.displayName,
      photoUrl: photoUrl ?? this.photoUrl,
      skills: skills ?? this.skills,
      careerGoal: careerGoal ?? this.careerGoal,
      savedProjectIds: savedProjectIds ?? this.savedProjectIds,
      completedProjectIds: completedProjectIds ?? this.completedProjectIds,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      preferences: preferences ?? this.preferences,
      isEmailVerified: isEmailVerified ?? this.isEmailVerified,
      emailVerifiedAt: emailVerifiedAt ?? this.emailVerifiedAt,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      institution: institution ?? this.institution,
      course: course ?? this.course,
      yearOfStudy: yearOfStudy ?? this.yearOfStudy,
      registrationMethod: registrationMethod ?? this.registrationMethod,
      lastLoginAt: lastLoginAt ?? this.lastLoginAt,
      isProfileComplete: isProfileComplete ?? this.isProfileComplete,
    );
  }
}
