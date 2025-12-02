import 'package:flutter/material.dart';
import '../models/hackathon_model.dart';
import '../services/hackathon_service.dart';

class HackathonProvider with ChangeNotifier {
  final HackathonService _hackathonService = HackathonService();

  HackathonProvider() {
    // Don't load hackathons in constructor to prevent blocking initialization
    // Hackathons will be loaded when needed
  }

  // Initialize provider with timeout protection
  Future<void> initialize() async {
    try {
      await loadHackathons().timeout(const Duration(seconds: 15));
    } catch (e) {
      print('HackathonProvider initialization failed: $e');
      _isLoading = false;
      _error = 'Failed to load hackathons. Please try again.';
      notifyListeners();
    }
  }

  List<Hackathon> _hackathons = [];
  List<Hackathon> _filteredHackathons = [];
  bool _isLoading = false;
  String? _error;
  String _searchQuery = '';
  Set<String> _selectedTags = {};
  bool _showOnlineOnly = false;
  bool _showOfflineOnly = false;

  // Getters
  List<Hackathon> get hackathons => _hackathons;
  List<Hackathon> get filteredHackathons => _filteredHackathons;
  bool get isLoading => _isLoading;
  String? get error => _error;
  String get searchQuery => _searchQuery;
  Set<String> get selectedTags => _selectedTags;
  bool get showOnlineOnly => _showOnlineOnly;
  bool get showOfflineOnly => _showOfflineOnly;

  // Get all available tags
  List<String> get availableTags {
    final tags = <String>{};
    for (final hackathon in _hackathons) {
      tags.addAll(hackathon.tags);
    }
    return tags.toList()..sort();
  }

  // Get hackathon count by status
  int get upcomingCount => _hackathons.where((h) => h.isUpcoming).length;
  int get onlineCount => _hackathons.where((h) => h.isOnline).length;
  int get offlineCount => _hackathons.where((h) => !h.isOnline).length;

  /// Load hackathons from API
  Future<void> loadHackathons({bool forceRefresh = false}) async {
    if (_isLoading) return; // Prevent concurrent loading

    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      if (forceRefresh) {
        await _hackathonService.clearCache();
      }

      final hackathons = await _hackathonService.fetchUpcomingHackathons()
          .timeout(const Duration(seconds: 15));
      _hackathons = hackathons;
      _filteredHackathons = hackathons;
      _applyFilters();
    } catch (e) {
      _error = 'Failed to load hackathons: $e';
      print('Error loading hackathons: $e');
      // Set empty list on error to prevent null issues
      _hackathons = [];
      _filteredHackathons = [];
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Search hackathons by query
  void searchHackathons(String query) {
    _searchQuery = query.toLowerCase();
    _applyFilters();
    notifyListeners();
  }

  /// Toggle tag filter
  void toggleTagFilter(String tag) {
    if (_selectedTags.contains(tag)) {
      _selectedTags.remove(tag);
    } else {
      _selectedTags.add(tag);
    }
    _applyFilters();
    notifyListeners();
  }

  /// Set online/offline filter
  void setOnlineFilter(bool? online) {
    if (online == null) {
      _showOnlineOnly = false;
      _showOfflineOnly = false;
    } else if (online) {
      _showOnlineOnly = true;
      _showOfflineOnly = false;
    } else {
      _showOnlineOnly = false;
      _showOfflineOnly = true;
    }
    _applyFilters();
    notifyListeners();
  }

  /// Clear all filters
  void clearAllFilters() {
    _searchQuery = '';
    _selectedTags.clear();
    _showOnlineOnly = false;
    _showOfflineOnly = false;
    _applyFilters();
    notifyListeners();
  }

  /// Apply all active filters
  void _applyFilters() {
    _filteredHackathons = _hackathons.where((hackathon) {
      // Search filter
      if (_searchQuery.isNotEmpty) {
        final matchesSearch = hackathon.title.toLowerCase().contains(_searchQuery) ||
            hackathon.description.toLowerCase().contains(_searchQuery) ||
            hackathon.location.toLowerCase().contains(_searchQuery) ||
            (hackathon.organizerName?.toLowerCase().contains(_searchQuery) ?? false);
        if (!matchesSearch) return false;
      }

      // Tag filter
      if (_selectedTags.isNotEmpty) {
        final hasMatchingTag = hackathon.tags.any((tag) => _selectedTags.contains(tag));
        if (!hasMatchingTag) return false;
      }

      // Online/Offline filter
      if (_showOnlineOnly && !hackathon.isOnline) return false;
      if (_showOfflineOnly && hackathon.isOnline) return false;

      return true;
    }).toList();

    // Sort by start date (upcoming first)
    _filteredHackathons.sort((a, b) => a.startDatetime.compareTo(b.startDatetime));
  }

  /// Get cache information
  Future<Map<String, dynamic>> getCacheInfo() async {
    return await _hackathonService.getCacheInfo();
  }

  /// Clear cache
  Future<void> clearCache() async {
    await _hackathonService.clearCache();
  }

  /// Refresh hackathons (force reload)
  Future<void> refreshHackathons() async {
    try {
      await loadHackathons(forceRefresh: true).timeout(const Duration(seconds: 15));
    } catch (e) {
      print('Failed to refresh hackathons: $e');
      _error = 'Failed to refresh hackathons. Please try again.';
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Get hackathons by category
  List<Hackathon> getHackathonsByTag(String tag) {
    return _hackathons.where((h) => h.tags.contains(tag)).toList();
  }

  /// Get upcoming hackathons only
  List<Hackathon> get upcomingHackathons {
    return _hackathons.where((h) => h.isUpcoming).toList();
  }

  /// Get online hackathons only
  List<Hackathon> get onlineHackathons {
    return _hackathons.where((h) => h.isOnline).toList();
  }

  /// Get offline hackathons only
  List<Hackathon> get offlineHackathons {
    return _hackathons.where((h) => !h.isOnline).toList();
  }

  /// Check if any filters are active
  bool get hasActiveFilters {
    return _searchQuery.isNotEmpty || 
           _selectedTags.isNotEmpty || 
           _showOnlineOnly || 
           _showOfflineOnly;
  }

  /// Get filter summary text
  String get filterSummary {
    final parts = <String>[];
    
    if (_searchQuery.isNotEmpty) {
      parts.add('Search: "$_searchQuery"');
    }
    
    if (_selectedTags.isNotEmpty) {
      parts.add('Tags: ${_selectedTags.join(", ")}');
    }
    
    if (_showOnlineOnly) {
      parts.add('Online only');
    } else if (_showOfflineOnly) {
      parts.add('Offline only');
    }
    
    return parts.isEmpty ? 'No filters' : parts.join(' • ');
  }
}
