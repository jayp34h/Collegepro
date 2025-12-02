import 'package:flutter/material.dart';
import '../../../core/services/groq_service.dart';

class ResumeAnalysisWidget extends StatelessWidget {
  final ResumeAnalysis analysis;
  final VoidCallback? onDownloadResume;

  const ResumeAnalysisWidget({
    super.key,
    required this.analysis,
    this.onDownloadResume,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // ATS Score Card
        _buildATSScoreCard(context, theme),
        const SizedBox(height: 16),

        // Strengths & Weaknesses
        Row(
          children: [
            Expanded(child: _buildStrengthsCard(context, theme)),
            const SizedBox(width: 12),
            Expanded(child: _buildWeaknessesCard(context, theme)),
          ],
        ),
        const SizedBox(height: 16),

        // Keywords Analysis
        _buildKeywordsCard(context, theme),
        const SizedBox(height: 16),

        // Tailored Suggestions
        _buildSuggestionsCard(context, theme),
        const SizedBox(height: 16),

        // Download Button
        if (onDownloadResume != null)
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: onDownloadResume,
              icon: const Icon(Icons.download),
              label: const Text('Download Improved Resume'),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildATSScoreCard(BuildContext context, ThemeData theme) {
    final scoreColor = _getScoreColor(analysis.atsScore);
    
    return Container(
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
        children: [
          Text(
            'ATS Score',
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          
          // Circular Progress Indicator
          Stack(
            alignment: Alignment.center,
            children: [
              SizedBox(
                width: 120,
                height: 120,
                child: CircularProgressIndicator(
                  value: analysis.atsScore / 100,
                  strokeWidth: 12,
                  backgroundColor: Colors.grey[200],
                  valueColor: AlwaysStoppedAnimation<Color>(scoreColor),
                ),
              ),
              Column(
                children: [
                  Text(
                    '${analysis.atsScore}',
                    style: theme.textTheme.headlineLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: scoreColor,
                    ),
                  ),
                  Text(
                    'out of 100',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 16),
          
          Text(
            analysis.overallFeedback,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: Colors.grey[700],
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildStrengthsCard(BuildContext context, ThemeData theme) {
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
          Row(
            children: [
              Icon(Icons.thumb_up, color: Colors.green, size: 20),
              const SizedBox(width: 8),
              Text(
                'Strengths',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Colors.green,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ...analysis.strengths.map((strength) => Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(Icons.check_circle, color: Colors.green, size: 16),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    strength,
                    style: theme.textTheme.bodySmall,
                  ),
                ),
              ],
            ),
          )),
        ],
      ),
    );
  }

  Widget _buildWeaknessesCard(BuildContext context, ThemeData theme) {
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
          Row(
            children: [
              Icon(Icons.warning, color: Colors.orange, size: 20),
              const SizedBox(width: 8),
              Text(
                'Areas to Improve',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Colors.orange,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ...analysis.weaknesses.map((weakness) => Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(Icons.info, color: Colors.orange, size: 16),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    weakness,
                    style: theme.textTheme.bodySmall,
                  ),
                ),
              ],
            ),
          )),
        ],
      ),
    );
  }

  Widget _buildKeywordsCard(BuildContext context, ThemeData theme) {
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
            'Keyword Analysis',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          
          // Matched Keywords
          Text(
            'Found Keywords',
            style: theme.textTheme.titleSmall?.copyWith(
              color: Colors.green,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: analysis.keywordMatches.map((keyword) => Chip(
              label: Text(keyword),
              backgroundColor: Colors.green.withOpacity(0.1),
              labelStyle: TextStyle(color: Colors.green[700]),
              side: BorderSide(color: Colors.green.withOpacity(0.3)),
            )).toList(),
          ),
          
          const SizedBox(height: 16),
          
          // Missing Keywords
          Text(
            'Missing Keywords',
            style: theme.textTheme.titleSmall?.copyWith(
              color: Colors.red,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: analysis.missingKeywords.map((keyword) => Chip(
              label: Text(keyword),
              backgroundColor: Colors.red.withOpacity(0.1),
              labelStyle: TextStyle(color: Colors.red[700]),
              side: BorderSide(color: Colors.red.withOpacity(0.3)),
            )).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildSuggestionsCard(BuildContext context, ThemeData theme) {
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
          Row(
            children: [
              Icon(Icons.lightbulb, color: Colors.blue, size: 20),
              const SizedBox(width: 8),
              Text(
                'AI Recommendations',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Colors.blue,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ...analysis.tailoredSuggestions.asMap().entries.map((entry) => Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 24,
                  height: 24,
                  decoration: BoxDecoration(
                    color: Colors.blue.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Center(
                    child: Text(
                      '${entry.key + 1}',
                      style: TextStyle(
                        color: Colors.blue,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    entry.value,
                    style: theme.textTheme.bodyMedium,
                  ),
                ),
              ],
            ),
          )),
        ],
      ),
    );
  }

  Color _getScoreColor(int score) {
    if (score >= 80) return Colors.green;
    if (score >= 60) return Colors.orange;
    return Colors.red;
  }
}
