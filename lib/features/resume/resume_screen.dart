import 'package:flutter/material.dart';
import 'dart:io';
import '../../core/services/ocr_service.dart';
import '../../core/services/resume_feedback_service.dart';
import '../../core/widgets/gradient_app_bar.dart';
import '../../core/widgets/drawer_screen_wrapper.dart';
import '../../core/utils/file_utils.dart';
import 'widgets/resume_feedback_widget.dart';
import 'widgets/resume_upload_widget.dart';

class ResumeScreen extends StatefulWidget {
  const ResumeScreen({super.key});

  @override
  State<ResumeScreen> createState() => _ResumeScreenState();
}

class _ResumeScreenState extends State<ResumeScreen> {
  ResumeFeedback? _feedback;
  bool _isAnalyzing = false;
  String? _uploadedFileName;
  String _selectedRole = 'Software Developer';
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    
    return DrawerScreenWrapper(
      title: 'Resume Builder',
      child: Scaffold(
      backgroundColor: isDark ? const Color(0xFF0F0F0F) : const Color(0xFFF8F9FA),
      appBar: const GradientAppBar(
        title: 'AI Resume Optimizer',
        titleIcon: Icons.auto_awesome,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header Card
            Container(
              width: double.infinity,
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
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.blue.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(
                          Icons.auto_awesome,
                          color: Colors.blue,
                          size: 28,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'AI-Powered Resume Analysis',
                              style: theme.textTheme.titleLarge?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Upload your resume and get personalized improvement feedback',
                              style: theme.textTheme.bodyMedium?.copyWith(
                                color: Colors.grey[600],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 24),
            
            // Role Selection
            _buildRoleSelector(context, theme),
            
            const SizedBox(height: 24),
            
            // Upload Widget
            ResumeUploadWidget(
              onFileSelected: _handleFileUpload,
              uploadedFileName: _uploadedFileName,
              isLoading: _isAnalyzing,
            ),
            
            const SizedBox(height: 24),
            
            // Feedback Results
            if (_feedback != null) ...[
              Text(
                'Resume Feedback',
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              ResumeFeedbackWidget(
                feedback: _feedback!,
              ),
            ],
            
            // Features Info
            if (_feedback == null) ...[
              const SizedBox(height: 24),
              _buildFeaturesInfo(context, theme),
            ],
          ],
        ),
      ),
    ),
    );
  }

  Widget _buildRoleSelector(BuildContext context, ThemeData theme) {
    final roles = [
      'Software Developer',
      'Data Scientist',
      'Product Manager',
      'UI/UX Designer',
      'DevOps Engineer',
      'Business Analyst',
      'Marketing Manager',
      'Sales Representative',
    ];

    return Container(
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
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Target Role',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          DropdownButtonFormField<String>(
            value: _selectedRole,
            decoration: InputDecoration(
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            ),
            items: roles.map((role) => DropdownMenuItem(
              value: role,
              child: Text(role),
            )).toList(),
            onChanged: (value) {
              if (value != null) {
                setState(() {
                  _selectedRole = value;
                });
              }
            },
          ),
        ],
      ),
    );
  }

  Widget _buildFeaturesInfo(BuildContext context, ThemeData theme) {
    final features = [
      {
        'icon': Icons.feedback,
        'title': 'Genuine Feedback',
        'description': 'Get honest, constructive feedback on your resume',
        'color': Colors.blue,
      },
      {
        'icon': Icons.error_outline,
        'title': 'Mistake Identification',
        'description': 'Identify specific areas that need improvement',
        'color': Colors.red,
      },
      {
        'icon': Icons.lightbulb,
        'title': 'Actionable Suggestions',
        'description': 'Receive specific steps to improve your resume',
        'color': Colors.orange,
      },
      {
        'icon': Icons.work_outline,
        'title': 'Role-Specific Advice',
        'description': 'Get advice tailored to your target job role',
        'color': Colors.green,
      },
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Features',
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        ...features.map((feature) => Container(
          margin: const EdgeInsets.only(bottom: 12),
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
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: (feature['color'] as Color).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  feature['icon'] as IconData,
                  color: feature['color'] as Color,
                  size: 24,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      feature['title'] as String,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      feature['description'] as String,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        )),
      ],
    );
  }

  Future<void> _handleFileUpload(File file, String fileName) async {
    // Validate file first
    if (!FileUtils.isValidResumeFile(file)) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Invalid file. Please upload PDF, DOCX, or DOC files under 10MB.'),
            backgroundColor: Colors.red,
          ),
        );
      }
      return;
    }

    if (mounted) {
      setState(() {
        _uploadedFileName = fileName;
        _isAnalyzing = true;
        _feedback = null;
      });
    }

    try {
      // Show file info
      final fileSize = FileUtils.getFileSizeString(file);
      final fileIcon = FileUtils.getFileTypeIcon(fileName);
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('$fileIcon Uploading $fileName ($fileSize)...'),
            backgroundColor: Colors.blue,
            duration: const Duration(seconds: 2),
          ),
        );
      }

      // Extract text from resume using OCR.space API
      final resumeText = await OCRService.extractTextFromResume(file);
      
      // Validate extracted text
      if (!OCRService.isValidResumeText(resumeText)) {
        throw Exception('The uploaded file does not appear to contain a valid resume');
      }
      
      // Generate feedback using OpenRouter API
      final feedback = await ResumeFeedbackService.generateResumeFeedback(resumeText, _selectedRole);
      
      if (mounted) {
        setState(() {
          _feedback = feedback;
          _isAnalyzing = false;
        });
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Row(
              children: [
                Icon(Icons.check_circle, color: Colors.white),
                SizedBox(width: 8),
                Expanded(
                  child: Text('Resume feedback generated successfully!'),
                ),
              ],
            ),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 3),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isAnalyzing = false;
        });
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.error, color: Colors.white),
                const SizedBox(width: 8),
                Expanded(
                  child: Text('Failed to analyze resume: ${e.toString().replaceAll('Exception: ', '')}'),
                ),
              ],
            ),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 4),
          ),
        );
      }
    }
  }



}
