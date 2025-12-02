import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/models/feedback_model.dart';
import '../../../core/providers/feedback_provider.dart';
import '../../../core/providers/auth_provider.dart';

class FeedbackSubmissionForm extends StatefulWidget {
  final String projectId;
  final FeedbackModel? existingFeedback;
  final VoidCallback? onSubmitted;

  const FeedbackSubmissionForm({
    super.key,
    required this.projectId,
    this.existingFeedback,
    this.onSubmitted,
  });

  @override
  State<FeedbackSubmissionForm> createState() => _FeedbackSubmissionFormState();
}

class _FeedbackSubmissionFormState extends State<FeedbackSubmissionForm> {
  final _formKey = GlobalKey<FormState>();
  final _feedbackController = TextEditingController();
  final _tagsController = TextEditingController();
  
  double _rating = 5.0;
  String _selectedCategory = 'general';
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    if (widget.existingFeedback != null) {
      _feedbackController.text = widget.existingFeedback!.feedback;
      _rating = widget.existingFeedback!.rating;
      _selectedCategory = widget.existingFeedback!.category;
      _tagsController.text = widget.existingFeedback!.tags.join(', ');
    }
  }

  @override
  void dispose() {
    _feedbackController.dispose();
    _tagsController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header
            Row(
              children: [
                Icon(
                  Icons.feedback_outlined,
                  color: Theme.of(context).primaryColor,
                  size: 24,
                ),
                const SizedBox(width: 8),
                Text(
                  widget.existingFeedback != null ? 'Edit Feedback' : 'Share Your Feedback',
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Spacer(),
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.close),
                ),
              ],
            ),
            const SizedBox(height: 20),

            // Rating Section
            Text(
              'Overall Rating',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.grey[800],
              ),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: Slider(
                    value: _rating,
                    min: 1.0,
                    max: 5.0,
                    divisions: 8,
                    label: _rating.toStringAsFixed(1),
                    onChanged: (value) {
                      setState(() {
                        _rating = value;
                      });
                    },
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: Theme.of(context).primaryColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.star,
                        color: Colors.amber,
                        size: 16,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        _rating.toStringAsFixed(1),
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).primaryColor,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),

            // Category Selection
            Text(
              'Feedback Category',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.grey[800],
              ),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: FeedbackCategory.values.map((category) {
                final isSelected = _selectedCategory == category.name;
                return GestureDetector(
                  onTap: () {
                    setState(() {
                      _selectedCategory = category.name;
                    });
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      color: isSelected 
                          ? Theme.of(context).primaryColor 
                          : Colors.grey[100],
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: isSelected 
                            ? Theme.of(context).primaryColor 
                            : Colors.grey[300]!,
                      ),
                    ),
                    child: Text(
                      category.displayName,
                      style: TextStyle(
                        color: isSelected ? Colors.white : Colors.grey[700],
                        fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                        fontSize: 12,
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 20),

            // Feedback Text
            Text(
              'Your Feedback',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.grey[800],
              ),
            ),
            const SizedBox(height: 8),
            TextFormField(
              controller: _feedbackController,
              maxLines: 5,
              decoration: InputDecoration(
                hintText: 'Share your thoughts, suggestions, or advice about this project...',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Theme.of(context).primaryColor),
                ),
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Please enter your feedback';
                }
                if (value.trim().length < 10) {
                  return 'Feedback must be at least 10 characters long';
                }
                return null;
              },
            ),
            const SizedBox(height: 20),

            // Tags
            Text(
              'Tags (Optional)',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.grey[800],
              ),
            ),
            const SizedBox(height: 8),
            TextFormField(
              controller: _tagsController,
              decoration: InputDecoration(
                hintText: 'e.g., innovative, well-documented, needs-improvement',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Theme.of(context).primaryColor),
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Submit Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _isSubmitting ? null : _submitFeedback,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Theme.of(context).primaryColor,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: _isSubmitting
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                        ),
                      )
                    : Text(
                        widget.existingFeedback != null ? 'Update Feedback' : 'Submit Feedback',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _submitFeedback() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isSubmitting = true;
    });

    try {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final feedbackProvider = Provider.of<FeedbackProvider>(context, listen: false);
      
      if (authProvider.user == null) {
        _showErrorSnackBar('Please login to submit feedback');
        return;
      }

      final tags = _tagsController.text
          .split(',')
          .map((tag) => tag.trim())
          .where((tag) => tag.isNotEmpty)
          .toList();

      final feedback = FeedbackModel(
        id: widget.existingFeedback?.id ?? DateTime.now().millisecondsSinceEpoch.toString(),
        projectId: widget.projectId,
        userId: authProvider.user!.uid,
        userName: authProvider.user!.displayName ?? 'Anonymous',
        userEmail: authProvider.user!.email ?? '',
        feedback: _feedbackController.text.trim(),
        rating: _rating,
        category: _selectedCategory,
        timestamp: DateTime.now(),
        tags: tags,
        helpfulCount: widget.existingFeedback?.helpfulCount ?? 0,
        helpfulUsers: widget.existingFeedback?.helpfulUsers ?? [],
      );

      bool success;
      if (widget.existingFeedback != null) {
        success = await feedbackProvider.updateFeedback(feedback);
      } else {
        success = await feedbackProvider.submitFeedback(feedback);
      }

      if (success) {
        Navigator.pop(context);
        _showSuccessSnackBar(
          widget.existingFeedback != null 
              ? 'Feedback updated successfully!' 
              : 'Thank you for your feedback!'
        );
        widget.onSubmitted?.call();
      } else {
        _showErrorSnackBar('Failed to submit feedback. Please try again.');
      }
    } catch (e) {
      _showErrorSnackBar('An error occurred: $e');
    } finally {
      setState(() {
        _isSubmitting = false;
      });
    }
  }

  void _showSuccessSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.green,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
}
