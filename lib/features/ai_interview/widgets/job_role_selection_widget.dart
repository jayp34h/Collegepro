import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/ai_interview_provider.dart';
import '../models/interview_models.dart';

class JobRoleSelectionWidget extends StatelessWidget {
  const JobRoleSelectionWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<AIInterviewProvider>(
      builder: (context, provider, child) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Select Your Target Job Role',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.white.withOpacity(0.9),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Choose the position you want to practice for. Arya will tailor questions based on your selection.',
              style: TextStyle(
                fontSize: 16,
                color: Colors.white.withOpacity(0.7),
                height: 1.4,
              ),
            ),
            const SizedBox(height: 24),
            ...provider.jobRoles.map((jobRole) => _buildJobRoleCard(
              context,
              jobRole,
              provider.selectedJobRole?.id == jobRole.id,
              () => provider.selectJobRole(jobRole),
            )),
          ],
        );
      },
    );
  }

  Widget _buildJobRoleCard(
    BuildContext context,
    JobRole jobRole,
    bool isSelected,
    VoidCallback onTap,
  ) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: isSelected
                  ? Colors.white.withOpacity(0.2)
                  : Colors.white.withOpacity(0.1),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: isSelected
                    ? Colors.white.withOpacity(0.6)
                    : Colors.white.withOpacity(0.2),
                width: isSelected ? 2 : 1,
              ),
            ),
            child: Row(
              children: [
                Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: isSelected
                          ? [Colors.white, Colors.white.withOpacity(0.8)]
                          : [
                              const Color(0xFF667eea).withOpacity(0.3),
                              const Color(0xFF764ba2).withOpacity(0.3)
                            ],
                    ),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    _getJobRoleIcon(jobRole.id),
                    color: isSelected
                        ? const Color(0xFF667eea)
                        : Colors.white.withOpacity(0.8),
                    size: 24,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        jobRole.title,
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: isSelected ? Colors.white : Colors.white.withOpacity(0.9),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        jobRole.description,
                        style: TextStyle(
                          fontSize: 14,
                          color: isSelected
                              ? Colors.white.withOpacity(0.8)
                              : Colors.white.withOpacity(0.6),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 6,
                        runSpacing: 4,
                        children: jobRole.skills.take(3).map((skill) {
                          return Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? Colors.white.withOpacity(0.2)
                                  : Colors.white.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              skill,
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.white.withOpacity(0.8),
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                    ],
                  ),
                ),
                if (isSelected)
                  Container(
                    width: 24,
                    height: 24,
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.check,
                      color: Color(0xFF667eea),
                      size: 16,
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  IconData _getJobRoleIcon(String jobRoleId) {
    switch (jobRoleId) {
      case 'software_engineer':
        return Icons.code;
      case 'data_scientist':
        return Icons.analytics;
      case 'web_developer':
        return Icons.web;
      case 'mobile_developer':
        return Icons.phone_android;
      case 'product_manager':
        return Icons.business_center;
      case 'ui_ux_designer':
        return Icons.design_services;
      default:
        return Icons.work;
    }
  }
}
