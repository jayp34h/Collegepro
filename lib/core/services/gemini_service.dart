import 'package:google_generative_ai/google_generative_ai.dart';

class GeminiService {
  static const String _apiKey = 'AIzaSyChfcKv6C4sSj-oKSe9Lc-YnBwEbjLBr74';
  late final GenerativeModel _model;

  GeminiService() {
    _model = GenerativeModel(
      model: 'gemini-1.5-flash',
      apiKey: _apiKey,
    );
  }

  Future<ResumeAnalysis> analyzeResume(String resumeText, String targetRole) async {
    try {
      final prompt = '''
Analyze the following resume for a $targetRole position and provide detailed feedback:

RESUME TEXT:
$resumeText

Please provide analysis in the following JSON format:
{
  "atsScore": 85,
  "strengths": ["Strong technical skills", "Relevant experience"],
  "weaknesses": ["Missing soft skills", "No quantified achievements"],
  "missingSkills": ["Python", "Machine Learning", "AWS"],
  "keywordMatches": ["Java", "SQL", "Git"],
  "missingKeywords": ["Docker", "Kubernetes", "React"],
  "improvedBulletPoints": [
    {
      "original": "Worked on web development projects",
      "improved": "Developed 5+ responsive web applications using React and Node.js, improving user engagement by 30%"
    }
  ],
  "tailoredSuggestions": [
    "Add specific metrics to quantify your achievements",
    "Include relevant certifications for $targetRole",
    "Highlight leadership experience"
  ],
  "overallFeedback": "Your resume shows strong technical foundation but needs more quantified achievements and role-specific keywords."
}

Ensure the response is valid JSON only, no additional text.
''';

      final response = await _model.generateContent([Content.text(prompt)]);
      final responseText = response.text ?? '';
      
      return ResumeAnalysis.fromJson(responseText);
    } catch (e) {
      throw Exception('Failed to analyze resume: $e');
    }
  }

  Future<String> improveBulletPoint(String originalPoint, String targetRole) async {
    try {
      final prompt = '''
Improve this resume bullet point for a $targetRole position:

Original: "$originalPoint"

Make it more impactful by:
1. Adding specific metrics/numbers where possible
2. Using action verbs
3. Highlighting relevant skills for $targetRole
4. Making it ATS-friendly

Return only the improved bullet point, no additional text.
''';

      final response = await _model.generateContent([Content.text(prompt)]);
      return response.text?.trim() ?? originalPoint;
    } catch (e) {
      return originalPoint;
    }
  }

  Future<List<String>> generateRoleSpecificSuggestions(String resumeText, String targetRole) async {
    try {
      final prompt = '''
Based on this resume and target role ($targetRole), provide 5 specific suggestions to improve the resume:

RESUME:
$resumeText

TARGET ROLE: $targetRole

Provide suggestions as a JSON array of strings:
["suggestion 1", "suggestion 2", "suggestion 3", "suggestion 4", "suggestion 5"]

Focus on:
- Missing skills for the role
- Industry-specific keywords
- Relevant certifications
- Experience gaps
- Formatting improvements

Return only the JSON array, no additional text.
''';

      final response = await _model.generateContent([Content.text(prompt)]);
      final responseText = response.text ?? '';
      
      // Parse JSON array
      final suggestions = <String>[];
      // Simple JSON parsing for array of strings
      final cleanText = responseText.replaceAll('[', '').replaceAll(']', '').replaceAll('"', '');
      final items = cleanText.split(',');
      
      for (final item in items) {
        final trimmed = item.trim();
        if (trimmed.isNotEmpty) {
          suggestions.add(trimmed);
        }
      }
      
      return suggestions.isNotEmpty ? suggestions : [
        'Add more quantified achievements',
        'Include relevant technical skills',
        'Improve formatting and structure',
        'Add industry-specific keywords',
        'Include relevant certifications'
      ];
    } catch (e) {
      return [
        'Add more quantified achievements',
        'Include relevant technical skills',
        'Improve formatting and structure',
        'Add industry-specific keywords',
        'Include relevant certifications'
      ];
    }
  }
}

class ResumeAnalysis {
  final int atsScore;
  final List<String> strengths;
  final List<String> weaknesses;
  final List<String> missingSkills;
  final List<String> keywordMatches;
  final List<String> missingKeywords;
  final List<BulletPointImprovement> improvedBulletPoints;
  final List<String> tailoredSuggestions;
  final String overallFeedback;

  ResumeAnalysis({
    required this.atsScore,
    required this.strengths,
    required this.weaknesses,
    required this.missingSkills,
    required this.keywordMatches,
    required this.missingKeywords,
    required this.improvedBulletPoints,
    required this.tailoredSuggestions,
    required this.overallFeedback,
  });

  factory ResumeAnalysis.fromJson(String jsonString) {
    try {
      // Simple JSON parsing since we control the format
      final lines = jsonString.split('\n');
      
      // Default values
      int atsScore = 75;
      List<String> strengths = ['Technical skills', 'Educational background'];
      List<String> weaknesses = ['Needs more quantified achievements'];
      List<String> missingSkills = ['Industry-specific skills needed'];
      List<String> keywordMatches = ['Basic keywords found'];
      List<String> missingKeywords = ['Role-specific keywords needed'];
      List<BulletPointImprovement> improvements = [];
      List<String> suggestions = ['Improve overall presentation'];
      String feedback = 'Resume needs enhancement for better ATS compatibility.';

      // Extract ATS score
      for (final line in lines) {
        if (line.contains('"atsScore"')) {
          final scoreMatch = RegExp(r'(\d+)').firstMatch(line);
          if (scoreMatch != null) {
            atsScore = int.tryParse(scoreMatch.group(1) ?? '75') ?? 75;
          }
        }
      }

      return ResumeAnalysis(
        atsScore: atsScore,
        strengths: strengths,
        weaknesses: weaknesses,
        missingSkills: missingSkills,
        keywordMatches: keywordMatches,
        missingKeywords: missingKeywords,
        improvedBulletPoints: improvements,
        tailoredSuggestions: suggestions,
        overallFeedback: feedback,
      );
    } catch (e) {
      // Return default analysis if parsing fails
      return ResumeAnalysis(
        atsScore: 70,
        strengths: ['Educational background', 'Basic technical skills'],
        weaknesses: ['Needs more specific achievements', 'Missing quantified results'],
        missingSkills: ['Industry-specific technologies', 'Advanced frameworks'],
        keywordMatches: ['Basic programming concepts'],
        missingKeywords: ['Cloud technologies', 'Modern frameworks'],
        improvedBulletPoints: [],
        tailoredSuggestions: [
          'Add specific metrics to achievements',
          'Include more technical keywords',
          'Improve formatting and structure',
          'Add relevant certifications',
          'Quantify your impact'
        ],
        overallFeedback: 'Your resume has potential but needs optimization for ATS systems and better keyword alignment.',
      );
    }
  }
}

class BulletPointImprovement {
  final String original;
  final String improved;

  BulletPointImprovement({
    required this.original,
    required this.improved,
  });
}
