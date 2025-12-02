import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:google_sign_in/google_sign_in.dart';

class AndroidAuthTest {
  static Future<void> runComprehensiveAuthTest() async {
    if (kDebugMode) {
      print('🔍 === ANDROID AUTHENTICATION DIAGNOSTIC TEST ===');
      
      // Test 1: Firebase Initialization
      await _testFirebaseInitialization();
      
      // Test 2: Google Services Configuration
      await _testGoogleServicesConfig();
      
      // Test 3: Network Connectivity
      await _testNetworkConnectivity();
      
      // Test 4: Firebase Auth Instance
      await _testFirebaseAuthInstance();
      
      // Test 5: Google Sign-In Configuration
      await _testGoogleSignInConfig();
      
      // Test 6: Email/Password Authentication
      await _testEmailPasswordAuth();
      
      print('🔍 === DIAGNOSTIC TEST COMPLETED ===');
    }
  }

  static Future<void> _testFirebaseInitialization() async {
    try {
      print('\n📱 Testing Firebase Initialization...');
      
      if (Firebase.apps.isEmpty) {
        print('❌ Firebase not initialized');
        return;
      }
      
      final app = Firebase.app();
      print('✅ Firebase initialized successfully');
      print('   App name: ${app.name}');
      print('   Project ID: ${app.options.projectId}');
      print('   API Key: ${app.options.apiKey.substring(0, 10)}...');
      
    } catch (e) {
      print('❌ Firebase initialization test failed: $e');
    }
  }

  static Future<void> _testGoogleServicesConfig() async {
    try {
      print('\n🔧 Testing Google Services Configuration...');
      
      final googleSignIn = GoogleSignIn();
      print('✅ GoogleSignIn instance created');
      print('   Client ID configured: ${googleSignIn.clientId != null}');
      
      // Test if we can initialize Google Sign-In
      final isAvailable = await googleSignIn.isSignedIn();
      print('✅ Google Sign-In service available');
      print('   Currently signed in: $isAvailable');
      
    } catch (e) {
      print('❌ Google Services configuration test failed: $e');
    }
  }

  static Future<void> _testNetworkConnectivity() async {
    try {
      print('\n🌐 Testing Network Connectivity...');
      
      // Simple connectivity test
      final auth = FirebaseAuth.instance;
      await auth.fetchSignInMethodsForEmail('test@example.com');
      print('✅ Network connectivity to Firebase working');
      
    } catch (e) {
      if (e.toString().contains('network')) {
        print('❌ Network connectivity issue: $e');
      } else {
        print('✅ Network connectivity working (expected auth error)');
      }
    }
  }

  static Future<void> _testFirebaseAuthInstance() async {
    try {
      print('\n🔐 Testing Firebase Auth Instance...');
      
      final auth = FirebaseAuth.instance;
      print('✅ FirebaseAuth instance created');
      print('   Current user: ${auth.currentUser?.email ?? 'None'}');
      print('   Auth state: ${auth.currentUser != null ? 'Signed in' : 'Signed out'}');
      
      // Test auth state listener
      auth.authStateChanges().listen((user) {
        print('   Auth state changed: ${user?.email ?? 'Signed out'}');
      });
      
    } catch (e) {
      print('❌ Firebase Auth instance test failed: $e');
    }
  }

  static Future<void> _testGoogleSignInConfig() async {
    try {
      print('\n📱 Testing Google Sign-In Configuration...');
      
      final googleSignIn = GoogleSignIn();
      
      // Test configuration
      print('   Scopes: ${googleSignIn.scopes}');
      print('   Hosted domain: ${googleSignIn.hostedDomain ?? 'None'}');
      
      // Test if we can start sign-in process (without completing it)
      try {
        await googleSignIn.signOut(); // Clear any existing session
        print('✅ Google Sign-In configuration appears valid');
      } catch (e) {
        print('⚠️ Google Sign-In configuration issue: $e');
      }
      
    } catch (e) {
      print('❌ Google Sign-In configuration test failed: $e');
    }
  }

  static Future<void> _testEmailPasswordAuth() async {
    try {
      print('\n📧 Testing Email/Password Authentication...');
      
      final auth = FirebaseAuth.instance;
      
      // Test with invalid credentials to check if auth is working
      try {
        await auth.signInWithEmailAndPassword(
          email: 'test@invalid.com',
          password: 'invalidpassword'
        );
      } catch (e) {
        if (e is FirebaseAuthException) {
          print('✅ Email/Password authentication service working');
          print('   Error code: ${e.code}');
          print('   Error message: ${e.message}');
        } else {
          print('❌ Unexpected error in email/password auth: $e');
        }
      }
      
    } catch (e) {
      print('❌ Email/Password authentication test failed: $e');
    }
  }

  static void showTestDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Android Auth Test'),
        content: const Text('Running comprehensive authentication test. Check debug console for results.'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              runComprehensiveAuthTest();
            },
            child: const Text('Run Test'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
        ],
      ),
    );
  }
}
