import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/ai_interview_provider.dart';

class FeedbackDisplayWidget extends StatelessWidget {
  const FeedbackDisplayWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<AIInterviewProvider>(
      builder: (context, provider, child) {
        final feedback = provider.currentFeedback;
        
        if (feedback == null) {
          return const SizedBox.shrink();
        }

        return Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.1),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.white.withOpacity(0.2)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildFeedbackHeader(feedback),
              const SizedBox(height: 20),
              _buildScoreCards(feedback),
              const SizedBox(height: 20),
              _buildFeedbackText(feedback),
              const SizedBox(height: 20),
              _buildStrengthsAndWeaknesses(feedback),
              const SizedBox(height: 20),
              _buildImprovementTips(feedback),
            ],
          ),
        );
      },
    );
  }

  Widget _buildFeedbackHeader(feedback) {
    return Row(
      children: [
        Container(
          width: 50,
          height: 50,
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFF667eea), Color(0xFF764ba2)],
            ),
            borderRadius: BorderRadius.circular(25),
          ),
          child: const Icon(
            Icons.psychology,
            color: Colors.white,
            size: 24,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Arya\'s Feedback',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 4),
              Row(
                children: [
                  Icon(
                    Icons.star,
                    size: 16,
                    color: _getScoreColor(feedback.overallScore),
                  ),
                  const SizedBox(width: 4),
                  Text(
                    '${feedback.overallScore.toStringAsFixed(1)}/10',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: _getScoreColor(feedback.overallScore),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    _getScoreLabel(feedback.overallScore),
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.white.withOpacity(0.7),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildScoreCards(feedback) {
    final scores = [
      {'label': 'Correctness', 'score': feedback.correctnessScore, 'icon': Icons.check_circle},
      {'label': 'Clarity', 'score': feedback.clarityScore, 'icon': Icons.visibility},
      {'label': 'Confidence', 'score': feedback.confidenceScore, 'icon': Icons.psychology},
      {'label': 'Fluency', 'score': feedback.fluencyScore, 'icon': Icons.record_voice_over},
    ];

    return Row(
      children: scores.map((scoreData) {
        return Expanded(
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 4),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.white.withOpacity(0.2)),
            ),
            child: Column(
              children: [
                Icon(
                  scoreData['icon'] as IconData,
                  color: _getScoreColor(scoreData['score'] as double),
                  size: 20,
                ),
                const SizedBox(height: 6),
                Text(
                  (scoreData['score'] as double).toStringAsFixed(1),
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: _getScoreColor(scoreData['score'] as double),
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  scoreData['label'] as String,
                  style: TextStyle(
                    fontSize: 10,
                    color: Colors.white.withOpacity(0.7),
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildFeedbackText(feedback) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white.withOpacity(0.1)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Detailed Feedback:',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Colors.white.withOpacity(0.9),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            feedback.feedback,
            style: TextStyle(
              fontSize: 15,
              color: Colors.white.withOpacity(0.8),
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStrengthsAndWeaknesses(feedback) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (feedback.strengths.isNotEmpty)
          Expanded(
            child: _buildFeedbackSection(
              title: 'Strengths',
              items: feedback.strengths,
              color: Colors.green,
              icon: Icons.thumb_up,
            ),
          ),
        if (feedback.strengths.isNotEmpty && feedback.weaknesses.isNotEmpty)
          const SizedBox(width: 12),
        if (feedback.weaknesses.isNotEmpty)
          Expanded(
            child: _buildFeedbackSection(
              title: 'Areas to Improve',
              items: feedback.weaknesses,
              color: Colors.orange,
              icon: Icons.trending_up,
            ),
          ),
      ],
    );
  }

  Widget _buildFeedbackSection({
    required String title,
    required List<String> items,
    required Color color,
    required IconData icon,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        // Enhanced background with better contrast
        color: Colors.white.withOpacity(0.15),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.4), width: 1.5),
        // Add subtle shadow for better definition
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
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
              Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Icon(icon, color: color, size: 16),
              ),
              const SizedBox(width: 8),
              Text(
                title,
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  color: color,
                  // Add text shadow for better visibility
                  shadows: [
                    Shadow(
                      color: Colors.black.withOpacity(0.5),
                      offset: const Offset(0, 1),
                      blurRadius: 2,
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ...items.map((item) => Padding(
            padding: const EdgeInsets.only(bottom: 6),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 6,
                  height: 6,
                  margin: const EdgeInsets.only(top: 6, right: 10),
                  decoration: BoxDecoration(
                    color: color,
                    shape: BoxShape.circle,
                  ),
                ),
                Expanded(
                  child: Text(
                    item,
                    style: const TextStyle(
                      fontSize: 14,
                      color: Colors.white,
                      fontWeight: FontWeight.w500,
                      height: 1.4,
                      // Add text shadow for better readability
                      shadows: [
                        Shadow(
                          color: Colors.black54,
                          offset: Offset(0, 1),
                          blurRadius: 2,
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          )),
        ],
      ),
    );
  }

  Widget _buildImprovementTips(feedback) {
    if (feedback.improvementTips.isEmpty) return const SizedBox.shrink();

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF667eea).withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFF667eea).withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.lightbulb,
                color: const Color(0xFF667eea),
                size: 16,
              ),
              const SizedBox(width: 6),
              const Text(
                'Improvement Tips',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF667eea),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ...feedback.improvementTips.asMap().entries.map((entry) {
            final index = entry.key;
            final tip = entry.value;
            return Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 20,
                    height: 20,
                    margin: const EdgeInsets.only(right: 12),
                    decoration: BoxDecoration(
                      color: const Color(0xFF667eea).withOpacity(0.2),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Center(
                      child: Text(
                        '${index + 1}',
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF667eea),
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                    child: Text(
                      tip,
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.white.withOpacity(0.8),
                        height: 1.4,
                      ),
                    ),
                  ),
                ],
              ),
            );
          }),
          const SizedBox(height: 20),
          Consumer<AIInterviewProvider>(
            builder: (context, provider, child) {
              return Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  // Repeat Feedback Button
                  if (provider.isTTSEnabled)
                    OutlinedButton.icon(
                      onPressed: provider.isAryaSpeaking
                          ? null
                          : () => provider.speakFeedback(
                                feedback.feedback,
                                feedback.overallScore,
                              ),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.white,
                        side: const BorderSide(color: Colors.white),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 12,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      icon: provider.isAryaSpeaking
                          ? const SizedBox(
                              width: 16,
                              height: 16,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                              ),
                            )
                          : const Icon(Icons.volume_up, size: 16),
                      label: Text(
                        provider.isAryaSpeaking ? 'Speaking...' : 'Repeat',
                        style: const TextStyle(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  // Next Question Button
                  ElevatedButton(
                    onPressed: () {
                      provider.nextQuestion();
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: const Color(0xFF667eea),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 12,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: const Text(
                      'Next Question',
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }

  Color _getScoreColor(double score) {
    if (score >= 8.0) return Colors.green;
    if (score >= 6.0) return Colors.orange;
    return Colors.red;
  }

  String _getScoreLabel(double score) {
    if (score >= 8.0) return 'Excellent';
    if (score >= 6.0) return 'Good';
    if (score >= 4.0) return 'Fair';
    return 'Needs Improvement';
  }
}
