import 'dart:convert';
import 'package:http/http.dart' as http;

class GroqApiService {
  static const String _baseUrl = 'https://api.groq.com/openai/v1/chat/completions';
  static const String _apiKey = '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';
  static const String _model = 'openai/gpt-oss-20b';

  /// Send a message to Groq AI and get response
  static Future<String> sendMessage({
    required String message,
    required String projectContext,
    List<Map<String, String>>? conversationHistory,
  }) async {
    try {
      // Build conversation messages
      List<Map<String, String>> messages = [
        {
          'role': 'system',
          'content': '''You are a friendly AI project mentor helping students with their final year projects. You have access to this project information:

$projectContext

Your role is to provide step-by-step guidance and contextual advice. For every response:

🎯 RESPONSE STRUCTURE:
1. Start with a brief acknowledgment of their question
2. Break down your answer into clear, numbered steps
3. Provide specific context related to their project
4. Include actionable next steps
5. End with encouragement and offer further help

📋 STEP-BY-STEP FORMAT:
• Use numbered steps (Step 1, Step 2, etc.) for processes
• Include sub-points with bullet points (•) when needed
• Provide specific examples related to their tech stack
• Reference their project domain and requirements
• Give timeline estimates where applicable

🔧 CONTEXTUAL GUIDANCE:
• Always relate advice to their specific project
• Reference their tech stack in examples
• Consider their project difficulty level
• Provide domain-specific insights
• Suggest resources specific to their technologies

💡 PRACTICAL APPROACH:
• Give concrete, actionable steps
• Include code snippets or commands when helpful
• Suggest specific tools and resources
• Provide learning paths tailored to their project
• Offer troubleshooting tips

FORMATTING RULES:
- Use clear step numbering (Step 1:, Step 2:, etc.)
- Include emojis for section headers
- Use bullet points (•) for sub-items
- Keep responses well-structured and scannable
- Avoid raw markdown syntax
- Make responses conversational yet professional

Always be encouraging, provide specific guidance, and help them feel confident about their project journey.'''
        },
      ];

      // Add conversation history if provided
      if (conversationHistory != null && conversationHistory.isNotEmpty) {
        messages.addAll(conversationHistory);
      }

      // Add current user message
      messages.add({
        'role': 'user',
        'content': message,
      });

      final response = await http.post(
        Uri.parse(_baseUrl),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $_apiKey',
        },
        body: jsonEncode({
          'model': _model,
          'messages': messages,
          'max_tokens': 1000,
          'temperature': 0.7,
          'top_p': 1,
          'stream': false,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        
        if (data['choices'] != null && data['choices'].isNotEmpty) {
          String rawResponse = data['choices'][0]['message']['content'] ?? 'Sorry, I couldn\'t generate a response.';
          
          // Clean up the response to remove raw markdown formatting
          String cleanedResponse = _cleanResponseFormatting(rawResponse);
          
          return cleanedResponse;
        } else {
          return 'Sorry, I couldn\'t generate a response. Please try again.';
        }
      } else {
        print('Groq API Error: ${response.statusCode} - ${response.body}');
        return 'Sorry, I\'m experiencing technical difficulties. Please try again later.';
      }
    } catch (e) {
      print('Error calling Groq API: $e');
      return 'Sorry, I\'m currently unavailable. Please check your internet connection and try again.';
    }
  }

  /// Generate project context string from project data
  static String generateProjectContext({
    required String title,
    required String description,
    required String domain,
    required String difficulty,
    required List<String> techStack,
    String? problemStatement,
    List<String>? realWorldApplications,
    List<String>? possibleExtensions,
    String? githubUrl,
  }) {
    final buffer = StringBuffer();
    
    buffer.writeln('Project Title: ');
    buffer.writeln(title);
    buffer.writeln('Domain: ');
    buffer.writeln(domain);
    buffer.writeln('Difficulty Level: ');
    buffer.writeln(difficulty);
    buffer.writeln('Description: ');
    buffer.writeln(description);
    
    if (problemStatement != null && problemStatement.isNotEmpty) {
      buffer.writeln('Problem Statement: ');
      buffer.writeln(problemStatement);
    }
    
    buffer.writeln('Technology Stack: ');
    buffer.writeln(techStack.join(', '));
    
    if (realWorldApplications != null && realWorldApplications.isNotEmpty) {
      buffer.writeln('Real-world Applications:');
      for (int i = 0; i < realWorldApplications.length; i++) {
        buffer.writeln('${i + 1}. ');
        buffer.writeln(realWorldApplications[i]);
      }
    }
    
    if (possibleExtensions != null && possibleExtensions.isNotEmpty) {
      buffer.writeln('Possible Extensions:');
      for (int i = 0; i < possibleExtensions.length; i++) {
        buffer.writeln('${i + 1}. ');
        buffer.writeln(possibleExtensions[i]);
      }
    }
    
    if (githubUrl != null && githubUrl.isNotEmpty) {
      buffer.writeln('GitHub Repository: ');
      buffer.writeln(githubUrl);
    }
    
    return buffer.toString();
  }

  /// Clean response formatting to remove raw markdown syntax and dollar signs
  static String _cleanResponseFormatting(String response) {
    String cleaned = response;
    
    // Remove dollar signs that appear in responses
    cleaned = cleaned.replaceAll(RegExp(r'\$\d+'), '');
    cleaned = cleaned.replaceAll(RegExp(r'\$1'), '');
    cleaned = cleaned.replaceAll(RegExp(r'\$'), '');
    
    // Remove table formatting with pipes and dashes
    cleaned = cleaned.replaceAll(RegExp(r'\|[^|]*\|'), '');
    cleaned = cleaned.replaceAll(RegExp(r'\|[-\s]*\|'), '');
    cleaned = cleaned.replaceAll(RegExp(r'^\|.*\|$', multiLine: true), '');
    
    // Clean up table separators
    cleaned = cleaned.replaceAll(RegExp(r'^[-\s|]+$', multiLine: true), '');
    cleaned = cleaned.replaceAll(RegExp(r'\|[-]+\|'), '');
    
    // Remove excessive markdown formatting
    cleaned = cleaned.replaceAll(RegExp(r'\*\*([^*]+)\*\*'), r'$1');
    cleaned = cleaned.replaceAll(RegExp(r'\*([^*]+)\*'), r'$1');
    
    // Clean up multiple line breaks
    cleaned = cleaned.replaceAll(RegExp(r'\n\s*\n\s*\n'), '\n\n');
    
    // Remove leading/trailing whitespace
    cleaned = cleaned.trim();
    
    // Replace markdown headers with clean format
    cleaned = cleaned.replaceAll(RegExp(r'^#{1,6}\s*(.+)$', multiLine: true), r'$1');
    
    // Convert markdown lists to clean bullet points
    cleaned = cleaned.replaceAll(RegExp(r'^\s*[-*+]\s*', multiLine: true), '• ');
    
    // Remove any remaining dollar signs or currency symbols
    cleaned = cleaned.replaceAll(RegExp(r'[\$]'), '');
    
    return cleaned;
  }

  /// Validate API key and connection
  static Future<bool> validateConnection() async {
    try {
      final response = await http.post(
        Uri.parse(_baseUrl),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $_apiKey',
        },
        body: jsonEncode({
          'model': _model,
          'messages': [
            {
              'role': 'user',
              'content': 'Hello, are you working?',
            }
          ],
          'max_tokens': 10,
        }),
      );

      return response.statusCode == 200;
    } catch (e) {
      print('Connection validation error: $e');
      return false;
    }
  }
}
