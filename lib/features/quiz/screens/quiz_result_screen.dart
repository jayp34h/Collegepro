import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/quiz_question.dart';
import '../providers/quiz_provider.dart';
import '../../learn/screens/learn_screen.dart';
import 'quiz_dashboard_screen.dart';

class QuizResultScreen extends StatelessWidget {
  final QuizSubject subject;

  const QuizResultScreen({super.key, required this.subject});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF3F7FF),
      appBar: AppBar(
        title: const Text(
          'Quiz Results',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        backgroundColor: const Color(0xFF2E5BBA),
        elevation: 0,
        automaticallyImplyLeading: false,
      ),
      body: Consumer<QuizProvider>(
        builder: (context, quizProvider, child) {
          final result = quizProvider.currentResult;
          if (result == null) {
            return const Center(child: Text('No results available'));
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                // Score Card
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        _getScoreColor(result.percentage),
                        _getScoreColor(result.percentage).withOpacity(0.8),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: _getScoreColor(result.percentage).withOpacity(0.3),
                        blurRadius: 15,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      Text(
                        _getScoreMessage(result.percentage),
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 16),
                      Container(
                        width: 120,
                        height: 120,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.white.withOpacity(0.2),
                        ),
                        child: Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                '${result.score}%',
                                style: const TextStyle(
                                  fontSize: 32,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                              Text(
                                '${result.correctAnswers}/${result.totalQuestions}',
                                style: const TextStyle(
                                  fontSize: 16,
                                  color: Colors.white,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        subject.name,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 24),

                // Performance Breakdown
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 10,
                        offset: const Offset(0, 5),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Performance Breakdown',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF2E5BBA),
                        ),
                      ),
                      const SizedBox(height: 16),
                      ...result.topicScores.entries.map((entry) {
                        final topic = entry.key;
                        final scores = entry.value;
                        final correct = scores['correct'] ?? 0;
                        final total = scores['total'] ?? 1;
                        final percentage = (correct / total * 100).round();
                        
                        return Container(
                          margin: const EdgeInsets.only(bottom: 12),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    topic,
                                    style: const TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w600,
                                      color: Color(0xFF2E5BBA),
                                    ),
                                  ),
                                  Text(
                                    '$correct/$total ($percentage%)',
                                    style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w600,
                                      color: Colors.grey[600],
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 4),
                              LinearProgressIndicator(
                                value: correct / total,
                                backgroundColor: Colors.grey[300],
                                valueColor: AlwaysStoppedAnimation<Color>(
                                  _getTopicScoreColor(percentage),
                                ),
                              ),
                            ],
                          ),
                        );
                      }).toList(),
                    ],
                  ),
                ),

                const SizedBox(height: 24),

                // Action Buttons
                Column(
                  children: [
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const LearnScreen(),
                            ),
                          );
                        },
                        icon: const Icon(Icons.play_circle_outline),
                        label: const Text('Continue Learning'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF2E5BBA),
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => const QuizDashboardScreen(),
                                ),
                              );
                            },
                            icon: const Icon(Icons.dashboard),
                            label: const Text('View Dashboard'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.white,
                              foregroundColor: const Color(0xFF2E5BBA),
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                                side: const BorderSide(color: Color(0xFF2E5BBA)),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: () {
                              Navigator.pop(context);
                              Navigator.pop(context);
                            },
                            icon: const Icon(Icons.refresh),
                            label: const Text('Retake Quiz'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.white,
                              foregroundColor: const Color(0xFF2E5BBA),
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                                side: const BorderSide(color: Color(0xFF2E5BBA)),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),

                const SizedBox(height: 24),

                // Motivational Message
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        const Color(0xFF2E5BBA).withOpacity(0.1),
                        const Color(0xFF2E5BBA).withOpacity(0.05),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Column(
                    children: [
                      Icon(
                        _getMotivationIcon(result.percentage),
                        size: 48,
                        color: const Color(0xFF2E5BBA),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        _getMotivationMessage(result.percentage),
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF2E5BBA),
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        _getMotivationDescription(result.percentage),
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[600],
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Color _getScoreColor(double percentage) {
    if (percentage >= 80) return Colors.green;
    if (percentage >= 60) return Colors.orange;
    return Colors.red;
  }

  Color _getTopicScoreColor(int percentage) {
    if (percentage >= 80) return Colors.green;
    if (percentage >= 60) return Colors.orange;
    return Colors.red;
  }

  String _getScoreMessage(double percentage) {
    if (percentage >= 90) return 'Excellent! 🎉';
    if (percentage >= 80) return 'Great Job! 👏';
    if (percentage >= 70) return 'Good Work! 👍';
    if (percentage >= 60) return 'Keep Trying! 💪';
    return 'Need More Practice! 📚';
  }

  IconData _getMotivationIcon(double percentage) {
    if (percentage >= 80) return Icons.emoji_events;
    if (percentage >= 60) return Icons.trending_up;
    return Icons.school;
  }

  String _getMotivationMessage(double percentage) {
    if (percentage >= 90) return 'Outstanding Performance!';
    if (percentage >= 80) return 'You\'re doing great!';
    if (percentage >= 70) return 'Good progress!';
    if (percentage >= 60) return 'Keep improving!';
    return 'Practice makes perfect!';
  }

  String _getMotivationDescription(double percentage) {
    if (percentage >= 90) return 'You have mastered this subject. Keep up the excellent work!';
    if (percentage >= 80) return 'You have a strong understanding. A little more practice will make you perfect!';
    if (percentage >= 70) return 'You\'re on the right track. Focus on your weak areas to improve further.';
    if (percentage >= 60) return 'You have the basics down. More practice will help you excel.';
    return 'Don\'t give up! Review the topics and try again. Every expert was once a beginner.';
  }
}
