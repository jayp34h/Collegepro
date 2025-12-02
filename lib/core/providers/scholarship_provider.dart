import 'package:flutter/material.dart';
import '../models/scholarship_model.dart';
import '../services/firebase_scholarship_service.dart';
import '../services/firebase_scholarship_initializer.dart';

class ScholarshipProvider extends ChangeNotifier {
  List<ScholarshipModel> _scholarships = [];
  List<ScholarshipModel> _filteredScholarships = [];
  bool _isLoading = false;
  String? _error;
  String _searchQuery = '';
  String _selectedCategory = 'All';
  Map<String, int> _stats = {};

  // Getters
  List<ScholarshipModel> get scholarships => _filteredScholarships;
  List<ScholarshipModel> get allScholarships => _scholarships;
  List<ScholarshipModel> get filteredScholarships => _filteredScholarships;
  bool get isLoading => _isLoading;
  String? get error => _error;
  String get searchQuery => _searchQuery;
  String get selectedCategory => _selectedCategory;
  Map<String, int> get stats => _stats;
  bool get hasData => _scholarships.isNotEmpty;
  int get totalCount => _scholarships.length;

  /// Load scholarships from Firebase
  Future<void> loadScholarships() async {
    _setLoading(true);
    _error = null;
    
    try {
      // Always force initialize to ensure we have the latest user-specified scholarships
      print('🔄 Force initializing with user-specified scholarships...');
      await FirebaseScholarshipInitializer.forceInitializeScholarships();
      
      // Load scholarships from Firebase
      _scholarships = await FirebaseScholarshipService.getAllScholarships();
      print('✅ Loaded ${_scholarships.length} scholarships from Firebase');
      
      _applyFilters();
      _calculateStats();
      
      _error = null;
      _setLoading(false);
    } catch (e) {
      print('❌ Provider error: $e');
      _error = null;
      _setLoading(false);
      _scholarships = [];
    }
  }

  /// Search scholarships in Firebase
  Future<void> searchScholarships(String query) async {
    _searchQuery = query;
    
    if (query.isEmpty) {
      _filteredScholarships = _filterByCategory(_scholarships);
    } else {
      _setLoading(true);
      try {
        final results = await FirebaseScholarshipService.searchScholarships(query);
        _filteredScholarships = _filterByCategory(results);
        _setLoading(false);
      } catch (e) {
        print('❌ Search error: $e');
        _setLoading(false);
      }
    }
    notifyListeners();
  }

  /// Filter by category
  void filterByCategory(String category) {
    _selectedCategory = category;
    _applyFilters();
    notifyListeners();
  }

  /// Apply current filters
  void _applyFilters() {
    List<ScholarshipModel> filtered = _scholarships;
    
    // Apply search filter
    if (_searchQuery.isNotEmpty) {
      final searchLower = _searchQuery.toLowerCase();
      filtered = filtered.where((scholarship) {
        return scholarship.title.toLowerCase().contains(searchLower) ||
               scholarship.organizer.toLowerCase().contains(searchLower) ||
               scholarship.category.toLowerCase().contains(searchLower) ||
               scholarship.tags.any((tag) => tag.toLowerCase().contains(searchLower));
      }).toList();
    }
    
    // Apply category filter
    filtered = _filterByCategory(filtered);
    
    _filteredScholarships = filtered;
  }

  /// Filter scholarships by category
  List<ScholarshipModel> _filterByCategory(List<ScholarshipModel> scholarships) {
    if (_selectedCategory == 'All') {
      return scholarships;
    }
    
    return scholarships.where((scholarship) {
      return scholarship.category == _selectedCategory;
    }).toList();
  }

  /// Clear all filters
  void clearFilters() {
    _searchQuery = '';
    _selectedCategory = 'All';
    _applyFilters();
    notifyListeners();
  }

  /// Refresh data
  Future<void> refreshData() async {
    await loadScholarships();
  }

  /// Set loading state
  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  /// Calculate stats from current scholarships
  void _calculateStats() {
    _stats = {
      'total': _scholarships.length,
      'active': _scholarships.where((s) => s.isActive).length,
      'expired': _scholarships.where((s) => s.isExpired).length,
      'engineering': _scholarships.where((s) => s.category.toLowerCase().contains('engineering')).length,
      'merit': _scholarships.where((s) => s.category.toLowerCase().contains('merit')).length,
    };
  }

  /// Get available categories
  List<String> get availableCategories => FirebaseScholarshipService.getPopularCategories();
  
  /// Get categories for filtering
  List<String> getCategories() => ['All'] + FirebaseScholarshipService.getPopularCategories();
  
  /// Refresh scholarships data
  Future<void> refreshScholarships() async {
    await loadScholarships();
  }
}
