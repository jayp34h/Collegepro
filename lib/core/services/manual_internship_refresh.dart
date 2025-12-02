import 'package:flutter/foundation.dart';
import 'firebase_cleanup_service.dart';
import 'firebase_internship_initializer.dart';

class ManualInternshipRefresh {
  /// Manually refresh all internships - clears old data and adds new data
  static Future<void> refreshAllInternships() async {
    try {
      if (kDebugMode) print('🔄 Starting manual internship refresh...');
      
      // Step 1: Clear all existing data
      await FirebaseCleanupService.clearAllInternships();
      
      // Step 2: Wait for cleanup to complete
      await Future.delayed(const Duration(seconds: 2));
      
      // Step 3: Initialize with fresh data
      await FirebaseInternshipInitializer.forceInitializeInternships();
      
      if (kDebugMode) print('✅ Manual internship refresh completed');
      
    } catch (e) {
      if (kDebugMode) print('❌ Error during manual refresh: $e');
      rethrow;
    }
  }
}
