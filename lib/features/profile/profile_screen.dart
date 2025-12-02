import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../core/providers/auth_provider.dart';
import '../../core/providers/theme_provider.dart';
import '../../core/models/user_model.dart';
import '../../core/widgets/modern_side_drawer.dart';
import '../../core/widgets/base64_image_widget.dart';
import '../../core/widgets/notification_badge.dart';
import '../../core/services/database_image_service.dart';
import '../auth/login_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final DatabaseImageService _imageService = DatabaseImageService();
  bool _isUploadingImage = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF3F7FF),
      drawer: const ModernSideDrawer(),
      appBar: AppBar(
        title: Text(
          'Student Profile',
          style: GoogleFonts.inter(
            fontWeight: FontWeight.w600,
            color: const Color(0xFF2D3748),
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Color(0xFF2D3748)),
        actions: [
          NotificationIcon(
            iconColor: const Color(0xFF2D3748),
            iconSize: 22,
          ),
          const SizedBox(width: 8),
          IconButton(
            icon: const Icon(
              Icons.logout_rounded,
              color: Color(0xFF2D3748),
              size: 22,
            ),
            onPressed: () => _handleLogout(context),
          ),
        ],
      ),
      body: _buildProfileContent(context),
    );
  }

  Widget _buildProfileContent(BuildContext context) {
    return Consumer<AuthProvider>(
      builder: (context, authProvider, child) {
        final user = authProvider.userModel;
        final firebaseUser = authProvider.user;
        
        if (firebaseUser == null) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (mounted) {
              Navigator.of(context).pushReplacement(
                MaterialPageRoute(builder: (context) => const LoginScreen()),
              );
            }
          });
          return const Center(
            child: CircularProgressIndicator(color: Color(0xFF2E5BBA)),
          );
        }
        
        // Show loading only if we don't have any user data at all
        if (user == null && authProvider.isLoading) {
          return const Center(
            child: CircularProgressIndicator(color: Color(0xFF2E5BBA)),
          );
        }
        
        return SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              _buildProfileHeader(context, user, firebaseUser),
              const SizedBox(height: 20),
              _buildStatsSection(context, user),
              const SizedBox(height: 20),
              _buildQuickActions(context),
              const SizedBox(height: 20),
              _buildSettingsSection(context),
              const SizedBox(height: 20),
              _buildAboutDeveloperSection(context),
              const SizedBox(height: 30),
            ],
          ),
        );
      },
    );
  }

  Widget _buildProfileHeader(BuildContext context, UserModel? user, dynamic firebaseUser) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFF2E5BBA),
            Color(0xFF00ACC1),
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF2E5BBA).withOpacity(0.3),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        children: [
          Stack(
            children: [
              CircleAvatar(
                radius: 50,
                backgroundColor: Colors.white,
                child: _isUploadingImage
                    ? const CircularProgressIndicator(
                        color: Color(0xFF2E5BBA),
                        strokeWidth: 3,
                      )
                    : _buildProfileImage(user, firebaseUser),
              ),
              Positioned(
                bottom: 0,
                right: 0,
                child: GestureDetector(
                  onTap: () => _showImageSourceDialog(),
                  child: Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      color: const Color(0xFF2E5BBA),
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 2),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.2),
                          blurRadius: 4,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: const Icon(
                      Icons.camera_alt,
                      color: Colors.white,
                      size: 16,
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            _getDisplayName(user, firebaseUser),
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(15),
            ),
            child: Text(
              _getEmail(user, firebaseUser),
              style: const TextStyle(
                color: Colors.white,
                fontSize: 14,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProfileImage(UserModel? user, dynamic firebaseUser) {
    final photoUrl = user?.photoUrl ?? firebaseUser?.photoURL;
    
    if (photoUrl != null && photoUrl.isNotEmpty) {
      // Check if it's a base64 image (from database) or network image
      if (photoUrl.startsWith('data:image')) {
        return ClipOval(
          child: Base64ImageWidget(
            base64String: photoUrl,
            width: 100,
            height: 100,
            fit: BoxFit.cover,
            errorWidget: _buildDefaultAvatar(user, firebaseUser),
          ),
        );
      } else {
        return ClipOval(
          child: Image.network(
            photoUrl,
            width: 100,
            height: 100,
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) {
              return _buildDefaultAvatar(user, firebaseUser);
            },
          ),
        );
      }
    }
    
    return _buildDefaultAvatar(user, firebaseUser);
  }

  Widget _buildDefaultAvatar(UserModel? user, dynamic firebaseUser) {
    final name = _getDisplayName(user, firebaseUser);
    final initial = name.isNotEmpty ? name[0].toUpperCase() : 'S';
    
    return Container(
      width: 100,
      height: 100,
      decoration: const BoxDecoration(
        color: Color(0xFF2E5BBA),
        shape: BoxShape.circle,
      ),
      child: Center(
        child: Text(
          initial,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 36,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  Widget _buildStatsSection(BuildContext context, UserModel? user) {
    return Row(
      children: [
        Expanded(
          child: _buildStatCard(
            'Saved',
            (user?.savedProjectIds ?? []).length.toString(),
            Icons.bookmark_outline,
            Colors.purple,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: _buildStatCard(
            'Completed',
            (user?.completedProjectIds ?? []).length.toString(),
            Icons.check_circle_outline,
            Colors.green,
          ),
        ),
      ],
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withOpacity(0.2)),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            title,
            style: const TextStyle(
              fontSize: 12,
              color: Colors.grey,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActions(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Quick Actions',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Color(0xFF2E5BBA),
            ),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildActionButton(
                'Edit',
                Icons.edit,
                const Color(0xFF2E5BBA),
                () => _showEditDialog(context),
              ),
              _buildActionButton(
                'Academic',
                Icons.school,
                Colors.green,
                () => _showAcademicDialog(context),
              ),
              _buildActionButton(
                'Share',
                Icons.share,
                Colors.orange,
                () => _showShareDialog(context),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton(String label, IconData icon, Color color, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(12),
        child: Column(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: color, size: 20),
            ),
            const SizedBox(height: 8),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey[700],
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSettingsSection(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Consumer<ThemeProvider>(
            builder: (context, themeProvider, child) {
              return _buildSettingsTile(
                'Dark Mode',
                Icons.dark_mode_outlined,
                Colors.indigo,
                trailing: Switch(
                  value: themeProvider.isDarkMode,
                  onChanged: (value) {
                    if (value) {
                      themeProvider.setThemeMode(ThemeMode.dark);
                    } else {
                      themeProvider.setThemeMode(ThemeMode.light);
                    }
                  },
                ),
              );
            },
          ),
          const Divider(height: 1),
          _buildSettingsTile(
            'About',
            Icons.info_outline,
            Colors.blue,
            onTap: () => _showAboutDialog(context),
          ),
          const Divider(height: 1),
          _buildSettingsTile(
            'Sign Out',
            Icons.logout,
            Colors.red,
            onTap: () => _showLogoutConfirmation(context),
          ),
        ],
      ),
    );
  }

  Widget _buildSettingsTile(
    String title,
    IconData icon,
    Color color, {
    Widget? trailing,
    VoidCallback? onTap,
  }) {
    return ListTile(
      leading: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(icon, color: color, size: 20),
      ),
      title: Text(
        title,
        style: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w600,
        ),
      ),
      trailing: trailing ?? const Icon(Icons.arrow_forward_ios, size: 14),
      onTap: onTap,
    );
  }

  Widget _buildAboutDeveloperSection(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: const Color(0xFF2E5BBA).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(
                  Icons.person,
                  color: Color(0xFF2E5BBA),
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              const Text(
                'About Developer',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF2E5BBA),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _buildDeveloperInfoRow(Icons.account_circle, 'Name', 'Jagdish Bhawar'),
          const SizedBox(height: 12),
          _buildDeveloperInfoRow(Icons.school, 'College', 'CSE Student at College of Engineering Phaltan'),
          const SizedBox(height: 12),
          GestureDetector(
            onTap: () => _launchLinkedIn(),
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
              decoration: BoxDecoration(
                color: const Color(0xFF0077B5).withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: const Color(0xFF0077B5).withOpacity(0.3)),
              ),
              child: Row(
                children: [
                  Container(
                    width: 24,
                    height: 24,
                    decoration: BoxDecoration(
                      color: const Color(0xFF0077B5),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: const Icon(
                      Icons.link,
                      color: Colors.white,
                      size: 14,
                    ),
                  ),
                  const SizedBox(width: 8),
                  const Expanded(
                    child: Text(
                      'Connect on LinkedIn',
                      style: TextStyle(
                        color: Color(0xFF0077B5),
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                      ),
                    ),
                  ),
                  const Icon(
                    Icons.open_in_new,
                    color: Color(0xFF0077B5),
                    size: 16,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDeveloperInfoRow(IconData icon, String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(
          icon,
          color: Colors.grey[600],
          size: 18,
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[600],
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 14,
                  color: Color(0xFF2D3748),
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Future<void> _launchLinkedIn() async {
    final Uri linkedInUrl = Uri.parse('https://www.linkedin.com/in/jagdish-bhawar-1403b72a1');
    try {
      if (await canLaunchUrl(linkedInUrl)) {
        await launchUrl(linkedInUrl, mode: LaunchMode.externalApplication);
      } else {
        if (mounted) {
          _showError(context, 'Could not open LinkedIn profile');
        }
      }
    } catch (e) {
      if (mounted) {
        _showError(context, 'Error opening LinkedIn: ${e.toString()}');
      }
    }
  }

  String _getDisplayName(UserModel? user, dynamic firebaseUser) {
    if (user?.displayName != null && user!.displayName.isNotEmpty) {
      return user.displayName;
    }
    if (firebaseUser?.displayName != null && firebaseUser.displayName.isNotEmpty) {
      return firebaseUser.displayName;
    }
    return 'Student';
  }

  String _getEmail(UserModel? user, dynamic firebaseUser) {
    if (user?.email != null && user!.email.isNotEmpty) {
      return user.email;
    }
    if (firebaseUser?.email != null && firebaseUser.email.isNotEmpty) {
      return firebaseUser.email;
    }
    return 'No email';
  }

  void _handleLogout(BuildContext context) async {
    try {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      await authProvider.signOut();
      if (mounted) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => const LoginScreen()),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Logout failed. Please try again.'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _showEditDialog(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final nameController = TextEditingController(
      text: authProvider.userModel?.displayName ?? '',
    );
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Edit Profile'),
        content: TextField(
          controller: nameController,
          decoration: const InputDecoration(
            labelText: 'Display Name',
            border: OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              try {
                GoRouter.of(context).pop();
              } catch (e) {
                context.go('/dashboard');
              }
            },
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              final newName = nameController.text.trim();
              if (newName.isNotEmpty) {
                try {
                  await authProvider.updateUserProfile(displayName: newName);
                  if (mounted) {
                    try {
                      GoRouter.of(context).pop();
                    } catch (e) {
                      context.go('/dashboard');
                    };
                    _showSuccess(context, 'Profile updated successfully');
                  }
                } catch (e) {
                  if (mounted) {
                    _showError(context, 'Failed to update profile');
                  }
                }
              }
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  void _showAcademicDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Academic Information'),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Institution: Your College/University'),
            SizedBox(height: 8),
            Text('Course: Computer Science'),
            SizedBox(height: 8),
            Text('Year: Final Year'),
            SizedBox(height: 8),
            Text('Specialization: Software Engineering'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              try {
                GoRouter.of(context).pop();
              } catch (e) {
                context.go('/dashboard');
              }
            },
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  void _showShareDialog(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final user = authProvider.user;
    
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Container(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Share Profile',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Name: ${user?.displayName ?? "Student"}\n'
              'Email: ${user?.email ?? "No email"}\n'
              'Status: Active Student\n'
              'App: CollegePro',
              style: const TextStyle(fontSize: 14),
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () {
                      try {
                      GoRouter.of(context).pop();
                    } catch (e) {
                      context.go('/dashboard');
                    };
                      _showSuccess(context, 'Profile copied to clipboard!');
                    },
                    child: const Text('Copy'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      try {
                      GoRouter.of(context).pop();
                    } catch (e) {
                      context.go('/dashboard');
                    };
                      _showComingSoon(context, 'Share feature');
                    },
                    child: const Text('Share'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _showAboutDialog(BuildContext context) {
    showAboutDialog(
      context: context,
      applicationName: 'CollegePro',
      applicationVersion: '1.0.0',
      applicationIcon: Container(
        width: 48,
        height: 48,
        decoration: BoxDecoration(
          color: const Color(0xFF2E5BBA),
          borderRadius: BorderRadius.circular(12),
        ),
        child: const Icon(
          Icons.school,
          color: Colors.white,
          size: 24,
        ),
      ),
      children: const [
        Text('An educational app to help students find research papers and manage academic profiles.'),
      ],
    );
  }

  void _showLogoutConfirmation(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Sign Out'),
        content: const Text('Are you sure you want to sign out?'),
        actions: [
          TextButton(
            onPressed: () {
              try {
                GoRouter.of(context).pop();
              } catch (e) {
                context.go('/dashboard');
              }
            },
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              try {
                GoRouter.of(context).pop();
              } catch (e) {
                context.go('/dashboard');
              };
              _handleLogout(context);
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Sign Out'),
          ),
        ],
      ),
    );
  }

  void _showSuccess(BuildContext context, String message) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: Colors.green,
        ),
      );
    }
  }

  void _showError(BuildContext context, String message) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _showComingSoon(BuildContext context, String feature) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('$feature coming soon!'),
          backgroundColor: const Color(0xFF2E5BBA),
        ),
      );
    }
  }

  Future<void> _showImageSourceDialog() async {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    showModalBottomSheet(
      context: context,
      backgroundColor: isDark ? const Color(0xFF1A1A1A) : Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Container(
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
            Text(
              'Update Profile Picture',
              style: GoogleFonts.inter(
                fontSize: 20,
                fontWeight: FontWeight.w600,
                color: isDark ? Colors.white : Colors.black87,
              ),
            ),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildImageSourceOption(
                  'Camera',
                  Icons.camera_alt,
                  const Color(0xFF2E5BBA),
                  () {
                    try {
                      GoRouter.of(context).pop();
                    } catch (e) {
                      context.go('/dashboard');
                    };
                    _pickAndUploadImage(ImageSource.camera);
                  },
                ),
                _buildImageSourceOption(
                  'Gallery',
                  Icons.photo_library,
                  Colors.green,
                  () {
                    try {
                      GoRouter.of(context).pop();
                    } catch (e) {
                      context.go('/dashboard');
                    };
                    _pickAndUploadImage(ImageSource.gallery);
                  },
                ),
                _buildImageSourceOption(
                  'Remove',
                  Icons.delete,
                  Colors.red,
                  () {
                    try {
                      GoRouter.of(context).pop();
                    } catch (e) {
                      context.go('/dashboard');
                    };
                    _removeProfilePicture();
                  },
                ),
              ],
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildImageSourceOption(String label, IconData icon, Color color, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 80,
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withOpacity(0.3)),
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 28),
            const SizedBox(height: 8),
            Text(
              label,
              style: GoogleFonts.inter(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _pickAndUploadImage(ImageSource source) async {
    try {
      if (mounted) {
        setState(() {
          _isUploadingImage = true;
        });
      }

      final XFile? imageFile = await _imageService.pickImage(source: source);
      if (imageFile == null) {
        if (mounted) {
          setState(() {
            _isUploadingImage = false;
          });
        }
        return;
      }

      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      if (authProvider.user == null) {
        if (mounted) {
          _showError(context, 'Please login to update profile picture');
          setState(() {
            _isUploadingImage = false;
          });
        }
        return;
      }

      // Delete old profile image if exists
      await _imageService.deleteProfileImageFromDatabase(authProvider.user!.uid);

      // Upload new image to database
      final downloadUrl = await _imageService.uploadProfileImageToDatabase(
        authProvider.user!.uid,
        imageFile,
      );

      if (mounted) {
        if (downloadUrl != null && downloadUrl.isNotEmpty) {
          // Update user profile with new photo URL
          await authProvider.updateUserProfile(photoUrl: downloadUrl);
          _showSuccess(context, 'Profile picture updated successfully!');
        } else {
          _showError(context, 'Failed to upload image. Please check your internet connection and try again.');
        }
      }
    } catch (e) {
      if (mounted) {
        String errorMessage = 'Error updating profile picture';
        if (e.toString().contains('Permission denied')) {
          errorMessage = 'Permission denied. Please check Firebase Storage rules.';
        } else if (e.toString().contains('Network error')) {
          errorMessage = 'Network error. Please check your internet connection.';
        } else if (e.toString().contains('Image too large')) {
          errorMessage = 'Image too large. Please select an image smaller than 5MB.';
        } else if (e.toString().contains('Unsupported image format')) {
          errorMessage = 'Unsupported image format. Please use JPG, PNG, or WebP.';
        } else {
          errorMessage = 'Error updating profile picture: ${e.toString()}';
        }
        _showError(context, errorMessage);
      }
    } finally {
      if (mounted) {
        setState(() {
          _isUploadingImage = false;
        });
      }
    }
  }

  Future<void> _removeProfilePicture() async {
    try {
      if (mounted) {
        setState(() {
          _isUploadingImage = true;
        });
      }

      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      if (authProvider.user == null) {
        if (mounted) {
          _showError(context, 'Please login to update profile picture');
          setState(() {
            _isUploadingImage = false;
          });
        }
        return;
      }

      // Delete current profile image from database
      await _imageService.deleteProfileImageFromDatabase(authProvider.user!.uid);

      // Update user profile to remove photo URL
      if (mounted) {
        await authProvider.updateUserProfile(photoUrl: '');
        _showSuccess(context, 'Profile picture removed successfully!');
      }
    } catch (e) {
      if (mounted) {
        String errorMessage = 'Error removing profile picture';
        if (e.toString().contains('Permission denied')) {
          errorMessage = 'Permission denied. Please check Firebase Storage rules.';
        } else if (e.toString().contains('Network error')) {
          errorMessage = 'Network error. Please check your internet connection.';
        } else {
          errorMessage = 'Error removing profile picture: ${e.toString()}';
        }
        _showError(context, errorMessage);
      }
    } finally {
      if (mounted) {
        setState(() {
          _isUploadingImage = false;
        });
      }
    }
  }
}
