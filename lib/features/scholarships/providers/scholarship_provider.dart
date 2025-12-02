import 'package:flutter/material.dart';
import '../../../core/models/scholarship_model.dart';
import '../../../core/services/scholarship_service.dart';
import '../../../core/services/firebase_scholarship_initializer.dart';

class ScholarshipProvider with ChangeNotifier {
  List<ScholarshipModel> _scholarships = [];
  List<ScholarshipModel> _filteredScholarships = [];
  bool _isLoading = false;
  String? _error;
  String _selectedCategory = 'All';
  String _searchQuery = '';
  Map<String, int> _stats = {};

  // Getters
  List<ScholarshipModel> get scholarships => _filteredScholarships;
  List<ScholarshipModel> get allScholarships => _scholarships;
  bool get isLoading => _isLoading;
  String? get error => _error;
  String get selectedCategory => _selectedCategory;
  String get searchQuery => _searchQuery;
  Map<String, int> get stats => _stats;
  
  bool get hasData => _scholarships.isNotEmpty;
  int get totalCount => _scholarships.length;

  /// Load scholarships from Firestore
  Future<void> loadScholarships() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      // Initialize scholarships with user-specified data
      await FirebaseScholarshipInitializer.forceInitializeScholarships();
      _scholarships = await FirebaseScholarshipService.getAllScholarships();
      _filteredScholarships = List.from(_scholarships);
      _stats = await FirebaseScholarshipService.getScholarshipStats();
      _applyFilters();
    } catch (e) {
      _error = 'Failed to load scholarships: ${e.toString()}';
      print('ScholarshipProvider Error: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Refresh scholarships data
  Future<void> refreshScholarships() async {
    await loadScholarships();
  }

  /// Search scholarships
  Future<void> searchScholarships(String query) async {
    _searchQuery = query;
    
    if (query.isEmpty) {
      _filteredScholarships = List.from(_scholarships);
    } else {
      _isLoading = true;
      notifyListeners();
      
      try {
        _filteredScholarships = await FirebaseScholarshipService.searchScholarships(query);
      } catch (e) {
        _error = 'Search failed: ${e.toString()}';
      } finally {
        _isLoading = false;
      }
    }
    
    _applyFilters();
    notifyListeners();
  }

  /// Filter scholarships by category
  void filterByCategory(String category) {
    _selectedCategory = category;
    _applyFilters();
    notifyListeners();
  }

  /// Apply current filters
  void _applyFilters() {
    List<ScholarshipModel> filtered = List.from(_scholarships);

    // Apply search filter
    if (_searchQuery.isNotEmpty) {
      final searchLower = _searchQuery.toLowerCase();
      filtered = filtered.where((scholarship) {
        return scholarship.title.toLowerCase().contains(searchLower) ||
               scholarship.organizer.toLowerCase().contains(searchLower) ||
               scholarship.category.toLowerCase().contains(searchLower);
      }).toList();
    }

    // Apply category filter
    if (_selectedCategory != 'All') {
      filtered = filtered.where((scholarship) {
        return scholarship.category == _selectedCategory;
      }).toList();
    }

    _filteredScholarships = filtered;
  }

  /// Clear search and filters
  void clearFilters() {
    _searchQuery = '';
    _selectedCategory = 'All';
    _filteredScholarships = List.from(_scholarships);
    notifyListeners();
  }

  /// Get available categories
  List<String> getCategories() {
    return [
      'All',
      'Merit Based',
      'Minority',
      'Reserved Category',
      'Women',
      'Research',
      'General',
    ];
  }

  /// Check if data needs refresh
  Future<bool> needsRefresh() async {
    try {
      // Always refresh to ensure we have the latest user-specified scholarships
      return true;
    } catch (e) {
      return true;
    }
  }

  /// Get scholarship by ID
  ScholarshipModel? getScholarshipById(String id) {
    try {
      return _scholarships.firstWhere((s) => s.id == id);
    } catch (e) {
      return null;
    }
  }
}
