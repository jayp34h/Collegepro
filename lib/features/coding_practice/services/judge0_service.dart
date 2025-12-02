import 'dart:convert';
import 'dart:developer';
import 'package:http/http.dart' as http;
import '../../../core/config/api_config.dart';

class Judge0Service {
  // Language IDs for Judge0
  static const Map<String, int> languageIds = {
    'python': 71,
    'java': 62,
    'cpp': 54,
    'c': 50,
    'javascript': 63,
    'dart': 90,
  };

  // Funny messages for different outcomes
  static const List<String> funnySuccessMessages = [
    '🎉 Wah! Your code is working like a charm! Even my chai got excited!',
    '🚀 Shabash! Your code runs smoother than butter chicken!',
    '💫 Arre waah! Your logic is sharper than a samosa corner!',
    '🎯 Perfect! Your code is more reliable than Mumbai local trains!',
    '⭐ Kamaal! Even Sharma ji ka beta would be proud of this code!',
  ];

  static const List<String> funnyErrorMessages = [
    '🤔 Oops! Your code needs some debugging... like finding the right spice in biryani!',
    '😅 Arre yaar! Something went wrong. Time for some code chai break!',
    '🐛 Bug alert! Your code has more issues than a Bollywood drama!',
    '🤯 Error ho gaya! Don\'t worry, even Google has bugs sometimes!',
    '🔧 Time to fix this! Remember, every coder was once a beginner!',
  ];

  // Helper methods
  static List<String> getSupportedLanguages() {
    return languageIds.keys.toList();
  }

  static int? getLanguageId(String language) {
    return languageIds[language.toLowerCase()];
  }

  Future<Map<String, dynamic>> executeCode({
    required String sourceCode,
    required int languageId,
    String stdin = '',
  }) async {
    try {
      log('Judge0Service: Executing code with language ID: $languageId');
      
      // Submit code for execution
      final submissionResult = await _submitCode(sourceCode, languageId, stdin);
      if (submissionResult == null) {
        return _createErrorResponse('Failed to submit code for execution');
      }

      final token = submissionResult['token'];
      if (token == null) {
        return _createErrorResponse('No execution token received');
      }

      // Get execution result
      final executionResult = await _getSubmissionResult(token);
      if (executionResult == null) {
        return _createErrorResponse('Failed to get execution result');
      }

      return _processExecutionResult(executionResult);
    } catch (e) {
      log('Judge0Service: Error executing code: $e');
      return _createErrorResponse('Execution failed: $e');
    }
  }

  Future<Map<String, dynamic>?> _submitCode(
    String sourceCode,
    int languageId,
    String stdin,
  ) async {
    try {
      final response = await http.post(
        Uri.parse('${ApiConfig.judge0BaseUrl}/submissions?base64_encoded=true&wait=false'),
        headers: ApiConfig.judge0Headers,
        body: jsonEncode({
          'source_code': base64Encode(utf8.encode(sourceCode)),
          'language_id': languageId,
          'stdin': base64Encode(utf8.encode(stdin)),
        }),
      );

      if (response.statusCode == 201) {
        return jsonDecode(response.body);
      } else {
        log('Judge0Service: Submit failed with status: ${response.statusCode}');
        log('Judge0Service: Response body: ${response.body}');
        return null;
      }
    } catch (e) {
      log('Judge0Service: Error submitting code: $e');
      return null;
    }
  }

  Future<Map<String, dynamic>?> _getSubmissionResult(String token) async {
    try {
      int attempts = 0;
      const maxAttempts = 10;

      while (attempts < maxAttempts) {
        final response = await http.get(
          Uri.parse('${ApiConfig.judge0BaseUrl}/submissions/$token?base64_encoded=true'),
          headers: ApiConfig.judge0Headers,
        );

        if (response.statusCode == 200) {
          final result = jsonDecode(response.body);
          
          // Check if execution is complete
          if (result['status']['id'] <= 2) {
            // Still processing (In Queue = 1, Processing = 2)
            await Future.delayed(const Duration(seconds: 1));
            attempts++;
            continue;
          }
          
          return result;
        } else {
          log('Judge0Service: Get result failed with status: ${response.statusCode}');
          return null;
        }
      }
      
      return null; // Timeout
    } catch (e) {
      log('Judge0Service: Error getting result: $e');
      return null;
    }
  }

  Map<String, dynamic> _processExecutionResult(Map<String, dynamic> result) {
    final statusId = result['status']['id'];
    final stdout = result['stdout'] != null 
        ? utf8.decode(base64Decode(result['stdout'])) 
        : '';
    final stderr = result['stderr'] != null 
        ? utf8.decode(base64Decode(result['stderr'])) 
        : '';
    final compileOutput = result['compile_output'] != null 
        ? utf8.decode(base64Decode(result['compile_output'])) 
        : '';

    String funnyMessage;
    bool success;

    switch (statusId) {
      case 3: // Accepted
        success = true;
        funnyMessage = funnySuccessMessages[
            DateTime.now().millisecondsSinceEpoch % funnySuccessMessages.length
        ];
        break;
      case 4: // Wrong Answer
        success = false;
        funnyMessage = 'Close, but no samosa! 🥟 Your output doesn\'t match what we expected. Keep trying!';
        break;
      case 5: // Time Limit Exceeded
        success = false;
        funnyMessage = 'Whoa there, Flash! ⚡ Your code is taking longer than a Bollywood movie. Try optimizing it!';
        break;
      case 6: // Compilation Error
        success = false;
        funnyMessage = 'Oops 🤯 your code tripped over a compilation bug! Time to debug like a detective 🕵️';
        break;
      case 7: // Runtime Error (SIGSEGV)
      case 8: // Runtime Error (SIGXFSZ)
      case 9: // Runtime Error (SIGFPE)
      case 10: // Runtime Error (SIGABRT)
      case 11: // Runtime Error (NZEC)
      case 12: // Runtime Error (Other)
        success = false;
        funnyMessage = 'Houston, we have a runtime problem! 🚀 Your code crashed harder than my motivation on Monday morning';
        break;
      case 13: // Memory Limit Exceeded
        success = false;
        funnyMessage = 'Your code is hungrier than me at a buffet! 🍽️ It ate up all the memory. Try being more efficient!';
        break;
      default:
        success = false;
        funnyMessage = funnyErrorMessages[
            DateTime.now().millisecondsSinceEpoch % funnyErrorMessages.length
        ];
    }

    return {
      'success': success,
      'funny_message': funnyMessage,
      'stdout': stdout,
      'stderr': stderr,
      'compile_output': compileOutput,
      'execution_time': result['time'] ?? '0',
      'memory': result['memory'] ?? '0',
      'status': result['status']['description'] ?? 'Unknown',
      'status_id': statusId,
    };
  }

  Map<String, dynamic> _createErrorResponse(String message) {
    return {
      'success': false,
      'funny_message': funnyErrorMessages[
          DateTime.now().millisecondsSinceEpoch % funnyErrorMessages.length
      ],
      'stdout': '',
      'stderr': message,
      'compile_output': '',
      'execution_time': '0',
      'memory': '0',
      'status': 'Error',
      'status_id': -1,
    };
  }
}
