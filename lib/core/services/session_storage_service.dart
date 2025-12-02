import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter/foundation.dart';

class SessionStorageService {
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

  /// Initialize Secure Storage (no initialization needed for FlutterSecureStorage)
  static Future<void> init() async {
    try {
      if (kDebugMode) {
        print('✅ SessionStorageService (Secure Storage) initialized');
      }
    } catch (e) {
      if (kDebugMode) {
        print('❌ Failed to initialize SessionStorageService: $e');
      }
    }
  }

  /// Save user session data
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
        print('✅ User session saved: $email');
      }
    } catch (e) {
      if (kDebugMode) {
        print('❌ Failed to save user session: $e');
      }
    }
  }

  /// Check if user is logged in
  static Future<bool> isUserLoggedIn() async {
    try {
      final isLoggedInStr = await _secureStorage.read(key: _keyIsLoggedIn);
      final sessionTimestampStr = await _secureStorage.read(key: _keySessionTimestamp);
      
      final isLoggedIn = isLoggedInStr == 'true';
      final sessionTimestamp = int.tryParse(sessionTimestampStr ?? '0') ?? 0;
      
      // Check if session is still valid (not older than 90 days for secure storage)
      final now = DateTime.now().millisecondsSinceEpoch;
      final sessionAge = now - sessionTimestamp;
      final maxSessionAge = 90 * 24 * 60 * 60 * 1000; // 90 days in milliseconds

      if (isLoggedIn && sessionAge < maxSessionAge) {
        if (kDebugMode) {
          print('✅ Valid user session found');
        }
        return true;
      } else if (isLoggedIn && sessionAge >= maxSessionAge) {
        if (kDebugMode) {
          print('⚠️ Session expired, clearing data');
        }
        await clearUserSession();
        return false;
      }

      return false;
    } catch (e) {
      if (kDebugMode) {
        print('❌ Failed to check login status: $e');
      }
      return false;
    }
  }

  /// Get stored user data
  static Future<Map<String, String?>> getStoredUserData() async {
    try {
      return {
        'userId': await _secureStorage.read(key: _keyUserId),
        'email': await _secureStorage.read(key: _keyUserEmail),
        'displayName': await _secureStorage.read(key: _keyUserName),
        'loginMethod': await _secureStorage.read(key: _keyLoginMethod),
      };
    } catch (e) {
      if (kDebugMode) {
        print('❌ Failed to get stored user data: $e');
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
        print('✅ User session cleared');
      }
    } catch (e) {
      if (kDebugMode) {
        print('❌ Failed to clear user session: $e');
      }
    }
  }

  /// Update session timestamp to keep session alive
  static Future<void> updateSessionTimestamp() async {
    try {
      await _secureStorage.write(key: _keySessionTimestamp, value: DateTime.now().millisecondsSinceEpoch.toString());
      
      if (kDebugMode) {
        print('✅ Session timestamp updated');
      }
    } catch (e) {
      if (kDebugMode) {
        print('❌ Failed to update session timestamp: $e');
      }
    }
  }
}
