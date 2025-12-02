import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import '../models/scholarship_model.dart';

class FirebaseScholarshipService {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  static const String _collection = 'scholarships';

  /// Add a new scholarship to Firebase
  static Future<bool> addScholarship(ScholarshipModel scholarship) async {
    try {
      await _firestore.collection(_collection).doc(scholarship.id).set({
        'id': scholarship.id,
        'title': scholarship.title,
        'organizer': scholarship.organizer,
        'description': scholarship.description,
        'amount': scholarship.amount,
        'deadline': scholarship.deadline,
        'link': scholarship.link,
        'status': scholarship.status,
        'eligibility': scholarship.eligibility,
        'tags': scholarship.tags,
        'createdAt': FieldValue.serverTimestamp(),
        'isActive': true,
      });
      
      if (kDebugMode) print('✅ Scholarship added successfully: ${scholarship.title}');
      return true;
    } catch (e) {
      if (kDebugMode) print('❌ Error adding scholarship: $e');
      return false;
    }
  }

  /// Get all scholarships from Firebase
  static Future<List<ScholarshipModel>> getAllScholarships() async {
    try {
      final querySnapshot = await _firestore
          .collection(_collection)
          .where('isActive', isEqualTo: true)
          .orderBy('createdAt', descending: true)
          .get();

      if (kDebugMode) print('🔍 Firebase query returned ${querySnapshot.docs.length} scholarships');

      final scholarships = querySnapshot.docs.map((doc) {
        final data = doc.data();
        if (kDebugMode) print('📄 Processing scholarship: ${doc.id} - ${data['title']}');
        
        return ScholarshipModel(
          id: data['id'] ?? doc.id,
          title: data['title'] ?? '',
          organizer: data['organizer'] ?? '',
          description: data['description'] ?? '',
          amount: data['amount'] ?? '',
          deadline: data['deadline'] ?? '',
          link: data['link'] ?? '',
          status: data['status'] ?? 'Active',
          eligibility: List<String>.from(data['eligibility'] ?? []),
          tags: List<String>.from(data['tags'] ?? []),
          createdAt: data['createdAt'] != null ? (data['createdAt'] as Timestamp).toDate() : null,
        );
      }).toList();

      if (kDebugMode) print('✅ Loaded ${scholarships.length} scholarships from Firebase');
      return scholarships;
    } catch (e) {
      if (kDebugMode) print('❌ Error fetching scholarships: $e');
      return [];
    }
  }

  /// Get real-time stream of scholarships
  static Stream<List<ScholarshipModel>> getScholarshipsStream() {
    return _firestore
        .collection(_collection)
        .where('isActive', isEqualTo: true)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) {
      if (kDebugMode) print('📡 Real-time update: ${snapshot.docs.length} scholarships');
      
      return snapshot.docs.map((doc) {
        final data = doc.data();
        return ScholarshipModel(
          id: data['id'] ?? doc.id,
          title: data['title'] ?? '',
          organizer: data['organizer'] ?? '',
          description: data['description'] ?? '',
          amount: data['amount'] ?? '',
          deadline: data['deadline'] ?? '',
          link: data['link'] ?? '',
          status: data['status'] ?? 'Active',
          eligibility: List<String>.from(data['eligibility'] ?? []),
          tags: List<String>.from(data['tags'] ?? []),
          createdAt: data['createdAt'] != null ? (data['createdAt'] as Timestamp).toDate() : null,
        );
      }).toList();
    });
  }

  /// Search scholarships by keywords
  static Future<List<ScholarshipModel>> searchScholarships(String query) async {
    try {
      final querySnapshot = await _firestore
          .collection(_collection)
          .where('isActive', isEqualTo: true)
          .get();

      final allScholarships = querySnapshot.docs.map((doc) {
        final data = doc.data();
        return ScholarshipModel(
          id: data['id'] ?? doc.id,
          title: data['title'] ?? '',
          organizer: data['organizer'] ?? '',
          description: data['description'] ?? '',
          amount: data['amount'] ?? '',
          deadline: data['deadline'] ?? '',
          link: data['link'] ?? '',
          status: data['status'] ?? 'Active',
          eligibility: List<String>.from(data['eligibility'] ?? []),
          tags: List<String>.from(data['tags'] ?? []),
          createdAt: data['createdAt'] != null ? (data['createdAt'] as Timestamp).toDate() : null,
        );
      }).toList();

      // Filter scholarships based on search query
      final filteredScholarships = allScholarships.where((scholarship) {
        final searchLower = query.toLowerCase();
        return scholarship.title.toLowerCase().contains(searchLower) ||
               scholarship.organizer.toLowerCase().contains(searchLower) ||
               scholarship.tags.any((tag) => tag.toLowerCase().contains(searchLower)) ||
               scholarship.description.toLowerCase().contains(searchLower);
      }).toList();

      if (kDebugMode) print('✅ Found ${filteredScholarships.length} scholarships matching "$query"');
      return filteredScholarships;
    } catch (e) {
      if (kDebugMode) print('❌ Error searching scholarships: $e');
      return [];
    }
  }

  /// Get scholarships by status
  static Future<List<ScholarshipModel>> getScholarshipsByStatus(String status) async {
    try {
      final querySnapshot = await _firestore
          .collection(_collection)
          .where('isActive', isEqualTo: true)
          .where('status', isEqualTo: status)
          .orderBy('createdAt', descending: true)
          .get();

      final scholarships = querySnapshot.docs.map((doc) {
        final data = doc.data();
        return ScholarshipModel(
          id: data['id'] ?? doc.id,
          title: data['title'] ?? '',
          organizer: data['organizer'] ?? '',
          description: data['description'] ?? '',
          amount: data['amount'] ?? '',
          deadline: data['deadline'] ?? '',
          link: data['link'] ?? '',
          status: data['status'] ?? 'Active',
          eligibility: List<String>.from(data['eligibility'] ?? []),
          tags: List<String>.from(data['tags'] ?? []),
          createdAt: data['createdAt'] != null ? (data['createdAt'] as Timestamp).toDate() : null,
        );
      }).toList();

      if (kDebugMode) print('✅ Found ${scholarships.length} scholarships with status: $status');
      return scholarships;
    } catch (e) {
      if (kDebugMode) print('❌ Error fetching scholarships by status: $e');
      return [];
    }
  }

  /// Update a scholarship
  static Future<bool> updateScholarship(ScholarshipModel scholarship) async {
    try {
      await _firestore.collection(_collection).doc(scholarship.id).update({
        'title': scholarship.title,
        'organizer': scholarship.organizer,
        'description': scholarship.description,
        'amount': scholarship.amount,
        'deadline': scholarship.deadline,
        'link': scholarship.link,
        'status': scholarship.status,
        'eligibility': scholarship.eligibility,
        'tags': scholarship.tags,
        'updatedAt': FieldValue.serverTimestamp(),
      });
      
      if (kDebugMode) print('✅ Scholarship updated successfully: ${scholarship.title}');
      return true;
    } catch (e) {
      if (kDebugMode) print('❌ Error updating scholarship: $e');
      return false;
    }
  }

  /// Delete a scholarship (soft delete)
  static Future<bool> deleteScholarship(String scholarshipId) async {
    try {
      await _firestore.collection(_collection).doc(scholarshipId).update({
        'isActive': false,
        'deletedAt': FieldValue.serverTimestamp(),
      });
      
      if (kDebugMode) print('✅ Scholarship deleted successfully: $scholarshipId');
      return true;
    } catch (e) {
      if (kDebugMode) print('❌ Error deleting scholarship: $e');
      return false;
    }
  }

  /// Get popular scholarship categories
  static List<String> getPopularCategories() {
    return [
      'Engineering',
      'Merit Based',
      'Research',
      'Women',
      'Minority',
      'Reserved Category',
      'General',
      'Postgraduate',
      'Undergraduate',
    ];
  }

  /// Get status types
  static List<String> getStatusTypes() {
    return [
      'Active',
      'Expired',
      'Upcoming',
    ];
  }
}
