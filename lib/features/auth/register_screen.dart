import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../core/providers/auth_provider.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _phoneController = TextEditingController();
  final _institutionController = TextEditingController();
  final _courseController = TextEditingController();
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  bool _acceptTerms = false;
  String _selectedYear = 'First Year';
  final List<String> _yearOptions = ['First Year', 'Second Year', 'Third Year', 'Final Year', 'Graduate'];

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _phoneController.dispose();
    _institutionController.dispose();
    _courseController.dispose();
    super.dispose();
  }

  Future<void> _signUp() async {
    if (_formKey.currentState!.validate() && _acceptTerms) {
      try {
        print('Starting registration process...');
        final authProvider = Provider.of<AuthProvider>(context, listen: false);
        
        print('Calling createUserWithEmailAndPassword...');
        final success = await authProvider.createUserWithEmailAndPassword(
          _emailController.text.trim(),
          _passwordController.text,
          _nameController.text.trim(),
          phoneNumber: _phoneController.text.trim().isNotEmpty ? _phoneController.text.trim() : null,
          institution: _institutionController.text.trim().isNotEmpty ? _institutionController.text.trim() : null,
          course: _courseController.text.trim().isNotEmpty ? _courseController.text.trim() : null,
          yearOfStudy: _selectedYear != 'Select Year' ? _selectedYear : null,
        );

        print('Registration result: $success, mounted: $mounted');
        
        if (success && mounted) {
          print('Showing email verification popup...');
          // Add delay to ensure UI is ready
          await Future.delayed(const Duration(milliseconds: 500));
          
          // Show modern email verification popup with Go to Login button
          showDialog(
            context: context,
            barrierDismissible: false,
            builder: (BuildContext dialogContext) {
              return Dialog(
                backgroundColor: Colors.transparent,
                child: Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 20,
                        offset: const Offset(0, 10),
                      ),
                    ],
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Email Icon with Animation
                      Container(
                        width: 80,
                        height: 80,
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [Color(0xFF667eea), Color(0xFF764ba2)],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: BorderRadius.circular(40),
                        ),
                        child: const Icon(
                          Icons.mark_email_unread_outlined,
                          color: Colors.white,
                          size: 40,
                        ),
                      ),
                      const SizedBox(height: 20),
                      
                      // Title
                      const Text(
                        'Verify Your Email',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF2D3748),
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 12),
                      
                      // Description
                      Text(
                        'We\'ve sent a verification link to:',
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.grey[600],
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 8),
                      
                      // Email Address
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF7FAFC),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: const Color(0xFFE2E8F0)),
                        ),
                        child: Text(
                          _emailController.text.trim(),
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF4A5568),
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                      const SizedBox(height: 20),
                      
                      // Instructions
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF0F8FF),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: const Color(0xFFBEE3F8)),
                        ),
                        child: Row(
                          children: [
                            Container(
                              width: 24,
                              height: 24,
                              decoration: BoxDecoration(
                                color: const Color(0xFF3182CE),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: const Icon(
                                Icons.info_outline,
                                color: Colors.white,
                                size: 16,
                              ),
                            ),
                            const SizedBox(width: 12),
                            const Expanded(
                              child: Text(
                                'Please check your email and click the verification link to continue.',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Color(0xFF2B6CB0),
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 12),
                      
                      // Spam Folder Warning
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFFF8E1),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: const Color(0xFFFFE082)),
                        ),
                        child: Row(
                          children: [
                            Container(
                              width: 32,
                              height: 32,
                              decoration: BoxDecoration(
                                color: const Color(0xFFFF8F00),
                                borderRadius: BorderRadius.circular(16),
                              ),
                              child: const Icon(
                                Icons.folder_special_outlined,
                                color: Colors.white,
                                size: 18,
                              ),
                            ),
                            const SizedBox(width: 12),
                            const Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Check Your Spam Folder!',
                                    style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.bold,
                                      color: Color(0xFFE65100),
                                    ),
                                  ),
                                  SizedBox(height: 4),
                                  Text(
                                    'Sometimes verification emails end up in spam or junk folders. Please check there if you don\'t see it in your inbox.',
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: Color(0xFFEF6C00),
                                      height: 1.3,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 20),
                      
                      // Continue Button
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: () async {
                            print('Continue button pressed - redirecting to Gmail');
                            
                            // Open Gmail in browser
                            const url = 'https://mail.google.com';
                            try {
                              final Uri uri = Uri.parse(url);
                              if (await canLaunchUrl(uri)) {
                                await launchUrl(uri, mode: LaunchMode.externalApplication);
                                print('Gmail opened successfully');
                              } else {
                                print('Could not launch Gmail');
                              }
                            } catch (e) {
                              print('Error launching Gmail: $e');
                            }
                            
                            // Close popup and navigate
                            Navigator.of(dialogContext).pop();
                            
                            // Small delay to ensure popup is closed
                            await Future.delayed(const Duration(milliseconds: 100));
                            
                            // Show success message
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Please check your email and click the verification link'),
                                backgroundColor: Colors.green,
                                behavior: SnackBarBehavior.floating,
                              ),
                            );
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.transparent,
                            shadowColor: Colors.transparent,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ).copyWith(
                            backgroundColor: MaterialStateProperty.all(Colors.transparent),
                          ),
                          child: Ink(
                            decoration: BoxDecoration(
                              gradient: const LinearGradient(
                                colors: [Color(0xFF667eea), Color(0xFF764ba2)],
                                begin: Alignment.centerLeft,
                                end: Alignment.centerRight,
                              ),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Container(
                              alignment: Alignment.center,
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              child: const Text(
                                'Continue to Verification',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      
                      // Go to Login Button
                      SizedBox(
                        width: double.infinity,
                        child: OutlinedButton(
                          onPressed: () async {
                            print('Go to Login button pressed');
                            
                            // Close popup first
                            Navigator.of(dialogContext).pop();
                            
                            // Small delay to ensure popup is closed
                            await Future.delayed(const Duration(milliseconds: 100));
                            
                            // Navigate to login using GoRouter
                            if (mounted) {
                              context.go('/login');
                            }
                          },
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            side: const BorderSide(
                              color: Color(0xFF667eea),
                              width: 2,
                            ),
                          ),
                          child: const Text(
                            'Go to Login',
                            style: TextStyle(
                              color: Color(0xFF667eea),
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
          print('Email verification popup displayed directly');
        } else if (mounted) {
          print('Registration failed: ${authProvider.errorMessage}');
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(authProvider.errorMessage ?? 'Registration failed'),
              backgroundColor: Colors.red,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          );
        }
      } catch (e) {
        print('Exception during registration: $e');
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Registration error: $e'),
              backgroundColor: Colors.red,
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
      }
    } else if (!_acceptTerms) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please accept the terms and conditions'),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  Future<void> _signInWithGoogle() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final success = await authProvider.signInWithGoogle();

    if (success && mounted) {
      // Google users are automatically verified, go to dashboard
      context.go('/dashboard');
    } else if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(authProvider.errorMessage ?? 'Google sign-in failed'),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFFF8F9FA),
              Color(0xFFE8F4FD),
              Color(0xFFF0F8FF),
            ],
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 10),
                
                // Modern Back Button
                Align(
                  alignment: Alignment.centerLeft,
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 10,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: IconButton(
                      onPressed: () => context.pop(),
                      icon: const Icon(Icons.arrow_back_ios, size: 20),
                      color: const Color(0xFF667eea),
                    ),
                  ),
                ),
                
                const SizedBox(height: 20),
                
                // Modern Header Section
                Column(
                  children: [
                    // Modern Logo Container
                    Container(
                      width: 100,
                      height: 100,
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            Color(0xFF667eea),
                            Color(0xFF764ba2),
                          ],
                        ),
                        borderRadius: BorderRadius.circular(25),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFF667eea).withOpacity(0.3),
                            blurRadius: 15,
                            offset: const Offset(0, 8),
                            spreadRadius: 2,
                          ),
                        ],
                      ),
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          Container(
                            width: 60,
                            height: 60,
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(15),
                            ),
                          ),
                          const Icon(
                            Icons.school_outlined,
                            size: 35,
                            color: Colors.white,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),
                    
                    // Welcome Text with Modern Typography
                    ShaderMask(
                      shaderCallback: (bounds) => const LinearGradient(
                        colors: [Color(0xFF667eea), Color(0xFF764ba2)],
                      ).createShader(bounds),
                      child: Text(
                        'Join CollegePro',
                        style: Theme.of(context).textTheme.displaySmall?.copyWith(
                          fontWeight: FontWeight.w800,
                          fontSize: 28,
                          color: Colors.white,
                          letterSpacing: -0.5,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Text(
                        'Create your account and start exploring thousands of amazing student projects',
                        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          color: Colors.grey[700],
                          fontSize: 15,
                          height: 1.4,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ],
                ),
              
                
                const SizedBox(height: 32),
                
                // Modern Registration Form Card
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.08),
                        blurRadius: 25,
                        offset: const Offset(0, 12),
                        spreadRadius: 0,
                      ),
                    ],
                  ),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      children: [
                        // Name Field with Modern Design
                        Container(
                          decoration: BoxDecoration(
                            color: const Color(0xFFF8F9FA),
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(
                              color: Colors.grey.withOpacity(0.1),
                            ),
                          ),
                          child: TextFormField(
                            controller: _nameController,
                            style: const TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w500,
                            ),
                            decoration: InputDecoration(
                              labelText: 'Full Name',
                              labelStyle: TextStyle(
                                color: Colors.grey[600],
                                fontSize: 13,
                                fontWeight: FontWeight.w500,
                              ),
                              prefixIcon: Container(
                                margin: const EdgeInsets.all(10),
                                padding: const EdgeInsets.all(6),
                                decoration: BoxDecoration(
                                  gradient: const LinearGradient(
                                    colors: [Color(0xFF667eea), Color(0xFF764ba2)],
                                  ),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: const Icon(
                                  Icons.person_outlined,
                                  color: Colors.white,
                                  size: 18,
                                ),
                              ),
                              border: InputBorder.none,
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 18,
                              ),
                            ),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Please enter your full name';
                              }
                              if (value.length < 2) {
                                return 'Name must be at least 2 characters';
                              }
                              return null;
                            },
                          ),
                        ),
                        const SizedBox(height: 16),
                        
                        // Modern Email Field
                        Container(
                          decoration: BoxDecoration(
                            color: const Color(0xFFF8F9FA),
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(color: Colors.grey.withOpacity(0.1)),
                          ),
                          child: TextFormField(
                            controller: _emailController,
                            keyboardType: TextInputType.emailAddress,
                            style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w500),
                            decoration: InputDecoration(
                              labelText: 'Email Address',
                              labelStyle: TextStyle(color: Colors.grey[600], fontSize: 13, fontWeight: FontWeight.w500),
                              prefixIcon: Container(
                                margin: const EdgeInsets.all(10),
                                padding: const EdgeInsets.all(6),
                                decoration: BoxDecoration(
                                  gradient: const LinearGradient(colors: [Color(0xFF667eea), Color(0xFF764ba2)]),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: const Icon(Icons.email_outlined, color: Colors.white, size: 18),
                              ),
                              border: InputBorder.none,
                              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
                            ),
                            validator: (value) {
                              if (value == null || value.isEmpty) return 'Please enter your email';
                              if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) return 'Please enter a valid email';
                              return null;
                            },
                          ),
                        ),
                        const SizedBox(height: 16),
                        
                        // Phone Number Field (Optional)
                        Container(
                          decoration: BoxDecoration(
                            color: const Color(0xFFF8F9FA),
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(color: Colors.grey.withOpacity(0.1)),
                          ),
                          child: TextFormField(
                            controller: _phoneController,
                            keyboardType: TextInputType.phone,
                            style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w500),
                            decoration: InputDecoration(
                              labelText: 'Phone Number (Optional)',
                              labelStyle: TextStyle(color: Colors.grey[600], fontSize: 13, fontWeight: FontWeight.w500),
                              prefixIcon: Container(
                                margin: const EdgeInsets.all(10),
                                padding: const EdgeInsets.all(6),
                                decoration: BoxDecoration(
                                  gradient: const LinearGradient(colors: [Color(0xFF667eea), Color(0xFF764ba2)]),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: const Icon(Icons.phone_outlined, color: Colors.white, size: 18),
                              ),
                              border: InputBorder.none,
                              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                        
                        // Institution Field (Optional)
                        Container(
                          decoration: BoxDecoration(
                            color: const Color(0xFFF8F9FA),
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(color: Colors.grey.withOpacity(0.1)),
                          ),
                          child: TextFormField(
                            controller: _institutionController,
                            style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w500),
                            decoration: InputDecoration(
                              labelText: 'College/University (Optional)',
                              labelStyle: TextStyle(color: Colors.grey[600], fontSize: 13, fontWeight: FontWeight.w500),
                              prefixIcon: Container(
                                margin: const EdgeInsets.all(10),
                                padding: const EdgeInsets.all(6),
                                decoration: BoxDecoration(
                                  gradient: const LinearGradient(colors: [Color(0xFF667eea), Color(0xFF764ba2)]),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: const Icon(Icons.school_outlined, color: Colors.white, size: 18),
                              ),
                              border: InputBorder.none,
                              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                        
                        // Course Field
                        Container(
                          decoration: BoxDecoration(
                            color: const Color(0xFFF8F9FA),
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(color: Colors.grey.withOpacity(0.1)),
                          ),
                          child: TextFormField(
                            controller: _courseController,
                            style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w500),
                            decoration: InputDecoration(
                              labelText: 'Course (Optional)',
                              labelStyle: TextStyle(color: Colors.grey[600], fontSize: 13, fontWeight: FontWeight.w500),
                              prefixIcon: Container(
                                margin: const EdgeInsets.all(10),
                                padding: const EdgeInsets.all(6),
                                decoration: BoxDecoration(
                                  gradient: const LinearGradient(colors: [Color(0xFF667eea), Color(0xFF764ba2)]),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: const Icon(Icons.book_outlined, color: Colors.white, size: 18),
                              ),
                              border: InputBorder.none,
                              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                        
                        // Year Dropdown
                        Container(
                          decoration: BoxDecoration(
                            color: const Color(0xFFF8F9FA),
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(color: Colors.grey.withOpacity(0.1)),
                          ),
                          child: DropdownButtonFormField<String>(
                            value: _selectedYear,
                            isExpanded: true,
                            style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w500, color: Colors.black87),
                            decoration: InputDecoration(
                              labelText: 'Year of Study (Optional)',
                              labelStyle: TextStyle(color: Colors.grey[600], fontSize: 13, fontWeight: FontWeight.w500),
                              prefixIcon: Container(
                                margin: const EdgeInsets.all(10),
                                padding: const EdgeInsets.all(6),
                                decoration: BoxDecoration(
                                  gradient: const LinearGradient(colors: [Color(0xFF667eea), Color(0xFF764ba2)]),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: const Icon(Icons.calendar_today_outlined, color: Colors.white, size: 18),
                              ),
                              border: InputBorder.none,
                              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
                            ),
                            items: _yearOptions.map((String year) {
                              return DropdownMenuItem<String>(
                                value: year,
                                child: Text(
                                  year,
                                  style: const TextStyle(fontSize: 14),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              );
                            }).toList(),
                            onChanged: (String? newValue) {
                              if (newValue != null) {
                                setState(() {
                                  _selectedYear = newValue;
                                });
                              }
                            },
                          ),
                        ),
                        const SizedBox(height: 16),
                        
                        // Modern Password Field
                        Container(
                          decoration: BoxDecoration(
                            color: const Color(0xFFF8F9FA),
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(color: Colors.grey.withOpacity(0.1)),
                          ),
                          child: TextFormField(
                            controller: _passwordController,
                            obscureText: _obscurePassword,
                            style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w500),
                            decoration: InputDecoration(
                              labelText: 'Password',
                              labelStyle: TextStyle(color: Colors.grey[600], fontSize: 13, fontWeight: FontWeight.w500),
                              prefixIcon: Container(
                                margin: const EdgeInsets.all(10),
                                padding: const EdgeInsets.all(6),
                                decoration: BoxDecoration(
                                  gradient: const LinearGradient(colors: [Color(0xFF667eea), Color(0xFF764ba2)]),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: const Icon(Icons.lock_outlined, color: Colors.white, size: 18),
                              ),
                              suffixIcon: IconButton(
                                icon: Icon(_obscurePassword ? Icons.visibility_outlined : Icons.visibility_off_outlined, color: Colors.grey[600]),
                                onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                              ),
                              border: InputBorder.none,
                              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
                            ),
                            validator: (value) {
                              if (value == null || value.isEmpty) return 'Please enter a password';
                              if (value.length < 6) return 'Password must be at least 6 characters';
                              return null;
                            },
                          ),
                        ),
                        const SizedBox(height: 16),
                        
                        // Modern Confirm Password Field
                        Container(
                          decoration: BoxDecoration(
                            color: const Color(0xFFF8F9FA),
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(color: Colors.grey.withOpacity(0.1)),
                          ),
                          child: TextFormField(
                            controller: _confirmPasswordController,
                            obscureText: _obscureConfirmPassword,
                            style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w500),
                            decoration: InputDecoration(
                              labelText: 'Confirm Password',
                              labelStyle: TextStyle(color: Colors.grey[600], fontSize: 13, fontWeight: FontWeight.w500),
                              prefixIcon: Container(
                                margin: const EdgeInsets.all(10),
                                padding: const EdgeInsets.all(6),
                                decoration: BoxDecoration(
                                  gradient: const LinearGradient(colors: [Color(0xFF667eea), Color(0xFF764ba2)]),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: const Icon(Icons.lock_outlined, color: Colors.white, size: 18),
                              ),
                              suffixIcon: IconButton(
                                icon: Icon(_obscureConfirmPassword ? Icons.visibility_outlined : Icons.visibility_off_outlined, color: Colors.grey[600]),
                                onPressed: () => setState(() => _obscureConfirmPassword = !_obscureConfirmPassword),
                              ),
                              border: InputBorder.none,
                              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
                            ),
                            validator: (value) {
                              if (value == null || value.isEmpty) return 'Please confirm your password';
                              if (value != _passwordController.text) return 'Passwords do not match';
                              return null;
                            },
                          ),
                        ),
                        const SizedBox(height: 20),
                        
                        // Modern Terms Checkbox
                        Row(
                          children: [
                            Container(
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(6),
                                border: Border.all(color: const Color(0xFF667eea).withOpacity(0.3)),
                              ),
                              child: Checkbox(
                                value: _acceptTerms,
                                onChanged: (value) => setState(() => _acceptTerms = value ?? false),
                                activeColor: const Color(0xFF667eea),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
                              ),
                            ),
                            Expanded(
                              child: RichText(
                                text: TextSpan(
                                  style: Theme.of(context).textTheme.bodySmall?.copyWith(fontSize: 13),
                                  children: const [
                                    TextSpan(text: 'I agree to the '),
                                    TextSpan(text: 'Terms of Service', style: TextStyle(color: Color(0xFF667eea), decoration: TextDecoration.underline, fontWeight: FontWeight.w600)),
                                    TextSpan(text: ' and '),
                                    TextSpan(text: 'Privacy Policy', style: TextStyle(color: Color(0xFF667eea), decoration: TextDecoration.underline, fontWeight: FontWeight.w600)),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 28),
                        
                        // Modern Create Account Button
                        Consumer<AuthProvider>(
                          builder: (context, authProvider, child) {
                            return Container(
                              width: double.infinity,
                              height: 52,
                              decoration: BoxDecoration(
                                gradient: const LinearGradient(colors: [Color(0xFF667eea), Color(0xFF764ba2)]),
                                borderRadius: BorderRadius.circular(14),
                                boxShadow: [BoxShadow(color: const Color(0xFF667eea).withOpacity(0.3), blurRadius: 12, offset: const Offset(0, 6))],
                              ),
                              child: ElevatedButton(
                                onPressed: authProvider.isLoading ? null : _signUp,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.transparent,
                                  shadowColor: Colors.transparent,
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                                ),
                                child: authProvider.isLoading
                                    ? const SizedBox(width: 22, height: 22, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2.5))
                                    : const Text('Create Account', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w600)),
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                ),
                
                const SizedBox(height: 24),
                
                // Modern Divider
                Row(
                  children: [
                    Expanded(child: Container(height: 1, decoration: BoxDecoration(gradient: LinearGradient(colors: [Colors.transparent, Colors.grey.withOpacity(0.3)])))),
                    Container(
                      margin: const EdgeInsets.symmetric(horizontal: 16),
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(color: Colors.grey.withOpacity(0.1), borderRadius: BorderRadius.circular(16)),
                      child: Text('OR', style: TextStyle(color: Colors.grey[600], fontSize: 11, fontWeight: FontWeight.w600)),
                    ),
                    Expanded(child: Container(height: 1, decoration: BoxDecoration(gradient: LinearGradient(colors: [Colors.grey.withOpacity(0.3), Colors.transparent])))),
                  ],
                ),
                
                const SizedBox(height: 24),
                
                // Modern Google Button
                Consumer<AuthProvider>(
                  builder: (context, authProvider, child) {
                    return Container(
                      width: double.infinity,
                      height: 52,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: Colors.grey.withOpacity(0.2), width: 1.5),
                        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 8, offset: const Offset(0, 3))],
                      ),
                      child: OutlinedButton.icon(
                        onPressed: authProvider.isLoading ? null : _signInWithGoogle,
                        style: OutlinedButton.styleFrom(
                          backgroundColor: Colors.transparent,
                          side: BorderSide.none,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                        ),
                        icon: Container(
                          width: 22,
                          height: 22,
                          decoration: BoxDecoration(color: Colors.red.withOpacity(0.1), borderRadius: BorderRadius.circular(5)),
                          child: const Icon(Icons.g_mobiledata, color: Colors.red, size: 18),
                        ),
                        label: const Text('Continue with Google', style: TextStyle(color: Colors.black87, fontSize: 15, fontWeight: FontWeight.w600)),
                      ),
                    );
                  },
                ),
                
                const SizedBox(height: 32),
                
                // Modern Sign In Link
                Container(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text('Already have an account? ', style: TextStyle(color: Colors.grey[700], fontSize: 14, fontWeight: FontWeight.w500)),
                      GestureDetector(
                        onTap: () => context.pop(),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(colors: [Color(0xFF667eea), Color(0xFF764ba2)]),
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: const Text('Sign In', style: TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w600)),
                        ),
                      ),
                    ],
                  ),
                ),
                
                const SizedBox(height: 16),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
