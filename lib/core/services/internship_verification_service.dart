import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

class InternshipVerificationService {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  static const String _collection = 'internships';

  /// Verify all 17 internships are properly stored with correct data
  static Future<void> verifyInternshipsData() async {
    try {
      if (kDebugMode) print('🔍 Verifying internships data...');

      final snapshot = await _firestore.collection(_collection).get();
      
      if (kDebugMode) print('📊 Total documents found: ${snapshot.docs.length}');

      for (final doc in snapshot.docs) {
        final data = doc.data();
        if (kDebugMode) {
          print('📄 Document ID: ${doc.id}');
          print('   Company: ${data['company']}');
          print('   Title: ${data['title']}');
          print('   Stipend: ${data['stipend']}');
          print('   Apply Link: ${data['applyLink']}');
          print('   Skills: ${data['skills']}');
          print('   Location: ${data['location']}');
          print('   Duration: ${data['duration']}');
          print('   Active: ${data['isActive']}');
          print('---');
        }
      }

      // Verify specific internships exist
      final expectedInternships = [
        'real_intern_001', // XLeap Labs
        'real_intern_002', // TheBlackJabGroup
        'real_intern_003', // Optimasys Java
        'real_intern_004', // Stealth Startup
        'real_intern_005', // EmendoAI
        'real_intern_006', // SGMOID
        'real_intern_007', // Optimasys Python
        'real_intern_008', // MetroMax Group
        'real_intern_009', // Digital Heroes
        'real_intern_010', // Belle Noor
        'real_intern_011', // Oldowan Innovations
        'real_intern_012', // Piesoft Backend
        'real_intern_013', // Piesoft Flutter
        'real_intern_014', // Namekart
        'real_intern_015', // Fiddle
        'real_intern_016', // Giant Labs
        'real_intern_017', // Artyvis Technologies
      ];

      int foundCount = 0;
      for (final expectedId in expectedInternships) {
        final doc = await _firestore.collection(_collection).doc(expectedId).get();
        if (doc.exists) {
          foundCount++;
          if (kDebugMode) print('✅ Found: $expectedId');
        } else {
          if (kDebugMode) print('❌ Missing: $expectedId');
        }
      }

      if (kDebugMode) print('📊 Verification Summary: $foundCount/${expectedInternships.length} internships found');

    } catch (e) {
      if (kDebugMode) print('❌ Error verifying internships: $e');
    }
  }

  /// Get all internships with their apply links for testing
  static Future<List<Map<String, dynamic>>> getAllInternshipsWithLinks() async {
    try {
      final snapshot = await _firestore
          .collection(_collection)
          .where('isActive', isEqualTo: true)
          .get();

      return snapshot.docs.map((doc) {
        final data = doc.data();
        return {
          'id': doc.id,
          'company': data['company'] ?? '',
          'title': data['title'] ?? '',
          'applyLink': data['applyLink'] ?? '',
          'stipend': data['stipend'] ?? '',
          'location': data['location'] ?? '',
          'skills': data['skills'] ?? [],
        };
      }).toList();
    } catch (e) {
      if (kDebugMode) print('❌ Error getting internships with links: $e');
      return [];
    }
  }
}
