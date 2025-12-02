import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:timeago/timeago.dart' as timeago;
import '../models/answer_model.dart';
import '../../../core/providers/auth_provider.dart';

class AnswerCard extends StatelessWidget {
  final DoubtAnswer answer;
  final Function(bool) onVote;
  final VoidCallback onMarkBest;
  final VoidCallback onReport;

  const AnswerCard({
    super.key,
    required this.answer,
    required this.onVote,
    required this.onMarkBest,
    required this.onReport,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: answer.isBestAnswer ? 3 : 1,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: answer.isBestAnswer
            ? const BorderSide(color: Colors.green, width: 2)
            : BorderSide.none,
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(),
            const SizedBox(height: 12),
            _buildContent(),
            const SizedBox(height: 16),
            _buildFooter(context),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      children: [
        CircleAvatar(
          radius: 16,
          backgroundColor: Colors.blue[600],
          child: Text(
            answer.userId.substring(0, 1).toUpperCase(),
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
                'User ${answer.userId.substring(0, 8)}...',
                style: const TextStyle(
                  fontWeight: FontWeight.w500,
                  fontSize: 14,
                ),
              ),
              Text(
                timeago.format(answer.timestamp),
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[600],
                ),
              ),
            ],
          ),
        ),
        if (answer.isBestAnswer)
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
                  Icons.star,
                  size: 14,
                  color: Colors.green[700],
                ),
                const SizedBox(width: 4),
                Text(
                  'Best Answer',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    color: Colors.green[700],
                  ),
                ),
              ],
            ),
          ),
        if (answer.helpfulCount > 0)
          Container(
            margin: const EdgeInsets.only(left: 8),
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.blue[100],
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.thumb_up,
                  size: 12,
                  color: Colors.blue[700],
                ),
                const SizedBox(width: 4),
                Text(
                  'Helpful',
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w500,
                    color: Colors.blue[700],
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }

  Widget _buildContent() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          answer.content,
          style: TextStyle(
            fontSize: 15,
            color: Colors.grey[800],
            height: 1.5,
          ),
        ),
        if (answer.attachments.isNotEmpty) ...[
          const SizedBox(height: 12),
          _buildAttachments(),
        ],
      ],
    );
  }

  Widget _buildAttachments() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Icon(
            Icons.attachment,
            size: 16,
            color: Colors.grey[600],
          ),
          const SizedBox(width: 8),
          Text(
            '${answer.attachments.length} attachment(s)',
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFooter(BuildContext context) {
    return Consumer<AuthProvider>(
      builder: (context, authProvider, child) {
        final currentUserId = authProvider.user?.uid;
        if (currentUserId == null) return const SizedBox.shrink();

        final hasUpvoted = answer.upvotedBy.contains(currentUserId);
        final hasDownvoted = answer.downvotedBy.contains(currentUserId);

        return Row(
          children: [
            _buildVoteButton(
              Icons.thumb_up,
              hasUpvoted,
              Colors.green,
              () => onVote(true),
            ),
            const SizedBox(width: 8),
            Text(
              '${answer.upvotes - answer.downvotes}',
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(width: 8),
            _buildVoteButton(
              Icons.thumb_down,
              hasDownvoted,
              Colors.red,
              () => onVote(false),
            ),
            const SizedBox(width: 16),
            _buildActionButton(
              Icons.star_border,
              'Mark as Best',
              Colors.amber,
              onMarkBest,
            ),
            const SizedBox(width: 8),
            _buildActionButton(
              Icons.flag_outlined,
              'Report',
              Colors.red,
              onReport,
            ),
            const Spacer(),
            Text(
              '${answer.upvotes} upvotes',
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey[600],
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildVoteButton(
    IconData icon,
    bool isActive,
    Color color,
    VoidCallback onPressed,
  ) {
    return InkWell(
      onTap: onPressed,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(6),
        decoration: BoxDecoration(
          color: isActive ? color.withOpacity(0.1) : Colors.grey[100],
          borderRadius: BorderRadius.circular(16),
        ),
        child: Icon(
          icon,
          size: 16,
          color: isActive ? color : Colors.grey[600],
        ),
      ),
    );
  }

  Widget _buildActionButton(
    IconData icon,
    String tooltip,
    Color color,
    VoidCallback onPressed,
  ) {
    return Tooltip(
      message: tooltip,
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.all(6),
          decoration: BoxDecoration(
            color: Colors.grey[100],
            borderRadius: BorderRadius.circular(16),
          ),
          child: Icon(
            icon,
            size: 16,
            color: color,
          ),
        ),
      ),
    );
  }
}
