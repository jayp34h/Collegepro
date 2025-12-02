import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../core/services/database_service.dart';
import 'dart:developer' as developer;

class TestRegistrationScreen extends StatefulWidget {
  const TestRegistrationScreen({super.key});

  @override
  State<TestRegistrationScreen> createState() => _TestRegistrationScreenState();
}

class _TestRegistrationScreenState extends State<TestRegistrationScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _nameController = TextEditingController();
  final DatabaseService _databaseService = DatabaseService();
  bool _isLoading = false;
  String _status = '';

  @override
  void initState() {
    super.initState();
    _emailController.text = 'test${DateTime.now().millisecondsSinceEpoch}@example.com';
    _passwordController.text = 'testpassword123';
    _nameController.text = 'Test User';
  }

  Future<void> _testDatabaseConnection() async {
    setState(() {
      _isLoading = true;
      _status = 'Testing database connection...';
    });

    try {
      // Simple database connection test
      await _databaseService.createUser(
        userId: 'test_connection_${DateTime.now().millisecondsSinceEpoch}',
        email: 'test@connection.com',
        displayName: 'Connection Test',
        additionalData: {'connectionTest': true},
      );
      setState(() {
        _status = 'Database connection test completed successfully!';
      });
    } catch (e) {
      setState(() {
        _status = 'Database connection failed: $e';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _testUserRegistration() async {
    setState(() {
      _isLoading = true;
      _status = 'Creating test user...';
    });

    try {
      final email = _emailController.text.trim();
      final password = _passwordController.text.trim();
      final name = _nameController.text.trim();

      developer.log('🚀 Starting test user registration...');
      developer.log('Email: $email');
      developer.log('Name: $name');

      // Create user with Firebase Auth
      final credential = await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      final user = credential.user;
      if (user == null) {
        throw Exception('User creation failed - no user returned');
      }

      developer.log('✅ Firebase Auth user created: ${user.uid}');

      // Update display name
      await user.updateDisplayName(name);
      await user.reload();
      
      developer.log('✅ Display name updated to: $name');

      // Store user data in Realtime Database
      await _databaseService.createUser(
        userId: user.uid,
        email: email,
        displayName: name,
        additionalData: {
          'registrationMethod': 'test',
          'isEmailVerified': user.emailVerified,
          'testUser': true,
        },
      );

      developer.log('✅ User data stored in Realtime Database');

      setState(() {
        _status = 'Test user created successfully! UID: ${user.uid}\nCheck Firebase Console for data.';
      });

    } catch (e) {
      developer.log('❌ Test registration failed: $e');
      setState(() {
        _status = 'Registration failed: $e';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _cleanupTestUser() async {
    setState(() {
      _isLoading = true;
      _status = 'Cleaning up test user...';
    });

    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        await user.delete();
        developer.log('✅ Test user deleted from Firebase Auth');
      }

      setState(() {
        _status = 'Test user cleaned up successfully!';
      });
    } catch (e) {
      setState(() {
        _status = 'Cleanup failed: $e';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Test User Registration'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              'Test Firebase Realtime Database Integration',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            
            TextField(
              controller: _emailController,
              decoration: const InputDecoration(
                labelText: 'Test Email',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            
            TextField(
              controller: _passwordController,
              decoration: const InputDecoration(
                labelText: 'Test Password',
                border: OutlineInputBorder(),
              ),
              obscureText: true,
            ),
            const SizedBox(height: 16),
            
            TextField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: 'Test Name',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 20),
            
            ElevatedButton(
              onPressed: _isLoading ? null : _testDatabaseConnection,
              child: const Text('Test Database Connection'),
            ),
            const SizedBox(height: 12),
            
            ElevatedButton(
              onPressed: _isLoading ? null : _testUserRegistration,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                foregroundColor: Colors.white,
              ),
              child: const Text('Test User Registration'),
            ),
            const SizedBox(height: 12),
            
            ElevatedButton(
              onPressed: _isLoading ? null : _cleanupTestUser,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
              ),
              child: const Text('Cleanup Test User'),
            ),
            const SizedBox(height: 20),
            
            if (_isLoading)
              const Center(child: CircularProgressIndicator()),
            
            if (_status.isNotEmpty)
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.grey[300]!),
                ),
                child: Text(
                  _status,
                  style: const TextStyle(fontSize: 14),
                ),
              ),
            
            const SizedBox(height: 20),
            const Text(
              'Instructions:\n'
              '1. Test Database Connection first\n'
              '2. Test User Registration to create a user\n'
              '3. Check Firebase Console for data\n'
              '4. Cleanup when done testing\n'
              '5. Check console logs for detailed output',
              style: TextStyle(fontSize: 12, color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _nameController.dispose();
    super.dispose();
  }
}
