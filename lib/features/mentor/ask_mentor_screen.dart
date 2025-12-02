import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:go_router/go_router.dart';
import '../../core/widgets/modern_side_drawer.dart';
import 'models/mentor_model.dart';

class AskMentorScreen extends StatefulWidget {
  const AskMentorScreen({super.key});

  @override
  State<AskMentorScreen> createState() => _AskMentorScreenState();
}

class _AskMentorScreenState extends State<AskMentorScreen> {
  int _currentMentorIndex = 0;
  late List<MentorModel> _mentors;

  @override
  void initState() {
    super.initState();
    _mentors = MentorModel.getMentors();
  }

  void _switchMentor(int index) {
    setState(() {
      _currentMentorIndex = index;
    });
  }

  Color _getAvatarColor(String colorHex) {
    return Color(int.parse('0xFF$colorHex'));
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF0A0A0A) : const Color(0xFFF8F9FA),
      drawer: const ModernSideDrawer(),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(
          'Meet Your Mentor',
          style: GoogleFonts.inter(
            fontSize: 24,
            fontWeight: FontWeight.w600,
            color: isDark ? Colors.white : Colors.black87,
          ),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            // Mentor Selector
            Container(
              height: 80,
              margin: const EdgeInsets.only(bottom: 20),
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: _mentors.length,
                itemBuilder: (context, index) {
                  final mentor = _mentors[index];
                  final isSelected = index == _currentMentorIndex;
                  return GestureDetector(
                    onTap: () => _switchMentor(index),
                    child: Container(
                      width: 70,
                      margin: const EdgeInsets.only(right: 12),
                      child: Column(
                        children: [
                          Container(
                            width: 50,
                            height: 50,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: _getAvatarColor(mentor.avatarColor),
                              border: Border.all(
                                color: isSelected ? Colors.white : Colors.transparent,
                                width: 3,
                              ),
                              boxShadow: isSelected ? [
                                BoxShadow(
                                  color: _getAvatarColor(mentor.avatarColor).withOpacity(0.5),
                                  blurRadius: 10,
                                  offset: const Offset(0, 4),
                                ),
                              ] : null,
                            ),
                            child: Icon(
                              mentor.isOnline ? Icons.person : Icons.person_outline,
                              color: Colors.white,
                              size: 24,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            mentor.name.split(' ')[0],
                            style: GoogleFonts.inter(
                              fontSize: 12,
                              fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                              color: isDark ? Colors.white : Colors.black87,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
            // Mentor Profile Card
            Container(
              width: double.infinity,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: isDark 
                    ? [const Color(0xFF1A1A1A), const Color(0xFF2A2A2A)]
                    : [Colors.white, const Color(0xFFF8F9FA)],
                ),
                borderRadius: BorderRadius.circular(24),
                border: Border.all(
                  color: isDark ? const Color(0xFF333333) : const Color(0xFFE0E0E0),
                ),
                boxShadow: [
                  BoxShadow(
                    color: isDark ? Colors.black26 : Colors.black.withOpacity(0.05),
                    blurRadius: 20,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  children: [
                    // Profile Picture
                    Container(
                      width: 120,
                      height: 120,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: _getAvatarColor(_mentors[_currentMentorIndex].avatarColor),
                        boxShadow: [
                          BoxShadow(
                            color: _getAvatarColor(_mentors[_currentMentorIndex].avatarColor).withOpacity(0.3),
                            blurRadius: 20,
                            offset: const Offset(0, 8),
                          ),
                        ],
                      ),
                      child: Icon(
                        _mentors[_currentMentorIndex].isOnline ? Icons.person : Icons.person_outline,
                        size: 60,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 20),
                    
                    // Name and Status
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          _mentors[_currentMentorIndex].name,
                          style: GoogleFonts.inter(
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                            color: isDark ? Colors.white : Colors.black87,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          width: 12,
                          height: 12,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: _mentors[_currentMentorIndex].isOnline ? Colors.green : Colors.grey,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    
                    // Designation
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      decoration: BoxDecoration(
                        color: _getAvatarColor(_mentors[_currentMentorIndex].avatarColor),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        _mentors[_currentMentorIndex].title,
                        style: GoogleFonts.inter(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    
                    // Bio
                    Text(
                      _mentors[_currentMentorIndex].description,
                      textAlign: TextAlign.center,
                      style: GoogleFonts.inter(
                        fontSize: 16,
                        height: 1.5,
                        color: isDark ? Colors.white70 : Colors.black54,
                      ),
                    ),
                    const SizedBox(height: 24),
                    
                    // Stats Row
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        _buildStatItem('Rating', '${_mentors[_currentMentorIndex].rating}⭐', isDark),
                        _buildStatItem('Response Time', '${_mentors[_currentMentorIndex].responseTime}h', isDark),
                        _buildStatItem('Status', _mentors[_currentMentorIndex].isOnline ? 'Online' : 'Offline', isDark),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            
            const SizedBox(height: 30),
            
            // Expertise Areas
            Container(
              width: double.infinity,
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF1A1A1A) : Colors.white,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: isDark ? const Color(0xFF333333) : const Color(0xFFE0E0E0),
                ),
              ),
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Expertise Areas',
                      style: GoogleFonts.inter(
                        fontSize: 20,
                        fontWeight: FontWeight.w600,
                        color: isDark ? Colors.white : Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Wrap(
                      spacing: 12,
                      runSpacing: 12,
                      children: _mentors[_currentMentorIndex].specializations.map((skill) => Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        decoration: BoxDecoration(
                          color: isDark ? const Color(0xFF2A2A2A) : const Color(0xFFF1F3F4),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: _getAvatarColor(_mentors[_currentMentorIndex].avatarColor).withOpacity(0.3),
                          ),
                        ),
                        child: Text(
                          skill,
                          style: GoogleFonts.inter(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                            color: isDark ? Colors.white70 : Colors.black87,
                          ),
                        ),
                      )).toList(),
                    ),
                  ],
                ),
              ),
            ),
            
            const SizedBox(height: 30),
            
            // Ask Career Doubt Button
            Container(
              width: double.infinity,
              height: 60,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF6366F1), Color(0xFF8B5CF6)],
                ),
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF6366F1).withOpacity(0.3),
                    blurRadius: 20,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  borderRadius: BorderRadius.circular(20),
                  onTap: () {
                    context.push('/doubt-screen');
                  },
                  child: Center(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(
                          Icons.help_outline_rounded,
                          color: Colors.white,
                          size: 24,
                        ),
                        const SizedBox(width: 12),
                        Text(
                          'Ask Career Doubt',
                          style: GoogleFonts.inter(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            
            const SizedBox(height: 20),
            
            // Contact Info
            Container(
              width: double.infinity,
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF1A1A1A) : Colors.white,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: isDark ? const Color(0xFF333333) : const Color(0xFFE0E0E0),
                ),
              ),
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Available Hours',
                      style: GoogleFonts.inter(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: isDark ? Colors.white : Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Icon(
                          Icons.schedule,
                          color: isDark ? Colors.white70 : Colors.black54,
                          size: 20,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Monday - Friday: 6:00 PM - 9:00 PM',
                          style: GoogleFonts.inter(
                            fontSize: 14,
                            color: isDark ? Colors.white70 : Colors.black54,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Icon(
                          Icons.schedule,
                          color: isDark ? Colors.white70 : Colors.black54,
                          size: 20,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Saturday - Sunday: 2:00 PM - 6:00 PM',
                          style: GoogleFonts.inter(
                            fontSize: 14,
                            color: isDark ? Colors.white70 : Colors.black54,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildStatItem(String label, String value, bool isDark) {
    return Column(
      children: [
        Text(
          value,
          style: GoogleFonts.inter(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: const Color(0xFF6366F1),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: GoogleFonts.inter(
            fontSize: 12,
            color: isDark ? Colors.white60 : Colors.black45,
          ),
        ),
      ],
    );
  }
}
