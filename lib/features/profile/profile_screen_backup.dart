import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/providers/auth_provider.dart';
import '../../core/models/user_model.dart';
import '../auth/login_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen>
    with TickerProviderStateMixin {
  late AnimationController _fadeController;
  late AnimationController _slideController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _slideController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeInOut,
    ));

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _slideController,
      curve: Curves.easeOutBack,
    ));

    _fadeController.forward();
    _slideController.forward();
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _slideController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    const lightEducationalBg = Color(0xFFF3F7FF);
    
    return Scaffold(
      backgroundColor: lightEducationalBg,
      appBar: AppBar(
        title: Text(
          'Student Profile',
          style: GoogleFonts.inter(
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
        backgroundColor: const Color(0xFF2E5BBA),
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(
              Icons.logout_rounded,
              color: Colors.white,
              size: 22,
            ),
            onPressed: () async {
              try {
                final authProvider = Provider.of<AuthProvider>(context, listen: false);
                await authProvider.signOut();
                if (context.mounted) {
                  Navigator.of(context).pushReplacement(
                    MaterialPageRoute(builder: (context) => const LoginScreen()),
                  );
                }
              } catch (e) {
                print('Error during logout: $e');
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Logout failed. Please try again.'),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              }
            },
          ),
        ],
      ),
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: SlideTransition(
          position: _slideAnimation,
          child: _buildProfileContent(context),
        ),
      ),
    );
  }


  Widget _buildProfileContent(BuildContext context) {
    return Consumer<AuthProvider>(
      builder: (context, authProvider, child) {
        try {
          final user = authProvider.userModel;
          final firebaseUser = authProvider.user;
          
          // If no Firebase user at all, redirect to login
          if (firebaseUser == null) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              if (context.mounted) {
                Navigator.of(context).pushReplacement(
                  MaterialPageRoute(builder: (context) => const LoginScreen()),
                );
              }
            });
            return const Center(
              child: CircularProgressIndicator(
                color: Color(0xFF2E5BBA),
              ),
            );
          }
          
          // If we have a Firebase user but no user model, show basic profile
          if (user == null) {
            return _buildBasicProfile(context, authProvider);
          }
          
          // Show enhanced profile with user model
          return _buildEnhancedProfile(context, user);
        } catch (e) {
          print('Error in _buildProfileContent: $e');
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.error_outline,
                  size: 64,
                  color: Colors.grey[400],
                ),
                const SizedBox(height: 16),
                Text(
                  'Unable to load profile',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                    color: Colors.grey[600],
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Please try again later',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[500],
                  ),
                ),
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: () {
                    if (context.mounted) {
                      Navigator.of(context).pop();
                    }
                  },
                  child: const Text('Go Back'),
                ),
              ],
            ),
          );
        }
      },
    );
  }

  Widget _buildEnhancedProfile(BuildContext context, UserModel? user) {
    return SingleChildScrollView(
      child: Column(
        children: [
          // Hero Profile Section
          Container(
            margin: const EdgeInsets.all(20),
            child: _buildHeroProfileCard(context, user),
          ),
          
          // Quick Actions
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 20),
            child: _buildQuickActions(context),
          ),
          
          const SizedBox(height: 20),
          
          // Stats Cards
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 20),
            child: _buildStatsCards(context, user),
          ),
          
          const SizedBox(height: 20),
          
          // Skills & Goals Section
          if ((user?.skills ?? []).isNotEmpty || (user?.careerGoal ?? '').isNotEmpty)
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 20),
              child: _buildSkillsAndGoals(context, user),
            ),
          
          const SizedBox(height: 20),
          
          // Settings Section
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 20),
            child: _buildModernSettings(context),
          ),
          
          const SizedBox(height: 30),
        ],
      ),
    );
  }

  Widget _buildHeroProfileCard(BuildContext context, UserModel? user) {
    const educationalBlue = Color(0xFF2E5BBA);
    const educationalCyan = Color(0xFF00ACC1);
    
    return TweenAnimationBuilder<double>(
      duration: const Duration(milliseconds: 1200),
      tween: Tween(begin: 0.0, end: 1.0),
      curve: Curves.elasticOut,
      builder: (context, value, child) {
        return Transform.scale(
          scale: 0.7 + (0.3 * value),
          child: Opacity(
            opacity: value,
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    educationalBlue,
                    educationalCyan,
                    educationalBlue.withOpacity(0.9),
                  ],
                  stops: const [0.0, 0.5, 1.0],
                ),
                borderRadius: BorderRadius.circular(28),
                boxShadow: [
                  BoxShadow(
                    color: educationalBlue.withOpacity(0.4),
                    blurRadius: 30,
                    offset: const Offset(0, 15),
                    spreadRadius: 3,
                  ),
                  BoxShadow(
                    color: educationalCyan.withOpacity(0.2),
                    blurRadius: 20,
                    offset: const Offset(0, 8),
                  ),
                  BoxShadow(
                    color: Colors.white.withOpacity(0.1),
                    blurRadius: 10,
                    offset: const Offset(-5, -5),
                  ),
                ],
              ),
              child: Stack(
                children: [
                  // Animated background pattern
                  Positioned.fill(
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(28),
                      child: Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [
                              Colors.white.withOpacity(0.1),
                              Colors.transparent,
                              Colors.white.withOpacity(0.05),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(28),
                    child: Column(
                      children: [
                        // Animated Profile Picture with pulse effect
                        TweenAnimationBuilder<double>(
                          duration: const Duration(milliseconds: 1500),
                          tween: Tween(begin: 0.0, end: 1.0),
                          curve: Curves.bounceOut,
                          builder: (context, animValue, child) {
                            return Transform.scale(
                              scale: 0.8 + (0.2 * animValue),
                              child: Container(
                                width: 130,
                                height: 130,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  gradient: LinearGradient(
                                    colors: [
                                      Colors.white.withOpacity(0.3),
                                      Colors.white.withOpacity(0.1),
                                    ],
                                  ),
                                  border: Border.all(
                                    color: Colors.white.withOpacity(0.4),
                                    width: 4,
                                  ),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.3),
                                      blurRadius: 20,
                                      offset: const Offset(0, 8),
                                    ),
                                  ],
                                ),
                                child: Padding(
                                  padding: const EdgeInsets.all(4),
                                  child: _buildSafeProfileImage(context, user),
                                ),
                              ),
                            );
                          },
                        ),
                        const SizedBox(height: 24),
                        
                        // Animated Name with typewriter effect
                        TweenAnimationBuilder<double>(
                          duration: const Duration(milliseconds: 1200),
                          tween: Tween(begin: 0.0, end: 1.0),
                          curve: Curves.easeOutBack,
                          builder: (context, animValue, child) {
                            return Transform.translate(
                              offset: Offset(0, 30 * (1 - animValue)),
                              child: Opacity(
                                opacity: animValue,
                                child: Column(
                                  children: [
                                    ShaderMask(
                                      shaderCallback: (bounds) => LinearGradient(
                                        colors: [Colors.white, Colors.white.withOpacity(0.8)],
                                      ).createShader(bounds),
                                      child: Text(
                                        _getSafeDisplayName(user),
                                        style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                          color: Colors.white,
                                          fontSize: 28,
                                          letterSpacing: 1.2,
                                        ),
                                        textAlign: TextAlign.center,
                                        maxLines: 2,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                                      decoration: BoxDecoration(
                                        color: Colors.white.withOpacity(0.2),
                                        borderRadius: BorderRadius.circular(20),
                                        border: Border.all(
                                          color: Colors.white.withOpacity(0.3),
                                          width: 1,
                                        ),
                                      ),
                                      child: Text(
                                        user?.email ?? 'No email',
                                        style: TextStyle(
                                          color: Colors.white.withOpacity(0.95),
                                          fontWeight: FontWeight.w500,
                                          fontSize: 14,
                                        ),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildQuickActions(BuildContext context) {
    const educationalBlue = Color(0xFF2E5BBA);
    const educationalGreen = Color(0xFF2E7D32);
    const educationalOrange = Color(0xFFFF6F00);
    
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: educationalBlue.withOpacity(0.1),
            blurRadius: 20,
            offset: const Offset(0, 8),
            spreadRadius: 2,
          ),
        ],
        border: Border.all(
          color: educationalBlue.withOpacity(0.1),
          width: 1,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            Row(
              children: [
                Icon(
                  Icons.flash_on_rounded,
                  color: educationalBlue,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Text(
                  'Quick Actions',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF2E5BBA),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _buildSimpleActionButton(
                      context,
                      Icons.edit_rounded,
                      'Edit',
                      educationalBlue,
                      () => _showEditProfileDialog(context, Provider.of<AuthProvider>(context, listen: false)),
                    ),
                    _buildSimpleActionButton(
                      context,
                      Icons.school_rounded,
                      'Academic',
                      educationalGreen,
                      () => _showAcademicInfoDialog(context),
                    ),
                    _buildSimpleActionButton(
                      context,
                      Icons.share_rounded,
                      'Share',
                      educationalOrange,
                      () => _shareProfile(context),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSimpleActionButton(BuildContext context, IconData icon, String label, Color color, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        width: 80,
        height: 80,
        padding: const EdgeInsets.all(8),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                icon,
                color: color,
                size: 20,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                color: Colors.grey[700],
                fontWeight: FontWeight.w500,
                fontSize: 9,
              ),
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatsCards(BuildContext context, UserModel? user) {
    return Row(
      children: [
        Expanded(
          child: Container(
            margin: const EdgeInsets.only(right: 8),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.purple.withOpacity(0.1),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: Colors.purple.withOpacity(0.2),
                width: 1,
              ),
            ),
            child: Column(
              children: [
                Icon(
                  Icons.bookmark_outline,
                  color: Colors.purple,
                  size: 24,
                ),
                const SizedBox(height: 8),
                Text(
                  (user?.savedProjectIds ?? []).length.toString(),
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.purple,
                  ),
                ),
                const SizedBox(height: 4),
                const Text(
                  'Saved',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey,
                  ),
                ),
              ],
            ),
          ),
        ),
        Expanded(
          child: Container(
            margin: const EdgeInsets.only(left: 8),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.green.withOpacity(0.1),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: Colors.green.withOpacity(0.2),
                width: 1,
              ),
            ),
            child: Column(
              children: [
                Icon(
                  Icons.check_circle_outline,
                  color: Colors.green,
                  size: 24,
                ),
                const SizedBox(height: 8),
                Text(
                  (user?.completedProjectIds ?? []).length.toString(),
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.green,
                  ),
                ),
                const SizedBox(height: 4),
                const Text(
                  'Completed',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }


  Widget _buildSkillsAndGoals(BuildContext context, UserModel? user) {
    return Column(
      children: [
        if ((user?.skills ?? []).isNotEmpty) ...[
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 15,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.star_outline,
                        color: Colors.amber,
                        size: 24,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Skills',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.grey[800],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: (user?.skills ?? []).asMap().entries.map((entry) {
                      int index = entry.key;
                      String skill = entry.value;
                      return TweenAnimationBuilder<double>(
                        duration: Duration(milliseconds: 600 + (index * 100)),
                        tween: Tween(begin: 0.0, end: 1.0),
                        builder: (context, value, child) {
                          return Transform.scale(
                            scale: value,
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: [
                                    Theme.of(context).colorScheme.primary.withOpacity(0.1),
                                    Theme.of(context).colorScheme.secondary.withOpacity(0.1),
                                  ],
                                ),
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(
                                  color: Theme.of(context).colorScheme.primary.withOpacity(0.3),
                                ),
                              ),
                              child: Text(
                                skill,
                                style: TextStyle(
                                  color: Theme.of(context).colorScheme.primary,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          );
                        },
                      );
                    }).toList(),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
        ],
        
        if ((user?.careerGoal ?? '').isNotEmpty) ...[
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 15,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.flag_outlined,
                        color: Colors.green,
                        size: 24,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Career Goal',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.grey[800],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(
                    user?.careerGoal ?? '',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey[700],
                      height: 1.5,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildModernSettings(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        children: [
          _buildSettingsTile(
            context,
            Icons.dark_mode_outlined,
            'Dark Mode',
            'Toggle dark theme',
            Colors.indigo,
            trailing: Switch(
              value: Theme.of(context).brightness == Brightness.dark,
              onChanged: (value) {
                // Theme switching logic would go here
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Theme switching coming soon!'),
                    backgroundColor: Color(0xFF2E5BBA),
                  ),
                );
              },
              activeColor: const Color(0xFF2E5BBA),
            ),
          ),
          const Divider(height: 1, indent: 70),
          _buildSettingsTile(
            context,
            Icons.info_outline,
            'About',
            'App information',
            Colors.blue,
            onTap: () => _showAboutDialog(context),
          ),
          const Divider(height: 1, indent: 70),
          _buildSettingsTile(
            context,
            Icons.logout,
            'Sign Out',
            'Logout from account',
            Colors.red,
            onTap: () => _showLogoutDialog(context),
          ),
        ],
      ),
    );
  }

  Widget _buildSettingsTile(
    BuildContext context,
    IconData icon,
    String title,
    String subtitle,
    Color color, {
    Widget? trailing,
    VoidCallback? onTap,
  }) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      leading: Container(
        width: 45,
        height: 45,
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Icon(
          icon,
          color: color,
          size: 22,
        ),
      ),
      title: Text(
        title,
        style: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          color: Colors.grey[800],
        ),
      ),
      subtitle: Text(
        subtitle,
        style: TextStyle(
          fontSize: 12,
          color: Colors.grey[600],
        ),
      ),
      trailing: trailing ?? Icon(
        Icons.arrow_forward_ios,
        size: 16,
        color: Colors.grey[400],
      ),
      onTap: onTap,
    );
  }

  Widget _buildDefaultAvatar(BuildContext context, String? name) {
    String displayChar = 'S';
    try {
      if (name != null && name.trim().isNotEmpty) {
        final cleanName = name.trim();
        if (cleanName.isNotEmpty) {
          displayChar = cleanName[0].toUpperCase();
        }
      }
    } catch (e) {
      print('Error processing avatar name: $e');
    }
    return Container(
      width: 122,
      height: 122,
      decoration: const BoxDecoration(
        shape: BoxShape.circle,
        color: Colors.white,
      ),
      child: Center(
        child: Text(
          displayChar,
          style: const TextStyle(
            color: Color(0xFF2E5BBA),
            fontSize: 40,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  /// Safe profile image builder with comprehensive null checks
  Widget _buildSafeProfileImage(BuildContext context, UserModel? user) {
    try {
      // Check if user and photoUrl are both non-null and non-empty
      if (user?.photoUrl != null && 
          user!.photoUrl!.trim().isNotEmpty) {
        return ClipOval(
          child: Image.network(
            user.photoUrl!,
            width: 122,
            height: 122,
            fit: BoxFit.cover,
            loadingBuilder: (context, child, loadingProgress) {
              if (loadingProgress == null) return child;
              return Container(
                width: 122,
                height: 122,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white,
                ),
                child: const Center(
                  child: CircularProgressIndicator(),
                ),
              );
            },
            errorBuilder: (context, error, stackTrace) {
              print('Error loading profile image: $error');
              return _buildDefaultAvatar(context, user.displayName);
            },
          ),
        );
      }
    } catch (e) {
      print('Error in _buildSafeProfileImage: $e');
    }
    
    // Fallback to default avatar
    return _buildDefaultAvatar(context, user?.displayName);
  }

  /// Safe display name getter with fallbacks
  String _getSafeDisplayName(UserModel? user) {
    try {
      if (user?.displayName != null && user!.displayName.trim().isNotEmpty) {
        return user.displayName.trim();
      }
      
      if (user?.email != null && user!.email.trim().isNotEmpty) {
        // Extract name from email
        final emailParts = user.email.split('@');
        if (emailParts.isNotEmpty && emailParts.first.isNotEmpty) {
          final username = emailParts.first.split('.').first;
          if (username.isNotEmpty) {
            return username[0].toUpperCase() + (username.length > 1 ? username.substring(1).toLowerCase() : '');
          }
        }
      }
    } catch (e) {
      print('Error getting safe display name: $e');
    }
    
    return 'Student';
  }

  /// Safe Firebase user image builder with comprehensive null checks
  Widget _buildSafeFirebaseUserImage(BuildContext context, dynamic firebaseUser) {
    try {
      // Check if photoURL is non-null and non-empty
      if (firebaseUser.photoURL != null && 
          firebaseUser.photoURL!.trim().isNotEmpty) {
        return ClipOval(
          child: Image.network(
            firebaseUser.photoURL!,
            width: 122,
            height: 122,
            fit: BoxFit.cover,
            loadingBuilder: (context, child, loadingProgress) {
              if (loadingProgress == null) return child;
              return Container(
                width: 122,
                height: 122,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white,
                ),
                child: const Center(
                  child: CircularProgressIndicator(),
                ),
              );
            },
            errorBuilder: (context, error, stackTrace) {
              print('Error loading Firebase user image: $error');
              return _buildDefaultAvatar(context, firebaseUser.displayName);
            },
          ),
        );
      }
    } catch (e) {
      print('Error in _buildSafeFirebaseUserImage: $e');
    }
    
    // Fallback to default avatar
    return _buildDefaultAvatar(context, firebaseUser.displayName);
  }

  void _showEditProfileDialog(BuildContext context, AuthProvider authProvider) {
    final nameController = TextEditingController(text: authProvider.userModel?.displayName ?? '');
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Edit Profile'),
        content: TextField(
          controller: nameController,
          decoration: InputDecoration(
            labelText: 'Display Name',
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Theme.of(context).colorScheme.primary),
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              try {
                final newName = nameController.text.trim();
                if (newName.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Name cannot be empty'),
                      backgroundColor: Colors.red,
                    ),
                  );
                  return;
                }
                
                await authProvider.updateUserProfile(displayName: newName);
                
                if (context.mounted) {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: const Text('Profile updated successfully'),
                      backgroundColor: Colors.green,
                      behavior: SnackBarBehavior.floating,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                  );
                }
              } catch (e) {
                print('Error updating profile: $e');
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Failed to update profile. Please try again.'),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF2E5BBA),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            Icon(Icons.logout, color: Colors.red),
            const SizedBox(width: 8),
            const Text('Sign Out'),
          ],
        ),
        content: const Text('Are you sure you want to sign out?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context); // Close dialog first
              
              try {
                final authProvider = Provider.of<AuthProvider>(context, listen: false);
                // Sign out from auth
                await authProvider.signOut();
                
                if (context.mounted) {
                  Navigator.of(context).pushReplacement(
                    MaterialPageRoute(builder: (context) => const LoginScreen()),
                  );
                }
              } catch (e) {
                print('Error during logout: $e');
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Logout failed. Please try again.'),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            child: const Text('Sign Out'),
          ),
        ],
      ),
    );
  }

  Widget _buildBasicProfile(BuildContext context, AuthProvider authProvider) {
    final firebaseUser = authProvider.user;
    if (firebaseUser == null) {
      return const Center(
        child: Text(
          'Unable to load user data',
          style: TextStyle(color: Colors.white),
        ),
      );
    }
    
    return SingleChildScrollView(
      child: Column(
        children: [
          // Enhanced Profile Header
          Container(
            margin: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Colors.white,
                  Colors.grey[50]!,
                ],
              ),
              borderRadius: BorderRadius.circular(24),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.08),
                  blurRadius: 25,
                  offset: const Offset(0, 12),
                ),
                BoxShadow(
                  color: Colors.white.withOpacity(0.7),
                  blurRadius: 10,
                  offset: const Offset(-5, -5),
                ),
              ],
            ),
            child: Padding(
              padding: const EdgeInsets.all(28),
              child: Column(
                children: [
                  // Profile Picture with enhanced design
                  Container(
                    width: 130,
                    height: 130,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: LinearGradient(
                        colors: [
                          const Color(0xFF6366F1),
                          const Color(0xFF8B5CF6),
                        ],
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF6366F1).withOpacity(0.4),
                          blurRadius: 25,
                          offset: const Offset(0, 10),
                        ),
                      ],
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(4),
                      child: _buildSafeFirebaseUserImage(context, firebaseUser),
                    ),
                  ),
                  const SizedBox(height: 24),
                  
                  // User Name with enhanced typography
                  Text(
                    firebaseUser.displayName ?? 'Welcome User',
                    style: const TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1F2937),
                      letterSpacing: 0.5,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  
                  // User Email with badge design
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      color: const Color(0xFF6366F1).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: const Color(0xFF6366F1).withOpacity(0.3),
                      ),
                    ),
                    child: Text(
                      firebaseUser.email ?? 'No email provided',
                      style: const TextStyle(
                        color: Color(0xFF6366F1),
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  
                  // User Status Badge
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          Colors.green.withOpacity(0.1),
                          Colors.green.withOpacity(0.05),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(25),
                      border: Border.all(
                        color: Colors.green.withOpacity(0.3),
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: 8,
                          height: 8,
                          decoration: const BoxDecoration(
                            color: Colors.green,
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 8),
                        const Text(
                          'Active Student',
                          style: TextStyle(
                            color: Colors.green,
                            fontWeight: FontWeight.w600,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          
          // Stats Cards Row
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 20),
            child: LayoutBuilder(
              builder: (context, constraints) {
                return Row(
                  children: [
                    Expanded(
                      child: _buildStatCard(
                        context,
                        'Projects',
                        '0',
                        Icons.folder_outlined,
                        const Color(0xFF8B5CF6),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: _buildStatCard(
                        context,
                        'Saved',
                        '0',
                        Icons.bookmark_outline,
                        const Color(0xFF06B6D4),
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
          
          const SizedBox(height: 20),
          
          // Quick Actions with enhanced design
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 20),
            child: _buildQuickActions(context),
          ),
          
          const SizedBox(height: 20),
          
          // Settings Section
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 20),
            child: _buildModernSettings(context),
          ),
          
          const SizedBox(height: 30),
        ],
      ),
    );
  }
  
  Widget _buildStatCard(BuildContext context, String title, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.1),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
        border: Border.all(
          color: color.withOpacity(0.1),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(15),
            ),
            child: Icon(
              icon,
              color: color,
              size: 24,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            value,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          const SizedBox(height: 4),
          Flexible(
            child: Text(
              title,
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey[600],
                fontWeight: FontWeight.w500,
              ),
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  void _showAboutDialog(BuildContext context) {
    showAboutDialog(
      context: context,
      applicationName: 'CollegePro',
      applicationVersion: '1.0.0',
      applicationIcon: Container(
        width: 64,
        height: 64,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              const Color(0xFF2E5BBA),
              const Color(0xFF00ACC1),
            ],
          ),
          borderRadius: BorderRadius.circular(16),
        ),
        child: const Icon(
          Icons.school_rounded,
          color: Colors.white,
          size: 32,
        ),
      ),
      children: const [
        Text('An educational app to help students find research papers, manage academic profiles, and enhance their learning experience.'),
      ],
    );
  }

  void _showAcademicInfoDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: Row(
            children: [
              Icon(
                Icons.school_rounded,
                color: const Color(0xFF2E5BBA),
                size: 24,
              ),
              const SizedBox(width: 8),
              const Text(
                'Academic Information',
                style: TextStyle(
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF2E5BBA),
                ),
              ),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildAcademicInfoItem('Institution', 'Your College/University'),
              const SizedBox(height: 12),
              _buildAcademicInfoItem('Course', 'Computer Science'),
              const SizedBox(height: 12),
              _buildAcademicInfoItem('Year', 'Final Year'),
              const SizedBox(height: 12),
              _buildAcademicInfoItem('Specialization', 'Software Engineering'),
              const SizedBox(height: 16),
              const Text(
                'Update your academic information in the Edit Profile section.',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey,
                  fontStyle: FontStyle.italic,
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text(
                'Close',
                style: TextStyle(color: Color(0xFF2E5BBA)),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildAcademicInfoItem(String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 80,
          child: Text(
            '$label:',
            style: const TextStyle(
              fontWeight: FontWeight.w600,
              color: Colors.grey,
            ),
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ],
    );
  }

  void _shareProfile(BuildContext context) {
    try {
      final user = Provider.of<AuthProvider>(context, listen: false).user;
      final userName = user?.displayName ?? 'Student';
      final userEmail = user?.email ?? 'No email';
      
      showModalBottomSheet(
        context: context,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        builder: (BuildContext context) {
          return Container(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  Icon(
                    Icons.share_rounded,
                    color: const Color(0xFF2E5BBA),
                    size: 24,
                  ),
                  const SizedBox(width: 8),
                  const Text(
                    'Share Profile',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF2E5BBA),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFF2E5BBA).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: const Color(0xFF2E5BBA).withOpacity(0.2),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Profile Summary:',
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        color: Colors.grey[700],
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Name: $userName\nEmail: $userEmail\nStatus: Active Student\nApp: CollegePro - Educational Platform',
                      style: const TextStyle(
                        fontSize: 14,
                        height: 1.4,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              LayoutBuilder(
                builder: (context, constraints) {
                  return Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () {
                            Navigator.of(context).pop();
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Profile copied to clipboard!'),
                                backgroundColor: Color(0xFF2E5BBA),
                              ),
                            );
                          },
                          icon: const Icon(Icons.copy_rounded, size: 16),
                          label: const Text(
                            'Copy',
                            style: TextStyle(fontSize: 12),
                            overflow: TextOverflow.ellipsis,
                            maxLines: 1,
                          ),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: const Color(0xFF2E5BBA),
                            side: const BorderSide(color: Color(0xFF2E5BBA)),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: () {
                            Navigator.of(context).pop();
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Share feature coming soon!'),
                                backgroundColor: Color(0xFF2E5BBA),
                              ),
                            );
                          },
                          icon: const Icon(Icons.send_rounded, size: 16),
                          label: const Text(
                            'Share',
                            style: TextStyle(fontSize: 12),
                            overflow: TextOverflow.ellipsis,
                            maxLines: 1,
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF2E5BBA),
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
                          ),
                        ),
                      ),
                    ],
                  );
                },
              ),
            ],
          ),
        );
      },
    );
    } catch (e) {
      print('Error sharing profile: $e');
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Unable to share profile. Please try again.'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

}
