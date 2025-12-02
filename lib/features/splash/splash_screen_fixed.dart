import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../../core/providers/auth_provider.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _setupAnimations();
    _navigateAfterDelay();
  }

  void _setupAnimations() {
    _animationController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));

    _scaleAnimation = Tween<double>(
      begin: 0.5,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.elasticOut,
    ));

    _animationController.forward();
  }

  void _navigateAfterDelay() {
    Future.microtask(() async {
      final delay = const Duration(seconds: 3);
      await Future.delayed(delay);
      
      if (!mounted) return;
      
      try {
        AuthProvider? authProvider;
        try {
          authProvider = context.read<AuthProvider>();
        } catch (e) {
          if (kDebugMode) {
            print('AuthProvider not ready, proceeding to login: $e');
          }
        }
        
        if (!mounted) return;
        
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (!mounted) return;
          
          if (authProvider != null && authProvider.isAuthenticated) {
            if (kDebugMode) {
              print('User authenticated, navigating to dashboard');
            }
            context.go('/dashboard');
          } else {
            if (kDebugMode) {
              print('User not authenticated or provider not ready, navigating to login');
            }
            context.go('/login');
          }
        });
      } catch (e) {
        if (kDebugMode) {
          print('Navigation error from splash: $e');
        }
        if (mounted) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (mounted) {
              if (kDebugMode) {
                print('Fallback navigation to login');
              }
              context.go('/login');
            }
          });
        }
      }
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    final screenSize = mediaQuery.size;
    final isSmallScreen = screenSize.width < 600;
    final isWeb = kIsWeb;
    
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFF667eea),
              Color(0xFF764ba2),
              Color(0xFF6C5CE7),
              Color(0xFF74b9ff),
            ],
            stops: [0.0, 0.3, 0.7, 1.0],
          ),
        ),
        child: Stack(
          children: [
            // Background decorative elements - responsive
            if (!isSmallScreen) ...[
              Positioned(
                top: -100,
                right: -100,
                child: Container(
                  width: isWeb ? 250 : 200,
                  height: isWeb ? 250 : 200,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white.withOpacity(0.1),
                  ),
                ),
              ),
              Positioned(
                bottom: -150,
                left: -150,
                child: Container(
                  width: isWeb ? 350 : 300,
                  height: isWeb ? 350 : 300,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white.withOpacity(0.05),
                  ),
                ),
              ),
              Positioned(
                top: 150,
                left: -50,
                child: Container(
                  width: isWeb ? 120 : 100,
                  height: isWeb ? 120 : 100,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white.withOpacity(0.08),
                  ),
                ),
              ),
            ],
            
            // Main content
            RepaintBoundary(
              child: Center(
                child: AnimatedBuilder(
                  animation: _animationController,
                  builder: (context, child) {
                    return FadeTransition(
                      opacity: _fadeAnimation,
                      child: ScaleTransition(
                        scale: _scaleAnimation,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            // Modern Logo Container - responsive
                            Container(
                              width: isSmallScreen ? 120 : (isWeb ? 160 : 140),
                              height: isSmallScreen ? 120 : (isWeb ? 160 : 140),
                              decoration: BoxDecoration(
                                gradient: const LinearGradient(
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                  colors: [
                                    Colors.white,
                                    Color(0xFFF8F9FA),
                                  ],
                                ),
                                borderRadius: BorderRadius.circular(isSmallScreen ? 30 : (isWeb ? 40 : 35)),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.15),
                                    blurRadius: isWeb ? 35 : 30,
                                    offset: const Offset(0, 15),
                                    spreadRadius: 5,
                                  ),
                                  BoxShadow(
                                    color: Colors.white.withOpacity(0.1),
                                    blurRadius: 10,
                                    offset: const Offset(-5, -5),
                                  ),
                                ],
                              ),
                              child: Stack(
                                alignment: Alignment.center,
                                children: [
                                  // Background accent
                                  Container(
                                    width: isSmallScreen ? 70 : (isWeb ? 90 : 80),
                                    height: isSmallScreen ? 70 : (isWeb ? 90 : 80),
                                    decoration: BoxDecoration(
                                      gradient: const LinearGradient(
                                        colors: [
                                          Color(0xFF6C5CE7),
                                          Color(0xFF74b9ff),
                                        ],
                                      ),
                                      borderRadius: BorderRadius.circular(isSmallScreen ? 18 : (isWeb ? 22 : 20)),
                                    ),
                                  ),
                                  // Main icon
                                  Icon(
                                    Icons.school_outlined,
                                    size: isSmallScreen ? 40 : (isWeb ? 60 : 50),
                                    color: Colors.white,
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 30),
                        
                            // App Name with modern typography - responsive
                            RepaintBoundary(
                              child: ShaderMask(
                                shaderCallback: (bounds) => const LinearGradient(
                                  colors: [Colors.white, Color(0xFFE8F4FD)],
                                ).createShader(bounds),
                                child: Text(
                                  'CollegePro',
                                  style: Theme.of(context).textTheme.displayLarge?.copyWith(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w800,
                                    fontSize: isSmallScreen ? 36 : (isWeb ? 56 : 48),
                                    letterSpacing: isWeb ? -2.0 : -1.5,
                                    height: 1.1,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              ),
                            ),
                            const SizedBox(height: 20),
                        
                            // Tagline with elegant styling - responsive
                            Padding(
                              padding: EdgeInsets.symmetric(
                                horizontal: isSmallScreen ? 30 : (isWeb ? 60 : 40),
                              ),
                              child: Text(
                                'Your Educational Journey Starts Here',
                                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                  color: Colors.white.withOpacity(0.95),
                                  fontWeight: FontWeight.w400,
                                  fontSize: isSmallScreen ? 16 : (isWeb ? 20 : 18),
                                  height: 1.4,
                                  letterSpacing: isWeb ? 0.4 : 0.3,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ),
                            const SizedBox(height: 50),
                        
                            // Modern loading indicator - responsive
                            Container(
                              width: isSmallScreen ? 45 : (isWeb ? 55 : 50),
                              height: isSmallScreen ? 45 : (isWeb ? 55 : 50),
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.2),
                                borderRadius: BorderRadius.circular(isSmallScreen ? 22.5 : (isWeb ? 27.5 : 25)),
                              ),
                              child: const Center(
                                child: SizedBox(
                                  width: 24,
                                  height: 24,
                                  child: CircularProgressIndicator(
                                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                    strokeWidth: 2.5,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
          
            // Bottom accent - responsive
            Positioned(
              bottom: isSmallScreen ? 30 : (isWeb ? 70 : 50),
              left: 0,
              right: 0,
              child: RepaintBoundary(
                child: Center(
                  child: Container(
                    width: isSmallScreen ? 50 : (isWeb ? 70 : 60),
                    height: isWeb ? 5 : 4,
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.3),
                      borderRadius: BorderRadius.circular(isWeb ? 2.5 : 2),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
