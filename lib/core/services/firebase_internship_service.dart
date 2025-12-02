import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import '../models/internship_model.dart';

class FirebaseInternshipService {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  static const String _collection = 'internships';

  /// Add a new internship to Firebase
  static Future<bool> addInternship(InternshipModel internship) async {
    try {
      await _firestore.collection(_collection).doc(internship.id).set({
        'id': internship.id,
        'title': internship.title,
        'company': internship.company,
        'location': internship.location,
        'stipend': internship.stipend,
        'duration': internship.duration,
        'applyLink': internship.applyLink,
        'skills': internship.skills,
        'description': internship.description,
        'createdAt': FieldValue.serverTimestamp(),
        'isActive': true,
      });
      
      if (kDebugMode) print('✅ Internship added successfully: ${internship.title}');
      return true;
    } catch (e) {
      if (kDebugMode) print('❌ Error adding internship: $e');
      return false;
    }
  }

  /// Get all internships from Firebase
  static Future<List<InternshipModel>> getAllInternships() async {
    try {
      final querySnapshot = await _firestore
          .collection(_collection)
          .where('isActive', isEqualTo: true)
          .orderBy('createdAt', descending: true)
          .get();

      if (kDebugMode) print('🔍 Firebase query returned ${querySnapshot.docs.length} documents');

      final internships = querySnapshot.docs.map((doc) {
        final data = doc.data();
        if (kDebugMode) print('📄 Processing document: ${doc.id} with data: ${data.keys}');
        
        return InternshipModel(
          id: data['id'] ?? doc.id,
          title: data['title'] ?? '',
          company: data['company'] ?? '',
          location: data['location'] ?? '',
          stipend: data['stipend'] ?? '',
          duration: data['duration'] ?? '',
          applyLink: data['applyLink'] ?? '',
          skills: List<String>.from(data['skills'] ?? []),
          description: data['description'] ?? '',
        );
      }).toList();

      if (kDebugMode) print('✅ Loaded ${internships.length} internships from Firebase');
      return internships;
    } catch (e) {
      return [];
    }
  }

  /// Get real-time stream of internships
  static Stream<List<InternshipModel>> getInternshipsStream() {
    return _firestore
        .collection(_collection)
        .where('isActive', isEqualTo: true)
        .orderBy('createdAt', descending: true)
        .snapshots()
      .map((snapshot) {
      if (kDebugMode) print('📡 Real-time update: ${snapshot.docs.length} internships');
      
      return snapshot.docs.map((doc) {
        final data = doc.data();
        return InternshipModel(
          id: data['id'] ?? doc.id,
          title: data['title'] ?? '',
          company: data['company'] ?? '',
          location: data['location'] ?? '',
          stipend: data['stipend'] ?? '',
          duration: data['duration'] ?? '',
          applyLink: data['applyLink'] ?? '',
          skills: List<String>.from(data['skills'] ?? []),
          description: data['description'] ?? '',
        );
      }).toList();
    });
  }

  /// Search internships by keywords
  static Future<List<InternshipModel>> searchInternships(String query) async {
    try {
      final querySnapshot = await _firestore
          .collection(_collection)
          .where('isActive', isEqualTo: true)
          .get();

      final allInternships = querySnapshot.docs.map((doc) {
        final data = doc.data();
        return InternshipModel(
          id: data['id'] ?? doc.id,
          title: data['title'] ?? '',
          company: data['company'] ?? '',
          location: data['location'] ?? '',
          stipend: data['stipend'] ?? '',
          duration: data['duration'] ?? '',
          applyLink: data['applyLink'] ?? '',
          skills: List<String>.from(data['skills'] ?? []),
          description: data['description'] ?? '',
        );
      }).toList();

      // Filter internships based on search query
      final filteredInternships = allInternships.where((internship) {
        final searchLower = query.toLowerCase();
        return internship.title.toLowerCase().contains(searchLower) ||
               internship.company.toLowerCase().contains(searchLower) ||
               internship.location.toLowerCase().contains(searchLower) ||
               internship.skills.any((skill) => skill.toLowerCase().contains(searchLower)) ||
               (internship.description?.toLowerCase().contains(searchLower) ?? false);
      }).toList();

      if (kDebugMode) print('✅ Found ${filteredInternships.length} internships matching "$query"');
      return filteredInternships;
    } catch (e) {
      if (kDebugMode) print('❌ Error searching internships: $e');
      return [];
    }
  }

  /// Get internships by location
  static Future<List<InternshipModel>> getInternshipsByLocation(String location) async {
    try {
      final querySnapshot = await _firestore
          .collection(_collection)
          .where('isActive', isEqualTo: true)
          .where('location', isEqualTo: location)
          .orderBy('createdAt', descending: true)
          .get();

      final internships = querySnapshot.docs.map((doc) {
        final data = doc.data();
        return InternshipModel(
          id: data['id'] ?? doc.id,
          title: data['title'] ?? '',
          company: data['company'] ?? '',
          location: data['location'] ?? '',
          stipend: data['stipend'] ?? '',
          duration: data['duration'] ?? '',
          applyLink: data['applyLink'] ?? '',
          skills: List<String>.from(data['skills'] ?? []),
          description: data['description'] ?? '',
        );
      }).toList();

      if (kDebugMode) print('✅ Found ${internships.length} internships in $location');
      return internships;
    } catch (e) {
      if (kDebugMode) print('❌ Error fetching internships by location: $e');
      return [];
    }
  }

  /// Update an internship
  static Future<bool> updateInternship(InternshipModel internship) async {
    try {
      await _firestore.collection(_collection).doc(internship.id).update({
        'title': internship.title,
        'company': internship.company,
        'location': internship.location,
        'stipend': internship.stipend,
        'duration': internship.duration,
        'applyLink': internship.applyLink,
        'skills': internship.skills,
        'description': internship.description,
        'updatedAt': FieldValue.serverTimestamp(),
      });
      
      if (kDebugMode) print('✅ Internship updated successfully: ${internship.title}');
      return true;
    } catch (e) {
      if (kDebugMode) print('❌ Error updating internship: $e');
      return false;
    }
  }

  /// Delete an internship (soft delete)
  static Future<bool> deleteInternship(String internshipId) async {
    try {
      await _firestore.collection(_collection).doc(internshipId).update({
        'isActive': false,
        'deletedAt': FieldValue.serverTimestamp(),
      });
      
      if (kDebugMode) print('✅ Internship deleted successfully: $internshipId');
      return true;
    } catch (e) {
      if (kDebugMode) print('❌ Error deleting internship: $e');
      return false;
    }
  }

  /// Initialize sample internships data in Firebase (call this once)
  static Future<void> initializeSampleData() async {
    try {
      // Always initialize data to ensure it exists in Firebase
      if (kDebugMode) print('🔄 Initializing internships data in Firebase...');

      final sampleInternships = [
        InternshipModel(
          id: 'intern_001',
          title: 'Flutter Developer Intern',
          company: 'TechCorp Solutions',
          location: 'Bangalore',
          stipend: '₹20,000/month',
          duration: '6 months',
          applyLink: 'https://techcorp.com/careers',
          skills: ['Flutter', 'Dart', 'Firebase', 'REST APIs'],
          description: 'Work on cutting-edge mobile applications using Flutter. You will collaborate with senior developers to build scalable and user-friendly mobile apps for our clients.',
        ),
        InternshipModel(
          id: 'intern_002',
          title: 'Full Stack Web Developer Intern',
          company: 'Digital Innovations Ltd',
          location: 'Mumbai',
          stipend: '₹18,000/month',
          duration: '4 months',
          applyLink: 'https://digitalinnovations.com/internships',
          skills: ['React', 'Node.js', 'MongoDB', 'JavaScript', 'Express.js'],
          description: 'Join our dynamic team to develop modern web applications. You will work on both frontend and backend development using the latest technologies.',
        ),
        InternshipModel(
          id: 'intern_003',
          title: 'Data Science Intern',
          company: 'Analytics Pro',
          location: 'Hyderabad',
          stipend: '₹25,000/month',
          duration: '5 months',
          applyLink: 'https://analyticspro.com/careers',
          skills: ['Python', 'Machine Learning', 'Pandas', 'NumPy', 'TensorFlow'],
          description: 'Work on real-world data science projects involving machine learning, data analysis, and predictive modeling. Perfect opportunity to apply your theoretical knowledge.',
        ),
        InternshipModel(
          id: 'intern_004',
          title: 'UI/UX Design Intern',
          company: 'Creative Studio',
          location: 'Pune',
          stipend: '₹15,000/month',
          duration: '3 months',
          applyLink: 'https://creativestudio.com/join-us',
          skills: ['Figma', 'Adobe XD', 'Sketch', 'User Research', 'Prototyping'],
          description: 'Design intuitive and beautiful user interfaces for web and mobile applications. You will work closely with our design team to create amazing user experiences.',
        ),
        InternshipModel(
          id: 'intern_005',
          title: 'Android Developer Intern',
          company: 'Mobile First Technologies',
          location: 'Delhi',
          stipend: '₹22,000/month',
          duration: '6 months',
          applyLink: 'https://mobilefirst.tech/careers',
          skills: ['Java', 'Kotlin', 'Android SDK', 'SQLite', 'Material Design'],
          description: 'Develop native Android applications with modern architecture patterns. You will learn industry best practices and work on apps used by millions of users.',
        ),
        InternshipModel(
          id: 'intern_006',
          title: 'DevOps Intern',
          company: 'CloudTech Systems',
          location: 'Chennai',
          stipend: '₹19,000/month',
          duration: '4 months',
          applyLink: 'https://cloudtech.com/internships',
          skills: ['Docker', 'Kubernetes', 'AWS', 'Jenkins', 'Linux'],
          description: 'Learn about cloud infrastructure, CI/CD pipelines, and automation. You will work with cutting-edge DevOps tools and practices.',
        ),
        InternshipModel(
          id: 'intern_007',
          title: 'Cybersecurity Intern',
          company: 'SecureNet Solutions',
          location: 'Kolkata',
          stipend: '₹17,000/month',
          duration: '5 months',
          applyLink: 'https://securenet.com/careers',
          skills: ['Network Security', 'Ethical Hacking', 'Python', 'Linux', 'Wireshark'],
          description: 'Gain hands-on experience in cybersecurity, including penetration testing, vulnerability assessment, and security analysis.',
        ),
        InternshipModel(
          id: 'intern_008',
          title: 'Digital Marketing Intern',
          company: 'Growth Marketing Agency',
          location: 'Remote',
          stipend: '₹12,000/month',
          duration: '3 months',
          applyLink: 'https://growthmarketing.com/join',
          skills: ['SEO', 'Google Analytics', 'Social Media Marketing', 'Content Marketing'],
          description: 'Learn digital marketing strategies, manage social media campaigns, and analyze marketing performance metrics.',
        ),
        InternshipModel(
          id: 'intern_009',
          title: 'Game Developer Intern',
          company: 'GameStudio Interactive',
          location: 'Gurgaon',
          stipend: '₹16,000/month',
          duration: '4 months',
          applyLink: 'https://gamestudio.com/careers',
          skills: ['Unity', 'C#', 'Game Design', '3D Modeling', 'Animation'],
          description: 'Create engaging mobile and PC games using Unity engine. You will work on game mechanics, graphics, and user experience.',
        ),
        InternshipModel(
          id: 'intern_010',
          title: 'Blockchain Developer Intern',
          company: 'CryptoTech Innovations',
          location: 'Noida',
          stipend: '₹24,000/month',
          duration: '6 months',
          applyLink: 'https://cryptotech.com/internships',
          skills: ['Solidity', 'Ethereum', 'Web3.js', 'Smart Contracts', 'JavaScript'],
          description: 'Work on blockchain applications and smart contracts. Learn about decentralized applications and cryptocurrency technologies.',
        ),
      ];

      for (final internship in sampleInternships) {
        await addInternship(internship);
      }

      if (kDebugMode) print('✅ Sample internships initialized successfully');
    } catch (e) {
      if (kDebugMode) print('❌ Error initializing sample internships: $e');
    }
  }

  /// Get popular search keywords
  static List<String> getPopularKeywords() {
    return [
      'Flutter',
      'React',
      'Python',
      'Java',
      'JavaScript',
      'Data Science',
      'Machine Learning',
      'UI/UX Design',
      'Android',
      'iOS',
      'Web Development',
      'Mobile Development',
      'DevOps',
      'Cybersecurity',
      'Digital Marketing',
    ];
  }

  /// Get popular locations
  static List<String> getPopularLocations() {
    return [
      'Bangalore',
      'Mumbai',
      'Delhi',
      'Pune',
      'Hyderabad',
      'Chennai',
      'Kolkata',
      'Gurgaon',
      'Noida',
      'Remote',
    ];
  }
}
