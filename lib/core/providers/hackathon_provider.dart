import 'package:flutter/material.dart';
import '../models/hackathon_model.dart';
import '../services/firebase_hackathon_service.dart';
import '../services/firebase_hackathon_initializer.dart';

class HackathonProvider extends ChangeNotifier {
  List<HackathonModel> _hackathons = [];
  bool _isLoading = false;
  String _searchQuery = '';
  String _selectedCategory = 'All';

  // Getters
  List<HackathonModel> get hackathons => _hackathons;
  bool get isLoading => _isLoading;
  String get searchQuery => _searchQuery;
  String get selectedCategory => _selectedCategory;

  // Filtered hackathons based on search and category
  List<HackathonModel> get filteredHackathons {
    return _hackathons.where((hackathon) {
      // Search filter
      if (_searchQuery.isNotEmpty) {
        final matchesSearch = hackathon.title.toLowerCase().contains(_searchQuery.toLowerCase()) ||
               hackathon.description.toLowerCase().contains(_searchQuery.toLowerCase()) ||
               hackathon.organizer.toLowerCase().contains(_searchQuery.toLowerCase());
        if (!matchesSearch) return false;
      }
      
      // Category filter
      if (_selectedCategory != 'All' && _selectedCategory.isNotEmpty) {
        final matchesCategory = hackathon.tags.any((tag) => 
          tag.toLowerCase().contains(_selectedCategory.toLowerCase()));
        if (!matchesCategory) return false;
      }
      
      return true;
    }).toList();
  }

  // Categories from hackathons
  List<String> get categories {
    final allTags = <String>{'All'};
    for (final hackathon in _hackathons) {
      allTags.addAll(hackathon.tags);
    }
    return allTags.toList();
  }

  // Stats getter
  Map<String, int> get stats {
    final total = _hackathons.length;
    final active = _hackathons.where((h) => h.status.toLowerCase() == 'active').length;
    final upcoming = _hackathons.where((h) => h.status.toLowerCase() == 'upcoming').length;
    final registrationOpen = _hackathons.where((h) => h.isRegistrationOpen).length;
    
    return {
      'total': total,
      'active': active,
      'upcoming': upcoming,
      'registrationOpen': registrationOpen,
    };
  }

  /// Initialize and load hackathons
  Future<void> initialize() async {
    if (_hackathons.isNotEmpty) return;
    await loadHackathons();
  }

  /// Load hackathons from Firebase
  Future<void> loadHackathons() async {
    _setLoading(true);
    
    try {
      // Always force initialize to ensure we have the latest user-specified hackathons
      print('🔄 Force initializing with user-specified hackathons...');
      await FirebaseHackathonInitializer.forceInitializeHackathons();
      
      // Load hackathons from Firebase
      _hackathons = await FirebaseHackathonService.getAllHackathons();
      print('✅ Loaded ${_hackathons.length} hackathons from Firebase');
    } catch (e) {
      print('❌ Provider error: $e');
      _hackathons = [];
    }
    
    _setLoading(false);
  }

  /// Search hackathons in Firebase
  Future<void> searchHackathonsInFirebase(String query) async {
    if (query.isEmpty) {
      await loadHackathons();
      return;
    }
    
    _setLoading(true);
    
    try {
      _hackathons = await FirebaseHackathonService.searchHackathons(query);
      _searchQuery = query;
    } catch (e) {
      print('❌ Search error: $e');
    }
    
    _setLoading(false);
  }

  /// Search hackathons
  void searchHackathons(String query) {
    _searchQuery = query;
    notifyListeners();
  }

  /// Filter by category
  void filterByCategory(String category) {
    _selectedCategory = category;
    notifyListeners();
  }

  /// Clear all filters
  void clearFilters() {
    _searchQuery = '';
    _selectedCategory = 'All';
    notifyListeners();
  }

  /// Refresh data
  Future<void> refreshData() async {
    _hackathons.clear();
    await loadHackathons();
  }

  /// Force initialize hackathons data
  Future<void> forceInitializeData() async {
    _setLoading(true);
    
    try {
      print('🔄 Force initializing hackathons data...');
      await FirebaseHackathonInitializer.forceInitializeHackathons();
      await loadHackathons();
    } catch (e) {
      print('❌ Force initialization error: $e');
    }
    
    _setLoading(false);
  }

  /// Set loading state
  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }
}
