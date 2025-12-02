import 'dart:convert';
import 'dart:math';
import 'package:http/http.dart' as http;
import '../models/project_model.dart';

class GitHubApiService {
  static const String _baseUrl = 'https://api.github.com';
  static const String _searchEndpoint = '/search/repositories';
  static final Random _random = Random();
  
  static Future<List<ProjectModel>> fetchFinalYearProjects({
    int page = 1,
    int perPage = 100,
  }) async {
    try {
      final uri = Uri.parse('$_baseUrl$_searchEndpoint').replace(
        queryParameters: {
          'q': '"final year project"',
          'sort': 'stars',
          'order': 'desc',
          'page': page.toString(),
          'per_page': perPage.toString(),
        },
      );

      final response = await http.get(
        uri,
        headers: {
          'Accept': 'application/vnd.github.v3+json',
          'User-Agent': 'FinalYearProjectFinder/1.0',
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final List<dynamic> repositories = data['items'] ?? [];
        
        return repositories.map((repo) => _mapGitHubRepoToProject(repo)).toList();
      } else {
        throw Exception('Failed to fetch GitHub repositories: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error fetching GitHub projects: $e');
    }
  }

  /// Fetches final year projects from a random page for fresh results
  static Future<List<ProjectModel>> fetchRandomFinalYearProjects({
    int perPage = 100,
    int maxPage = 10, // GitHub API typically allows up to 1000 results (10 pages of 100)
  }) async {
    final randomPage = _random.nextInt(maxPage) + 1;
    return fetchFinalYearProjects(page: randomPage, perPage: perPage);
  }

  /// Fetches multiple pages of projects and shuffles them for variety
  static Future<List<ProjectModel>> fetchShuffledFinalYearProjects({
    int numberOfPages = 3,
    int perPage = 100,
  }) async {
    final List<ProjectModel> allProjects = [];
    
    // Fetch from multiple random pages
    for (int i = 0; i < numberOfPages; i++) {
      final randomPage = _random.nextInt(10) + 1;
      try {
        final projects = await fetchFinalYearProjects(
          page: randomPage, 
          perPage: perPage,
        );
        allProjects.addAll(projects);
      } catch (e) {
        // Continue with other pages if one fails
        continue;
      }
    }
    
    // Remove duplicates based on project ID
    final uniqueProjects = <String, ProjectModel>{};
    for (final project in allProjects) {
      uniqueProjects[project.id] = project;
    }
    
    // Shuffle the results for variety
    final shuffledProjects = uniqueProjects.values.toList();
    shuffledProjects.shuffle(_random);
    
    return shuffledProjects;
  }

  /// Fetches multiple consecutive pages for pagination (more than 100 results)
  static Future<List<ProjectModel>> fetchMultiplePages({
    int startPage = 1,
    int numberOfPages = 5,
    int perPage = 100,
  }) async {
    final List<ProjectModel> allProjects = [];
    
    // Fetch consecutive pages
    for (int i = 0; i < numberOfPages; i++) {
      final currentPage = startPage + i;
      try {
        final projects = await fetchFinalYearProjects(
          page: currentPage,
          perPage: perPage,
        );
        
        // If no projects returned, we've reached the end
        if (projects.isEmpty) break;
        
        allProjects.addAll(projects);
      } catch (e) {
        // Stop pagination if API fails
        break;
      }
    }
    
    return allProjects;
  }

  /// Fetches enhanced final year projects with broader search terms for maximum variety
  static Future<List<ProjectModel>> fetchEnhancedFinalYearProjects({
    int page = 1,
    int perPage = 100,
  }) async {
    try {
      // Use the exact query format provided by user for fresh projects
      final uri = Uri.parse('$_baseUrl$_searchEndpoint').replace(
        queryParameters: {
          'q': '"final year project"',
          'sort': 'stars',
          'order': 'desc',
          'page': page.toString(),
          'per_page': perPage.toString(),
        },
      );

      final response = await http.get(
        uri,
        headers: {
          'Accept': 'application/vnd.github.v3+json',
          'User-Agent': 'FinalYearProjectFinder/1.0',
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final List<dynamic> repositories = data['items'] ?? [];
        
        return repositories.map((repo) => _mapGitHubRepoToProject(repo)).toList();
      } else {
        throw Exception('Failed to fetch enhanced GitHub repositories: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error fetching enhanced GitHub projects: $e');
    }
  }

  /// Fetches projects with pagination info for UI pagination controls
  static Future<Map<String, dynamic>> fetchProjectsWithPagination({
    int page = 1,
    int perPage = 100,
  }) async {
    try {
      final uri = Uri.parse('$_baseUrl$_searchEndpoint').replace(
        queryParameters: {
          'q': 'final year project computer science OR CSE OR ai OR machine learning OR blockchain OR cybersecurity OR iot created:2025-01-01..2025-12-31',
          'sort': 'stars',
          'order': 'desc',
          'page': page.toString(),
          'per_page': perPage.toString(),
        },
      );

      final response = await http.get(
        uri,
        headers: {
          'Accept': 'application/vnd.github.v3+json',
          'User-Agent': 'FinalYearProjectFinder/1.0',
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final List<dynamic> repositories = data['items'] ?? [];
        final totalCount = data['total_count'] ?? 0;
        final projects = repositories.map((repo) => _mapGitHubRepoToProject(repo)).toList();
        
        return {
          'projects': projects,
          'totalCount': totalCount,
          'currentPage': page,
          'perPage': perPage,
          'totalPages': (totalCount / perPage).ceil(),
          'hasNextPage': page < (totalCount / perPage).ceil(),
          'hasPreviousPage': page > 1,
        };
      } else {
        throw Exception('Failed to fetch GitHub repositories: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error fetching GitHub projects: $e');
    }
  }

  static ProjectModel _mapGitHubRepoToProject(Map<String, dynamic> repo) {
    // Extract programming language and topics for categories
    final language = repo['language'] as String? ?? 'Unknown';
    final topics = List<String>.from(repo['topics'] ?? []);
    
    // Create categories from language and topics
    final categories = <String>{language};
    categories.addAll(topics.take(3)); // Limit topics to avoid too many categories
    
    // Determine difficulty based on stars and complexity
    final stars = repo['stargazers_count'] as int? ?? 0;
    String difficulty = 'Beginner';
    if (stars > 100) difficulty = 'Intermediate';
    if (stars > 500) difficulty = 'Advanced';
    
    // Create description from repo description and readme info
    final description = repo['description'] as String? ?? 'No description available';
    final fullDescription = '''
$description

**Repository Details:**
• Stars: ${repo['stargazers_count'] ?? 0}
• Forks: ${repo['forks_count'] ?? 0}
• Language: $language
• Last Updated: ${_formatDate(repo['updated_at'])}

**GitHub Repository:** ${repo['html_url']}
''';

    return ProjectModel(
      id: 'github_${repo['id']}',
      title: repo['name'] as String? ?? 'Untitled Project',
      description: fullDescription,
      categories: categories.toList(),
      difficulty: difficulty,
      estimatedDuration: _estimateDuration(stars, repo['size'] as int? ?? 0),
      technologies: _extractTechnologies(language, topics),
      githubUrl: repo['html_url'] as String?,
      stars: stars,
      isGitHubProject: true,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );
  }

  static String _formatDate(String? dateString) {
    if (dateString == null) return 'Unknown';
    try {
      final date = DateTime.parse(dateString);
      return '${date.day}/${date.month}/${date.year}';
    } catch (e) {
      return 'Unknown';
    }
  }

  static String _estimateDuration(int stars, int size) {
    // Estimate duration based on repository popularity and size
    if (stars > 1000 || size > 50000) return '3-6 months';
    if (stars > 100 || size > 10000) return '2-4 months';
    if (stars > 10 || size > 1000) return '1-3 months';
    return '2-8 weeks';
  }

  static List<String> _extractTechnologies(String language, List<String> topics) {
    final technologies = <String>{};
    
    // Add primary language
    if (language.isNotEmpty && language != 'Unknown') {
      technologies.add(language);
    }
    
    // Add relevant topics as technologies
    for (final topic in topics) {
      if (_isTechnologyTopic(topic)) {
        technologies.add(_formatTechnology(topic));
      }
    }
    
    // Add default technologies if none found
    if (technologies.isEmpty) {
      technologies.addAll(['Git', 'GitHub']);
    }
    
    return technologies.toList();
  }

  static bool _isTechnologyTopic(String topic) {
    final techKeywords = [
      'javascript', 'python', 'java', 'cpp', 'csharp', 'php', 'ruby', 'go',
      'rust', 'swift', 'kotlin', 'dart', 'typescript', 'html', 'css',
      'react', 'vue', 'angular', 'flutter', 'nodejs', 'express', 'django',
      'flask', 'spring', 'laravel', 'rails', 'mongodb', 'mysql', 'postgresql',
      'redis', 'docker', 'kubernetes', 'aws', 'azure', 'firebase', 'api',
      'rest', 'graphql', 'machine-learning', 'ai', 'blockchain', 'web',
      'mobile', 'android', 'ios', 'frontend', 'backend', 'fullstack'
    ];
    
    return techKeywords.any((keyword) => 
      topic.toLowerCase().contains(keyword) || keyword.contains(topic.toLowerCase())
    );
  }

  static String _formatTechnology(String topic) {
    // Format technology names for better display
    final formatted = topic.split('-').map((word) => 
      word.isEmpty ? '' : word[0].toUpperCase() + word.substring(1)
    ).join(' ');
    
    return formatted;
  }
}
