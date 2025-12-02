import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'dart:developer' as developer;

class DatabaseService {
  static final DatabaseService _instance = DatabaseService._internal();
  factory DatabaseService() => _instance;
  DatabaseService._internal();

  final FirebaseDatabase _database = FirebaseDatabase.instance;
  
  // Database references
  DatabaseReference get _usersRef => _database.ref().child('users');
  DatabaseReference get _userProfilesRef => _database.ref().child('user_profiles');
  DatabaseReference get _userPreferencesRef => _database.ref().child('user_preferences');
  DatabaseReference get _userProjectsRef => _database.ref().child('user_projects');
  DatabaseReference get _userActivitiesRef => _database.ref().child('user_activities');

  /// Create or update user data in Realtime Database
  Future<void> createUser({
    required String userId,
    required String email,
    String? displayName,
    String? photoUrl,
    String? phoneNumber,
    Map<String, dynamic>? additionalData,
  }) async {
    try {
      print('🔄 Starting user creation in Realtime Database for: $userId');
      developer.log('🔄 Starting user creation in Realtime Database for: $userId');
      
      // Check if user is authenticated
      final currentUser = FirebaseAuth.instance.currentUser;
      if (currentUser == null) {
        throw Exception('No authenticated user found');
      }
      developer.log('✅ Current user authenticated: ${currentUser.uid}');
      
      final timestamp = ServerValue.timestamp;
      
      // Basic user data
      final userData = {
        'uid': userId,
        'email': email,
        'displayName': displayName ?? 'Student',
        'photoUrl': photoUrl,
        'phoneNumber': phoneNumber,
        'createdAt': timestamp,
        'updatedAt': timestamp,
        'isActive': true,
        'lastLoginAt': timestamp,
        'emailVerified': FirebaseAuth.instance.currentUser?.emailVerified ?? false,
        ...?additionalData,
      };

      print('📝 User data to store: $userData');

      // Store in users collection
      await _usersRef.child(userId).set(userData);
      print('✅ User data stored in /users/$userId');

      // Create user profile with extended information
      final profileData = {
        'userId': userId,
        'displayName': displayName ?? 'Student',
        'email': email,
        'photoUrl': photoUrl,
        'bio': '',
        'institution': '',
        'course': '',
        'year': '',
        'skills': [],
        'interests': [],
        'socialLinks': {},
        'createdAt': timestamp,
        'updatedAt': timestamp,
      };

      await _userProfilesRef.child(userId).set(profileData);
      print('✅ Profile data stored in /user_profiles/$userId');

      // Initialize user preferences
      final preferencesData = {
        'userId': userId,
        'theme': 'system',
        'notifications': {
          'email': true,
          'push': true,
          'projectUpdates': true,
          'newProjects': true,
        },
        'privacy': {
          'profileVisible': true,
          'emailVisible': false,
          'phoneVisible': false,
        },
        'language': 'en',
        'createdAt': timestamp,
        'updatedAt': timestamp,
      };

      await _userPreferencesRef.child(userId).set(preferencesData);
      print('✅ Preferences data stored in /user_preferences/$userId');

      // Initialize user projects collection
      await _userProjectsRef.child(userId).set({
        'savedProjects': {},
        'favoriteProjects': {},
        'viewedProjects': {},
        'createdAt': timestamp,
        'updatedAt': timestamp,
      });
      print('✅ Projects data stored in /user_projects/$userId');

      // Initialize user activities
      await _userActivitiesRef.child(userId).set({
        'loginHistory': {
          DateTime.now().millisecondsSinceEpoch.toString(): {
            'timestamp': timestamp,
            'action': 'account_created',
            'details': 'User account created successfully',
          }
        },
        'projectActivities': {},
        'searchHistory': {},
        'createdAt': timestamp,
        'updatedAt': timestamp,
      });
      print('✅ Activities data stored in /user_activities/$userId');

      print('🎉 User data successfully stored in Realtime Database: $userId');
    } catch (e) {
      print('Error creating user in database: $e');
      throw Exception('Failed to create user data: $e');
    }
  }

  /// Get user data from Realtime Database
  Future<Map<String, dynamic>?> getUser(String userId) async {
    try {
      final snapshot = await _usersRef.child(userId).get();
      if (snapshot.exists) {
        return Map<String, dynamic>.from(snapshot.value as Map);
      }
      return null;
    } catch (e) {
      print('Error getting user data: $e');
      return null;
    }
  }

  /// Get user profile data
  Future<Map<String, dynamic>?> getUserProfile(String userId) async {
    try {
      final snapshot = await _userProfilesRef.child(userId).get();
      if (snapshot.exists) {
        return Map<String, dynamic>.from(snapshot.value as Map);
      }
      return null;
    } catch (e) {
      print('Error getting user profile: $e');
      return null;
    }
  }

  /// Update user profile
  Future<void> updateUserProfile(String userId, Map<String, dynamic> updates) async {
    try {
      updates['updatedAt'] = ServerValue.timestamp;
      await _userProfilesRef.child(userId).update(updates);
      
      // Also update basic info in users collection
      final basicUpdates = <String, dynamic>{};
      if (updates.containsKey('displayName')) {
        basicUpdates['displayName'] = updates['displayName'];
      }
      if (updates.containsKey('photoUrl')) {
        basicUpdates['photoUrl'] = updates['photoUrl'];
      }
      if (basicUpdates.isNotEmpty) {
        basicUpdates['updatedAt'] = ServerValue.timestamp;
        await _usersRef.child(userId).update(basicUpdates);
      }
      
      print('User profile updated successfully: $userId');
    } catch (e) {
      print('Error updating user profile: $e');
      throw Exception('Failed to update profile: $e');
    }
  }

  /// Update user preferences
  Future<void> updateUserPreferences(String userId, Map<String, dynamic> preferences) async {
    try {
      preferences['updatedAt'] = ServerValue.timestamp;
      await _userPreferencesRef.child(userId).update(preferences);
      print('User preferences updated successfully: $userId');
    } catch (e) {
      print('Error updating user preferences: $e');
      throw Exception('Failed to update preferences: $e');
    }
  }

  /// Record user login activity
  Future<void> recordLoginActivity(String userId) async {
    try {
      final timestamp = ServerValue.timestamp;
      final loginKey = DateTime.now().millisecondsSinceEpoch.toString();
      
      await _userActivitiesRef.child(userId).child('loginHistory').child(loginKey).set({
        'timestamp': timestamp,
        'action': 'login',
        'details': 'User logged in',
      });

      // Update last login in users collection
      await _usersRef.child(userId).update({
        'lastLoginAt': timestamp,
        'updatedAt': timestamp,
      });
      
      print('Login activity recorded for user: $userId');
    } catch (e) {
      print('Error recording login activity: $e');
    }
  }

  /// Save project to user's saved projects
  Future<void> saveProject(String userId, String projectId, Map<String, dynamic> projectData) async {
    try {
      final timestamp = ServerValue.timestamp;
      await _userProjectsRef.child(userId).child('savedProjects').child(projectId).set({
        ...projectData,
        'savedAt': timestamp,
      });

      // Record activity
      await _userActivitiesRef.child(userId).child('projectActivities').child(projectId).set({
        'action': 'saved',
        'timestamp': timestamp,
        'projectTitle': projectData['title'] ?? 'Unknown Project',
      });
      
      print('Project saved for user: $userId');
    } catch (e) {
      print('Error saving project: $e');
      throw Exception('Failed to save project: $e');
    }
  }

  /// Add project to favorites
  Future<void> favoriteProject(String userId, String projectId, Map<String, dynamic> projectData) async {
    try {
      final timestamp = ServerValue.timestamp;
      await _userProjectsRef.child(userId).child('favoriteProjects').child(projectId).set({
        ...projectData,
        'favoritedAt': timestamp,
      });

      // Record activity
      await _userActivitiesRef.child(userId).child('projectActivities').child(projectId).set({
        'action': 'favorited',
        'timestamp': timestamp,
        'projectTitle': projectData['title'] ?? 'Unknown Project',
      });
      
      print('Project favorited for user: $userId');
    } catch (e) {
      print('Error favoriting project: $e');
      throw Exception('Failed to favorite project: $e');
    }
  }

  /// Record project view
  Future<void> recordProjectView(String userId, String projectId, Map<String, dynamic> projectData) async {
    try {
      final timestamp = ServerValue.timestamp;
      await _userProjectsRef.child(userId).child('viewedProjects').child(projectId).set({
        'title': projectData['title'] ?? 'Unknown Project',
        'category': projectData['category'] ?? 'General',
        'viewedAt': timestamp,
        'viewCount': ServerValue.increment(1),
      });
      
      print('Project view recorded for user: $userId');
    } catch (e) {
      print('Error recording project view: $e');
    }
  }

  /// Get user's saved projects
  Future<Map<String, dynamic>?> getUserSavedProjects(String userId) async {
    try {
      final snapshot = await _userProjectsRef.child(userId).child('savedProjects').get();
      if (snapshot.exists) {
        return Map<String, dynamic>.from(snapshot.value as Map);
      }
      return {};
    } catch (e) {
      print('Error getting saved projects: $e');
      return null;
    }
  }

  /// Get user's favorite projects
  Future<Map<String, dynamic>?> getUserFavoriteProjects(String userId) async {
    try {
      final snapshot = await _userProjectsRef.child(userId).child('favoriteProjects').get();
      if (snapshot.exists) {
        return Map<String, dynamic>.from(snapshot.value as Map);
      }
      return {};
    } catch (e) {
      print('Error getting favorite projects: $e');
      return null;
    }
  }

  /// Delete user data (for account deletion)
  Future<void> deleteUserData(String userId) async {
    try {
      // Delete from all collections
      await Future.wait([
        _usersRef.child(userId).remove(),
        _userProfilesRef.child(userId).remove(),
        _userPreferencesRef.child(userId).remove(),
        _userProjectsRef.child(userId).remove(),
        _userActivitiesRef.child(userId).remove(),
      ]);
      
      print('User data deleted successfully: $userId');
    } catch (e) {
      print('Error deleting user data: $e');
      throw Exception('Failed to delete user data: $e');
    }
  }

  /// Check if user exists in database
  Future<bool> userExists(String userId) async {
    try {
      final snapshot = await _usersRef.child(userId).get();
      return snapshot.exists;
    } catch (e) {
      print('Error checking user existence: $e');
      return false;
    }
  }

  /// Get user statistics
  Future<Map<String, dynamic>?> getUserStats(String userId) async {
    try {
      final futures = await Future.wait([
        _userProjectsRef.child(userId).child('savedProjects').get(),
        _userProjectsRef.child(userId).child('favoriteProjects').get(),
        _userProjectsRef.child(userId).child('viewedProjects').get(),
        _userActivitiesRef.child(userId).child('loginHistory').get(),
      ]);

      final savedProjects = futures[0].exists ? (futures[0].value as Map).length : 0;
      final favoriteProjects = futures[1].exists ? (futures[1].value as Map).length : 0;
      final viewedProjects = futures[2].exists ? (futures[2].value as Map).length : 0;
      final loginCount = futures[3].exists ? (futures[3].value as Map).length : 0;

      return {
        'savedProjectsCount': savedProjects,
        'favoriteProjectsCount': favoriteProjects,
        'viewedProjectsCount': viewedProjects,
        'loginCount': loginCount,
        'lastUpdated': ServerValue.timestamp,
      };
    } catch (e) {
      print('Error getting user stats: $e');
      return null;
    }
  }

  /// Listen to user data changes
  Stream<Map<String, dynamic>?> listenToUser(String userId) {
    return _usersRef.child(userId).onValue.map((event) {
      if (event.snapshot.exists) {
        return Map<String, dynamic>.from(event.snapshot.value as Map);
      }
      return null;
    });
  }

  /// Listen to user profile changes
  Stream<Map<String, dynamic>?> listenToUserProfile(String userId) {
    return _userProfilesRef.child(userId).onValue.map((event) {
      if (event.snapshot.exists) {
        return Map<String, dynamic>.from(event.snapshot.value as Map);
      }
      return null;
    });
  }
}
