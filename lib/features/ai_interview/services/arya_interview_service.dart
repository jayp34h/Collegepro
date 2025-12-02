import 'dart:math';
import 'package:flutter/foundation.dart';
import '../models/interview_models.dart';
import 'groq_api_service.dart';

class AryaInterviewService {
  late final GroqApiService _groqService;
  
  AryaInterviewService() {
    _groqService = GroqApiService();
  }

  // Arya's introduction message
  String getIntroductionMessage() {
    return "Hello! I am Arya, your AI interviewer. I was developed by Jagdish to help you practice and improve your interview skills. I will ask you questions based on your chosen job role and provide detailed feedback to help you grow. Let's begin your interview journey!";
  }

  // Generate interview questions based on job role
  Future<List<InterviewQuestion>> generateInterviewQuestions({
    required String jobRole,
    required String experienceLevel,
    int numberOfQuestions = 5,
  }) async {
    try {
      final questions = await _groqService.generateInterviewQuestions(
        jobRole: jobRole,
        experienceLevel: experienceLevel,
        numberOfQuestions: numberOfQuestions,
      );
      
      return questions.asMap().entries.map((entry) {
        final index = entry.key;
        final question = entry.value;
        
        return InterviewQuestion(
          id: (index + 1).toString(),
          question: question,
          difficulty: 'Medium',
          category: _categorizeQuestion(question),
          expectedKeywords: [],
        );
      }).toList();
      
    } catch (e) {
      if (kDebugMode) {
        print('Error generating questions: $e');
      }
      return _generateFallbackQuestions(jobRole, experienceLevel, numberOfQuestions);
    }
  }

  // Evaluate user's answer and provide feedback
  Future<InterviewFeedback> evaluateAnswer({
    required InterviewQuestion question,
    required String userAnswer,
    required bool isVoiceInput,
  }) async {
    try {
      final feedbackData = await _groqService.generateFeedback(
        question: question.question,
        answer: userAnswer,
        jobRole: question.category,
      );
      
      final score = feedbackData['score'] as double;
      return InterviewFeedback(
        questionId: question.id,
        correctnessScore: score,
        clarityScore: score,
        confidenceScore: score,
        fluencyScore: score,
        overallScore: score,
        feedback: feedbackData['feedback'] as String,
        strengths: (feedbackData['strengths'] as List).cast<String>(),
        weaknesses: (feedbackData['improvements'] as List).cast<String>(),
        improvementTips: (feedbackData['improvements'] as List).cast<String>(),
      );
      
    } catch (e) {
      if (kDebugMode) {
        print('Error evaluating answer: $e');
      }
      return InterviewFeedback(
        questionId: question.id,
        correctnessScore: 5.0,
        clarityScore: 5.0,
        confidenceScore: 5.0,
        fluencyScore: 5.0,
        overallScore: 5.0,
        feedback: 'Thank you for your answer. Keep practicing to improve your interview skills!',
        strengths: [],
        weaknesses: [],
        improvementTips: [],
      );
    }
  }

  // Generate final interview summary
  Future<String> generateInterviewSummary({
    required List<InterviewFeedback> feedbacks,
    required double averageScore,
    required String jobRole,
  }) async {
    try {
      final questionAnswers = feedbacks.map((f) => {
        'question': 'Interview Question',
        'score': f.overallScore,
      }).toList();
      
      final summary = await _groqService.generateInterviewSummary(
        questionAnswers: questionAnswers,
        averageScore: averageScore,
        jobRole: jobRole,
      );
      
      return summary;
    } catch (e) {
      if (kDebugMode) {
        print('Error generating summary: $e');
      }
      return _getFallbackSummary(averageScore, jobRole);
    }
  }

  // Categorize question based on content
  String _categorizeQuestion(String question) {
    final lowerQuestion = question.toLowerCase();
    if (lowerQuestion.contains('technical') || lowerQuestion.contains('code') || lowerQuestion.contains('algorithm')) {
      return 'technical';
    } else if (lowerQuestion.contains('team') || lowerQuestion.contains('leadership') || lowerQuestion.contains('conflict')) {
      return 'behavioral';
    } else if (lowerQuestion.contains('situation') || lowerQuestion.contains('example') || lowerQuestion.contains('time when')) {
      return 'situational';
    }
    return 'general';
  }

  // Fallback questions when API fails
  List<InterviewQuestion> _generateFallbackQuestions(String jobRole, String level, int numberOfQuestions) {
    final random = Random();
    final questionId = random.nextInt(1000);
    
    final allQuestions = [
      InterviewQuestion(
        id: 'q${questionId}1',
        question: 'Tell me about yourself and your interest in $jobRole.',
        difficulty: 'Easy',
        category: jobRole,
        expectedKeywords: ['experience', 'skills', 'passion', 'background'],
      ),
      InterviewQuestion(
        id: 'q${questionId}2',
        question: 'What are your key strengths relevant to this $jobRole position?',
        difficulty: 'Easy',
        category: jobRole,
        expectedKeywords: ['strengths', 'skills', 'abilities', 'expertise'],
      ),
      InterviewQuestion(
        id: 'q${questionId}3',
        question: 'Describe a challenging project you worked on and how you overcame obstacles.',
        difficulty: 'Medium',
        category: jobRole,
        expectedKeywords: ['project', 'challenges', 'problem-solving', 'solution'],
      ),
      InterviewQuestion(
        id: 'q${questionId}4',
        question: 'How do you stay updated with the latest trends in $jobRole?',
        difficulty: 'Medium',
        category: jobRole,
        expectedKeywords: ['learning', 'trends', 'development', 'research'],
      ),
      InterviewQuestion(
        id: 'q${questionId}5',
        question: 'Design a solution for a complex problem in your field. Walk me through your approach.',
        difficulty: 'Hard',
        category: jobRole,
        expectedKeywords: ['design', 'architecture', 'approach', 'methodology'],
      ),
      InterviewQuestion(
        id: 'q${questionId}6',
        question: 'Where do you see yourself in 5 years, and how does this role fit into your career goals?',
        difficulty: 'Hard',
        category: jobRole,
        expectedKeywords: ['career', 'goals', 'growth', 'vision', 'future'],
      ),
    ];
    
    return allQuestions.take(numberOfQuestions).toList();
  }

  // Fallback feedback when API fails (unused method - kept for potential future use)
  // ignore: unused_element
  InterviewFeedback _getFallbackFeedback(String questionId, String answer) {
    final answerLength = answer.length;
    final hasKeywords = answer.toLowerCase().contains('experience') || 
                       answer.toLowerCase().contains('skill') ||
                       answer.toLowerCase().contains('project');
    
    final correctnessScore = hasKeywords ? 7.0 : 5.0;
    final clarityScore = answerLength > 50 ? 7.0 : 5.0;
    final confidenceScore = 6.0;
    final fluencyScore = 6.0;
    final overallScore = (correctnessScore + clarityScore + confidenceScore + fluencyScore) / 4;
    
    return InterviewFeedback(
      questionId: questionId,
      correctnessScore: correctnessScore,
      clarityScore: clarityScore,
      confidenceScore: confidenceScore,
      fluencyScore: fluencyScore,
      overallScore: overallScore,
      feedback: 'Thank you for your response. You provided relevant information and showed good understanding of the topic.',
      strengths: ['Clear communication', 'Relevant content'],
      weaknesses: ['Could provide more specific examples', 'Consider elaborating on key points'],
      improvementTips: [
        'Include specific examples from your experience',
        'Structure your answer with clear beginning, middle, and end',
        'Practice speaking with confidence and enthusiasm'
      ],
    );
  }

  // Fallback summary when API fails
  String _getFallbackSummary(double averageScore, String jobRole) {
    return '''
Congratulations on completing your AI interview with me, Arya! 

You achieved an overall score of ${averageScore.toStringAsFixed(1)}/10 for the $jobRole position. This shows your dedication to improving your interview skills.

Your responses demonstrated good understanding of the role requirements and showed your enthusiasm for the field. I noticed your ability to communicate clearly and provide relevant examples.

To further enhance your interview performance, continue practicing your responses, focus on providing specific examples, and maintain confidence in your abilities.

Remember, every interview is a learning opportunity. Keep practicing, stay confident, and believe in your potential. You have what it takes to succeed in your career journey!

Best of luck from Arya, your AI interview companion developed by Jagdish.
''';
  }

  // Get available job roles for selection
  List<JobRole> getAvailableJobRoles() {
    return [
      JobRole(
        id: 'software_engineer',
        title: 'Software Engineer',
        description: 'Develop and maintain software applications',
        skills: ['Programming', 'Problem Solving', 'Algorithms', 'Data Structures'],
        level: 'Entry',
      ),
      JobRole(
        id: 'data_scientist',
        title: 'Data Scientist',
        description: 'Analyze data to extract insights and build predictive models',
        skills: ['Python', 'Machine Learning', 'Statistics', 'SQL'],
        level: 'Mid',
      ),
      JobRole(
        id: 'web_developer',
        title: 'Web Developer',
        description: 'Create and maintain websites and web applications',
        skills: ['HTML', 'CSS', 'JavaScript', 'React', 'Node.js'],
        level: 'Entry',
      ),
      JobRole(
        id: 'mobile_developer',
        title: 'Mobile Developer',
        description: 'Develop mobile applications for iOS and Android',
        skills: ['Flutter', 'React Native', 'Swift', 'Kotlin'],
        level: 'Mid',
      ),
      JobRole(
        id: 'product_manager',
        title: 'Product Manager',
        description: 'Manage product development and strategy',
        skills: ['Strategy', 'Communication', 'Analytics', 'Leadership'],
        level: 'Mid',
      ),
      JobRole(
        id: 'ui_ux_designer',
        title: 'UI/UX Designer',
        description: 'Design user interfaces and user experiences',
        skills: ['Design', 'Figma', 'User Research', 'Prototyping'],
        level: 'Entry',
      ),
    ];
  }
}
