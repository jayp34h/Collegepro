import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

class OpenRouterApiService {
  static const String _apiKey = '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';
  static const String _baseUrl = 'https://openrouter.ai/api/v1';
  static const String _model = 'openai/gpt-oss-20b:free';

  /// Summarize text content using OpenRouter API with DeepSeek model
  Future<Map<String, dynamic>> summarizeText(String text) async {
    try {
      final prompt = '''You are an educational AI assistant. Provide a comprehensive summary of the following content in a structured format:

$text

Please format your response with these sections:

🧩 **Definition:**
[Clear definition of the main topic]

⚙️ **Key Characteristics:**
• [Key point 1]
• [Key point 2]
• [Key point 3]
• [Key point 4]

📘 **Summary:**
[Brief explanation in simple terms]

✅ **Advantages:**
• [Advantage 1]
• [Advantage 2]
• [Advantage 3]

❌ **Disadvantages:**
• [Disadvantage 1]
• [Disadvantage 2]
• [Disadvantage 3]

🌍 **Real-Life Examples:**
• [Example 1]
• [Example 2]
• [Example 3]

Make it educational and easy to understand for students.''';

      final response = await http.post(
        Uri.parse('$_baseUrl/chat/completions'),
        headers: {
          'Authorization': 'Bearer $_apiKey',
          'Content-Type': 'application/json',
          'HTTP-Referer': 'https://collegepro.app',
          'X-Title': 'CollegePro AI Summarizer',
        },
        body: jsonEncode({
          'model': _model,
          'messages': [
            {
              'role': 'user',
              'content': prompt,
            }
          ],
          'max_tokens': 1500,
          'temperature': 0.7,
          'stream': false,
        }),
      );

      if (kDebugMode) {
        print('🧠 OpenRouter API response status: ${response.statusCode}');
        print('🧠 Response headers: ${response.headers}');
        print('🧠 Response body: ${response.body}');
      }

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        
        if (kDebugMode) print('🧠 Parsed response data: $data');
        
        if (data['choices'] != null && data['choices'].isNotEmpty) {
          final aiResponse = data['choices'][0]['message']['content'];
          
          if (kDebugMode) print('✅ AI Response received: ${aiResponse.substring(0, aiResponse.length > 100 ? 100 : aiResponse.length)}...');
          
          return {
            'success': true,
            'summary': aiResponse.trim(),
          };
        } else {
          throw Exception('No choices in API response: $data');
        }
      } else {
        final errorBody = response.body;
        if (kDebugMode) print('❌ API Error Response: $errorBody');
        throw Exception('API request failed with status ${response.statusCode}: $errorBody');
      }
    } catch (e) {
      if (kDebugMode) print('❌ OpenRouter API service error: $e');
      
      if (e.toString().contains('SocketException') || e.toString().contains('TimeoutException')) {
        throw Exception('Network error. Please check your internet connection.');
      } else if (e.toString().contains('FormatException')) {
        throw Exception('Invalid response format from API.');
      } else {
        throw Exception('Failed to summarize content: ${e.toString().replaceAll('Exception: ', '')}');
      }
    }
  }


  /// Generate a title for the summary based on content
  Future<String> generateTitle(String content) async {
    try {
      final shortContent = content.length > 500 ? content.substring(0, 500) : content;
      
      final prompt = '''Create a short title (max 6 words) for this content:

$shortContent

Title only:''';

      final response = await http.post(
        Uri.parse('$_baseUrl/chat/completions'),
        headers: {
          'Authorization': 'Bearer $_apiKey',
          'Content-Type': 'application/json',
          'HTTP-Referer': 'https://collegepro.app',
          'X-Title': 'CollegePro AI Summarizer',
        },
        body: jsonEncode({
          'model': _model,
          'messages': [
            {
              'role': 'user',
              'content': prompt,
            }
          ],
          'max_tokens': 50,
          'temperature': 0.5,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final title = data['choices'][0]['message']['content'].trim();
        return title.replaceAll('"', '').replaceAll("'", '');
      } else {
        return 'AI Generated Summary';
      }
    } catch (e) {
      if (kDebugMode) print('⚠️ Title generation failed: $e');
      return 'AI Generated Summary';
    }
  }
}
