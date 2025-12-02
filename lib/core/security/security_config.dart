import 'package:flutter/foundation.dart';

class SecurityConfig {
  // Security check intervals
  static const Duration securityCheckInterval = Duration(minutes: 5);
  static const Duration sessionTimeout = Duration(minutes: 30);
  static const Duration biometricAuthTimeout = Duration(minutes: 5);
  
  // Network security settings
  static const Duration networkTimeout = Duration(seconds: 30);
  static const int maxRetryAttempts = 3;
  
  // Trusted domains for network requests
  static const List<String> trustedDomains = [
    'firebase.googleapis.com',
    'firebaseio.com',
    'googleapis.com',
    'google.com',
    'hackerearth.com',
    'export.arxiv.org',
    'identitytoolkit.googleapis.com',
    'firebasestorage.googleapis.com',
  ];
  
  // Security violation thresholds
  static const int maxSecurityViolations = 3;
  static const Duration violationCooldown = Duration(hours: 1);
  
  // Encryption settings
  static const String encryptionAlgorithm = 'AES';
  static const int encryptionKeyLength = 256;
  
  // App integrity settings
  static const String expectedPackageName = 'com.collegepro.app';
  static const bool enforceAppSignature = true;
  static const bool enforceInstallationSource = false; // Set to true for production
  
  // Debug mode settings
  static bool get isSecurityEnabled => !kDebugMode;
  static bool get allowDebuggerInProduction => false;
  static bool get logSecurityEvents => kDebugMode;
  
  // Biometric authentication settings
  static const bool requireBiometricForSensitiveOps = true;
  static const bool fallbackToDeviceCredentials = true;
  
  // Root/Jailbreak detection settings
  static const bool blockRootedDevices = true;
  static const bool blockEmulators = true;
  static const bool blockDeveloperMode = false; // Set to true for production
  
  // Network security settings
  static const bool enforceHTTPS = true;
  static const bool validateCertificates = true;
  static const bool blockUntrustedDomains = true;
  
  /// Get security level based on environment
  static SecurityLevel getSecurityLevel() {
    if (kDebugMode) {
      return SecurityLevel.low;
    } else if (kReleaseMode) {
      return SecurityLevel.high;
    } else {
      return SecurityLevel.medium;
    }
  }
  
  /// Check if domain is trusted
  static bool isTrustedDomain(String domain) {
    return trustedDomains.any((trusted) => domain.contains(trusted));
  }
  
  /// Get timeout for security operation
  static Duration getTimeoutForOperation(SecurityOperation operation) {
    switch (operation) {
      case SecurityOperation.networkRequest:
        return networkTimeout;
      case SecurityOperation.biometricAuth:
        return biometricAuthTimeout;
      case SecurityOperation.securityCheck:
        return securityCheckInterval;
      case SecurityOperation.sessionValidation:
        return sessionTimeout;
    }
  }
}

enum SecurityLevel {
  low,
  medium,
  high,
}

enum SecurityOperation {
  networkRequest,
  biometricAuth,
  securityCheck,
  sessionValidation,
}

class SecurityConstants {
  // Storage keys
  static const String encryptionKeyStorage = 'encryption_key';
  static const String biometricEnabledStorage = 'biometric_enabled';
  static const String lastSecurityCheckStorage = 'last_security_check';
  static const String securityViolationStorage = 'security_violation';
  static const String sessionDataStorage = 'session_data';
  static const String userCredentialsStorage = 'user_credentials';
  static const String appSignatureStorage = 'app_signature';
  
  // Security headers
  static const Map<String, String> securityHeaders = {
    'X-Requested-With': 'XMLHttpRequest',
    'Cache-Control': 'no-cache, no-store, must-revalidate',
    'Pragma': 'no-cache',
    'Expires': '0',
    'X-Content-Type-Options': 'nosniff',
    'X-Frame-Options': 'DENY',
    'X-XSS-Protection': '1; mode=block',
  };
  
  // Error messages
  static const String rootedDeviceError = 'This app cannot run on rooted/jailbroken devices for security reasons.';
  static const String emulatorError = 'This app cannot run on emulators for security reasons.';
  static const String integrityError = 'App integrity check failed. Please reinstall the app from official sources.';
  static const String networkSecurityError = 'Network security violation detected. Please check your connection.';
  static const String biometricError = 'Biometric authentication failed. Please try again.';
  static const String sessionExpiredError = 'Your session has expired. Please log in again.';
}
