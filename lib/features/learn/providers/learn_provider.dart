import 'package:flutter/foundation.dart';
import '../services/youtube_service.dart';

class LearnProvider with ChangeNotifier {
  final YouTubeService _youtubeService = YouTubeService();
  
  List<YouTubeVideo> _videos = [];
  List<YouTubeVideo> _searchResults = [];
  bool _isLoading = false;
  bool _isSearching = false;
  String? _error;
  String _searchQuery = '';
  
  // Categories for educational content
  final List<String> _categories = [
    'All',
    'Programming',
    'Web Development',
    'Data Science',
    'Machine Learning',
    'Mobile Development',
    'Computer Science',
    'Software Engineering',
    'Algorithms',
    'Database',
  ];
  
  String _selectedCategory = 'All';
  
  // Getters
  List<YouTubeVideo> get videos => _searchQuery.isEmpty ? _videos : _searchResults;
  List<String> get categories => _categories;
  String get selectedCategory => _selectedCategory;
  bool get isLoading => _isLoading;
  bool get isSearching => _isSearching;
  String? get error => _error;
  String get searchQuery => _searchQuery;
  
  // Initialize with educational videos
  Future<void> initialize() async {
    await loadEducationalVideos();
  }
  
  // Load educational videos
  Future<void> loadEducationalVideos() async {
    _setLoading(true);
    _error = null;
    
    try {
      _videos = await _youtubeService.getTrendingEducationalVideos();
      _setLoading(false);
    } catch (e) {
      _error = 'Failed to load videos: $e';
      _setLoading(false);
      print('Error loading educational videos: $e');
    }
  }
  
  // Search videos
  Future<void> searchVideos(String query) async {
    if (query.trim().isEmpty) {
      _searchQuery = '';
      _searchResults = [];
      notifyListeners();
      return;
    }
    
    _setSearching(true);
    _searchQuery = query;
    _error = null;
    
    try {
      _searchResults = await _youtubeService.searchVideos(
        query: query,
        maxResults: 25,
        order: 'relevance',
      );
      _setSearching(false);
    } catch (e) {
      _error = 'Failed to search videos: $e';
      _setSearching(false);
      print('Error searching videos: $e');
    }
  }
  
  // Filter by category
  Future<void> filterByCategory(String category) async {
    _selectedCategory = category;
    _searchQuery = '';
    _searchResults = [];
    
    if (category == 'All') {
      await loadEducationalVideos();
    } else {
      _setLoading(true);
      _error = null;
      
      try {
        _videos = await _youtubeService.searchVideos(
          query: category.toLowerCase(),
          maxResults: 20,
          order: 'relevance',
        );
        _setLoading(false);
      } catch (e) {
        _error = 'Failed to load category videos: $e';
        _setLoading(false);
        print('Error filtering by category: $e');
      }
    }
  }
  
  // Clear search
  void clearSearch() {
    _searchQuery = '';
    _searchResults = [];
    notifyListeners();
  }
  
  // Clear error
  void clearError() {
    _error = null;
    notifyListeners();
  }
  
  // Get video details
  Future<YouTubeVideoDetails?> getVideoDetails(String videoId) async {
    try {
      return await _youtubeService.getVideoDetails(videoId);
    } catch (e) {
      print('Error getting video details: $e');
      return null;
    }
  }
  
  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }
  
  void _setSearching(bool searching) {
    _isSearching = searching;
    notifyListeners();
  }
  
  // Refresh videos
  Future<void> refresh() async {
    if (_searchQuery.isNotEmpty) {
      await searchVideos(_searchQuery);
    } else if (_selectedCategory != 'All') {
      await filterByCategory(_selectedCategory);
    } else {
      await loadEducationalVideos();
    }
  }
}
