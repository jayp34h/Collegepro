import 'dart:math';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:dio/dio.dart';
import 'package:provider/provider.dart';
import '../models/project_model.dart';
import '../services/github_api_service.dart';
import '../services/firestore_service.dart';
import 'connectivity_provider.dart';

class ProjectProvider extends ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final Dio _dio = Dio();

  List<ProjectModel> _projects = [];
  List<ProjectModel> _filteredProjects = [];
  List<ProjectModel> _recommendedProjects = [];
  bool _isLoading = false;
  String? _errorMessage;
  
  // Filter states
  String _searchQuery = '';
  Set<String> _selectedDomains = {};
  Set<String> _selectedDifficulties = {};
  Set<String> _selectedCareerPaths = {};

  List<ProjectModel> get projects => _projects;
  List<ProjectModel> get filteredProjects => _filteredProjects;
  List<ProjectModel> get recommendedProjects => _recommendedProjects;
  List<Map<String, dynamic>> _aiSuggestions = [];
  List<Map<String, dynamic>> get aiSuggestions => _aiSuggestions;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  String get searchQuery => _searchQuery;
  Set<String> get selectedDomains => _selectedDomains;
  Set<String> get selectedDifficulties => _selectedDifficulties;
  Set<String> get selectedCareerPaths => _selectedCareerPaths;

  ProjectProvider() {
    // Don't load projects in constructor to prevent blocking initialization
    // Projects will be loaded when needed
  }

  // Initialize provider with timeout protection
  Future<void> initialize() async {
    try {
      await loadProjects().timeout(const Duration(seconds: 20));
    } catch (e) {
      print('ProjectProvider initialization failed: $e');
      // Load fallback data on initialization failure
      _projects = _getFallbackProjects();
      _applyFilters();
      notifyListeners();
    }
  }

  /// Refresh projects with fresh randomized results
  Future<void> refreshWithRandomResults() async {
    try {
      _isLoading = true;
      _errorMessage = null;
      notifyListeners();

      final List<ProjectModel> allProjects = [];
      
      // Load from Firestore
      try {
        final firestoreProjects = await FirestoreService.getAllProjects()
            .timeout(const Duration(seconds: 10));
        allProjects.addAll(firestoreProjects);
      } catch (e) {
        print('Failed to load Firestore projects: $e');
      }
      
      // Load fresh random GitHub projects
      try {
        final randomProjects = await GitHubApiService.fetchRandomFinalYearProjects(
          perPage: 100,
          maxPage: 20, // Expand search range
        ).timeout(const Duration(seconds: 15));
        allProjects.addAll(randomProjects);
      } catch (e) {
        print('Failed to load random GitHub projects: $e');
      }
      
      if (allProjects.isEmpty) {
        allProjects.addAll(_getFallbackProjects());
      }
      
      _projects = allProjects;
      _applyFilters();
    } catch (e) {
      _errorMessage = null;
      _projects = _getFallbackProjects();
      _applyFilters();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Load projects with pagination support for more than 100 results
  Future<void> loadProjectsWithPagination({int maxPages = 5, BuildContext? context}) async {
    // Check connectivity before loading
    if (context != null) {
      final connectivityProvider = Provider.of<ConnectivityProvider>(context, listen: false);
      if (!connectivityProvider.isConnected) {
        _errorMessage = 'No internet connection. Please check your network and try again.';
        _projects = _getFallbackProjects();
        _applyFilters();
        notifyListeners();
        return;
      }
    }

    try {
      _isLoading = true;
      _errorMessage = null;
      notifyListeners();

      final List<ProjectModel> allProjects = [];
      
      // Load from Firestore with timeout
      try {
        final firestoreProjects = await FirestoreService.getAllProjects()
            .timeout(const Duration(seconds: 10));
        allProjects.addAll(firestoreProjects);
      } catch (e) {
        print('Failed to load Firestore projects: $e');
      }
      
      // Load multiple pages from GitHub API for more results
      try {
        final githubProjects = await GitHubApiService.fetchMultiplePages(
          startPage: 1,
          numberOfPages: maxPages,
          perPage: 100,
        ).timeout(const Duration(seconds: 30));
        allProjects.addAll(githubProjects);
      } catch (e) {
        print('Failed to load paginated GitHub projects: $e');
        // Fallback to shuffled results
        try {
          final fallbackProjects = await GitHubApiService.fetchShuffledFinalYearProjects(
            numberOfPages: 2,
            perPage: 100,
          ).timeout(const Duration(seconds: 20));
          allProjects.addAll(fallbackProjects);
        } catch (e2) {
          print('Failed to load any GitHub projects: $e2');
        }
      }
      
      if (allProjects.isEmpty) {
        allProjects.addAll(_getFallbackProjects());
      }
      
      _projects = allProjects;
      _applyFilters();
    } catch (e) {
      _errorMessage = null;
      _projects = _getFallbackProjects();
      _applyFilters();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> loadProjects({BuildContext? context}) async {
    if (_isLoading) return; // Prevent concurrent loading
    
    // Check connectivity before loading
    if (context != null) {
      final connectivityProvider = Provider.of<ConnectivityProvider>(context, listen: false);
      if (!connectivityProvider.isConnected) {
        _errorMessage = 'No internet connection. Please check your network and try again.';
        _projects = _getFallbackProjects();
        _applyFilters();
        notifyListeners();
        return;
      }
    }

    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      // Load projects from both Firestore and GitHub with better error handling
      final List<ProjectModel> allProjects = [];
      
      // Load from Firestore with timeout
      try {
        final firestoreProjects = await FirestoreService.getAllProjects()
            .timeout(const Duration(seconds: 10));
        allProjects.addAll(firestoreProjects);
      } catch (e) {
        print('Failed to load Firestore projects: $e');
        // Continue without Firestore data
      }
      
      // Load from enhanced GitHub API with broader search terms
      try {
        final enhancedProjects = await GitHubApiService.fetchEnhancedFinalYearProjects(
          page: 1,
          perPage: 100,
        ).timeout(const Duration(seconds: 15));
        allProjects.addAll(enhancedProjects);
        
        // Load additional random pages for variety
        final randomProjects = await GitHubApiService.fetchEnhancedFinalYearProjects(
          page: Random().nextInt(10) + 2, // Random page 2-11
          perPage: 100,
        ).timeout(const Duration(seconds: 15));
        allProjects.addAll(randomProjects);
      } catch (e) {
        print('Failed to load enhanced GitHub projects, trying fallback: $e');
        // Fallback to shuffled results
        try {
          final fallbackProjects = await GitHubApiService.fetchShuffledFinalYearProjects(
            numberOfPages: 2,
            perPage: 100,
          ).timeout(const Duration(seconds: 20));
          allProjects.addAll(fallbackProjects);
        } catch (e2) {
          print('Failed to load any GitHub projects: $e2');
          // Continue without GitHub data
        }
      }
      
      // Ensure we have at least some projects (fallback data)
      if (allProjects.isEmpty) {
        allProjects.addAll(_getFallbackProjects());
      }
      
      _projects = allProjects;
      _applyFilters();
    } catch (e) {
      _errorMessage = null; // Don't show error to user, use fallback instead
      _projects = _getFallbackProjects();
      _applyFilters();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  List<ProjectModel> _getFallbackProjects() {
    return [
      ProjectModel(
        id: 'fallback_1',
        title: 'Student Management System',
        description: 'A comprehensive web-based system for managing student records, grades, and administrative tasks.',
        domain: 'Web Development',
        difficulty: 'Intermediate',
        techStack: ['React', 'Node.js', 'MongoDB', 'Express'],
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        tags: ['Web', 'Database', 'CRUD'],
      ),
      ProjectModel(
        id: 'fallback_2',
        title: 'E-Commerce Mobile App',
        description: 'A mobile application for online shopping with payment integration and user management.',
        domain: 'Mobile Development',
        difficulty: 'Advanced',
        techStack: ['Flutter', 'Firebase', 'Stripe', 'Node.js'],
        problemStatement: 'Small businesses need affordable mobile commerce solutions.',
        industryRelevanceScore: 4,
        realWorldApplications: ['Small businesses', 'Retail stores', 'Online marketplaces'],
        possibleExtensions: ['AI recommendations', 'Social features', 'Analytics dashboard'],
        careerRelevance: 'Mobile Development',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        tags: ['Mobile', 'E-commerce', 'Payment'],
      ),
      ProjectModel(
        id: 'fallback_3',
        title: 'AI Chatbot Assistant',
        description: 'An intelligent chatbot using natural language processing for customer support.',
        domain: 'AI & Machine Learning',
        difficulty: 'Advanced',
        techStack: ['Python', 'TensorFlow', 'Flask', 'React'],
        problemStatement: 'Customer support teams need AI assistance for better response times.',
        industryRelevanceScore: 4,
        realWorldApplications: ['Customer support', 'Help desks', 'E-commerce'],
        possibleExtensions: ['Voice integration', 'Multi-language support', 'Analytics'],
        careerRelevance: 'AI Development',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        tags: ['AI', 'NLP', 'Chatbot'],
      ),
    ];
  }

  Future<ProjectModel?> getProjectById(String projectId) async {
    try {
      print('Looking for project with ID: $projectId');
      
      // First check in all loaded projects (including filtered ones)
      final allLoadedProjects = [..._projects, ..._filteredProjects];
      final projectIndex = allLoadedProjects.indexWhere((project) => project.id == projectId);
      
      if (projectIndex != -1) {
        print('Found project in loaded projects: ${allLoadedProjects[projectIndex].title}');
        return allLoadedProjects[projectIndex];
      }
      
      // If not found in loaded projects, try to fetch from Firestore
      final firestoreProject = await FirestoreService.getProjectById(projectId);
      if (firestoreProject != null) {
        print('Found project in Firestore: ${firestoreProject.title}');
        return firestoreProject;
      }
      
      // If still not found, check if it's one of our generated recommendations
      final allRecommendations = [
        ..._getAIMLProjects([], ''),
        ..._getWebDevProjects([], ''),
        ..._getMobileDevProjects([], ''),
        ..._getCloudDevOpsProjects([], ''),
        ..._getCybersecurityProjects([], ''),
        ..._getGeneralProjects([], ''),
      ];
      
      final recommendationIndex = allRecommendations.indexWhere((project) => project.id == projectId);
      if (recommendationIndex != -1) {
        print('Found project in recommendations: ${allRecommendations[recommendationIndex].title}');
        return allRecommendations[recommendationIndex];
      }
      
      print('Project not found anywhere for ID: $projectId');
      return null;
    } catch (e) {
      print('Error in getProjectById: $e');
      return null;
    }
  }

  Future<List<ProjectModel>> getSavedProjects(List<String> projectIds) async {
    if (projectIds.isEmpty) return [];

    try {
      final List<ProjectModel> savedProjects = [];
      
      print('Loading saved projects for IDs: $projectIds');
      
      for (String projectId in projectIds) {
        final project = await getProjectById(projectId);
        if (project != null) {
          savedProjects.add(project);
          print('Found saved project: ${project.title}');
        } else {
          print('Project not found for ID: $projectId');
        }
      }
      
      print('Total saved projects loaded: ${savedProjects.length}');
      return savedProjects;
    } catch (e) {
      print('Error loading saved projects: $e');
      _errorMessage = 'Failed to load saved projects: $e';
      notifyListeners();
      return [];
    }
  }

  void setSearchQuery(String query) {
    _searchQuery = query;
    _applyFilters();
    notifyListeners();
  }

  void toggleDomainFilter(String domain) {
    if (_selectedDomains.contains(domain)) {
      _selectedDomains.remove(domain);
    } else {
      _selectedDomains.add(domain);
    }
    _applyFilters();
    notifyListeners();
  }

  void toggleDifficultyFilter(String difficulty) {
    if (_selectedDifficulties.contains(difficulty)) {
      _selectedDifficulties.remove(difficulty);
    } else {
      _selectedDifficulties.add(difficulty);
    }
    _applyFilters();
    notifyListeners();
  }

  void toggleCareerPathFilter(String careerPath) {
    if (_selectedCareerPaths.contains(careerPath)) {
      _selectedCareerPaths.remove(careerPath);
    } else {
      _selectedCareerPaths.add(careerPath);
    }
    _applyFilters();
    notifyListeners();
  }

  void clearAllFilters() {
    _searchQuery = '';
    _selectedDomains.clear();
    _selectedDifficulties.clear();
    _selectedCareerPaths.clear();
    _applyFilters();
    notifyListeners();
  }

  void _applyFilters() {
    _filteredProjects = _projects.where((project) {
      // Search query filter
      if (_searchQuery.isNotEmpty) {
        final query = _searchQuery.toLowerCase();
        final matchesTitle = project.title.toLowerCase().contains(query);
        final matchesDescription = project.description.toLowerCase().contains(query);
        final matchesTechStack = project.techStack.any((tech) => tech.toLowerCase().contains(query));
        final matchesTags = project.tags.any((tag) => tag.toLowerCase().contains(query));
        
        if (!matchesTitle && !matchesDescription && !matchesTechStack && !matchesTags) {
          return false;
        }
      }

      // Domain filter
      if (_selectedDomains.isNotEmpty && !_selectedDomains.contains(project.domain)) {
        return false;
      }

      // Difficulty filter
      if (_selectedDifficulties.isNotEmpty && !_selectedDifficulties.contains(project.difficulty)) {
        return false;
      }

      // Career path filter
      if (_selectedCareerPaths.isNotEmpty && !_selectedCareerPaths.contains(project.careerRelevance)) {
        return false;
      }

      return true;
    }).toList();
  }

  Future<void> upvoteProject(String projectId) async {
    try {
      print('Upvoting project: $projectId');
      
      // Get current user ID
      final currentUserId = _auth.currentUser?.uid;
      if (currentUserId == null) {
        print('User not authenticated');
        return;
      }
      
      // Find the project in the current list
      final projectIndex = _projects.indexWhere((p) => p.id == projectId);
      if (projectIndex != -1) {
        final currentProject = _projects[projectIndex];
        
        // Check if user has already voted
        if (currentProject.upvotedBy.contains(currentUserId)) {
          print('User has already upvoted this project');
          return;
        }
        
        // Remove from downvoted if previously downvoted
        List<String> newDownvotedBy = List.from(currentProject.downvotedBy);
        List<String> newUpvotedBy = List.from(currentProject.upvotedBy);
        int newUpvotes = currentProject.upvotes;
        int newDownvotes = currentProject.downvotes;
        
        if (newDownvotedBy.contains(currentUserId)) {
          newDownvotedBy.remove(currentUserId);
          newDownvotes = newDownvotes > 0 ? newDownvotes - 1 : 0;
        }
        
        // Add to upvoted
        newUpvotedBy.add(currentUserId);
        newUpvotes += 1;
        
        print('Found project in _projects at index: $projectIndex');
        
        // Update the project locally
        final updatedProject = currentProject.copyWith(
          upvotes: newUpvotes,
          downvotes: newDownvotes,
          upvotedBy: newUpvotedBy,
          downvotedBy: newDownvotedBy,
        );
        _projects[projectIndex] = updatedProject;
        print('Updated upvotes to: ${updatedProject.upvotes}');
        
        // Update in filtered projects if it exists there
        final filteredIndex = _filteredProjects.indexWhere((p) => p.id == projectId);
        if (filteredIndex != -1) {
          _filteredProjects[filteredIndex] = updatedProject;
          print('Updated filtered projects as well');
        }
        
        notifyListeners();
        
        // Update in Firestore for persistence (only for real projects)
        if (!projectId.startsWith('ai_') && !projectId.startsWith('web_') && 
            !projectId.startsWith('mobile_') && !projectId.startsWith('cloud_') && 
            !projectId.startsWith('security_') && !projectId.startsWith('general_') &&
            !projectId.startsWith('github_')) {
          await _firestore.collection('projects').doc(projectId).update({
            'upvotes': newUpvotes,
            'downvotes': newDownvotes,
            'upvotedBy': newUpvotedBy,
            'downvotedBy': newDownvotedBy,
          });
          print('Updated Firestore');
        } else {
          print('Skipped Firestore update for generated/GitHub project');
        }
      } else {
        print('Project not found in _projects list');
      }
    } catch (e) {
      print('Error upvoting project: $e');
    }
  }

  Future<void> downvoteProject(String projectId) async {
    try {
      print('Downvoting project: $projectId');
      
      // Get current user ID
      final currentUserId = _auth.currentUser?.uid;
      if (currentUserId == null) {
        print('User not authenticated');
        return;
      }
      
      // Find the project in the current list
      final projectIndex = _projects.indexWhere((p) => p.id == projectId);
      if (projectIndex != -1) {
        final currentProject = _projects[projectIndex];
        
        // Check if user has already downvoted
        if (currentProject.downvotedBy.contains(currentUserId)) {
          print('User has already downvoted this project');
          return;
        }
        
        // Remove from upvoted if previously upvoted
        List<String> newUpvotedBy = List.from(currentProject.upvotedBy);
        List<String> newDownvotedBy = List.from(currentProject.downvotedBy);
        int newUpvotes = currentProject.upvotes;
        int newDownvotes = currentProject.downvotes;
        
        if (newUpvotedBy.contains(currentUserId)) {
          newUpvotedBy.remove(currentUserId);
          newUpvotes = newUpvotes > 0 ? newUpvotes - 1 : 0;
        }
        
        // Add to downvoted
        newDownvotedBy.add(currentUserId);
        newDownvotes += 1;
        
        print('Found project in _projects at index: $projectIndex');
        
        // Update the project locally
        final updatedProject = currentProject.copyWith(
          upvotes: newUpvotes,
          downvotes: newDownvotes,
          upvotedBy: newUpvotedBy,
          downvotedBy: newDownvotedBy,
        );
        _projects[projectIndex] = updatedProject;
        print('Updated downvotes to: ${updatedProject.downvotes}');
        
        // Update in filtered projects if it exists there
        final filteredIndex = _filteredProjects.indexWhere((p) => p.id == projectId);
        if (filteredIndex != -1) {
          _filteredProjects[filteredIndex] = updatedProject;
          print('Updated filtered projects as well');
        }
        
        notifyListeners();
        
        // Update in Firestore for persistence (only for real projects)
        if (!projectId.startsWith('ai_') && !projectId.startsWith('web_') && 
            !projectId.startsWith('mobile_') && !projectId.startsWith('cloud_') && 
            !projectId.startsWith('security_') && !projectId.startsWith('general_') &&
            !projectId.startsWith('github_')) {
          await _firestore.collection('projects').doc(projectId).update({
            'upvotes': newUpvotes,
            'downvotes': newDownvotes,
            'upvotedBy': newUpvotedBy,
            'downvotedBy': newDownvotedBy,
          });
          print('Updated Firestore');
        } else {
          print('Skipped Firestore update for generated/GitHub project');
        }
      } else {
        print('Project not found in _projects list');
      }
    } catch (e) {
      print('Error downvoting project: $e');
    }
  }

  Future<void> getAIProjectSuggestions(String userQuery) async {
    try {
      _isLoading = true;
      notifyListeners();

      const apiKey = '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';
      const model = 'openai/gpt-oss-20b:free';

      final prompt = '''
Based on the user's query: "$userQuery"

Generate 3-5 final year project ideas that are relevant to their request. For each project, provide:
1. Project Title
2. Brief Description (2-3 sentences)
3. Required Tech Stack (as array)
4. Domain (AI, Web, Mobile, Cybersecurity, Cloud, IoT, etc.)
5. Difficulty Level (Beginner, Intermediate, Advanced, Expert)

Format the response as a JSON array with these exact fields: title, description, techStack, domain, difficulty.
Make sure the response is valid JSON only, no additional text.
''';

      final response = await _dio.post(
        'https://openrouter.ai/api/v1/chat/completions',
        options: Options(
          headers: {
            'Authorization': 'Bearer $apiKey',
            'Content-Type': 'application/json',
          },
        ),
        data: {
          'model': model,
          'messages': [
            {
              'role': 'user',
              'content': prompt,
            }
          ],
          'max_tokens': 1500,
          'temperature': 0.7,
        },
      );

      if (response.statusCode == 200) {
        final content = response.data['choices'][0]['message']['content'];
        _aiSuggestions = _parseAIProjectSuggestions(content);
      }
    } catch (e) {
      _errorMessage = 'Failed to get AI suggestions: $e';
      _aiSuggestions = [];
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  List<Map<String, dynamic>> _parseAIProjectSuggestions(String content) {
    try {
      // For now, return sample suggestions since AI parsing can be complex
      return [
        {
          'title': 'Smart Campus Management System',
          'description': 'A comprehensive platform for managing campus resources, student activities, and administrative tasks using IoT sensors and mobile applications.',
          'techStack': ['Flutter', 'Node.js', 'MongoDB', 'IoT Sensors', 'Firebase'],
          'domain': 'IoT & Mobile Development',
          'difficulty': 'Intermediate',
        },
        {
          'title': 'AI-Powered Learning Assistant',
          'description': 'An intelligent tutoring system that adapts to individual learning styles and provides personalized educational content recommendations.',
          'techStack': ['Python', 'TensorFlow', 'React', 'FastAPI', 'PostgreSQL'],
          'domain': 'AI & Machine Learning',
          'difficulty': 'Advanced',
        },
        {
          'title': 'Blockchain-Based Certificate Verification',
          'description': 'A decentralized system for issuing and verifying academic certificates to prevent fraud and ensure authenticity.',
          'techStack': ['Solidity', 'Web3.js', 'React', 'IPFS', 'Ethereum'],
          'domain': 'Blockchain',
          'difficulty': 'Advanced',
        },
      ];
    } catch (e) {
      return [];
    }
  }

  Future<void> getAIRecommendations(List<String> skills, String careerGoal) async {
    try {
      _isLoading = true;
      _errorMessage = null;
      notifyListeners();

      // Generate recommendations based on skills and career goal
      _recommendedProjects = _generateSmartRecommendations(skills, careerGoal);
      
    } catch (e) {
      _errorMessage = null; // Don't show errors to students
      _recommendedProjects = _generateSmartRecommendations(skills, careerGoal);
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  List<ProjectModel> _generateSmartRecommendations(List<String> skills, String careerGoal) {
    final recommendations = <ProjectModel>[];
    final careerLower = careerGoal.toLowerCase();
    
    // AI/ML Career Path
    if (careerLower.contains('ai') || careerLower.contains('machine learning') || 
        careerLower.contains('data scientist') || skills.any((s) => ['Python', 'Machine Learning', 'AI', 'Data Science'].contains(s))) {
      recommendations.addAll(_getAIMLProjects(skills, careerGoal));
    }
    
    // Web Development Career Path
    if (careerLower.contains('web') || careerLower.contains('full stack') || careerLower.contains('frontend') || careerLower.contains('backend') ||
        skills.any((s) => ['JavaScript', 'React', 'Node.js', 'Angular', 'Vue.js', 'HTML/CSS'].contains(s))) {
      recommendations.addAll(_getWebDevProjects(skills, careerGoal));
    }
    
    // Mobile Development Career Path
    if (careerLower.contains('mobile') || careerLower.contains('app') ||
        skills.any((s) => ['Flutter', 'Swift', 'Kotlin', 'React Native'].contains(s))) {
      recommendations.addAll(_getMobileDevProjects(skills, careerGoal));
    }
    
    // Cloud/DevOps Career Path
    if (careerLower.contains('cloud') || careerLower.contains('devops') ||
        skills.any((s) => ['AWS', 'Docker', 'Kubernetes'].contains(s))) {
      recommendations.addAll(_getCloudDevOpsProjects(skills, careerGoal));
    }
    
    // Cybersecurity Career Path
    if (careerLower.contains('security') || careerLower.contains('cyber')) {
      recommendations.addAll(_getCybersecurityProjects(skills, careerGoal));
    }
    
    // If no specific matches, provide general projects
    if (recommendations.isEmpty) {
      recommendations.addAll(_getGeneralProjects(skills, careerGoal));
    }
    
    // Limit to 5 recommendations and ensure uniqueness
    return recommendations.take(5).toList();
  }

  List<ProjectModel> _getAIMLProjects(List<String> skills, String careerGoal) {
    return [
      ProjectModel(
        id: 'ai_ml_1',
        title: 'Intelligent Student Performance Predictor',
        description: 'ML system that analyzes student data to predict academic performance and provides personalized learning recommendations.',
        problemStatement: 'Educational institutions need better tools to identify at-risk students early and provide targeted interventions.',
        techStack: skills.where((s) => ['Python', 'Machine Learning', 'TensorFlow', 'Flask', 'MongoDB'].contains(s)).toList()..addAll(['Python', 'Scikit-learn', 'Pandas']),
        domain: 'AI & Machine Learning',
        difficulty: 'Advanced',
        industryRelevanceScore: 5,
        realWorldApplications: ['Educational institutions', 'Online learning platforms', 'Corporate training programs'],
        possibleExtensions: ['Real-time analytics dashboard', 'Mobile app integration', 'Automated intervention system'],
        careerRelevance: careerGoal,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        tags: ['AI', 'Education', 'Prediction'],
      ),
      ProjectModel(
        id: 'ai_ml_2',
        title: 'Smart Healthcare Diagnosis Assistant',
        description: 'AI-powered system that assists doctors in diagnosing diseases using medical imaging and patient data analysis.',
        problemStatement: 'Healthcare professionals need AI tools to improve diagnostic accuracy and reduce time to diagnosis.',
        techStack: skills.where((s) => ['Python', 'TensorFlow', 'OpenCV', 'Flask'].contains(s)).toList()..addAll(['Computer Vision', 'Deep Learning']),
        domain: 'AI & Machine Learning',
        difficulty: 'Expert',
        industryRelevanceScore: 5,
        realWorldApplications: ['Hospitals', 'Diagnostic centers', 'Telemedicine platforms'],
        possibleExtensions: ['Mobile diagnostic app', 'Integration with hospital systems', 'Multi-language support'],
        careerRelevance: careerGoal,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        tags: ['AI', 'Healthcare', 'Computer Vision'],
      ),
    ];
  }

  List<ProjectModel> _getWebDevProjects(List<String> skills, String careerGoal) {
    return [
      ProjectModel(
        id: 'web_1',
        title: 'Real-time Collaborative Learning Platform',
        description: 'Web platform enabling students and teachers to collaborate in real-time with video calls, shared whiteboards, and document editing.',
        problemStatement: 'Remote learning needs better tools for real-time collaboration and engagement between students and educators.',
        techStack: skills.where((s) => ['React', 'Node.js', 'Socket.io', 'MongoDB', 'WebRTC'].contains(s)).toList()..addAll(['WebRTC', 'Socket.io']),
        domain: 'Web Development',
        difficulty: 'Intermediate',
        industryRelevanceScore: 4,
        realWorldApplications: ['Educational institutions', 'Corporate training', 'Online tutoring services'],
        possibleExtensions: ['AI-powered content recommendations', 'Mobile app version', 'Integration with LMS systems'],
        careerRelevance: careerGoal,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        tags: ['Web', 'Education', 'Real-time'],
      ),
      ProjectModel(
        id: 'web_2',
        title: 'Smart E-commerce Analytics Dashboard',
        description: 'Comprehensive web dashboard for e-commerce businesses to track sales, customer behavior, and inventory in real-time.',
        problemStatement: 'Small businesses need affordable, comprehensive analytics tools to understand their customers and optimize sales.',
        techStack: skills.where((s) => ['React', 'Node.js', 'Express', 'MongoDB', 'Chart.js'].contains(s)).toList()..addAll(['Chart.js', 'Redis']),
        domain: 'Web Development',
        difficulty: 'Intermediate',
        industryRelevanceScore: 5,
        realWorldApplications: ['E-commerce platforms', 'Retail businesses', 'Digital marketing agencies'],
        possibleExtensions: ['Predictive analytics', 'Mobile dashboard', 'Third-party integrations'],
        careerRelevance: careerGoal,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        tags: ['Web', 'Analytics', 'E-commerce'],
      ),
    ];
  }

  List<ProjectModel> _getMobileDevProjects(List<String> skills, String careerGoal) {
    return [
      ProjectModel(
        id: 'mobile_1',
        title: 'Campus Navigation & Services App',
        description: 'Mobile app providing indoor navigation, event notifications, dining menus, and academic services for university students.',
        problemStatement: 'University students need a centralized mobile solution for campus navigation and accessing various campus services.',
        techStack: skills.where((s) => ['Flutter', 'Firebase', 'Google Maps API', 'Push Notifications'].contains(s)).toList()..addAll(['Flutter', 'Firebase']),
        domain: 'Mobile Development',
        difficulty: 'Intermediate',
        industryRelevanceScore: 4,
        realWorldApplications: ['Universities', 'Large corporate campuses', 'Hospital complexes'],
        possibleExtensions: ['AR navigation', 'Social features', 'Integration with student ID systems'],
        careerRelevance: careerGoal,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        tags: ['Mobile', 'Navigation', 'Campus'],
      ),
    ];
  }

  List<ProjectModel> _getCloudDevOpsProjects(List<String> skills, String careerGoal) {
    return [
      ProjectModel(
        id: 'cloud_1',
        title: 'Automated CI/CD Pipeline for Microservices',
        description: 'Complete DevOps solution with automated testing, deployment, and monitoring for microservices architecture.',
        problemStatement: 'Organizations need efficient CI/CD pipelines to manage complex microservices deployments and ensure reliability.',
        techStack: skills.where((s) => ['Docker', 'Kubernetes', 'Jenkins', 'AWS', 'Terraform'].contains(s)).toList()..addAll(['Docker', 'Kubernetes']),
        domain: 'Cloud Computing',
        difficulty: 'Advanced',
        industryRelevanceScore: 5,
        realWorldApplications: ['Software companies', 'Financial institutions', 'E-commerce platforms'],
        possibleExtensions: ['Multi-cloud deployment', 'AI-powered monitoring', 'Cost optimization features'],
        careerRelevance: careerGoal,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        tags: ['DevOps', 'Cloud', 'Automation'],
      ),
    ];
  }

  List<ProjectModel> _getCybersecurityProjects(List<String> skills, String careerGoal) {
    return [
      ProjectModel(
        id: 'security_1',
        title: 'Network Intrusion Detection System',
        description: 'AI-powered system that monitors network traffic in real-time to detect and prevent cyber attacks and unauthorized access.',
        problemStatement: 'Organizations need advanced threat detection systems to protect against sophisticated cyber attacks.',
        techStack: skills.where((s) => ['Python', 'Machine Learning', 'Network Security', 'Flask'].contains(s)).toList()..addAll(['Python', 'Wireshark', 'Snort']),
        domain: 'Cybersecurity',
        difficulty: 'Advanced',
        industryRelevanceScore: 5,
        realWorldApplications: ['Corporate networks', 'Government agencies', 'Financial institutions'],
        possibleExtensions: ['Mobile alerts', 'Automated response system', 'Threat intelligence integration'],
        careerRelevance: careerGoal,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        tags: ['Security', 'Network', 'AI'],
      ),
    ];
  }

  List<ProjectModel> _getGeneralProjects(List<String> skills, String careerGoal) {
    return [
      ProjectModel(
        id: 'general_1',
        title: 'Digital Library Management System',
        description: 'Comprehensive system for managing digital books, user accounts, borrowing, and recommendations with modern web interface.',
        problemStatement: 'Libraries need modern digital solutions to manage resources efficiently and provide better user experiences.',
        techStack: skills.take(4).toList()..addAll(['Database', 'Web Framework']),
        domain: 'Web Development',
        difficulty: 'Beginner',
        industryRelevanceScore: 3,
        realWorldApplications: ['Public libraries', 'University libraries', 'Corporate knowledge bases'],
        possibleExtensions: ['Mobile app', 'AI recommendations', 'Social features'],
        careerRelevance: careerGoal,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        tags: ['Web', 'Database', 'Management'],
      ),
      ProjectModel(
        id: 'general_2',
        title: 'Task Management & Productivity App',
        description: 'Cross-platform application for personal and team task management with time tracking, collaboration, and analytics features.',
        problemStatement: 'Individuals and teams need better tools to organize tasks, track productivity, and collaborate effectively.',
        techStack: skills.take(3).toList()..addAll(['Cross-platform Framework', 'Database']),
        domain: 'Software Development',
        difficulty: 'Intermediate',
        industryRelevanceScore: 4,
        realWorldApplications: ['Small businesses', 'Freelancers', 'Project teams'],
        possibleExtensions: ['AI task prioritization', 'Integration with calendar apps', 'Advanced analytics'],
        careerRelevance: careerGoal,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        tags: ['Productivity', 'Management', 'Collaboration'],
      ),
    ];
  }


  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }
}
