import 'dart:io';

class FileUtils {
  /// Extract text content from various file types
  static Future<String> extractTextFromFile(File file) async {
    try {
      final extension = file.path.split('.').last.toLowerCase();
      
      switch (extension) {
        case 'pdf':
          return await _extractTextFromPdf(file);
        case 'docx':
        case 'doc':
          return await _extractTextFromDocx(file);
        case 'txt':
          return await file.readAsString();
        default:
          throw UnsupportedError('File type $extension is not supported');
      }
    } catch (e) {
      throw Exception('Failed to extract text from file: $e');
    }
  }

  /// Extract text from PDF file
  static Future<String> _extractTextFromPdf(File file) async {
    try {
      // For now, return a sample text since PDF text extraction requires additional packages
      // In a real implementation, you would use packages like 'pdf_text' or 'syncfusion_flutter_pdf'
      final bytes = await file.readAsBytes();
      
      // Basic PDF validation
      if (bytes.length < 4 || 
          String.fromCharCodes(bytes.take(4)) != '%PDF') {
        throw Exception('Invalid PDF file format');
      }
      
      // Return sample extracted content for demonstration
      return '''
John Doe
Software Developer
Email: john.doe@email.com
Phone: +1-234-567-8900

PROFESSIONAL SUMMARY
Experienced software developer with 3+ years of expertise in full-stack web development.
Proficient in modern frameworks and technologies including React, Node.js, and cloud platforms.

TECHNICAL SKILLS
• Programming Languages: JavaScript, Python, Java, TypeScript
• Frontend: React, Vue.js, HTML5, CSS3, Bootstrap
• Backend: Node.js, Express.js, Django, Spring Boot
• Databases: MongoDB, PostgreSQL, MySQL
• Cloud: AWS, Azure, Docker, Kubernetes
• Tools: Git, Jenkins, JIRA, VS Code

PROFESSIONAL EXPERIENCE
Senior Software Developer | Tech Solutions Inc. | 2022 - Present
• Developed and maintained 5+ web applications serving 10,000+ users
• Implemented microservices architecture reducing system latency by 40%
• Led a team of 3 junior developers on critical project deliveries
• Collaborated with cross-functional teams to deliver features on time

Software Developer | StartupXYZ | 2021 - 2022
• Built responsive web applications using React and Node.js
• Integrated third-party APIs and payment gateways
• Optimized database queries improving performance by 25%
• Participated in code reviews and agile development processes

EDUCATION
Bachelor of Science in Computer Science
University of Technology | 2017 - 2021
GPA: 3.8/4.0

PROJECTS
E-Commerce Platform
• Developed full-stack e-commerce solution with React and Node.js
• Implemented secure payment processing and user authentication
• Deployed on AWS with CI/CD pipeline

Task Management App
• Created collaborative task management application
• Used React, Express.js, and MongoDB
• Implemented real-time notifications using WebSocket

CERTIFICATIONS
• AWS Certified Developer Associate (2023)
• Google Cloud Professional Developer (2022)
• Certified Scrum Master (2021)
''';
    } catch (e) {
      throw Exception('Failed to extract text from PDF: $e');
    }
  }

  /// Extract text from DOCX file
  static Future<String> _extractTextFromDocx(File file) async {
    try {
      // For now, return a sample text since DOCX text extraction requires additional packages
      // In a real implementation, you would use packages like 'docx_to_text' or similar
      final bytes = await file.readAsBytes();
      
      // Basic DOCX validation (ZIP file signature)
      if (bytes.length < 4 || 
          !(bytes[0] == 0x50 && bytes[1] == 0x4B)) {
        throw Exception('Invalid DOCX file format');
      }
      
      // Return sample extracted content for demonstration
      return '''
Jane Smith
Data Scientist
Email: jane.smith@email.com
Phone: +1-987-654-3210

PROFESSIONAL SUMMARY
Data scientist with 4+ years of experience in machine learning, statistical analysis, and data visualization.
Expertise in Python, R, and cloud-based analytics platforms.

TECHNICAL SKILLS
• Programming: Python, R, SQL, Scala
• Machine Learning: Scikit-learn, TensorFlow, PyTorch, Keras
• Data Visualization: Matplotlib, Seaborn, Plotly, Tableau
• Big Data: Spark, Hadoop, Kafka
• Cloud Platforms: AWS, GCP, Azure
• Databases: PostgreSQL, MongoDB, Cassandra

PROFESSIONAL EXPERIENCE
Senior Data Scientist | DataCorp Analytics | 2021 - Present
• Developed predictive models improving customer retention by 35%
• Led data science initiatives for 3 major client projects
• Implemented MLOps pipelines reducing model deployment time by 60%
• Mentored junior data scientists and conducted technical workshops

Data Scientist | AI Innovations Ltd | 2020 - 2021
• Built recommendation systems using collaborative filtering
• Performed statistical analysis on large datasets (10M+ records)
• Created interactive dashboards for business stakeholders
• Collaborated with engineering teams on model productionization

EDUCATION
Master of Science in Data Science
Institute of Technology | 2018 - 2020
Thesis: "Deep Learning Applications in Natural Language Processing"

Bachelor of Science in Statistics
State University | 2014 - 2018
Magna Cum Laude, GPA: 3.9/4.0

PROJECTS
Customer Churn Prediction
• Developed ML model with 92% accuracy using ensemble methods
• Processed and analyzed customer behavior data
• Deployed model using Flask API and Docker containers

Sentiment Analysis Tool
• Built NLP pipeline for social media sentiment analysis
• Used BERT and transformer models for text classification
• Created real-time dashboard for monitoring brand sentiment

PUBLICATIONS
• "Advanced Techniques in Predictive Analytics" - Journal of Data Science (2023)
• "Machine Learning in Customer Analytics" - Conference Proceedings (2022)

CERTIFICATIONS
• AWS Certified Machine Learning Specialty (2023)
• Google Cloud Professional Data Engineer (2022)
• Certified Analytics Professional (CAP) (2021)
''';
    } catch (e) {
      throw Exception('Failed to extract text from DOCX: $e');
    }
  }

  /// Validate file size and type
  static bool isValidResumeFile(File file) {
    try {
      // Check file size (max 10MB)
      final fileSizeInBytes = file.lengthSync();
      final fileSizeInMB = fileSizeInBytes / (1024 * 1024);
      
      if (fileSizeInMB > 10) {
        return false;
      }
      
      // Check file extension
      final extension = file.path.split('.').last.toLowerCase();
      final allowedExtensions = ['pdf', 'docx', 'doc', 'txt'];
      
      return allowedExtensions.contains(extension);
    } catch (e) {
      return false;
    }
  }

  /// Get file size in human readable format
  static String getFileSizeString(File file) {
    try {
      final bytes = file.lengthSync();
      
      if (bytes < 1024) {
        return '$bytes B';
      } else if (bytes < 1024 * 1024) {
        return '${(bytes / 1024).toStringAsFixed(1)} KB';
      } else {
        return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
      }
    } catch (e) {
      return 'Unknown size';
    }
  }

  /// Get file type icon
  static String getFileTypeIcon(String fileName) {
    final extension = fileName.split('.').last.toLowerCase();
    
    switch (extension) {
      case 'pdf':
        return '📄';
      case 'docx':
      case 'doc':
        return '📝';
      case 'txt':
        return '📋';
      default:
        return '📁';
    }
  }
}
