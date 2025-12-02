import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import '../project_ideas/project_ideas_screen.dart';
import '../project_ideas/submit_project_idea_screen.dart';
import '../quiz/screens/quiz_subjects_screen.dart';
import '../../core/providers/project_provider.dart';
import '../../core/providers/auth_provider.dart';
import '../../core/providers/user_progress_provider.dart';
import '../../core/widgets/modern_side_drawer.dart';
import '../../core/widgets/connectivity_wrapper.dart';
import '../dashboard/widgets/filter_chips.dart';
import '../dashboard/widgets/dashboard_app_bar.dart';
import '../dashboard/widgets/search_bar_widget.dart';
import '../dashboard/widgets/project_card.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  final ScrollController _scrollController = ScrollController();
  bool _showFilters = false;

  @override
  void initState() {
    super.initState();
    // Add delay to ensure proper initialization
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        try {
          final projectProvider = Provider.of<ProjectProvider>(context, listen: false);
          projectProvider.loadProjects(context: context);
          
          // Track dashboard visit activity
          final authProvider = Provider.of<AuthProvider>(context, listen: false);
          final progressProvider = Provider.of<UserProgressProvider>(context, listen: false);
          
          if (authProvider.user != null) {
            progressProvider.trackActivity(authProvider.user!.uid, 'dashboard_visited').then((_) {
              debugPrint('✅ Tracked dashboard visit activity for user: ${authProvider.user!.uid}');
            }).catchError((e) {
              debugPrint('❌ Failed to track dashboard visit activity: $e');
            });
          }
        } catch (e) {
          debugPrint('Error loading projects in initState: $e');
        }
      }
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isSmallScreen = MediaQuery.of(context).size.width < 600;
    
    // Enhanced Educational app color scheme
    const primaryEducationColor = Color(0xFF2E5BBA);
    const lightEducationBg = Color(0xFFF3F7FF);
    
    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF0F0F0F) : lightEducationBg,
      drawer: const ModernSideDrawer(),
      body: ConnectivityWrapper(
        child: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  minHeight: constraints.maxHeight,
                ),
                child: Column(
                  children: [
              // Enhanced App Bar with educational gradient background
              Container(
                decoration: BoxDecoration(
                  color: const Color(0xFF2E5BBA), // Attractive educational blue
                  borderRadius: const BorderRadius.only(
                    bottomLeft: Radius.circular(32),
                    bottomRight: Radius.circular(32),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF2E5BBA).withOpacity(0.3),
                      blurRadius: 25,
                      offset: const Offset(0, 10),
                      spreadRadius: 2,
                    ),
                    BoxShadow(
                      color: const Color(0xFF2E5BBA).withOpacity(0.15),
                      blurRadius: 15,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                child: Stack(
                  children: [
                    // Educational pattern overlay
                    Positioned.fill(
                      child: CustomPaint(
                        painter: EducationalPatternPainter(),
                      ),
                    ),
                    DashboardAppBar(
                      onMenuPressed: () {
                        Scaffold.of(context).openDrawer();
                      },
                    ),
                  ],
                ),
              ),
              
              // Quick Stats Cards with animation and educational styling
              Padding(
                padding: EdgeInsets.fromLTRB(
                  isSmallScreen ? 16 : 20, 
                  isSmallScreen ? 16 : 24, 
                  isSmallScreen ? 16 : 20, 
                  isSmallScreen ? 12 : 16
                ),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 600),
                  curve: Curves.easeOutBack,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '📚 Learning Dashboard',
                        style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.w700,
                          color: primaryEducationColor,
                          fontSize: isSmallScreen ? 20 : 22,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Track your academic journey',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Colors.grey[600],
                          fontWeight: FontWeight.w500,
                          fontSize: isSmallScreen ? 14 : null,
                        ),
                      ),
                      SizedBox(height: isSmallScreen ? 16 : 20),
                      _buildQuickStatsCards(context),
                    ],
                  ),
                ),
              ),
              
              // Enhanced Search Bar with educational styling
              Padding(
                padding: EdgeInsets.symmetric(horizontal: isSmallScreen ? 16 : 20),
                child: Hero(
                  tag: 'search_bar',
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
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
                        color: primaryEducationColor.withOpacity(0.2),
                        width: 1.5,
                      ),
                    ),
                    child: SearchBarWidget(
                      onFilterTap: () {
                        setState(() {
                          _showFilters = !_showFilters;
                        });
                      },
                    ),
                  ),
                ),
              ),
              
              const SizedBox(height: 16),
              
              // Enhanced Filter Chips with educational styling
              if (_showFilters)
                AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  margin: EdgeInsets.symmetric(horizontal: isSmallScreen ? 16 : 20),
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF2E7D32).withOpacity(0.1),
                        blurRadius: 15,
                        offset: const Offset(0, 5),
                        spreadRadius: 1,
                      ),
                    ],
                    border: Border.all(
                      color: const Color(0xFF2E7D32).withOpacity(0.1),
                      width: 1,
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(
                            Icons.filter_list_rounded,
                            color: const Color(0xFF2E7D32),
                            size: 20,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'Filter Projects',
                            style: Theme.of(context).textTheme.titleSmall?.copyWith(
                              fontWeight: FontWeight.w600,
                              color: const Color(0xFF2E7D32),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      const SingleChildScrollView(
                        child: FilterChips(),
                      ),
                    ],
                  ),
                ),
              
              const SizedBox(height: 16),
              
              // Projects Grid
              Consumer<ProjectProvider>(
                builder: (context, projectProvider, child) {
                  if (projectProvider.isLoading) {
                    return Container(
                      height: 200,
                      padding: EdgeInsets.all(isSmallScreen ? 16 : 20),
                      child: Center(
                        child: Container(
                          padding: EdgeInsets.all(isSmallScreen ? 16 : 20),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(20),
                            boxShadow: [
                              BoxShadow(
                                color: primaryEducationColor.withOpacity(0.1),
                                blurRadius: 15,
                                offset: const Offset(0, 5),
                              ),
                            ],
                          ),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              CircularProgressIndicator(
                                color: primaryEducationColor,
                                strokeWidth: 3,
                              ),
                              const SizedBox(height: 16),
                              Text(
                                '📖 Loading your projects...',
                                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                  color: primaryEducationColor,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  }

                    // Remove error display since we now use fallback projects
                    // This ensures students never see error screens

                    final projects = projectProvider.filteredProjects;

                  if (projects.isEmpty) {
                    return Container(
                      padding: EdgeInsets.all(isSmallScreen ? 16 : 20),
                      child: Center(
                        child: Container(
                          margin: EdgeInsets.all(isSmallScreen ? 16 : 20),
                          padding: EdgeInsets.all(isSmallScreen ? 24 : 32),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(24),
                            boxShadow: [
                              BoxShadow(
                                color: const Color(0xFF2E7D32).withOpacity(0.1),
                                blurRadius: 20,
                                offset: const Offset(0, 8),
                              ),
                            ],
                          ),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Container(
                                padding: const EdgeInsets.all(16),
                                decoration: BoxDecoration(
                                  color: lightEducationBg,
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                child: Icon(
                                  Icons.school_outlined,
                                  size: 48,
                                  color: primaryEducationColor,
                                ),
                              ),
                              const SizedBox(height: 20),
                              Text(
                                '📚 No projects found',
                                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                                  color: primaryEducationColor,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'Try adjusting your search or explore different categories',
                                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                  color: Colors.grey[600],
                                ),
                                textAlign: TextAlign.center,
                              ),
                              const SizedBox(height: 24),
                              ElevatedButton.icon(
                                onPressed: () => projectProvider.clearAllFilters(),
                                icon: const Icon(Icons.refresh_rounded),
                                label: const Text('Clear Filters'),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: primaryEducationColor,
                                  foregroundColor: Colors.white,
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 24,
                                    vertical: 12,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  }

                  return Container(
                    padding: EdgeInsets.all(isSmallScreen ? 16 : 20),
                    child: RefreshIndicator(
                      onRefresh: () async {
                        await projectProvider.loadProjects(context: context);
                      },
                      color: const Color(0xFF2E7D32),
                      backgroundColor: Colors.white,
                      strokeWidth: 3,
                      child: LayoutBuilder(
                        builder: (context, constraints) {
                          // Responsive grid based on screen width
                          int crossAxisCount = 1;
                          double mainAxisSpacing = 12;
                          double crossAxisSpacing = 12;
                          
                          if (constraints.maxWidth < 600) {
                            crossAxisCount = 1; // Single column on small screens
                            mainAxisSpacing = 12;
                            crossAxisSpacing = 0;
                          } else if (constraints.maxWidth < 900) {
                            crossAxisCount = 2; // Two columns on medium screens
                            mainAxisSpacing = 16;
                            crossAxisSpacing = 16;
                          } else {
                            crossAxisCount = 3; // Three columns on large screens
                            mainAxisSpacing = 16;
                            crossAxisSpacing = 16;
                          }
                          
                          return MasonryGridView.count(
                            controller: _scrollController,
                            crossAxisCount: crossAxisCount,
                            mainAxisSpacing: mainAxisSpacing,
                            crossAxisSpacing: crossAxisSpacing,
                            itemCount: projects.length,
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemBuilder: (context, index) {
                              final project = projects[index];
                              return TweenAnimationBuilder<double>(
                                duration: Duration(milliseconds: 300 + (index * 100)),
                                tween: Tween(begin: 0.0, end: 1.0),
                                curve: Curves.easeOutBack,
                                builder: (context, value, child) {
                                  // Clamp opacity value to prevent assertion errors
                                  final clampedOpacity = value.clamp(0.0, 1.0);
                                  final clampedTranslation = (30 * (1 - value)).clamp(-100.0, 100.0);
                                  
                                  return Transform.translate(
                                    offset: Offset(0, clampedTranslation),
                                    child: Opacity(
                                      opacity: clampedOpacity,
                                      child: ProjectCard(
                                        project: project,
                                        onTap: () => context.push('/project/${project.id}'),
                                      ),
                                    ),
                                  );
                                },
                              );
                            },
                          );
                        },
                      ),
                    ),
                  );
                },
              ),
                  ],
                ),
              ),
            );
          }),
        ),
      ),
    );
  }

  Widget _buildQuickStatsCards(BuildContext context) {
    return Consumer<ProjectProvider>(
      builder: (context, projectProvider, child) {
        return LayoutBuilder(
          builder: (context, constraints) {
            // Responsive layout for stats cards
            if (constraints.maxWidth < 600) {
              // Vertical layout for small screens with project ideas button
              return Column(
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: TweenAnimationBuilder<double>(
                          duration: const Duration(milliseconds: 800),
                          tween: Tween(begin: 0.0, end: 1.0),
                          curve: Curves.elasticOut,
                          builder: (context, value, child) {
                            final clampedScale = value.clamp(0.0, 2.0);
                            return Transform.scale(
                              scale: clampedScale,
                              child: _buildStatCard(
                                context,
                                'Total Projects',
                                '${projectProvider.projects.length}',
                                Icons.folder_outlined,
                                Colors.blue,
                              ),
                            );
                          },
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: TweenAnimationBuilder<double>(
                          duration: const Duration(milliseconds: 1000),
                          tween: Tween(begin: 0.0, end: 1.0),
                          curve: Curves.elasticOut,
                          builder: (context, value, child) {
                            final clampedScale = value.clamp(0.0, 2.0);
                            return Transform.scale(
                              scale: clampedScale,
                              child: GestureDetector(
                                onTap: () => _showTrendingProjects(context, projectProvider),
                                child: _buildStatCard(
                                  context,
                                  'Trending',
                                  '8',
                                  Icons.trending_up,
                                  Colors.orange,
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  _buildProjectIdeasButtons(),
                ],
              );
            } else {
              // Row layout for larger screens
              return Column(
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: TweenAnimationBuilder<double>(
                          duration: const Duration(milliseconds: 800),
                          tween: Tween(begin: 0.0, end: 1.0),
                          curve: Curves.elasticOut,
                          builder: (context, value, child) {
                            final clampedScale = value.clamp(0.0, 2.0);
                            return Transform.scale(
                              scale: clampedScale,
                              child: _buildStatCard(
                                context,
                                'Total Projects',
                                '${projectProvider.projects.length}',
                                Icons.folder_outlined,
                                Colors.blue,
                              ),
                            );
                          },
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: TweenAnimationBuilder<double>(
                          duration: const Duration(milliseconds: 1000),
                          tween: Tween(begin: 0.0, end: 1.0),
                          curve: Curves.elasticOut,
                          builder: (context, value, child) {
                            final clampedScale = value.clamp(0.0, 2.0);
                            return Transform.scale(
                              scale: clampedScale,
                              child: GestureDetector(
                                onTap: () => _showTrendingProjects(context, projectProvider),
                                child: _buildStatCard(
                                  context,
                                  'Trending',
                                  '8',
                                  Icons.trending_up,
                                  Colors.orange,
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  _buildProjectIdeasButtons(),
                ],
              );
            }
          },
        );
      },
    );
  }

  void _showTrendingProjects(BuildContext context, ProjectProvider projectProvider) {
    // Get trending projects (most recent or popular ones)
    final trendingProjects = projectProvider.projects.take(8).toList();
    
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.85,
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
        ),
        child: Column(
          children: [
            // Handle bar
            Container(
              margin: const EdgeInsets.only(top: 12),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            
            // Enhanced Header
            Container(
              padding: const EdgeInsets.all(24),
              child: Column(
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              Colors.orange.withOpacity(0.2),
                              Colors.deepOrange.withOpacity(0.1),
                            ],
                          ),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: Colors.orange.withOpacity(0.3),
                            width: 1,
                          ),
                        ),
                        child: const Icon(
                          Icons.trending_up,
                          color: Colors.orange,
                          size: 28,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Trending Projects',
                              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: const Color(0xFF2D3748),
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Most popular projects right now',
                              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                color: Colors.grey[600],
                              ),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: Colors.orange.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: Colors.orange.withOpacity(0.3),
                          ),
                        ),
                        child: Text(
                          '${trendingProjects.length} Projects',
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: Colors.orange,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  
                  // Stats Row
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          const Color(0xFF2E5BBA).withOpacity(0.05),
                          Colors.orange.withOpacity(0.05),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: Colors.grey.withOpacity(0.1),
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        _buildTrendingStat('🔥', 'Hot', '${trendingProjects.length}'),
                        _buildTrendingStat('⭐', 'Featured', '3'),
                        _buildTrendingStat('📈', 'Rising', '5'),
                        _buildTrendingStat('👥', 'Popular', '12K'),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            
            // Projects List
            Expanded(
              child: trendingProjects.isEmpty
                  ? _buildTrendingEmptyState()
                  : ListView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      itemCount: trendingProjects.length,
                      itemBuilder: (context, index) {
                        final project = trendingProjects[index];
                        return Container(
                          margin: const EdgeInsets.only(bottom: 16),
                          child: _buildEnhancedProjectCard(context, project, index),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTrendingStat(String emoji, String label, String value) {
    return Column(
      children: [
        Text(
          emoji,
          style: const TextStyle(fontSize: 20),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Color(0xFF2D3748),
          ),
        ),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey[600],
          ),
        ),
      ],
    );
  }

  Widget _buildTrendingEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.orange.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.trending_up,
              size: 64,
              color: Colors.orange.withOpacity(0.7),
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'No Trending Projects Yet',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
              color: const Color(0xFF2D3748),
            ),
          ),
          const SizedBox(height: 12),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 40),
            child: Text(
              'Projects will appear here as they gain popularity. Check back soon to discover what\'s trending!',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Colors.grey[600],
                height: 1.5,
              ),
            ),
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: () {
              Navigator.pop(context);
            },
            icon: const Icon(Icons.explore),
            label: const Text('Explore All Projects'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.orange,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEnhancedProjectCard(BuildContext context, dynamic project, int index) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
        border: Border.all(
          color: Colors.grey.withOpacity(0.1),
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () {
            Navigator.pop(context);
            context.push('/project/${project.id}');
          },
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: _getTrendingColor(index).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            _getTrendingIcon(index),
                            size: 14,
                            color: _getTrendingColor(index),
                          ),
                          const SizedBox(width: 4),
                          Text(
                            '#${index + 1}',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: _getTrendingColor(index),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const Spacer(),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.green.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.trending_up,
                            size: 12,
                            color: Colors.green[600],
                          ),
                          const SizedBox(width: 4),
                          Text(
                            '+${(index * 12 + 45)}%',
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              color: Colors.green[600],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  project.title ?? 'Untitled Project',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF2D3748),
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 8),
                Text(
                  project.description ?? 'No description available',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[600],
                    height: 1.4,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Icon(
                      Icons.visibility,
                      size: 16,
                      color: Colors.grey[500],
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '${(index * 234 + 1200)} views',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[600],
                      ),
                    ),
                    const SizedBox(width: 16),
                    Icon(
                      Icons.favorite,
                      size: 16,
                      color: Colors.grey[500],
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '${(index * 45 + 120)} likes',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[600],
                      ),
                    ),
                    const Spacer(),
                    Icon(
                      Icons.arrow_forward_ios,
                      size: 14,
                      color: Colors.grey[400],
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Color _getTrendingColor(int index) {
    switch (index) {
      case 0:
        return Colors.amber;
      case 1:
        return Colors.orange;
      case 2:
        return Colors.deepOrange;
      default:
        return Colors.blue;
    }
  }

  IconData _getTrendingIcon(int index) {
    switch (index) {
      case 0:
        return Icons.emoji_events;
      case 1:
        return Icons.star;
      case 2:
        return Icons.local_fire_department;
      default:
        return Icons.trending_up;
    }
  }

  Widget _buildStatCard(
    BuildContext context,
    String title,
    String value,
    IconData icon,
    Color color,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Icon(
                icon,
                color: color,
                size: 24,
              ),
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  Icons.arrow_upward,
                  color: color,
                  size: 16,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            value,
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            title,
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey[600],
              fontWeight: FontWeight.w600,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildProjectIdeasButtons() {
    return MediaQuery.of(context).size.width < 350
        ? Column(
            children: [
              _buildProjectIdeaButton(
                'Submit Idea',
                Icons.lightbulb_outline,
                const LinearGradient(
                  colors: [Color(0xFF6366F1), Color(0xFF8B5CF6)],
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                ),
                const Color(0xFF6366F1),
                () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const SubmitProjectIdeaScreen(),
                  ),
                ),
                1200,
              ),
              const SizedBox(height: 12),
              _buildProjectIdeaButton(
                'Browse Ideas',
                Icons.explore_outlined,
                const LinearGradient(
                  colors: [Color(0xFF10B981), Color(0xFF059669)],
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                ),
                const Color(0xFF10B981),
                () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const ProjectIdeasScreen(),
                  ),
                ),
                1400,
              ),
              const SizedBox(height: 12),
              _buildProjectIdeaButton(
                'Learn',
                Icons.play_circle_outline,
                const LinearGradient(
                  colors: [Color(0xFFEF4444), Color(0xFFDC2626)],
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                ),
                const Color(0xFFEF4444),
                () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const QuizSubjectsScreen(),
                  ),
                ),
                1600,
              ),
            ],
          )
        : Column(
            children: [
              Row(
                children: [
                  Expanded(
                    child: _buildProjectIdeaButton(
                      'Submit Idea',
                      Icons.lightbulb_outline,
                      const LinearGradient(
                        colors: [Color(0xFF6366F1), Color(0xFF8B5CF6)],
                        begin: Alignment.centerLeft,
                        end: Alignment.centerRight,
                      ),
                      const Color(0xFF6366F1),
                      () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const SubmitProjectIdeaScreen(),
                        ),
                      ),
                      1200,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildProjectIdeaButton(
                      'Browse Ideas',
                      Icons.explore_outlined,
                      const LinearGradient(
                        colors: [Color(0xFF10B981), Color(0xFF059669)],
                        begin: Alignment.centerLeft,
                        end: Alignment.centerRight,
                      ),
                      const Color(0xFF10B981),
                      () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const ProjectIdeasScreen(),
                        ),
                      ),
                      1400,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              _buildProjectIdeaButton(
                'Learn',
                Icons.play_circle_outline,
                const LinearGradient(
                  colors: [Color(0xFFEF4444), Color(0xFFDC2626)],
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                ),
                const Color(0xFFEF4444),
                () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const QuizSubjectsScreen(),
                  ),
                ),
                1600,
              ),
            ],
          );
  }


  Widget _buildProjectIdeaButton(
    String text,
    IconData icon,
    LinearGradient gradient,
    Color shadowColor,
    VoidCallback onTap,
    int animationDuration,
  ) {
    return Container(
      height: 56,
      decoration: BoxDecoration(
        gradient: gradient,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: shadowColor.withOpacity(0.3),
            spreadRadius: 1,
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  icon,
                  color: Colors.white,
                  size: 24,
                ),
                const SizedBox(width: 8),
                Flexible(
                  child: Text(
                    text,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// Educational Pattern Painter for the app bar
class EducationalPatternPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withOpacity(0.1)
      ..style = PaintingStyle.fill;

    final strokePaint = Paint()
      ..color = Colors.white.withOpacity(0.15)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;

    // Draw educational icons pattern
    final iconSize = 16.0;
    final spacing = 40.0;
    
    for (double x = 0; x < size.width; x += spacing) {
      for (double y = 0; y < size.height; y += spacing) {
        // Draw book icon pattern
        final bookRect = Rect.fromCenter(
          center: Offset(x + 20, y + 10),
          width: iconSize,
          height: iconSize * 0.8,
        );
        canvas.drawRRect(
          RRect.fromRectAndRadius(bookRect, const Radius.circular(2)),
          paint,
        );
        
        // Draw graduation cap pattern
        final capPath = Path()
          ..moveTo(x + 60, y + 20)
          ..lineTo(x + 75, y + 15)
          ..lineTo(x + 90, y + 20)
          ..lineTo(x + 85, y + 25)
          ..lineTo(x + 65, y + 25)
          ..close();
        canvas.drawPath(capPath, paint);
        
        // Draw atom/science pattern
        canvas.drawCircle(Offset(x + 100, y + 35), 6, strokePaint);
        canvas.drawCircle(Offset(x + 100, y + 35), 3, paint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
