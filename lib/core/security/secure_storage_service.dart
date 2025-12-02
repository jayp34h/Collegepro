import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:encrypt/encrypt.dart' as encrypt;
import 'package:crypto/crypto.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SecureStorageService {
  static final SecureStorageService _instance = SecureStorageService._internal();
  factory SecureStorageService() => _instance;
  SecureStorageService._internal();

  static const FlutterSecureStorage _secureStorage = FlutterSecureStorage(
    aOptions: AndroidOptions(
      encryptedSharedPreferences: true,
    ),
    iOptions: IOSOptions(
      groupId: 'group.com.collegepro.app',
    ),
  );

  late encrypt.Encrypter _encrypter;
  late encrypt.IV _iv;
  bool _isInitialized = false;

  /// Initialize the secure storage service
  Future<void> initialize() async {
    if (_isInitialized) return;

    try {
      // Generate or retrieve encryption key
      final key = await _getOrCreateEncryptionKey();
      _encrypter = encrypt.Encrypter(encrypt.AES(key));
      _iv = encrypt.IV.fromSecureRandom(16);
      _isInitialized = true;
    } catch (e) {
      debugPrint('SecureStorageService initialization error: $e');
      throw Exception('Failed to initialize secure storage');
    }
  }

  /// Get or create encryption key
  Future<encrypt.Key> _getOrCreateEncryptionKey() async {
    try {
      // Try to get existing key
      final existingKey = await _secureStorage.read(key: 'encryption_key');
      if (existingKey != null) {
        return encrypt.Key.fromBase64(existingKey);
      }

      // Create new key
      final key = encrypt.Key.fromSecureRandom(32);
      await _secureStorage.write(key: 'encryption_key', value: key.base64);
      return key;
    } catch (e) {
      debugPrint('Encryption key generation error: $e');
      // Fallback to device-specific key
      return _generateDeviceSpecificKey();
    }
  }

  /// Generate device-specific encryption key
  encrypt.Key _generateDeviceSpecificKey() {
    final deviceId = 'collegepro_device_key'; // In production, use actual device ID
    final bytes = utf8.encode(deviceId);
    final digest = sha256.convert(bytes);
    // Create Key from digest bytes (SHA-256 produces 32 bytes, perfect for AES-256)
    return encrypt.Key.fromBase64(base64.encode(digest.bytes));
  }

  /// Store sensitive data with encryption
  Future<void> storeSecureData(String key, String value) async {
    if (!_isInitialized) await initialize();

    try {
      final encrypted = _encrypter.encrypt(value, iv: _iv);
      final encryptedData = {
        'data': encrypted.base64,
        'iv': _iv.base64,
        'timestamp': DateTime.now().millisecondsSinceEpoch,
      };

      await _secureStorage.write(
        key: key,
        value: jsonEncode(encryptedData),
      );
    } catch (e) {
      debugPrint('Secure data storage error: $e');
      throw Exception('Failed to store secure data');
    }
  }

  /// Retrieve and decrypt sensitive data
  Future<String?> getSecureData(String key) async {
    if (!_isInitialized) await initialize();

    try {
      final encryptedJson = await _secureStorage.read(key: key);
      if (encryptedJson == null) return null;

      final encryptedData = jsonDecode(encryptedJson) as Map<String, dynamic>;
      final encrypted = encrypt.Encrypted.fromBase64(encryptedData['data']);
      final iv = encrypt.IV.fromBase64(encryptedData['iv']);

      return _encrypter.decrypt(encrypted, iv: iv);
    } catch (e) {
      debugPrint('Secure data retrieval error: $e');
      return null;
    }
  }

  /// Store user credentials securely
  Future<void> storeUserCredentials({
    required String userId,
    required String email,
    String? token,
  }) async {
    final credentials = {
      'userId': userId,
      'email': email,
      if (token != null) 'token': token,
      'timestamp': DateTime.now().millisecondsSinceEpoch,
    };

    await storeSecureData('user_credentials', jsonEncode(credentials));
  }

  /// Retrieve user credentials
  Future<Map<String, dynamic>?> getUserCredentials() async {
    final credentialsJson = await getSecureData('user_credentials');
    if (credentialsJson == null) return null;

    try {
      return jsonDecode(credentialsJson) as Map<String, dynamic>;
    } catch (e) {
      debugPrint('User credentials parsing error: $e');
      return null;
    }
  }

  /// Store biometric authentication data
  Future<void> storeBiometricData(String biometricHash) async {
    await storeSecureData('biometric_hash', biometricHash);
  }

  /// Get biometric authentication data
  Future<String?> getBiometricData() async {
    return await getSecureData('biometric_hash');
  }

  /// Store API keys securely
  Future<void> storeApiKey(String keyName, String apiKey) async {
    await storeSecureData('api_key_$keyName', apiKey);
  }

  /// Retrieve API key
  Future<String?> getApiKey(String keyName) async {
    return await getSecureData('api_key_$keyName');
  }

  /// Store session data
  Future<void> storeSessionData(Map<String, dynamic> sessionData) async {
    await storeSecureData('session_data', jsonEncode(sessionData));
  }

  /// Get session data
  Future<Map<String, dynamic>?> getSessionData() async {
    final sessionJson = await getSecureData('session_data');
    if (sessionJson == null) return null;

    try {
      return jsonDecode(sessionJson) as Map<String, dynamic>;
    } catch (e) {
      debugPrint('Session data parsing error: $e');
      return null;
    }
  }

  /// Clear all secure data
  Future<void> clearAllSecureData() async {
    try {
      await _secureStorage.deleteAll();
    } catch (e) {
      debugPrint('Clear secure data error: $e');
    }
  }

  /// Clear specific secure data
  Future<void> clearSecureData(String key) async {
    try {
      await _secureStorage.delete(key: key);
    } catch (e) {
      debugPrint('Clear specific secure data error: $e');
    }
  }

  /// Check if secure data exists
  Future<bool> hasSecureData(String key) async {
    try {
      final data = await _secureStorage.read(key: key);
      return data != null;
    } catch (e) {
      debugPrint('Check secure data existence error: $e');
      return false;
    }
  }

  /// Get all secure storage keys
  Future<Set<String>> getAllKeys() async {
    try {
      final allData = await _secureStorage.readAll();
      return allData.keys.toSet();
    } catch (e) {
      debugPrint('Get all keys error: $e');
      return <String>{};
    }
  }

  /// Encrypt sensitive data for transmission
  String encryptForTransmission(String data) {
    if (!_isInitialized) throw Exception('SecureStorageService not initialized');
    
    final encrypted = _encrypter.encrypt(data, iv: _iv);
    return encrypted.base64;
  }

  /// Decrypt received data
  String decryptFromTransmission(String encryptedData, String ivString) {
    if (!_isInitialized) throw Exception('SecureStorageService not initialized');
    
    final encrypted = encrypt.Encrypted.fromBase64(encryptedData);
    final iv = encrypt.IV.fromBase64(ivString);
    return _encrypter.decrypt(encrypted, iv: iv);
  }

  /// Generate secure hash for data integrity
  String generateSecureHash(String data) {
    final bytes = utf8.encode(data);
    final digest = sha256.convert(bytes);
    return digest.toString();
  }

  /// Verify data integrity
  bool verifyDataIntegrity(String data, String expectedHash) {
    final actualHash = generateSecureHash(data);
    return actualHash == expectedHash;
  }
}

/// Enhanced SharedPreferences wrapper with encryption for non-sensitive data
class SecurePreferencesService {
  static final SecurePreferencesService _instance = SecurePreferencesService._internal();
  factory SecurePreferencesService() => _instance;
  SecurePreferencesService._internal();

  SharedPreferences? _prefs;
  late encrypt.Encrypter _encrypter;
  late encrypt.IV _iv;

  /// Initialize secure preferences
  Future<void> initialize() async {
    _prefs = await SharedPreferences.getInstance();
    
    // Use a simpler encryption for preferences
    final keyString = 'collegepro_preferences_key_2024';
    final keyBytes = keyString.padRight(32, '0').substring(0, 32);
    final key = encrypt.Key.fromBase64(base64.encode(utf8.encode(keyBytes)));
    _encrypter = encrypt.Encrypter(encrypt.AES(key));
    
    final ivString = 'collegepro_iv';
    final ivBytes = ivString.padRight(16, '0').substring(0, 16);
    _iv = encrypt.IV.fromBase64(base64.encode(utf8.encode(ivBytes)));
  }

  /// Store encrypted preference
  Future<bool> setEncryptedString(String key, String value) async {
    if (_prefs == null) await initialize();
    
    try {
      final encrypted = _encrypter.encrypt(value, iv: _iv);
      return await _prefs!.setString(key, encrypted.base64);
    } catch (e) {
      debugPrint('Encrypted preference storage error: $e');
      return false;
    }
  }

  /// Get encrypted preference
  String? getEncryptedString(String key) {
    if (_prefs == null) return null;
    
    try {
      final encryptedValue = _prefs!.getString(key);
      if (encryptedValue == null) return null;
      
      final encrypted = encrypt.Encrypted.fromBase64(encryptedValue);
      return _encrypter.decrypt(encrypted, iv: _iv);
    } catch (e) {
      debugPrint('Encrypted preference retrieval error: $e');
      return null;
    }
  }

  /// Store encrypted boolean
  Future<bool> setEncryptedBool(String key, bool value) async {
    return await setEncryptedString(key, value.toString());
  }

  /// Get encrypted boolean
  bool? getEncryptedBool(String key) {
    final value = getEncryptedString(key);
    if (value == null) return null;
    return value.toLowerCase() == 'true';
  }

  /// Store encrypted integer
  Future<bool> setEncryptedInt(String key, int value) async {
    return await setEncryptedString(key, value.toString());
  }

  /// Get encrypted integer
  int? getEncryptedInt(String key) {
    final value = getEncryptedString(key);
    if (value == null) return null;
    return int.tryParse(value);
  }

  /// Clear all encrypted preferences
  Future<bool> clearAll() async {
    if (_prefs == null) await initialize();
    return await _prefs!.clear();
  }

  /// Remove specific encrypted preference
  Future<bool> remove(String key) async {
    if (_prefs == null) await initialize();
    return await _prefs!.remove(key);
  }
}
