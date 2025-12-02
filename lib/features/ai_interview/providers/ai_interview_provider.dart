import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:speech_to_text/speech_to_text.dart';
import '../models/interview_models.dart';
import '../services/arya_interview_service.dart';
import '../services/arya_tts_service.dart';

class AIInterviewProvider with ChangeNotifier {
  final AryaInterviewService _aryaService = AryaInterviewService();
  final SpeechToText _speechToText = SpeechToText();
  final AryaTTSService _aryaTTS = AryaTTSService();

  // Current interview session
  InterviewSession? _currentSession;
  InterviewSession? get currentSession => _currentSession;

  // Current question index
  int _currentQuestionIndex = 0;
  int get currentQuestionIndex => _currentQuestionIndex;

  // Current question
  InterviewQuestion? get currentQuestion {
    if (_currentSession == null || 
        _currentQuestionIndex >= _currentSession!.questions.length) {
      return null;
    }
    return _currentSession!.questions[_currentQuestionIndex];
  }

  // Loading states
  bool _isLoadingQuestions = false;
  bool get isLoadingQuestions => _isLoadingQuestions;

  bool _isEvaluatingAnswer = false;
  bool get isEvaluatingAnswer => _isEvaluatingAnswer;

  bool _isGeneratingSummary = false;
  bool get isGeneratingSummary => _isGeneratingSummary;

  // Speech to text states
  bool _isSpeechEnabled = false;
  bool get isSpeechEnabled => _isSpeechEnabled;

  bool _isListening = false;
  bool get isListening => _isListening;

  String _speechText = '';
  String get speechText => _speechText;

  double _speechConfidence = 0.0;
  double get speechConfidence => _speechConfidence;

  // Input mode
  InputMode _inputMode = InputMode.text;
  InputMode get inputMode => _inputMode;

  // Available job roles
  List<JobRole> _jobRoles = [];
  List<JobRole> get jobRoles => _jobRoles;

  // Selected job role
  JobRole? _selectedJobRole;
  JobRole? get selectedJobRole => _selectedJobRole;

  // Error handling
  String? _error;
  String? get error => _error;

  // Interview summary
  String? _interviewSummary;
  String? get interviewSummary => _interviewSummary;

  // TTS states
  bool _isTTSEnabled = true;
  bool get isTTSEnabled => _isTTSEnabled;
  
  bool _autoSpeakEnabled = true;
  bool get autoSpeakEnabled => _autoSpeakEnabled;
  
  String get currentLanguage => _aryaTTS.currentLanguage;

  bool _isAryaSpeaking = false;
  bool get isAryaSpeaking => _isAryaSpeaking;

  AIInterviewProvider() {
    // Initialize immediately for mobile compatibility
    WidgetsBinding.instance.addPostFrameCallback((_) {
      initialize();
    });
  }

  // Initialize provider with timeout protection
  Future<void> initialize() async {
    try {
      // Initialize with shorter timeouts for mobile
      await Future.wait([
        _initializeSpeechToText().timeout(const Duration(seconds: 5)),
        _initializeTTS().timeout(const Duration(seconds: 5)),
      ]).timeout(const Duration(seconds: 8));
      _loadJobRoles();
      if (kDebugMode) print('✅ AIInterviewProvider initialized successfully');
    } catch (e) {
      if (kDebugMode) print('AIInterviewProvider initialization failed: $e');
      // Don't set error for initialization failures - let the app continue
      // _error = 'Failed to initialize AI interview. Please try again.';
      // Still load job roles even if TTS/Speech fails
      _loadJobRoles();
      notifyListeners();
    }
  }

  // Initialize TTS
  Future<void> _initializeTTS() async {
    try {
      await _aryaTTS.initialize();
      notifyListeners();
    } catch (e) {
      print('Failed to initialize Arya TTS: $e');
    }
  }

  // Initialize speech to text
  Future<void> _initializeSpeechToText() async {
    try {
      _isSpeechEnabled = await _speechToText.initialize(
        onError: (error) {
          print('Speech recognition error: $error');
          _error = 'Speech recognition error: ${error.errorMsg}';
          notifyListeners();
        },
        onStatus: (status) {
          print('Speech recognition status: $status');
          if (status == 'done' || status == 'notListening') {
            _isListening = false;
            notifyListeners();
          }
        },
      );
      notifyListeners();
    } catch (e) {
      print('Failed to initialize speech recognition: $e');
      _isSpeechEnabled = false;
      notifyListeners();
    }
  }

  // Load available job roles
  void _loadJobRoles() {
    _jobRoles = _aryaService.getAvailableJobRoles();
    notifyListeners();
  }

  // Select job role
  void selectJobRole(JobRole jobRole) {
    _selectedJobRole = jobRole;
    notifyListeners();
  }

  // Set input mode
  void setInputMode(InputMode mode) {
    _inputMode = mode;
    if (mode == InputMode.text && _isListening) {
      stopListening();
    }
    notifyListeners();
  }

  // Start new interview session
  Future<void> startInterview() async {
    if (_selectedJobRole == null) {
      _error = 'Please select a job role first';
      notifyListeners();
      return;
    }

    _isLoadingQuestions = true;
    _error = null;
    notifyListeners();

    try {
      // Generate questions using Arya with timeout
      final questions = await _aryaService.generateInterviewQuestions(
        jobRole: _selectedJobRole!.title,
        experienceLevel: _selectedJobRole!.level,
        numberOfQuestions: 6,
      ).timeout(const Duration(seconds: 30));

      // Create new interview session
      _currentSession = InterviewSession(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        jobRole: _selectedJobRole!.title,
        startTime: DateTime.now(),
        questions: questions,
        answers: [],
        feedbacks: [],
        status: InterviewStatus.inProgress,
      );

      _currentQuestionIndex = 0;
      _isLoadingQuestions = false;
      notifyListeners();

      // Arya automatically speaks the first question
      if (_isTTSEnabled && _autoSpeakEnabled && currentQuestion != null) {
        await speakQuestion(currentQuestion!.question);
      }
    } catch (e) {
      _error = 'Failed to start interview: $e';
      _isLoadingQuestions = false;
      notifyListeners();
    }
  }

  // Submit answer for current question
  Future<void> submitAnswer(String answer) async {
    if (_currentSession == null || currentQuestion == null) {
      _error = 'No active interview session';
      notifyListeners();
      return;
    }

    _isEvaluatingAnswer = true;
    _error = null;
    notifyListeners();

    try {
      // Create answer object
      final interviewAnswer = InterviewAnswer(
        questionId: currentQuestion!.id,
        answer: answer,
        timestamp: DateTime.now(),
        isVoiceInput: _inputMode == InputMode.voice,
        confidenceScore: _inputMode == InputMode.voice ? _speechConfidence : null,
      );

      // Add answer to session
      _currentSession!.answers.add(interviewAnswer);

      // Get feedback from Arya with timeout
      final feedback = await _aryaService.evaluateAnswer(
        question: currentQuestion!,
        userAnswer: answer,
        isVoiceInput: _inputMode == InputMode.voice,
      ).timeout(const Duration(seconds: 30));

      // Add feedback to session
      _currentSession!.feedbacks.add(feedback);

      _isEvaluatingAnswer = false;
      notifyListeners();

      // Arya automatically speaks feedback
      if (_isTTSEnabled && _autoSpeakEnabled) {
        await speakFeedback(feedback.feedback, feedback.overallScore);
      }
    } catch (e) {
      _error = 'Failed to evaluate answer: $e';
      _isEvaluatingAnswer = false;
      notifyListeners();
    }
  }

  // Move to next question
  void nextQuestion() {
    if (_currentSession == null) return;

    if (_currentQuestionIndex < _currentSession!.questions.length - 1) {
      _currentQuestionIndex++;
      _speechText = '';
      notifyListeners();
      
      // Arya automatically speaks the next question
      if (_isTTSEnabled && _autoSpeakEnabled && currentQuestion != null) {
        speakQuestion(currentQuestion!.question);
      }
    } else {
      // Interview completed
      _completeInterview();
    }
  }

  // Complete interview and generate summary
  Future<void> _completeInterview() async {
    if (_currentSession == null) return;

    _isGeneratingSummary = true;
    notifyListeners();

    try {
      // Calculate average score
      final totalScore = _currentSession!.feedbacks
          .map((f) => f.overallScore)
          .reduce((a, b) => a + b);
      final averageScore = totalScore / _currentSession!.feedbacks.length;

      // Update session
      _currentSession = InterviewSession(
        id: _currentSession!.id,
        jobRole: _currentSession!.jobRole,
        startTime: _currentSession!.startTime,
        endTime: DateTime.now(),
        questions: _currentSession!.questions,
        answers: _currentSession!.answers,
        feedbacks: _currentSession!.feedbacks,
        averageScore: averageScore,
        status: InterviewStatus.completed,
      );

      // Generate summary using Arya
      _interviewSummary = await _aryaService.generateInterviewSummary(
        feedbacks: _currentSession!.feedbacks,
        averageScore: averageScore,
        jobRole: _currentSession!.jobRole,
      );

      _isGeneratingSummary = false;
      notifyListeners();

      // Arya automatically speaks the final summary
      if (_isTTSEnabled && _autoSpeakEnabled && _interviewSummary != null) {
        await speakSummary(_interviewSummary!, averageScore);
      }
    } catch (e) {
      _error = 'Failed to generate summary: $e';
      _isGeneratingSummary = false;
      notifyListeners();
    }
  }

  // Start listening for speech input
  Future<void> startListening() async {
    if (!_isSpeechEnabled) {
      _error = 'Speech recognition not available';
      notifyListeners();
      return;
    }

    _isListening = true;
    _speechText = '';
    _error = null;
    notifyListeners();

    try {
      await _speechToText.listen(
        onResult: (result) {
          _speechText = result.recognizedWords;
          _speechConfidence = result.confidence;
          notifyListeners();
        },
        listenFor: const Duration(seconds: 30),
        pauseFor: const Duration(seconds: 3),
        partialResults: true,
        cancelOnError: true,
        listenMode: ListenMode.confirmation,
      );
    } catch (e) {
      _error = 'Failed to start listening: $e';
      _isListening = false;
      notifyListeners();
    }
  }

  // Stop listening for speech input
  Future<void> stopListening() async {
    if (_isListening) {
      await _speechToText.stop();
      _isListening = false;
      notifyListeners();
    }
  }

  // Clear speech text
  void clearSpeechText() {
    _speechText = '';
    _speechConfidence = 0.0;
    notifyListeners();
  }

  // Reset interview session
  void resetInterview() {
    _currentSession = null;
    _currentQuestionIndex = 0;
    _speechText = '';
    _speechConfidence = 0.0;
    _isListening = false;
    _error = null;
    _interviewSummary = null;
    _inputMode = InputMode.text;
    notifyListeners();
  }

  // Clear error
  void clearError() {
    _error = null;
    notifyListeners();
  }

  // Get Arya's introduction message
  String getIntroductionMessage() {
    return _aryaService.getIntroductionMessage();
  }

  // Arya speaks introduction
  Future<void> speakIntroduction() async {
    if (!_isTTSEnabled) return;
    _isAryaSpeaking = true;
    notifyListeners();
    try {
      await _aryaTTS.speakIntroduction();
    } finally {
      _isAryaSpeaking = false;
      notifyListeners();
    }
  }

  // Arya speaks a question
  Future<void> speakQuestion(String question) async {
    if (!_isTTSEnabled) return;
    _isAryaSpeaking = true;
    notifyListeners();
    try {
      await _aryaTTS.speakQuestion(question);
    } finally {
      _isAryaSpeaking = false;
      notifyListeners();
    }
  }

  // Arya speaks feedback
  Future<void> speakFeedback(String feedback, double score) async {
    if (!_isTTSEnabled) return;
    _isAryaSpeaking = true;
    notifyListeners();
    try {
      await _aryaTTS.speakFeedback(feedback, score);
    } finally {
      _isAryaSpeaking = false;
      notifyListeners();
    }
  }

  // Arya speaks interview summary
  Future<void> speakSummary(String summary, double averageScore) async {
    if (!_isTTSEnabled) return;
    _isAryaSpeaking = true;
    notifyListeners();
    try {
      await _aryaTTS.speakSummary(summary, averageScore);
    } finally {
      _isAryaSpeaking = false;
      notifyListeners();
    }
  }

  // Arya speaks encouragement
  Future<void> speakEncouragement() async {
    if (!_isTTSEnabled) return;
    _isAryaSpeaking = true;
    notifyListeners();
    try {
      await _aryaTTS.speakEncouragement();
    } finally {
      _isAryaSpeaking = false;
      notifyListeners();
    }
  }

  // Stop Arya from speaking
  Future<void> stopAryaSpeaking() async {
    await _aryaTTS.stop();
    _isAryaSpeaking = false;
    notifyListeners();
  }

  // Toggle TTS on/off
  void toggleTTS() {
    _isTTSEnabled = !_isTTSEnabled;
    if (!_isTTSEnabled) {
      stopAryaSpeaking();
    }
    notifyListeners();
  }

  void toggleAutoSpeak() {
    _autoSpeakEnabled = !_autoSpeakEnabled;
    notifyListeners();
  }

  // Set language for Arya
  Future<void> setLanguage(String language) async {
    await _aryaTTS.setLanguage(language);
    notifyListeners();
  }

  // Set TTS enabled state
  void setTTSEnabled(bool enabled) {
    _isTTSEnabled = enabled;
    _aryaTTS.setEnabled(enabled);
    if (!enabled && _isAryaSpeaking) {
      stopAryaSpeaking();
    }
    notifyListeners();
  }

  // Get current question progress
  String getQuestionProgress() {
    if (_currentSession == null) return '0/0';
    return '${_currentQuestionIndex + 1}/${_currentSession!.questions.length}';
  }

  // Get current difficulty
  String getCurrentDifficulty() {
    return currentQuestion?.difficulty ?? 'Unknown';
  }

  // Check if interview is completed
  bool get isInterviewCompleted {
    return _currentSession?.status == InterviewStatus.completed;
  }

  // Check if there's a current feedback
  InterviewFeedback? get currentFeedback {
    if (_currentSession == null || 
        _currentQuestionIndex >= _currentSession!.feedbacks.length) {
      return null;
    }
    return _currentSession!.feedbacks[_currentQuestionIndex];
  }

  // Check if current question has been answered
  bool get hasCurrentQuestionBeenAnswered {
    if (_currentSession == null) return false;
    return _currentQuestionIndex < _currentSession!.answers.length;
  }

  @override
  void dispose() {
    _speechToText.cancel();
    super.dispose();
  }
}
