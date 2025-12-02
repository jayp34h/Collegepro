import 'package:flutter/material.dart';
import 'firebase_quiz_initializer.dart';

class QuizDataManager {
  /// Initialize quiz data in Firebase when app starts
  static Future<void> initializeOnAppStart() async {
    try {
      // Check if data already exists
      final isInitialized = await FirebaseQuizInitializer.isQuizDataInitialized();
      
      if (!isInitialized) {
        debugPrint('🔥 Initializing quiz data in Firebase...');
        await FirebaseQuizInitializer.initializeQuizData();
        debugPrint('✅ Quiz data initialization completed!');
      } else {
        debugPrint('✅ Quiz data already exists in Firebase');
      }
    } catch (e) {
      debugPrint('❌ Error initializing quiz data: $e');
    }
  }

  /// Force reinitialize quiz data (useful for updates)
  static Future<void> forceReinitialize() async {
    try {
      debugPrint('🔄 Force reinitializing quiz data...');
      await FirebaseQuizInitializer.clearQuizData();
      await FirebaseQuizInitializer.initializeQuizData();
      debugPrint('✅ Quiz data reinitialized successfully!');
    } catch (e) {
      debugPrint('❌ Error reinitializing quiz data: $e');
      rethrow;
    }
  }
}
