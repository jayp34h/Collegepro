import 'package:flutter/material.dart' hide Badge;
import 'package:provider/provider.dart';
import '../providers/community_doubts_provider.dart';
import '../widgets/badge_widget.dart';
import '../models/badge_model.dart';

class BadgeCollectionScreen extends StatefulWidget {
  const BadgeCollectionScreen({super.key});

  @override
  State<BadgeCollectionScreen> createState() => _BadgeCollectionScreenState();
}

class _BadgeCollectionScreenState extends State<BadgeCollectionScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  
  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    
    // Load badges when screen initializes
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<CommunityDoubtsProvider>().loadUserBadges();
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        title: const Text(
          'Badge Collection',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
        elevation: 0,
        bottom: TabBar(
          controller: _tabController,
          labelColor: const Color(0xFF667eea),
          unselectedLabelColor: Colors.grey,
          indicatorColor: const Color(0xFF667eea),
          tabs: const [
            Tab(text: 'Unlocked'),
            Tab(text: 'Available'),
            Tab(text: 'Progress'),
          ],
        ),
      ),
      body: Consumer<CommunityDoubtsProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          return TabBarView(
            controller: _tabController,
            children: [
              _buildUnlockedBadges(provider),
              _buildAvailableBadges(provider),
              _buildProgressView(provider),
            ],
          );
        },
      ),
    );
  }

  Widget _buildUnlockedBadges(CommunityDoubtsProvider provider) {
    final unlockedBadges = provider.userBadges.where((badge) => badge.isUnlocked).toList();
    
    if (unlockedBadges.isEmpty) {
      return _buildEmptyState(
        icon: Icons.emoji_events_outlined,
        title: 'No Badges Yet',
        subtitle: 'Start participating in the community to unlock your first badge!',
      );
    }

    return GridView.builder(
      padding: const EdgeInsets.all(16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 1.2,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
      ),
      itemCount: unlockedBadges.length,
      itemBuilder: (context, index) {
        final badge = unlockedBadges[index];
        return _buildBadgeCard(badge, isUnlocked: true);
      },
    );
  }

  Widget _buildAvailableBadges(CommunityDoubtsProvider provider) {
    final availableBadges = _getAvailableBadges();
    
    return GridView.builder(
      padding: const EdgeInsets.all(16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 1.2,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
      ),
      itemCount: availableBadges.length,
      itemBuilder: (context, index) {
        final badge = availableBadges[index];
        return _buildBadgeCard(badge, isUnlocked: false);
      },
    );
  }

  Widget _buildProgressView(CommunityDoubtsProvider provider) {
    final progress = provider.userProgress;
    
    if (progress == null) {
      return _buildEmptyState(
        icon: Icons.analytics_outlined,
        title: 'No Progress Data',
        subtitle: 'Start participating to track your progress!',
      );
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildProgressCard(
            'Overall Progress',
            [
              _buildProgressItem('Total Points', progress.totalPoints.toString(), Icons.star),
              _buildProgressItem('Questions Asked', progress.questionsAsked.toString(), Icons.help_outline),
              _buildProgressItem('Answers Given', progress.answersGiven.toString(), Icons.lightbulb_outline),
              _buildProgressItem('Best Answers', progress.bestAnswers.toString(), Icons.emoji_events),
            ],
          ),
          
          const SizedBox(height: 16),
          
          _buildProgressCard(
            'Engagement Stats',
            [
              _buildProgressItem('Upvotes Received', progress.upvotesReceived.toString(), Icons.thumb_up),
              _buildProgressItem('Helpful Marks', progress.helpfulMarks.toString(), Icons.favorite),
              _buildProgressItem('Current Streak', '${progress.currentStreak} days', Icons.local_fire_department),
              _buildProgressItem('Longest Streak', '${progress.longestStreak} days', Icons.trending_up),
            ],
          ),
          
          const SizedBox(height: 16),
          
          _buildLevelProgress(progress),
        ],
      ),
    );
  }

  Widget _buildBadgeCard(Badge badge, {required bool isUnlocked}) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          BadgeWidget(
            badge: badge,
            size: 80,
            showDetails: false,
          ),
          const SizedBox(height: 12),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: Text(
              badge.name,
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: isUnlocked ? _getBadgeColor(badge.level) : Colors.grey,
              ),
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          const SizedBox(height: 4),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
            decoration: BoxDecoration(
              color: (isUnlocked ? _getBadgeColor(badge.level) : Colors.grey).withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              badge.level.toString().split('.').last.toUpperCase(),
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                fontSize: 10,
                fontWeight: FontWeight.bold,
                color: isUnlocked ? _getBadgeColor(badge.level) : Colors.grey,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProgressCard(String title, List<Widget> items) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          ...items,
        ],
      ),
    );
  }

  Widget _buildProgressItem(String label, String value, IconData icon) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: const Color(0xFF667eea).withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              icon,
              size: 16,
              color: const Color(0xFF667eea),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              label,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ),
          Text(
            value,
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.bold,
              color: const Color(0xFF667eea),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLevelProgress(UserProgress progress) {
    final currentLevel = progress.calculateLevel();
    final pointsForNext = progress.getPointsForNextLevel();
    final progressPercent = pointsForNext > 0 
        ? (progress.experiencePoints % 100) / 100.0
        : 1.0;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF667eea), Color(0xFF764ba2)],
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Level $currentLevel',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  '${progress.experiencePoints} XP',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 16),
          
          if (pointsForNext > 0) ...[
            Text(
              '$pointsForNext XP to next level',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Colors.white.withOpacity(0.9),
              ),
            ),
            const SizedBox(height: 8),
            ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: LinearProgressIndicator(
                value: progressPercent,
                minHeight: 8,
                backgroundColor: Colors.white.withOpacity(0.3),
                valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
              ),
            ),
          ] else ...[
            Text(
              'Maximum level reached!',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Colors.white.withOpacity(0.9),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildEmptyState({
    required IconData icon,
    required String title,
    required String subtitle,
  }) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 80,
              color: Colors.grey.shade400,
            ),
            const SizedBox(height: 16),
            Text(
              title,
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: Colors.grey.shade600,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              subtitle,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Colors.grey.shade500,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  List<Badge> _getAvailableBadges() {
    // Return predefined badges that can be unlocked
    return [
      Badge(
        id: 'first_question',
        name: 'First Question',
        description: 'Asked your first question',
        type: BadgeType.questioner,
        level: BadgeLevel.bronze,
        iconPath: '',
        requiredPoints: 10,
        criteria: 'Ask your first question in the community',
        isUnlocked: false,
      ),
      Badge(
        id: 'helpful_answerer',
        name: 'Helpful Answerer',
        description: 'Provided 10 helpful answers',
        type: BadgeType.answerer,
        level: BadgeLevel.silver,
        iconPath: '',
        requiredPoints: 100,
        criteria: 'Provide 10 answers that are marked as helpful',
        isUnlocked: false,
      ),
      Badge(
        id: 'expert_contributor',
        name: 'Expert Contributor',
        description: 'Earned 500 points from community participation',
        type: BadgeType.expert,
        level: BadgeLevel.gold,
        iconPath: '',
        requiredPoints: 500,
        criteria: 'Earn 500 total points from questions, answers, and votes',
        isUnlocked: false,
      ),
      Badge(
        id: 'community_mentor',
        name: 'Community Mentor',
        description: 'Helped 50 students with their doubts',
        type: BadgeType.mentor,
        level: BadgeLevel.platinum,
        iconPath: '',
        requiredPoints: 1000,
        criteria: 'Answer 50 questions and receive positive feedback',
        isUnlocked: false,
      ),
    ];
  }

  Color _getBadgeColor(BadgeLevel level) {
    switch (level) {
      case BadgeLevel.bronze:
        return const Color(0xFFCD7F32);
      case BadgeLevel.silver:
        return const Color(0xFFC0C0C0);
      case BadgeLevel.gold:
        return const Color(0xFFFFD700);
      case BadgeLevel.platinum:
        return const Color(0xFFE5E4E2);
      case BadgeLevel.diamond:
        return const Color(0xFFB9F2FF);
    }
  }
}
