import 'package:flutter/material.dart';
import '../../core/widgets/drawer_screen_wrapper.dart';
import '../../core/services/tawk_chat_service.dart';
import '../../core/widgets/gradient_app_bar.dart';

class HelpScreen extends StatefulWidget {
  const HelpScreen({super.key});

  @override
  State<HelpScreen> createState() => _HelpScreenState();
}

class _HelpScreenState extends State<HelpScreen> {
  final List<Map<String, dynamic>> _faqItems = [
    {
      'question': 'How do I find relevant projects?',
      'answer': 'Use our smart search and filter features. You can filter by technology, difficulty level, and industry to find projects that match your interests and skills.',
      'category': 'Projects',
    },
    {
      'question': 'How do I apply for internships?',
      'answer': 'Browse our internships section, click on any internship that interests you, and follow the application instructions. Make sure your profile is complete.',
      'category': 'Internships',
    },
    {
      'question': 'Can I save projects for later?',
      'answer': 'Yes! Click the bookmark icon on any project card to save it. You can view all saved projects in the "Saved Projects" section.',
      'category': 'Projects',
    },
    {
      'question': 'How do scholarship applications work?',
      'answer': 'Each scholarship has specific requirements and deadlines. Read the details carefully and prepare all required documents before applying.',
      'category': 'Scholarships',
    },
    {
      'question': 'Is my data secure?',
      'answer': 'Yes, we use industry-standard encryption and security measures to protect your personal information and academic data.',
      'category': 'Privacy',
    },
  ];

  final List<Map<String, dynamic>> _supportOptions = [
    {
      'title': 'Live Chat',
      'subtitle': 'Get instant help from our support team',
      'icon': Icons.chat_bubble_outline,
      'color': Colors.blue,
      'available': true,
    },
    {
      'title': 'Email Support',
      'subtitle': 'Send us detailed questions via email',
      'icon': Icons.email_outlined,
      'color': Colors.green,
      'available': true,
    },
    {
      'title': 'Community Forum',
      'subtitle': 'Connect with other students',
      'icon': Icons.forum_outlined,
      'color': Colors.orange,
      'available': true,
    },
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    const primaryEducationColor = Color(0xFF2E5BBA);
    
    return DrawerScreenWrapper(
      title: 'Help & Support',
      child: Scaffold(
      backgroundColor: isDark ? const Color(0xFF0F0F0F) : const Color(0xFFF3F7FF),
      appBar: GradientAppBar(
        title: 'Help & Support',
        titleIcon: Icons.support_agent_rounded,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Enhanced Modern Header Card
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Colors.white,
                    Colors.white.withOpacity(0.95),
                  ],
                ),
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                    color: primaryEducationColor.withOpacity(0.15),
                    blurRadius: 20,
                    offset: const Offset(0, 8),
                    spreadRadius: 2,
                  ),
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 2),
                  ),
                ],
                border: Border.all(
                  color: primaryEducationColor.withOpacity(0.1),
                  width: 1,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              primaryEducationColor.withOpacity(0.15),
                              primaryEducationColor.withOpacity(0.08),
                            ],
                          ),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: primaryEducationColor.withOpacity(0.2),
                            width: 1,
                          ),
                        ),
                        child: Icon(
                          Icons.support_agent_rounded,
                          size: 32,
                          color: primaryEducationColor,
                        ),
                      ),
                      const SizedBox(width: 20),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '🎓 Student Support Center',
                              style: theme.textTheme.headlineSmall?.copyWith(
                                fontWeight: FontWeight.w800,
                                color: const Color(0xFF1A1A1A),
                                fontSize: 22,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Get instant help from our dedicated academic support team',
                              style: theme.textTheme.bodyMedium?.copyWith(
                                color: Colors.grey[600],
                                height: 1.4,
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  // Quick Stats Row
                  Row(
                    children: [
                      Expanded(
                        child: _buildQuickStat(
                          context,
                          '24/7',
                          'Support',
                          Icons.access_time_rounded,
                          Colors.green,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _buildQuickStat(
                          context,
                          '< 2min',
                          'Response',
                          Icons.flash_on_rounded,
                          Colors.orange,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _buildQuickStat(
                          context,
                          '98%',
                          'Satisfaction',
                          Icons.thumb_up_rounded,
                          Colors.blue,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 24),
            
            // Enhanced Search Bar
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Colors.white,
                    Colors.white.withOpacity(0.95),
                  ],
                ),
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: primaryEducationColor.withOpacity(0.1),
                    blurRadius: 15,
                    offset: const Offset(0, 5),
                    spreadRadius: 1,
                  ),
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
                border: Border.all(
                  color: primaryEducationColor.withOpacity(0.15),
                  width: 1,
                ),
              ),
              child: TextField(
                decoration: InputDecoration(
                  hintText: 'Search for help topics, FAQs, guides...',
                  hintStyle: TextStyle(
                    color: Colors.grey[500],
                    fontSize: 14,
                  ),
                  prefixIcon: Container(
                    padding: const EdgeInsets.all(12),
                    child: Icon(
                      Icons.search_rounded,
                      color: primaryEducationColor,
                      size: 22,
                    ),
                  ),
                  suffixIcon: Container(
                    padding: const EdgeInsets.all(12),
                    child: Icon(
                      Icons.mic_rounded,
                      color: Colors.grey[400],
                      size: 20,
                    ),
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(20),
                    borderSide: BorderSide.none,
                  ),
                  filled: true,
                  fillColor: Colors.transparent,
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 16,
                  ),
                ),
              ),
            ),
            
            const SizedBox(height: 24),
            
            // Enhanced Support Options Section
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: primaryEducationColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    Icons.support_rounded,
                    color: primaryEducationColor,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  '🚀 Get Instant Support',
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w800,
                    color: const Color(0xFF1A1A1A),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            
            LayoutBuilder(
              builder: (context, constraints) {
                // Responsive grid layout
                int crossAxisCount = constraints.maxWidth > 600 ? 3 : 1;
                double childAspectRatio = constraints.maxWidth > 600 ? 1.1 : 2.2;
                
                return GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: crossAxisCount,
                    crossAxisSpacing: 16,
                    mainAxisSpacing: 16,
                    childAspectRatio: childAspectRatio,
                  ),
                  itemCount: _supportOptions.length,
                  itemBuilder: (context, index) {
                    return _buildEnhancedSupportCard(context, _supportOptions[index]);
                  },
                );
              },
            ),
            
            const SizedBox(height: 24),
            
            // FAQ Section
            Text(
              'Frequently Asked Questions',
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: _faqItems.length,
              itemBuilder: (context, index) {
                return _buildFAQItem(context, _faqItems[index]);
              },
            ),
            
            const SizedBox(height: 20),
            
            // Contact Info Card
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Colors.teal.withOpacity(0.1),
                    Colors.teal.withOpacity(0.05),
                  ],
                ),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: Colors.teal.withOpacity(0.3),
                  width: 1,
                ),
              ),
              child: Column(
                children: [
                  Icon(
                    Icons.contact_support,
                    size: 32,
                    color: Colors.teal,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Still need help?',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Our support team is available 24/7 to assist you',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: Colors.grey[600],
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton.icon(
                    onPressed: () => _startLiveChat(context),
                    icon: const Icon(Icons.chat),
                    label: const Text('Start Live Chat'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.teal,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                    ),
                  ),
                ],
              ),
            ),
            // Extra bottom padding for safe area
            const SizedBox(height: 20),
          ],
        ),
      ),
    ),
    );
  }

  Widget _buildEnhancedSupportCard(BuildContext context, Map<String, dynamic> option) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.white,
            Colors.white.withOpacity(0.95),
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: (option['color'] as Color).withOpacity(0.15),
            blurRadius: 20,
            offset: const Offset(0, 8),
            spreadRadius: 1,
          ),
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
        border: Border.all(
          color: (option['color'] as Color).withOpacity(0.2),
          width: 1,
        ),
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(20),
        child: InkWell(
          borderRadius: BorderRadius.circular(20),
          onTap: option['available'] ? () => _handleSupportOptionTap(context, option) : null,
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        (option['color'] as Color).withOpacity(0.15),
                        (option['color'] as Color).withOpacity(0.08),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(
                      color: (option['color'] as Color).withOpacity(0.3),
                      width: 1,
                    ),
                  ),
                  child: Icon(
                    option['icon'],
                    color: option['available'] ? option['color'] : Colors.grey,
                    size: 28,
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  option['title'],
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w800,
                    color: option['available'] ? const Color(0xFF1A1A1A) : Colors.grey,
                    fontSize: 16,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                Text(
                  option['subtitle'],
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Colors.grey[600],
                    fontSize: 12,
                    height: 1.4,
                  ),
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                if (!option['available']) ...[
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          Colors.orange.withOpacity(0.1),
                          Colors.orange.withOpacity(0.05),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: Colors.orange.withOpacity(0.3),
                        width: 1,
                      ),
                    ),
                    child: Text(
                      '🚧 Coming Soon',
                      style: TextStyle(
                        fontSize: 11,
                        color: Colors.orange[700],
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFAQItem(BuildContext context, Map<String, dynamic> faq) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ExpansionTile(
        title: Text(
          faq['question'],
          style: Theme.of(context).textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        leading: Container(
          padding: const EdgeInsets.all(6),
          decoration: BoxDecoration(
            color: Colors.teal.withOpacity(0.1),
            borderRadius: BorderRadius.circular(6),
          ),
          child: Icon(
            Icons.help_outline,
            color: Colors.teal,
            size: 16,
          ),
        ),
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            child: Text(
              faq['answer'],
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Colors.grey[700],
                height: 1.5,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _handleSupportOptionTap(BuildContext context, Map<String, dynamic> option) {
    switch (option['title']) {
      case 'Live Chat':
        _startLiveChat(context);
        break;
      case 'Email Support':
        _openEmailSupport();
        break;
      case 'Video Call':
        _showComingSoonDialog(context, 'Video Call');
        break;
      case 'Community Forum':
        _openCommunityForum();
        break;
      default:
        break;
    }
  }

  void _startLiveChat(BuildContext context) {
    // Use the improved Android-compatible chat service directly
    TawkChatService.launchTawkChatForAndroid(context);
  }

  void _openEmailSupport() async {
    try {
      await TawkChatService.launchTawkChat(); // Fallback to chat if email fails
    } catch (e) {
      debugPrint('Email support not available: $e');
    }
  }

  void _openCommunityForum() {
    // Placeholder for community forum
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Row(
          children: [
            Icon(Icons.info, color: Colors.white),
            SizedBox(width: 8),
            Text('Community forum coming soon!'),
          ],
        ),
        backgroundColor: Colors.blue[600],
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );
  }

  void _showComingSoonDialog(BuildContext context, String feature) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: Row(
          children: [
            Icon(
              Icons.construction,
              color: Colors.orange[600],
            ),
            const SizedBox(width: 8),
            const Text('Coming Soon'),
          ],
        ),
        content: Text('$feature feature is currently under development and will be available soon!'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickStat(BuildContext context, String value, String label, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            color.withOpacity(0.1),
            color.withOpacity(0.05),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: color.withOpacity(0.2),
          width: 1,
        ),
      ),
      child: Column(
        children: [
          Icon(
            icon,
            color: color,
            size: 20,
          ),
          const SizedBox(height: 6),
          Text(
            value,
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.w800,
              color: color,
              fontSize: 14,
            ),
          ),
          Text(
            label,
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
              color: Colors.grey[600],
              fontSize: 10,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
