import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/models/feedback_model.dart';
import '../../../core/providers/feedback_provider.dart';
import '../../../core/providers/auth_provider.dart';
import 'feedback_card.dart';
import 'feedback_submission_form.dart';
import 'feedback_stats_widget.dart';

class FeedbackSection extends StatefulWidget {
  final String projectId;

  const FeedbackSection({
    super.key,
    required this.projectId,
  });

  @override
  State<FeedbackSection> createState() => _FeedbackSectionState();
}

class _FeedbackSectionState extends State<FeedbackSection> {
  String _selectedFilter = 'all';
  String _selectedSort = 'newest';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadFeedbacks();
    });
  }

  Future<void> _loadFeedbacks() async {
    final feedbackProvider = Provider.of<FeedbackProvider>(context, listen: false);
    debugPrint('🔄 FeedbackSection: Loading feedbacks for project ${widget.projectId}');
    await feedbackProvider.loadProjectFeedbacks(widget.projectId);
    debugPrint('📊 FeedbackSection: Loaded ${feedbackProvider.feedbacks.length} feedbacks');
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<FeedbackProvider>(
      builder: (context, feedbackProvider, child) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Section Header
            Container(
              padding: const EdgeInsets.all(20),
              child: LayoutBuilder(
                builder: (context, constraints) {
                  if (constraints.maxWidth < 600) {
                    // Mobile layout - stack vertically
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(
                              Icons.feedback_outlined,
                              color: Theme.of(context).primaryColor,
                              size: 24,
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                'Student Feedback & Reviews',
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        _buildAddFeedbackButton(context),
                      ],
                    );
                  } else {
                    // Desktop layout - horizontal
                    return Row(
                      children: [
                        Icon(
                          Icons.feedback_outlined,
                          color: Theme.of(context).primaryColor,
                          size: 24,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'Student Feedback & Reviews',
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        _buildAddFeedbackButton(context),
                      ],
                    );
                  }
                },
              ),
            ),

            // Feedback Stats
            if (feedbackProvider.stats.totalFeedbacks > 0)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: FeedbackStatsWidget(stats: feedbackProvider.stats),
              ),

            // Filters and Sort
            if (feedbackProvider.feedbacks.isNotEmpty)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    if (constraints.maxWidth < 600) {
                      // Mobile layout - stack vertically
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildFilterChips(),
                          const SizedBox(height: 12),
                          Row(
                            children: [
                              const Text(
                                'Sort by: ',
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              Expanded(child: _buildSortDropdown()),
                            ],
                          ),
                        ],
                      );
                    } else {
                      // Desktop layout - horizontal
                      return Row(
                        children: [
                          Expanded(child: _buildFilterChips()),
                          const SizedBox(width: 16),
                          _buildSortDropdown(),
                        ],
                      );
                    }
                  },
                ),
              ),

            // Loading State
            if (feedbackProvider.isLoading)
              const Center(
                child: Padding(
                  padding: EdgeInsets.all(32),
                  child: CircularProgressIndicator(),
                ),
              ),

            // Error State
            if (feedbackProvider.error.isNotEmpty)
              Container(
                margin: const EdgeInsets.all(20),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.red[50],
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.red[200]!),
                ),
                child: Row(
                  children: [
                    Icon(Icons.error_outline, color: Colors.red[600]),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        feedbackProvider.error,
                        style: TextStyle(color: Colors.red[600]),
                      ),
                    ),
                    TextButton(
                      onPressed: _loadFeedbacks,
                      child: const Text('Retry'),
                    ),
                  ],
                ),
              ),

            // Empty State
            if (!feedbackProvider.isLoading && 
                feedbackProvider.feedbacks.isEmpty && 
                feedbackProvider.error.isEmpty)
              _buildEmptyState(context),

            // Feedback List
            if (feedbackProvider.filteredFeedbacks.isNotEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  children: _getSortedFeedbacks(feedbackProvider.filteredFeedbacks)
                      .map((feedback) => FeedbackCard(
                            feedback: feedback,
                            projectId: widget.projectId,
                          ))
                      .toList(),
                ),
              ),

            const SizedBox(height: 20),
          ],
        );
      },
    );
  }

  Widget _buildAddFeedbackButton(BuildContext context) {
    return Consumer<AuthProvider>(
      builder: (context, authProvider, child) {
        if (authProvider.user == null) {
          return LayoutBuilder(
            builder: (context, constraints) {
              final isSmallScreen = constraints.maxWidth < 150;
              return ElevatedButton.icon(
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Please login to share feedback'),
                      behavior: SnackBarBehavior.floating,
                    ),
                  );
                },
                icon: const Icon(Icons.add, size: 16),
                label: Text(
                  isSmallScreen ? 'Share' : 'Share Feedback',
                  overflow: TextOverflow.ellipsis,
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.grey[300],
                  foregroundColor: Colors.grey[600],
                  padding: EdgeInsets.symmetric(
                    horizontal: isSmallScreen ? 12 : 16,
                    vertical: 8,
                  ),
                ),
              );
            },
          );
        }

        return Consumer<FeedbackProvider>(
          builder: (context, feedbackProvider, child) {
            final userFeedback = feedbackProvider.getUserFeedback(authProvider.user!.uid);
            
            return LayoutBuilder(
              builder: (context, constraints) {
                final isSmallScreen = constraints.maxWidth < 150;
                return ElevatedButton.icon(
                  onPressed: () => _showFeedbackForm(context, userFeedback),
                  icon: Icon(
                    userFeedback != null ? Icons.edit : Icons.add,
                    size: 16,
                  ),
                  label: Text(
                    userFeedback != null 
                        ? (isSmallScreen ? 'Edit' : 'Edit Feedback')
                        : (isSmallScreen ? 'Share' : 'Share Feedback'),
                    overflow: TextOverflow.ellipsis,
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Theme.of(context).primaryColor,
                    foregroundColor: Colors.white,
                    padding: EdgeInsets.symmetric(
                      horizontal: isSmallScreen ? 12 : 16,
                      vertical: 8,
                    ),
                  ),
                );
              },
            );
          },
        );
      },
    );
  }

  Widget _buildFilterChips() {
    final filters = [
      {'key': 'all', 'label': 'All'},
      {'key': 'technical', 'label': 'Technical'},
      {'key': 'design', 'label': 'Design'},
      {'key': 'implementation', 'label': 'Implementation'},
      {'key': 'general', 'label': 'General'},
    ];

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: filters.map((filter) {
          final isSelected = _selectedFilter == filter['key'];
          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: FilterChip(
              label: Text(filter['label']!),
              selected: isSelected,
              onSelected: (selected) {
                setState(() {
                  _selectedFilter = filter['key']!;
                });
                final feedbackProvider = Provider.of<FeedbackProvider>(context, listen: false);
                feedbackProvider.setCategory(_selectedFilter);
              },
              selectedColor: Theme.of(context).primaryColor.withOpacity(0.2),
              checkmarkColor: Theme.of(context).primaryColor,
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildSortDropdown() {
    return DropdownButton<String>(
      value: _selectedSort,
      onChanged: (value) {
        setState(() {
          _selectedSort = value!;
        });
      },
      items: const [
        DropdownMenuItem(value: 'newest', child: Text('Newest First')),
        DropdownMenuItem(value: 'oldest', child: Text('Oldest First')),
        DropdownMenuItem(value: 'rating_high', child: Text('Highest Rating')),
        DropdownMenuItem(value: 'rating_low', child: Text('Lowest Rating')),
        DropdownMenuItem(value: 'helpful', child: Text('Most Helpful')),
      ],
      underline: Container(),
      icon: const Icon(Icons.sort),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(40),
      child: Column(
        children: [
          Icon(
            Icons.feedback_outlined,
            size: 64,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            'No feedback yet',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Be the first to share your thoughts about this project!',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.grey[500],
            ),
          ),
          const SizedBox(height: 20),
          Consumer<AuthProvider>(
            builder: (context, authProvider, child) {
              if (authProvider.user != null) {
                return ElevatedButton.icon(
                  onPressed: () => _showFeedbackForm(context, null),
                  icon: const Icon(Icons.add),
                  label: const Text('Share Your Feedback'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Theme.of(context).primaryColor,
                    foregroundColor: Colors.white,
                  ),
                );
              }
              return const SizedBox.shrink();
            },
          ),
        ],
      ),
    );
  }

  List<FeedbackModel> _getSortedFeedbacks(List<FeedbackModel> feedbacks) {
    final sortedFeedbacks = List<FeedbackModel>.from(feedbacks);

    switch (_selectedSort) {
      case 'newest':
        sortedFeedbacks.sort((a, b) => b.timestamp.compareTo(a.timestamp));
        break;
      case 'oldest':
        sortedFeedbacks.sort((a, b) => a.timestamp.compareTo(b.timestamp));
        break;
      case 'rating_high':
        sortedFeedbacks.sort((a, b) => b.rating.compareTo(a.rating));
        break;
      case 'rating_low':
        sortedFeedbacks.sort((a, b) => a.rating.compareTo(b.rating));
        break;
      case 'helpful':
        sortedFeedbacks.sort((a, b) => b.helpfulCount.compareTo(a.helpfulCount));
        break;
    }

    return sortedFeedbacks;
  }

  void _showFeedbackForm(BuildContext context, FeedbackModel? existingFeedback) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: FeedbackSubmissionForm(
          projectId: widget.projectId,
          existingFeedback: existingFeedback,
          onSubmitted: () {
            _loadFeedbacks();
          },
        ),
      ),
    );
  }
}
