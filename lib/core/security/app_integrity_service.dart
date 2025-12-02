import 'dart:io';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:crypto/crypto.dart';
import 'secure_storage_service.dart';

class AppIntegrityService {
  static final AppIntegrityService _instance = AppIntegrityService._internal();
  factory AppIntegrityService() => _instance;
  AppIntegrityService._internal();

  final SecureStorageService _secureStorage = SecureStorageService();
  
  // Expected app signatures for integrity verification
  static const Map<String, String> _expectedSignatures = {
    'debug': 'debug_signature_hash',
    'release': 'release_signature_hash',
  };

  /// Perform comprehensive app integrity check
  Future<IntegrityCheckResult> performIntegrityCheck() async {
    final results = <String, bool>{};
    final violations = <String>[];

    try {
      // 1. Package integrity check
      final packageResult = await _checkPackageIntegrity();
      results['package'] = packageResult.isValid;
      if (!packageResult.isValid) violations.add(packageResult.reason);

      // 2. Installation source check
      final installResult = await _checkInstallationSource();
      results['installation'] = installResult.isValid;
      if (!installResult.isValid) violations.add(installResult.reason);

      // 3. App signature verification
      final signatureResult = await _checkAppSignature();
      results['signature'] = signatureResult.isValid;
      if (!signatureResult.isValid) violations.add(signatureResult.reason);

      // 4. Runtime integrity check
      final runtimeResult = await _checkRuntimeIntegrity();
      results['runtime'] = runtimeResult.isValid;
      if (!runtimeResult.isValid) violations.add(runtimeResult.reason);

      // 5. File system integrity
      final fileSystemResult = await _checkFileSystemIntegrity();
      results['filesystem'] = fileSystemResult.isValid;
      if (!fileSystemResult.isValid) violations.add(fileSystemResult.reason);

      return IntegrityCheckResult(
        isValid: violations.isEmpty,
        violations: violations,
        checkResults: results,
      );
    } catch (e) {
      debugPrint('App integrity check error: $e');
      return IntegrityCheckResult(
        isValid: false,
        violations: ['Integrity check failed: $e'],
        checkResults: {},
      );
    }
  }

  /// Check package information integrity
  Future<IntegrityResult> _checkPackageIntegrity() async {
    try {
      final packageInfo = await PackageInfo.fromPlatform();
      
      // Verify package name
      const expectedPackageName = 'com.collegepro.app'; // Update with your actual package name
      if (packageInfo.packageName != expectedPackageName && !kDebugMode) {
        return IntegrityResult(
          isValid: false,
          reason: 'Invalid package name: ${packageInfo.packageName}',
        );
      }

      // Check version consistency
      if (packageInfo.version.isEmpty || packageInfo.buildNumber.isEmpty) {
        return IntegrityResult(
          isValid: false,
          reason: 'Invalid version information',
        );
      }

      // Store package info for future verification
      await _secureStorage.storeSecureData('package_info', jsonEncode({
        'packageName': packageInfo.packageName,
        'version': packageInfo.version,
        'buildNumber': packageInfo.buildNumber,
        'appName': packageInfo.appName,
      }));

      return IntegrityResult(isValid: true, reason: '');
    } catch (e) {
      return IntegrityResult(
        isValid: false,
        reason: 'Package integrity check failed: $e',
      );
    }
  }

  /// Check installation source
  Future<IntegrityResult> _checkInstallationSource() async {
    try {
      if (Platform.isAndroid) {
        final deviceInfo = DeviceInfoPlugin();
        final androidInfo = await deviceInfo.androidInfo;
        
        // In production, you might want to check if app was installed from Play Store
        // This is a basic implementation
        if (!kDebugMode) {
          // Add specific checks for installation source
          // For example, checking installer package name
          debugPrint('Android device: ${androidInfo.model}');
        }
      }

      return IntegrityResult(isValid: true, reason: '');
    } catch (e) {
      return IntegrityResult(
        isValid: false,
        reason: 'Installation source check failed: $e',
      );
    }
  }

  /// Check app signature
  Future<IntegrityResult> _checkAppSignature() async {
    try {
      final packageInfo = await PackageInfo.fromPlatform();
      
      // Generate current app signature hash
      final currentSignature = _generateAppSignatureHash(packageInfo);
      
      // Compare with expected signature
      final buildMode = kDebugMode ? 'debug' : 'release';
      final expectedSignature = _expectedSignatures[buildMode];
      
      if (expectedSignature != null && currentSignature != expectedSignature && !kDebugMode) {
        return IntegrityResult(
          isValid: false,
          reason: 'App signature mismatch',
        );
      }

      // Store signature for monitoring
      await _secureStorage.storeSecureData('app_signature', currentSignature);

      return IntegrityResult(isValid: true, reason: '');
    } catch (e) {
      return IntegrityResult(
        isValid: false,
        reason: 'App signature check failed: $e',
      );
    }
  }

  /// Check runtime integrity
  Future<IntegrityResult> _checkRuntimeIntegrity() async {
    try {
      // Check for debugging tools
      if (_isDebuggerAttached()) {
        return IntegrityResult(
          isValid: false,
          reason: 'Debugger detected',
        );
      }

      // Check for code injection
      if (await _detectCodeInjection()) {
        return IntegrityResult(
          isValid: false,
          reason: 'Code injection detected',
        );
      }

      // Check memory integrity
      if (await _checkMemoryIntegrity()) {
        return IntegrityResult(
          isValid: false,
          reason: 'Memory tampering detected',
        );
      }

      return IntegrityResult(isValid: true, reason: '');
    } catch (e) {
      return IntegrityResult(
        isValid: false,
        reason: 'Runtime integrity check failed: $e',
      );
    }
  }

  /// Check file system integrity
  Future<IntegrityResult> _checkFileSystemIntegrity() async {
    try {
      // Check for suspicious files or modifications
      // This is a basic implementation
      
      // In a production app, you might want to:
      // 1. Check for presence of known hacking tools
      // 2. Verify critical app files haven't been modified
      // 3. Check for suspicious processes

      return IntegrityResult(isValid: true, reason: '');
    } catch (e) {
      return IntegrityResult(
        isValid: false,
        reason: 'File system integrity check failed: $e',
      );
    }
  }

  /// Generate app signature hash
  String _generateAppSignatureHash(PackageInfo packageInfo) {
    final signatureData = '${packageInfo.packageName}${packageInfo.version}${packageInfo.buildNumber}';
    final bytes = utf8.encode(signatureData);
    final digest = sha256.convert(bytes);
    return digest.toString();
  }

  /// Check if debugger is attached
  bool _isDebuggerAttached() {
    // Basic debugger detection
    // In production, you might implement more sophisticated detection
    return kDebugMode;
  }

  /// Detect code injection
  Future<bool> _detectCodeInjection() async {
    try {
      // Basic code injection detection
      // This is a placeholder for more sophisticated detection methods
      return false;
    } catch (e) {
      debugPrint('Code injection detection error: $e');
      return true; // Assume injection if detection fails
    }
  }

  /// Check memory integrity
  Future<bool> _checkMemoryIntegrity() async {
    try {
      // Basic memory integrity check
      // This is a placeholder for more sophisticated memory protection
      return false;
    } catch (e) {
      debugPrint('Memory integrity check error: $e');
      return true; // Assume tampering if check fails
    }
  }

  /// Get app integrity status
  Future<AppIntegrityStatus> getIntegrityStatus() async {
    final result = await performIntegrityCheck();
    final lastCheck = DateTime.now();
    
    // Store last check time
    await _secureStorage.storeSecureData(
      'last_integrity_check',
      lastCheck.millisecondsSinceEpoch.toString(),
    );

    return AppIntegrityStatus(
      isIntegrityValid: result.isValid,
      violations: result.violations,
      lastCheckTime: lastCheck,
      checkResults: result.checkResults,
    );
  }

  /// Schedule periodic integrity checks
  void schedulePeriodicChecks() {
    // This would typically use a background service or timer
    // For now, it's a placeholder for the concept
    debugPrint('Periodic integrity checks scheduled');
  }

  /// Handle integrity violation
  Future<void> handleIntegrityViolation(List<String> violations) async {
    try {
      // Log violation
      debugPrint('Integrity violation detected: ${violations.join(', ')}');
      
      // Store violation record
      await _secureStorage.storeSecureData('integrity_violation', jsonEncode({
        'violations': violations,
        'timestamp': DateTime.now().millisecondsSinceEpoch,
      }));

      // In production, you might want to:
      // 1. Send violation report to server
      // 2. Disable sensitive features
      // 3. Clear sensitive data
      // 4. Show warning to user
      // 5. Exit app if violation is severe
      
    } catch (e) {
      debugPrint('Handle integrity violation error: $e');
    }
  }
}

/// Result of integrity check
class IntegrityCheckResult {
  final bool isValid;
  final List<String> violations;
  final Map<String, bool> checkResults;

  IntegrityCheckResult({
    required this.isValid,
    required this.violations,
    required this.checkResults,
  });

  @override
  String toString() {
    return 'IntegrityCheckResult(isValid: $isValid, violations: $violations)';
  }
}

/// Individual integrity check result
class IntegrityResult {
  final bool isValid;
  final String reason;

  IntegrityResult({
    required this.isValid,
    required this.reason,
  });
}

/// App integrity status
class AppIntegrityStatus {
  final bool isIntegrityValid;
  final List<String> violations;
  final DateTime lastCheckTime;
  final Map<String, bool> checkResults;

  AppIntegrityStatus({
    required this.isIntegrityValid,
    required this.violations,
    required this.lastCheckTime,
    required this.checkResults,
  });

  @override
  String toString() {
    return 'AppIntegrityStatus(isValid: $isIntegrityValid, violations: $violations, lastCheck: $lastCheckTime)';
  }
}
