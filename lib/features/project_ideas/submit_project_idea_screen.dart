import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/providers/auth_provider.dart';
import '../../core/models/project_idea_model.dart';
import 'services/project_ideas_service.dart';

class SubmitProjectIdeaScreen extends StatefulWidget {
  const SubmitProjectIdeaScreen({super.key});

  @override
  State<SubmitProjectIdeaScreen> createState() => _SubmitProjectIdeaScreenState();
}

class _SubmitProjectIdeaScreenState extends State<SubmitProjectIdeaScreen>
    with TickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _problemStatementController = TextEditingController();
  final _techStackController = TextEditingController();
  final _expectedOutcomesController = TextEditingController();
  
  String _selectedDomain = 'Web Development';
  String _selectedDifficulty = 'Beginner';
  String _selectedDuration = '1-2 weeks';
  bool _isSubmitting = false;

  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  final List<String> _domains = [
    'Web Development',
    'Mobile Development',
    'Machine Learning',
    'Data Science',
    'Artificial Intelligence',
    'Blockchain',
    'IoT',
    'Game Development',
    'Desktop Applications',
    'DevOps',
    'Cybersecurity',
    'Cloud Computing',
    'Other',
  ];

  final List<String> _difficulties = [
    'Beginner',
    'Intermediate',
    'Advanced',
    'Expert',
  ];

  final List<String> _durations = [
    '1-2 weeks',
    '3-4 weeks',
    '1-2 months',
    '3-6 months',
    '6+ months',
  ];

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    _titleController.dispose();
    _descriptionController.dispose();
    _problemStatementController.dispose();
    _techStackController.dispose();
    _expectedOutcomesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: _buildAppBar(),
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildHeaderCard(),
                const SizedBox(height: 24),
                _buildFormCard(),
                const SizedBox(height: 24),
                _buildSubmitButton(),
                const SizedBox(height: 32),
              ],
            ),
          ),
        ),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      elevation: 0,
      backgroundColor: Colors.transparent,
      flexibleSpace: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFF8B5CF6),
              Color(0xFFA855F7),
            ],
          ),
        ),
      ),
      leading: IconButton(
        onPressed: () => Navigator.of(context).pop(),
        icon: const Icon(Icons.arrow_back, color: Colors.white),
      ),
      title: const Text(
        'Share Your Project Idea',
        style: TextStyle(
          color: Colors.white,
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
      ),
      centerTitle: true,
    );
  }

  Widget _buildHeaderCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.blue.shade50,
            Colors.purple.shade50,
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Colors.blue.shade100,
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.blue.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Colors.purple.shade400, Colors.blue.shade400],
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.lightbulb,
                  color: Colors.white,
                  size: 24,
                ),
              ),
              const SizedBox(width: 16),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Share Your Innovation',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF2d2d2d),
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      'Help fellow students discover amazing project ideas',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.amber.shade50,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.amber.shade200),
            ),
            child: Row(
              children: [
                Icon(Icons.info_outline, color: Colors.amber.shade700, size: 20),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Your idea will be reviewed before being visible to other students',
                    style: TextStyle(
                      color: Colors.amber.shade700,
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFormCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildTextField(
            controller: _titleController,
            label: 'Project Title',
            hint: 'Enter a catchy title for your project idea',
            icon: Icons.title,
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return 'Please enter a project title';
              }
              if (value.trim().length < 5) {
                return 'Title must be at least 5 characters long';
              }
              return null;
            },
          ),
          const SizedBox(height: 20),
          _buildTextField(
            controller: _descriptionController,
            label: 'Project Description',
            hint: 'Describe your project idea in detail',
            icon: Icons.description,
            maxLines: 4,
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return 'Please enter a project description';
              }
              if (value.trim().length < 20) {
                return 'Description must be at least 20 characters long';
              }
              return null;
            },
          ),
          const SizedBox(height: 20),
          LayoutBuilder(
            builder: (context, constraints) {
              if (constraints.maxWidth < 600) {
                // Mobile layout - stack vertically
                return Column(
                  children: [
                    _buildDropdownField(
                      label: 'Domain',
                      value: _selectedDomain,
                      items: _domains,
                      onChanged: (value) => setState(() => _selectedDomain = value!),
                      icon: Icons.category,
                    ),
                    const SizedBox(height: 16),
                    _buildDropdownField(
                      label: 'Difficulty',
                      value: _selectedDifficulty,
                      items: _difficulties,
                      onChanged: (value) => setState(() => _selectedDifficulty = value!),
                      icon: Icons.trending_up,
                    ),
                  ],
                );
              } else {
                // Desktop layout - side by side
                return Row(
                  children: [
                    Expanded(
                      child: _buildDropdownField(
                        label: 'Domain',
                        value: _selectedDomain,
                        items: _domains,
                        onChanged: (value) => setState(() => _selectedDomain = value!),
                        icon: Icons.category,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: _buildDropdownField(
                        label: 'Difficulty',
                        value: _selectedDifficulty,
                        items: _difficulties,
                        onChanged: (value) => setState(() => _selectedDifficulty = value!),
                        icon: Icons.trending_up,
                      ),
                    ),
                  ],
                );
              }
            },
          ),
          const SizedBox(height: 20),
          _buildDropdownField(
            label: 'Estimated Duration',
            value: _selectedDuration,
            items: _durations,
            onChanged: (value) => setState(() => _selectedDuration = value!),
            icon: Icons.schedule,
          ),
          const SizedBox(height: 20),
          _buildTextField(
            controller: _problemStatementController,
            label: 'Problem Statement',
            hint: 'What problem does this project solve?',
            icon: Icons.help_outline,
            maxLines: 3,
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return 'Please enter the problem statement';
              }
              return null;
            },
          ),
          const SizedBox(height: 20),
          _buildTextField(
            controller: _techStackController,
            label: 'Technology Stack',
            hint: 'e.g., React, Node.js, MongoDB, Python (comma-separated)',
            icon: Icons.code,
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return 'Please enter the technology stack';
              }
              return null;
            },
          ),
          const SizedBox(height: 20),
          _buildTextField(
            controller: _expectedOutcomesController,
            label: 'Expected Outcomes',
            hint: 'What will students learn/achieve? (one per line)',
            icon: Icons.emoji_events,
            maxLines: 4,
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return 'Please enter expected outcomes';
              }
              return null;
            },
          ),
        ],
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    int maxLines = 1,
    String? Function(String?)? validator,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, size: 20, color: Colors.purple[600]),
            const SizedBox(width: 8),
            Text(
              label,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.grey[800],
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          maxLines: maxLines,
          validator: validator,
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: TextStyle(color: Colors.grey[400]),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey[300]!),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey[300]!),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.purple[400]!, width: 2),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Colors.red, width: 2),
            ),
            contentPadding: const EdgeInsets.all(16),
            filled: true,
            fillColor: Colors.grey[50],
          ),
        ),
      ],
    );
  }

  Widget _buildDropdownField({
    required String label,
    required String value,
    required List<String> items,
    required void Function(String?) onChanged,
    required IconData icon,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, size: 20, color: Colors.purple[600]),
            const SizedBox(width: 8),
            Text(
              label,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.grey[800],
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        DropdownButtonFormField<String>(
          value: value,
          onChanged: onChanged,
          decoration: InputDecoration(
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey[300]!),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey[300]!),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.purple[400]!, width: 2),
            ),
            contentPadding: const EdgeInsets.all(16),
            filled: true,
            fillColor: Colors.grey[50],
          ),
          items: items.map((String item) {
            return DropdownMenuItem<String>(
              value: item,
              child: Text(item),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildSubmitButton() {
    return Container(
      width: double.infinity,
      height: 56,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        gradient: const LinearGradient(
          colors: [
            Color(0xFF8B5CF6),
            Color(0xFFA855F7),
          ],
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF8B5CF6).withOpacity(0.3),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: ElevatedButton(
        onPressed: _isSubmitting ? null : _submitProjectIdea,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          shadowColor: Colors.transparent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
        child: _isSubmitting
            ? const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  ),
                  SizedBox(width: 12),
                  Text(
                    'Submitting...',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              )
            : const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.send, color: Colors.white),
                  SizedBox(width: 8),
                  Text(
                    'Submit Project Idea',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
      ),
    );
  }

  Future<void> _submitProjectIdea() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final user = authProvider.userModel;

    if (user == null) {
      _showErrorSnackBar('Please log in to submit a project idea');
      return;
    }

    setState(() {
      _isSubmitting = true;
    });

    try {
      // Parse tech stack and expected outcomes
      final techStack = _techStackController.text
          .split(',')
          .map((e) => e.trim())
          .where((e) => e.isNotEmpty)
          .toList();

      final expectedOutcomes = _expectedOutcomesController.text
          .split('\n')
          .map((e) => e.trim())
          .where((e) => e.isNotEmpty)
          .toList();

      final projectIdea = ProjectIdeaModel(
        id: '', // Will be generated by service
        title: _titleController.text.trim(),
        description: _descriptionController.text.trim(),
        domain: _selectedDomain,
        difficulty: _selectedDifficulty,
        techStack: techStack,
        problemStatement: _problemStatementController.text.trim(),
        expectedOutcomes: expectedOutcomes,
        estimatedDuration: _selectedDuration,
        authorId: user.id,
        authorName: user.displayName,
        authorEmail: user.email,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      final ideaId = await ProjectIdeasService.submitProjectIdea(projectIdea);

      if (ideaId != null) {
        _showSuccessDialog();
      } else {
        _showErrorSnackBar('Failed to submit project idea. Please try again.');
      }
    } catch (e) {
      _showErrorSnackBar('An error occurred: ${e.toString()}');
    } finally {
      setState(() {
        _isSubmitting = false;
      });
    }
  }

  void _showSuccessDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.green.shade50,
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.check_circle,
                color: Colors.green.shade600,
                size: 48,
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'Success!',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Your project idea has been submitted successfully. It will be reviewed and made visible to other students soon.',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop(); // Close dialog
              Navigator.of(context).pop(); // Go back to dashboard
            },
            child: const Text('Great!'),
          ),
        ],
      ),
    );
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.error, color: Colors.white),
            const SizedBox(width: 8),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: Colors.red[600],
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }
}
