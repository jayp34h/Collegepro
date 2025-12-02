import 'package:flutter/foundation.dart';
import '../models/doubt_model.dart';
import '../services/doubt_service.dart';

class DoubtProvider with ChangeNotifier {
  final DoubtService _doubtService = DoubtService();
  List<DoubtModel> _doubts = [];
  bool _isLoading = false;
  String? _error;

  List<DoubtModel> get doubts => _doubts;
  bool get isLoading => _isLoading;
  String? get error => _error;

  // Post a new doubt
  Future<bool> postDoubt({
    required String userId,
    required String title,
    required String description,
    required String category,
    required String mentorId,
    required String mentorName,
  }) async {
    _setLoading(true);
    _error = null;

    try {
      final doubt = DoubtModel(
        id: '', // Will be set by Firebase
        userId: userId,
        title: title,
        description: description,
        category: category,
        timestamp: DateTime.now(),
        mentorId: mentorId,
        mentorName: mentorName,
      );

      final doubtId = await _doubtService.postDoubt(doubt);
      
      if (doubtId != null && doubtId.isNotEmpty) {
        // Don't manually add to local list - let the real-time listener handle it
        // This prevents duplicate entries
        _setLoading(false);
        return true;
      } else {
        _error = 'Failed to post doubt. Please try again.';
        _setLoading(false);
        return false;
      }
    } catch (e) {
      _error = e.toString().contains('Permission denied') 
          ? 'Permission denied. Please check Firebase database rules in console.'
          : 'An error occurred while posting your doubt: $e';
      _setLoading(false);
      return false;
    }
  }

  // Load user doubts with real-time updates and timeout protection
  Future<void> loadUserDoubts(String userId) async {
    _setLoading(true);
    _error = null;

    try {
      // Add timeout protection
      final doubts = await _doubtService.getUserDoubts(userId)
          .timeout(const Duration(seconds: 15));
      
      _doubts = doubts;
      _setLoading(false);
      
      // Then set up real-time listener
      _listenToUserDoubts(userId);
    } catch (e) {
      if (e.toString().contains('TimeoutException')) {
        _handleTimeout();
      } else {
        _error = 'Failed to load doubts: $e';
        print('Error loading doubts: $e');
        _setLoading(false);
      }
    }
  }

  // Private method for real-time doubt updates
  void _listenToUserDoubts(String userId) {
    _doubtService.getUserDoubtsStream(userId).listen(
      (doubts) {
        _doubts = doubts;
        // Don't set loading to false here as it's already false from initial load
        notifyListeners();
      },
      onError: (error) {
        _error = 'Error listening to doubts: $error';
        print('Stream error: $error');
        notifyListeners();
      },
    );
  }

  // Separate method to only listen without initial load (for real-time updates)
  void listenToUserDoubts(String userId) {
    _listenToUserDoubts(userId);
  }

  // Update doubt status
  Future<bool> updateDoubtStatus(String doubtId, String status) async {
    try {
      final success = await _doubtService.updateDoubtStatus(doubtId, status);
      
      if (success) {
        // Update local doubt
        final doubtIndex = _doubts.indexWhere((d) => d.id == doubtId);
        if (doubtIndex != -1) {
          _doubts[doubtIndex] = _doubts[doubtIndex].copyWith(status: status);
          notifyListeners();
        }
      }
      
      return success;
    } catch (e) {
      _error = 'Failed to update doubt status: $e';
      notifyListeners();
      return false;
    }
  }

  // Delete a doubt
  Future<bool> deleteDoubt(String doubtId) async {
    try {
      _error = null;
      final success = await _doubtService.deleteDoubt(doubtId);
      
      if (success) {
        _doubts.removeWhere((doubt) => doubt.id == doubtId);
        notifyListeners();
        return true;
      } else {
        _error = 'Failed to delete doubt. Please try again.';
        notifyListeners();
        return false;
      }
    } catch (e) {
      _error = e.toString().contains('Permission denied') 
          ? 'Permission denied. Please check Firebase database rules in console.'
          : 'Failed to delete doubt: $e';
      notifyListeners();
      return false;
    }
  }

  // Clear error
  void clearError() {
    _error = null;
    notifyListeners();
  }

  // Get doubts by category
  List<DoubtModel> getDoubtsByCategory(String category) {
    return _doubts.where((doubt) => doubt.category == category).toList();
  }

  // Get doubts by status
  List<DoubtModel> getDoubtsByStatus(String status) {
    return _doubts.where((doubt) => doubt.status == status).toList();
  }

  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  // Add method to reset provider state
  void reset() {
    _doubts = [];
    _isLoading = false;
    _error = null;
    notifyListeners();
  }

  // Add method to handle timeout scenarios
  void _handleTimeout() {
    _isLoading = false;
    _error = 'Request timed out. Please check your internet connection.';
    notifyListeners();
  }
}
