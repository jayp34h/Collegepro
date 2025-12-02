import 'package:flutter/material.dart';
import '../../../core/services/groq_service.dart';

class UserDataForm extends StatefulWidget {
  final Map<String, dynamic> initialData;
  final String targetRole;
  final ResumeAnalysis analysis;

  const UserDataForm({
    super.key,
    required this.initialData,
    required this.targetRole,
    required this.analysis,
  });

  @override
  State<UserDataForm> createState() => _UserDataFormState();
}

class _UserDataFormState extends State<UserDataForm> {
  final _formKey = GlobalKey<FormState>();
  late final Map<String, TextEditingController> _controllers;

  @override
  void initState() {
    super.initState();
    _controllers = {
      'name': TextEditingController(text: widget.initialData['name'] ?? ''),
      'email': TextEditingController(text: widget.initialData['email'] ?? ''),
      'phone': TextEditingController(text: widget.initialData['phone'] ?? ''),
      'location': TextEditingController(text: widget.initialData['location'] ?? ''),
      'linkedin': TextEditingController(text: widget.initialData['linkedin'] ?? ''),
      'github': TextEditingController(text: widget.initialData['github'] ?? ''),
      'education': TextEditingController(text: widget.initialData['education'] ?? ''),
      'skills': TextEditingController(text: widget.initialData['skills'] ?? ''),
      'experience': TextEditingController(text: widget.initialData['experience'] ?? ''),
      'projects': TextEditingController(text: widget.initialData['projects'] ?? ''),
      'certifications': TextEditingController(text: widget.initialData['certifications'] ?? ''),
      'achievements': TextEditingController(text: widget.initialData['achievements'] ?? ''),
    };
  }

  @override
  void dispose() {
    _controllers.values.forEach((controller) => controller.dispose());
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final screenSize = MediaQuery.of(context).size;
    final isSmallScreen = screenSize.width < 600;
    
    return Dialog(
      insetPadding: EdgeInsets.all(isSmallScreen ? 16 : 24),
      child: Container(
        width: double.infinity,
        height: screenSize.height * 0.95,
        padding: EdgeInsets.all(isSmallScreen ? 16 : 24),
        child: Column(
          children: [
            // Header
            Row(
              children: [
                Icon(Icons.person_add, color: theme.primaryColor, size: 28),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Complete Your Profile',
                        style: theme.textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                          fontSize: isSmallScreen ? 18 : 22,
                        ),
                      ),
                      Text(
                        'Fill in your details to generate an enhanced resume',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: Colors.grey[600],
                          fontSize: isSmallScreen ? 12 : 14,
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  onPressed: () => Navigator.of(context).pop(),
                  icon: const Icon(Icons.close),
                ),
              ],
            ),
            const Divider(height: 32),
            
            // Form
            Expanded(
              child: Form(
                key: _formKey,
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Personal Information
                      _buildSectionHeader('Personal Information', Icons.person),
                      SizedBox(height: isSmallScreen ? 12 : 16),
                      isSmallScreen 
                        ? Column(
                            children: [
                              _buildTextField(
                                'name',
                                'Full Name',
                                Icons.person_outline,
                                required: true,
                              ),
                              const SizedBox(height: 12),
                              _buildTextField(
                                'email',
                                'Email Address',
                                Icons.email_outlined,
                                required: true,
                                keyboardType: TextInputType.emailAddress,
                              ),
                            ],
                          )
                        : Row(
                            children: [
                              Expanded(
                                child: _buildTextField(
                                  'name',
                                  'Full Name',
                                  Icons.person_outline,
                                  required: true,
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: _buildTextField(
                                  'email',
                                  'Email Address',
                                  Icons.email_outlined,
                                  required: true,
                                  keyboardType: TextInputType.emailAddress,
                                ),
                              ),
                            ],
                          ),
                      SizedBox(height: isSmallScreen ? 12 : 16),
                      isSmallScreen 
                        ? Column(
                            children: [
                              _buildTextField(
                                'phone',
                                'Phone Number',
                                Icons.phone_outlined,
                                required: true,
                                keyboardType: TextInputType.phone,
                              ),
                              const SizedBox(height: 12),
                              _buildTextField(
                                'location',
                                'Location (City, State)',
                                Icons.location_on_outlined,
                                required: true,
                              ),
                            ],
                          )
                        : Row(
                            children: [
                              Expanded(
                                child: _buildTextField(
                                  'phone',
                                  'Phone Number',
                                  Icons.phone_outlined,
                                  required: true,
                                  keyboardType: TextInputType.phone,
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: _buildTextField(
                                  'location',
                                  'Location (City, State)',
                                  Icons.location_on_outlined,
                                  required: true,
                                ),
                              ),
                            ],
                          ),
                      SizedBox(height: isSmallScreen ? 12 : 16),
                      isSmallScreen 
                        ? Column(
                            children: [
                              _buildTextField(
                                'linkedin',
                                'LinkedIn Profile (Optional)',
                                Icons.link_outlined,
                                hintText: 'linkedin.com/in/yourprofile',
                              ),
                              const SizedBox(height: 12),
                              _buildTextField(
                                'github',
                                'GitHub Profile (Optional)',
                                Icons.code_outlined,
                                hintText: 'github.com/yourusername',
                              ),
                            ],
                          )
                        : Row(
                            children: [
                              Expanded(
                                child: _buildTextField(
                                  'linkedin',
                                  'LinkedIn Profile (Optional)',
                                  Icons.link_outlined,
                                  hintText: 'linkedin.com/in/yourprofile',
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: _buildTextField(
                                  'github',
                                  'GitHub Profile (Optional)',
                                  Icons.code_outlined,
                                  hintText: 'github.com/yourusername',
                                ),
                              ),
                            ],
                          ),
                      
                      SizedBox(height: isSmallScreen ? 20 : 32),
                      
                      // Education
                      _buildSectionHeader('Education', Icons.school),
                      const SizedBox(height: 16),
                      _buildTextField(
                        'education',
                        'Education Details',
                        Icons.school_outlined,
                        required: true,
                        maxLines: 3,
                        hintText: 'Bachelor of Technology in Computer Science\nUniversity Name, Year of Graduation\nCGPA: X.X/10.0',
                      ),
                      
                      SizedBox(height: isSmallScreen ? 20 : 32),
                      
                      // Skills with AI suggestions
                      _buildSectionHeader('Technical Skills', Icons.code),
                      const SizedBox(height: 8),
                      if (widget.analysis.missingKeywords.isNotEmpty)
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.blue.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: Colors.blue.withOpacity(0.3)),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Icon(Icons.lightbulb_outlined, color: Colors.blue, size: 16),
                                  const SizedBox(width: 8),
                                  Text(
                                    'AI Suggestions for ${widget.targetRole}:',
                                    style: theme.textTheme.bodySmall?.copyWith(
                                      fontWeight: FontWeight.w600,
                                      color: Colors.blue[700],
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              Wrap(
                                spacing: 8,
                                runSpacing: 4,
                                children: widget.analysis.missingKeywords.take(6).map((skill) => 
                                  GestureDetector(
                                    onTap: () => _addSkillToField(skill),
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                      decoration: BoxDecoration(
                                        color: Colors.blue.withOpacity(0.2),
                                        borderRadius: BorderRadius.circular(12),
                                        border: Border.all(color: Colors.blue.withOpacity(0.5)),
                                      ),
                                      child: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Text(
                                            skill,
                                            style: theme.textTheme.bodySmall?.copyWith(
                                              color: Colors.blue[700],
                                              fontSize: 11,
                                            ),
                                          ),
                                          const SizedBox(width: 4),
                                          Icon(Icons.add, size: 12, color: Colors.blue[700]),
                                        ],
                                      ),
                                    ),
                                  ),
                                ).toList(),
                              ),
                            ],
                          ),
                        ),
                      const SizedBox(height: 16),
                      _buildTextField(
                        'skills',
                        'Technical Skills',
                        Icons.code_outlined,
                        required: true,
                        maxLines: 3,
                        hintText: 'Java, Python, JavaScript, React, Node.js, MySQL, Git, AWS, Docker',
                      ),
                      
                      SizedBox(height: isSmallScreen ? 20 : 32),
                      
                      // Experience
                      _buildSectionHeader('Experience', Icons.work),
                      const SizedBox(height: 16),
                      _buildTextField(
                        'experience',
                        'Work Experience (Optional)',
                        Icons.work_outline,
                        maxLines: 5,
                        hintText: 'Software Development Intern\nCompany Name, Duration\n• Developed web applications using React and Node.js\n• Collaborated with team of 5 developers\n• Improved application performance by 25%',
                      ),
                      
                      SizedBox(height: isSmallScreen ? 20 : 32),
                      
                      // Projects
                      _buildSectionHeader('Projects', Icons.folder),
                      const SizedBox(height: 16),
                      _buildTextField(
                        'projects',
                        'Projects',
                        Icons.folder_outlined,
                        required: true,
                        maxLines: 5,
                        hintText: 'E-commerce Website\n• Built using React and Node.js\n• Implemented user authentication and payment gateway\n• Deployed on AWS with 99% uptime\n\nMobile App Development\n• Created using Flutter and Firebase\n• Published on Google Play Store',
                      ),
                      
                      SizedBox(height: isSmallScreen ? 20 : 32),
                      
                      // Optional sections
                      _buildSectionHeader('Additional Information (Optional)', Icons.add_circle_outline),
                      const SizedBox(height: 16),
                      _buildTextField(
                        'certifications',
                        'Certifications',
                        Icons.verified_outlined,
                        maxLines: 3,
                        hintText: 'AWS Certified Developer\nGoogle Cloud Professional\nOracle Java Certification',
                      ),
                      const SizedBox(height: 16),
                      _buildTextField(
                        'achievements',
                        'Achievements & Awards',
                        Icons.emoji_events_outlined,
                        maxLines: 3,
                        hintText: 'Winner of National Coding Competition 2023\nDean\'s List for Academic Excellence\nOpen Source Contributor with 100+ commits',
                      ),
                    ],
                  ),
                ),
              ),
            ),
            
            // Action buttons
            Divider(height: isSmallScreen ? 24 : 32),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: const Text('Cancel'),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  flex: 2,
                  child: ElevatedButton.icon(
                    onPressed: _generateResume,
                    icon: const Icon(Icons.auto_awesome),
                    label: Text(isSmallScreen ? 'Generate Resume' : 'Generate Enhanced Resume'),
                    style: ElevatedButton.styleFrom(
                      padding: EdgeInsets.symmetric(vertical: isSmallScreen ? 12 : 16),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title, IconData icon) {
    return Row(
      children: [
        Icon(icon, size: 20, color: Theme.of(context).primaryColor),
        const SizedBox(width: 8),
        Text(
          title,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
            color: Theme.of(context).primaryColor,
          ),
        ),
      ],
    );
  }

  Widget _buildTextField(
    String key,
    String label,
    IconData icon, {
    bool required = false,
    int maxLines = 1,
    String? hintText,
    TextInputType? keyboardType,
  }) {
    final screenSize = MediaQuery.of(context).size;
    final isSmallScreen = screenSize.width < 600;
    
    return TextFormField(
      controller: _controllers[key],
      decoration: InputDecoration(
        labelText: required ? '$label *' : label,
        hintText: hintText,
        prefixIcon: Icon(icon, size: isSmallScreen ? 18 : 20),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        contentPadding: EdgeInsets.symmetric(
          horizontal: isSmallScreen ? 12 : 16, 
          vertical: isSmallScreen ? 10 : 12
        ),
        labelStyle: TextStyle(fontSize: isSmallScreen ? 13 : 14),
        hintStyle: TextStyle(fontSize: isSmallScreen ? 12 : 13),
      ),
      maxLines: maxLines,
      keyboardType: keyboardType,
      style: TextStyle(fontSize: isSmallScreen ? 13 : 14),
      validator: required ? (value) {
        if (value == null || value.trim().isEmpty) {
          return 'This field is required';
        }
        return null;
      } : null,
    );
  }

  void _addSkillToField(String skill) {
    final currentSkills = _controllers['skills']!.text;
    if (!currentSkills.toLowerCase().contains(skill.toLowerCase())) {
      final newSkills = currentSkills.isEmpty 
          ? skill 
          : '$currentSkills, $skill';
      _controllers['skills']!.text = newSkills;
    }
  }

  void _generateResume() {
    if (_formKey.currentState!.validate()) {
      final userData = <String, dynamic>{};
      _controllers.forEach((key, controller) {
        userData[key] = controller.text.trim();
      });
      
      // Add target role
      userData['targetRole'] = widget.targetRole;
      
      Navigator.of(context).pop(userData);
    }
  }
}
