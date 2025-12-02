import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

class FirebaseCleanupService {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  static const String _collection = 'internships';

  /// Clear all existing internships from Firebase
  static Future<void> clearAllInternships() async {
    try {
      if (kDebugMode) print('🧹 Clearing all existing internships...');

      // Get all documents in the collection
      final querySnapshot = await _firestore.collection(_collection).get();
      
      if (querySnapshot.docs.isEmpty) {
        if (kDebugMode) print('✅ No internships to clear');
        return;
      }

      // Create a batch to delete all documents
      WriteBatch batch = _firestore.batch();
      
      for (final doc in querySnapshot.docs) {
        batch.delete(doc.reference);
      }

      // Commit the batch deletion
      await batch.commit();

      if (kDebugMode) print('✅ Successfully cleared ${querySnapshot.docs.length} internships');

    } catch (e) {
      if (kDebugMode) print('❌ Error clearing internships: $e');
      rethrow;
    }
  }

  /// Force refresh internships collection
  static Future<void> forceRefreshInternships() async {
    try {
      if (kDebugMode) print('🔄 Force refreshing internships collection...');
      
      // Clear existing data
      await clearAllInternships();
      
      // Small delay to ensure deletion is complete
      await Future.delayed(const Duration(seconds: 2));
      
      if (kDebugMode) print('✅ Ready for new data initialization');
      
    } catch (e) {
      if (kDebugMode) print('❌ Error force refreshing internships: $e');
      rethrow;
    }
  }
}
