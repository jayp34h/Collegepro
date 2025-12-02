import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/community_doubts_provider.dart';
import '../models/badge_model.dart' as badge_model;

class GamificationPanel extends StatelessWidget {
  const GamificationPanel({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<CommunityDoubtsProvider>(
      builder: (context, provider, child) {
        final progress = provider.userProgress;
        if (progress == null) {
          return const SizedBox.shrink();
        }

        return Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.15),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: Colors.white.withOpacity(0.3),
              width: 1,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(progress),
              const SizedBox(height: 16),
              _buildUserStats(progress),
              const SizedBox(height: 16),
              _buildRecentBadges(provider.userBadges),
            ],
          ),
        );
      },
    );
  }

  Widget _buildHeader(badge_model.UserProgress progress) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.2),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(
            _getLevelIcon(progress.level),
            color: Colors.white,
            size: 24,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Level ${progress.level}',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                '${progress.totalPoints} points',
                style: TextStyle(
                  color: Colors.white.withOpacity(0.8),
                  fontSize: 14,
                ),
              ),
            ],
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: Colors.orange.withOpacity(0.2),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: Colors.orange.withOpacity(0.5),
              width: 1,
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.local_fire_department,
                color: Colors.orange,
                size: 16,
              ),
              const SizedBox(width: 4),
              Text(
                '${progress.currentStreak}',
                style: const TextStyle(
                  color: Colors.orange,
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildUserStats(badge_model.UserProgress progress) {
    return Row(
      children: [
        Expanded(
          child: _buildStatCard(
            'Questions',
            progress.questionsAsked.toString(),
            Icons.help_outline,
            Colors.blue,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: _buildStatCard(
            'Answers',
            progress.answersGiven.toString(),
            Icons.chat_bubble_outline,
            Colors.green,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: _buildStatCard(
            'Best',
            progress.bestAnswers.toString(),
            Icons.star,
            Colors.amber,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: _buildStatCard(
            'Solved',
            progress.doubtsSolved.toString(),
            Icons.check_circle,
            Colors.purple,
          ),
        ),
      ],
    );
  }

  Widget _buildStatCard(String label, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        children: [
          Icon(
            icon,
            color: color,
            size: 20,
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
          Text(
            label,
            style: TextStyle(
              color: Colors.white.withOpacity(0.8),
              fontSize: 10,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRecentBadges(List<badge_model.Badge> badges) {
    if (badges.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          children: [
            Icon(
              Icons.emoji_events_outlined,
              color: Colors.white.withOpacity(0.6),
              size: 20,
            ),
            const SizedBox(width: 8),
            Text(
              'No badges earned yet',
              style: TextStyle(
                color: Colors.white.withOpacity(0.8),
                fontSize: 12,
              ),
            ),
          ],
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Recent Badges (${badges.length})',
          style: TextStyle(
            color: Colors.white.withOpacity(0.9),
            fontSize: 12,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 8),
        SizedBox(
          height: 60,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: badges.take(5).length,
            itemBuilder: (context, index) {
              final badge = badges[index];
              return Container(
                margin: const EdgeInsets.only(right: 8),
                child: _buildBadgeItem(badge),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildBadgeItem(badge_model.Badge badge) {
    return Container(
      width: 50,
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: _getBadgeLevelColor(badge.level).withOpacity(0.5),
          width: 1,
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            _getBadgeIcon(badge.type),
            color: _getBadgeLevelColor(badge.level),
            size: 20,
          ),
          const SizedBox(height: 4),
          Text(
            badge.name.split(' ').first,
            style: TextStyle(
              color: Colors.white.withOpacity(0.9),
              fontSize: 8,
              fontWeight: FontWeight.w500,
            ),
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  IconData _getLevelIcon(int level) {
    if (level >= 50) return Icons.diamond;
    if (level >= 30) return Icons.star;
    if (level >= 20) return Icons.military_tech;
    if (level >= 10) return Icons.shield;
    return Icons.person;
  }

  IconData _getBadgeIcon(badge_model.BadgeType type) {
    switch (type) {
      case badge_model.BadgeType.questioner:
        return Icons.help;
      case badge_model.BadgeType.answerer:
        return Icons.chat;
      case badge_model.BadgeType.expert:
        return Icons.lightbulb;
      case badge_model.BadgeType.contributor:
        return Icons.favorite;
      case badge_model.BadgeType.scholar:
        return Icons.school;
      case badge_model.BadgeType.mentor:
        return Icons.person_pin;
      default:
        return Icons.help;
    }
  }

  Color _getBadgeLevelColor(badge_model.BadgeLevel level) {
    switch (level) {
      case badge_model.BadgeLevel.bronze:
        return Colors.brown[400]!;
      case badge_model.BadgeLevel.silver:
        return Colors.grey[300]!;
      case badge_model.BadgeLevel.gold:
        return Colors.yellow[600]!;
      case badge_model.BadgeLevel.platinum:
        return Colors.blueGrey[200]!;
      case badge_model.BadgeLevel.diamond:
        return Colors.cyan[300]!;
    }
  }
}
