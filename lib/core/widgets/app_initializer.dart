import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/user_provider.dart';

class AppInitializer extends StatefulWidget {
  final Widget child;
  
  const AppInitializer({
    super.key,
    required this.child,
  });

  @override
  State<AppInitializer> createState() => _AppInitializerState();
}

class _AppInitializerState extends State<AppInitializer> {
  bool _isInitialized = false;

  @override
  void initState() {
    super.initState();
    _initializeApp();
  }

  Future<void> _initializeApp() async {
    // Wait for both providers to be fully initialized
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    
    // Wait for UserProvider initialization
    if (!userProvider.isInitialized) {
      await userProvider.initializationFuture;
    }
    
    // Give AuthProvider time to initialize auth state
    await Future.delayed(const Duration(milliseconds: 1000));
    
    // Mark as initialized
    if (mounted) {
      setState(() {
        _isInitialized = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!_isInitialized) {
      return const Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(),
              SizedBox(height: 16),
              Text('Initializing app...'),
            ],
          ),
        ),
      );
    }
    
    return widget.child;
  }
}
