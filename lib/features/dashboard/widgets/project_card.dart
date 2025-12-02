import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/models/project_model.dart';
import '../../../core/providers/auth_provider.dart';
import '../../../core/providers/user_progress_provider.dart';

class ProjectCard extends StatefulWidget {
  final ProjectModel project;
  final VoidCallback onTap;

  const ProjectCard({
    super.key,
    required this.project,
    required this.onTap,
  });

  @override
  State<ProjectCard> createState() => _ProjectCardState();
}

class _ProjectCardState extends State<ProjectCard> with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  bool _isHovered = false;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 1.02,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final screenWidth = MediaQuery.of(context).size.width;
    final isSmallScreen = screenWidth < 600;
    const primaryEducationColor = Color(0xFF2E5BBA);
    
    return MouseRegion(
      onEnter: (_) {
        setState(() => _isHovered = true);
        _animationController.forward();
      },
      onExit: (_) {
        setState(() => _isHovered = false);
        _animationController.reverse();
      },
      child: AnimatedBuilder(
        animation: _scaleAnimation,
        builder: (context, child) {
          return Transform.scale(
            scale: _scaleAnimation.value,
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(24),
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Colors.white,
                    Colors.white.withValues(alpha: 0.95),
                  ],
                ),
                boxShadow: [
                  BoxShadow(
                    color: _isHovered 
                        ? primaryEducationColor.withValues(alpha: 0.25)
                        : Colors.black.withValues(alpha: 0.08),
                    blurRadius: _isHovered ? 25 : 15,
                    offset: Offset(0, _isHovered ? 12 : 6),
                    spreadRadius: _isHovered ? 2 : 0,
                  ),
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.04),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
                border: Border.all(
                  color: _isHovered 
                      ? primaryEducationColor.withValues(alpha: 0.3)
                      : Colors.grey.withValues(alpha: 0.1),
                  width: _isHovered ? 2 : 1,
                ),
              ),
              child: Material(
                color: Colors.transparent,
                borderRadius: BorderRadius.circular(24),
                child: InkWell(
                  onTap: () async {
                    // Track project tap activity
                    final authProvider = Provider.of<AuthProvider>(context, listen: false);
                    final progressProvider = Provider.of<UserProgressProvider>(context, listen: false);
                    
                    if (authProvider.user != null) {
                      try {
                        await progressProvider.trackActivity(authProvider.user!.uid, 'project_tapped');
                        debugPrint('✅ Tracked project tap activity for user: ${authProvider.user!.uid}');
                      } catch (e) {
                        debugPrint('❌ Failed to track project tap activity: $e');
                      }
                    }
                    
                    // Call the original onTap callback
                    widget.onTap();
                  },
                  borderRadius: BorderRadius.circular(24),
                  child: Padding(
                    padding: EdgeInsets.all(isSmallScreen ? 16 : 20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Enhanced Header with domain and difficulty
                        Row(
                          children: [
                            Expanded(
                              flex: 2,
                              child: Container(
                                padding: EdgeInsets.symmetric(
                                  horizontal: isSmallScreen ? 10 : 12, 
                                  vertical: isSmallScreen ? 6 : 8
                                ),
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    colors: [
                                      _getDomainColor(widget.project.domain).withValues(alpha: 0.15),
                                      _getDomainColor(widget.project.domain).withValues(alpha: 0.08),
                                    ],
                                  ),
                                  borderRadius: BorderRadius.circular(16),
                                  border: Border.all(
                                    color: _getDomainColor(widget.project.domain).withValues(alpha: 0.3),
                                    width: 1,
                                  ),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(
                                      _getDomainIcon(widget.project.domain),
                                      size: 14,
                                      color: _getDomainColor(widget.project.domain),
                                    ),
                                    const SizedBox(width: 6),
                                    Flexible(
                                      child: Text(
                                        widget.project.domain,
                                        style: theme.textTheme.labelSmall?.copyWith(
                                          color: _getDomainColor(widget.project.domain),
                                          fontWeight: FontWeight.w700,
                                          fontSize: 11,
                                        ),
                                        overflow: TextOverflow.ellipsis,
                                        maxLines: 1,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: [
                                    _getDifficultyColor(widget.project.difficulty).withValues(alpha: 0.15),
                                    _getDifficultyColor(widget.project.difficulty).withValues(alpha: 0.08),
                                  ],
                                ),
                                borderRadius: BorderRadius.circular(14),
                                border: Border.all(
                                  color: _getDifficultyColor(widget.project.difficulty).withValues(alpha: 0.3),
                                  width: 1,
                                ),
                              ),
                              child: Text(
                                widget.project.difficulty,
                                style: theme.textTheme.labelSmall?.copyWith(
                                  color: _getDifficultyColor(widget.project.difficulty),
                                  fontWeight: FontWeight.w700,
                                  fontSize: 10,
                                ),
                                overflow: TextOverflow.ellipsis,
                                maxLines: 1,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        
                        // Enhanced Project Title with icon
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: primaryEducationColor.withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Icon(
                                Icons.lightbulb_outline,
                                size: 18,
                                color: primaryEducationColor,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                widget.project.title,
                                style: theme.textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.w800,
                                  color: const Color(0xFF1A1A1A),
                                  fontSize: 16,
                                  height: 1.3,
                                ),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        
                        // Enhanced Project Description
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.grey[50],
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: Colors.grey.withOpacity(0.1),
                              width: 1,
                            ),
                          ),
                          child: Text(
                            widget.project.description,
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: Colors.grey[700],
                              height: 1.4,
                              fontSize: 13,
                            ),
                            maxLines: 3,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const SizedBox(height: 16),
                        
                        // Enhanced Tech Stack with better styling
                        if (widget.project.techStack.isNotEmpty) ...[
                          Row(
                            children: [
                              Icon(
                                Icons.code_rounded,
                                size: 16,
                                color: Colors.grey[600],
                              ),
                              const SizedBox(width: 6),
                              Text(
                                'Tech Stack',
                                style: theme.textTheme.labelMedium?.copyWith(
                                  fontWeight: FontWeight.w600,
                                  color: Colors.grey[700],
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          LayoutBuilder(
                            builder: (context, constraints) {
                              return Wrap(
                                spacing: 6,
                                runSpacing: 6,
                                children: widget.project.techStack.take(3).map((tech) {
                                  return Container(
                                    constraints: BoxConstraints(
                                      maxWidth: constraints.maxWidth * 0.32,
                                    ),
                                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                                    decoration: BoxDecoration(
                                      gradient: LinearGradient(
                                        colors: [
                                          primaryEducationColor.withValues(alpha: 0.1),
                                          primaryEducationColor.withValues(alpha: 0.05),
                                        ],
                                      ),
                                      borderRadius: BorderRadius.circular(12),
                                      border: Border.all(
                                        color: primaryEducationColor.withValues(alpha: 0.2),
                                        width: 1,
                                      ),
                                    ),
                                    child: Text(
                                      tech,
                                      style: theme.textTheme.labelSmall?.copyWith(
                                        color: primaryEducationColor,
                                        fontWeight: FontWeight.w600,
                                        fontSize: 11,
                                      ),
                                      overflow: TextOverflow.ellipsis,
                                      maxLines: 1,
                                    ),
                                  );
                                }).toList(),
                              );
                            },
                          ),
                          if (widget.project.techStack.length > 3)
                            Padding(
                              padding: const EdgeInsets.only(top: 6),
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                decoration: BoxDecoration(
                                  color: Colors.grey[100],
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Text(
                                  '+${widget.project.techStack.length - 3} more technologies',
                                  style: theme.textTheme.labelSmall?.copyWith(
                                    color: Colors.grey[600],
                                    fontSize: 10,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                            ),
                          const SizedBox(height: 16),
                        ],
                        
                        // Enhanced Footer with better design
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                Colors.grey[50]!,
                                Colors.white,
                              ],
                            ),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: Colors.grey.withOpacity(0.1),
                              width: 1,
                            ),
                          ),
                          child: Row(
                            children: [
                              // Enhanced Industry Relevance
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Industry Rating',
                                      style: theme.textTheme.labelSmall?.copyWith(
                                        color: Colors.grey[600],
                                        fontWeight: FontWeight.w600,
                                        fontSize: 10,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: List.generate(5, (index) {
                                        return Container(
                                          margin: const EdgeInsets.only(right: 2),
                                          child: Icon(
                                            index < widget.project.industryRelevanceScore
                                                ? Icons.star_rounded
                                                : Icons.star_outline_rounded,
                                            size: 16,
                                            color: index < widget.project.industryRelevanceScore
                                                ? Colors.amber[600]
                                                : Colors.grey[300],
                                          ),
                                        );
                                      }),
                                    ),
                                  ],
                                ),
                              ),
                              
                              // Enhanced Save Button
                              Consumer<AuthProvider>(
                                builder: (context, authProvider, child) {
                                  final isSaved = authProvider.userModel?.savedProjectIds
                                          .contains(widget.project.id) ?? false;
                                  
                                  return Container(
                                    decoration: BoxDecoration(
                                      gradient: LinearGradient(
                                        colors: isSaved 
                                            ? [primaryEducationColor, primaryEducationColor.withValues(alpha: 0.8)]
                                            : [Colors.grey[100]!, Colors.grey[50]!],
                                      ),
                                      borderRadius: BorderRadius.circular(12),
                                      border: Border.all(
                                        color: isSaved 
                                            ? primaryEducationColor.withValues(alpha: 0.3)
                                            : Colors.grey.withValues(alpha: 0.2),
                                        width: 1,
                                      ),
                                    ),
                                    child: Material(
                                      color: Colors.transparent,
                                      child: InkWell(
                                        onTap: () async {
                          try {
                            // Track save/unsave activity
                            final progressProvider = Provider.of<UserProgressProvider>(context, listen: false);
                            
                            if (isSaved) {
                              await authProvider.unsaveProject(widget.project.id);
                              
                              // Track unsave activity
                              if (authProvider.user != null) {
                                try {
                                  await progressProvider.trackActivity(authProvider.user!.uid, 'project_unsaved');
                                  debugPrint('✅ Tracked project unsave activity');
                                } catch (e) {
                                  debugPrint('❌ Failed to track project unsave activity: $e');
                                }
                              }
                              
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: const Row(
                                    children: [
                                      Icon(Icons.bookmark_remove, color: Colors.white),
                                      SizedBox(width: 8),
                                      Text('Project removed from saved'),
                                    ],
                                  ),
                                  backgroundColor: Colors.orange[600],
                                  behavior: SnackBarBehavior.floating,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                              );
                            } else {
                              await authProvider.saveProject(widget.project.id);
                              
                              // Track save activity
                              if (authProvider.user != null) {
                                try {
                                  await progressProvider.trackActivity(authProvider.user!.uid, 'project_saved');
                                  debugPrint('✅ Tracked project save activity');
                                } catch (e) {
                                  debugPrint('❌ Failed to track project save activity: $e');
                                }
                              }
                              
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: const Row(
                                    children: [
                                      Icon(Icons.bookmark_added, color: Colors.white),
                                      SizedBox(width: 8),
                                      Text('Project saved successfully'),
                                    ],
                                  ),
                                  backgroundColor: Colors.green[600],
                                  behavior: SnackBarBehavior.floating,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                              );
                            }
                          } catch (e) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Row(
                                  children: [
                                    const Icon(Icons.error, color: Colors.white),
                                    const SizedBox(width: 8),
                                    Expanded(child: Text('Failed to save project: $e')),
                                  ],
                                ),
                                backgroundColor: Colors.red[600],
                                behavior: SnackBarBehavior.floating,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                            );
                          }
                                        },
                                        borderRadius: BorderRadius.circular(12),
                                        child: Padding(
                                          padding: const EdgeInsets.all(10),
                                          child: Icon(
                                            isSaved ? Icons.bookmark_rounded : Icons.bookmark_border_rounded,
                                            size: 20,
                                            color: isSaved 
                                                ? Colors.white
                                                : Colors.grey[600],
                                          ),
                                        ),
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
              ),
            ),
          );
        },
      ),
    );
  }

  IconData _getDomainIcon(String domain) {
    switch (domain.toLowerCase()) {
      case 'ai & machine learning':
      case 'ai':
        return Icons.psychology_rounded;
      case 'web development':
      case 'web':
        return Icons.web_rounded;
      case 'mobile development':
      case 'mobile':
        return Icons.phone_android_rounded;
      case 'cybersecurity':
        return Icons.security_rounded;
      case 'cloud computing':
      case 'cloud':
        return Icons.cloud_rounded;
      case 'internet of things':
      case 'iot':
        return Icons.device_hub_rounded;
      case 'blockchain':
        return Icons.link_rounded;
      case 'game development':
      case 'gamedev':
        return Icons.sports_esports_rounded;
      case 'data science':
      case 'datascience':
        return Icons.analytics_rounded;
      case 'devops':
        return Icons.settings_applications_rounded;
      default:
        return Icons.code_rounded;
    }
  }

  Color _getDomainColor(String domain) {
    switch (domain.toLowerCase()) {
      case 'ai & machine learning':
      case 'ai':
        return Colors.purple;
      case 'web development':
      case 'web':
        return Colors.blue;
      case 'mobile development':
      case 'mobile':
        return Colors.green;
      case 'cybersecurity':
        return Colors.red;
      case 'cloud computing':
      case 'cloud':
        return Colors.cyan;
      case 'internet of things':
      case 'iot':
        return Colors.orange;
      case 'blockchain':
        return Colors.indigo;
      case 'game development':
      case 'gamedev':
        return Colors.pink;
      case 'data science':
      case 'datascience':
        return Colors.teal;
      case 'devops':
        return Colors.brown;
      default:
        return Colors.grey;
    }
  }

  Color _getDifficultyColor(String difficulty) {
    switch (difficulty.toLowerCase()) {
      case 'beginner':
        return Colors.green;
      case 'intermediate':
        return Colors.orange;
      case 'advanced':
        return Colors.red;
      case 'expert':
        return Colors.purple;
      default:
        return Colors.grey;
    }
  }
}
