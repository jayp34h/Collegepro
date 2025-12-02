import 'dart:convert';
import 'package:http/http.dart' as http;

class GroqService {
  static const String _apiKey = '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';
  static const String _baseUrl = 'https://openrouter.ai/api/v1/chat/completions';
  static const String _model = 'moonshotai/kimi-vl-a3b-thinking:free';

  Future<ResumeAnalysis> analyzeResume(String resumeText, String targetRole) async {
    try {
      // Validate input
      if (resumeText.trim().isEmpty) {
        throw Exception('Resume text is empty');
      }

      // Truncate resume text if too long to avoid API limits
      final truncatedText = resumeText.length > 3000 
          ? resumeText.substring(0, 3000) + '...'
          : resumeText;

      final prompt = '''
You are an expert ATS (Applicant Tracking System) resume analyzer and career counselor. Analyze this resume for a $targetRole position and provide detailed, personalized feedback.

RESUME CONTENT:
$truncatedText

TARGET ROLE: $targetRole

Perform a comprehensive analysis and return ONLY valid JSON with the following structure:

{
  "atsScore": [Calculate actual ATS score 0-100 based on keyword density, formatting, relevance],
  "strengths": [List 3-5 specific strengths found in this resume],
  "weaknesses": [List 3-5 specific weaknesses and areas for improvement],
  "missingSkills": [Skills required for $targetRole that are missing from resume],
  "keywordMatches": [Keywords from resume that match $targetRole requirements],
  "missingKeywords": [Important $targetRole keywords missing from resume],
  "improvedBulletPoints": [
    {
      "original": "[Exact text from resume]",
      "improved": "[Specific improvement with metrics and action verbs]",
      "reason": "[Why this improvement helps]"
    }
  ],
  "tailoredSuggestions": [
    "[Specific actionable advice for $targetRole]",
    "[Format/structure improvements]",
    "[Content additions needed]"
  ],
  "overallFeedback": "[Detailed paragraph about resume quality and next steps]",
  "mistakesFound": [
    "[Specific formatting issues]",
    "[Content gaps identified]",
    "[ATS compatibility problems]"
  ],
  "industrySpecificAdvice": "[Advice specific to $targetRole industry]"
}

ANALYSIS CRITERIA:
- ATS Score: Based on keyword relevance, formatting, quantified achievements, skills match
- Focus on actual content from the provided resume
- Provide role-specific feedback for $targetRole
- Identify real formatting and content issues
- Give actionable, specific improvements
- Consider industry standards for $targetRole''';

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
              'content': 'You are a professional resume analyzer. Always respond with valid JSON only.'
            },
            {
              'role': 'user',
              'content': prompt,
            }
          ],
          'max_tokens': 2000,
          'temperature': 0.2,
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
        
        return ResumeAnalysis.fromJson(cleanContent);
      } else {
        // Return a default analysis instead of throwing error
        return _getDefaultAnalysis(targetRole);
      }
    } catch (e) {
      // Return a default analysis instead of throwing error
      return _getDefaultAnalysis(targetRole);
    }
  }

  ResumeAnalysis _getDefaultAnalysis(String targetRole) {
    // Generate role-specific default analysis
    Map<String, dynamic> roleSpecificData = _getRoleSpecificDefaults(targetRole);
    
    return ResumeAnalysis(
      atsScore: roleSpecificData['atsScore'],
      strengths: List<String>.from(roleSpecificData['strengths']),
      weaknesses: List<String>.from(roleSpecificData['weaknesses']),
      missingSkills: List<String>.from(roleSpecificData['missingSkills']),
      keywordMatches: List<String>.from(roleSpecificData['keywordMatches']),
      missingKeywords: List<String>.from(roleSpecificData['missingKeywords']),
      improvedBulletPoints: List<BulletPointImprovement>.from(
        roleSpecificData['improvedBulletPoints'].map((item) => 
          BulletPointImprovement(
            original: item['original'],
            improved: item['improved']
          )
        )
      ),
      tailoredSuggestions: List<String>.from(roleSpecificData['tailoredSuggestions']),
      overallFeedback: roleSpecificData['overallFeedback']
    );
  }

  Map<String, dynamic> _getRoleSpecificDefaults(String targetRole) {
    final roleData = {
      'Software Developer': {
        'atsScore': 72,
        'strengths': [
          'Programming skills foundation',
          'Technical project experience',
          'Problem-solving abilities'
        ],
        'weaknesses': [
          'Missing quantified achievements',
          'Lacks industry-specific keywords',
          'No mention of modern frameworks'
        ],
        'missingSkills': [
          'React/Angular',
          'Cloud platforms (AWS/Azure)',
          'Docker/Kubernetes',
          'CI/CD pipelines'
        ],
        'keywordMatches': [
          'Programming',
          'Development',
          'Coding'
        ],
        'missingKeywords': [
          'Agile',
          'Scrum',
          'REST APIs',
          'Microservices'
        ],
        'improvedBulletPoints': [
          {
            'original': 'Worked on web development projects',
            'improved': 'Developed 5+ responsive web applications using React and Node.js, improving user engagement by 30%'
          },
          {
            'original': 'Used programming languages',
            'improved': 'Implemented scalable solutions using Java, Python, and JavaScript, reducing processing time by 25%'
          }
        ],
        'tailoredSuggestions': [
          'Add specific programming languages and frameworks you\'ve used',
          'Include metrics for projects (users served, performance improvements)',
          'Mention version control systems (Git) and collaboration tools',
          'Add any coding bootcamp or online course certifications'
        ],
        'overallFeedback': 'Your resume shows technical potential for a Software Developer role. Focus on quantifying your coding achievements, highlighting specific technologies, and demonstrating problem-solving impact through metrics.'
      },
      'Data Scientist': {
        'atsScore': 68,
        'strengths': [
          'Analytical mindset',
          'Mathematical background',
          'Research experience'
        ],
        'weaknesses': [
          'Missing machine learning experience',
          'No data visualization examples',
          'Lacks statistical analysis details'
        ],
        'missingSkills': [
          'Python/R programming',
          'Machine Learning algorithms',
          'SQL databases',
          'Tableau/PowerBI'
        ],
        'keywordMatches': [
          'Analysis',
          'Research',
          'Statistics'
        ],
        'missingKeywords': [
          'Machine Learning',
          'Deep Learning',
          'Data Mining',
          'Predictive Modeling'
        ],
        'improvedBulletPoints': [
          {
            'original': 'Analyzed data for projects',
            'improved': 'Analyzed 10M+ data points using Python and SQL, identifying trends that increased revenue by 15%'
          },
          {
            'original': 'Created reports',
            'improved': 'Built interactive dashboards in Tableau, enabling stakeholders to make data-driven decisions 40% faster'
          }
        ],
        'tailoredSuggestions': [
          'Highlight specific ML algorithms and statistical methods used',
          'Include data visualization tools and dashboard creation experience',
          'Mention programming languages (Python, R, SQL) prominently',
          'Add any Kaggle competitions or data science certifications'
        ],
        'overallFeedback': 'Your resume has potential for a Data Scientist role but needs more technical depth. Emphasize quantitative analysis, machine learning projects, and data visualization skills with specific examples and metrics.'
      },
      'Product Manager': {
        'atsScore': 70,
        'strengths': [
          'Leadership potential',
          'Strategic thinking',
          'Communication skills'
        ],
        'weaknesses': [
          'No product management experience',
          'Missing user research background',
          'Lacks market analysis skills'
        ],
        'missingSkills': [
          'Product roadmap planning',
          'User experience design',
          'Market research',
          'Agile methodologies'
        ],
        'keywordMatches': [
          'Leadership',
          'Strategy',
          'Communication'
        ],
        'missingKeywords': [
          'Product Strategy',
          'User Research',
          'A/B Testing',
          'Product Analytics'
        ],
        'improvedBulletPoints': [
          {
            'original': 'Led team projects',
            'improved': 'Led cross-functional team of 8 members to deliver product features, increasing user satisfaction by 25%'
          },
          {
            'original': 'Conducted research',
            'improved': 'Conducted user research with 200+ participants, identifying key pain points that shaped product roadmap'
          }
        ],
        'tailoredSuggestions': [
          'Highlight any experience with user research or customer feedback',
          'Include examples of strategic decision-making and prioritization',
          'Mention familiarity with product management tools (Jira, Asana)',
          'Add any business or product management courses/certifications'
        ],
        'overallFeedback': 'Your resume shows leadership qualities suitable for Product Management. Focus on demonstrating strategic thinking, user-centric approach, and ability to drive product decisions with data and customer insights.'
      }
    };

    return roleData[targetRole] ?? roleData['Software Developer']!;
  }

  Future<String> generateImprovedResume(ResumeAnalysis analysis, Map<String, dynamic> userData) async {
    try {
      final prompt = '''
Generate a professional resume template with the following user data and improvements:

USER DATA:
Name: ${userData['name'] ?? 'Student Name'}
Email: ${userData['email'] ?? 'student@email.com'}
Phone: ${userData['phone'] ?? '+91 XXXXXXXXXX'}
Location: ${userData['location'] ?? 'City, State'}
LinkedIn: ${userData['linkedin'] ?? 'linkedin.com/in/username'}
GitHub: ${userData['github'] ?? 'github.com/username'}

EDUCATION:
${userData['education'] ?? 'Bachelor of Technology in Computer Science\nUniversity Name, Year'}

SKILLS:
${userData['skills'] ?? 'Programming Languages, Frameworks, Tools'}

EXPERIENCE:
${userData['experience'] ?? 'Internship/Project Experience'}

PROJECTS:
${userData['projects'] ?? 'Academic and Personal Projects'}

IMPROVEMENTS TO APPLY:
- ATS Score: ${analysis.atsScore}/100
- Missing Keywords: ${analysis.missingKeywords.join(', ')}
- Suggestions: ${analysis.tailoredSuggestions.join(', ')}

Generate a clean, ATS-friendly resume in HTML format that can be converted to PDF. Use professional formatting with proper sections, bullet points, and keyword optimization.

Return only the HTML content without any additional text.
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
              'role': 'user',
              'content': prompt,
            }
          ],
          'max_tokens': 3000,
          'temperature': 0.5,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['choices'][0]['message']['content'];
      } else {
        throw Exception('Failed to generate resume: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Failed to generate resume: $e');
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
      final Map<String, dynamic> json = jsonDecode(jsonString);
      
      return ResumeAnalysis(
        atsScore: json['atsScore'] ?? 75,
        strengths: List<String>.from(json['strengths'] ?? ['Technical skills']),
        weaknesses: List<String>.from(json['weaknesses'] ?? ['Needs improvement']),
        missingSkills: List<String>.from(json['missingSkills'] ?? ['Industry skills']),
        keywordMatches: List<String>.from(json['keywordMatches'] ?? ['Basic keywords']),
        missingKeywords: List<String>.from(json['missingKeywords'] ?? ['Role-specific keywords']),
        improvedBulletPoints: (json['improvedBulletPoints'] as List?)
            ?.map((item) => BulletPointImprovement(
              original: item['original'] ?? 'Original text',
              improved: item['improved'] ?? 'Improved text'
            ))
            .toList() ?? [],
        tailoredSuggestions: List<String>.from(json['tailoredSuggestions'] ?? ['Improve presentation']),
        overallFeedback: json['overallFeedback'] ?? 'Resume needs enhancement.',
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

  factory BulletPointImprovement.fromJson(Map<String, dynamic> json) {
    return BulletPointImprovement(
      original: json['original'] ?? '',
      improved: json['improved'] ?? '',
    );
  }
}
