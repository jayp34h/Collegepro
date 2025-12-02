import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/community_doubts_provider.dart';
import '../models/doubt_model.dart';
import '../../../core/providers/auth_provider.dart';

class PostDoubtDialog extends StatefulWidget {
  const PostDoubtDialog({super.key});

  @override
  State<PostDoubtDialog> createState() => _PostDoubtDialogState();
}

class _PostDoubtDialogState extends State<PostDoubtDialog> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  
  String _selectedSubject = 'Computer Science';
  String _selectedDifficulty = 'Medium';
  bool _isUrgent = false;
  List<String> _selectedTags = [];
  bool _isPosting = false;

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Container(
        constraints: const BoxConstraints(maxWidth: 500, maxHeight: 600),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildHeader(),
            Flexible(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildTitleField(),
                      const SizedBox(height: 16),
                      _buildDescriptionField(),
                      const SizedBox(height: 16),
                      _buildSubjectDropdown(),
                      const SizedBox(height: 16),
                      _buildDifficultyDropdown(),
                      const SizedBox(height: 16),
                      _buildTagsSection(),
                      const SizedBox(height: 16),
                      _buildUrgentCheckbox(),
                      const SizedBox(height: 24),
                      _buildActionButtons(),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: const BoxDecoration(
        color: Color(0xFF6366F1),
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(16),
          topRight: Radius.circular(16),
        ),
      ),
      child: Row(
        children: [
          const Icon(
            Icons.help_outline,
            color: Colors.white,
            size: 24,
          ),
          const SizedBox(width: 12),
          const Text(
            'Ask a Question',
            style: TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const Spacer(),
          IconButton(
            onPressed: () => Navigator.pop(context),
            icon: const Icon(Icons.close, color: Colors.white),
          ),
        ],
      ),
    );
  }

  Widget _buildTitleField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Question Title *',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: _titleController,
          decoration: InputDecoration(
            hintText: 'What\'s your question?',
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: Color(0xFF6366F1)),
            ),
          ),
          validator: (value) {
            if (value == null || value.trim().isEmpty) {
              return 'Please enter a question title';
            }
            if (value.trim().length < 10) {
              return 'Title must be at least 10 characters';
            }
            return null;
          },
          maxLines: 2,
        ),
      ],
    );
  }

  Widget _buildDescriptionField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Description *',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: _descriptionController,
          decoration: InputDecoration(
            hintText: 'Provide more details about your question...',
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: Color(0xFF6366F1)),
            ),
          ),
          validator: (value) {
            if (value == null || value.trim().isEmpty) {
              return 'Please provide a description';
            }
            if (value.trim().length < 20) {
              return 'Description must be at least 20 characters';
            }
            return null;
          },
          maxLines: 4,
        ),
      ],
    );
  }

  Widget _buildSubjectDropdown() {
    final provider = context.read<CommunityDoubtsProvider>();
    final subjects = provider.getAvailableSubjects();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Subject *',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        DropdownButtonFormField<String>(
          value: _selectedSubject,
          decoration: InputDecoration(
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: Color(0xFF6366F1)),
            ),
          ),
          items: subjects.map((subject) {
            return DropdownMenuItem(
              value: subject,
              child: Text(subject),
            );
          }).toList(),
          onChanged: (value) {
            setState(() {
              _selectedSubject = value!;
            });
          },
        ),
      ],
    );
  }

  Widget _buildDifficultyDropdown() {
    final provider = context.read<CommunityDoubtsProvider>();
    final difficulties = provider.getAvailableDifficulties();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Difficulty Level *',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        DropdownButtonFormField<String>(
          value: _selectedDifficulty,
          decoration: InputDecoration(
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: Color(0xFF6366F1)),
            ),
          ),
          items: difficulties.map((difficulty) {
            return DropdownMenuItem(
              value: difficulty,
              child: Row(
                children: [
                  Icon(
                    _getDifficultyIcon(difficulty),
                    color: _getDifficultyColor(difficulty),
                    size: 16,
                  ),
                  const SizedBox(width: 8),
                  Text(difficulty),
                ],
              ),
            );
          }).toList(),
          onChanged: (value) {
            setState(() {
              _selectedDifficulty = value!;
            });
          },
        ),
      ],
    );
  }

  Widget _buildTagsSection() {
    final provider = context.read<CommunityDoubtsProvider>();
    final availableTags = provider.getAvailableTags();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Tags (Optional)',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Select up to 5 tags that best describe your question',
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey[600],
          ),
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: availableTags.map((tag) {
            final isSelected = _selectedTags.contains(tag);
            return FilterChip(
              label: Text(tag),
              selected: isSelected,
              onSelected: _selectedTags.length >= 5 && !isSelected
                  ? null
                  : (selected) {
                      setState(() {
                        if (selected) {
                          _selectedTags.add(tag);
                        } else {
                          _selectedTags.remove(tag);
                        }
                      });
                    },
              selectedColor: const Color(0xFF6366F1).withOpacity(0.2),
              checkmarkColor: const Color(0xFF6366F1),
              labelStyle: TextStyle(
                color: isSelected ? const Color(0xFF6366F1) : Colors.grey[700],
                fontWeight: isSelected ? FontWeight.w500 : FontWeight.normal,
                fontSize: 12,
              ),
            );
          }).toList(),
        ),
        if (_selectedTags.length >= 5)
          Padding(
            padding: const EdgeInsets.only(top: 8),
            child: Text(
              'Maximum 5 tags allowed',
              style: TextStyle(
                fontSize: 12,
                color: Colors.orange[700],
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildUrgentCheckbox() {
    return Row(
      children: [
        Checkbox(
          value: _isUrgent,
          onChanged: (value) {
            setState(() {
              _isUrgent = value ?? false;
            });
          },
          activeColor: const Color(0xFF6366F1),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Mark as Urgent',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
              Text(
                'Urgent questions get priority visibility',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[600],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildActionButtons() {
    return Row(
      children: [
        Expanded(
          child: OutlinedButton(
            onPressed: _isPosting ? null : () => Navigator.pop(context),
            style: OutlinedButton.styleFrom(
              side: const BorderSide(color: Color(0xFF6366F1)),
              foregroundColor: const Color(0xFF6366F1),
              padding: const EdgeInsets.symmetric(vertical: 12),
            ),
            child: const Text('Cancel'),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: ElevatedButton(
            onPressed: _isPosting ? null : _postDoubt,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF6366F1),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 12),
            ),
            child: _isPosting
                ? const SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  )
                : const Text('Post Question'),
          ),
        ),
      ],
    );
  }

  IconData _getDifficultyIcon(String difficulty) {
    switch (difficulty.toLowerCase()) {
      case 'easy':
        return Icons.sentiment_satisfied;
      case 'medium':
        return Icons.sentiment_neutral;
      case 'hard':
        return Icons.sentiment_very_dissatisfied;
      default:
        return Icons.help;
    }
  }

  Color _getDifficultyColor(String difficulty) {
    switch (difficulty.toLowerCase()) {
      case 'easy':
        return Colors.green;
      case 'medium':
        return Colors.orange;
      case 'hard':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  Future<void> _postDoubt() async {
    if (!_formKey.currentState!.validate()) return;

    final authProvider = context.read<AuthProvider>();
    if (authProvider.user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please log in to post a question'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() {
      _isPosting = true;
    });

    final doubt = CommunityDoubt(
      id: '', // Will be set by Firebase
      userId: authProvider.user!.uid,
      userName: authProvider.user?.displayName ?? 'Anonymous',
      userAvatar: authProvider.user?.photoURL ?? '',
      title: _titleController.text.trim(),
      description: _descriptionController.text.trim(),
      subject: _selectedSubject,
      difficulty: _selectedDifficulty,
      tags: _selectedTags,
      timestamp: DateTime.now(),
      createdAt: DateTime.now(),
      isUrgent: _isUrgent,
    );

    try {
      final provider = context.read<CommunityDoubtsProvider>();
      final success = await provider.postDoubt(doubt);

      if (success) {
        if (mounted) {
          Navigator.pop(context);
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Question posted successfully!'),
              backgroundColor: Colors.green,
            ),
          );
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(provider.error ?? 'Failed to post question'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isPosting = false;
        });
      }
    }
  }
}
