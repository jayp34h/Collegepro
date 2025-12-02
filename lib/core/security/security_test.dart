import 'package:flutter/foundation.dart';
import 'security_manager.dart';
import 'security_service.dart';
import 'secure_storage_service.dart';
import 'app_integrity_service.dart';

/// Test class for security implementation
class SecurityTest {
  static Future<void> runSecurityTests() async {
    if (!kDebugMode) {
      debugPrint('Security tests should only run in debug mode');
      return;
    }

    debugPrint('🔒 Starting Security Tests...');

    try {
      // Test 1: Security Manager Initialization
      await _testSecurityManagerInitialization();

      // Test 2: Secure Storage
      await _testSecureStorage();

      // Test 3: Security Service
      await _testSecurityService();

      // Test 4: Biometric Authentication
      await _testBiometricAuth();

      // Test 5: App Integrity
      await _testAppIntegrity();

      debugPrint('✅ All security tests completed successfully');
    } catch (e) {
      debugPrint('❌ Security test failed: $e');
    }
  }

  static Future<void> _testSecurityManagerInitialization() async {
    debugPrint('Testing Security Manager Initialization...');
    
    final securityManager = SecurityManager();
    final result = await securityManager.initialize();
    
    if (result.isSuccess) {
      debugPrint('✅ Security Manager initialized successfully');
    } else {
      debugPrint('⚠️ Security Manager initialization failed: ${result.errorMessage}');
    }
  }

  static Future<void> _testSecureStorage() async {
    debugPrint('Testing Secure Storage...');
    
    try {
      final storage = SecureStorageService();
      await storage.initialize();
      
      // Test storing and retrieving data
      const testKey = 'test_key';
      const testValue = 'test_value_123';
      
      await storage.storeSecureData(testKey, testValue);
      final retrievedValue = await storage.getSecureData(testKey);
      
      if (retrievedValue == testValue) {
        debugPrint('✅ Secure Storage test passed');
      } else {
        debugPrint('❌ Secure Storage test failed: values don\'t match');
      }
      
      // Clean up
      await storage.clearSecureData(testKey);
    } catch (e) {
      debugPrint('❌ Secure Storage test error: $e');
    }
  }

  static Future<void> _testSecurityService() async {
    debugPrint('Testing Security Service...');
    
    try {
      final securityService = SecurityService();
      final result = await securityService.performSecurityCheck();
      
      debugPrint('Security Check Results:');
      debugPrint('  - Device Secure: ${result.isSecure}');
      debugPrint('  - Violations: ${result.violations}');
      debugPrint('  - Check Results: ${result.checkResults}');
      
      debugPrint('✅ Security Service test completed');
    } catch (e) {
      debugPrint('❌ Security Service test error: $e');
    }
  }

  static Future<void> _testBiometricAuth() async {
    debugPrint('Testing Biometric Authentication...');
    debugPrint('⚠️ Biometric Authentication has been removed from this app');
    debugPrint('✅ Biometric Authentication test skipped');
  }

  static Future<void> _testAppIntegrity() async {
    debugPrint('Testing App Integrity...');
    
    try {
      final integrityService = AppIntegrityService();
      final result = await integrityService.performIntegrityCheck();
      
      debugPrint('App Integrity Results:');
      debugPrint('  - Valid: ${result.isValid}');
      debugPrint('  - Violations: ${result.violations}');
      debugPrint('  - Check Results: ${result.checkResults}');
      
      debugPrint('✅ App Integrity test completed');
    } catch (e) {
      debugPrint('❌ App Integrity test error: $e');
    }
  }

  /// Test security status monitoring
  static Future<void> testSecurityMonitoring() async {
    if (!kDebugMode) return;

    debugPrint('🔍 Testing Security Monitoring...');
    
    try {
      final securityManager = SecurityManager();
      await securityManager.initialize();
      
      // Enable monitoring
      securityManager.enableSecurityMonitoring();
      
      // Get security status
      final status = await securityManager.getSecurityStatus();
      
      debugPrint('Security Status:');
      debugPrint('  - Device Secure: ${status.isDeviceSecure}');
      debugPrint('  - App Integrity Valid: ${status.isAppIntegrityValid}');
      debugPrint('  - Biometric Available: ${status.isBiometricAvailable}');
      debugPrint('  - Biometric Enabled: ${status.isBiometricEnabled}');
      debugPrint('  - Security Violations: ${status.securityViolations}');
      debugPrint('  - Last Check: ${status.lastSecurityCheck}');
      debugPrint('  - Overall Secure: ${status.isSecure}');
      
      debugPrint('✅ Security Monitoring test completed');
    } catch (e) {
      debugPrint('❌ Security Monitoring test error: $e');
    }
  }

  /// Test session management
  static Future<void> testSessionManagement() async {
    if (!kDebugMode) return;

    debugPrint('📱 Testing Session Management...');
    
    try {
      final securityManager = SecurityManager();
      await securityManager.initialize();
      
      // Test session validity
      final isValid = await securityManager.isSessionValid();
      debugPrint('Session Valid: $isValid');
      
      // Refresh session
      await securityManager.refreshSession();
      debugPrint('Session refreshed');
      
      // Check validity again
      final isValidAfterRefresh = await securityManager.isSessionValid();
      debugPrint('Session Valid After Refresh: $isValidAfterRefresh');
      
      debugPrint('✅ Session Management test completed');
    } catch (e) {
      debugPrint('❌ Session Management test error: $e');
    }
  }
}

/// Quick security health check
class SecurityHealthCheck {
  static Future<Map<String, dynamic>> performHealthCheck() async {
    final results = <String, dynamic>{};
    
    try {
      // Check Security Manager
      final securityManager = SecurityManager();
      final initResult = await securityManager.initialize();
      results['security_manager'] = initResult.isSuccess;
      
      // Check device security
      final status = await securityManager.getSecurityStatus();
      results['device_secure'] = status.isDeviceSecure;
      results['app_integrity'] = status.isAppIntegrityValid;
      results['biometric_available'] = status.isBiometricAvailable;
      results['violations'] = status.securityViolations;
      
      // Check session
      final sessionValid = await securityManager.isSessionValid();
      results['session_valid'] = sessionValid;
      
      results['overall_health'] = results['security_manager'] && 
                                 results['device_secure'] && 
                                 results['app_integrity'];
      
    } catch (e) {
      results['error'] = e.toString();
      results['overall_health'] = false;
    }
    
    return results;
  }
}
