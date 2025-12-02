import 'package:flutter/foundation.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../services/feedback_service.dart';
import '../models/feedback_model.dart';
import 'notification_provider.dart';

class FeedbackProvider with ChangeNotifier {
  final FeedbackService _feedbackService = FeedbackService();

  List<FeedbackModel> _feedbacks = [];
  FeedbackStats _stats = FeedbackStats.empty();
  bool _isLoading = false;
  String _error = '';
  String _selectedCategory = 'all';
  String _searchQuery = '';

  // Getters
  List<FeedbackModel> get feedbacks => _feedbacks;
  FeedbackStats get stats => _stats;
  bool get isLoading => _isLoading;
  String get error => _error;
  String get selectedCategory => _selectedCategory;
  String get searchQuery => _searchQuery;

  // Filtered feedbacks based on category and search
  List<FeedbackModel> get filteredFeedbacks {
    var filtered = _feedbacks;

    // Filter by category
    if (_selectedCategory != 'all') {
      filtered = filtered.where((feedback) => feedback.category == _selectedCategory).toList();
    }

    // Filter by search query
    if (_searchQuery.isNotEmpty) {
      final query = _searchQuery.toLowerCase();
      filtered = filtered.where((feedback) {
        return feedback.feedback.toLowerCase().contains(query) ||
               feedback.userName.toLowerCase().contains(query) ||
               feedback.tags.any((tag) => tag.toLowerCase().contains(query));
      }).toList();
    }

    return filtered;
  }

  /// Load project feedbacks
  Future<void> loadProjectFeedbacks(String projectId) async {
    _setLoading(true);
    _setError('');

    try {
      debugPrint('🔄 FeedbackProvider: Loading feedbacks for project $projectId');
      
      // Load feedbacks with timeout
      final feedbacks = await _feedbackService.getProjectFeedbacks(projectId)
          .timeout(
            const Duration(seconds: 15),
            onTimeout: () {
              debugPrint('⏰ FeedbackProvider: Timeout loading feedbacks');
              return <FeedbackModel>[];
            },
          );
      
      final stats = await _feedbackService.getProjectFeedbackStats(projectId)
          .timeout(
            const Duration(seconds: 10),
            onTimeout: () {
              debugPrint('⏰ FeedbackProvider: Timeout loading stats');
              return FeedbackStats.empty();
            },
          );
      
      _feedbacks = feedbacks;
      _stats = stats;
      
      debugPrint('✅ FeedbackProvider: Loaded ${feedbacks.length} feedbacks for project $projectId');
      debugPrint('📊 FeedbackProvider: Stats - Total: ${stats.totalFeedbacks}, Average: ${stats.averageRating}');
    } catch (e) {
      debugPrint('❌ FeedbackProvider: Error loading feedbacks: $e');
      
      // For any errors, just use empty state without showing error to user
      _feedbacks = [];
      _stats = FeedbackStats.empty();
    } finally {
      _setLoading(false);
    }
  }

  /// Submit new feedback
  Future<bool> submitFeedback(FeedbackModel feedback) async {
    _setLoading(true);
    _setError('');

    try {
      final success = await _feedbackService.submitFeedback(feedback);
      
      if (success) {
        // Add to local list and refresh stats
        _feedbacks.insert(0, feedback);
        _stats = FeedbackStats.fromFeedbacks(_feedbacks);
        notifyListeners();
        
        debugPrint('✅ Feedback submitted successfully');
        return true;
      } else {
        _setError('Failed to submit feedback');
        return false;
      }
    } catch (e) {
      _setError('Error submitting feedback: $e');
      debugPrint('❌ Error submitting feedback: $e');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  /// Update existing feedback
  Future<bool> updateFeedback(FeedbackModel feedback) async {
    _setLoading(true);
    _setError('');

    try {
      final success = await _feedbackService.updateFeedback(feedback);
      
      if (success) {
        // Update local list
        final index = _feedbacks.indexWhere((f) => f.id == feedback.id);
        if (index != -1) {
          _feedbacks[index] = feedback;
          _stats = FeedbackStats.fromFeedbacks(_feedbacks);
          notifyListeners();
        }
        
        debugPrint('✅ Feedback updated successfully');
        return true;
      } else {
        _setError('Failed to update feedback');
        return false;
      }
    } catch (e) {
      _setError('Error updating feedback: $e');
      debugPrint('❌ Error updating feedback: $e');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  /// Delete feedback
  Future<bool> deleteFeedback(String projectId, String feedbackId, String userId) async {
    _setLoading(true);
    _setError('');

    try {
      final success = await _feedbackService.deleteFeedback(projectId, feedbackId, userId);
      
      if (success) {
        // Remove from local list
        _feedbacks.removeWhere((feedback) => feedback.id == feedbackId);
        _stats = FeedbackStats.fromFeedbacks(_feedbacks);
        notifyListeners();
        
        debugPrint('✅ Feedback deleted successfully');
        return true;
      } else {
        _setError('Failed to delete feedback');
        return false;
      }
    } catch (e) {
      _setError('Error deleting feedback: $e');
      debugPrint('❌ Error deleting feedback: $e');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  /// Mark feedback as helpful
  Future<bool> markFeedbackHelpful(String projectId, String feedbackId, String userId) async {
    try {
      final success = await _feedbackService.markFeedbackHelpful(projectId, feedbackId, userId);
      
      if (success) {
        // Update local feedback
        final index = _feedbacks.indexWhere((f) => f.id == feedbackId);
        if (index != -1) {
          final feedback = _feedbacks[index];
          final helpfulUsers = List<String>.from(feedback.helpfulUsers);
          
          if (helpfulUsers.contains(userId)) {
            helpfulUsers.remove(userId);
          } else {
            helpfulUsers.add(userId);
          }
          
          _feedbacks[index] = feedback.copyWith(
            helpfulUsers: helpfulUsers,
            helpfulCount: helpfulUsers.length,
          );
          
          notifyListeners();
        }
        
        return true;
      }
      return false;
    } catch (e) {
      debugPrint('❌ Error marking feedback helpful: $e');
      return false;
    }
  }

  /// Set category filter
  void setCategory(String category) {
    if (_selectedCategory != category) {
      _selectedCategory = category;
      notifyListeners();
    }
  }

  /// Set search query
  void setSearchQuery(String query) {
    if (_searchQuery != query) {
      _searchQuery = query;
      notifyListeners();
    }
  }

  /// Clear filters
  void clearFilters() {
    _selectedCategory = 'all';
    _searchQuery = '';
    notifyListeners();
  }

  /// Get user's feedback for current project
  FeedbackModel? getUserFeedback(String userId) {
    try {
      return _feedbacks.where((feedback) => feedback.userId == userId).firstOrNull;
    } catch (e) {
      return null;
    }
  }

  /// Check if user has already given feedback
  bool hasUserGivenFeedback(String userId) {
    return _feedbacks.any((feedback) => feedback.userId == userId);
  }

  /// Get feedbacks by rating
  List<FeedbackModel> getFeedbacksByRating(int rating) {
    return _feedbacks.where((feedback) => feedback.rating.round() == rating).toList();
  }

  /// Get top rated feedbacks
  List<FeedbackModel> getTopRatedFeedbacks({int limit = 5}) {
    final sortedFeedbacks = List<FeedbackModel>.from(_feedbacks);
    sortedFeedbacks.sort((a, b) => b.rating.compareTo(a.rating));
    return sortedFeedbacks.take(limit).toList();
  }

  /// Get most helpful feedbacks
  List<FeedbackModel> getMostHelpfulFeedbacks({int limit = 5}) {
    final sortedFeedbacks = List<FeedbackModel>.from(_feedbacks);
    sortedFeedbacks.sort((a, b) => b.helpfulCount.compareTo(a.helpfulCount));
    return sortedFeedbacks.take(limit).toList();
  }

  /// Refresh feedbacks
  Future<void> refreshFeedbacks(String projectId) async {
    await loadProjectFeedbacks(projectId);
  }

  // Private helper methods
  void _setLoading(bool loading) {
    if (_isLoading != loading) {
      _isLoading = loading;
      notifyListeners();
    }
  }

  void _setError(String error) {
    if (_error != error) {
      _error = error;
      notifyListeners();
    }
  }

  /// Add reply to feedback
  Future<bool> addReplyToFeedback(String projectId, String feedbackId, String reply, String userId, String userName, {NotificationProvider? notificationProvider}) async {
    try {
      final replyId = DateTime.now().millisecondsSinceEpoch.toString();
      final success = await _feedbackService.addReplyToFeedback(
        projectId, 
        feedbackId, 
        replyId,
        reply, 
        userId, 
        userName,
        notificationProvider: notificationProvider,
      );
      
      if (success) {
        // Refresh feedbacks to get updated data with replies
        await loadProjectFeedbacks(projectId);
        return true;
      }
      return false;
    } catch (e) {
      debugPrint('❌ Error adding reply to feedback: $e');
      return false;
    }
  }

  /// Edit reply to feedback
  Future<bool> editReply(String projectId, String feedbackId, String replyId, String newReply) async {
    try {
      final currentUser = FirebaseAuth.instance.currentUser;
      if (currentUser == null) {
        throw Exception('User not authenticated');
      }

      final success = await _feedbackService.editReply(
        projectId, 
        feedbackId, 
        replyId, 
        newReply, 
        currentUser.uid,
      );
      
      if (success) {
        // Refresh feedbacks to get updated data with replies
        await loadProjectFeedbacks(projectId);
        return true;
      }
      return false;
    } catch (e) {
      debugPrint('❌ Error editing reply: $e');
      return false;
    }
  }

  /// Delete a reply from feedback
  Future<void> deleteReply(String projectId, String feedbackId, String replyId) async {
    try {
      final currentUser = FirebaseAuth.instance.currentUser;
      if (currentUser == null) {
        throw Exception('User not authenticated');
      }

      final success = await _feedbackService.deleteReply(
        projectId,
        feedbackId,
        replyId,
        currentUser.uid,
      );

      if (success) {
        // Refresh feedback list to reflect the changes
        await loadProjectFeedbacks(projectId);
      } else {
        // Instead of throwing, provide a more specific error message
        throw Exception('Unable to delete reply. This could be due to insufficient permissions or the reply may have already been deleted.');
      }
    } catch (e) {
      debugPrint('❌ Error in deleteReply: $e');
      
      // Provide user-friendly error messages
      if (e.toString().contains('permission')) {
        throw Exception('You don\'t have permission to delete this reply.');
      } else if (e.toString().contains('timeout')) {
        throw Exception('Request timed out. Please check your internet connection and try again.');
      } else if (e.toString().contains('not authenticated')) {
        throw Exception('Please log in to delete replies.');
      } else {
        throw Exception('Failed to delete reply. Please try again later.');
      }
    }
  }

  /// Clear all data
  void clear() {
    _feedbacks.clear();
    _stats = FeedbackStats.empty();
    _selectedCategory = 'all';
    _searchQuery = '';
    _error = '';
    _isLoading = false;
    notifyListeners();
  }
}
