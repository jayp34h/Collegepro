import 'package:flutter/material.dart';
import '../../../core/services/resume_feedback_service.dart';

class ResumeFeedbackWidget extends StatelessWidget {
  final ResumeFeedback feedback;

  const ResumeFeedbackWidget({
    super.key,
    required this.feedback,
  });

  @override
  Widget build(BuildContext context) {

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Overall Summary
        _buildSectionCard(
          context,
          'Overall Summary',
          Icons.summarize,
          Colors.blue,
          [feedback.overallSummary],
          isExpanded: true,
        ),
        
        const SizedBox(height: 16),
        
        // Strengths
        _buildSectionCard(
          context,
          'Strengths',
          Icons.thumb_up,
          Colors.green,
          feedback.strengths,
        ),
        
        const SizedBox(height: 16),
        
        // Critical Mistakes
        _buildSectionCard(
          context,
          'Critical Mistakes',
          Icons.error_outline,
          Colors.red,
          feedback.criticalMistakes,
        ),
        
        const SizedBox(height: 16),
        
        // Improvement Areas
        _buildSectionCard(
          context,
          'Areas for Improvement',
          Icons.trending_up,
          Colors.orange,
          feedback.improvementAreas,
        ),
        
        const SizedBox(height: 16),
        
        // Specific Suggestions
        _buildSectionCard(
          context,
          'Specific Suggestions',
          Icons.lightbulb_outline,
          Colors.amber,
          feedback.specificSuggestions,
        ),
        
        const SizedBox(height: 16),
        
        // Content Gaps
        _buildSectionCard(
          context,
          'Missing Content',
          Icons.add_circle_outline,
          Colors.purple,
          feedback.contentGaps,
        ),
        
        const SizedBox(height: 16),
        
        // Formatting Issues
        if (feedback.formattingIssues.isNotEmpty) ...[
          _buildSectionCard(
            context,
            'Formatting Issues',
            Icons.format_align_left,
            Colors.indigo,
            feedback.formattingIssues,
          ),
          const SizedBox(height: 16),
        ],
        
        // Role-Specific Advice
        _buildSectionCard(
          context,
          'Role-Specific Advice',
          Icons.work_outline,
          Colors.teal,
          [feedback.roleSpecificAdvice],
          isExpanded: true,
        ),
        
        const SizedBox(height: 16),
        
        // Next Steps
        _buildSectionCard(
          context,
          'Next Steps',
          Icons.checklist,
          Colors.cyan,
          feedback.nextSteps,
        ),
      ],
    );
  }

  Widget _buildSectionCard(
    BuildContext context,
    String title,
    IconData icon,
    Color color,
    List<String> items, {
    bool isExpanded = false,
  }) {

    return Card(
      elevation: 2,
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: ExpansionTile(
        initiallyExpanded: isExpanded,
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            icon,
            color: color,
            size: 20,
          ),
        ),
        title: Text(
          title,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        subtitle: Text(
          '${items.length} ${items.length == 1 ? 'item' : 'items'}',
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: Colors.grey[600],
          ),
        ),
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: items.map((item) => Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      margin: const EdgeInsets.only(top: 6),
                      width: 6,
                      height: 6,
                      decoration: BoxDecoration(
                        color: color,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        item,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          height: 1.5,
                        ),
                      ),
                    ),
                  ],
                ),
              )).toList(),
            ),
          ),
        ],
      ),
    );
  }
}
