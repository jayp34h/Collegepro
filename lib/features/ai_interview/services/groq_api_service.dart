import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

class GroqApiService {
  static const String _apiKey = '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';
  static const String _baseUrl = 'https://api.groq.com/openai/v1/chat/completions';
  static const String _model = 'llama-3.3-70b-versatile';

  // Generate chat completion using Groq API
  Future<String> generateResponse(String prompt, {String? systemPrompt}) async {
    try {
      final headers = {
        'Authorization': 'Bearer $_apiKey',
        'Content-Type': 'application/json',
      };

      final messages = <Map<String, String>>[];
      
      if (systemPrompt != null && systemPrompt.isNotEmpty) {
        messages.add({
          'role': 'system',
          'content': systemPrompt,
        });
      }
      
      messages.add({
        'role': 'user',
        'content': prompt,
      });

      final body = jsonEncode({
        'model': _model,
        'messages': messages,
        'temperature': 0.7,
        'max_tokens': 2048,
        'top_p': 1.0,
        'stream': false,
      });

      if (kDebugMode) {
        print('🤖 Making Groq API request to $_model...');
      }

      final response = await http.post(
        Uri.parse(_baseUrl),
        headers: headers,
        body: body,
      ).timeout(const Duration(seconds: 30));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final content = data['choices']?[0]?['message']?['content'] as String?;
        
        if (content != null && content.isNotEmpty) {
          if (kDebugMode) {
            print('✅ Groq API response received successfully');
          }
          return content.trim();
        } else {
          throw Exception('Empty response from Groq API');
        }
      } else {
        final errorBody = response.body;
        if (kDebugMode) {
          print('❌ Groq API error: ${response.statusCode} - $errorBody');
        }
        throw Exception('Groq API error: ${response.statusCode} - $errorBody');
      }
    } catch (e) {
      if (kDebugMode) {
        print('❌ Groq API request failed: $e');
      }
      rethrow;
    }
  }

  // Generate interview questions
  Future<List<String>> generateInterviewQuestions({
    required String jobRole,
    required String experienceLevel,
    required int numberOfQuestions,
  }) async {
    final systemPrompt = '''You are Arya, an expert AI interviewer. Generate exactly $numberOfQuestions interview questions for a $experienceLevel level $jobRole position.

Requirements:
- Questions should be relevant to the job role and experience level
- Mix of technical, behavioral, and situational questions
- Progressive difficulty based on experience level
- Each question should be clear and specific
- Return only the questions, one per line
- No numbering or bullet points''';

    final userPrompt = '''Generate $numberOfQuestions interview questions for:
Job Role: $jobRole
Experience Level: $experienceLevel

Focus on practical skills, problem-solving abilities, and relevant experience for this role.''';

    try {
      final response = await generateResponse(userPrompt, systemPrompt: systemPrompt);
      
      // Parse the response into individual questions
      final questions = response
          .split('\n')
          .where((line) => line.trim().isNotEmpty)
          .map((line) => line.trim())
          .where((line) => line.endsWith('?'))
          .take(numberOfQuestions)
          .toList();

      if (questions.isEmpty) {
        // Fallback questions if parsing fails
        return _getFallbackQuestions(jobRole, experienceLevel);
      }

      return questions;
    } catch (e) {
      if (kDebugMode) {
        print('❌ Error generating questions: $e');
      }
      return _getFallbackQuestions(jobRole, experienceLevel);
    }
  }

  // Generate feedback for an answer
  Future<Map<String, dynamic>> generateFeedback({
    required String question,
    required String answer,
    required String jobRole,
  }) async {
    final systemPrompt = '''You are Arya, an expert AI interviewer providing constructive feedback. Analyze the candidate's answer and provide:

1. A score from 1-10 (be realistic, not too harsh or too lenient)
2. Specific feedback highlighting strengths and areas for improvement
3. Actionable suggestions for better answers

Format your response as JSON:
{
  "score": <number>,
  "feedback": "<detailed feedback text>",
  "strengths": ["<strength1>", "<strength2>"],
  "improvements": ["<improvement1>", "<improvement2>"]
}''';

    final userPrompt = '''Evaluate this interview answer:

Question: $question
Answer: $answer
Job Role: $jobRole

Provide detailed feedback with a score out of 10.''';

    try {
      final response = await generateResponse(userPrompt, systemPrompt: systemPrompt);
      
      // Try to parse JSON response
      try {
        final jsonData = jsonDecode(response);
        return {
          'score': (jsonData['score'] as num?)?.toDouble() ?? 5.0,
          'feedback': jsonData['feedback'] as String? ?? 'Good effort! Keep practicing to improve your interview skills.',
          'strengths': (jsonData['strengths'] as List?)?.cast<String>() ?? [],
          'improvements': (jsonData['improvements'] as List?)?.cast<String>() ?? [],
        };
      } catch (jsonError) {
        // If JSON parsing fails, extract score and use response as feedback
        final scoreMatch = RegExp(r'(\d+(?:\.\d+)?)\s*(?:out of|/)\s*10').firstMatch(response);
        final score = scoreMatch != null ? double.tryParse(scoreMatch.group(1)!) ?? 5.0 : 5.0;
        
        return {
          'score': score,
          'feedback': response,
          'strengths': <String>[],
          'improvements': <String>[],
        };
      }
    } catch (e) {
      if (kDebugMode) {
        print('❌ Error generating feedback: $e');
      }
      return {
        'score': 5.0,
        'feedback': 'Thank you for your answer. Keep practicing to improve your interview skills!',
        'strengths': <String>[],
        'improvements': <String>[],
      };
    }
  }

  // Generate final interview summary
  Future<String> generateInterviewSummary({
    required List<Map<String, dynamic>> questionAnswers,
    required double averageScore,
    required String jobRole,
  }) async {
    final systemPrompt = '''You are Arya, an expert AI interviewer providing a comprehensive interview summary. Create a professional, encouraging summary that includes:

1. Overall performance assessment
2. Key strengths demonstrated
3. Areas for improvement
4. Specific recommendations for career development
5. Encouraging closing remarks

Keep the tone professional but supportive.''';

    final userPrompt = '''Generate a comprehensive interview summary:

Job Role: $jobRole
Average Score: ${averageScore.toStringAsFixed(1)}/10
Number of Questions: ${questionAnswers.length}

Questions and Performance:
${questionAnswers.map((qa) => '- Q: ${qa['question']}\n  Score: ${qa['score']}/10').join('\n')}

Provide a detailed summary with actionable insights for the candidate.''';

    try {
      final response = await generateResponse(userPrompt, systemPrompt: systemPrompt);
      return response;
    } catch (e) {
      if (kDebugMode) {
        print('❌ Error generating summary: $e');
      }
      return _getFallbackSummary(averageScore, jobRole);
    }
  }

  // Fallback questions if API fails
  List<String> _getFallbackQuestions(String jobRole, String experienceLevel) {
    final fallbackQuestions = [
      "Tell me about yourself and your background.",
      "Why are you interested in this $jobRole position?",
      "What are your greatest strengths?",
      "Describe a challenging project you've worked on.",
      "How do you handle working under pressure?",
      "Where do you see yourself in 5 years?",
      "What motivates you in your work?",
      "How do you stay updated with industry trends?",
      "Describe a time when you had to learn something new quickly.",
      "What questions do you have for us?"
    ];
    
    return fallbackQuestions.take(5).toList();
  }

  // Fallback summary if API fails
  String _getFallbackSummary(double averageScore, String jobRole) {
    if (averageScore >= 8.0) {
      return "Excellent performance! You demonstrated strong knowledge and skills relevant to the $jobRole position. Your answers showed confidence and expertise. Continue building on your strengths and you'll be well-prepared for interviews.";
    } else if (averageScore >= 6.0) {
      return "Good job on the interview! You showed solid understanding of the $jobRole requirements. Focus on providing more specific examples and details in your answers to make them even stronger.";
    } else {
      return "Thank you for completing the interview practice. This is a great start! Focus on preparing more detailed examples from your experience and practice articulating your thoughts clearly. Keep practicing and you'll see improvement.";
    }
  }
}
