import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import '../../core/providers/project_provider.dart';
import '../../core/providers/auth_provider.dart';
import '../dashboard/widgets/project_card.dart';

class AIRecommendationsScreen extends StatefulWidget {
  const AIRecommendationsScreen({super.key});

  @override
  State<AIRecommendationsScreen> createState() => _AIRecommendationsScreenState();
}

class _AIRecommendationsScreenState extends State<AIRecommendationsScreen> {
  final _skillsController = TextEditingController();
  final _careerGoalController = TextEditingController();
  List<String> _selectedSkills = [];
  bool _hasGeneratedRecommendations = false;

  final List<String> _availableSkills = [
    'Python', 'Java', 'JavaScript', 'C++', 'C#', 'Flutter', 'React', 'Node.js',
    'Angular', 'Vue.js', 'Django', 'Spring Boot', 'Express.js', 'MongoDB',
    'MySQL', 'PostgreSQL', 'Firebase', 'AWS', 'Docker', 'Kubernetes',
    'Git', 'HTML/CSS', 'TypeScript', 'Swift', 'Kotlin', 'PHP', 'Ruby',
    'Go', 'Rust', 'Machine Learning', 'Data Science', 'AI', 'Blockchain'
  ];

  @override
  void initState() {
    super.initState();
    _loadUserProfile();
  }

  void _loadUserProfile() {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final user = authProvider.userModel;
    
    if (user != null) {
      _selectedSkills = List.from(user.skills);
      _careerGoalController.text = user.careerGoal;
    }
  }

  @override
  void dispose() {
    _skillsController.dispose();
    _careerGoalController.dispose();
    super.dispose();
  }

  Future<void> _generateRecommendations() async {
    if (_selectedSkills.isEmpty || _careerGoalController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select skills and enter your career goal'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    final projectProvider = Provider.of<ProjectProvider>(context, listen: false);
    await projectProvider.getAIRecommendations(
      _selectedSkills,
      _careerGoalController.text.trim(),
    );

    setState(() {
      _hasGeneratedRecommendations = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('AI Recommendations'),
        centerTitle: true,
      ),
      body: Consumer<ProjectProvider>(
        builder: (context, projectProvider, child) {
          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(
                              Icons.auto_awesome,
                              color: Theme.of(context).colorScheme.primary,
                              size: 28,
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                'AI-Powered Project Recommendations',
                                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Get personalized project suggestions based on your skills and career goals.',
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                
                const SizedBox(height: 16),
                
                // Skills Selection
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Your Skills',
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 12),
                        LayoutBuilder(
                          builder: (context, constraints) {
                            return Wrap(
                              spacing: 8,
                              runSpacing: 8,
                              children: _availableSkills.map((skill) {
                                final isSelected = _selectedSkills.contains(skill);
                                return ConstrainedBox(
                                  constraints: BoxConstraints(
                                    maxWidth: constraints.maxWidth * 0.45,
                                  ),
                                  child: FilterChip(
                                    label: Text(
                                      skill,
                                      overflow: TextOverflow.ellipsis,
                                      maxLines: 1,
                                    ),
                                    selected: isSelected,
                                    onSelected: (selected) {
                                      setState(() {
                                        if (selected) {
                                          _selectedSkills.add(skill);
                                        } else {
                                          _selectedSkills.remove(skill);
                                        }
                                      });
                                    },
                                    selectedColor: Theme.of(context).colorScheme.primary.withOpacity(0.2),
                                    checkmarkColor: Theme.of(context).colorScheme.primary,
                                  ),
                                );
                              }).toList(),
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                ),
                
                const SizedBox(height: 16),
                
                // Career Goal
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Career Goal',
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 12),
                        TextField(
                          controller: _careerGoalController,
                          decoration: const InputDecoration(
                            hintText: 'e.g., Full Stack Developer, Data Scientist, Mobile Developer',
                            border: OutlineInputBorder(),
                          ),
                          maxLines: 2,
                        ),
                      ],
                    ),
                  ),
                ),
                
                const SizedBox(height: 24),
                
                // Generate Button
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton.icon(
                    onPressed: projectProvider.isLoading ? null : _generateRecommendations,
                    icon: projectProvider.isLoading
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : const Icon(Icons.auto_awesome),
                    label: Text(
                      projectProvider.isLoading
                          ? 'Generating Recommendations...'
                          : 'Generate AI Recommendations',
                    ),
                  ),
                ),
                
                const SizedBox(height: 24),
                
                // Recommendations
                if (_hasGeneratedRecommendations) ...[
                  if (projectProvider.errorMessage != null) ...[
                    Card(
                      color: Colors.red[50],
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          children: [
                            Icon(
                              Icons.error_outline,
                              color: Colors.red[700],
                              size: 48,
                            ),
                            const SizedBox(height: 12),
                            Text(
                              'Failed to Generate Recommendations',
                              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                color: Colors.red[700],
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              projectProvider.errorMessage!,
                              style: TextStyle(color: Colors.red[600]),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 16),
                            ElevatedButton(
                              onPressed: _generateRecommendations,
                              child: const Text('Try Again'),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ] else if (projectProvider.recommendedProjects.isEmpty) ...[
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(32),
                        child: Column(
                          children: [
                            Icon(
                              Icons.lightbulb_outline,
                              size: 64,
                              color: Colors.grey[400],
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'No Recommendations Yet',
                              style: Theme.of(context).textTheme.titleLarge,
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Click the button above to get personalized project recommendations.',
                              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                color: Colors.grey[600],
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ] else ...[
                    Text(
                      'Recommended Projects for You',
                      style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    LayoutBuilder(
                      builder: (context, constraints) {
                        int crossAxisCount = 1;
                        if (constraints.maxWidth > 600) {
                          crossAxisCount = 2;
                        }
                        return MasonryGridView.count(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          crossAxisCount: crossAxisCount,
                          mainAxisSpacing: 16,
                          crossAxisSpacing: 16,
                          itemCount: projectProvider.recommendedProjects.length,
                          itemBuilder: (context, index) {
                            final project = projectProvider.recommendedProjects[index];
                            return ProjectCard(
                              project: project,
                              onTap: () => context.push('/project/${project.id}'),
                            );
                          },
                        );
                      },
                    ),
                  ],
                ],
              ],
            ),
          );
        },
      ),
    );
  }
}
