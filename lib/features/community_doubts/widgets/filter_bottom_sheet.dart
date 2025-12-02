import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/community_doubts_provider.dart';

class FilterBottomSheet extends StatefulWidget {
  const FilterBottomSheet({super.key});

  @override
  State<FilterBottomSheet> createState() => _FilterBottomSheetState();
}

class _FilterBottomSheetState extends State<FilterBottomSheet> {
  String? _selectedSubject;
  String? _selectedDifficulty;
  bool? _showResolved;

  @override
  void initState() {
    super.initState();
    final provider = context.read<CommunityDoubtsProvider>();
    _selectedSubject = provider.selectedSubject;
    _selectedDifficulty = provider.selectedDifficulty;
    _showResolved = provider.showResolved;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildHeader(),
          Flexible(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildSubjectFilter(),
                  const SizedBox(height: 24),
                  _buildDifficultyFilter(),
                  const SizedBox(height: 24),
                  _buildStatusFilter(),
                  const SizedBox(height: 32),
                  _buildActionButtons(),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: const BoxDecoration(
        border: Border(
          bottom: BorderSide(color: Colors.grey, width: 0.2),
        ),
      ),
      child: Row(
        children: [
          const Text(
            'Filter Doubts',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const Spacer(),
          IconButton(
            onPressed: () => Navigator.pop(context),
            icon: const Icon(Icons.close),
          ),
        ],
      ),
    );
  }

  Widget _buildSubjectFilter() {
    final provider = context.read<CommunityDoubtsProvider>();
    final subjects = provider.getAvailableSubjects();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Subject',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: subjects.map((subject) {
            final isSelected = _selectedSubject == subject;
            return FilterChip(
              label: Text(subject),
              selected: isSelected,
              onSelected: (selected) {
                setState(() {
                  _selectedSubject = selected ? subject : null;
                });
              },
              selectedColor: const Color(0xFF6366F1).withOpacity(0.2),
              checkmarkColor: const Color(0xFF6366F1),
              labelStyle: TextStyle(
                color: isSelected ? const Color(0xFF6366F1) : Colors.grey[700],
                fontWeight: isSelected ? FontWeight.w500 : FontWeight.normal,
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildDifficultyFilter() {
    final provider = context.read<CommunityDoubtsProvider>();
    final difficulties = provider.getAvailableDifficulties();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Difficulty',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 12),
        Row(
          children: difficulties.map((difficulty) {
            final isSelected = _selectedDifficulty == difficulty;
            Color chipColor;
            switch (difficulty.toLowerCase()) {
              case 'easy':
                chipColor = Colors.green;
                break;
              case 'medium':
                chipColor = Colors.orange;
                break;
              case 'hard':
                chipColor = Colors.red;
                break;
              default:
                chipColor = Colors.grey;
            }

            return Padding(
              padding: const EdgeInsets.only(right: 8),
              child: FilterChip(
                label: Text(difficulty),
                selected: isSelected,
                onSelected: (selected) {
                  setState(() {
                    _selectedDifficulty = selected ? difficulty : null;
                  });
                },
                selectedColor: chipColor.withOpacity(0.2),
                checkmarkColor: chipColor,
                labelStyle: TextStyle(
                  color: isSelected ? chipColor : Colors.grey[700],
                  fontWeight: isSelected ? FontWeight.w500 : FontWeight.normal,
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildStatusFilter() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Status',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 12),
        Column(
          children: [
            RadioListTile<bool?>(
              title: const Text('All Doubts'),
              value: null,
              groupValue: _showResolved,
              onChanged: (value) {
                setState(() {
                  _showResolved = value;
                });
              },
              activeColor: const Color(0xFF6366F1),
            ),
            RadioListTile<bool?>(
              title: const Text('Unsolved Only'),
              value: false,
              groupValue: _showResolved,
              onChanged: (value) {
                setState(() {
                  _showResolved = value;
                });
              },
              activeColor: const Color(0xFF6366F1),
            ),
            RadioListTile<bool?>(
              title: const Text('Solved Only'),
              value: true,
              groupValue: _showResolved,
              onChanged: (value) {
                setState(() {
                  _showResolved = value;
                });
              },
              activeColor: const Color(0xFF6366F1),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildActionButtons() {
    return Row(
      children: [
        Expanded(
          child: OutlinedButton(
            onPressed: _clearFilters,
            style: OutlinedButton.styleFrom(
              side: const BorderSide(color: Color(0xFF6366F1)),
              foregroundColor: const Color(0xFF6366F1),
              padding: const EdgeInsets.symmetric(vertical: 12),
            ),
            child: const Text('Clear All'),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: ElevatedButton(
            onPressed: _applyFilters,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF6366F1),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 12),
            ),
            child: const Text('Apply Filters'),
          ),
        ),
      ],
    );
  }

  void _clearFilters() {
    setState(() {
      _selectedSubject = null;
      _selectedDifficulty = null;
      _showResolved = null;
    });
    
    context.read<CommunityDoubtsProvider>().clearFilters();
    Navigator.pop(context);
  }

  void _applyFilters() {
    context.read<CommunityDoubtsProvider>().applyFilters(
      subject: _selectedSubject,
      difficulty: _selectedDifficulty,
      showResolved: _showResolved,
    );
    Navigator.pop(context);
  }
}
