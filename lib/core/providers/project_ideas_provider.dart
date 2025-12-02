import 'package:flutter/foundation.dart';
import '../models/project_idea_model.dart';
import '../../features/project_ideas/services/project_ideas_service.dart';

class ProjectIdeasProvider with ChangeNotifier {
  
  List<ProjectIdeaModel> _projectIdeas = [];
  List<ProjectIdeaModel> _filteredIdeas = [];
  bool _isLoading = false;
  String? _error;
  String _searchQuery = '';
  String _selectedDomain = 'All';
  String _selectedDifficulty = 'All';

  // Getters
  List<ProjectIdeaModel> get projectIdeas => _filteredIdeas;
  List<ProjectIdeaModel> get allProjectIdeas => _projectIdeas;
  bool get isLoading => _isLoading;
  String? get error => _error;
  String get searchQuery => _searchQuery;
  String get selectedDomain => _selectedDomain;
  String get selectedDifficulty => _selectedDifficulty;

  // Get unique domains from all project ideas
  List<String> get availableDomains {
    final domains = _projectIdeas.map((idea) => idea.domain).toSet().toList();
    domains.sort();
    return ['All', ...domains];
  }

  // Get unique difficulties from all project ideas
  List<String> get availableDifficulties {
    final difficulties = _projectIdeas.map((idea) => idea.difficulty).toSet().toList();
    difficulties.sort();
    return ['All', ...difficulties];
  }

  // Initialize and load project ideas
  Future<void> initialize() async {
    await loadProjectIdeas();
  }

  // Load all project ideas from Firebase
  Future<void> loadProjectIdeas() async {
    _setLoading(true);
    _setError(null);

    try {
      _projectIdeas = await ProjectIdeasService.getAllProjectIdeas();
      _applyFilters();
      _setLoading(false);
    } catch (e) {
      _setError('Failed to load project ideas: ${e.toString()}');
      _setLoading(false);
    }
  }

  // Submit a new project idea
  Future<bool> submitProjectIdea(ProjectIdeaModel idea) async {
    try {
      await ProjectIdeasService.submitProjectIdea(idea);
      // Reload ideas to include the new one
      await loadProjectIdeas();
      return true;
    } catch (e) {
      _setError('Failed to submit project idea: ${e.toString()}');
      return false;
    }
  }

  // Like or unlike a project idea
  Future<void> toggleLike(String ideaId, String userId) async {
    try {
      // Find the idea in our local list
      final ideaIndex = _projectIdeas.indexWhere((idea) => idea.id == ideaId);
      if (ideaIndex == -1) return;

      final idea = _projectIdeas[ideaIndex];
      final isLiked = idea.likedBy.contains(userId);

      if (isLiked) {
        await ProjectIdeasService.toggleLikeProjectIdea(ideaId, userId);
        // Update local state
        final updatedLikedBy = List<String>.from(idea.likedBy);
        updatedLikedBy.remove(userId);
        _projectIdeas[ideaIndex] = idea.copyWith(
          likedBy: updatedLikedBy,
          likes: updatedLikedBy.length,
        );
      } else {
        await ProjectIdeasService.toggleLikeProjectIdea(ideaId, userId);
        // Update local state
        final updatedLikedBy = List<String>.from(idea.likedBy);
        updatedLikedBy.add(userId);
        _projectIdeas[ideaIndex] = idea.copyWith(
          likedBy: updatedLikedBy,
          likes: updatedLikedBy.length,
        );
      }

      _applyFilters();
    } catch (e) {
      _setError('Failed to update like: ${e.toString()}');
    }
  }

  // Increment view count for a project idea
  Future<void> incrementViewCount(String ideaId) async {
    try {
      await ProjectIdeasService.incrementViewCount(ideaId);
      
      // Update local state
      final ideaIndex = _projectIdeas.indexWhere((idea) => idea.id == ideaId);
      if (ideaIndex != -1) {
        final idea = _projectIdeas[ideaIndex];
        _projectIdeas[ideaIndex] = idea.copyWith(
          views: idea.views + 1,
        );
        _applyFilters();
      }
    } catch (e) {
      _setError('Failed to update view count: ${e.toString()}');
    }
  }

  // Delete a project idea (only by author)
  Future<bool> deleteProjectIdea(String ideaId, String userId) async {
    try {
      await ProjectIdeasService.deleteProjectIdea(ideaId, userId);
      // Remove from local list
      _projectIdeas.removeWhere((idea) => idea.id == ideaId);
      _applyFilters();
      return true;
    } catch (e) {
      _setError('Failed to delete project idea: ${e.toString()}');
      return false;
    }
  }

  // Search project ideas
  void searchIdeas(String query) {
    _searchQuery = query.toLowerCase();
    _applyFilters();
  }

  // Filter by domain
  void filterByDomain(String domain) {
    _selectedDomain = domain;
    _applyFilters();
  }

  // Filter by difficulty
  void filterByDifficulty(String difficulty) {
    _selectedDifficulty = difficulty;
    _applyFilters();
  }

  // Clear all filters
  void clearFilters() {
    _searchQuery = '';
    _selectedDomain = 'All';
    _selectedDifficulty = 'All';
    _applyFilters();
  }

  // Apply current filters to the project ideas list
  void _applyFilters() {
    _filteredIdeas = _projectIdeas.where((idea) {
      // Search filter
      bool matchesSearch = _searchQuery.isEmpty ||
          idea.title.toLowerCase().contains(_searchQuery) ||
          idea.description.toLowerCase().contains(_searchQuery) ||
          idea.techStack.any((tech) => tech.toLowerCase().contains(_searchQuery)) ||
          idea.domain.toLowerCase().contains(_searchQuery);

      // Domain filter
      bool matchesDomain = _selectedDomain == 'All' || idea.domain == _selectedDomain;

      // Difficulty filter
      bool matchesDifficulty = _selectedDifficulty == 'All' || idea.difficulty == _selectedDifficulty;

      return matchesSearch && matchesDomain && matchesDifficulty;
    }).toList();

    // Sort by creation date (newest first)
    _filteredIdeas.sort((a, b) => b.createdAt.compareTo(a.createdAt));

    notifyListeners();
  }

  // Get project ideas by author
  List<ProjectIdeaModel> getIdeasByAuthor(String authorId) {
    return _projectIdeas.where((idea) => idea.authorId == authorId).toList();
  }

  // Get most liked project ideas
  List<ProjectIdeaModel> getMostLikedIdeas({int limit = 10}) {
    final sortedIdeas = List<ProjectIdeaModel>.from(_projectIdeas);
    sortedIdeas.sort((a, b) => b.likes.compareTo(a.likes));
    return sortedIdeas.take(limit).toList();
  }

  // Get most viewed project ideas
  List<ProjectIdeaModel> getMostViewedIdeas({int limit = 10}) {
    final sortedIdeas = List<ProjectIdeaModel>.from(_projectIdeas);
    sortedIdeas.sort((a, b) => b.views.compareTo(a.views));
    return sortedIdeas.take(limit).toList();
  }

  // Get recent project ideas
  List<ProjectIdeaModel> getRecentIdeas({int limit = 10}) {
    final sortedIdeas = List<ProjectIdeaModel>.from(_projectIdeas);
    sortedIdeas.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return sortedIdeas.take(limit).toList();
  }

  // Get project ideas by difficulty
  List<ProjectIdeaModel> getIdeasByDifficulty(String difficulty) {
    return _projectIdeas.where((idea) => idea.difficulty == difficulty).toList();
  }

  // Get project ideas by domain
  List<ProjectIdeaModel> getIdeasByDomain(String domain) {
    return _projectIdeas.where((idea) => idea.domain == domain).toList();
  }

  // Check if user has liked a specific idea
  bool hasUserLikedIdea(String ideaId, String userId) {
    final idea = _projectIdeas.firstWhere(
      (idea) => idea.id == ideaId,
      orElse: () => ProjectIdeaModel(
        id: '',
        title: '',
        description: '',
        domain: '',
        difficulty: '',
        techStack: [],
        problemStatement: '',
        expectedOutcomes: [],
        estimatedDuration: '',
        authorId: '',
        authorName: '',
        authorEmail: '',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        likes: 0,
        views: 0,
        likedBy: [],
        isApproved: false,
      ),
    );
    return idea.likedBy.contains(userId);
  }

  // Get statistics
  Map<String, dynamic> getStatistics() {
    return {
      'totalIdeas': _projectIdeas.length,
      'totalLikes': _projectIdeas.fold<int>(0, (sum, idea) => sum + idea.likes),
      'totalViews': _projectIdeas.fold<int>(0, (sum, idea) => sum + idea.views),
      'domainDistribution': _getDomainDistribution(),
      'difficultyDistribution': _getDifficultyDistribution(),
    };
  }

  Map<String, int> _getDomainDistribution() {
    final distribution = <String, int>{};
    for (final idea in _projectIdeas) {
      distribution[idea.domain] = (distribution[idea.domain] ?? 0) + 1;
    }
    return distribution;
  }

  Map<String, int> _getDifficultyDistribution() {
    final distribution = <String, int>{};
    for (final idea in _projectIdeas) {
      distribution[idea.difficulty] = (distribution[idea.difficulty] ?? 0) + 1;
    }
    return distribution;
  }

  // Refresh data
  Future<void> refresh() async {
    await loadProjectIdeas();
  }

  // Private helper methods
  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void _setError(String? error) {
    _error = error;
    notifyListeners();
  }

  // Clear error
  void clearError() {
    _error = null;
    notifyListeners();
  }

}
