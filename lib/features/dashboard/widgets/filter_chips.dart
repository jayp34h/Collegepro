import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/providers/project_provider.dart';

class FilterChips extends StatelessWidget {
  const FilterChips({super.key});

  @override
  Widget build(BuildContext context) {
    const educationalBlue = Color(0xFF2E5BBA);
    const educationalGreen = Color(0xFF2E7D32);
    const educationalOrange = Color(0xFFFF6F00);
    const educationalPurple = Color(0xFF6A1B9A);
    
    return Consumer<ProjectProvider>(
      builder: (context, projectProvider, child) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Technology/Domain Filters
            _buildFilterSection(
              context,
              title: '💻 Technology Domains',
              titleColor: educationalBlue,
              items: [
                'Web Development',
                'Mobile Apps',
                'AI & Machine Learning',
                'Data Science',
                'Blockchain',
                'IoT',
                'Game Development',
                'Cloud Computing',
              ],
              selectedItems: projectProvider.selectedDomains.toList(),
              onToggle: projectProvider.toggleDomainFilter,
              chipColor: educationalBlue,
            ),
            
            const SizedBox(height: 20),
            
            // Difficulty Filters
            _buildFilterSection(
              context,
              title: '📊 Difficulty Level',
              titleColor: educationalGreen,
              items: [
                'Beginner',
                'Intermediate',
                'Advanced',
                'Expert',
              ],
              selectedItems: projectProvider.selectedDifficulties.toList(),
              onToggle: projectProvider.toggleDifficultyFilter,
              chipColor: educationalGreen,
            ),
            
            const SizedBox(height: 20),
            
            // Project Type Filters
            _buildFilterSection(
              context,
              title: '🎯 Project Type',
              titleColor: educationalOrange,
              items: [
                'Research Project',
                'Industry Project',
                'Open Source',
                'Startup Idea',
                'Academic Study',
                'Innovation',
              ],
              selectedItems: projectProvider.selectedCareerPaths.toList(),
              onToggle: projectProvider.toggleCareerPathFilter,
              chipColor: educationalOrange,
            ),
            
            const SizedBox(height: 20),
            
            // Duration Filters
            _buildFilterSection(
              context,
              title: '⏱️ Project Duration',
              titleColor: educationalPurple,
              items: [
                '1-3 Months',
                '3-6 Months',
                '6-12 Months',
                '1+ Year',
              ],
              selectedItems: [], // Add duration filter to provider if needed
              onToggle: (item) {}, // Implement duration filter
              chipColor: educationalPurple,
            ),
            
            const SizedBox(height: 24),
            
            // Clear Filters Button
            if (_hasActiveFilters(projectProvider)) ...[
              Center(
                child: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        educationalBlue.withOpacity(0.1),
                        educationalGreen.withOpacity(0.1),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(25),
                    border: Border.all(
                      color: educationalBlue.withOpacity(0.3),
                    ),
                  ),
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      onTap: () => projectProvider.clearAllFilters(),
                      borderRadius: BorderRadius.circular(25),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 24,
                          vertical: 12,
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.clear_all_rounded,
                              color: educationalBlue,
                              size: 20,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              'Clear All Filters',
                              style: TextStyle(
                                color: educationalBlue,
                                fontWeight: FontWeight.w600,
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ],
        );
      },
    );
  }
  
  Widget _buildFilterSection(
    BuildContext context, {
    required String title,
    required Color titleColor,
    required List<String> items,
    required List<String> selectedItems,
    required Function(String) onToggle,
    required Color chipColor,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Section Title
        Row(
          children: [
            Container(
              width: 4,
              height: 20,
              decoration: BoxDecoration(
                color: titleColor,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(width: 12),
            Text(
              title,
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w700,
                color: titleColor,
                fontSize: 16,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        
        // Filter Chips
        Wrap(
          spacing: 10,
          runSpacing: 8,
          children: items.map((item) {
            final isSelected = selectedItems.contains(item);
            return _buildModernFilterChip(
              context,
              label: item,
              isSelected: isSelected,
              onTap: () => onToggle(item),
              chipColor: chipColor,
            );
          }).toList(),
        ),
      ],
    );
  }
  
  Widget _buildModernFilterChip(
    BuildContext context, {
    required String label,
    required bool isSelected,
    required VoidCallback onTap,
    required Color chipColor,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 10,
        ),
        decoration: BoxDecoration(
          gradient: isSelected
              ? LinearGradient(
                  colors: [
                    chipColor,
                    chipColor.withOpacity(0.8),
                  ],
                )
              : LinearGradient(
                  colors: [
                    Colors.white,
                    Colors.grey[50]!,
                  ],
                ),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected
                ? chipColor
                : chipColor.withOpacity(0.3),
            width: isSelected ? 2 : 1,
          ),
          boxShadow: [
            if (isSelected)
              BoxShadow(
                color: chipColor.withOpacity(0.3),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (isSelected) ...[
              Icon(
                Icons.check_circle_rounded,
                color: Colors.white,
                size: 16,
              ),
              const SizedBox(width: 6),
            ],
            Text(
              label,
              style: TextStyle(
                color: isSelected ? Colors.white : chipColor,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                fontSize: 13,
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  bool _hasActiveFilters(ProjectProvider provider) {
    return provider.selectedDomains.isNotEmpty ||
           provider.selectedDifficulties.isNotEmpty ||
           provider.selectedCareerPaths.isNotEmpty ||
           provider.searchQuery.isNotEmpty;
  }
}
