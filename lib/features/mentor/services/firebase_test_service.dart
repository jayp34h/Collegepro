import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';

class FirebaseTestService {
  static Future<void> testFirebaseConnection() async {
    try {
      print('=== Firebase Connection Test ===');
      
      // Test Firebase Auth
      final auth = FirebaseAuth.instance;
      final currentUser = auth.currentUser;
      
      print('Auth Current User: ${currentUser?.uid}');
      print('Auth User Email: ${currentUser?.email}');
      print('Auth User Verified: ${currentUser?.emailVerified}');
      
      if (currentUser == null) {
        print('ERROR: No authenticated user found');
        return;
      }
      
      // Test Firebase Realtime Database connection
      final database = FirebaseDatabase.instance.ref();
      
      print('Testing database write permission...');
      
      // Try to write a test record
      final testRef = database.child('test').child('connection_test');
      await testRef.set({
        'timestamp': DateTime.now().toIso8601String(),
        'userId': currentUser.uid,
        'test': true,
      }).timeout(const Duration(seconds: 10));
      
      print('SUCCESS: Database write test passed');
      
      // Try to read the test record
      print('Testing database read permission...');
      final snapshot = await testRef.get().timeout(const Duration(seconds: 10));
      
      if (snapshot.exists) {
        print('SUCCESS: Database read test passed');
        print('Test data: ${snapshot.value}');
      } else {
        print('WARNING: Database read returned no data');
      }
      
      // Clean up test data
      await testRef.remove();
      print('Test data cleaned up');
      
      print('=== Firebase Test Complete ===');
      
    } catch (e) {
      print('ERROR in Firebase test: $e');
      print('Error type: ${e.runtimeType}');
    }
  }
  
  static Future<void> testDoubtPosting() async {
    try {
      print('=== Doubt Posting Test ===');
      
      final auth = FirebaseAuth.instance;
      final currentUser = auth.currentUser;
      
      if (currentUser == null) {
        print('ERROR: No authenticated user for doubt test');
        return;
      }
      
      final database = FirebaseDatabase.instance.ref();
      final doubtRef = database.child('doubts').push();
      
      final testDoubt = {
        'id': doubtRef.key,
        'userId': currentUser.uid,
        'title': 'Test Doubt - ${DateTime.now().millisecondsSinceEpoch}',
        'description': 'This is a test doubt to verify posting functionality',
        'category': 'Technical Skills',
        'timestamp': DateTime.now().toIso8601String(),
        'status': 'Pending',
      };
      
      print('Posting test doubt with ID: ${doubtRef.key}');
      
      await doubtRef.set(testDoubt).timeout(const Duration(seconds: 15));
      
      print('SUCCESS: Test doubt posted successfully');
      
      // Verify the doubt was saved
      final snapshot = await doubtRef.get();
      if (snapshot.exists) {
        print('SUCCESS: Test doubt verified in database');
        
        // Clean up test doubt
        await doubtRef.remove();
        print('Test doubt cleaned up');
      } else {
        print('ERROR: Test doubt not found in database');
      }
      
      print('=== Doubt Test Complete ===');
      
    } catch (e) {
      print('ERROR in doubt posting test: $e');
      print('Error type: ${e.runtimeType}');
    }
  }
}
