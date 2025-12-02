import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/quiz_question.dart';
import '../providers/quiz_provider.dart';
import '../../../core/providers/auth_provider.dart';
import 'quiz_result_screen.dart';

class QuizScreen extends StatefulWidget {
  final QuizSubject subject;

  const QuizScreen({super.key, required this.subject});

  @override
  State<QuizScreen> createState() => _QuizScreenState();
}

class _QuizScreenState extends State<QuizScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final quizProvider = Provider.of<QuizProvider>(context, listen: false);
      quizProvider.startQuiz(widget.subject.id, questionCount: 10);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF3F7FF),
      appBar: AppBar(
        title: Text(
          widget.subject.name,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        backgroundColor: const Color(0xFF2E5BBA),
        elevation: 0,
        actions: [
          Consumer<QuizProvider>(
            builder: (context, quizProvider, child) {
              return Padding(
                padding: const EdgeInsets.only(right: 16),
                child: Center(
                  child: Text(
                    '${quizProvider.currentQuestionIndex + 1}/${quizProvider.totalQuestions}',
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              );
            },
          ),
        ],
      ),
      body: Consumer<QuizProvider>(
        builder: (context, quizProvider, child) {
          if (quizProvider.isLoading) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(color: Color(0xFF2E5BBA)),
                  SizedBox(height: 16),
                  Text(
                    'Loading quiz questions...',
                    style: TextStyle(
                      color: Color(0xFF2E5BBA),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            );
          }

          if (quizProvider.error != null) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.error_outline,
                    size: 64,
                    color: Colors.red[400],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Error loading quiz',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.red[400],
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    quizProvider.error!,
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.grey[600]),
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: () => Navigator.pop(context),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF2E5BBA),
                      foregroundColor: Colors.white,
                    ),
                    child: const Text('Go Back'),
                  ),
                ],
              ),
            );
          }

          if (quizProvider.questions.isEmpty) {
            return const Center(
              child: Text('No questions available'),
            );
          }

          return Column(
            children: [
              // Progress Bar
              Container(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Question ${quizProvider.currentQuestionIndex + 1}',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF2E5BBA),
                          ),
                        ),
                        Text(
                          '${((quizProvider.progress) * 100).toInt()}% Complete',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    LinearProgressIndicator(
                      value: quizProvider.progress,
                      backgroundColor: Colors.grey[300],
                      valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF2E5BBA)),
                    ),
                  ],
                ),
              ),

              // Question Content
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      // Question Card
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(24),
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
                            Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: _getDifficultyColor(quizProvider.currentQuestion!.difficulty),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Text(
                                    quizProvider.currentQuestion!.difficulty.toUpperCase(),
                                    style: const TextStyle(
                                      fontSize: 10,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    quizProvider.currentQuestion!.topic,
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: Colors.grey[600],
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),
                            Text(
                              quizProvider.currentQuestion!.question,
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w600,
                                color: Color(0xFF2E5BBA),
                                height: 1.4,
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 24),

                      // Options
                      Expanded(
                        child: ListView.builder(
                          itemCount: quizProvider.currentQuestion!.options.length,
                          itemBuilder: (context, index) {
                            final option = quizProvider.currentQuestion!.options[index];
                            final isSelected = quizProvider.userAnswers[quizProvider.currentQuestionIndex] == option;
                            
                            return Container(
                              margin: const EdgeInsets.only(bottom: 12),
                              child: Material(
                                color: Colors.transparent,
                                child: InkWell(
                                  borderRadius: BorderRadius.circular(12),
                                  onTap: () => quizProvider.answerQuestion(option),
                                  child: Container(
                                    padding: const EdgeInsets.all(16),
                                    decoration: BoxDecoration(
                                      color: isSelected ? const Color(0xFF2E5BBA) : Colors.white,
                                      borderRadius: BorderRadius.circular(12),
                                      border: Border.all(
                                        color: isSelected ? const Color(0xFF2E5BBA) : Colors.grey[300]!,
                                        width: 2,
                                      ),
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.black.withOpacity(0.05),
                                          blurRadius: 5,
                                          offset: const Offset(0, 2),
                                        ),
                                      ],
                                    ),
                                    child: Row(
                                      children: [
                                        Container(
                                          width: 24,
                                          height: 24,
                                          decoration: BoxDecoration(
                                            shape: BoxShape.circle,
                                            color: isSelected ? Colors.white : Colors.grey[300],
                                          ),
                                          child: Center(
                                            child: Text(
                                              String.fromCharCode(65 + index), // A, B, C, D
                                              style: TextStyle(
                                                fontSize: 12,
                                                fontWeight: FontWeight.bold,
                                                color: isSelected ? const Color(0xFF2E5BBA) : Colors.grey[600],
                                              ),
                                            ),
                                          ),
                                        ),
                                        const SizedBox(width: 16),
                                        Expanded(
                                          child: Text(
                                            option,
                                            style: TextStyle(
                                              fontSize: 16,
                                              fontWeight: FontWeight.w500,
                                              color: isSelected ? Colors.white : const Color(0xFF2E5BBA),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // Navigation Buttons
              Container(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    if (quizProvider.currentQuestionIndex > 0)
                      Expanded(
                        child: ElevatedButton(
                          onPressed: quizProvider.previousQuestion,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.grey[300],
                            foregroundColor: Colors.grey[700],
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          child: const Text('Previous'),
                        ),
                      ),
                    if (quizProvider.currentQuestionIndex > 0) const SizedBox(width: 16),
                    Expanded(
                      flex: 2,
                      child: ElevatedButton(
                        onPressed: () => _handleNext(context, quizProvider),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF2E5BBA),
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: Text(
                          quizProvider.currentQuestionIndex == quizProvider.totalQuestions - 1
                              ? 'Submit Quiz'
                              : 'Next Question',
                          style: const TextStyle(fontWeight: FontWeight.w600),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
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
        return Colors.blue;
    }
  }

  void _handleNext(BuildContext context, QuizProvider quizProvider) {
    if (quizProvider.currentQuestionIndex == quizProvider.totalQuestions - 1) {
      _submitQuiz(context, quizProvider);
    } else {
      quizProvider.nextQuestion();
    }
  }

  void _submitQuiz(BuildContext context, QuizProvider quizProvider) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: const Text(
            'Submit Quiz?',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: Color(0xFF2E5BBA),
            ),
          ),
          content: const Text(
            'Are you sure you want to submit your quiz? You won\'t be able to change your answers after submission.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(
                'Review Answers',
                style: TextStyle(color: Colors.grey[600]),
              ),
            ),
            ElevatedButton(
              onPressed: () async {
                Navigator.pop(context);
                
                final authProvider = Provider.of<AuthProvider>(context, listen: false);
                final userId = authProvider.user?.uid ?? 'anonymous';
                
                await quizProvider.submitQuiz(userId);
                
                if (context.mounted) {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                      builder: (context) => QuizResultScreen(subject: widget.subject),
                    ),
                  );
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF2E5BBA),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const Text('Submit'),
            ),
          ],
        );
      },
    );
  }
}
