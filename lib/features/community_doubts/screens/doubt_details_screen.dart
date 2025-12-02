import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:timeago/timeago.dart' as timeago;
import '../providers/community_doubts_provider.dart';
import '../models/doubt_model.dart';
import '../models/answer_model.dart';
import '../widgets/answer_card.dart';
import '../widgets/post_answer_dialog.dart';
import '../widgets/report_dialog.dart';
import '../../../core/providers/auth_provider.dart';

class DoubtDetailsScreen extends StatefulWidget {
  final String doubtId;

  const DoubtDetailsScreen({
    super.key,
    required this.doubtId,
  });

  @override
  State<DoubtDetailsScreen> createState() => _DoubtDetailsScreenState();
}

class _DoubtDetailsScreenState extends State<DoubtDetailsScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<CommunityDoubtsProvider>().loadDoubtDetails(widget.doubtId);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: _buildAppBar(),
      body: Consumer<CommunityDoubtsProvider>(
        builder: (context, provider, child) {
          if (provider.isLoadingAnswers) {
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
                      provider.clearError();
                      provider.loadDoubtDetails(widget.doubtId);
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

          final doubt = provider.currentDoubt;
          if (doubt == null) {
            return const Center(
              child: Text('Doubt not found'),
            );
          }

          return Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildDoubtCard(doubt),
                      const SizedBox(height: 24),
                      _buildAnswersSection(provider.currentAnswers),
                    ],
                  ),
                ),
              ),
              _buildAnswerButton(),
            ],
          );
        },
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      title: const Text(
        'Question Details',
        style: TextStyle(
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      ),
      backgroundColor: const Color(0xFF6366F1),
      elevation: 0,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back, color: Colors.white),
        onPressed: () => Navigator.pop(context),
      ),
      actions: [
        Consumer<CommunityDoubtsProvider>(
          builder: (context, provider, child) {
            final doubt = provider.currentDoubt;
            if (doubt == null) return const SizedBox.shrink();

            return PopupMenuButton<String>(
              icon: const Icon(Icons.more_vert, color: Colors.white),
              onSelected: (value) => _handleMenuAction(value, doubt),
              itemBuilder: (context) => [
                const PopupMenuItem(
                  value: 'report',
                  child: Row(
                    children: [
                      Icon(Icons.flag, color: Colors.red),
                      SizedBox(width: 8),
                      Text('Report'),
                    ],
                  ),
                ),
                const PopupMenuItem(
                  value: 'share',
                  child: Row(
                    children: [
                      Icon(Icons.share, color: Colors.blue),
                      SizedBox(width: 8),
                      Text('Share'),
                    ],
                  ),
                ),
              ],
            );
          },
        ),
      ],
    );
  }

  Widget _buildDoubtCard(CommunityDoubt doubt) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildDoubtHeader(doubt),
            const SizedBox(height: 16),
            _buildDoubtTitle(doubt),
            const SizedBox(height: 12),
            _buildDoubtDescription(doubt),
            const SizedBox(height: 16),
            _buildDoubtTags(doubt),
            const SizedBox(height: 16),
            _buildDoubtStats(doubt),
            const SizedBox(height: 16),
            _buildVotingSection(doubt),
          ],
        ),
      ),
    );
  }

  Widget _buildDoubtHeader(CommunityDoubt doubt) {
    return Row(
      children: [
        CircleAvatar(
          radius: 20,
          backgroundColor: _getSubjectColor(doubt.subject),
          child: Text(
            doubt.subject.substring(0, 1).toUpperCase(),
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Text(
                    doubt.subject,
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(width: 8),
                  _buildDifficultyChip(doubt.difficulty),
                ],
              ),
              const SizedBox(height: 4),
              Text(
                'Posted ${timeago.format(doubt.createdAt)}',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[600],
                ),
              ),
            ],
          ),
        ),
        if (doubt.isResolved)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.green[100],
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.check_circle,
                  size: 16,
                  color: Colors.green[700],
                ),
                const SizedBox(width: 4),
                Text(
                  'Solved',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: Colors.green[700],
                  ),
                ),
              ],
            ),
          ),
        if (doubt.isUrgent)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.red[100],
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              'URGENT',
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.bold,
                color: Colors.red[700],
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildDoubtTitle(CommunityDoubt doubt) {
    return Text(
      doubt.title,
      style: const TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.bold,
        color: Colors.black87,
        height: 1.3,
      ),
    );
  }

  Widget _buildDoubtDescription(CommunityDoubt doubt) {
    return Text(
      doubt.description,
      style: TextStyle(
        fontSize: 16,
        color: Colors.grey[700],
        height: 1.5,
      ),
    );
  }

  Widget _buildDoubtTags(CommunityDoubt doubt) {
    if (doubt.tags.isEmpty) return const SizedBox.shrink();

    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: doubt.tags.map((tag) {
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: const Color(0xFF6366F1).withOpacity(0.1),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Text(
            tag,
            style: const TextStyle(
              fontSize: 12,
              color: Color(0xFF6366F1),
              fontWeight: FontWeight.w500,
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildDoubtStats(CommunityDoubt doubt) {
    return Row(
      children: [
        _buildStatItem(
          Icons.visibility_outlined,
          doubt.viewsCount.toString(),
          'views',
          Colors.grey,
        ),
        const SizedBox(width: 20),
        _buildStatItem(
          Icons.chat_bubble_outline,
          doubt.answersCount.toString(),
          'answers',
          Colors.blue,
        ),
        const SizedBox(width: 20),
        _buildStatItem(
          Icons.thumb_up_outlined,
          doubt.upvotes.toString(),
          'upvotes',
          Colors.green,
        ),
      ],
    );
  }

  Widget _buildStatItem(IconData icon, String count, String label, Color color) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 16, color: color),
        const SizedBox(width: 4),
        Text(
          count,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: color,
          ),
        ),
        const SizedBox(width: 4),
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

  Widget _buildVotingSection(CommunityDoubt doubt) {
    return Consumer<AuthProvider>(
      builder: (context, authProvider, child) {
        final currentUserId = authProvider.user?.uid;
        if (currentUserId == null) return const SizedBox.shrink();

        final hasUpvoted = doubt.upvotedBy.contains(currentUserId);
        final hasDownvoted = doubt.downvotedBy.contains(currentUserId);

        return Row(
          children: [
            _buildVoteButton(
              Icons.thumb_up,
              hasUpvoted,
              Colors.green,
              () => _voteOnDoubt(doubt.id, currentUserId, true),
            ),
            const SizedBox(width: 8),
            Text(
              '${doubt.upvotes - doubt.downvotes}',
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(width: 8),
            _buildVoteButton(
              Icons.thumb_down,
              hasDownvoted,
              Colors.red,
              () => _voteOnDoubt(doubt.id, currentUserId, false),
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
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: isActive ? color.withOpacity(0.1) : Colors.grey[100],
          borderRadius: BorderRadius.circular(20),
        ),
        child: Icon(
          icon,
          size: 20,
          color: isActive ? color : Colors.grey[600],
        ),
      ),
    );
  }

  Widget _buildAnswersSection(List<DoubtAnswer> answers) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Text(
              'Answers',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: const Color(0xFF6366F1).withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                '${answers.length}',
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF6366F1),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        if (answers.isEmpty)
          _buildNoAnswersWidget()
        else
          ...answers.map((answer) => AnswerCard(
                answer: answer,
                onVote: (isUpvote) => _voteOnAnswer(answer.id, isUpvote),
                onMarkBest: () => _markAsBestAnswer(answer),
                onReport: () => _reportAnswer(answer),
              )),
      ],
    );
  }

  Widget _buildNoAnswersWidget() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[300]!),
      ),
      child: Column(
        children: [
          Icon(
            Icons.chat_bubble_outline,
            size: 48,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 12),
          Text(
            'No answers yet',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Be the first to help solve this question!',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[500],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAnswerButton() {
    return Consumer<AuthProvider>(
      builder: (context, authProvider, child) {
        if (authProvider.user == null) {
          return const SizedBox.shrink();
        }

        return Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 4,
                offset: const Offset(0, -2),
              ),
            ],
          ),
          child: SafeArea(
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _showPostAnswerDialog,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF6366F1),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                icon: const Icon(Icons.edit),
                label: const Text(
                  'Write an Answer',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildDifficultyChip(String difficulty) {
    Color chipColor;
    switch (difficulty.toLowerCase()) {
      case 'easy':
        chipColor = Colors.green.shade700;
        break;
      case 'medium':
        chipColor = Colors.orange.shade700;
        break;
      case 'hard':
        chipColor = Colors.red.shade700;
        break;
      default:
        chipColor = Colors.grey.shade700;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: chipColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        difficulty,
        style: TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.w600,
          color: chipColor,
        ),
      ),
    );
  }

  Color _getSubjectColor(String subject) {
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
    
    return colors[subject.hashCode % colors.length];
  }

  void _handleMenuAction(String action, CommunityDoubt doubt) {
    switch (action) {
      case 'report':
        _reportDoubt(doubt);
        break;
      case 'share':
        _shareDoubt(doubt);
        break;
    }
  }

  void _voteOnDoubt(String doubtId, String userId, bool isUpvote) {
    context.read<CommunityDoubtsProvider>().voteOnDoubt(doubtId, userId, isUpvote);
  }

  void _voteOnAnswer(String answerId, bool isUpvote) {
    final authProvider = context.read<AuthProvider>();
    if (authProvider.user != null) {
      context.read<CommunityDoubtsProvider>().voteOnAnswer(
            answerId,
            authProvider.user!.uid,
            isUpvote,
          );
    }
  }

  void _markAsBestAnswer(DoubtAnswer answer) {
    final authProvider = context.read<AuthProvider>();
    final provider = context.read<CommunityDoubtsProvider>();
    final doubt = provider.currentDoubt;
    
    if (authProvider.user != null && doubt != null) {
      provider.markAsBestAnswer(
        doubt.id,
        answer.id,
        doubt.userId,
        authProvider.user!.uid,
      );
    }
  }

  void _showPostAnswerDialog() {
    showDialog(
      context: context,
      builder: (context) => PostAnswerDialog(doubtId: widget.doubtId),
    );
  }

  void _reportDoubt(CommunityDoubt doubt) {
    showDialog(
      context: context,
      builder: (context) => ReportDialog(
        contentId: doubt.id,
        contentType: 'doubt',
        contentTitle: doubt.title,
      ),
    );
  }

  void _reportAnswer(DoubtAnswer answer) {
    showDialog(
      context: context,
      builder: (context) => ReportDialog(
        contentId: answer.id,
        contentType: 'answer',
        contentTitle: 'Answer to: ${context.read<CommunityDoubtsProvider>().currentDoubt?.title ?? "Question"}',
      ),
    );
  }

  void _shareDoubt(CommunityDoubt doubt) {
    // Implement share functionality
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Share functionality coming soon!'),
      ),
    );
  }
}
