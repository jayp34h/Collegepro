import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'firebase_cleanup_service.dart';

class FirebaseInternshipInitializer {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  static const String _collection = 'internships';

  /// Force create internships collection with sample data
  static Future<void> forceInitializeInternships() async {
    try {
      if (kDebugMode) print('🔄 Force initializing internships collection...');
      
      // Clear existing old data first
      await FirebaseCleanupService.clearAllInternships();

      // User-specified internship opportunities
      final internships = [
        {
          'id': 'user_intern_001',
          'title': 'Software Development Engineer Intern',
          'company': 'HackerRank',
          'location': 'Remote',
          'stipend': 'Competitive',
          'duration': '6 months',
          'applyLink': 'https://www.linkedin.com/jobs/view/4306187935/',
          'skills': ['Software Development', 'Programming', 'Algorithms', 'Data Structures'],
          'description': 'Join HackerRank as a Software Development Engineer Intern and work on innovative coding platforms and assessment tools.',
          'createdAt': FieldValue.serverTimestamp(),
          'isActive': true,
        },
        {
          'id': 'user_intern_002',
          'title': 'Data Science Intern',
          'company': 'BNP Paribas',
          'location': 'Mumbai',
          'stipend': 'Competitive',
          'duration': '6 months',
          'applyLink': 'https://www.linkedin.com/jobs/view/4301521808',
          'skills': ['Data Science', 'Machine Learning', 'Python', 'Analytics', 'Statistics'],
          'description': 'Work with BNP Paribas data science team on cutting-edge financial analytics and machine learning projects.',
          'createdAt': FieldValue.serverTimestamp(),
          'isActive': true,
        },
        {
          'id': 'user_intern_003',
          'title': 'AI Interns',
          'company': 'Fireblaze AI School',
          'location': 'Bangalore',
          'stipend': 'Competitive',
          'duration': '4 months',
          'applyLink': 'https://www.linkedin.com/jobs/view/4259986069',
          'skills': ['Artificial Intelligence', 'Machine Learning', 'Deep Learning', 'Neural Networks', 'Python'],
          'description': 'Join Fireblaze AI School and work on revolutionary AI projects while learning from industry experts.',
          'createdAt': FieldValue.serverTimestamp(),
          'isActive': true,
        },
        {
          'id': 'user_intern_004',
          'title': 'Fullstack Intern',
          'company': 'Paasa',
          'location': 'Hyderabad',
          'stipend': 'Competitive',
          'duration': '5 months',
          'applyLink': 'https://www.linkedin.com/jobs/view/4303721971',
          'skills': ['Full Stack Development', 'React', 'Node.js', 'JavaScript', 'Database Management'],
          'description': 'Develop end-to-end web applications at Paasa and gain experience in modern full-stack technologies.',
          'createdAt': FieldValue.serverTimestamp(),
          'isActive': true,
        },
        {
          'id': 'user_intern_005',
          'title': 'Data Science & AI Intern',
          'company': 'SourcingXPress',
          'location': 'Delhi',
          'stipend': 'Competitive',
          'duration': '6 months',
          'applyLink': 'https://www.linkedin.com/jobs/view/4305239391',
          'skills': ['Data Science', 'Artificial Intelligence', 'Machine Learning', 'Python', 'Data Analytics'],
          'description': 'Work on advanced data science and AI projects at SourcingXPress, focusing on supply chain optimization.',
          'createdAt': FieldValue.serverTimestamp(),
          'isActive': true,
        },
      ];

      // Create a batch write to add all internships at once
      WriteBatch batch = _firestore.batch();

      for (final internship in internships) {
        DocumentReference docRef = _firestore.collection(_collection).doc(internship['id'] as String);
        batch.set(docRef, internship);
      }

      // Commit the batch
      await batch.commit();

      if (kDebugMode) print('✅ Successfully created internships collection with ${internships.length} internships');

      // Verify the data was written
      final snapshot = await _firestore.collection(_collection).get();
      if (kDebugMode) print('✅ Verification: ${snapshot.docs.length} documents in internships collection');

    } catch (e) {
      if (kDebugMode) print('❌ Error initializing internships: $e');
      rethrow;
    }
  }

  /// Check if internships collection exists and has data
  static Future<bool> hasInternshipsData() async {
    try {
      final snapshot = await _firestore.collection(_collection).limit(1).get();
      return snapshot.docs.isNotEmpty;
    } catch (e) {
      if (kDebugMode) print('❌ Error checking internships data: $e');
      return false;
    }
  }
}
