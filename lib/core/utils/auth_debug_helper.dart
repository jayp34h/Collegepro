import 'package:flutter/foundation.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:connectivity_plus/connectivity_plus.dart';

class AuthDebugHelper {
  static final FirebaseAuth _auth = FirebaseAuth.instance;
  static final GoogleSignIn _googleSignIn = GoogleSignIn();

  /// Comprehensive authentication environment check
  static Future<Map<String, dynamic>> performAuthDiagnostics() async {
    final diagnostics = <String, dynamic>{};

    try {
      // 1. Firebase Auth Status
      diagnostics['firebase_initialized'] = true;
      diagnostics['current_user'] = _auth.currentUser?.uid ?? 'null';
      diagnostics['auth_state_ready'] = true;

      // 2. Google Sign-In Configuration
      diagnostics['google_signin_initialized'] = _googleSignIn.clientId != null;
      diagnostics['google_signin_signed_in'] = await _googleSignIn.isSignedIn();
      
      // 3. Network Connectivity
      final connectivity = await Connectivity().checkConnectivity();
      diagnostics['network_status'] = connectivity.name;
      diagnostics['has_internet'] = connectivity != ConnectivityResult.none;

      // 4. Platform-specific checks
      diagnostics['platform'] = defaultTargetPlatform.name;
      
      // 5. Firebase Auth Settings
      diagnostics['auth_language_code'] = _auth.languageCode ?? 'default';
      diagnostics['auth_tenant_id'] = _auth.tenantId ?? 'null';

      // 6. Google Sign-In Account Info
      final googleAccount = await _googleSignIn.signInSilently();
      diagnostics['google_account_cached'] = googleAccount != null;
      if (googleAccount != null) {
        diagnostics['google_account_email'] = googleAccount.email;
      }

      if (kDebugMode) {
        print('🔍 AUTH DIAGNOSTICS COMPLETE:');
        diagnostics.forEach((key, value) {
          print('  $key: $value');
        });
      }

    } catch (e) {
      diagnostics['diagnostics_error'] = e.toString();
      if (kDebugMode) {
        print('❌ Error during auth diagnostics: $e');
      }
    }

    return diagnostics;
  }

  /// Test Firebase Auth connection
  static Future<bool> testFirebaseConnection() async {
    try {
      if (kDebugMode) {
        print('🔄 Testing Firebase Auth connection...');
      }

      // Try to get auth state stream (this tests Firebase real-time connection)
      final authStateStream = _auth.authStateChanges();
      await authStateStream.first.timeout(const Duration(seconds: 5));

      if (kDebugMode) {
        print('✅ Firebase Auth connection successful');
      }
      return true;
    } catch (e) {
      if (kDebugMode) {
        print('❌ Firebase Auth connection failed: $e');
      }
      return false;
    }
  }

  /// Test Google Sign-In configuration
  static Future<bool> testGoogleSignInConfig() async {
    try {
      if (kDebugMode) {
        print('🔄 Testing Google Sign-In configuration...');
      }

      // Try silent sign-in to test configuration
      await _googleSignIn.signInSilently();

      if (kDebugMode) {
        print('✅ Google Sign-In configuration is valid');
      }
      return true;
    } catch (e) {
      if (kDebugMode) {
        print('❌ Google Sign-In configuration error: $e');
      }
      return false;
    }
  }

  /// Clear all authentication data for fresh start
  static Future<void> clearAuthData() async {
    try {
      if (kDebugMode) {
        print('🔄 Clearing all authentication data...');
      }

      // Sign out from Firebase
      await _auth.signOut();
      
      // Sign out from Google
      await _googleSignIn.signOut();
      await _googleSignIn.disconnect();

      if (kDebugMode) {
        print('✅ All authentication data cleared');
      }
    } catch (e) {
      if (kDebugMode) {
        print('❌ Error clearing auth data: $e');
      }
    }
  }

  /// Get detailed error information for debugging
  static Map<String, String> getDetailedErrorInfo(dynamic error) {
    final errorInfo = <String, String>{};

    if (error is FirebaseAuthException) {
      errorInfo['type'] = 'FirebaseAuthException';
      errorInfo['code'] = error.code;
      errorInfo['message'] = error.message ?? 'No message';
      errorInfo['plugin'] = error.plugin;
      errorInfo['stack_trace'] = error.stackTrace?.toString() ?? 'No stack trace';
    } else if (error is Exception) {
      errorInfo['type'] = 'Exception';
      errorInfo['message'] = error.toString();
      errorInfo['runtime_type'] = error.runtimeType.toString();
    } else {
      errorInfo['type'] = 'Unknown Error';
      errorInfo['message'] = error.toString();
      errorInfo['runtime_type'] = error.runtimeType.toString();
    }

    return errorInfo;
  }

  /// Log authentication attempt with full context
  static void logAuthAttempt(String method, String email, {dynamic error}) {
    if (!kDebugMode) return;

    print('🔐 AUTH ATTEMPT: $method');
    print('  📧 Email: $email');
    print('  ⏰ Time: ${DateTime.now().toIso8601String()}');
    
    if (error != null) {
      final errorInfo = getDetailedErrorInfo(error);
      print('  ❌ Error Details:');
      errorInfo.forEach((key, value) {
        print('    $key: $value');
      });
    } else {
      print('  ✅ Status: Success');
    }
    print('  ═══════════════════════════════════════');
  }
}
