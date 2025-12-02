import 'dart:async';
import 'package:flutter/foundation.dart';
import 'security_service.dart';
import 'secure_http_client.dart';
import 'secure_storage_service.dart';
import 'app_integrity_service.dart';

class SecurityManager {
  static final SecurityManager _instance = SecurityManager._internal();
  factory SecurityManager() => _instance;
  SecurityManager._internal();

  final SecurityService _securityService = SecurityService();
  final SecureHttpClient _httpClient = SecureHttpClient();
  final SecureStorageService _storageService = SecureStorageService();
  final AppIntegrityService _integrityService = AppIntegrityService();

  bool _isInitialized = false;
  bool _isSecurityViolated = false;
  Timer? _periodicSecurityCheck;

  // Security configuration
  static const Duration _securityCheckInterval = Duration(minutes: 5);
  static const Duration _sessionTimeout = Duration(minutes: 30);

  /// Initialize all security services
  Future<SecurityInitResult> initialize() async {
    if (_isInitialized) return SecurityInitResult.success();

    try {
      // Initialize services in order
      await _storageService.initialize();
      await _httpClient.initialize();
      
      // Enable anti-debugging measures
      _enableAntiDebugging();
      
      // Perform initial security check
      final securityResult = await _securityService.performSecurityCheck();
      final integrityResult = await _integrityService.performIntegrityCheck();
      
      if (!securityResult.isSecure || !integrityResult.isValid) {
        _isSecurityViolated = true;
        final violations = [
          ...securityResult.violations,
          ...integrityResult.violations,
        ];
        
        await _handleSecurityViolation(violations);
        
        return SecurityInitResult.failure(
          'Security violations detected: ${violations.join(', ')}',
        );
      }

      // Start periodic security checks
      _startPeriodicSecurityChecks();
      
      _isInitialized = true;
      return SecurityInitResult.success();
      
    } catch (e) {
      debugPrint('Security manager initialization error: $e');
      return SecurityInitResult.failure('Security initialization failed: $e');
    }
  }

  /// Enable anti-debugging and obfuscation measures
  void _enableAntiDebugging() {
    if (kDebugMode) return;

    try {
      // Disable debug console
      debugPrint = (String? message, {int? wrapWidth}) {};
      
      // Enable security-focused error handling
      FlutterError.onError = (FlutterErrorDetails details) {
        // In production, log errors securely without exposing sensitive info
        _logSecurityEvent('Flutter error occurred', details.toString());
      };

      // Add platform-specific anti-debugging measures
      _enablePlatformAntiDebugging();
      
    } catch (e) {
      _logSecurityEvent('Anti-debugging setup error', e.toString());
    }
  }

  /// Enable platform-specific anti-debugging
  void _enablePlatformAntiDebugging() {
    // This would typically involve platform channels for native anti-debugging
    // For now, it's a placeholder for the concept
    _logSecurityEvent('Platform anti-debugging enabled', '');
  }

  /// Start periodic security checks
  void _startPeriodicSecurityChecks() {
    _periodicSecurityCheck?.cancel();
    _periodicSecurityCheck = Timer.periodic(_securityCheckInterval, (timer) {
      _performPeriodicSecurityCheck();
    });
  }

  /// Perform periodic security check
  Future<void> _performPeriodicSecurityCheck() async {
    try {
      final securityResult = await _securityService.performSecurityCheck();
      final integrityResult = await _integrityService.performIntegrityCheck();
      
      if (!securityResult.isSecure || !integrityResult.isValid) {
        _isSecurityViolated = true;
        final violations = [
          ...securityResult.violations,
          ...integrityResult.violations,
        ];
        
        await _handleSecurityViolation(violations);
      }
    } catch (e) {
      _logSecurityEvent('Periodic security check error', e.toString());
    }
  }

  /// Handle security violations
  Future<void> _handleSecurityViolation(List<String> violations) async {
    try {
      _logSecurityEvent('Security violation detected', violations.join(', '));
      
      // Clear sensitive data
      await clearSensitiveData();
      
      // Disable sensitive features
      await _disableSensitiveFeatures();
      
      // Store violation record
      await _storageService.storeSecureData('security_violation', violations.join('|'));
      
      // In production, you might want to:
      // 1. Send violation report to server
      // 2. Show security warning to user
      // 3. Force app restart or exit
      // 4. Require re-authentication
      
    } catch (e) {
      _logSecurityEvent('Handle security violation error', e.toString());
    }
  }

  /// Disable sensitive features when security is compromised
  Future<void> _disableSensitiveFeatures() async {
    try {
      // Biometric auth removed - no status to check - no action needed
      
      // Clear session data
      await _storageService.clearSecureData('session_data');
      
      // Additional feature disabling can be added here
      
    } catch (e) {
      _logSecurityEvent('Disable sensitive features error', e.toString());
    }
  }

  /// Authenticate user for sensitive operations
  Future<bool> authenticateForSensitiveOperation({
    String reason = 'Authentication required for this operation',
  }) async {
    if (_isSecurityViolated) {
      _logSecurityEvent('Authentication blocked', 'Security violation active');
      return false;
    }

    try {
      // Simple authentication - no biometric required
      // In production, implement your preferred authentication method
      return true;
    } catch (e) {
      debugPrint('Authentication error: $e');
      return false;
    }
  }

  /// Get secure HTTP client
  SecureHttpClient get httpClient {
    if (!_isInitialized) {
      throw Exception('SecurityManager not initialized');
    }
    return _httpClient;
  }

  /// Get secure storage service
  SecureStorageService get storage {
    if (!_isInitialized) {
      throw Exception('SecurityManager not initialized');
    }
    return _storageService;
  }


  /// Check if device is secure
  bool get isDeviceSecure => !_isSecurityViolated && _securityService.isDeviceSecure;

  /// Get security status
  Future<SecurityStatus> getSecurityStatus() async {
    final securityResult = await _securityService.performSecurityCheck();
    final integrityResult = await _integrityService.performIntegrityCheck();
    
    return SecurityStatus(
      isDeviceSecure: securityResult.isSecure,
      isAppIntegrityValid: integrityResult.isValid,
      isBiometricAvailable: false,
      isBiometricEnabled: false,
      securityViolations: [
        ...securityResult.violations,
        ...integrityResult.violations,
      ],
      lastSecurityCheck: DateTime.now(),
    );
  }

  /// Clear all sensitive data
  Future<void> clearSensitiveData() async {
    try {
      await _storageService.clearAllSecureData();
      _securityService.clearSensitiveData();
      _logSecurityEvent('Sensitive data cleared', '');
    } catch (e) {
      _logSecurityEvent('Clear sensitive data error', e.toString());
    }
  }

  /// Enable security monitoring
  void enableSecurityMonitoring() {
    if (!_isInitialized) return;
    
    _startPeriodicSecurityChecks();
    _integrityService.schedulePeriodicChecks();
  }

  /// Disable security monitoring
  void disableSecurityMonitoring() {
    _periodicSecurityCheck?.cancel();
    _periodicSecurityCheck = null;
  }

  /// Log security events
  void _logSecurityEvent(String event, String details) {
    if (kDebugMode) {
      debugPrint('SECURITY EVENT: $event - $details');
    }
    
    // In production, send to secure logging service
    // Don't store sensitive details in logs
  }

  /// Dispose resources
  void dispose() {
    _periodicSecurityCheck?.cancel();
    _periodicSecurityCheck = null;
    _isInitialized = false;
  }

  /// Check session validity
  Future<bool> isSessionValid() async {
    try {
      final sessionData = await _storageService.getSessionData();
      if (sessionData == null) return false;
      
      final sessionStart = DateTime.fromMillisecondsSinceEpoch(
        sessionData['timestamp'] ?? 0,
      );
      
      final now = DateTime.now();
      return now.difference(sessionStart) <= _sessionTimeout;
      
    } catch (e) {
      _logSecurityEvent('Session validity check error', e.toString());
      return false;
    }
  }

  /// Refresh session
  Future<void> refreshSession() async {
    try {
      await _storageService.storeSessionData({
        'timestamp': DateTime.now().millisecondsSinceEpoch,
        'refreshed': true,
      });
    } catch (e) {
      _logSecurityEvent('Session refresh error', e.toString());
    }
  }
}

/// Security initialization result
class SecurityInitResult {
  final bool isSuccess;
  final String? errorMessage;

  SecurityInitResult._({
    required this.isSuccess,
    this.errorMessage,
  });

  factory SecurityInitResult.success() => SecurityInitResult._(isSuccess: true);
  
  factory SecurityInitResult.failure(String message) => SecurityInitResult._(
    isSuccess: false,
    errorMessage: message,
  );

  @override
  String toString() {
    return 'SecurityInitResult(isSuccess: $isSuccess, errorMessage: $errorMessage)';
  }
}

/// Overall security status
class SecurityStatus {
  final bool isDeviceSecure;
  final bool isAppIntegrityValid;
  final bool isBiometricAvailable;
  final bool isBiometricEnabled;
  final List<String> securityViolations;
  final DateTime lastSecurityCheck;

  SecurityStatus({
    required this.isDeviceSecure,
    required this.isAppIntegrityValid,
    required this.isBiometricAvailable,
    required this.isBiometricEnabled,
    required this.securityViolations,
    required this.lastSecurityCheck,
  });

  bool get isSecure => isDeviceSecure && isAppIntegrityValid && securityViolations.isEmpty;

  @override
  String toString() {
    return 'SecurityStatus(isSecure: $isSecure, violations: $securityViolations)';
  }
}
