import 'dart:io';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:safe_device/safe_device.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:crypto/crypto.dart';

class SecurityService {
  static final SecurityService _instance = SecurityService._internal();
  factory SecurityService() => _instance;
  SecurityService._internal();

  bool _isSecurityCheckComplete = false;
  bool _isDeviceSecure = true;
  String _securityViolationReason = '';

  // Security check results
  bool get isDeviceSecure => _isDeviceSecure;
  String get securityViolationReason => _securityViolationReason;
  bool get isSecurityCheckComplete => _isSecurityCheckComplete;

  /// Comprehensive security check
  Future<SecurityCheckResult> performSecurityCheck() async {
    try {
      final results = <String, bool>{};
      final violations = <String>[];

      // 1. Root/Jailbreak Detection
      final rootJailbreakResult = await _checkRootJailbreak();
      results['rootJailbreak'] = rootJailbreakResult.isSecure;
      if (!rootJailbreakResult.isSecure) {
        violations.add(rootJailbreakResult.reason);
      }

      // 2. Device Security Checks
      final deviceSecurityResult = await _checkDeviceSecurity();
      results['deviceSecurity'] = deviceSecurityResult.isSecure;
      if (!deviceSecurityResult.isSecure) {
        violations.add(deviceSecurityResult.reason);
      }

      // 3. App Integrity Check
      final integrityResult = await _checkAppIntegrity();
      results['appIntegrity'] = integrityResult.isSecure;
      if (!integrityResult.isSecure) {
        violations.add(integrityResult.reason);
      }

      // 4. Debug Detection
      final debugResult = await _checkDebugMode();
      results['debugMode'] = debugResult.isSecure;
      if (!debugResult.isSecure) {
        violations.add(debugResult.reason);
      }

      // 5. Emulator Detection
      final emulatorResult = await _checkEmulator();
      results['emulator'] = emulatorResult.isSecure;
      if (!emulatorResult.isSecure) {
        violations.add(emulatorResult.reason);
      }

      _isDeviceSecure = violations.isEmpty;
      _securityViolationReason = violations.join(', ');
      _isSecurityCheckComplete = true;

      return SecurityCheckResult(
        isSecure: _isDeviceSecure,
        violations: violations,
        checkResults: results,
      );
    } catch (e) {
      debugPrint('Security check error: $e');
      _isDeviceSecure = false;
      _securityViolationReason = 'Security check failed: $e';
      _isSecurityCheckComplete = true;
      
      return SecurityCheckResult(
        isSecure: false,
        violations: ['Security check failed'],
        checkResults: {},
      );
    }
  }

  /// Check for root/jailbreak
  Future<SecurityResult> _checkRootJailbreak() async {
    try {
      // Using safe_device for comprehensive detection
      final isJailbroken = await SafeDevice.isJailBroken;
      final isRealDevice = await SafeDevice.isRealDevice;
      final isDevelopmentModeEnable = await SafeDevice.isDevelopmentModeEnable;
      
      final violations = <String>[];
      
      if (isJailbroken) {
        violations.add('Device is jailbroken/rooted');
      }
      
      if (!isRealDevice) {
        violations.add('Not running on real device');
      }
      
      if (isDevelopmentModeEnable) {
        violations.add('Developer mode is enabled');
      }
      
      if (violations.isNotEmpty) {
        return SecurityResult(
          isSecure: false,
          reason: violations.join(', '),
        );
      }
      
      return SecurityResult(isSecure: true, reason: '');
    } catch (e) {
      debugPrint('Root/Jailbreak check error: $e');
      return SecurityResult(
        isSecure: false,
        reason: 'Root/Jailbreak detection failed',
      );
    }
  }

  /// Check device security features
  Future<SecurityResult> _checkDeviceSecurity() async {
    try {
      final isDevelopmentModeEnable = await SafeDevice.isDevelopmentModeEnable;
      final isOnExternalStorage = await SafeDevice.isOnExternalStorage;
      
      final violations = <String>[];
      
      if (isDevelopmentModeEnable) {
        violations.add('Developer mode enabled');
      }
      
      if (isOnExternalStorage) {
        violations.add('App installed on external storage');
      }
      
      if (violations.isNotEmpty) {
        return SecurityResult(
          isSecure: false,
          reason: violations.join(', '),
        );
      }
      
      return SecurityResult(isSecure: true, reason: '');
    } catch (e) {
      debugPrint('Device security check error: $e');
      return SecurityResult(
        isSecure: false,
        reason: 'Device security check failed',
      );
    }
  }

  /// Check app integrity
  Future<SecurityResult> _checkAppIntegrity() async {
    try {
      // Check if app is signed with debug key (basic check)
      if (kDebugMode) {
        return SecurityResult(
          isSecure: false,
          reason: 'App running in debug mode',
        );
      }
      
      // Additional integrity checks can be added here
      // For example, checking package signature, app store validation, etc.
      
      return SecurityResult(isSecure: true, reason: '');
    } catch (e) {
      debugPrint('App integrity check error: $e');
      return SecurityResult(
        isSecure: false,
        reason: 'App integrity check failed',
      );
    }
  }

  /// Check for debug mode
  Future<SecurityResult> _checkDebugMode() async {
    try {
      if (kDebugMode) {
        return SecurityResult(
          isSecure: false,
          reason: 'App is running in debug mode',
        );
      }
      
      return SecurityResult(isSecure: true, reason: '');
    } catch (e) {
      return SecurityResult(
        isSecure: false,
        reason: 'Debug mode check failed',
      );
    }
  }

  /// Check for emulator
  Future<SecurityResult> _checkEmulator() async {
    try {
      final deviceInfo = DeviceInfoPlugin();
      
      if (Platform.isAndroid) {
        final androidInfo = await deviceInfo.androidInfo;
        
        // Common emulator indicators
        final emulatorIndicators = [
          'google_sdk',
          'Emulator',
          'Android SDK built for x86',
          'sdk_gphone',
          'generic',
        ];
        
        final model = androidInfo.model.toLowerCase();
        final product = androidInfo.product.toLowerCase();
        final hardware = androidInfo.hardware.toLowerCase();
        
        for (final indicator in emulatorIndicators) {
          if (model.contains(indicator.toLowerCase()) ||
              product.contains(indicator.toLowerCase()) ||
              hardware.contains(indicator.toLowerCase())) {
            return SecurityResult(
              isSecure: false,
              reason: 'App is running on emulator',
            );
          }
        }
      } else if (Platform.isIOS) {
        final iosInfo = await deviceInfo.iosInfo;
        
        if (!iosInfo.isPhysicalDevice) {
          return SecurityResult(
            isSecure: false,
            reason: 'App is running on iOS simulator',
          );
        }
      }
      
      return SecurityResult(isSecure: true, reason: '');
    } catch (e) {
      debugPrint('Emulator check error: $e');
      return SecurityResult(
        isSecure: false,
        reason: 'Emulator detection failed',
      );
    }
  }

  /// Generate app signature hash for integrity verification
  Future<String> generateAppSignatureHash() async {
    try {
      final packageInfo = await PackageInfo.fromPlatform();
      final appData = '${packageInfo.packageName}${packageInfo.version}${packageInfo.buildNumber}';
      final bytes = utf8.encode(appData);
      final digest = sha256.convert(bytes);
      return digest.toString();
    } catch (e) {
      debugPrint('App signature hash generation error: $e');
      return '';
    }
  }

  /// Anti-debugging measures
  void enableAntiDebugging() {
    if (kDebugMode) return;
    
    // Disable debug banner
    // This should be done in main.dart: debugShowCheckedModeBanner: false
    
    // Additional anti-debugging measures can be implemented here
    // Note: Some measures might require platform-specific code
  }

  /// Check if app is running on a secure network
  Future<bool> isNetworkSecure() async {
    try {
      // This is a basic implementation
      // In production, you might want to check for VPN, proxy, etc.
      return true;
    } catch (e) {
      debugPrint('Network security check error: $e');
      return false;
    }
  }

  /// Clear sensitive data from memory
  void clearSensitiveData() {
    // Clear any cached sensitive data
    // This method should be called when security violations are detected
    _securityViolationReason = '';
  }
}

class SecurityCheckResult {
  final bool isSecure;
  final List<String> violations;
  final Map<String, bool> checkResults;

  SecurityCheckResult({
    required this.isSecure,
    required this.violations,
    required this.checkResults,
  });

  @override
  String toString() {
    return 'SecurityCheckResult(isSecure: $isSecure, violations: $violations)';
  }
}

class SecurityResult {
  final bool isSecure;
  final String reason;

  SecurityResult({
    required this.isSecure,
    required this.reason,
  });
}

// Security exception for handling security violations
class SecurityViolationException implements Exception {
  final String message;
  final List<String> violations;

  SecurityViolationException(this.message, this.violations);

  @override
  String toString() => 'SecurityViolationException: $message';
}
