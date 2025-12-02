import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

class FirebaseHackathonInitializer {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  static const String _collection = 'hackathons';

  /// Force create hackathons collection with verified 2025 hackathons for CSE students
  static Future<void> forceInitializeHackathons() async {
    try {
      if (kDebugMode) print('🔄 Force initializing hackathons collection...');
      
      // Clear existing old data first
      await _clearExistingHackathons();

      // User specified hackathons with provided URLs
      final hackathons = [
        {
          'id': 'hack_2025_001',
          'title': 'The TechClasher',
          'organizer': 'MANAN Club of Department of CSE - AI',
          'description': 'The TechClasher is a Hackathon event that is organized by MANAN Club of Department of CSE - AI AI-DS bringing together students, professionals, and innovators to solve real-world challenges through AI.',
          'prize': 'Recognition & Certificates',
          'registrationUrl': 'https://reskilll.com/hack/techclasher',
          'startDate': '2025-10-06T00:00:00Z',
          'endDate': '2025-10-09T23:59:59Z',
          'registrationEndDate': '2025-10-05T23:59:59Z',
          'tags': ['AI', 'Machine Learning', 'Innovation', 'CSE'],
          'difficulty': 'Intermediate',
          'location': 'Greater Noida Institute of Technology',
          'isOnline': false,
          'logoUrl': null,
          'participantCount': null,
          'createdAt': FieldValue.serverTimestamp(),
          'isActive': true,
        },
        {
          'id': 'hack_2025_002',
          'title': 'Innoquest#3',
          'organizer': 'Microsoft Azure & Azure Developer Community',
          'description': 'Welcome to Innoquest#3, where innovation meets creativity! This hackathon is a platform for passionate developers, designers, and problem-solvers to come together, collaborate, and create groundbreaking solutions.',
          'prize': 'Recognition & Prizes',
          'registrationUrl': 'https://reskilll.com/hack/agenticindia',
          'startDate': '2025-10-16T00:00:00Z',
          'endDate': '2025-10-18T23:59:59Z',
          'registrationEndDate': '2025-10-15T23:59:59Z',
          'tags': ['Innovation', 'Azure', 'Development', 'Collaboration'],
          'difficulty': 'Intermediate',
          'location': 'Anurag University, Hyderabad',
          'isOnline': false,
          'logoUrl': null,
          'participantCount': null,
          'createdAt': FieldValue.serverTimestamp(),
          'isActive': true,
        },
        {
          'id': 'hack_2025_003',
          'title': 'MariaDB Python Hackathon',
          'organizer': 'MariaDB Foundation',
          'description': 'MariaDB Python Hackathon - Build innovative solutions using MariaDB and Python. Perfect for developers interested in database technologies and Python programming.',
          'prize': 'Recognition & Certificates',
          'registrationUrl': 'https://mariadb-python.hackerearth.com/',
          'startDate': '2025-08-23T06:00:00Z',
          'endDate': '2025-10-31T23:59:59Z',
          'registrationEndDate': '2025-10-05T23:59:59Z',
          'tags': ['Python', 'Database', 'MariaDB', 'Backend Development'],
          'difficulty': 'Intermediate',
          'location': null,
          'isOnline': true,
          'logoUrl': null,
          'participantCount': 4144,
          'createdAt': FieldValue.serverTimestamp(),
          'isActive': true,
        },
        {
          'id': 'hack_2025_004',
          'title': 'Thales GenTech India Hackathon 2025',
          'organizer': 'Thales',
          'description': 'GenTech India Hackathon 2025 - Innovative hackathon by Thales focusing on cutting-edge technology solutions. Join to solve real-world challenges and showcase your technical skills.',
          'prize': 'Recognition & Prizes',
          'registrationUrl': 'https://www.hackerearth.com/challenges/hackathon/thales-gentech-india-hackathon-3/',
          'startDate': '2025-09-15T06:00:00Z',
          'endDate': '2025-10-12T23:55:00Z',
          'registrationEndDate': '2025-10-12T23:55:00Z',
          'tags': ['Technology', 'Innovation', 'Engineering', 'GenTech'],
          'difficulty': 'Advanced',
          'location': null,
          'isOnline': true,
          'logoUrl': null,
          'participantCount': 7102,
          'createdAt': FieldValue.serverTimestamp(),
          'isActive': true,
        },
      ];

      // Create a batch write to add all hackathons at once
      WriteBatch batch = _firestore.batch();

      for (final hackathon in hackathons) {
        DocumentReference docRef = _firestore.collection(_collection).doc(hackathon['id'] as String);
        batch.set(docRef, hackathon);
      }

      // Commit the batch
      await batch.commit();

      if (kDebugMode) print('✅ Successfully created hackathons collection with ${hackathons.length} user-specified hackathons');

      // Verify the data was written
      final snapshot = await _firestore.collection(_collection).get();
      if (kDebugMode) print('✅ Verification: ${snapshot.docs.length} documents in hackathons collection');

    } catch (e) {
      if (kDebugMode) print('❌ Error initializing hackathons: $e');
      rethrow;
    }
  }

  /// Clear existing hackathons data
  static Future<void> _clearExistingHackathons() async {
    try {
      if (kDebugMode) print('🧹 Clearing existing hackathons...');

      final querySnapshot = await _firestore.collection(_collection).get();
      
      if (querySnapshot.docs.isEmpty) {
        if (kDebugMode) print('✅ No existing hackathons to clear');
        return;
      }

      WriteBatch batch = _firestore.batch();
      
      for (final doc in querySnapshot.docs) {
        batch.delete(doc.reference);
      }

      await batch.commit();

      if (kDebugMode) print('✅ Successfully cleared ${querySnapshot.docs.length} existing hackathons');

    } catch (e) {
      if (kDebugMode) print('❌ Error clearing hackathons: $e');
    }
  }

  /// Check if hackathons collection exists and has data
  static Future<bool> hasHackathonsData() async {
    try {
      final snapshot = await _firestore.collection(_collection).limit(1).get();
      return snapshot.docs.isNotEmpty;
    } catch (e) {
      if (kDebugMode) print('❌ Error checking hackathons data: $e');
      return false;
    }
  }
}
