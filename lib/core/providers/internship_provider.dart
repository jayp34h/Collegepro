import 'dart:async';
import 'package:flutter/foundation.dart';
import '../models/internship_model.dart';
import '../services/firebase_internship_service.dart';
import '../services/firebase_internship_initializer.dart';

class InternshipProvider extends ChangeNotifier {
  List<InternshipModel> _internships = [];
  List<InternshipModel> _filteredInternships = [];
  bool _isLoading = false;
  String? _error;
  String _searchQuery = '';
  String _selectedLocation = 'All';
  String _selectedKeyword = 'computer science';
  int _currentPage = 1;
  bool _hasMoreData = false;
  StreamSubscription<List<InternshipModel>>? _internshipsSubscription;

  InternshipProvider() {
    // Initialize Firebase data when provider is created
    _initializeFirebaseData();
  }

  /// Initialize Firebase data with sample internships
  Future<void> _initializeFirebaseData() async {
    try {
      // Always force reinitialize to ensure fresh data
      if (kDebugMode) print('🔄 Force reinitializing internships with fresh data...');
      await FirebaseInternshipInitializer.forceInitializeInternships();
      // Small delay to ensure data is written to Firestore
      await Future.delayed(const Duration(seconds: 3));
      
      // Set up real-time listener
      _setupRealtimeListener();
    } catch (e) {
      if (kDebugMode) print('Error initializing Firebase data: $e');
    }
  }

  /// Set up real-time listener for internships
  void _setupRealtimeListener() {
    _internshipsSubscription?.cancel();
    _internshipsSubscription = FirebaseInternshipService.getInternshipsStream().listen(
      (internships) {
        if (kDebugMode) print('📡 Received real-time update: ${internships.length} internships');
        _internships = internships;
        _applyFilters();
        notifyListeners();
      },
      onError: (error) {
        if (kDebugMode) print('❌ Real-time listener error: $error');
        _error = 'Real-time connection failed: $error';
        notifyListeners();
      },
    );
  }

  @override
  void dispose() {
    _internshipsSubscription?.cancel();
    super.dispose();
  }

  // Initialize provider
  Future<void> initialize() async {
    try {
      await loadInternships();
    } catch (e) {
      _isLoading = false;
      _error = 'Failed to load internships. Please try again.';
      notifyListeners();
    }
  }

  // Getters
  List<InternshipModel> get internships => _internships;
  List<InternshipModel> get filteredInternships => _filteredInternships;
  bool get isLoading => _isLoading;
  String? get error => _error;
  String get searchQuery => _searchQuery;
  String get selectedLocation => _selectedLocation;
  String get selectedKeyword => _selectedKeyword;
  int get currentPage => _currentPage;
  bool get hasMoreData => _hasMoreData;

  /// Load internships from Firebase
  Future<void> loadInternships({bool refresh = false}) async {
    if (_isLoading) return; // Prevent concurrent loading
    
    if (refresh) {
      _internships.clear();
    }
    
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final internships = await FirebaseInternshipService.getAllInternships();
      
      if (refresh) {
        _internships = internships;
      } else {
        _internships = internships;
      }
      
      _applyFilters();
      _hasMoreData = false; // Firebase loads all data at once
      
    } catch (e) {
      _error = 'Failed to load internships: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Search internships
  Future<void> searchInternships(String query) async {
    _searchQuery = query;
    _isLoading = true;
    notifyListeners();
    
    try {
      if (query.isEmpty) {
        _internships = await FirebaseInternshipService.getAllInternships();
      } else {
        _internships = await FirebaseInternshipService.searchInternships(query);
      }
      _applyFilters();
    } catch (e) {
      _error = 'Failed to search internships: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Filter by location
  Future<void> filterByLocation(String location) async {
    _selectedLocation = location;
    _isLoading = true;
    notifyListeners();
    
    try {
      if (location == 'All') {
        _internships = await FirebaseInternshipService.getAllInternships();
      } else {
        _internships = await FirebaseInternshipService.getInternshipsByLocation(location);
      }
      _applyFilters();
    } catch (e) {
      _error = 'Failed to filter internships: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Filter by keyword/category
  Future<void> filterByKeyword(String keyword) async {
    _selectedKeyword = keyword;
    _isLoading = true;
    notifyListeners();
    
    try {
      _internships = await FirebaseInternshipService.searchInternships(keyword);
      _applyFilters();
    } catch (e) {
      _error = 'Failed to filter internships: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Load more internships (not needed for Firebase - loads all at once)
  Future<void> loadMoreInternships() async {
    // Firebase loads all data at once, so this is not needed
    return;
  }

  /// Apply current filters
  void _applyFilters() {
    List<InternshipModel> filtered = _internships;
    
    // Apply search filter
    if (_searchQuery.isNotEmpty) {
      final searchLower = _searchQuery.toLowerCase();
      filtered = filtered.where((internship) {
        return internship.title.toLowerCase().contains(searchLower) ||
               internship.company.toLowerCase().contains(searchLower) ||
               internship.location.toLowerCase().contains(searchLower) ||
               internship.skillsText.toLowerCase().contains(searchLower);
      }).toList();
    }
    
    _filteredInternships = filtered;
  }

  /// Clear all filters
  void clearFilters() {
    _searchQuery = '';
    _selectedLocation = 'All';
    _selectedKeyword = 'computer science';
    _applyFilters();
    notifyListeners();
  }

  /// Force refresh all data
  Future<void> forceRefreshData() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      // Get fresh data from Firebase
      final internships = await FirebaseInternshipService.getAllInternships();
      _internships = internships;
      _applyFilters();
      
      if (kDebugMode) print('✅ Force refreshed ${internships.length} internships');
    } catch (e) {
      _error = 'Failed to refresh internships: $e';
      if (kDebugMode) print('❌ Error force refreshing: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Refresh data
  Future<void> refreshData() async {
    _currentPage = 1;
    _hasMoreData = true;
    await loadInternships(refresh: true);
  }



  /// Get available locations
  List<String> get availableLocations {
    final locations = ['All'] + FirebaseInternshipService.getPopularLocations();
    return locations;
  }

  /// Get available keywords
  List<String> get availableKeywords => FirebaseInternshipService.getPopularKeywords();

  /// Get internship statistics
  Map<String, int> get stats {
    final total = _internships.length;
    final remote = _internships.where((i) => i.location.toLowerCase().contains('remote')).length;
    final paid = _internships.where((i) => !i.stipend.toLowerCase().contains('unpaid')).length;
    final urgent = _internships.where((i) => i.urgencyLevel == 'urgent').length;

    return {
      'total': total,
      'remote': remote,
      'paid': paid,
      'urgent': urgent,
    };
  }
}
