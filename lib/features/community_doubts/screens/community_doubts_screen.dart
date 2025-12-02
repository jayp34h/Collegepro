import 'package:flutter/material.dart';
import '../../../core/widgets/drawer_screen_wrapper.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../providers/community_doubts_provider.dart';
import '../models/doubt_model.dart';
import '../widgets/doubt_card.dart';
import '../widgets/filter_bottom_sheet.dart';
import '../widgets/post_doubt_dialog.dart';
import '../widgets/gamification_panel.dart';
import '../../../core/providers/auth_provider.dart';

class CommunityDoubtsScreen extends StatefulWidget {
  const CommunityDoubtsScreen({super.key});

  @override
  State<CommunityDoubtsScreen> createState() => _CommunityDoubtsScreenState();
}

class _CommunityDoubtsScreenState extends State<CommunityDoubtsScreen>
    with SingleTickerProviderStateMixin {
  final ScrollController _scrollController = ScrollController();
  final TextEditingController _searchController = TextEditingController();
  late TabController _tabController;
  bool _showGamificationPanel = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _scrollController.addListener(_onScroll);
    
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initializeProvider();
    });
  }

  void _initializeProvider() {
    final provider = context.read<CommunityDoubtsProvider>();
    final authProvider = context.read<AuthProvider>();
    
    if (authProvider.user != null) {
      provider.loadDoubts();
      provider.loadUserProgress();
      // Track activity functionality can be added later
    }
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      final provider = context.read<CommunityDoubtsProvider>();
      if (provider.hasMore && !provider.isLoading) {
        provider.loadDoubts();
      }
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _searchController.dispose();
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return DrawerScreenWrapper(
      title: 'Community Doubts',
      child: Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: _buildAppBar(),
      body: Column(
        children: [
          _buildSearchAndFilters(),
          _buildTabBar(),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildDoubtsTab(),
                _buildMyDoubtsTab(),
                _buildLeaderboardTab(),
              ],
            ),
          ),
        ],
      ),
      floatingActionButton: _buildFloatingActionButton(),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
    ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      title: const Text(
        'Community Doubts',
        style: TextStyle(
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      ),
      backgroundColor: const Color(0xFF6366F1),
      elevation: 0,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back, color: Colors.white),
        onPressed: () => DrawerScreenWrapper.openDrawer(context),
      ),
      actions: [
        Consumer<CommunityDoubtsProvider>(
          builder: (context, provider, child) {
            final progress = provider.userProgress;
            return IconButton(
              icon: Stack(
                children: [
                  const Icon(Icons.emoji_events, color: Colors.white),
                  if (progress != null && progress.unlockedBadges.isNotEmpty)
                    Positioned(
                      right: 0,
                      top: 0,
                      child: Container(
                        padding: const EdgeInsets.all(2),
                        decoration: const BoxDecoration(
                          color: Colors.orange,
                          shape: BoxShape.circle,
                        ),
                        child: Text(
                          '${progress.unlockedBadges.length}',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
              onPressed: () {
                setState(() {
                  _showGamificationPanel = !_showGamificationPanel;
                });
              },
            );
          },
        ),
        IconButton(
          icon: const Icon(Icons.refresh, color: Colors.white),
          onPressed: () {
            context.read<CommunityDoubtsProvider>().loadDoubts(refresh: true);
          },
        ),
      ],
    );
  }

  Widget _buildSearchAndFilters() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: const BoxDecoration(
        color: Color(0xFF6366F1),
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(20),
          bottomRight: Radius.circular(20),
        ),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: TextField(
                    controller: _searchController,
                    decoration: const InputDecoration(
                      hintText: 'Search doubts...',
                      prefixIcon: Icon(Icons.search, color: Colors.grey),
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                    ),
                    onSubmitted: (query) {
                      context.read<CommunityDoubtsProvider>().searchDoubts(query);
                    },
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Container(
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: IconButton(
                  icon: const Icon(Icons.filter_list, color: Colors.white),
                  onPressed: _showFilterBottomSheet,
                ),
              ),
            ],
          ),
          if (_showGamificationPanel) ...[
            const SizedBox(height: 16),
            const GamificationPanel(),
          ],
        ],
      ),
    );
  }

  Widget _buildTabBar() {
    return Container(
      color: Colors.white,
      child: TabBar(
        controller: _tabController,
        labelColor: const Color(0xFF6366F1),
        unselectedLabelColor: Colors.grey,
        indicatorColor: const Color(0xFF6366F1),
        tabs: const [
          Tab(text: 'All Doubts'),
          Tab(text: 'My Doubts'),
          Tab(text: 'Leaderboard'),
        ],
      ),
    );
  }

  Widget _buildDoubtsTab() {
    return Consumer<CommunityDoubtsProvider>(
      builder: (context, provider, child) {
        if (provider.isLoading && provider.doubts.isEmpty) {
          return const Center(
            child: CircularProgressIndicator(
              color: Color(0xFF6366F1),
            ),
          );
        }

        if (provider.error != null) {
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
                  provider.error!,
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 16,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () {
                    // Clear error functionality
                    provider.loadDoubts(refresh: true);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF6366F1),
                    foregroundColor: Colors.white,
                  ),
                  child: const Text('Retry'),
                ),
              ],
            ),
          );
        }

        if (provider.doubts.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.help_outline,
                  size: 64,
                  color: Colors.grey[400],
                ),
                const SizedBox(height: 16),
                Text(
                  'No doubts found',
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 18,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Be the first to ask a question!',
                  style: TextStyle(
                    color: Colors.grey[500],
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          );
        }

        return RefreshIndicator(
          onRefresh: () => provider.loadDoubts(refresh: true),
          color: const Color(0xFF6366F1),
          child: ListView.builder(
            controller: _scrollController,
            padding: const EdgeInsets.all(16),
            itemCount: provider.doubts.length + (provider.hasMore ? 1 : 0),
            itemBuilder: (context, index) {
              if (index == provider.doubts.length) {
                return const Center(
                  child: Padding(
                    padding: EdgeInsets.all(16),
                    child: CircularProgressIndicator(
                      color: Color(0xFF6366F1),
                    ),
                  ),
                );
              }

              return DoubtCard(
                doubt: provider.doubts[index],
                onTap: () => _navigateToDoubtDetails(provider.doubts[index]),
              );
            },
          ),
        );
      },
    );
  }

  Widget _buildMyDoubtsTab() {
    return Consumer2<CommunityDoubtsProvider, AuthProvider>(
      builder: (context, provider, authProvider, child) {
        if (authProvider.user == null) {
          return const Center(
            child: Text('Please log in to view your doubts'),
          );
        }

        final myDoubts = provider.doubts
            .where((doubt) => doubt.userId == authProvider.user!.uid)
            .toList();

        if (myDoubts.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.quiz,
                  size: 64,
                  color: Colors.grey[400],
                ),
                const SizedBox(height: 16),
                Text(
                  'No doubts posted yet',
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 18,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Ask your first question to get started!',
                  style: TextStyle(
                    color: Colors.grey[500],
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: myDoubts.length,
          itemBuilder: (context, index) {
            return DoubtCard(
              doubt: myDoubts[index],
              onTap: () => _navigateToDoubtDetails(myDoubts[index]),
              showOwnerActions: true,
            );
          },
        );
      },
    );
  }

  Widget _buildLeaderboardTab() {
    return Consumer<CommunityDoubtsProvider>(
      builder: (context, provider, child) {
        // Show loading indicator when loading
        if (provider.isLoading && provider.leaderboard.isEmpty) {
          return const Center(
            child: CircularProgressIndicator(
              color: Color(0xFF6366F1),
            ),
          );
        }

        // Show error state if there's an error
        if (provider.error != null && provider.leaderboard.isEmpty) {
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
                  'Failed to load leaderboard',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: Colors.grey[600],
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  provider.error!,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[500],
                  ),
                ),
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: () => provider.loadLeaderboard(),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF6366F1),
                    foregroundColor: Colors.white,
                  ),
                  child: const Text('Retry'),
                ),
              ],
            ),
          );
        }

        // Load leaderboard if empty and not loading
        if (provider.leaderboard.isEmpty && !provider.isLoading) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            provider.loadLeaderboard();
          });
          return const Center(
            child: CircularProgressIndicator(
              color: Color(0xFF6366F1),
            ),
          );
        }

        // Show empty state if no users found
        if (provider.leaderboard.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.emoji_events_outlined,
                  size: 64,
                  color: Colors.grey[400],
                ),
                const SizedBox(height: 16),
                Text(
                  'No leaderboard data yet',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: Colors.grey[600],
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Start answering questions to appear on the leaderboard!',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[500],
                  ),
                ),
              ],
            ),
          );
        }

        return RefreshIndicator(
          onRefresh: () => provider.loadLeaderboard(),
          color: const Color(0xFF6366F1),
          child: ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: provider.leaderboard.length,
            itemBuilder: (context, index) {
              final user = provider.leaderboard[index];
              final rank = index + 1;
              
              return Container(
                margin: const EdgeInsets.only(bottom: 12),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                  border: rank <= 3 ? Border.all(
                    color: _getRankColor(rank).withOpacity(0.3),
                    width: 2,
                  ) : null,
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      // Rank Badge
                      Container(
                        width: 50,
                        height: 50,
                        decoration: BoxDecoration(
                          color: _getRankColor(rank),
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: _getRankColor(rank).withOpacity(0.3),
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Stack(
                          alignment: Alignment.center,
                          children: [
                            if (rank <= 3) Icon(
                              rank == 1 ? Icons.emoji_events : 
                              rank == 2 ? Icons.military_tech : Icons.workspace_premium,
                              color: Colors.white,
                              size: 24,
                            ) else Text(
                              '$rank',
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 16),
                      
                      // User Info
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Flexible(
                                  child: Text(
                                    user.userName.isNotEmpty ? user.userName : 'Anonymous User',
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                      color: Colors.black87,
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                                if (rank <= 3) ...[
                                  const SizedBox(width: 8),
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                    decoration: BoxDecoration(
                                      color: _getRankColor(rank).withOpacity(0.1),
                                      borderRadius: BorderRadius.circular(12),
                                      border: Border.all(
                                        color: _getRankColor(rank).withOpacity(0.3),
                                      ),
                                    ),
                                    child: Text(
                                      rank == 1 ? 'TOP HELPER' : 
                                      rank == 2 ? 'EXPERT' : 'RISING STAR',
                                      style: TextStyle(
                                        color: _getRankColor(rank),
                                        fontSize: 10,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ],
                              ],
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Level ${user.level} • ${user.totalPoints} points',
                              style: TextStyle(
                                color: Colors.grey[600],
                                fontSize: 13,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Row(
                              children: [
                                _buildStatChip(
                                  Icons.question_answer,
                                  '${user.answersGiven}',
                                  'Answers',
                                  const Color(0xFF6366F1),
                                ),
                                const SizedBox(width: 8),
                                _buildStatChip(
                                  Icons.verified,
                                  '${user.bestAnswers}',
                                  'Best',
                                  Colors.green,
                                ),
                                const SizedBox(width: 8),
                                _buildStatChip(
                                  Icons.emoji_events,
                                  '${user.unlockedBadges.length}',
                                  'Badges',
                                  Colors.orange,
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      
                      // Points Display
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                            decoration: BoxDecoration(
                              color: const Color(0xFF6366F1).withOpacity(0.1),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              '${user.answersGiven} answers',
                              style: const TextStyle(
                                color: Color(0xFF6366F1),
                                fontWeight: FontWeight.bold,
                                fontSize: 12,
                              ),
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '${user.totalPoints} pts',
                            style: TextStyle(
                              color: Colors.grey[600],
                              fontSize: 11,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        );
      },
    );
  }
  
  Widget _buildStatChip(IconData icon, String value, String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: color.withOpacity(0.3),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 12,
            color: color,
          ),
          const SizedBox(width: 4),
          Text(
            value,
            style: TextStyle(
              color: color,
              fontSize: 11,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Color _getRankColor(int rank) {
    switch (rank) {
      case 1:
        return Colors.amber;
      case 2:
        return Colors.grey[400]!;
      case 3:
        return Colors.brown[300]!;
      default:
        return const Color(0xFF6366F1);
    }
  }

  Widget _buildFloatingActionButton() {
    return Consumer<AuthProvider>(
      builder: (context, authProvider, child) {
        if (authProvider.user == null) {
          return const SizedBox.shrink();
        }

        return FloatingActionButton.extended(
          onPressed: _showPostDoubtDialog,
          backgroundColor: const Color(0xFF6366F1),
          foregroundColor: Colors.white,
          icon: const Icon(Icons.add),
          label: const Text('Ask Question'),
        );
      },
    );
  }

  void _showFilterBottomSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const FilterBottomSheet(),
    );
  }

  void _showPostDoubtDialog() {
    showDialog(
      context: context,
      builder: (context) => const PostDoubtDialog(),
    );
  }

  void _navigateToDoubtDetails(CommunityDoubt doubt) {
    context.push('/doubt-details/${doubt.id}');
  }
}
