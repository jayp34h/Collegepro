import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart' hide Badge;
import '../models/doubt_model.dart';
import '../models/answer_model.dart';
import '../models/badge_model.dart';
import '../services/community_doubts_service.dart';
import '../services/gamification_service.dart';
import '../../../core/providers/auth_provider.dart';
import '../../../core/providers/notification_provider.dart';
import '../../../core/providers/user_progress_provider.dart';

class CommunityDoubtsProvider with ChangeNotifier {
  final AuthProvider? _authProvider;
  final NotificationProvider? _notificationProvider;
  UserProgressProvider? _progressProvider;
  
  // State variables
  List<CommunityDoubt> _doubts = [];
  List<DoubtAnswer> _currentAnswers = [];
  CommunityDoubt? _currentDoubt;
  UserProgress? _userProgress;
  List<Badge> _userBadges = [];
  List<UserProgress> _leaderboard = [];
  
  // Loading states
  bool _isLoading = false;
  bool _isLoadingAnswers = false;
  bool _isPostingDoubt = false;
  bool _isPostingAnswer = false;
  bool _isVoting = false;
  
  // Error handling
  String? _error;
  
  // Filters
  String _searchQuery = '';
  String? _selectedSubject;
  String? _selectedDifficulty;
  bool? _showResolved;
  
  // Pagination
  String? _lastKey;
  bool _hasMore = true;
  
  // Getters
  List<CommunityDoubt> get doubts => _doubts;
  List<DoubtAnswer> get currentAnswers => _currentAnswers;
  CommunityDoubt? get currentDoubt => _currentDoubt;
  UserProgress? get userProgress => _userProgress;
  List<Badge> get userBadges => _userBadges;
  List<UserProgress> get leaderboard => _leaderboard;
  
  bool get isLoading => _isLoading;
  bool get isLoadingAnswers => _isLoadingAnswers;
  bool get isPostingDoubt => _isPostingDoubt;
  bool get isPostingAnswer => _isPostingAnswer;
  bool get isVoting => _isVoting;
  
  String? get error => _error;
  String get searchQuery => _searchQuery;
  String? get selectedSubject => _selectedSubject;
  String? get selectedDifficulty => _selectedDifficulty;
  bool? get showResolved => _showResolved;
  bool get hasMore => _hasMore;

  CommunityDoubtsProvider(this._authProvider, [this._notificationProvider]);
  
  // Set progress provider for activity tracking
  void setProgressProvider(UserProgressProvider progressProvider) {
    _progressProvider = progressProvider;
  }

  // Initialize provider
  Future<void> initialize() async {
    try {
      await loadDoubts();
    } catch (e) {
      print('CommunityDoubtsProvider initialization failed: $e');
      _error = 'Failed to initialize community doubts. Please try again.';
      notifyListeners();
    }
  }

  // Load doubts with filters
  Future<void> loadDoubts({bool refresh = false}) async {
    if (_isLoading && !refresh) return;
    
    try {
      _isLoading = true;
      _error = null;
      if (refresh) {
        _doubts.clear();
        _lastKey = null;
        _hasMore = true;
      }
      notifyListeners();

      List<CommunityDoubt> newDoubts;
      
      if (_searchQuery.isNotEmpty) {
        newDoubts = await CommunityDoubtsService.searchDoubts(_searchQuery);
      } else {
        newDoubts = await CommunityDoubtsService.getDoubts(
          limit: 20,
          lastKey: _lastKey,
          subject: _selectedSubject,
          difficulty: _selectedDifficulty,
          isResolved: _showResolved,
        );
      }

      if (refresh) {
        _doubts = newDoubts;
      } else {
        _doubts.addAll(newDoubts);
      }
      
      _hasMore = newDoubts.length == 20;
      if (newDoubts.isNotEmpty) {
        _lastKey = newDoubts.last.id;
      }

    } catch (e) {
      _error = 'Failed to load doubts: $e';
      print('Error loading doubts: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }


  // Post new doubt
  Future<bool> postDoubt(CommunityDoubt doubt) async {
    try {
      _isPostingDoubt = true;
      _error = null;
      notifyListeners();

      final doubtId = await CommunityDoubtsService.postDoubt(doubt);
      
      // Award points for asking question
      final userName = _authProvider?.userModel?.displayName ?? _authProvider?.user?.displayName;
      await GamificationService.awardPoints(
        doubt.userId, 
        GamificationService.POINTS_ASK_QUESTION, 
        'question_asked',
        subject: doubt.subject,
        userName: userName,
      );
      
      // Refresh user progress
      loadUserProgress(doubt.userId);
      
      // Add to local list
      final newDoubt = doubt.copyWith(id: doubtId);
      _doubts.insert(0, newDoubt);
      
      return true;
    } catch (e) {
      _error = 'Failed to post doubt: $e';
      print('Error posting doubt: $e');
      return false;
    } finally {
      _isPostingDoubt = false;
      notifyListeners();
    }
  }

  // Load doubt details
  Future<void> loadDoubtDetails(String doubtId) async {
    try {
      _isLoadingAnswers = true;
      _error = null;
      notifyListeners();

      // Load doubt
      final doubt = await CommunityDoubtsService.getDoubtById(doubtId);
      if (doubt != null) {
        _currentDoubt = doubt;
        
        // Increment view count
        await CommunityDoubtsService.incrementViewCount(doubtId);
        
        // Load answers
        _currentAnswers = await CommunityDoubtsService.getAnswersForDoubt(doubtId);
      }

    } catch (e) {
      _error = 'Failed to load doubt details: $e';
      print('Error loading doubt details: $e');
    } finally {
      _isLoadingAnswers = false;
      notifyListeners();
    }
  }

  // Post answer
  Future<bool> postAnswer(DoubtAnswer answer) async {
    try {
      _isPostingAnswer = true;
      _error = null;
      notifyListeners();

      // Check for similar answers
      final similarAnswers = await CommunityDoubtsService.checkSimilarAnswers(
        answer.doubtId, 
        answer.content,
      );
      
      if (similarAnswers.isNotEmpty) {
        _error = 'Similar answers already exist. Please check existing answers before posting.';
        return false;
      }

      final answerId = await CommunityDoubtsService.postAnswer(answer, notificationProvider: _notificationProvider);
      
      // Track answer activity using UserProgressProvider for consistency
      final currentUser = _authProvider?.user;
      if (_progressProvider != null && currentUser != null) {
        try {
          await _progressProvider!.trackActivity(currentUser.uid, 'answer_given');
          debugPrint('✅ Tracked answer given activity for user: ${currentUser.uid}');
        } catch (e) {
          debugPrint('❌ Failed to track answer given activity: $e');
        }
      }
      
      // Award points for giving answer (keep existing gamification)
      final userName = _authProvider?.userModel?.displayName ?? _authProvider?.user?.displayName;
      await GamificationService.awardPoints(
        answer.userId, 
        GamificationService.POINTS_ANSWER_QUESTION, 
        'answer_given',
        subject: _currentDoubt?.subject,
        userName: userName,
      );
      
      // Refresh user progress
      loadUserProgress(answer.userId);
      
      // Add to local list
      final newAnswer = answer.copyWith(id: answerId);
      _currentAnswers.add(newAnswer);
      
      // Update doubt's answer count
      if (_currentDoubt != null) {
        _currentDoubt = _currentDoubt!.copyWith(
          answersCount: _currentDoubt!.answersCount + 1,
        );
      }
      
      return true;
    } catch (e) {
      _error = 'Failed to post answer: $e';
      print('Error posting answer: $e');
      return false;
    } finally {
      _isPostingAnswer = false;
      notifyListeners();
    }
  }

  // Vote on doubt
  Future<void> voteOnDoubt(String doubtId, String userId, bool isUpvote) async {
    if (_isVoting) return;
    
    try {
      _isVoting = true;
      notifyListeners();

      await CommunityDoubtsService.voteOnDoubt(doubtId, userId, isUpvote);
      
      // Update local doubt
      final doubtIndex = _doubts.indexWhere((d) => d.id == doubtId);
      if (doubtIndex != -1) {
        final doubt = _doubts[doubtIndex];
        List<String> upvotedBy = List.from(doubt.upvotedBy);
        List<String> downvotedBy = List.from(doubt.downvotedBy);
        
        if (isUpvote) {
          downvotedBy.remove(userId);
          if (upvotedBy.contains(userId)) {
            upvotedBy.remove(userId);
          } else {
            upvotedBy.add(userId);
          }
        } else {
          upvotedBy.remove(userId);
          if (downvotedBy.contains(userId)) {
            downvotedBy.remove(userId);
          } else {
            downvotedBy.add(userId);
          }
        }
        
        _doubts[doubtIndex] = doubt.copyWith(
          upvotes: upvotedBy.length,
          downvotes: downvotedBy.length,
          upvotedBy: upvotedBy,
          downvotedBy: downvotedBy,
        );
      }
      
      // Update current doubt if it's the same
      if (_currentDoubt?.id == doubtId) {
        _currentDoubt = _doubts[doubtIndex];
      }

    } catch (e) {
      _error = 'Failed to vote: $e';
      print('Error voting on doubt: $e');
    } finally {
      _isVoting = false;
      notifyListeners();
    }
  }

  // Vote on answer
  Future<void> voteOnAnswer(String answerId, String userId, bool isUpvote) async {
    if (_isVoting) return;
    
    try {
      _isVoting = true;
      notifyListeners();

      await CommunityDoubtsService.voteOnAnswer(answerId, userId, isUpvote);
      
      // Update local answer
      final answerIndex = _currentAnswers.indexWhere((a) => a.id == answerId);
      if (answerIndex != -1) {
        final answer = _currentAnswers[answerIndex];
        List<String> upvotedBy = List.from(answer.upvotedBy);
        List<String> downvotedBy = List.from(answer.downvotedBy);
        
        if (isUpvote) {
          downvotedBy.remove(userId);
          if (upvotedBy.contains(userId)) {
            upvotedBy.remove(userId);
          } else {
            upvotedBy.add(userId);
            
            // Track upvote received activity
            if (_progressProvider != null) {
              try {
                await _progressProvider!.trackActivity(answer.userId, 'upvote_received');
                debugPrint('✅ Tracked upvote received activity for user: ${answer.userId}');
              } catch (e) {
                debugPrint('❌ Failed to track upvote received activity: $e');
              }
            }
            
            // Award points for upvote received (keep existing gamification)
            final userName = _authProvider?.userModel?.displayName ?? _authProvider?.user?.displayName;
            await GamificationService.awardPoints(
              answer.userId, 
              GamificationService.POINTS_UPVOTE_RECEIVED, 
              'upvote_received',
              userName: userName,
            );
          }
        } else {
          upvotedBy.remove(userId);
          if (downvotedBy.contains(userId)) {
            downvotedBy.remove(userId);
          } else {
            downvotedBy.add(userId);
          }
        }
        
        _currentAnswers[answerIndex] = answer.copyWith(
          upvotes: upvotedBy.length,
          downvotes: downvotedBy.length,
          upvotedBy: upvotedBy,
          downvotedBy: downvotedBy,
        );
      }

    } catch (e) {
      _error = 'Failed to vote: $e';
      print('Error voting on answer: $e');
    } finally {
      _isVoting = false;
      notifyListeners();
    }
  }

  // Mark answer as best
  Future<void> markAsBestAnswer(String doubtId, String answerId, String doubtOwnerId, String currentUserId) async {
    try {
      await CommunityDoubtsService.markAsBestAnswer(doubtId, answerId, doubtOwnerId, currentUserId);
      
      // Find the answer and track best answer activity
      final answer = _currentAnswers.firstWhere((a) => a.id == answerId);
      
      // Track best answer activity
      if (_progressProvider != null) {
        try {
          await _progressProvider!.trackActivity(answer.userId, 'best_answer');
          debugPrint('✅ Tracked best answer activity for user: ${answer.userId}');
        } catch (e) {
          debugPrint('❌ Failed to track best answer activity: $e');
        }
      }
      
      // Award points for best answer (keep existing gamification)
      final userName = _authProvider?.userModel?.displayName ?? _authProvider?.user?.displayName;
      await GamificationService.awardPoints(
        answer.userId, 
        GamificationService.POINTS_BEST_ANSWER, 
        'best_answer',
        subject: _currentDoubt?.subject,
        userName: userName,
      );
      
      // Update local data
      final answerIndex = _currentAnswers.indexWhere((a) => a.id == answerId);
      if (answerIndex != -1) {
        _currentAnswers[answerIndex] = _currentAnswers[answerIndex].copyWith(isBestAnswer: true);
      }
      
      if (_currentDoubt != null) {
        _currentDoubt = _currentDoubt!.copyWith(
          isResolved: true,
          bestAnswerId: answerId,
        );
      }
      
    } catch (e) {
      _error = 'Failed to mark best answer: $e';
      print('Error marking best answer: $e');
    } finally {
      notifyListeners();
    }
  }

  // Report content
  Future<void> reportContent(String contentId, String contentType, String userId, String reason) async {
    try {
      await CommunityDoubtsService.reportContent(contentId, contentType, userId, reason);
      
      // Update local data to show as reported
      if (contentType == 'doubt') {
        final doubtIndex = _doubts.indexWhere((d) => d.id == contentId);
        if (doubtIndex != -1) {
          _doubts[doubtIndex] = _doubts[doubtIndex].copyWith(isReported: true);
        }
        if (_currentDoubt?.id == contentId) {
          _currentDoubt = _currentDoubt!.copyWith(isReported: true);
        }
      } else {
        final answerIndex = _currentAnswers.indexWhere((a) => a.id == contentId);
        if (answerIndex != -1) {
          _currentAnswers[answerIndex] = _currentAnswers[answerIndex].copyWith(isReported: true);
        }
      }
      
    } catch (e) {
      _error = 'Failed to report content: $e';
      print('Error reporting content: $e');
    } finally {
      notifyListeners();
    }
  }

  // Load user progress and badges
  Future<void> loadUserProgress([String? userId]) async {
    final targetUserId = userId ?? _authProvider?.user?.uid;
    if (targetUserId == null) return;
    
    try {
      _isLoading = true;
      notifyListeners();
      
      // Get user name from auth provider
      final userName = _authProvider?.userModel?.displayName ?? _authProvider?.user?.displayName;
      
      _userProgress = await GamificationService.getUserProgress(targetUserId, userName: userName);
      notifyListeners();
    } catch (e) {
      if (kDebugMode) {
        print('❌ Error loading user progress: $e');
      }
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Load user badges
  Future<void> loadUserBadges() async {
    if (_authProvider?.user == null) return;
    
    try {
      _isLoading = true;
      notifyListeners();
      
      _userBadges = await GamificationService.getUserBadges(_authProvider!.user!.uid);
      notifyListeners();
    } catch (e) {
      if (kDebugMode) {
        print('❌ Error loading user badges: $e');
      }
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Load leaderboard
  Future<void> loadLeaderboard() async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();
      
      _leaderboard = await GamificationService.getLeaderboard();
      
      if (kDebugMode) {
        print('✅ Leaderboard loaded: ${_leaderboard.length} users');
      }
    } catch (e) {
      _error = 'Failed to load leaderboard: $e';
      if (kDebugMode) {
        print('❌ Error loading leaderboard: $e');
      }
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Track activity
  Future<void> trackActivity(String userId, String activityType, {Map<String, dynamic>? metadata}) async {
    try {
      await GamificationService.trackActivity(userId, activityType, metadata: metadata);
      loadUserProgress(userId);
    } catch (e) {
      print('Error tracking activity: $e');
    }
  }

  // Clear error
  void clearError() {
    _error = null;
    notifyListeners();
  }

  // Get available subjects for filtering
  List<String> getAvailableSubjects() {
    final subjects = _doubts.map((doubt) => doubt.subject).toSet().toList();
    if (subjects.isEmpty) {
      return [
        'Computer Science',
        'Mathematics',
        'Physics',
        'Chemistry',
        'Biology',
        'Engineering',
        'Data Science',
      ];
    }
    subjects.sort();
    return subjects;
  }

  // Get available difficulties for filtering
  List<String> getAvailableDifficulties() {
    return ['Easy', 'Medium', 'Hard'];
  }

  // Apply filters
  Future<void> applyFilters({
    String? subject,
    String? difficulty,
    bool? showResolved,
  }) async {
    if (_isLoading) return;
    
    try {
      _error = null;
      
      // Validate inputs
      if (subject != null && subject.trim().isEmpty) {
        subject = null;
      }
      if (difficulty != null && difficulty.trim().isEmpty) {
        difficulty = null;
      }
      
      // Check if filters actually changed
      if (_selectedSubject == subject && 
          _selectedDifficulty == difficulty && 
          _showResolved == showResolved) {
        return;
      }
      
      _selectedSubject = subject;
      _selectedDifficulty = difficulty;
      _showResolved = showResolved;
      
      notifyListeners();
      await loadDoubts(refresh: true);
    } catch (e) {
      _error = 'Failed to apply filters: $e';
      print('Error applying filters: $e');
      notifyListeners();
    }
  }

  // Clear filters
  Future<void> clearFilters() async {
    if (_isLoading) return;
    
    try {
      _error = null;
      _selectedSubject = null;
      _selectedDifficulty = null;
      _showResolved = null;
      _searchQuery = '';
      notifyListeners();
      await loadDoubts(refresh: true);
    } catch (e) {
      _error = 'Failed to clear filters: $e';
      print('Error clearing filters: $e');
      notifyListeners();
    }
  }

  // Search doubts
  Future<void> searchDoubts(String query) async {
    if (_isLoading) return;
    
    try {
      _error = null;
      final trimmedQuery = query.trim();
      
      // Check if search query actually changed
      if (_searchQuery == trimmedQuery) {
        return;
      }
      
      _searchQuery = trimmedQuery;
      notifyListeners();
      await loadDoubts(refresh: true);
    } catch (e) {
      _error = 'Failed to search doubts: $e';
      print('Error searching doubts: $e');
      notifyListeners();
    }
  }

  // Get available tags from all doubts
  List<String> getAvailableTags() {
    final allTags = <String>{};
    for (final doubt in _doubts) {
      allTags.addAll(doubt.tags);
    }
    return allTags.toList()..sort();
  }
}
