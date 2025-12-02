import 'dart:convert';
import 'package:flutter/foundation.dart';

/// Utility class for moving heavy computations off the main thread
class ComputeUtils {
  /// Parse JSON data in a separate isolate to avoid blocking UI
  static Future<Map<String, dynamic>> parseJsonInBackground(String jsonString) async {
    if (kIsWeb) {
      // Web doesn't support isolates, so use microtask
      return await Future.microtask(() => json.decode(jsonString));
    }
    return await compute(_parseJson, jsonString);
  }

  /// Process user data in background to avoid UI blocking
  static Future<Map<String, dynamic>> processUserDataInBackground(
    Map<String, dynamic> userData,
  ) async {
    if (kIsWeb) {
      return await Future.microtask(() => _processUserData(userData));
    }
    return await compute(_processUserData, userData);
  }
}

// Functions for compute() - these run in isolates
Map<String, dynamic> _parseJson(String jsonString) {
  return json.decode(jsonString);
}

Map<String, dynamic> _processUserData(Map<String, dynamic> userData) {
  // Process user data without blocking UI
  final processed = Map<String, dynamic>.from(userData);
  
  // Add computed fields
  processed['displayName'] = processed['displayName'] ?? 'User';
  processed['initials'] = _getInitials(processed['displayName']);
  processed['profileComplete'] = _calculateProfileCompleteness(processed);
  
  return processed;
}

String _getInitials(String name) {
  if (name.isEmpty) return 'U';
  final parts = name.split(' ');
  if (parts.length == 1) return parts[0][0].toUpperCase();
  return '${parts[0][0]}${parts[parts.length - 1][0]}'.toUpperCase();
}

double _calculateProfileCompleteness(Map<String, dynamic> userData) {
  int completedFields = 0;
  int totalFields = 6;
  
  if (userData['displayName']?.toString().isNotEmpty == true) completedFields++;
  if (userData['email']?.toString().isNotEmpty == true) completedFields++;
  if (userData['phoneNumber']?.toString().isNotEmpty == true) completedFields++;
  if (userData['institution']?.toString().isNotEmpty == true) completedFields++;
  if (userData['course']?.toString().isNotEmpty == true) completedFields++;
  if (userData['yearOfStudy']?.toString().isNotEmpty == true) completedFields++;
  
  return completedFields / totalFields;
}
