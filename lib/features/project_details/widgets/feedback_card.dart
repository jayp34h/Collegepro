import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:timeago/timeago.dart' as timeago;
import '../../../core/models/feedback_model.dart';
import '../../../core/providers/feedback_provider.dart';
import '../../../core/providers/notification_provider.dart';
import '../../../core/providers/auth_provider.dart';
import 'feedback_submission_form.dart';

class FeedbackCard extends StatelessWidget {
  final FeedbackModel feedback;
  final String projectId;

  const FeedbackCard({
    super.key,
    required this.feedback,
    required this.projectId,
  });

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final isCurrentUser = authProvider.user?.uid == feedback.userId;
    final hasMarkedHelpful = feedback.helpfulUsers.contains(authProvider.user?.uid);

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
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
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header with user info and rating
          Row(
            children: [
              CircleAvatar(
                radius: 20,
                backgroundColor: Theme.of(context).primaryColor.withOpacity(0.1),
                child: Text(
                  feedback.userName.isNotEmpty 
                      ? feedback.userName[0].toUpperCase()
                      : 'A',
                  style: TextStyle(
                    color: Theme.of(context).primaryColor,
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
                        Flexible(
                          child: Text(
                            feedback.userName.isNotEmpty ? feedback.userName : 'Anonymous',
                            style: const TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: 14,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        if (isCurrentUser) ...[
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: Theme.of(context).primaryColor.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              'You',
                              style: TextStyle(
                                color: Theme.of(context).primaryColor,
                                fontSize: 10,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                    const SizedBox(height: 2),
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: [
                          Row(
                            children: List.generate(5, (index) {
                              return Icon(
                                index < feedback.rating.round()
                                    ? Icons.star
                                    : Icons.star_border,
                                color: Colors.amber,
                                size: 14,
                              );
                            }),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            feedback.rating.toStringAsFixed(1),
                            style: TextStyle(
                              color: Colors.grey[600],
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            '•',
                            style: TextStyle(color: Colors.grey[400]),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            timeago.format(feedback.timestamp),
                            style: TextStyle(
                              color: Colors.grey[600],
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              if (isCurrentUser)
                PopupMenuButton<String>(
                  onSelected: (value) => _handleMenuAction(context, value),
                  itemBuilder: (context) => [
                    const PopupMenuItem(
                      value: 'edit',
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.edit, size: 18),
                          SizedBox(width: 8),
                          Text('Edit'),
                        ],
                      ),
                    ),
                    const PopupMenuItem(
                      value: 'delete',
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.delete, size: 18, color: Colors.red),
                          SizedBox(width: 8),
                          Text('Delete', style: TextStyle(color: Colors.red)),
                        ],
                      ),
                    ),
                  ],
                ),
            ],
          ),
          const SizedBox(height: 12),

          // Category badge
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: _getCategoryColor(feedback.category).withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: _getCategoryColor(feedback.category).withOpacity(0.3),
              ),
            ),
            child: Text(
              _getCategoryDisplayName(feedback.category),
              style: TextStyle(
                color: _getCategoryColor(feedback.category),
                fontSize: 11,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          const SizedBox(height: 12),

          // Feedback content
          Text(
            feedback.feedback,
            style: TextStyle(
              fontSize: 14,
              height: 1.5,
              color: Colors.grey[800],
            ),
          ),

          // Tags
          if (feedback.tags.isNotEmpty) ...[
            const SizedBox(height: 12),
            ConstrainedBox(
              constraints: const BoxConstraints(maxHeight: 100),
              child: SingleChildScrollView(
                child: Wrap(
                  spacing: 6,
                  runSpacing: 6,
                  children: feedback.tags.map((tag) {
                    return Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.grey[100],
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        '#$tag',
                        style: TextStyle(
                          color: Colors.grey[700],
                          fontSize: 11,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    );
                  }).toList(),
                ),
              ),
            ),
          ],

          const SizedBox(height: 12),

          // Replies Section
          if (feedback.replies.isNotEmpty) ...[
            const Divider(height: 24),
            Text(
              'Replies (${feedback.replies.length})',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Colors.grey[700],
              ),
            ),
            const SizedBox(height: 12),
            ...feedback.replies.map((reply) => _buildReplyCard(reply, context)),
          ],

          const SizedBox(height: 12),

          // Actions
          LayoutBuilder(
            builder: (context, constraints) {
              if (constraints.maxWidth < 300) {
                // Stack actions vertically on very small screens
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Helpful button
                    InkWell(
                      onTap: () => _markHelpful(context),
                      borderRadius: BorderRadius.circular(20),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: hasMarkedHelpful 
                              ? Theme.of(context).primaryColor.withOpacity(0.1)
                              : Colors.grey[100],
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: hasMarkedHelpful 
                                ? Theme.of(context).primaryColor.withOpacity(0.3)
                                : Colors.grey[300]!,
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              hasMarkedHelpful ? Icons.thumb_up : Icons.thumb_up_outlined,
                              size: 14,
                              color: hasMarkedHelpful 
                                  ? Theme.of(context).primaryColor
                                  : Colors.grey[600],
                            ),
                            const SizedBox(width: 4),
                            Flexible(
                              child: Text(
                                'Helpful${feedback.helpfulCount > 0 ? ' (${feedback.helpfulCount})' : ''}',
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w500,
                                  color: hasMarkedHelpful 
                                      ? Theme.of(context).primaryColor
                                      : Colors.grey[600],
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    // Reply button
                    InkWell(
                      onTap: () => _showReplyDialog(context),
                      borderRadius: BorderRadius.circular(20),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.reply_outlined,
                              size: 14,
                              color: Colors.grey[600],
                            ),
                            const SizedBox(width: 4),
                            Text(
                              'Reply',
                              style: TextStyle(
                                fontSize: 11,
                                color: Colors.grey[600],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                );
              } else {
                // Horizontal layout for larger screens
                return Row(
                  children: [
                    // Helpful button
                    Flexible(
                      child: InkWell(
                        onTap: () => _markHelpful(context),
                        borderRadius: BorderRadius.circular(20),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: hasMarkedHelpful 
                                ? Theme.of(context).primaryColor.withOpacity(0.1)
                                : Colors.grey[100],
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: hasMarkedHelpful 
                                  ? Theme.of(context).primaryColor.withOpacity(0.3)
                                  : Colors.grey[300]!,
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                hasMarkedHelpful ? Icons.thumb_up : Icons.thumb_up_outlined,
                                size: 14,
                                color: hasMarkedHelpful 
                                    ? Theme.of(context).primaryColor
                                    : Colors.grey[600],
                              ),
                              const SizedBox(width: 4),
                              Flexible(
                                child: Text(
                                  'Helpful${feedback.helpfulCount > 0 ? ' (${feedback.helpfulCount})' : ''}',
                                  style: TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w500,
                                    color: hasMarkedHelpful 
                                        ? Theme.of(context).primaryColor
                                        : Colors.grey[600],
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    const Spacer(),
                    
                    // Reply button
                    InkWell(
                      onTap: () => _showReplyDialog(context),
                      borderRadius: BorderRadius.circular(20),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.reply_outlined,
                              size: 14,
                              color: Colors.grey[600],
                            ),
                            const SizedBox(width: 4),
                            Text(
                              'Reply',
                              style: TextStyle(
                                fontSize: 11,
                                color: Colors.grey[600],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                );
              }
            },
          ),
        ],
      ),
    );
  }

  void _handleMenuAction(BuildContext context, String action) {
    switch (action) {
      case 'edit':
        _editFeedback(context);
        break;
      case 'delete':
        _deleteFeedback(context);
        break;
    }
  }

  void _editFeedback(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: FeedbackSubmissionForm(
          projectId: projectId,
          existingFeedback: feedback,
        ),
      ),
    );
  }

  void _deleteFeedback(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Feedback'),
        content: const Text('Are you sure you want to delete this feedback? This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              final feedbackProvider = Provider.of<FeedbackProvider>(context, listen: false);
              final authProvider = Provider.of<AuthProvider>(context, listen: false);
              
              final success = await feedbackProvider.deleteFeedback(
                projectId,
                feedback.id,
                authProvider.user!.uid,
              );
              
              if (success) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Feedback deleted successfully'),
                    backgroundColor: Colors.green,
                    behavior: SnackBarBehavior.floating,
                  ),
                );
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Failed to delete feedback'),
                    backgroundColor: Colors.red,
                    behavior: SnackBarBehavior.floating,
                  ),
                );
              }
            },
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  void _markHelpful(BuildContext context) async {
    final feedbackProvider = Provider.of<FeedbackProvider>(context, listen: false);
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    
    if (authProvider.user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please login to mark feedback as helpful'),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    await feedbackProvider.markFeedbackHelpful(
      projectId,
      feedback.id,
      authProvider.user!.uid,
    );
  }

  Color _getCategoryColor(String category) {
    switch (category) {
      case 'technical':
        return Colors.blue;
      case 'design':
        return Colors.purple;
      case 'implementation':
        return Colors.green;
      case 'suggestion':
        return Colors.orange;
      case 'improvement':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  String _getCategoryDisplayName(String category) {
    switch (category) {
      case 'technical':
        return 'Technical';
      case 'design':
        return 'Design';
      case 'implementation':
        return 'Implementation';
      case 'suggestion':
        return 'Suggestion';
      case 'improvement':
        return 'Improvement';
      default:
        return 'General';
    }
  }

  void _showReplyDialog(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    
    if (authProvider.user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please login to reply to feedback'),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    final TextEditingController replyController = TextEditingController();
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Reply to ${feedback.userName}'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                feedback.feedback,
                style: TextStyle(
                  color: Colors.grey[700],
                  fontSize: 13,
                ),
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: replyController,
              decoration: const InputDecoration(
                hintText: 'Write your reply...',
                border: OutlineInputBorder(),
              ),
              maxLines: 3,
              autofocus: true,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              final reply = replyController.text.trim();
              if (reply.isNotEmpty) {
                Navigator.pop(context);
                _submitReply(context, reply);
              }
            },
            child: const Text('Reply'),
          ),
        ],
      ),
    );
  }

  void _submitReply(BuildContext context, String reply) async {
    final feedbackProvider = Provider.of<FeedbackProvider>(context, listen: false);
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final notificationProvider = Provider.of<NotificationProvider>(context, listen: false);
    
    final success = await feedbackProvider.addReplyToFeedback(
      projectId,
      feedback.id,
      reply,
      authProvider.user!.uid,
      authProvider.userModel?.displayName ?? 'Anonymous',
      notificationProvider: notificationProvider,
    );
    
    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Reply added successfully!'),
          backgroundColor: Colors.green,
          behavior: SnackBarBehavior.floating,
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Failed to add reply'),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  void _handleReplyMenuAction(BuildContext context, String action, FeedbackReply reply) {
    switch (action) {
      case 'edit':
        _editReply(context, reply);
        break;
      case 'delete':
        _deleteReply(context, reply);
        break;
    }
  }

  void _editReply(BuildContext context, FeedbackReply reply) {
    final TextEditingController replyController = TextEditingController(text: reply.reply);
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Edit Reply'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              controller: replyController,
              decoration: const InputDecoration(
                hintText: 'Edit your reply...',
                border: OutlineInputBorder(),
              ),
              maxLines: 3,
              autofocus: true,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              final editedReply = replyController.text.trim();
              if (editedReply.isNotEmpty && editedReply != reply.reply) {
                Navigator.pop(context);
                
                final feedbackProvider = Provider.of<FeedbackProvider>(context, listen: false);
                final success = await feedbackProvider.editReply(
                  projectId,
                  feedback.id,
                  reply.id,
                  editedReply,
                );
                
                if (success) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Reply updated successfully!'),
                      backgroundColor: Colors.green,
                      behavior: SnackBarBehavior.floating,
                    ),
                  );
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Failed to update reply'),
                      backgroundColor: Colors.red,
                      behavior: SnackBarBehavior.floating,
                    ),
                  );
                }
              } else {
                Navigator.pop(context);
              }
            },
            child: const Text('Update'),
          ),
        ],
      ),
    );
  }

  void _deleteReply(BuildContext context, FeedbackReply reply) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Reply'),
        content: const Text('Are you sure you want to delete this reply? This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.of(context).pop();
              
              // Show loading indicator
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Row(
                      children: [
                        SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                          ),
                        ),
                        SizedBox(width: 12),
                        Text('Deleting reply...'),
                      ],
                    ),
                    duration: Duration(seconds: 2),
                  ),
                );
              }
              
              try {
                await Provider.of<FeedbackProvider>(context, listen: false)
                    .deleteReply(projectId, feedback.id, reply.id);
                
                if (context.mounted) {
                  ScaffoldMessenger.of(context).clearSnackBars();
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Row(
                        children: [
                          Icon(Icons.check_circle, color: Colors.white),
                          SizedBox(width: 8),
                          Text('Reply deleted successfully'),
                        ],
                      ),
                      backgroundColor: Colors.green,
                      duration: Duration(seconds: 2),
                    ),
                  );
                }
              } catch (e) {
                if (context.mounted) {
                  ScaffoldMessenger.of(context).clearSnackBars();
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Row(
                        children: [
                          const Icon(Icons.error, color: Colors.white),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              e.toString().replaceFirst('Exception: ', ''),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                      backgroundColor: Colors.red,
                      duration: const Duration(seconds: 4),
                      action: SnackBarAction(
                        label: 'Retry',
                        textColor: Colors.white,
                        onPressed: () => _deleteReply(context, reply),
                      ),
                    ),
                  );
                }
              }
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  Widget _buildReplyCard(FeedbackReply reply, BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final isCurrentUser = authProvider.user?.uid == reply.userId;
    
    return Container(
      margin: const EdgeInsets.only(bottom: 8, left: 16),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 12,
                backgroundColor: Theme.of(context).primaryColor.withOpacity(0.1),
                child: Text(
                  reply.userName.isNotEmpty 
                      ? reply.userName[0].toUpperCase()
                      : 'A',
                  style: TextStyle(
                    color: Theme.of(context).primaryColor,
                    fontWeight: FontWeight.bold,
                    fontSize: 10,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Flexible(
                          child: Text(
                            reply.userName.isNotEmpty ? reply.userName : 'Anonymous',
                            style: const TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: 12,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        if (isCurrentUser) ...[
                          const SizedBox(width: 6),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
                            decoration: BoxDecoration(
                              color: Theme.of(context).primaryColor.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              'You',
                              style: TextStyle(
                                color: Theme.of(context).primaryColor,
                                fontSize: 8,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                    Text(
                      timeago.format(reply.timestamp),
                      style: TextStyle(
                        color: Colors.grey[600],
                        fontSize: 10,
                      ),
                    ),
                  ],
                ),
              ),
              if (isCurrentUser)
                PopupMenuButton<String>(
                  onSelected: (value) => _handleReplyMenuAction(context, value, reply),
                  itemBuilder: (context) => [
                    const PopupMenuItem(
                      value: 'edit',
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.edit, size: 16),
                          SizedBox(width: 6),
                          Text('Edit', style: TextStyle(fontSize: 12)),
                        ],
                      ),
                    ),
                    const PopupMenuItem(
                      value: 'delete',
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.delete, size: 16, color: Colors.red),
                          SizedBox(width: 6),
                          Text('Delete', style: TextStyle(color: Colors.red, fontSize: 12)),
                        ],
                      ),
                    ),
                  ],
                  icon: Icon(
                    Icons.more_vert,
                    size: 16,
                    color: Colors.grey[600],
                  ),
                ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            reply.reply,
            style: TextStyle(
              fontSize: 12,
              height: 1.4,
              color: Colors.grey[800],
            ),
          ),
        ],
      ),
    );
  }
}
