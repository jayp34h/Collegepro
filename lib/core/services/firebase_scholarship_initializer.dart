import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

class FirebaseScholarshipInitializer {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  static const String _collection = 'scholarships';

  /// Force create scholarships collection with user-specified scholarships
  static Future<void> forceInitializeScholarships() async {
    try {
      if (kDebugMode) print('🔄 Force initializing scholarships collection...');
      
      // Clear existing old data first
      await _clearExistingScholarships();

      // User specified scholarships - Cummins first (expired), then Reliance Foundation
      final scholarships = [
        {
          'id': 'scholarship_2025_001',
          'title': 'Cummins India Scholarship Program',
          'organizer': 'Cummins India',
          'description': 'Cummins India scholarship program for engineering students. Application was available from July 1, 2025 to September 30, 2025. Fill accurate & complete information and ensure eligibility & document readiness.',
          'amount': 'Up to ₹1,00,000 per year',
          'deadline': 'September 30, 2025',
          'link': 'https://nurturingbrilliance.org/',
          'status': 'Expired',
          'eligibility': [
            'Engineering students',
            'Academic excellence required',
            'Financial need consideration',
            'Indian citizenship required'
          ],
          'tags': ['Engineering', 'Corporate Scholarship', 'Merit Based'],
          'createdAt': FieldValue.serverTimestamp(),
          'isActive': true,
        },
        {
          'id': 'scholarship_2025_002',
          'title': 'Reliance Foundation Scholarships 2025-26',
          'organizer': 'Reliance Foundation',
          'description': 'Reliance Foundation Scholarships 2025-26 - Fueling Dreams, Empowering Futures. Scholarship over the duration of the degree with up to INR 2,00,000 for undergraduate students and up to INR 6,00,000 for postgraduate students.',
          'amount': 'Up to ₹2,00,000 (UG) / ₹6,00,000 (PG)',
          'deadline': 'Check website for latest dates',
          'link': 'https://www.buddy4study.com/page/reliance-foundation-scholarships',
          'status': 'Active',
          'eligibility': [
            'Undergraduate and postgraduate students',
            'Merit-based selection',
            'Financial need consideration',
            'Indian students only'
          ],
          'tags': ['Merit Based', 'Corporate Scholarship', 'Undergraduate', 'Postgraduate'],
          'createdAt': FieldValue.serverTimestamp(),
          'isActive': true,
        },
      ];

      // Create a batch write to add all scholarships at once
      WriteBatch batch = _firestore.batch();

      for (final scholarship in scholarships) {
        DocumentReference docRef = _firestore.collection(_collection).doc(scholarship['id'] as String);
        batch.set(docRef, scholarship);
      }

      // Commit the batch
      await batch.commit();

      if (kDebugMode) print('✅ Successfully created scholarships collection with ${scholarships.length} user-specified scholarships');

      // Verify the data was written
      final snapshot = await _firestore.collection(_collection).get();
      if (kDebugMode) print('✅ Verification: ${snapshot.docs.length} documents in scholarships collection');

    } catch (e) {
      if (kDebugMode) print('❌ Error initializing scholarships: $e');
      rethrow;
    }
  }

  /// Clear existing scholarships data
  static Future<void> _clearExistingScholarships() async {
    try {
      if (kDebugMode) print('🧹 Clearing existing scholarships...');

      final querySnapshot = await _firestore.collection(_collection).get();
      
      if (querySnapshot.docs.isEmpty) {
        if (kDebugMode) print('✅ No existing scholarships to clear');
        return;
      }

      WriteBatch batch = _firestore.batch();
      
      for (final doc in querySnapshot.docs) {
        batch.delete(doc.reference);
      }

      await batch.commit();

      if (kDebugMode) print('✅ Successfully cleared ${querySnapshot.docs.length} existing scholarships');

    } catch (e) {
      if (kDebugMode) print('❌ Error clearing scholarships: $e');
    }
  }

  /// Check if scholarships collection exists and has data
  static Future<bool> hasScholarshipsData() async {
    try {
      final snapshot = await _firestore.collection(_collection).limit(1).get();
      return snapshot.docs.isNotEmpty;
    } catch (e) {
      if (kDebugMode) print('❌ Error checking scholarships data: $e');
      return false;
    }
  }
}
