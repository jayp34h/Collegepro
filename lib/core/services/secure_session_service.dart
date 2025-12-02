import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter/foundation.dart';

class SecureSessionService {
  static const String _keyIsLoggedIn = 'is_logged_in';
  static const String _keyUserEmail = 'user_email';
  static const String _keyUserId = 'user_id';
  static const String _keyUserName = 'user_name';
  static const String _keyLoginMethod = 'login_method';
  static const String _keySessionTimestamp = 'session_timestamp';

  static const FlutterSecureStorage _secureStorage = FlutterSecureStorage(
    aOptions: AndroidOptions(
      encryptedSharedPreferences: true,
    ),
    iOptions: IOSOptions(
      accessibility: KeychainAccessibility.first_unlock_this_device,
    ),
  );

  /// Initialize Secure Storage
  static Future<void> init() async {
    try {
      if (kDebugMode) {
        print('✅ SecureSessionService initialized');
      }
    } catch (e) {
      if (kDebugMode) {
        print('❌ Failed to initialize SecureSessionService: $e');
      }
    }
  }

  /// Save user session data securely
  static Future<void> saveUserSession({
    required String userId,
    required String email,
    required String displayName,
    required String loginMethod,
  }) async {
    try {
      await _secureStorage.write(key: _keyIsLoggedIn, value: 'true');
      await _secureStorage.write(key: _keyUserId, value: userId);
      await _secureStorage.write(key: _keyUserEmail, value: email);
      await _secureStorage.write(key: _keyUserName, value: displayName);
      await _secureStorage.write(key: _keyLoginMethod, value: loginMethod);
      await _secureStorage.write(key: _keySessionTimestamp, value: DateTime.now().millisecondsSinceEpoch.toString());

      if (kDebugMode) {
        print('✅ User session saved securely: $email');
      }
    } catch (e) {
      if (kDebugMode) {
        print('❌ Failed to save user session securely: $e');
      }
    }
  }

  /// Check if user is logged in
  static Future<bool> isUserLoggedIn() async {
    try {
      final isLoggedIn = await _secureStorage.read(key: _keyIsLoggedIn);
      final sessionTimestampStr = await _secureStorage.read(key: _keySessionTimestamp);
      
      if (isLoggedIn == 'true' && sessionTimestampStr != null) {
        final sessionTimestamp = int.tryParse(sessionTimestampStr) ?? 0;
        
        // Check if session is still valid (not older than 90 days for secure storage)
        final now = DateTime.now().millisecondsSinceEpoch;
        final sessionAge = now - sessionTimestamp;
        final maxSessionAge = 90 * 24 * 60 * 60 * 1000; // 90 days in milliseconds

        if (sessionAge < maxSessionAge) {
          if (kDebugMode) {
            print('✅ Valid secure user session found');
          }
          return true;
        } else {
          if (kDebugMode) {
            print('⚠️ Secure session expired, clearing data');
          }
          await clearUserSession();
          return false;
        }
      }

      return false;
    } catch (e) {
      if (kDebugMode) {
        print('❌ Failed to check secure login status: $e');
      }
      return false;
    }
  }

  /// Get stored user data
  static Future<Map<String, String?>> getStoredUserData() async {
    try {
      final userId = await _secureStorage.read(key: _keyUserId);
      final email = await _secureStorage.read(key: _keyUserEmail);
      final displayName = await _secureStorage.read(key: _keyUserName);
      final loginMethod = await _secureStorage.read(key: _keyLoginMethod);

      return {
        'userId': userId,
        'email': email,
        'displayName': displayName,
        'loginMethod': loginMethod,
      };
    } catch (e) {
      if (kDebugMode) {
        print('❌ Failed to get stored secure user data: $e');
      }
      return {};
    }
  }

  /// Clear user session data
  static Future<void> clearUserSession() async {
    try {
      await _secureStorage.delete(key: _keyIsLoggedIn);
      await _secureStorage.delete(key: _keyUserId);
      await _secureStorage.delete(key: _keyUserEmail);
      await _secureStorage.delete(key: _keyUserName);
      await _secureStorage.delete(key: _keyLoginMethod);
      await _secureStorage.delete(key: _keySessionTimestamp);

      if (kDebugMode) {
        print('✅ Secure user session cleared');
      }
    } catch (e) {
      if (kDebugMode) {
        print('❌ Failed to clear secure user session: $e');
      }
    }
  }

  /// Update session timestamp to keep session alive
  static Future<void> updateSessionTimestamp() async {
    try {
      await _secureStorage.write(key: _keySessionTimestamp, value: DateTime.now().millisecondsSinceEpoch.toString());
      
      if (kDebugMode) {
        print('✅ Secure session timestamp updated');
      }
    } catch (e) {
      if (kDebugMode) {
        print('❌ Failed to update secure session timestamp: $e');
      }
    }
  }

  /// Clear all secure storage (for debugging)
  static Future<void> clearAll() async {
    try {
      await _secureStorage.deleteAll();
      if (kDebugMode) {
        print('✅ All secure storage cleared');
      }
    } catch (e) {
      if (kDebugMode) {
        print('❌ Failed to clear all secure storage: $e');
      }
    }
  }
}
