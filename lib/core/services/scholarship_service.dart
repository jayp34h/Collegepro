import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/scholarship_model.dart';

class FirebaseScholarshipService {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  static const String _collection = 'scholarships';

  /// Create a new scholarship
  static Future<void> createScholarship(ScholarshipModel scholarship) async {
    try {
      await _firestore
          .collection(_collection)
          .doc(scholarship.id)
          .set(scholarship.toMap());
      print('Scholarship created successfully: ${scholarship.id}');
    } catch (e) {
      print('Error creating scholarship: $e');
      rethrow;
    }
  }

  /// Get all scholarships
  static Future<List<ScholarshipModel>> getAllScholarships() async {
    try {
      final querySnapshot = await _firestore
          .collection(_collection)
          .orderBy('createdAt', descending: false)
          .get();

      return querySnapshot.docs
          .map((doc) => ScholarshipModel.fromFirestore(doc))
          .toList();
    } catch (e) {
      print('Error fetching scholarships: $e');
      return [];
    }
  }

  /// Get scholarship by ID
  static Future<ScholarshipModel?> getScholarshipById(String id) async {
    try {
      final doc = await _firestore.collection(_collection).doc(id).get();
      if (doc.exists) {
        return ScholarshipModel.fromFirestore(doc);
      }
      return null;
    } catch (e) {
      print('Error fetching scholarship by ID: $e');
      return null;
    }
  }

  /// Update scholarship
  static Future<void> updateScholarship(ScholarshipModel scholarship) async {
    try {
      await _firestore
          .collection(_collection)
          .doc(scholarship.id)
          .update(scholarship.toMap());
      print('Scholarship updated successfully: ${scholarship.id}');
    } catch (e) {
      print('Error updating scholarship: $e');
      rethrow;
    }
  }

  /// Delete scholarship
  static Future<void> deleteScholarship(String id) async {
    try {
      await _firestore.collection(_collection).doc(id).delete();
      print('Scholarship deleted successfully: $id');
    } catch (e) {
      print('Error deleting scholarship: $e');
      rethrow;
    }
  }

  /// Search scholarships
  static Future<List<ScholarshipModel>> searchScholarships(String query) async {
    try {
      if (query.isEmpty) {
        return await getAllScholarships();
      }

      // Get all scholarships and filter client-side
      // Note: Firestore doesn't support full-text search natively
      final allScholarships = await getAllScholarships();
      final searchQuery = query.toLowerCase();

      return allScholarships.where((scholarship) {
        return scholarship.title.toLowerCase().contains(searchQuery) ||
               scholarship.organizer.toLowerCase().contains(searchQuery) ||
               scholarship.description.toLowerCase().contains(searchQuery) ||
               scholarship.tags.any((tag) => tag.toLowerCase().contains(searchQuery));
      }).toList();
    } catch (e) {
      print('Error searching scholarships: $e');
      return [];
    }
  }

  /// Filter scholarships by status
  static Future<List<ScholarshipModel>> getScholarshipsByStatus(String status) async {
    try {
      final querySnapshot = await _firestore
          .collection(_collection)
          .where('status', isEqualTo: status)
          .orderBy('createdAt', descending: false)
          .get();

      return querySnapshot.docs
          .map((doc) => ScholarshipModel.fromFirestore(doc))
          .toList();
    } catch (e) {
      print('Error fetching scholarships by status: $e');
      return [];
    }
  }

  /// Filter scholarships by tags
  static Future<List<ScholarshipModel>> getScholarshipsByTag(String tag) async {
    try {
      final querySnapshot = await _firestore
          .collection(_collection)
          .where('tags', arrayContains: tag)
          .orderBy('createdAt', descending: false)
          .get();

      return querySnapshot.docs
          .map((doc) => ScholarshipModel.fromFirestore(doc))
          .toList();
    } catch (e) {
      print('Error fetching scholarships by tag: $e');
      return [];
    }
  }

  /// Get scholarships stream for real-time updates
  static Stream<List<ScholarshipModel>> getScholarshipsStream() {
    try {
      return _firestore
          .collection(_collection)
          .orderBy('createdAt', descending: false)
          .snapshots()
          .map((snapshot) => snapshot.docs
              .map((doc) => ScholarshipModel.fromFirestore(doc))
              .toList());
    } catch (e) {
      print('Error creating scholarships stream: $e');
      return Stream.value([]);
    }
  }

  /// Clear all scholarships (for testing/reset purposes)
  static Future<void> clearAllScholarships() async {
    try {
      final batch = _firestore.batch();
      final querySnapshot = await _firestore.collection(_collection).get();
      
      for (final doc in querySnapshot.docs) {
        batch.delete(doc.reference);
      }
      
      await batch.commit();
      print('All scholarships cleared successfully');
    } catch (e) {
      print('Error clearing scholarships: $e');
      rethrow;
    }
  }

  /// Batch create multiple scholarships
  static Future<void> batchCreateScholarships(List<ScholarshipModel> scholarships) async {
    try {
      final batch = _firestore.batch();
      
      for (final scholarship in scholarships) {
        final docRef = _firestore.collection(_collection).doc(scholarship.id);
        batch.set(docRef, scholarship.toMap());
      }
      
      await batch.commit();
      print('Batch created ${scholarships.length} scholarships successfully');
    } catch (e) {
      print('Error batch creating scholarships: $e');
      rethrow;
    }
  }

  /// Get scholarship statistics
  static Future<Map<String, int>> getScholarshipStats() async {
    try {
      final scholarships = await getAllScholarships();
      
      final stats = <String, int>{
        'total': scholarships.length,
        'active': 0,
        'expired': 0,
      };

      for (final scholarship in scholarships) {
        if (scholarship.status.toLowerCase() == 'active') {
          stats['active'] = (stats['active'] ?? 0) + 1;
        } else if (scholarship.status.toLowerCase() == 'expired') {
          stats['expired'] = (stats['expired'] ?? 0) + 1;
        }
      }

      return stats;
    } catch (e) {
      print('Error getting scholarship stats: $e');
      return {'total': 0, 'active': 0, 'expired': 0};
    }
  }
}
