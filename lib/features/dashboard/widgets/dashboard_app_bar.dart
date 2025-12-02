import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../../../core/providers/auth_provider.dart';

class DashboardAppBar extends StatelessWidget {
  final VoidCallback? onMenuPressed;
  
  const DashboardAppBar({super.key, this.onMenuPressed});

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isSmallScreen = screenWidth < 600;
    
    return Container(
      padding: EdgeInsets.all(isSmallScreen ? 16 : 20),
      decoration: const BoxDecoration(
        color: Colors.transparent,
      ),
      child: Consumer<AuthProvider>(
        builder: (context, authProvider, child) {
          final user = authProvider.userModel;
          final firebaseUser = authProvider.user;
          
          // Show loading state only if we have a Firebase user but no user model yet AND we're actually loading
          if (firebaseUser != null && user == null && authProvider.isLoading) {
            return Row(
              children: [
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: IconButton(
                    onPressed: onMenuPressed ?? () {
                      try {
                        Scaffold.of(context).openDrawer();
                      } catch (e) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Menu not available')),
                        );
                      }
                    },
                    icon: const Icon(Icons.menu, color: Colors.white),
                    tooltip: 'Menu',
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _getGreeting(),
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          color: Colors.white.withOpacity(0.9),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Row(
                        children: [
                          SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(Colors.white.withOpacity(0.8)),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'Loading...',
                            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                              fontWeight: FontWeight.w800,
                              color: Colors.white,
                              fontSize: 22,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white,
                    border: Border.all(color: Colors.white.withOpacity(0.3), width: 3),
                  ),
                  child: const Icon(Icons.person, color: Colors.grey),
                ),
              ],
            );
          }
          
          // If we have a Firebase user but no user model and not loading, show the user with Firebase data
          if (firebaseUser != null && user == null && !authProvider.isLoading) {
            return Row(
              children: [
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: IconButton(
                    onPressed: onMenuPressed ?? () {
                      try {
                        Scaffold.of(context).openDrawer();
                      } catch (e) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Menu not available')),
                        );
                      }
                    },
                    icon: const Icon(Icons.menu, color: Colors.white),
                    tooltip: 'Menu',
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _getGreeting(),
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          color: Colors.white.withOpacity(0.9),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        _getDisplayNameWithFallback(null, firebaseUser),
                        style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.w800,
                          color: Colors.white,
                          fontSize: 22,
                        ),
                      ),
                    ],
                  ),
                ),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: IconButton(
                        onPressed: () {
                          try {
                            context.push('/saved-projects');
                          } catch (e) {
                            print('Error navigating to saved projects: $e');
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Saved projects not available right now'),
                                duration: Duration(seconds: 2),
                              ),
                            );
                          }
                        },
                        icon: const Icon(Icons.bookmark_outline, color: Colors.white),
                        tooltip: 'Saved Projects',
                        iconSize: isSmallScreen ? 20 : 24,
                      ),
                    ),
                    SizedBox(width: isSmallScreen ? 8 : 12),
                    GestureDetector(
                      onTap: () {
                        try {
                          context.push('/profile');
                        } catch (e) {
                          print('Error navigating to profile: $e');
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Profile not available right now'),
                              duration: Duration(seconds: 2),
                            ),
                          );
                        }
                      },
                      child: Container(
                        width: 44,
                        height: 44,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.white,
                          border: Border.all(color: Colors.white.withOpacity(0.3), width: 3),
                        ),
                        child: _buildProfileImage(firebaseUser, context),
                      ),
                    ),
                  ],
                ),
              ],
            );
          }
          
          // If no Firebase user, show logged out state
          if (firebaseUser == null) {
            return Row(
              children: [
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: IconButton(
                    onPressed: onMenuPressed ?? () {
                      try {
                        Scaffold.of(context).openDrawer();
                      } catch (e) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Menu not available')),
                        );
                      }
                    },
                    icon: const Icon(Icons.menu, color: Colors.white),
                    tooltip: 'Menu',
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _getGreeting(),
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          color: Colors.white.withOpacity(0.9),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        'Guest User',
                        style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.w800,
                          color: Colors.white,
                          fontSize: 22,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white,
                    border: Border.all(color: Colors.white.withOpacity(0.3), width: 3),
                  ),
                  child: const Icon(Icons.person, color: Colors.grey),
                ),
              ],
            );
          }
          
          return Row(
            children: [
              // Menu Button
              Container(
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: IconButton(
                  onPressed: onMenuPressed ?? () {
                    try {
                      Scaffold.of(context).openDrawer();
                    } catch (e) {
                      // Fallback: show message if drawer not accessible
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Menu not available')),
                      );
                    }
                  },
                  icon: const Icon(Icons.menu, color: Colors.white),
                  tooltip: 'Menu',
                ),
              ),
              const SizedBox(width: 16),
              
              // Greeting and User Info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    AnimatedSwitcher(
                      duration: const Duration(milliseconds: 500),
                      child: Text(
                        _getGreeting(),
                        key: ValueKey(_getGreeting()),
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          color: Colors.white.withOpacity(0.9),
                          fontWeight: FontWeight.w500,
                        ),
                        overflow: TextOverflow.ellipsis,
                        maxLines: 1,
                      ),
                    ),
                    const SizedBox(height: 6),
                    AnimatedSwitcher(
                      duration: const Duration(milliseconds: 700),
                      child: Text(
                        _getDisplayNameWithFallback(user, firebaseUser),
                        key: ValueKey(_getDisplayNameWithFallback(user, firebaseUser)),
                        style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.w800,
                          color: Colors.white,
                          fontSize: 22,
                        ),
                        overflow: TextOverflow.ellipsis,
                        maxLines: 1,
                      ),
                    ),
                  ],
                ),
              ),
              
              // Action Buttons - Always show saved projects button
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Saved Projects Button
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: IconButton(
                      onPressed: () {
                        try {
                          context.push('/saved-projects');
                        } catch (e) {
                          print('Error navigating to saved projects: $e');
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Saved projects not available right now'),
                              duration: Duration(seconds: 2),
                            ),
                          );
                        }
                      },
                      icon: const Icon(Icons.bookmark_outline, color: Colors.white),
                      tooltip: 'Saved Projects',
                      iconSize: isSmallScreen ? 20 : 24,
                    ),
                  ),
                  SizedBox(width: isSmallScreen ? 8 : 12),
                  
                  // Profile
                  GestureDetector(
                    onTap: () {
                      try {
                        context.push('/profile');
                      } catch (e) {
                        print('Error navigating to profile: $e');
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Profile not available right now'),
                            duration: Duration(seconds: 2),
                          ),
                        );
                      }
                    },
                    child: Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.white,
                        border: Border.all(color: Colors.white.withOpacity(0.3), width: 3),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: _buildProfileImage(user ?? firebaseUser, context),
                    ),
                  ),
                ],
              ),
            ],
          );
        },
      ),
    );
  }

  /// Builds profile image with comprehensive error handling
  Widget _buildProfileImage(dynamic user, BuildContext context) {
    try {
      if (user?.photoUrl != null && user.photoUrl.toString().trim().isNotEmpty) {
        return ClipOval(
          child: Image.network(
            user.photoUrl!,
            width: 44,
            height: 44,
            fit: BoxFit.cover,
            loadingBuilder: (context, child, loadingProgress) {
              if (loadingProgress == null) return child;
              return _buildDefaultAvatar(context, user.displayName);
            },
            errorBuilder: (context, error, stackTrace) {
              print('Error loading profile image: $error');
              return _buildDefaultAvatar(context, user.displayName);
            },
          ),
        );
      }
    } catch (e) {
      print('Error in _buildProfileImage: $e');
    }
    
    return _buildDefaultAvatar(context, user?.displayName);
  }

  Widget _buildDefaultAvatar(BuildContext context, String? name) {
    // Safely handle null or empty names
    String displayChar = 'S'; // Default to 'S' for Student
    
    try {
      if (name != null && name.trim().isNotEmpty) {
        final cleanName = name.trim();
        if (cleanName.isNotEmpty) {
          displayChar = cleanName[0].toUpperCase();
        }
      }
    } catch (e) {
      print('Error processing avatar name: $e');
      // Keep default 'S'
    }
    
    return Container(
      width: 44,
      height: 44,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Theme.of(context).colorScheme.primary,
            Theme.of(context).colorScheme.primary.withOpacity(0.8),
          ],
        ),
      ),
      child: Center(
        child: Text(
          displayChar,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  String _getGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) {
      return 'Good Morning';
    } else if (hour < 17) {
      return 'Good Afternoon';
    } else {
      return 'Good Evening';
    }
  }


  // Enhanced method to get display name with better fallback handling
  String _getDisplayNameWithFallback(dynamic userModel, dynamic firebaseUser) {
    // Try userModel first
    if (userModel?.displayName != null && userModel.displayName.trim().isNotEmpty) {
      return _capitalizeString(userModel.displayName.trim().split(' ').first);
    }
    
    // Try Firebase user
    if (firebaseUser?.displayName != null && firebaseUser.displayName.trim().isNotEmpty) {
      return _capitalizeString(firebaseUser.displayName.trim().split(' ').first);
    }
    
    // Try email from userModel
    if (userModel?.email != null && userModel.email.trim().isNotEmpty) {
      try {
        final username = userModel.email.split('@').first.split('.').first.trim();
        if (username.isNotEmpty) {
          return _capitalizeString(username);
        }
      } catch (e) {
        print('Error processing userModel email: $e');
      }
    }
    
    // Try email from Firebase user
    if (firebaseUser?.email != null && firebaseUser.email.trim().isNotEmpty) {
      try {
        final username = firebaseUser.email.split('@').first.split('.').first.trim();
        if (username.isNotEmpty) {
          return _capitalizeString(username);
        }
      } catch (e) {
        print('Error processing Firebase user email: $e');
      }
    }
    
    return 'Student';
  }

  /// Helper method to capitalize strings safely
  String _capitalizeString(String input) {
    if (input.isEmpty) return input;
    if (input.length == 1) return input.toUpperCase();
    return input[0].toUpperCase() + input.substring(1).toLowerCase();
  }
}
