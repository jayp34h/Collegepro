import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../providers/user_progress_provider.dart';

class ModernSideDrawer extends StatelessWidget {
  const ModernSideDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final screenWidth = MediaQuery.of(context).size.width;
    final isSmallScreen = screenWidth < 600;
    
    // Initialize progress tracking for current user
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final progressProvider = Provider.of<UserProgressProvider>(context, listen: false);
    
    if (authProvider.user != null && progressProvider.userProgress == null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        progressProvider.initializeProgress(authProvider.user!.uid);
      });
    }
    
    return Drawer(
      backgroundColor: isDark ? const Color(0xFF1A1A1A) : Colors.white,
      child: Column(
        children: [
          // Modern Header Section - Responsive height
          Container(
            height: isSmallScreen ? 180 : 220,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  const Color(0xFF667eea),
                  const Color(0xFF764ba2),
                  const Color(0xFFf093fb),
                  const Color(0xFFf5576c),
                ],
                stops: const [0.0, 0.3, 0.7, 1.0],
              ),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF667eea).withOpacity(0.3),
                  blurRadius: 20,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: SafeArea(
              child: Padding(
                padding: EdgeInsets.all(isSmallScreen ? 12 : 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Profile Section
                    Row(
                      children: [
                        // Avatar - Responsive size
                        Container(
                          width: isSmallScreen ? 50 : 60,
                          height: isSmallScreen ? 50 : 60,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            gradient: LinearGradient(
                              colors: [
                                Colors.white.withOpacity(0.3),
                                Colors.white.withOpacity(0.1),
                              ],
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.2),
                                blurRadius: 15,
                                offset: const Offset(0, 8),
                              ),
                            ],
                          ),
                          child: Container(
                            margin: const EdgeInsets.all(4),
                            decoration: const BoxDecoration(
                              shape: BoxShape.circle,
                              color: Colors.white,
                            ),
                            child: Icon(
                              Icons.school_rounded,
                              size: isSmallScreen ? 28 : 32,
                              color: Color(0xFF667eea),
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Welcome Back!',
                                style: (isSmallScreen ? theme.textTheme.titleMedium : theme.textTheme.titleLarge)?.copyWith(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  shadows: [
                                    Shadow(
                                      color: Colors.black.withOpacity(0.3),
                                      offset: const Offset(0, 2),
                                      blurRadius: 4,
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 4),
                              Container(
                                padding: EdgeInsets.symmetric(
                                  horizontal: isSmallScreen ? 6 : 8,
                                  vertical: isSmallScreen ? 2 : 4,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(0.2),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(
                                      Icons.star,
                                      size: isSmallScreen ? 12 : 14,
                                      color: Colors.yellow[300],
                                    ),
                                    SizedBox(width: isSmallScreen ? 2 : 4),
                                    Text(
                                      'Premium Student',
                                      style: theme.textTheme.bodySmall?.copyWith(
                                        color: Colors.white,
                                        fontWeight: FontWeight.w600,
                                        fontSize: isSmallScreen ? 10 : null,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    
                    SizedBox(height: isSmallScreen ? 12 : 16),
                    
                    // Progress Section - Completely fixed overflow
                    Container(
                      margin: EdgeInsets.only(top: isSmallScreen ? 4 : 6),
                      padding: EdgeInsets.all(isSmallScreen ? 4 : 6),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                          color: Colors.white.withOpacity(0.3),
                          width: 1,
                        ),
                      ),
                      child: Consumer<UserProgressProvider>(
                        builder: (context, progressProvider, child) {
                          final progress = progressProvider.progressPercentage;
                          final completedActivities = progressProvider.completedActivities;
                          
                          return IntrinsicHeight(
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Container(
                                      padding: EdgeInsets.all(isSmallScreen ? 3 : 4),
                                      decoration: BoxDecoration(
                                        color: Colors.white.withOpacity(0.2),
                                        borderRadius: BorderRadius.circular(4),
                                      ),
                                      child: Icon(
                                        Icons.trending_up_rounded,
                                        color: Colors.white,
                                        size: isSmallScreen ? 10 : 12,
                                      ),
                                    ),
                                    const SizedBox(width: 4),
                                    Expanded(
                                      child: Text(
                                        'Progress',
                                        style: theme.textTheme.bodySmall?.copyWith(
                                          color: Colors.white,
                                          fontWeight: FontWeight.bold,
                                          fontSize: isSmallScreen ? 9 : 10,
                                        ),
                                        overflow: TextOverflow.ellipsis,
                                        maxLines: 1,
                                      ),
                                    ),
                                  ],
                                ),
                                SizedBox(height: isSmallScreen ? 2 : 3),
                                LinearProgressIndicator(
                                  value: progress / 100,
                                  backgroundColor: Colors.white.withOpacity(0.2),
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                    progress > 0 ? Colors.yellow[300]! : Colors.grey[400]!,
                                  ),
                                  minHeight: isSmallScreen ? 2 : 3,
                                ),
                                SizedBox(height: isSmallScreen ? 2 : 3),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Flexible(
                                      flex: 1,
                                      child: Text(
                                        '${progress.toStringAsFixed(0)}%',
                                        style: theme.textTheme.bodySmall?.copyWith(
                                          color: Colors.white.withOpacity(0.9),
                                          fontWeight: FontWeight.w600,
                                          fontSize: isSmallScreen ? 8 : 9,
                                        ),
                                        overflow: TextOverflow.ellipsis,
                                        maxLines: 1,
                                      ),
                                    ),
                                    Flexible(
                                      flex: 2,
                                      child: Text(
                                        '$completedActivities Act.',
                                        style: theme.textTheme.bodySmall?.copyWith(
                                          color: Colors.green[300],
                                          fontWeight: FontWeight.bold,
                                          fontSize: isSmallScreen ? 8 : 9,
                                        ),
                                        overflow: TextOverflow.ellipsis,
                                        maxLines: 1,
                                        textAlign: TextAlign.end,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          
          // Menu Items
          Expanded(
            child: Container(
              padding: EdgeInsets.symmetric(
                horizontal: isSmallScreen ? 12 : 16, 
                vertical: isSmallScreen ? 8 : 12
              ),
              child: Column(
                children: [
                  // Achievement Banner
                  Container(
                    margin: EdgeInsets.only(bottom: isSmallScreen ? 12 : 16),
                    padding: EdgeInsets.all(isSmallScreen ? 8 : 12),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          Colors.amber.withOpacity(0.15),
                          Colors.orange.withOpacity(0.08),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: Colors.amber.withOpacity(0.3),
                        width: 1,
                      ),
                    ),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(6),
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [Colors.amber, Colors.orange],
                            ),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Icon(
                            Icons.emoji_events,
                            color: Colors.white,
                            size: 16,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Achievement Unlocked!',
                                style: theme.textTheme.bodySmall?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.amber[700],
                                ),
                              ),
                              Text(
                                'Resume Master Badge',
                                style: theme.textTheme.bodySmall?.copyWith(
                                  color: Colors.grey[600],
                                  fontSize: 11,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  
                  // Menu Items
                  Expanded(
                    child: ListView(
                      padding: EdgeInsets.zero,
                      children: [
                        _buildDrawerItem(
                          context,
                          icon: Icons.description_outlined,
                          title: 'Resume Builder',
                          subtitle: 'AI-powered resume creation',
                          onTap: () => _navigateToRoute(context, '/resume'),
                          color: const Color(0xFF667eea),
                        ),
                        _buildDrawerItem(
                          context,
                          icon: Icons.school_outlined,
                          title: 'Scholarships',
                          subtitle: 'Find funding opportunities',
                          onTap: () => _navigateToRoute(context, '/scholarships'),
                          color: Colors.orange,
                        ),
                        _buildDrawerItem(
                          context,
                          icon: Icons.work_outline,
                          title: 'Internships',
                          subtitle: 'Discover career opportunities',
                          onTap: () => _navigateToRoute(context, '/internships'),
                          color: Colors.green,
                        ),
                        _buildDrawerItem(
                          context,
                          icon: Icons.code_outlined,
                          title: 'Hackathons',
                          subtitle: 'Join coding competitions',
                          onTap: () => _navigateToRoute(context, '/hackathons'),
                          color: Colors.purple,
                        ),
                        _buildDrawerItem(
                          context,
                          icon: Icons.psychology_outlined,
                          title: 'AI Interview',
                          subtitle: 'Practice with Arya AI interviewer',
                          onTap: () => _navigateToRoute(context, '/ai-interview'),
                          color: const Color(0xFF667eea),
                        ),
                        _buildDrawerItem(
                          context,
                          icon: Icons.terminal_outlined,
                          title: 'AI Coding Practice',
                          subtitle: 'Fun coding challenges with AI feedback',
                          onTap: () => _navigateToRoute(context, '/coding-practice'),
                          color: const Color(0xFF10B981),
                        ),
                        _buildDrawerItem(
                          context,
                          icon: Icons.analytics_outlined,
                          title: 'Coding Progress',
                          subtitle: 'Track your coding journey',
                          onTap: () => _navigateToRoute(context, '/coding-dashboard'),
                          color: const Color(0xFF8B5CF6),
                        ),
                        _buildDrawerItem(
                          context,
                          icon: Icons.forum_outlined,
                          title: 'Community Doubts',
                          subtitle: 'Ask & answer student questions',
                          onTap: () => _navigateToRoute(context, '/community-doubts'),
                          color: const Color(0xFF3B82F6),
                        ),
                        _buildDrawerItem(
                          context,
                          icon: Icons.note_alt_outlined,
                          title: 'Study Notes',
                          subtitle: 'Download & access subject notes',
                          onTap: () => _navigateToRoute(context, '/notes'),
                          color: const Color(0xFF10B981),
                        ),
                        _buildDrawerItem(
                          context,
                          icon: Icons.auto_awesome_outlined,
                          title: 'AI Summarizer',
                          subtitle: 'Convert notes to simple summaries',
                          onTap: () => _navigateToRoute(context, '/ai-summarizer'),
                          color: const Color(0xFF9C27B0),
                        ),
                        
                        // Divider
                        Container(
                          margin: const EdgeInsets.symmetric(vertical: 16),
                          child: Divider(
                            color: Colors.grey.withOpacity(0.3),
                            thickness: 1,
                          ),
                        ),
                        
                        _buildDrawerItem(
                          context,
                          icon: Icons.help_outline,
                          title: 'Help & Support',
                          subtitle: 'Get assistance & guidance',
                          onTap: () => _navigateToRoute(context, '/help'),
                          color: Colors.teal,
                        ),
                        _buildDrawerItem(
                          context,
                          icon: Icons.settings_outlined,
                          title: 'Settings',
                          subtitle: 'App preferences & more',
                          onTap: () => _navigateToRoute(context, '/settings'),
                          color: Colors.grey,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          
          // Footer Section
          Container(
            padding: EdgeInsets.all(isSmallScreen ? 12 : 16),
            child: Column(
              children: [
                // Logout Button
                Consumer<AuthProvider>(
                  builder: (context, authProvider, child) {
                    return Container(
                      width: double.infinity,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            Colors.red.withOpacity(0.1),
                            Colors.redAccent.withOpacity(0.05)
                          ],
                        ),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: Colors.red.withOpacity(0.3),
                          width: 1,
                        ),
                      ),
                      child: Material(
                        color: Colors.transparent,
                        child: InkWell(
                          borderRadius: BorderRadius.circular(12),
                          onTap: () async {
                            Navigator.pop(context);
                            await authProvider.signOut();
                            if (context.mounted) {
                              context.go('/login');
                            }
                          },
                          child: Padding(
                            padding: const EdgeInsets.all(12),
                            child: Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    color: Colors.red.withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: const Icon(
                                    Icons.logout_rounded,
                                    color: Colors.red,
                                    size: 18,
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Text(
                                    'Logout',
                                    style: theme.textTheme.titleMedium?.copyWith(
                                      color: Colors.red,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                                Icon(
                                  Icons.arrow_forward_ios_rounded,
                                  size: 14,
                                  color: Colors.red.withOpacity(0.7),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),
                
                const SizedBox(height: 12),
                
                // App Version
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        const Color(0xFF667eea).withOpacity(0.1),
                        const Color(0xFF764ba2).withOpacity(0.05),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: const Color(0xFF667eea).withOpacity(0.2),
                      width: 1,
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.school_rounded,
                        size: 14,
                        color: const Color(0xFF667eea),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        'CollegePro v2.0',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: const Color(0xFF667eea),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDrawerItem(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
    required Color color,
  }) {
    final theme = Theme.of(context);
    
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            color.withOpacity(0.1),
            color.withOpacity(0.05),
          ],
        ),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: color.withOpacity(0.2),
          width: 1,
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        color.withOpacity(0.2),
                        color.withOpacity(0.1),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(
                    icon,
                    color: color,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: theme.textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: theme.brightness == Brightness.dark 
                              ? Colors.white 
                              : Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        subtitle,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.brightness == Brightness.dark 
                              ? Colors.white70 
                              : Colors.grey[600],
                          fontSize: 11,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    Icons.arrow_forward_ios_rounded,
                    size: 12,
                    color: color,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _navigateToRoute(BuildContext context, String route) {
    Navigator.pop(context);
    // Use push() to add route to navigation stack, allowing pop() to return to dashboard
    context.push(route);
  }
}
