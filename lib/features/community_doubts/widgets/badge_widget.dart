import 'package:flutter/material.dart';
import '../models/badge_model.dart' as badge_model;

class BadgeWidget extends StatelessWidget {
  final badge_model.Badge badge;
  final double size;
  final bool showDetails;
  final VoidCallback? onTap;

  const BadgeWidget({
    super.key,
    required this.badge,
    this.size = 60,
    this.showDetails = true,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return GestureDetector(
      onTap: onTap ?? () => _showBadgeDetails(context),
      child: Container(
        width: showDetails ? null : size,
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              _getBadgeColor().withOpacity(0.1),
              _getBadgeColor().withOpacity(0.05),
            ],
          ),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: _getBadgeColor().withOpacity(0.3),
            width: 1,
          ),
        ),
        child: showDetails ? _buildDetailedBadge(theme) : _buildCompactBadge(),
      ),
    );
  }

  Widget _buildDetailedBadge(ThemeData theme) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        _buildBadgeIcon(),
        const SizedBox(width: 8),
        Flexible(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                badge.name,
                style: theme.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: _getBadgeColor(),
                ),
                overflow: TextOverflow.ellipsis,
              ),
              Text(
                badge.description,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: Colors.grey[600],
                  fontSize: 10,
                ),
                overflow: TextOverflow.ellipsis,
                maxLines: 2,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildCompactBadge() {
    return _buildBadgeIcon();
  }

  Widget _buildBadgeIcon() {
    return Container(
      width: size * 0.8,
      height: size * 0.8,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: LinearGradient(
          colors: badge.isUnlocked
              ? [_getBadgeColor(), _getBadgeColor().withOpacity(0.7)]
              : [Colors.grey.shade400, Colors.grey.shade300],
        ),
        boxShadow: badge.isUnlocked
            ? [
                BoxShadow(
                  color: _getBadgeColor().withOpacity(0.3),
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                ),
              ]
            : null,
      ),
      child: Icon(
        _getBadgeIcon(),
        color: badge.isUnlocked ? Colors.white : Colors.grey.shade600,
        size: size * 0.4,
      ),
    );
  }

  Color _getBadgeColor() {
    if (!badge.isUnlocked) return Colors.grey;
    
    switch (badge.level) {
      case badge_model.BadgeLevel.bronze:
        return const Color(0xFFCD7F32);
      case badge_model.BadgeLevel.silver:
        return const Color(0xFFC0C0C0);
      case badge_model.BadgeLevel.gold:
        return const Color(0xFFFFD700);
      case badge_model.BadgeLevel.platinum:
        return const Color(0xFFE5E4E2);
      case badge_model.BadgeLevel.diamond:
        return const Color(0xFFB9F2FF);
    }
  }

  IconData _getBadgeIcon() {
    switch (badge.type) {
      case badge_model.BadgeType.questioner:
        return Icons.help_outline;
      case badge_model.BadgeType.answerer:
        return Icons.lightbulb_outline;
      case badge_model.BadgeType.expert:
        return Icons.school_outlined;
      case badge_model.BadgeType.mentor:
        return Icons.person_outline;
      case badge_model.BadgeType.scholar:
        return Icons.auto_stories_outlined;
      case badge_model.BadgeType.contributor:
        return Icons.volunteer_activism_outlined;
      default:
        return Icons.help_outline;
    }
  }

  void _showBadgeDetails(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => BadgeDetailsDialog(badge: badge),
    );
  }
}

class BadgeDetailsDialog extends StatelessWidget {
  final badge_model.Badge badge;

  const BadgeDetailsDialog({
    super.key,
    required this.badge,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              _getBadgeColor().withOpacity(0.1),
              _getBadgeColor().withOpacity(0.05),
            ],
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Badge Icon
            Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(
                  colors: badge.isUnlocked
                      ? [_getBadgeColor(), _getBadgeColor().withOpacity(0.7)]
                      : [Colors.grey.shade400, Colors.grey.shade300],
                ),
                boxShadow: badge.isUnlocked
                    ? [
                        BoxShadow(
                          color: _getBadgeColor().withOpacity(0.3),
                          blurRadius: 15,
                          offset: const Offset(0, 8),
                        ),
                      ]
                    : null,
              ),
              child: Icon(
                _getBadgeIcon(),
                color: badge.isUnlocked ? Colors.white : Colors.grey.shade600,
                size: 50,
              ),
            ),
            
            const SizedBox(height: 16),
            
            // Badge Name
            Text(
              badge.name,
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: _getBadgeColor(),
              ),
              textAlign: TextAlign.center,
            ),
            
            const SizedBox(height: 8),
            
            // Badge Level
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              decoration: BoxDecoration(
                color: _getBadgeColor().withOpacity(0.2),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                badge.level.toString().split('.').last.toUpperCase(),
                style: theme.textTheme.bodySmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: _getBadgeColor(),
                ),
              ),
            ),
            
            const SizedBox(height: 16),
            
            // Description
            Text(
              badge.description,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: Colors.grey[600],
              ),
              textAlign: TextAlign.center,
            ),
            
            const SizedBox(height: 16),
            
            // Criteria
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'How to unlock:',
                    style: theme.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    badge.criteria,
                    style: theme.textTheme.bodySmall,
                  ),
                ],
              ),
            ),
            
            if (badge.isUnlocked && badge.unlockedAt != null) ...[
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.green.shade50,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.green.shade200),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.check_circle,
                      color: Colors.green,
                      size: 16,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      'Unlocked on ${_formatDate(badge.unlockedAt!)}',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: Colors.green.shade700,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ],
            
            const SizedBox(height: 24),
            
            // Close Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => Navigator.pop(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: _getBadgeColor(),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: const Text('Close'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Color _getBadgeColor() {
    if (!badge.isUnlocked) return Colors.grey;
    
    switch (badge.level) {
      case badge_model.BadgeLevel.bronze:
        return const Color(0xFFCD7F32);
      case badge_model.BadgeLevel.silver:
        return const Color(0xFFC0C0C0);
      case badge_model.BadgeLevel.gold:
        return const Color(0xFFFFD700);
      case badge_model.BadgeLevel.platinum:
        return const Color(0xFFE5E4E2);
      case badge_model.BadgeLevel.diamond:
        return const Color(0xFFB9F2FF);
    }
  }

  IconData _getBadgeIcon() {
    switch (badge.type) {
      case badge_model.BadgeType.questioner:
        return Icons.help_outline;
      case badge_model.BadgeType.answerer:
        return Icons.lightbulb_outline;
      case badge_model.BadgeType.expert:
        return Icons.school_outlined;
      case badge_model.BadgeType.mentor:
        return Icons.person_outline;
      case badge_model.BadgeType.scholar:
        return Icons.auto_stories_outlined;
      case badge_model.BadgeType.contributor:
        return Icons.volunteer_activism_outlined;
      default:
        return Icons.help_outline;
    }
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}
