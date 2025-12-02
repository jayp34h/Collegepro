import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:share_plus/share_plus.dart';
import 'groq_service.dart';

class ResumeGeneratorService {

  Future<String> generateAndDownloadResume({
    required ResumeAnalysis analysis,
    required Map<String, dynamic> userData,
  }) async {
    try {
      // Create PDF preserving all original resume content with enhancements
      final pdfFile = await _createPdfResume(userData, analysis);
      
      // Save and share the PDF
      final savedPath = await _savePdfToDevice(pdfFile, userData['name'] ?? 'Student');
      
      return savedPath;
    } catch (e) {
      throw Exception('Failed to generate resume: $e');
    }
  }

  Future<Uint8List> _createPdfResume(Map<String, dynamic> userData, ResumeAnalysis analysis) async {
    final pdf = pw.Document();

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(32),
        build: (pw.Context context) {
          return [
            // Header Section - preserve all contact info from original resume
            _buildHeader(userData),
            pw.SizedBox(height: 20),
            
            // Professional Summary - enhanced but preserving original content
            _buildSection('PROFESSIONAL SUMMARY', [
              pw.Text(
                _generateEnhancedSummary(userData, analysis),
                style: const pw.TextStyle(fontSize: 11, lineSpacing: 1.4),
              ),
            ]),
            pw.SizedBox(height: 15),
            
            // Education Section - preserve original education details
            _buildSection('EDUCATION', _buildEducation(userData)),
            pw.SizedBox(height: 15),
            
            // Skills Section - combine original + missing keywords
            _buildSection('TECHNICAL SKILLS', _buildSkills(userData, analysis)),
            pw.SizedBox(height: 15),
            
            // Experience Section - preserve all original experience
            if (userData['experience'] != null && userData['experience'].toString().isNotEmpty) ...[
              _buildSection('PROFESSIONAL EXPERIENCE', _buildExperience(userData)),
              pw.SizedBox(height: 15),
            ],
            
            // Projects Section - preserve original projects with enhancements
            _buildSection('PROJECTS', _buildProjects(userData)),
            pw.SizedBox(height: 15),
            
            // Certifications Section - preserve all certifications
            if (userData['certifications'] != null && userData['certifications'].toString().isNotEmpty) ...[
              _buildSection('CERTIFICATIONS', _buildCertifications(userData)),
              pw.SizedBox(height: 15),
            ],
            
            // Achievements Section - preserve all achievements
            if (userData['achievements'] != null && userData['achievements'].toString().isNotEmpty) ...[
              _buildSection('ACHIEVEMENTS', _buildAchievements(userData)),
              pw.SizedBox(height: 15),
            ],
            
            // Additional Sections from original resume
            if (userData['languages'] != null && userData['languages'].toString().isNotEmpty) ...[
              _buildSection('LANGUAGES', _buildLanguages(userData)),
              pw.SizedBox(height: 15),
            ],
            
            if (userData['publications'] != null && userData['publications'].toString().isNotEmpty) ...[
              _buildSection('PUBLICATIONS', _buildPublications(userData)),
              pw.SizedBox(height: 15),
            ],
            
            if (userData['volunteering'] != null && userData['volunteering'].toString().isNotEmpty) ...[
              _buildSection('VOLUNTEER EXPERIENCE', _buildVolunteering(userData)),
              pw.SizedBox(height: 15),
            ],
            
            if (userData['awards'] != null && userData['awards'].toString().isNotEmpty) ...[
              _buildSection('AWARDS & HONORS', _buildAwards(userData)),
            ],
          ];
        },
      ),
    );

    return await pdf.save();
  }

  pw.Widget _buildHeader(Map<String, dynamic> userData) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        // Name - ATS friendly format
        pw.Text(
          (userData['name'] ?? 'Student Name').toUpperCase(),
          style: pw.TextStyle(
            fontSize: 22,
            fontWeight: pw.FontWeight.bold,
            color: PdfColors.black,
          ),
        ),
        pw.SizedBox(height: 12),
        
        // Contact Information - ATS friendly without emojis
        pw.Row(
          mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
          children: [
            pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Text('Email: ${userData['email'] ?? 'student@email.com'}', 
                  style: const pw.TextStyle(fontSize: 10)),
                pw.SizedBox(height: 2),
                pw.Text('Phone: ${userData['phone'] ?? '+91 XXXXXXXXXX'}', 
                  style: const pw.TextStyle(fontSize: 10)),
              ],
            ),
            pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Text('Location: ${userData['location'] ?? 'City, State'}', 
                  style: const pw.TextStyle(fontSize: 10)),
                if (userData['linkedin'] != null) ...[
                  pw.SizedBox(height: 2),
                  pw.Text('LinkedIn: ${userData['linkedin']}', 
                    style: const pw.TextStyle(fontSize: 10)),
                ],
              ],
            ),
          ],
        ),
        
        if (userData['github'] != null)
          pw.Padding(
            padding: const pw.EdgeInsets.only(top: 4),
            child: pw.Text('GitHub: ${userData['github']}', 
              style: const pw.TextStyle(fontSize: 10)),
          ),
        
        pw.SizedBox(height: 8),
        pw.Divider(thickness: 1, color: PdfColors.grey600),
      ],
    );
  }

  pw.Widget _buildSection(String title, List<pw.Widget> content) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text(
          title,
          style: pw.TextStyle(
            fontSize: 14,
            fontWeight: pw.FontWeight.bold,
            color: PdfColors.blue800,
          ),
        ),
        pw.SizedBox(height: 8),
        ...content,
      ],
    );
  }

  String _generateEnhancedSummary(Map<String, dynamic> userData, ResumeAnalysis analysis) {
    // Use original summary if provided, otherwise generate enhanced one
    final originalSummary = userData['summary'] ?? userData['objective'] ?? '';
    final role = userData['targetRole'] ?? 'Software Developer';
    final experience = userData['experienceYears'] ?? '0-1';
    final keySkills = analysis.keywordMatches.isNotEmpty 
        ? analysis.keywordMatches.take(4).join(', ')
        : 'Programming, Development, Problem-solving';
    
    if (originalSummary.isNotEmpty) {
      // Enhance the original summary with missing keywords
      final missingKeywords = analysis.missingKeywords.take(3).join(', ');
      return '$originalSummary Enhanced expertise in $missingKeywords with proven track record in delivering high-quality solutions.';
    }
    
    // Generate ATS-friendly summary with keywords
    return 'Results-driven $role with $experience years of experience in software development and technology solutions. '
           'Proficient in $keySkills with demonstrated expertise in delivering scalable applications. '
           'Strong analytical and problem-solving skills with experience in ${analysis.missingKeywords.take(2).join(', ')}. '
           'Seeking to leverage technical expertise and collaborative approach to drive innovation and contribute to organizational growth.';
  }

  List<pw.Widget> _buildEducation(Map<String, dynamic> userData) {
    final education = userData['education'] ?? 'Bachelor of Technology in Computer Science\nUniversity Name, 2024';
    final lines = education.split('\n');
    
    return [
      pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: lines.map((line) => pw.Padding(
          padding: const pw.EdgeInsets.only(bottom: 4),
          child: pw.Text('• $line', style: const pw.TextStyle(fontSize: 11)),
        )).toList(),
      ),
    ];
  }

  List<pw.Widget> _buildSkills(Map<String, dynamic> userData, ResumeAnalysis analysis) {
    final skills = userData['skills'] ?? 'Java, Python, JavaScript, React, Node.js, MySQL, Git';
    final skillsList = skills.split(',').map((s) => s.trim()).toList();
    
    // Add missing keywords from analysis for ATS optimization
    final enhancedSkills = [...skillsList, ...analysis.missingKeywords.take(4)];
    
    // Organize skills by category for better ATS parsing
    final programmingLangs = enhancedSkills.where((skill) => 
      ['Java', 'Python', 'JavaScript', 'C++', 'C#', 'TypeScript', 'Go', 'Rust'].any((lang) => 
        skill.toLowerCase().contains(lang.toLowerCase()))).toList();
    
    final frameworks = enhancedSkills.where((skill) => 
      ['React', 'Angular', 'Vue', 'Node.js', 'Express', 'Spring', 'Django', 'Flask'].any((fw) => 
        skill.toLowerCase().contains(fw.toLowerCase()))).toList();
    
    final databases = enhancedSkills.where((skill) => 
      ['MySQL', 'PostgreSQL', 'MongoDB', 'Redis', 'Oracle', 'SQL Server'].any((db) => 
        skill.toLowerCase().contains(db.toLowerCase()))).toList();
    
    final tools = enhancedSkills.where((skill) => 
      ['Git', 'Docker', 'Kubernetes', 'AWS', 'Azure', 'Jenkins', 'Jira'].any((tool) => 
        skill.toLowerCase().contains(tool.toLowerCase()))).toList();
    
    final otherSkills = enhancedSkills.where((skill) => 
      !programmingLangs.contains(skill) && 
      !frameworks.contains(skill) && 
      !databases.contains(skill) && 
      !tools.contains(skill)).toList();
    
    List<pw.Widget> skillWidgets = [];
    
    // Programming Languages
    if (programmingLangs.isNotEmpty) {
      skillWidgets.add(pw.Text('Programming Languages:', style: pw.TextStyle(fontSize: 10, fontWeight: pw.FontWeight.bold)));
      skillWidgets.add(pw.SizedBox(height: 4));
      skillWidgets.add(pw.Text(programmingLangs.join(' • '), style: const pw.TextStyle(fontSize: 10)));
      skillWidgets.add(pw.SizedBox(height: 8));
    }
    
    // Frameworks & Libraries
    if (frameworks.isNotEmpty) {
      skillWidgets.add(pw.Text('Frameworks & Libraries:', style: pw.TextStyle(fontSize: 10, fontWeight: pw.FontWeight.bold)));
      skillWidgets.add(pw.SizedBox(height: 4));
      skillWidgets.add(pw.Text(frameworks.join(' • '), style: const pw.TextStyle(fontSize: 10)));
      skillWidgets.add(pw.SizedBox(height: 8));
    }
    
    // Databases
    if (databases.isNotEmpty) {
      skillWidgets.add(pw.Text('Databases:', style: pw.TextStyle(fontSize: 10, fontWeight: pw.FontWeight.bold)));
      skillWidgets.add(pw.SizedBox(height: 4));
      skillWidgets.add(pw.Text(databases.join(' • '), style: const pw.TextStyle(fontSize: 10)));
      skillWidgets.add(pw.SizedBox(height: 8));
    }
    
    // Tools & Technologies
    if (tools.isNotEmpty) {
      skillWidgets.add(pw.Text('Tools & Technologies:', style: pw.TextStyle(fontSize: 10, fontWeight: pw.FontWeight.bold)));
      skillWidgets.add(pw.SizedBox(height: 4));
      skillWidgets.add(pw.Text(tools.join(' • '), style: const pw.TextStyle(fontSize: 10)));
      skillWidgets.add(pw.SizedBox(height: 8));
    }
    
    // Other Skills
    if (otherSkills.isNotEmpty) {
      skillWidgets.add(pw.Text('Other Skills:', style: pw.TextStyle(fontSize: 10, fontWeight: pw.FontWeight.bold)));
      skillWidgets.add(pw.SizedBox(height: 4));
      skillWidgets.add(pw.Text(otherSkills.join(' • '), style: const pw.TextStyle(fontSize: 10)));
    }
    
    return skillWidgets;
  }

  List<pw.Widget> _buildExperience(Map<String, dynamic> userData) {
    final experience = userData['experience'] ?? '';
    if (experience.isEmpty) return [];
    
    final experiences = experience.split('\n\n');
    
    List<pw.Widget> experienceWidgets = [];
    
    for (String exp in experiences) {
      final lines = exp.split('\n');
      experienceWidgets.add(
        pw.Padding(
          padding: const pw.EdgeInsets.only(bottom: 12),
          child: pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Text(
                lines.first,
                style: pw.TextStyle(fontSize: 12, fontWeight: pw.FontWeight.bold),
              ),
              ...lines.skip(1).map((line) => pw.Padding(
                padding: const pw.EdgeInsets.only(top: 2, left: 10),
                child: pw.Text('• $line', style: const pw.TextStyle(fontSize: 10)),
              )).toList(),
            ],
          ),
        ),
      );
    }
    
    return experienceWidgets;
  }

  List<pw.Widget> _buildProjects(Map<String, dynamic> userData) {
    final projects = userData['projects'] ?? 'E-commerce Website\n• Built using React and Node.js with responsive design\n• Implemented secure user authentication and payment gateway integration\n• Deployed on AWS with 99% uptime and optimized performance\n• Achieved 40% faster load times through code optimization';
    final projectList = projects.split('\n\n');
    
    List<pw.Widget> projectWidgets = [];
    
    for (String project in projectList) {
      final lines = project.split('\n');
      projectWidgets.add(
        pw.Padding(
          padding: const pw.EdgeInsets.only(bottom: 12),
          child: pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Text(
                lines.first,
                style: pw.TextStyle(fontSize: 12, fontWeight: pw.FontWeight.bold, color: PdfColors.blue800),
              ),
              pw.SizedBox(height: 4),
              ...lines.skip(1).map((line) => pw.Padding(
                padding: const pw.EdgeInsets.only(top: 2, left: 10),
                child: pw.Text(
                  line.startsWith('•') ? line : '• $line', 
                  style: const pw.TextStyle(fontSize: 10),
                  textAlign: pw.TextAlign.left,
                ),
              )).toList(),
            ],
          ),
        ),
      );
    }
    
    return projectWidgets;
  }

  List<pw.Widget> _buildCertifications(Map<String, dynamic> userData) {
    final certifications = userData['certifications'] ?? '';
    if (certifications.isEmpty) return [];
    
    final certList = certifications.split('\n');
    
    List<pw.Widget> certWidgets = [];
    
    for (String cert in certList) {
      certWidgets.add(
        pw.Padding(
          padding: const pw.EdgeInsets.only(bottom: 4),
          child: pw.Text('• $cert', style: const pw.TextStyle(fontSize: 11)),
        ),
      );
    }
    
    return certWidgets;
  }

  List<pw.Widget> _buildAchievements(Map<String, dynamic> userData) {
    final achievements = userData['achievements'] ?? '';
    if (achievements.isEmpty) return [];
    
    final achievementList = achievements.split('\n');
    
    List<pw.Widget> achievementWidgets = [];
    
    for (String achievement in achievementList) {
      achievementWidgets.add(
        pw.Padding(
          padding: const pw.EdgeInsets.only(bottom: 4),
          child: pw.Text('• $achievement', style: const pw.TextStyle(fontSize: 11)),
        ),
      );
    }
    
    return achievementWidgets;
  }

  List<pw.Widget> _buildLanguages(Map<String, dynamic> userData) {
    final languages = userData['languages'] ?? '';
    if (languages.isEmpty) return [];
    
    final languageList = languages.split('\n');
    
    List<pw.Widget> languageWidgets = [];
    
    for (String language in languageList) {
      languageWidgets.add(
        pw.Padding(
          padding: const pw.EdgeInsets.only(bottom: 4),
          child: pw.Text('• $language', style: const pw.TextStyle(fontSize: 11)),
        ),
      );
    }
    
    return languageWidgets;
  }

  List<pw.Widget> _buildPublications(Map<String, dynamic> userData) {
    final publications = userData['publications'] ?? '';
    if (publications.isEmpty) return [];
    
    final publicationList = publications.split('\n\n');
    
    List<pw.Widget> publicationWidgets = [];
    
    for (String publication in publicationList) {
      final lines = publication.split('\n');
      publicationWidgets.add(
        pw.Padding(
          padding: const pw.EdgeInsets.only(bottom: 8),
          child: pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Text(lines.first, style: pw.TextStyle(fontSize: 11, fontWeight: pw.FontWeight.bold)),
              if (lines.length > 1) ...lines.skip(1).map((line) => pw.Text('  $line', style: const pw.TextStyle(fontSize: 10))).toList(),
            ],
          ),
        ),
      );
    }
    
    return publicationWidgets;
  }

  List<pw.Widget> _buildVolunteering(Map<String, dynamic> userData) {
    final volunteering = userData['volunteering'] ?? '';
    if (volunteering.isEmpty) return [];
    
    final volunteerList = volunteering.split('\n\n');
    
    List<pw.Widget> volunteerWidgets = [];
    
    for (String volunteer in volunteerList) {
      final lines = volunteer.split('\n');
      volunteerWidgets.add(
        pw.Padding(
          padding: const pw.EdgeInsets.only(bottom: 12),
          child: pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Text(
                lines.first,
                style: pw.TextStyle(fontSize: 12, fontWeight: pw.FontWeight.bold, color: PdfColors.blue800),
              ),
              pw.SizedBox(height: 4),
              ...lines.skip(1).map((line) => pw.Padding(
                padding: const pw.EdgeInsets.only(top: 2, left: 10),
                child: pw.Text(
                  line.startsWith('•') ? line : '• $line', 
                  style: const pw.TextStyle(fontSize: 10),
                ),
              )).toList(),
            ],
          ),
        ),
      );
    }
    
    return volunteerWidgets;
  }

  List<pw.Widget> _buildAwards(Map<String, dynamic> userData) {
    final awards = userData['awards'] ?? '';
    if (awards.isEmpty) return [];
    
    final awardList = awards.split('\n');
    
    List<pw.Widget> awardWidgets = [];
    
    for (String award in awardList) {
      awardWidgets.add(
        pw.Padding(
          padding: const pw.EdgeInsets.only(bottom: 4),
          child: pw.Text('• $award', style: const pw.TextStyle(fontSize: 11)),
        ),
      );
    }
    
    return awardWidgets;
  }

  Future<String> _savePdfToDevice(Uint8List pdfBytes, String studentName) async {
    try {
      final directory = await getApplicationDocumentsDirectory();
      final fileName = '${studentName.replaceAll(' ', '_')}_Resume_Enhanced.pdf';
      final file = File('${directory.path}/$fileName');
      
      await file.writeAsBytes(pdfBytes);
      
      // Share the file immediately after creation
      await Share.shareXFiles([XFile(file.path)], text: 'Enhanced Resume - $studentName');
      
      return file.path;
    } catch (e) {
      print('Error saving PDF: $e');
      throw Exception('Failed to save PDF: $e');
    }
  }
}
