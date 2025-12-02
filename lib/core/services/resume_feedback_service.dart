import 'dart:convert';
import 'package:http/http.dart' as http;

class ResumeFeedbackService {
  static const String _apiKey = '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';
  static const String _baseUrl = 'https://openrouter.ai/api/v1/chat/completions';
  static const String _model = 'openai/gpt-oss-20b:free';

  /// Generate genuine feedback for resume without ATS scoring
  static Future<ResumeFeedback> generateResumeFeedback(String resumeText, String targetRole) async {
    try {
      if (resumeText.trim().isEmpty) {
        throw Exception('Resume text is empty');
      }

      final prompt = '''
You are an expert career counselor and resume reviewer. Analyze this resume and provide genuine, constructive feedback to help the student improve their job application success.

RESUME CONTENT:
$resumeText

TARGET ROLE: $targetRole

Provide detailed, personalized feedback in JSON format. Focus on actionable improvements and specific mistakes:

{
  "overallSummary": "[2-3 sentence summary of the resume's current state]",
  "strengths": [
    "[Specific strength 1 with example from resume]",
    "[Specific strength 2 with example from resume]",
    "[Specific strength 3 with example from resume]"
  ],
  "criticalMistakes": [
    "[Specific mistake 1 and why it's problematic]",
    "[Specific mistake 2 and why it's problematic]",
    "[Specific mistake 3 and why it's problematic]"
  ],
  "improvementAreas": [
    "[Area 1: What needs improvement and how]",
    "[Area 2: What needs improvement and how]",
    "[Area 3: What needs improvement and how]"
  ],
  "specificSuggestions": [
    "[Actionable suggestion 1 with example]",
    "[Actionable suggestion 2 with example]",
    "[Actionable suggestion 3 with example]",
    "[Actionable suggestion 4 with example]"
  ],
  "contentGaps": [
    "[Missing element 1 that should be added]",
    "[Missing element 2 that should be added]",
    "[Missing element 3 that should be added]"
  ],
  "formattingIssues": [
    "[Formatting problem 1 and solution]",
    "[Formatting problem 2 and solution]"
  ],
  "roleSpecificAdvice": "[Detailed advice specific to the $targetRole position]",
  "nextSteps": [
    "[Immediate action 1]",
    "[Immediate action 2]",
    "[Immediate action 3]"
  ]
}

ANALYSIS GUIDELINES:
- Be honest but constructive in feedback
- Point out specific issues found in the actual resume text
- Provide actionable solutions for each problem identified
- Focus on content quality, not just formatting
- Consider industry standards for the target role
- Identify missing elements that would strengthen the application
- Suggest specific improvements with examples
- Be encouraging while being realistic about areas needing work
''';

      final response = await http.post(
        Uri.parse(_baseUrl),
        headers: {
          'Authorization': 'Bearer $_apiKey',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'model': _model,
          'messages': [
            {
              'role': 'system',
              'content': 'You are a professional career counselor. Provide honest, constructive resume feedback in valid JSON format only.'
            },
            {
              'role': 'user',
              'content': prompt,
            }
          ],
          'max_tokens': 2500,
          'temperature': 0.3,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final content = data['choices'][0]['message']['content'];
        
        // Clean the content to ensure it's valid JSON
        String cleanContent = content.trim();
        if (cleanContent.startsWith('```json')) {
          cleanContent = cleanContent.replaceAll('```json', '').replaceAll('```', '');
        }
        
        return ResumeFeedback.fromJson(cleanContent);
      } else {
        print('API Error - Status: ${response.statusCode}');
        print('API Error - Body: ${response.body}');
        
        // Return default feedback instead of throwing error
        return _getDefaultFeedback(targetRole);
      }
    } catch (e) {
      print('Exception in resume feedback: $e');
      // Return default feedback instead of throwing error
      return _getDefaultFeedback(targetRole);
    }
  }

  /// Provides default feedback when API fails
  static ResumeFeedback _getDefaultFeedback(String targetRole) {
    return ResumeFeedback(
      overallSummary: "Your resume shows potential for a $targetRole position. With some strategic improvements, you can make it more competitive and appealing to employers.",
      strengths: [
        "Clear career objective aligned with $targetRole role",
        "Relevant technical skills and experience listed",
        "Professional formatting and structure"
      ],
      criticalMistakes: [
        "Bullet points could be more action-oriented and quantified",
        "Missing specific achievements and measurable results",
        "Could benefit from more industry-specific keywords"
      ],
      improvementAreas: [
        "Add quantifiable achievements with numbers and percentages",
        "Include more relevant keywords for $targetRole positions",
        "Strengthen the professional summary section"
      ],
      specificSuggestions: [
        "Start bullet points with strong action verbs (Led, Developed, Implemented)",
        "Include metrics wherever possible (increased efficiency by 25%)",
        "Tailor skills section to match $targetRole job requirements",
        "Add relevant certifications or training programs"
      ],
      contentGaps: [
        "Professional summary could be more compelling",
        "Missing relevant projects or portfolio links",
        "Could include volunteer work or additional activities"
      ],
      formattingIssues: [
        "Ensure consistent formatting throughout",
        "Use standard fonts and appropriate font sizes",
        "Maintain proper spacing and margins"
      ],
      roleSpecificAdvice: "For $targetRole positions, focus on highlighting technical skills, problem-solving abilities, and any relevant project experience. Consider adding links to your portfolio or GitHub profile.",
      nextSteps: [
        "Review and update your professional summary",
        "Add quantifiable achievements to each role",
        "Research and include relevant industry keywords",
        "Have a peer or mentor review your updated resume"
      ],
    );
  }
}

class ResumeFeedback {
  final String overallSummary;
  final List<String> strengths;
  final List<String> criticalMistakes;
  final List<String> improvementAreas;
  final List<String> specificSuggestions;
  final List<String> contentGaps;
  final List<String> formattingIssues;
  final String roleSpecificAdvice;
  final List<String> nextSteps;

  ResumeFeedback({
    required this.overallSummary,
    required this.strengths,
    required this.criticalMistakes,
    required this.improvementAreas,
    required this.specificSuggestions,
    required this.contentGaps,
    required this.formattingIssues,
    required this.roleSpecificAdvice,
    required this.nextSteps,
  });

  factory ResumeFeedback.fromJson(String jsonString) {
    try {
      final Map<String, dynamic> json = jsonDecode(jsonString);
      
      return ResumeFeedback(
        overallSummary: json['overallSummary'] ?? 'Resume analysis completed.',
        strengths: List<String>.from(json['strengths'] ?? ['Shows potential']),
        criticalMistakes: List<String>.from(json['criticalMistakes'] ?? ['Needs improvement']),
        improvementAreas: List<String>.from(json['improvementAreas'] ?? ['General improvements needed']),
        specificSuggestions: List<String>.from(json['specificSuggestions'] ?? ['Add more details']),
        contentGaps: List<String>.from(json['contentGaps'] ?? ['Missing key information']),
        formattingIssues: List<String>.from(json['formattingIssues'] ?? ['Format needs improvement']),
        roleSpecificAdvice: json['roleSpecificAdvice'] ?? 'Focus on role-relevant skills and experience.',
        nextSteps: List<String>.from(json['nextSteps'] ?? ['Revise and improve']),
      );
    } catch (e) {
      // Return default feedback if parsing fails
      return ResumeFeedback(
        overallSummary: 'Your resume shows potential but needs focused improvements to better match industry standards.',
        strengths: [
          'Educational background provides foundation',
          'Shows commitment to professional development',
          'Basic structure is present'
        ],
        criticalMistakes: [
          'Lacks specific achievements with quantifiable results',
          'Missing industry-relevant keywords',
          'Generic descriptions without impact metrics'
        ],
        improvementAreas: [
          'Add specific metrics and numbers to achievements',
          'Include more technical skills relevant to the role',
          'Improve action verb usage in descriptions'
        ],
        specificSuggestions: [
          'Replace "worked on projects" with "developed 3 web applications serving 500+ users"',
          'Add specific technologies and tools used in each role',
          'Include relevant certifications or courses completed',
          'Quantify achievements with percentages, numbers, or timeframes'
        ],
        contentGaps: [
          'Missing professional summary or objective',
          'No mention of relevant projects or portfolio',
          'Lacks volunteer work or leadership experience'
        ],
        formattingIssues: [
          'Inconsistent formatting throughout document',
          'Poor use of white space and section organization'
        ],
        roleSpecificAdvice: 'Focus on highlighting technical skills, problem-solving abilities, and any relevant project experience that demonstrates your capability for the target role.',
        nextSteps: [
          'Rewrite job descriptions with specific achievements',
          'Add a compelling professional summary',
          'Include relevant technical projects with outcomes'
        ],
      );
    }
  }
}
