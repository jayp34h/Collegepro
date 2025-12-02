import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import '../../core/providers/auth_provider.dart';
import '../../core/providers/project_provider.dart';
import '../../core/models/project_model.dart';
import '../dashboard/widgets/project_card.dart';

class SavedProjectsScreen extends StatefulWidget {
  const SavedProjectsScreen({super.key});

  @override
  State<SavedProjectsScreen> createState() => _SavedProjectsScreenState();
}

class _SavedProjectsScreenState extends State<SavedProjectsScreen> {
  List<ProjectModel> savedProjects = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadSavedProjects();
  }

  Future<void> _loadSavedProjects() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final projectProvider = Provider.of<ProjectProvider>(context, listen: false);
    
    final savedProjectIds = authProvider.userModel?.savedProjectIds ?? [];
    final projects = await projectProvider.getSavedProjects(savedProjectIds);
    
    if (mounted) {
      setState(() {
        savedProjects = projects;
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Saved Projects'),
        centerTitle: true,
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : savedProjects.isEmpty
              ? _buildEmptyState()
              : RefreshIndicator(
                  onRefresh: _loadSavedProjects,
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: LayoutBuilder(
                      builder: (context, constraints) {
                        int crossAxisCount = 1;
                        if (constraints.maxWidth > 600) {
                          crossAxisCount = 2;
                        }
                        if (constraints.maxWidth > 900) {
                          crossAxisCount = 3;
                        }
                        return MasonryGridView.count(
                          crossAxisCount: crossAxisCount,
                          mainAxisSpacing: 16,
                          crossAxisSpacing: 16,
                          itemCount: savedProjects.length,
                          itemBuilder: (context, index) {
                            final project = savedProjects[index];
                            return ProjectCard(
                              project: project,
                              onTap: () => context.push('/project/${project.id}'),
                            );
                          },
                        );
                      },
                    ),
                  ),
                ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.bookmark_border,
            size: 64,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            'No Saved Projects',
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: 8),
          Text(
            'Projects you save will appear here',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: () => context.go('/dashboard'),
            child: const Text('Explore Projects'),
          ),
        ],
      ),
    );
  }
}
