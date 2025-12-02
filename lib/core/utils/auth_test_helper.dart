import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'auth_debug_helper.dart';

class AuthTestHelper {
  /// Show authentication test dialog for debugging
  static void showAuthTestDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => const AuthTestDialog(),
    );
  }
}

class AuthTestDialog extends StatefulWidget {
  const AuthTestDialog({super.key});

  @override
  State<AuthTestDialog> createState() => _AuthTestDialogState();
}

class _AuthTestDialogState extends State<AuthTestDialog> {
  final _testResults = <String, dynamic>{};
  bool _isRunningTests = false;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Authentication Tests'),
      content: SizedBox(
        width: double.maxFinite,
        height: 400,
        child: Column(
          children: [
            ElevatedButton(
              onPressed: _isRunningTests ? null : _runAllTests,
              child: _isRunningTests 
                ? const CircularProgressIndicator()
                : const Text('Run All Tests'),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: ListView(
                children: [
                  _buildTestButton('Firebase Connection', _testFirebaseConnection),
                  _buildTestButton('Google Sign-In Config', _testGoogleSignInConfig),
                  _buildTestButton('Auth Diagnostics', _runDiagnostics),
                  _buildTestButton('Clear Auth Data', _clearAuthData),
                  const Divider(),
                  const Text('Test Results:', style: TextStyle(fontWeight: FontWeight.bold)),
                  ..._testResults.entries.map((entry) => 
                    ListTile(
                      title: Text(entry.key),
                      subtitle: Text(entry.value.toString()),
                      leading: Icon(
                        entry.value is bool && entry.value 
                          ? Icons.check_circle 
                          : Icons.error,
                        color: entry.value is bool && entry.value 
                          ? Colors.green 
                          : Colors.red,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Close'),
        ),
      ],
    );
  }

  Widget _buildTestButton(String title, VoidCallback onPressed) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: ElevatedButton(
        onPressed: _isRunningTests ? null : onPressed,
        child: Text(title),
      ),
    );
  }

  Future<void> _runAllTests() async {
    setState(() {
      _isRunningTests = true;
      _testResults.clear();
    });

    await _testFirebaseConnection();
    await _testGoogleSignInConfig();
    await _runDiagnostics();

    setState(() {
      _isRunningTests = false;
    });

    if (kDebugMode) {
      print('🧪 All authentication tests completed');
    }
  }

  Future<void> _testFirebaseConnection() async {
    try {
      final result = await AuthDebugHelper.testFirebaseConnection();
      setState(() {
        _testResults['Firebase Connection'] = result;
      });
    } catch (e) {
      setState(() {
        _testResults['Firebase Connection'] = 'Error: $e';
      });
    }
  }

  Future<void> _testGoogleSignInConfig() async {
    try {
      final result = await AuthDebugHelper.testGoogleSignInConfig();
      setState(() {
        _testResults['Google Sign-In Config'] = result;
      });
    } catch (e) {
      setState(() {
        _testResults['Google Sign-In Config'] = 'Error: $e';
      });
    }
  }

  Future<void> _runDiagnostics() async {
    try {
      final diagnostics = await AuthDebugHelper.performAuthDiagnostics();
      setState(() {
        _testResults.addAll(diagnostics);
      });
    } catch (e) {
      setState(() {
        _testResults['Diagnostics'] = 'Error: $e';
      });
    }
  }

  Future<void> _clearAuthData() async {
    try {
      await AuthDebugHelper.clearAuthData();
      setState(() {
        _testResults['Clear Auth Data'] = 'Success';
      });
      
      // Auth state listener will handle the sign out automatically
    } catch (e) {
      setState(() {
        _testResults['Clear Auth Data'] = 'Error: $e';
      });
    }
  }
}
