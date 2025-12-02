import 'package:flutter/material.dart';

/// Lightweight wrapper for drawer screens with optimized navigation
class DrawerScreenWrapper extends StatelessWidget {
  final Widget child;
  final String title;
  
  const DrawerScreenWrapper({
    super.key,
    required this.child,
    required this.title,
  });

  /// Navigate back to dashboard without refreshing - preserves dashboard state
  static void openDrawer(BuildContext context) {
    // Always use Navigator.pop() to return to existing MainNavigation instance
    // This prevents dashboard refresh and preserves state
    // Since drawer screens are pushed via context.push(), pop() will always work
    Navigator.pop(context);
  }

  /// Safe navigation to dashboard - preserves existing state
  static void navigateToDashboard(BuildContext context) {
    // Always use Navigator.pop() to return to existing MainNavigation instance
    // This prevents dashboard refresh and preserves state
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    // Minimal wrapper - just return child directly
    return child;
  }
}
