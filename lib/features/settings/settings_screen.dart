import 'package:flutter/material.dart';
import '../../core/widgets/drawer_screen_wrapper.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../../core/providers/auth_provider.dart';
import '../../core/providers/theme_provider.dart';
import '../../core/services/onesignal_service.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _notificationsEnabled = true;
  bool _emailNotifications = false;
  bool _pushNotifications = true;
  String _selectedLanguage = 'English';

  final List<String> _languages = ['English', 'Spanish', 'French', 'German', 'Hindi'];
  final List<String> _themes = ['Light', 'Dark', 'System'];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final themeProvider = Provider.of<ThemeProvider>(context);
    
    return DrawerScreenWrapper(
      title: 'Settings',
      child: Scaffold(
      backgroundColor: isDark ? const Color(0xFF0F0F0F) : const Color(0xFFF8F9FA),
      appBar: AppBar(
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF667eea), Color(0xFF764ba2)],
                ),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(
                Icons.settings,
                color: Colors.white,
                size: 20,
              ),
            ),
            const SizedBox(width: 12),
            const Text('Settings'),
          ],
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => DrawerScreenWrapper.openDrawer(context),
        ),
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Color(0xFF667eea),
                Color(0xFF764ba2),
                Color(0xFF6C5CE7),
              ],
            ),
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Profile Section
            _buildSectionCard(
              context,
              'Profile Settings',
              Icons.person_rounded,
              Colors.blue,
              [
                _buildSettingsTile(
                  context,
                  Icons.edit_rounded,
                  'Edit Profile',
                  'Update your personal information',
                  Colors.blue,
                  onTap: () => _showEditProfileDialog(context),
                ),
                _buildSettingsTile(
                  context,
                  Icons.lock_rounded,
                  'Change Password',
                  'Update your account password',
                  Colors.orange,
                  onTap: () => _showChangePasswordDialog(context),
                ),
                _buildSettingsTile(
                  context,
                  Icons.privacy_tip_rounded,
                  'Privacy Settings',
                  'Manage your privacy preferences',
                  Colors.purple,
                  onTap: () => _showPrivacySettings(context),
                ),
              ],
            ),
            
            const SizedBox(height: 20),
            
            // Notifications Section
            _buildSectionCard(
              context,
              'Notifications',
              Icons.notifications_rounded,
              Colors.green,
              [
                _buildSwitchTile(
                  context,
                  Icons.notifications_active_rounded,
                  'Enable Notifications',
                  'Receive app notifications',
                  Colors.green,
                  _notificationsEnabled,
                  (value) => setState(() => _notificationsEnabled = value),
                ),
                _buildSwitchTile(
                  context,
                  Icons.email_rounded,
                  'Email Notifications',
                  'Receive notifications via email',
                  Colors.blue,
                  _emailNotifications,
                  (value) => setState(() => _emailNotifications = value),
                ),
                _buildSwitchTile(
                  context,
                  Icons.phone_android_rounded,
                  'Push Notifications',
                  'Receive push notifications',
                  Colors.purple,
                  _pushNotifications,
                  (value) async {
                    setState(() => _pushNotifications = value);
                    if (value) {
                      // Initialize OneSignal with permission when user enables notifications
                      final oneSignalService = OneSignalService();
                      await oneSignalService.initializeWithPermission();
                    }
                  },
                ),
              ],
            ),
            
            const SizedBox(height: 20),
            
            // Appearance Section
            _buildSectionCard(
              context,
              'Appearance',
              Icons.palette_rounded,
              Colors.purple,
              [
                _buildDropdownTile(
                  context,
                  Icons.language_rounded,
                  'Language',
                  'Select your preferred language',
                  Colors.orange,
                  _selectedLanguage,
                  _languages,
                  (value) => setState(() => _selectedLanguage = value!),
                ),
                _buildDropdownTile(
                  context,
                  Icons.brightness_6_rounded,
                  'Theme',
                  'Choose app theme',
                  Colors.indigo,
                  themeProvider.themeName,
                  _themes,
                  (value) async {
                    if (value != null) {
                      await themeProvider.setThemeFromString(value);
                    }
                  },
                ),
              ],
            ),
            
            const SizedBox(height: 20),
            
            // Support Section
            _buildSectionCard(
              context,
              'Support & Info',
              Icons.help_rounded,
              Colors.teal,
              [
                _buildSettingsTile(
                  context,
                  Icons.help_center_rounded,
                  'Help Center',
                  'Get help and support',
                  Colors.teal,
                  onTap: () => _showHelpCenter(context),
                ),
                _buildSettingsTile(
                  context,
                  Icons.feedback_rounded,
                  'Send Feedback',
                  'Share your thoughts with us',
                  Colors.green,
                  onTap: () => _showFeedbackDialog(context),
                ),
                _buildSettingsTile(
                  context,
                  Icons.notifications_active_rounded,
                  'Test Notifications',
                  'Test push notification system',
                  Colors.orange,
                  onTap: () => _testNotifications(context),
                ),
                _buildSettingsTile(
                  context,
                  Icons.info_rounded,
                  'About App',
                  'App version and information',
                  Colors.blue,
                  onTap: () => _showAboutDialog(context),
                ),
              ],
            ),
            
            const SizedBox(height: 20),
            
            // Account Section
            _buildSectionCard(
              context,
              'Account',
              Icons.account_circle_rounded,
              Colors.red,
              [
                _buildSettingsTile(
                  context,
                  Icons.logout_rounded,
                  'Sign Out',
                  'Sign out of your account',
                  Colors.red,
                  onTap: () => _showSignOutDialog(context),
                ),
                _buildSettingsTile(
                  context,
                  Icons.delete_forever_rounded,
                  'Delete Account',
                  'Permanently delete your account',
                  Colors.red,
                  onTap: () => _showDeleteAccountDialog(context),
                ),
              ],
            ),
            
            const SizedBox(height: 30),
          ],
        ),
      ),
    ),
    );
  }

  Widget _buildSectionCard(
    BuildContext context,
    String title,
    IconData icon,
    Color color,
    List<Widget> children,
  ) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    
    return Container(
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: isDark ? Border.all(
          color: Colors.grey.withOpacity(0.2),
          width: 1,
        ) : null,
        boxShadow: [
          BoxShadow(
            color: isDark 
                ? Colors.black.withOpacity(0.3)
                : Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(icon, color: color, size: 24),
                ),
                const SizedBox(width: 12),
                Text(
                  title,
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: isDark ? Colors.white : Colors.grey[800],
                  ),
                ),
              ],
            ),
          ),
          ...children,
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
    VoidCallback? onTap,
  }) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
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
        style: Theme.of(context).textTheme.titleMedium?.copyWith(
          fontWeight: FontWeight.w600,
        ),
      ),
      subtitle: Text(
        subtitle,
        style: Theme.of(context).textTheme.bodySmall?.copyWith(
          color: Colors.grey[600],
        ),
      ),
      trailing: Icon(
        Icons.arrow_forward_ios_rounded,
        size: 16,
        color: Colors.grey[400],
      ),
      onTap: onTap,
    );
  }

  Widget _buildSwitchTile(
    BuildContext context,
    IconData icon,
    String title,
    String subtitle,
    Color color,
    bool value,
    ValueChanged<bool> onChanged,
  ) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
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
        style: Theme.of(context).textTheme.titleMedium?.copyWith(
          fontWeight: FontWeight.w600,
        ),
      ),
      subtitle: Text(
        subtitle,
        style: Theme.of(context).textTheme.bodySmall?.copyWith(
          color: Colors.grey[600],
        ),
      ),
      trailing: Switch(
        value: value,
        onChanged: onChanged,
        activeColor: color,
      ),
    );
  }

  Widget _buildDropdownTile(
    BuildContext context,
    IconData icon,
    String title,
    String subtitle,
    Color color,
    String value,
    List<String> items,
    ValueChanged<String?> onChanged,
  ) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
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
        style: Theme.of(context).textTheme.titleMedium?.copyWith(
          fontWeight: FontWeight.w600,
        ),
      ),
      subtitle: Text(
        subtitle,
        style: Theme.of(context).textTheme.bodySmall?.copyWith(
          color: Colors.grey[600],
        ),
      ),
      trailing: DropdownButton<String>(
        value: value,
        underline: const SizedBox(),
        items: items.map((item) => DropdownMenuItem(
          value: item,
          child: Text(item),
        )).toList(),
        onChanged: onChanged,
      ),
    );
  }

  void _showEditProfileDialog(BuildContext context) {
    final nameController = TextEditingController();
    final emailController = TextEditingController();
    final phoneController = TextEditingController();
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Edit Profile'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: const InputDecoration(
                  labelText: 'Full Name',
                  prefixIcon: Icon(Icons.person),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: emailController,
                decoration: const InputDecoration(
                  labelText: 'Email',
                  prefixIcon: Icon(Icons.email),
                ),
                keyboardType: TextInputType.emailAddress,
              ),
              const SizedBox(height: 16),
              TextField(
                controller: phoneController,
                decoration: const InputDecoration(
                  labelText: 'Phone Number',
                  prefixIcon: Icon(Icons.phone),
                ),
                keyboardType: TextInputType.phone,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Profile updated successfully!'),
                  backgroundColor: Colors.green,
                ),
              );
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  void _showChangePasswordDialog(BuildContext context) {
    final currentPasswordController = TextEditingController();
    final newPasswordController = TextEditingController();
    final confirmPasswordController = TextEditingController();
    bool obscureCurrentPassword = true;
    bool obscureNewPassword = true;
    bool obscureConfirmPassword = true;
    
    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: const Text('Change Password'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: currentPasswordController,
                  obscureText: obscureCurrentPassword,
                  decoration: InputDecoration(
                    labelText: 'Current Password',
                    prefixIcon: const Icon(Icons.lock),
                    suffixIcon: IconButton(
                      icon: Icon(obscureCurrentPassword ? Icons.visibility : Icons.visibility_off),
                      onPressed: () => setState(() => obscureCurrentPassword = !obscureCurrentPassword),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: newPasswordController,
                  obscureText: obscureNewPassword,
                  decoration: InputDecoration(
                    labelText: 'New Password',
                    prefixIcon: const Icon(Icons.lock_outline),
                    suffixIcon: IconButton(
                      icon: Icon(obscureNewPassword ? Icons.visibility : Icons.visibility_off),
                      onPressed: () => setState(() => obscureNewPassword = !obscureNewPassword),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: confirmPasswordController,
                  obscureText: obscureConfirmPassword,
                  decoration: InputDecoration(
                    labelText: 'Confirm New Password',
                    prefixIcon: const Icon(Icons.lock_outline),
                    suffixIcon: IconButton(
                      icon: Icon(obscureConfirmPassword ? Icons.visibility : Icons.visibility_off),
                      onPressed: () => setState(() => obscureConfirmPassword = !obscureConfirmPassword),
                    ),
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                if (newPasswordController.text != confirmPasswordController.text) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Passwords do not match!'),
                      backgroundColor: Colors.red,
                    ),
                  );
                  return;
                }
                if (newPasswordController.text.length < 6) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Password must be at least 6 characters!'),
                      backgroundColor: Colors.red,
                    ),
                  );
                  return;
                }
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Password changed successfully!'),
                    backgroundColor: Colors.green,
                  ),
                );
              },
              child: const Text('Change Password'),
            ),
          ],
        ),
      ),
    );
  }

  void _showPrivacySettings(BuildContext context) {
    bool dataCollection = true;
    bool analytics = false;
    bool personalization = true;
    bool thirdPartySharing = false;
    
    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: const Text('Privacy Settings'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Control how your data is used:', style: TextStyle(fontWeight: FontWeight.w600)),
                const SizedBox(height: 16),
                SwitchListTile(
                  title: const Text('Data Collection'),
                  subtitle: const Text('Allow app to collect usage data'),
                  value: dataCollection,
                  onChanged: (value) => setState(() => dataCollection = value),
                ),
                SwitchListTile(
                  title: const Text('Analytics'),
                  subtitle: const Text('Help improve app with analytics'),
                  value: analytics,
                  onChanged: (value) => setState(() => analytics = value),
                ),
                SwitchListTile(
                  title: const Text('Personalization'),
                  subtitle: const Text('Personalize your experience'),
                  value: personalization,
                  onChanged: (value) => setState(() => personalization = value),
                ),
                SwitchListTile(
                  title: const Text('Third-party Sharing'),
                  subtitle: const Text('Share data with partners'),
                  value: thirdPartySharing,
                  onChanged: (value) => setState(() => thirdPartySharing = value),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Privacy settings updated!'),
                    backgroundColor: Colors.green,
                  ),
                );
              },
              child: const Text('Save'),
            ),
          ],
        ),
      ),
    );
  }

  void _showHelpCenter(BuildContext context) {
    final List<Map<String, String>> helpTopics = [
      {'title': 'Getting Started', 'content': 'Learn how to use CollegePro effectively for your academic journey.'},
      {'title': 'AI Interview', 'content': 'Practice interviews with AI-powered feedback and tips.'},
      {'title': 'Study Notes', 'content': 'Access and download subject-wise study materials.'},
      {'title': 'Coding Practice', 'content': 'Improve your programming skills with coding challenges.'},
      {'title': 'Community Doubts', 'content': 'Ask questions and help other students in the community.'},
      {'title': 'Notifications', 'content': 'Manage your notification preferences and settings.'},
      {'title': 'Account Issues', 'content': 'Resolve login, password, and account-related problems.'},
      {'title': 'Technical Support', 'content': 'Get help with app crashes, bugs, and technical issues.'},
    ];
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Help Center'),
        content: SizedBox(
          width: double.maxFinite,
          height: 400,
          child: ListView.builder(
            itemCount: helpTopics.length,
            itemBuilder: (context, index) {
              final topic = helpTopics[index];
              return Card(
                margin: const EdgeInsets.only(bottom: 8),
                child: ExpansionTile(
                  leading: const Icon(Icons.help_outline, color: Colors.blue),
                  title: Text(topic['title']!, style: const TextStyle(fontWeight: FontWeight.w600)),
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(16),
                      child: Text(topic['content']!),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _showContactSupport(context);
            },
            child: const Text('Contact Support'),
          ),
        ],
      ),
    );
  }
  
  void _showContactSupport(BuildContext context) {
    final messageController = TextEditingController();
    String selectedCategory = 'General';
    final categories = ['General', 'Technical', 'Account', 'Feature Request', 'Bug Report'];
    
    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: const Text('Contact Support'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Category:', style: TextStyle(fontWeight: FontWeight.w600)),
                const SizedBox(height: 8),
                DropdownButtonFormField<String>(
                  value: selectedCategory,
                  items: categories.map((category) => DropdownMenuItem(
                    value: category,
                    child: Text(category),
                  )).toList(),
                  onChanged: (value) => setState(() => selectedCategory = value!),
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  ),
                ),
                const SizedBox(height: 16),
                const Text('Message:', style: TextStyle(fontWeight: FontWeight.w600)),
                const SizedBox(height: 8),
                TextField(
                  controller: messageController,
                  maxLines: 4,
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    hintText: 'Describe your issue or question...',
                    contentPadding: EdgeInsets.all(12),
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                if (messageController.text.trim().isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Please enter a message'),
                      backgroundColor: Colors.red,
                    ),
                  );
                  return;
                }
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Support request sent! We\'ll get back to you soon.'),
                    backgroundColor: Colors.green,
                  ),
                );
              },
              child: const Text('Send'),
            ),
          ],
        ),
      ),
    );
  }

  void _showFeedbackDialog(BuildContext context) {
    final feedbackController = TextEditingController();
    double rating = 5.0;
    String feedbackType = 'General';
    final feedbackTypes = ['General', 'Bug Report', 'Feature Request', 'UI/UX', 'Performance'];
    
    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: const Text('Send Feedback'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Rate your experience:', style: TextStyle(fontWeight: FontWeight.w600)),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: Slider(
                        value: rating,
                        min: 1,
                        max: 5,
                        divisions: 4,
                        label: '${rating.round()} stars',
                        onChanged: (value) => setState(() => rating = value),
                      ),
                    ),
                    Text('${rating.round()}/5 ⭐'),
                  ],
                ),
                const SizedBox(height: 16),
                const Text('Feedback Type:', style: TextStyle(fontWeight: FontWeight.w600)),
                const SizedBox(height: 8),
                DropdownButtonFormField<String>(
                  value: feedbackType,
                  items: feedbackTypes.map((type) => DropdownMenuItem(
                    value: type,
                    child: Text(type),
                  )).toList(),
                  onChanged: (value) => setState(() => feedbackType = value!),
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  ),
                ),
                const SizedBox(height: 16),
                const Text('Your Feedback:', style: TextStyle(fontWeight: FontWeight.w600)),
                const SizedBox(height: 8),
                TextField(
                  controller: feedbackController,
                  maxLines: 4,
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    hintText: 'Tell us what you think...',
                    contentPadding: EdgeInsets.all(12),
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                if (feedbackController.text.trim().isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Please enter your feedback'),
                      backgroundColor: Colors.red,
                    ),
                  );
                  return;
                }
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Thank you for your feedback! 🙏'),
                    backgroundColor: Colors.green,
                  ),
                );
              },
              child: const Text('Send Feedback'),
            ),
          ],
        ),
      ),
    );
  }

  void _showAboutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('About CollegePro'),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('CollegePro v2.0'),
            SizedBox(height: 8),
            Text('Your ultimate college companion app for academic success.'),
            SizedBox(height: 8),
            Text('© 2024 CollegePro Team'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  void _showSignOutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Sign Out'),
        content: const Text('Are you sure you want to sign out?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              final authProvider = Provider.of<AuthProvider>(context, listen: false);
              await authProvider.signOut();
              if (context.mounted) {
                context.go('/login');
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Sign Out', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _showDeleteAccountDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Account'),
        content: const Text('This action cannot be undone. Are you sure you want to permanently delete your account?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Account deletion feature coming soon!'),
                  backgroundColor: Colors.red,
                ),
              );
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Delete', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _testNotifications(BuildContext context) async {
    try {
      // Show loading dialog
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const AlertDialog(
          content: Row(
            children: [
              CircularProgressIndicator(),
              SizedBox(width: 16),
              Text('Testing notifications...'),
            ],
          ),
        ),
      );

      // Initialize OneSignal with permission if not already done
      final oneSignalService = OneSignalService();
      await oneSignalService.initializeWithPermission();
      
      // Send test notification
      final result = await oneSignalService.sendTestNotification();
      
      // Close loading dialog
      if (context.mounted) {
        Navigator.pop(context);
      }
      
      // Show result
      if (context.mounted) {
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: Text(result ? '✅ Success' : '❌ Failed'),
            content: Text(result 
              ? 'Test notification sent successfully! Check your notification tray.'
              : 'Failed to send test notification. Please check your notification permissions and try again.'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('OK'),
              ),
            ],
          ),
        );
      }
    } catch (e) {
      // Close loading dialog if open
      if (context.mounted) {
        Navigator.pop(context);
      }
      
      // Show error
      if (context.mounted) {
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('❌ Error'),
            content: Text('Failed to test notifications: $e'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('OK'),
              ),
            ],
          ),
        );
      }
    }
  }
}
