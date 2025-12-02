import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:async';
import '../../core/providers/auth_provider.dart';

class EmailVerificationScreen extends StatefulWidget {
  const EmailVerificationScreen({super.key});

  @override
  State<EmailVerificationScreen> createState() => _EmailVerificationScreenState();
}

class _EmailVerificationScreenState extends State<EmailVerificationScreen>
    with TickerProviderStateMixin {
  Timer? _timer;
  bool _isCheckingVerification = false;
  late AnimationController _pulseController;
  late AnimationController _fadeController;
  late Animation<double> _pulseAnimation;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    
    // Initialize animations
    _pulseController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..repeat();
    
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    )..forward();
    
    _pulseAnimation = Tween<double>(
      begin: 0.8,
      end: 1.2,
    ).animate(CurvedAnimation(
      parent: _pulseController,
      curve: Curves.easeInOut,
    ));
    
    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeOut,
    ));
    
    // Start checking for email verification every 3 seconds
    _startVerificationCheck();
  }

  @override
  void dispose() {
    _timer?.cancel();
    _pulseController.dispose();
    _fadeController.dispose();
    super.dispose();
  }

  void _startVerificationCheck() {
    _timer = Timer.periodic(const Duration(seconds: 3), (timer) async {
      if (!mounted) return;
      
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      await authProvider.checkEmailVerification();
      
      // If email is verified, navigate to dashboard
      if (authProvider.isEmailVerified) {
        timer.cancel();
        if (mounted) {
          Navigator.of(context).pushReplacementNamed('/dashboard');
        }
      }
    });
  }

  Future<void> _resendVerification() async {
    setState(() {
      _isCheckingVerification = true;
    });

    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    await authProvider.resendEmailVerification();

    setState(() {
      _isCheckingVerification = false;
    });

    if (mounted && authProvider.errorMessage != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(authProvider.errorMessage!),
          backgroundColor: authProvider.errorMessage!.contains('sent') 
              ? const Color(0xFF2E7D32) 
              : Colors.red,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      );
    }
  }

  Future<void> _checkVerificationManually() async {
    setState(() {
      _isCheckingVerification = true;
    });

    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    await authProvider.checkEmailVerification();

    setState(() {
      _isCheckingVerification = false;
    });

    if (authProvider.isEmailVerified) {
      if (mounted) {
        Navigator.of(context).pushReplacementNamed('/dashboard');
      }
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Email not verified yet. Please check your inbox and click the verification link.'),
            backgroundColor: Colors.orange,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    const educationalBlue = Color(0xFF2E5BBA);
    const educationalGreen = Color(0xFF2E7D32);
    
    return Scaffold(
      backgroundColor: const Color(0xFFF3F7FF),
      body: SafeArea(
        child: FadeTransition(
          opacity: _fadeAnimation,
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              children: [
                // Header
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 20),
                  child: Row(
                    children: [
                      IconButton(
                        onPressed: () => Navigator.of(context).pop(),
                        icon: const Icon(
                          Icons.arrow_back_ios_rounded,
                          color: educationalBlue,
                        ),
                      ),
                      const Expanded(
                        child: Text(
                          'Verify Your Email',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w700,
                            color: educationalBlue,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                      const SizedBox(width: 48), // Balance the back button
                    ],
                  ),
                ),
                
                const SizedBox(height: 40),
                
                // Main Content
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Animated Email Icon
                      AnimatedBuilder(
                        animation: _pulseAnimation,
                        builder: (context, child) {
                          return Transform.scale(
                            scale: _pulseAnimation.value,
                            child: Container(
                              width: 120,
                              height: 120,
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: [
                                    educationalBlue.withOpacity(0.1),
                                    educationalGreen.withOpacity(0.1),
                                  ],
                                ),
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: educationalBlue.withOpacity(0.3),
                                  width: 2,
                                ),
                              ),
                              child: const Icon(
                                Icons.mark_email_unread_rounded,
                                size: 60,
                                color: educationalBlue,
                              ),
                            ),
                          );
                        },
                      ),
                      
                      const SizedBox(height: 32),
                      
                      // Title
                      const Text(
                        '📧 Check Your Email',
                        style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.w800,
                          color: educationalBlue,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      
                      const SizedBox(height: 16),
                      
                      // Description
                      Consumer<AuthProvider>(
                        builder: (context, authProvider, child) {
                          return Text(
                            'We\'ve sent a verification link to:\n${authProvider.user?.email ?? "your email"}',
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.grey[600],
                              height: 1.5,
                            ),
                            textAlign: TextAlign.center,
                          );
                        },
                      ),
                      
                      const SizedBox(height: 24),
                      
                      // Instructions
                      Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: educationalBlue.withOpacity(0.1),
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: educationalBlue.withOpacity(0.05),
                              blurRadius: 10,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Column(
                          children: [
                            _buildInstructionStep(
                              '1',
                              'Open your email app',
                              Icons.email_outlined,
                            ),
                            const SizedBox(height: 16),
                            _buildInstructionStep(
                              '2',
                              'Find the verification email',
                              Icons.search_rounded,
                            ),
                            const SizedBox(height: 16),
                            _buildInstructionStep(
                              '3',
                              'Click the verification link',
                              Icons.link_rounded,
                            ),
                          ],
                        ),
                      ),
                      
                      const SizedBox(height: 32),
                      
                      // Action Buttons
                      Column(
                        children: [
                          // Check Verification Button
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton.icon(
                              onPressed: _isCheckingVerification 
                                  ? null 
                                  : _checkVerificationManually,
                              icon: _isCheckingVerification
                                  ? const SizedBox(
                                      width: 20,
                                      height: 20,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                      ),
                                    )
                                  : const Icon(Icons.refresh_rounded),
                              label: Text(
                                _isCheckingVerification 
                                    ? 'Checking...' 
                                    : 'I\'ve Verified My Email',
                              ),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: educationalBlue,
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(vertical: 16),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                elevation: 2,
                              ),
                            ),
                          ),
                          
                          const SizedBox(height: 12),
                          
                          // Resend Email Button
                          SizedBox(
                            width: double.infinity,
                            child: OutlinedButton.icon(
                              onPressed: _isCheckingVerification 
                                  ? null 
                                  : _resendVerification,
                              icon: const Icon(Icons.send_rounded),
                              label: const Text('Resend Verification Email'),
                              style: OutlinedButton.styleFrom(
                                foregroundColor: educationalBlue,
                                side: const BorderSide(color: educationalBlue),
                                padding: const EdgeInsets.symmetric(vertical: 16),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                
                // Footer
                Padding(
                  padding: const EdgeInsets.only(bottom: 20),
                  child: Text(
                    'Can\'t find the email? Check your spam folder',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[500],
                      fontStyle: FontStyle.italic,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildInstructionStep(String number, String text, IconData icon) {
    const educationalBlue = Color(0xFF2E5BBA);
    
    return Row(
      children: [
        Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            color: educationalBlue,
            shape: BoxShape.circle,
          ),
          child: Center(
            child: Text(
              number,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w600,
                fontSize: 14,
              ),
            ),
          ),
        ),
        const SizedBox(width: 16),
        Icon(
          icon,
          color: educationalBlue,
          size: 20,
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            text,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: Colors.grey[700],
            ),
          ),
        ),
      ],
    );
  }
}
