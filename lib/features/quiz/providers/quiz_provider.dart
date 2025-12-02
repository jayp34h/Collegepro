import 'package:flutter/material.dart';
import '../models/quiz_question.dart';
import '../services/quiz_service.dart';

class QuizProvider with ChangeNotifier {
  final QuizService _quizService = QuizService();
  
  List<QuizQuestion> _questions = [];
  List<String> _userAnswers = [];
  int _currentQuestionIndex = 0;
  bool _isLoading = false;
  String? _error;
  QuizResult? _currentResult;
  List<QuizResult> _userResults = [];
  String _selectedSubject = '';

  // Getters
  List<QuizQuestion> get questions => _questions;
  List<String> get userAnswers => _userAnswers;
  int get currentQuestionIndex => _currentQuestionIndex;
  bool get isLoading => _isLoading;
  String? get error => _error;
  QuizResult? get currentResult => _currentResult;
  List<QuizResult> get userResults => _userResults;
  String get selectedSubject => _selectedSubject;
  
  QuizQuestion? get currentQuestion => 
      _currentQuestionIndex < _questions.length ? _questions[_currentQuestionIndex] : null;
  
  bool get isQuizCompleted => _currentQuestionIndex >= _questions.length;
  int get totalQuestions => _questions.length;
  double get progress => _questions.isEmpty ? 0.0 : (_currentQuestionIndex + 1) / _questions.length;

  // Start a new quiz
  Future<void> startQuiz(String subject, {int questionCount = 10}) async {
    _isLoading = true;
    _error = null;
    _selectedSubject = subject;
    notifyListeners();

    try {
      _questions = await QuizService.getQuizQuestions(subject);
      _userAnswers = List.filled(_questions.length, '');
      _currentQuestionIndex = 0;
      _currentResult = null;
      
      if (_questions.isEmpty) {
        _error = 'No questions available for this subject';
      }
    } catch (e) {
      _error = 'Failed to load quiz questions: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Answer current question
  void answerQuestion(String answer) {
    if (_currentQuestionIndex < _userAnswers.length) {
      _userAnswers[_currentQuestionIndex] = answer;
      notifyListeners();
    }
  }

  // Move to next question
  void nextQuestion() {
    if (_currentQuestionIndex < _questions.length - 1) {
      _currentQuestionIndex++;
      notifyListeners();
    }
  }

  // Move to previous question
  void previousQuestion() {
    if (_currentQuestionIndex > 0) {
      _currentQuestionIndex--;
      notifyListeners();
    }
  }

  // Go to specific question
  void goToQuestion(int index) {
    if (index >= 0 && index < _questions.length) {
      _currentQuestionIndex = index;
      notifyListeners();
    }
  }

  // Submit quiz and calculate results
  Future<void> submitQuiz(String userId) async {
    if (_questions.isEmpty) return;

    _isLoading = true;
    notifyListeners();

    try {
      // Calculate scores
      int correctAnswers = 0;
      Map<String, dynamic> topicScores = {};
      
      for (int i = 0; i < _questions.length; i++) {
        final question = _questions[i];
        final userAnswer = _userAnswers[i];
        final isCorrect = userAnswer == question.options[question.correctAnswer];
        
        if (isCorrect) correctAnswers++;
        
        // Track topic-wise scores
        final topic = question.topic;
        if (!topicScores.containsKey(topic)) {
          topicScores[topic] = {'correct': 0, 'total': 0};
        }
        topicScores[topic]['total']++;
        if (isCorrect) topicScores[topic]['correct']++;
      }

      // Create result
      final result = QuizResult(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        userId: userId,
        subject: _selectedSubject,
        totalQuestions: _questions.length,
        correctAnswers: correctAnswers,
        score: ((correctAnswers / _questions.length) * 100).round(),
        completedAt: DateTime.now(),
        topicScores: topicScores,
      );

      // Save to Firebase
      await _quizService.saveQuizResult(result);
      
      _currentResult = result;
      _userResults.insert(0, result);
      
    } catch (e) {
      _error = 'Failed to submit quiz: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Load user's quiz history
  Future<void> loadUserResults(String userId) async {
    _isLoading = true;
    notifyListeners();

    try {
      _userResults = await _quizService.getUserQuizResults(userId);
    } catch (e) {
      _error = 'Failed to load quiz results: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Reset quiz state
  void resetQuiz() {
    _questions = [];
    _userAnswers = [];
    _currentQuestionIndex = 0;
    _currentResult = null;
    _error = null;
    _selectedSubject = '';
    notifyListeners();
  }

  // Get user's best score for a subject
  int getBestScore(String subject) {
    final subjectResults = _userResults.where((r) => r.subject == subject);
    if (subjectResults.isEmpty) return 0;
    return subjectResults.map((r) => r.score).reduce((a, b) => a > b ? a : b);
  }

  // Get user's average score for a subject
  double getAverageScore(String subject) {
    final subjectResults = _userResults.where((r) => r.subject == subject);
    if (subjectResults.isEmpty) return 0.0;
    final totalScore = subjectResults.map((r) => r.score).reduce((a, b) => a + b);
    return totalScore / subjectResults.length;
  }

  // Get total quizzes attempted
  int getTotalQuizzesAttempted() {
    return _userResults.length;
  }

  // Get subjects attempted
  List<String> getAttemptedSubjects() {
    return _userResults.map((r) => r.subject).toSet().toList();
  }
}
