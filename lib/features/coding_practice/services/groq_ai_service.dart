import 'dart:convert';
import 'dart:developer';
import 'package:http/http.dart' as http;
import '../../../core/config/api_config.dart';

class GroqAIService {
  static const String _baseUrl = '${ApiConfig.groqBaseUrl}/chat/completions';

  Future<Map<String, dynamic>> getFeedback({
    required String question,
    required String studentCode,
    required Map<String, dynamic> executionResult,
    required String expectedOutput,
  }) async {
    try {
      log('GroqAIService: Getting AI feedback for code submission');
      
      final prompt = _buildFeedbackPrompt(
        question: question,
        studentCode: studentCode,
        executionResult: executionResult,
        expectedOutput: expectedOutput,
      );

      final response = await _makeGroqRequest(prompt);
      if (response == null) {
        return _createFallbackFeedback(executionResult);
      }

      return _parseFeedbackResponse(response);
    } catch (e) {
      log('GroqAIService: Error getting feedback: $e');
      return _createFallbackFeedback(executionResult);
    }
  }

  Future<Map<String, dynamic>> generateSolution({
    required String question,
    required String language,
    required String expectedOutput,
  }) async {
    try {
      log('GroqAIService: Generating solution for question');
      
      final prompt = _buildSolutionPrompt(
        question: question,
        language: language,
        expectedOutput: expectedOutput,
      );

      final response = await _makeGroqRequest(prompt);
      if (response == null) {
        return _createFallbackSolution(language);
      }

      return _parseSolutionResponse(response);
    } catch (e) {
      log('GroqAIService: Error generating solution: $e');
      return _createFallbackSolution(language);
    }
  }

  String _buildFeedbackPrompt({
    required String question,
    required String studentCode,
    required Map<String, dynamic> executionResult,
    required String expectedOutput,
  }) {
    final isSuccess = executionResult['success'] ?? false;
    final stdout = executionResult['stdout'] ?? '';
    final stderr = executionResult['stderr'] ?? '';
    final executionTime = executionResult['execution_time'] ?? '0';

    return '''
You are a funny but helpful coding tutor for Indian students. Analyze this coding submission and provide feedback in JSON format.

QUESTION:
$question

EXPECTED OUTPUT:
$expectedOutput

STUDENT CODE:
$studentCode

EXECUTION RESULT:
- Success: $isSuccess
- Output: $stdout
- Errors: $stderr
- Execution Time: ${executionTime}s

Provide response in this EXACT JSON format:
{
  "score": <number 1-10>,
  "feedback": "<funny but educational feedback with Indian context and emojis>",
  "suggestion": "<specific improvement tip in friendly tone>"
}

Guidelines:
- Use Indian context, food references, Bollywood, cricket, etc.
- Be encouraging even for wrong answers
- Include relevant emojis
- Keep feedback under 100 words
- Make suggestions specific and actionable
- Score based on correctness, efficiency, and code quality
''';
  }

  String _buildSolutionPrompt({
    required String question,
    required String language,
    required String expectedOutput,
  }) {
    return '''
You are a funny coding tutor. Generate a solution for this coding problem with a lighthearted explanation.

QUESTION:
$question

LANGUAGE: $language
EXPECTED OUTPUT:
$expectedOutput

Provide response in this EXACT JSON format:
{
  "code": "<complete working solution code>",
  "explanation": "<step-by-step explanation with cooking/food analogies and emojis>",
  "time_complexity": "<Big O notation>",
  "space_complexity": "<Big O notation>"
}

Guidelines:
- Write clean, well-commented code
- Use cooking/recipe analogies in explanation
- Include emojis and Indian context
- Explain each step like a recipe
- Keep explanation fun but educational
''';
  }

  Future<String?> _makeGroqRequest(String prompt) async {
    try {
      final response = await http.post(
        Uri.parse(_baseUrl),
        headers: ApiConfig.groqHeaders,
        body: jsonEncode({
          'model': ApiConfig.groqModel,
          'messages': [
            {
              'role': 'user',
              'content': prompt,
            }
          ],
          'max_tokens': 1000,
          'temperature': 0.7,
        }),
      ).timeout(const Duration(seconds: 30));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final content = data['choices']?[0]?['message']?['content'];
        log('GroqAIService: Got response: $content');
        return content;
      } else {
        log('GroqAIService: Request failed with status: ${response.statusCode}');
        log('GroqAIService: Response body: ${response.body}');
        return null;
      }
    } catch (e) {
      log('GroqAIService: Error making request: $e');
      return null;
    }
  }

  Map<String, dynamic> _parseFeedbackResponse(String response) {
    try {
      // Try to extract JSON from response
      final jsonMatch = RegExp(r'\{[\s\S]*\}').firstMatch(response);
      if (jsonMatch != null) {
        final jsonStr = jsonMatch.group(0)!;
        final parsed = jsonDecode(jsonStr);
        
        return {
          'score': _validateScore(parsed['score']),
          'feedback': parsed['feedback']?.toString() ?? 'Great attempt! Keep coding! 🚀',
          'suggestion': parsed['suggestion']?.toString() ?? 'Practice makes perfect! Try again! 💪',
        };
      }
    } catch (e) {
      log('GroqAIService: Error parsing feedback response: $e');
    }
    
    return _createFallbackFeedback({});
  }

  Map<String, dynamic> _parseSolutionResponse(String response) {
    try {
      // Try to extract JSON from response
      final jsonMatch = RegExp(r'\{[\s\S]*\}').firstMatch(response);
      if (jsonMatch != null) {
        final jsonStr = jsonMatch.group(0)!;
        final parsed = jsonDecode(jsonStr);
        
        return {
          'code': parsed['code']?.toString() ?? '// Solution code here',
          'explanation': parsed['explanation']?.toString() ?? 'Here\'s one tasty recipe 🍲 for solving this problem!',
          'time_complexity': parsed['time_complexity']?.toString() ?? 'O(n)',
          'space_complexity': parsed['space_complexity']?.toString() ?? 'O(1)',
        };
      }
    } catch (e) {
      log('GroqAIService: Error parsing solution response: $e');
    }
    
    return _createFallbackSolution('python');
  }

  int _validateScore(dynamic score) {
    if (score is int && score >= 1 && score <= 10) {
      return score;
    }
    if (score is String) {
      final parsed = int.tryParse(score);
      if (parsed != null && parsed >= 1 && parsed <= 10) {
        return parsed;
      }
    }
    return 5; // Default score
  }

  Map<String, dynamic> _createFallbackFeedback(Map<String, dynamic> executionResult) {
    final isSuccess = executionResult['success'] ?? false;
    
    if (isSuccess) {
      return {
        'score': 8,
        'feedback': 'Yay! 🎉 Your code runs smoother than butter on hot paratha! Well done!',
        'suggestion': 'Great job! Try optimizing for better performance or handling edge cases! 🚀',
      };
    } else {
      return {
        'score': 4,
        'feedback': 'Oops! 🤯 Your code hit a small bump. Don\'t worry, even the best chefs burn their first rotis!',
        'suggestion': 'Check your logic and syntax. Debug step by step like solving a puzzle! 🧩',
      };
    }
  }

  Map<String, dynamic> _createFallbackSolution(String language) {
    return {
      'code': '# Solution code will be generated here\nprint("Hello, World!")',
      'explanation': 'Here\'s one tasty recipe 🍲 for solving this problem: Step 1 - understand the problem, Step 2 - write clean code, Step 3 - test thoroughly!',
      'time_complexity': 'O(n)',
      'space_complexity': 'O(1)',
    };
  }
}
