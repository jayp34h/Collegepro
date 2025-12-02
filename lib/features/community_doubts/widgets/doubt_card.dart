import 'package:flutter/material.dart';
import 'package:timeago/timeago.dart' as timeago;
import '../models/doubt_model.dart';

class DoubtCard extends StatelessWidget {
  final CommunityDoubt doubt;
  final VoidCallback onTap;
  final bool showOwnerActions;

  const DoubtCard({
    super.key,
    required this.doubt,
    required this.onTap,
    this.showOwnerActions = false,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(),
              const SizedBox(height: 12),
              _buildTitle(),
              const SizedBox(height: 8),
              _buildDescription(),
              const SizedBox(height: 12),
              _buildTags(),
              const SizedBox(height: 12),
              _buildFooter(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      children: [
        CircleAvatar(
          radius: 16,
          backgroundColor: _getSubjectColor(),
          child: Text(
            doubt.subject.substring(0, 1).toUpperCase(),
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 14,
            ),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                doubt.subject,
                style: const TextStyle(
                  fontWeight: FontWeight.w500,
                  fontSize: 12,
                  color: Colors.grey,
                ),
              ),
              Text(
                timeago.format(doubt.createdAt),
                style: const TextStyle(
                  fontSize: 11,
                  color: Colors.grey,
                ),
              ),
            ],
          ),
        ),
        _buildDifficultyChip(),
        if (doubt.isResolved) ...[
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.green[100],
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.check_circle,
                  size: 12,
                  color: Colors.green[700],
                ),
                const SizedBox(width: 4),
                Text(
                  'Solved',
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w500,
                    color: Colors.green[700],
                  ),
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildTitle() {
    return Text(
      doubt.title,
      style: const TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w600,
        color: Colors.black87,
      ),
      maxLines: 2,
      overflow: TextOverflow.ellipsis,
    );
  }

  Widget _buildDescription() {
    return Text(
      doubt.description,
      style: TextStyle(
        fontSize: 14,
        color: Colors.grey[600],
        height: 1.4,
      ),
      maxLines: 3,
      overflow: TextOverflow.ellipsis,
    );
  }

  Widget _buildTags() {
    if (doubt.tags.isEmpty) return const SizedBox.shrink();

    return Wrap(
      spacing: 6,
      runSpacing: 4,
      children: doubt.tags.take(3).map((tag) {
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: const Color(0xFF6366F1).withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            tag,
            style: const TextStyle(
              fontSize: 11,
              color: Color(0xFF6366F1),
              fontWeight: FontWeight.w500,
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildFooter() {
    return Row(
      children: [
        _buildStatItem(
          Icons.thumb_up_outlined,
          doubt.upvotes.toString(),
          Colors.green,
        ),
        const SizedBox(width: 16),
        _buildStatItem(
          Icons.chat_bubble_outline,
          doubt.answersCount.toString(),
          Colors.blue,
        ),
        const SizedBox(width: 16),
        _buildStatItem(
          Icons.visibility_outlined,
          doubt.viewsCount.toString(),
          Colors.grey,
        ),
        const Spacer(),
        if (doubt.attachments.isNotEmpty)
          Container(
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              color: Colors.orange[100],
              borderRadius: BorderRadius.circular(6),
            ),
            child: Icon(
              Icons.attachment,
              size: 16,
              color: Colors.orange[700],
            ),
          ),
        if (doubt.isUrgent) ...[
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
            decoration: BoxDecoration(
              color: Colors.red[100],
              borderRadius: BorderRadius.circular(6),
            ),
            child: Text(
              'URGENT',
              style: TextStyle(
                fontSize: 9,
                fontWeight: FontWeight.bold,
                color: Colors.red[700],
              ),
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildStatItem(IconData icon, String count, Color color) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          icon,
          size: 16,
          color: color,
        ),
        const SizedBox(width: 4),
        Text(
          count,
          style: TextStyle(
            fontSize: 12,
            color: color,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _buildDifficultyChip() {
    MaterialColor chipColor;
    switch (doubt.difficulty.toLowerCase()) {
      case 'easy':
        chipColor = Colors.green;
        break;
      case 'medium':
        chipColor = Colors.orange;
        break;
      case 'hard':
        chipColor = Colors.red;
        break;
      default:
        chipColor = Colors.grey;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: chipColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        doubt.difficulty,
        style: TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.w500,
          color: chipColor[700],
        ),
      ),
    );
  }

  Color _getSubjectColor() {
    final colors = [
      Colors.blue,
      Colors.green,
      Colors.orange,
      Colors.purple,
      Colors.red,
      Colors.teal,
      Colors.indigo,
      Colors.pink,
    ];
    
    return colors[doubt.subject.hashCode % colors.length];
  }
}
