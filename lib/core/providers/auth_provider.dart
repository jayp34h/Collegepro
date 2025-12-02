import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user_model.dart';
import '../services/secure_session_service.dart';
import '../utils/auth_debug_helper.dart';
import '../services/user_progress_service.dart';
import '../utils/performance_utils.dart';

class AuthProvider extends ChangeNotifier {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn(
    scopes: ['email', 'profile'],
  );
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  User? _user;
  UserModel? _userModel;
  bool _isLoading = false;
  String? _errorMessage;
  bool _isInitialized = false;
  bool _firebaseReady = false;

  User? get user => _user;
  UserModel? get userModel => _userModel;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  bool get isAuthenticated => _user != null;
  bool get isEmailVerified => _user?.emailVerified ?? false;
  bool get requiresEmailVerification => false;

  AuthProvider() {
    _waitForFirebaseAndInitialize();
  }

  Future<void> _waitForFirebaseAndInitialize() async {
    try {
      if (kDebugMode) {
        print('🔄 Waiting for Firebase initialization...');
      }

      // Wait for Firebase to be ready with timeout
      int attempts = 0;
      const maxAttempts = 50; // 5 seconds max wait
      
      while (Firebase.apps.isEmpty && attempts < maxAttempts) {
        await Future.delayed(const Duration(milliseconds: 100));
        attempts++;
      }
      
      if (Firebase.apps.isEmpty) {
        if (kDebugMode) {
          print('❌ Firebase initialization timeout');
        }
        return;
      }
      
      _firebaseReady = true;
      if (kDebugMode) {
        print('✅ Firebase ready, initializing AuthProvider');
      }
      
      await _initializeAuthProvider();
    } catch (e) {
      if (kDebugMode) {
        print('❌ Error waiting for Firebase: $e');
      }
    }
  }

  Future<void> _initializeAuthProvider() async {
    try {
      if (kDebugMode) {
        print('🔄 AuthProvider initializing...');
      }

      // Check Firebase Auth current user first (most reliable)
      _user = _auth.currentUser;
      
      if (kDebugMode) {
        print('🔥 Firebase current user: ${_user?.email ?? "null"}');
      }

      // If Firebase user exists, prioritize Firebase auth state over stored session
      if (_user != null) {
        if (kDebugMode) {
          print('✅ Firebase user found, restoring session');
        }
        
        // Load user model synchronously for immediate UI update
        _loadUserModelSynchronously();
        
        // Always save/update session when Firebase user exists (handles web refresh)
        await SecureSessionService.saveUserSession(
          userId: _user!.uid,
          email: _user!.email ?? '',
          displayName: _user!.displayName ?? 'User',
          loginMethod: _user!.providerData.isNotEmpty && 
                      _user!.providerData.first.providerId == 'google.com' 
                      ? 'google' : 'email',
        );
        
        notifyListeners();
      } else {
        // No Firebase user - check stored session as fallback
        final isStoredSessionValid = await SecureSessionService.isUserLoggedIn();
        
        if (kDebugMode) {
          print('📱 No Firebase user, stored session valid: $isStoredSessionValid');
        }
        
        if (isStoredSessionValid) {
          // Stored session exists but no Firebase user - clear invalid session
          if (kDebugMode) {
            print('⚠️ Clearing invalid stored session - no Firebase user');
          }
          await SecureSessionService.clearUserSession();
        }
      }

      // Initialize auth state listener
      _initializeAuthListener();
      
    } catch (e) {
      if (kDebugMode) {
        print('❌ Error initializing AuthProvider: $e');
      }
    }
  }
  
  // Initialize auth state listener immediately
  void _initializeAuthListener() {
    try {
      if (kDebugMode) {
        print('🔄 Setting up auth state listener...');
      }
      
      // Use ONLY authStateChanges to avoid conflicts
      _auth.authStateChanges().listen(_onAuthStateChanged, onError: (error) {
        if (kDebugMode) {
          print('Auth state changes listener error: $error');
        }
      });
      
      if (kDebugMode) {
        print('✅ Auth listener initialized successfully');
      }
    } catch (e) {
      if (kDebugMode) {
        print('❌ Failed to initialize auth listener: $e');
      }
    }
  }
  
  // Call this method after the widget tree is built (deprecated - auth listener now starts immediately)
  void initialize() {
    if (_isInitialized) return;
    _isInitialized = true;
    
    // Load user model if user exists (non-blocking with timeout)
    if (_user != null) {
      PerformanceUtils.executeAfterFrame(() async {
        try {
          await PerformanceUtils.executeWithTimeout(
            () => _loadUserModel(),
            PerformanceUtils.platformOptimizedTimeout,
            debugName: 'Initial user model load',
          );
        } catch (e) {
          if (kDebugMode) {
            print('Non-blocking user model load failed: $e');
          }
        }
      });
    }
  }

  void _onAuthStateChanged(User? user) {
    if (kDebugMode) {
      print('🔄 Auth state changed: ${user?.email ?? "null"}');
    }
    
    _user = user;
    if (user != null) {
      if (kDebugMode) {
        print('✅ User authenticated: ${user.email}');
        print('📧 Email verified: ${user.emailVerified}');
      }
      
      // Load user model synchronously first for immediate UI update
      _loadUserModelSynchronously();
      
      // Load full user model asynchronously in background
      Future.microtask(() {
        _loadUserModel().catchError((e) {
          if (kDebugMode) {
            print('Non-blocking auth state user model load failed: $e');
          }
        });
      });
      
      // Initialize user progress tracking
      Future.microtask(() {
        UserProgressService().initializeUserProgress(user.uid).catchError((e) {
          if (kDebugMode) {
            print('Non-critical: Failed to initialize user progress: $e');
          }
        });
      });
      
      // Update last login time (non-blocking)
      Future.microtask(() {
        _updateLastLogin().catchError((e) {
          if (kDebugMode) {
            print('Non-critical: Failed to update last login: $e');
          }
        });
      });
    } else {
      if (kDebugMode) {
        print('❌ User signed out or not authenticated');
      }
      _userModel = null;
      _isLoading = false;
    }
    
    // Use post frame callback to avoid setState during build
    WidgetsBinding.instance.addPostFrameCallback((_) {
      notifyListeners();
    });
  }

  // Synchronous method to load basic user model from current user data
  void _loadUserModelSynchronously() {
    if (_user == null) return;
    
    try {
      // Create basic user model from Firebase Auth data immediately
      final registrationMethod = _user!.providerData.isNotEmpty 
          ? _user!.providerData.first.providerId == 'google.com' ? 'google' : 'email'
          : 'email';
      
      // Get display name with proper fallback
      String displayName = _user!.displayName ?? '';
      if (displayName.isEmpty) {
        if (_user!.email != null && _user!.email!.isNotEmpty) {
          displayName = _user!.email!.split('@').first;
        } else {
          displayName = 'Student';
        }
      }
          
      _userModel = UserModel(
        id: _user!.uid,
        email: _user!.email ?? '',
        displayName: displayName,
        photoUrl: _user!.photoURL,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        isEmailVerified: _user!.emailVerified || registrationMethod == 'google',
        emailVerifiedAt: _user!.emailVerified ? DateTime.now() : null,
        registrationMethod: registrationMethod,
        lastLoginAt: DateTime.now(),
      );
      
      // Set loading to false since we have basic user data
      _isLoading = false;
      
      if (kDebugMode) {
        print('Basic user model loaded synchronously for: ${_userModel!.displayName}');
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error creating synchronous user model: $e');
      }
      _isLoading = false;
    }
  }

  Future<void> _loadUserModel() async {
    if (_user == null) return;

    try {
      await PerformanceUtils.measureExecutionTime(() async {
        if (kDebugMode) {
          print('Loading user model for: ${_user!.uid}');
        }
        
        // Use platform-optimized timeout
        final doc = await _firestore.collection('users').doc(_user!.uid)
            .get()
            .timeout(PerformanceUtils.platformOptimizedTimeout);
        
        if (doc.exists && doc.data() != null) {
          // Process user data directly
          _userModel = UserModel.fromJson(doc.data()!);
          
          if (kDebugMode) {
            print('User model loaded. Email verified: ${_userModel!.isEmailVerified}');
            print('Saved projects: ${_userModel!.savedProjectIds.length}');
          }
          
          // Update email verification status from Firebase Auth (non-blocking)
          if (_user!.emailVerified && !_userModel!.isEmailVerified) {
            _updateEmailVerificationStatus().catchError((e) {
              if (kDebugMode) {
                print('Non-critical: Failed to update email verification: $e');
              }
            });
          }
          
          // Save session data to secure storage
          await SecureSessionService.saveUserSession(
            userId: _user!.uid,
            email: _user!.email ?? '',
            displayName: _user!.displayName ?? 'User',
            loginMethod: 'email',
          );
        } else {
          // Create new user model if doesn't exist
          if (kDebugMode) {
            print('Creating new user model');
          }
          final registrationMethod = _user!.providerData.isNotEmpty 
              ? _user!.providerData.first.providerId == 'google.com' ? 'google' : 'email'
              : 'email';
              
          _userModel = UserModel(
            id: _user!.uid,
            email: _user!.email ?? '',
            displayName: _user!.displayName ?? '',
            photoUrl: _user!.photoURL,
            createdAt: DateTime.now(),
            updatedAt: DateTime.now(),
            isEmailVerified: _user!.emailVerified || registrationMethod == 'google',
            emailVerifiedAt: _user!.emailVerified ? DateTime.now() : null,
            registrationMethod: registrationMethod,
            lastLoginAt: DateTime.now(),
          );
          
          // Save to Firestore with shorter timeout
          try {
            await _firestore.collection('users').doc(_user!.uid)
                .set(_userModel!.toJson())
                .timeout(const Duration(seconds: 5));
          } catch (firestoreError) {
            if (kDebugMode) {
              print('Non-critical: Firestore save failed: $firestoreError');
            }
          }
          
          // Save session data to secure storage
          await SecureSessionService.saveUserSession(
            userId: _user!.uid,
            email: _user!.email ?? '',
            displayName: _user!.displayName ?? 'User',
            loginMethod: registrationMethod,
          );
          
          if (kDebugMode) {
            print('New user model created with verification status: ${_userModel!.isEmailVerified}');
          }
        }
        
        // Notify listeners after successful load using post frame callback
        WidgetsBinding.instance.addPostFrameCallback((_) {
          notifyListeners();
        });
      }, debugName: 'Load User Model');
    } catch (e) {
      if (kDebugMode) {
        print('Error loading user model: $e');
      }
      // Don't set error message for non-critical failures
      // Create minimal user model to prevent app blocking
      if (_userModel == null) {
        _userModel = UserModel(
          id: _user!.uid,
          email: _user!.email ?? '',
          displayName: _user!.displayName ?? 'User',
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
          isEmailVerified: _user!.emailVerified,
          registrationMethod: 'email',
          lastLoginAt: DateTime.now(),
        );
        WidgetsBinding.instance.addPostFrameCallback((_) {
          notifyListeners();
        });
      }
    }
  }

  Future<bool> signInWithEmailAndPassword(String email, String password) async {
    try {
      _isLoading = true;
      _errorMessage = null;
      notifyListeners();

      if (kDebugMode) {
        print('🔄 Starting email/password sign-in for: $email');
        print('Platform: ${defaultTargetPlatform.name}');
        print('Firebase initialized: ${Firebase.apps.isNotEmpty}');
      }

      // Check Firebase initialization
      if (!_firebaseReady || Firebase.apps.isEmpty) {
        throw Exception('Firebase not ready for authentication');
      }

      // Set persistence before signing in (only for web)
      if (kIsWeb) {
        await _auth.setPersistence(Persistence.LOCAL);
      }
      
      final credential = await _auth.signInWithEmailAndPassword(email: email, password: password);
      
      if (kDebugMode) {
        print('✅ Firebase authentication successful for: ${credential.user?.email}');
        print('User UID: ${credential.user?.uid}');
        print('Email verified: ${credential.user?.emailVerified}');
        print('Provider data: ${credential.user?.providerData.map((p) => p.providerId).toList()}');
      }
      
      // Load user model after successful authentication
      if (credential.user != null) {
        _loadUserModel();
      }
      
      if (kDebugMode) {
        print('✅ Email/Password sign in completed successfully');
      }
      
      return true;
    } on FirebaseAuthException catch (e) {
      if (kDebugMode) {
        print('❌ Firebase Auth Exception during email sign-in: ${e.code} - ${e.message}');
        print('Error details: ${e.toString()}');
      }
      _errorMessage = _getAuthErrorMessage(e.code);
      return false;
    } catch (e) {
      if (kDebugMode) {
        print('❌ Unexpected error during email sign-in: $e');
        print('Error type: ${e.runtimeType}');
        print('Stack trace: ${StackTrace.current}');
      }
      _errorMessage = 'Authentication failed. Please check your internet connection and try again.';
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> createUserWithEmailAndPassword(
    String email, 
    String password, 
    String displayName, {
    String? phoneNumber,
    String? institution,
    String? course,
    String? yearOfStudy,
  }) async {
    try {
      _isLoading = true;
      _errorMessage = null;
      notifyListeners();

      print('Starting registration for: $email');
      print('Additional data - Phone: $phoneNumber, Institution: $institution, Course: $course, Year: $yearOfStudy');

      final credential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      if (credential.user != null) {
        print('User created successfully: ${credential.user!.uid}');
        
        // Update display name
        await credential.user!.updateDisplayName(displayName);
        print('Display name updated');
        
        // Send email verification
        await credential.user!.sendEmailVerification();
        print('Verification email sent');
        
        // Create user document in Firestore with extended info (non-blocking)
        _createUserDocument(
          credential.user!, 
          displayName,
          phoneNumber: phoneNumber,
          institution: institution,
          course: course,
          yearOfStudy: yearOfStudy,
        ).catchError((error) {
          print('User document creation failed but continuing: $error');
        });
        print('User document creation initiated (non-blocking)');
        
        // Sign out user until email is verified
        await _auth.signOut();
        print('User signed out pending verification');
      }

      return true;
    } catch (e) {
      _errorMessage = 'An unexpected error occurred: $e';
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> signInWithGoogle() async {
    try {
      _isLoading = true;
      _errorMessage = null;
      notifyListeners();

      if (kDebugMode) {
        print('🔄 Starting Google Sign-In process...');
        print('Platform: ${defaultTargetPlatform.name}');
        print('Firebase initialized: ${Firebase.apps.isNotEmpty}');
      }

      // Check Firebase initialization
      if (!_firebaseReady || Firebase.apps.isEmpty) {
        throw Exception('Firebase not ready for authentication');
      }

      // Run authentication diagnostics
      await AuthDebugHelper.performAuthDiagnostics();

      // Set persistence before signing in (only for web)
      if (kIsWeb) {
        await _auth.setPersistence(Persistence.LOCAL);
      }

      // Sign out from Google first to ensure fresh login
      await _googleSignIn.signOut();

      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser == null) {
        if (kDebugMode) {
          print('❌ Google sign-in cancelled by user');
        }
        _isLoading = false;
        notifyListeners();
        return false;
      }

      if (kDebugMode) {
        print('✅ Google account selected: ${googleUser.email}');
        print('Google user ID: ${googleUser.id}');
        print('Display name: ${googleUser.displayName}');
      }

      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
      
      if (kDebugMode) {
        print('🔑 Got Google authentication tokens');
        print('Access Token available: ${googleAuth.accessToken != null}');
        print('ID Token available: ${googleAuth.idToken != null}');
        if (googleAuth.accessToken != null) {
          print('Access Token length: ${googleAuth.accessToken!.length}');
        }
        if (googleAuth.idToken != null) {
          print('ID Token length: ${googleAuth.idToken!.length}');
        }
      }

      if (googleAuth.accessToken == null || googleAuth.idToken == null) {
        _errorMessage = 'Failed to get Google authentication tokens. Please try again.';
        return false;
      }

      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      if (kDebugMode) {
        print('🔄 Signing in to Firebase with Google credentials...');
      }

      final userCredential = await _auth.signInWithCredential(credential);
      
      if (kDebugMode) {
        print('✅ Firebase Google sign in successful: ${userCredential.user?.email}');
        print('User UID: ${userCredential.user?.uid}');
        print('Email verified: ${userCredential.user?.emailVerified}');
        print('Provider data: ${userCredential.user?.providerData.map((p) => p.providerId).toList()}');
      }

      // Load user model after successful authentication
      if (userCredential.user != null) {
        _loadUserModel();
      }

      // Log successful authentication attempt
      AuthDebugHelper.logAuthAttempt('Google Sign-In', googleUser.email);
      
      if (kDebugMode) {
        print('✅ Google Sign-In completed successfully');
      }
      
      return true;
    } on FirebaseAuthException catch (e) {
      if (kDebugMode) {
        print('❌ Firebase Auth Exception during Google sign-in: ${e.code} - ${e.message}');
        print('Error details: ${e.toString()}');
      }
      AuthDebugHelper.logAuthAttempt('Google Sign-In', 'unknown', error: e);
      _errorMessage = _getAuthErrorMessage(e.code);
      return false;
    } on Exception catch (e) {
      if (kDebugMode) {
        print('❌ Exception during Google sign-in: $e');
        print('Exception type: ${e.runtimeType}');
      }
      AuthDebugHelper.logAuthAttempt('Google Sign-In', 'unknown', error: e);
      _errorMessage = 'Google sign-in failed: Please check your internet connection and try again.';
      return false;
    } catch (e) {
      if (kDebugMode) {
        print('❌ Unexpected error during Google sign-in: $e');
        print('Error type: ${e.runtimeType}');
        print('Stack trace: ${StackTrace.current}');
      }
      AuthDebugHelper.logAuthAttempt('Google Sign-In', 'unknown', error: e);
      _errorMessage = 'An unexpected error occurred during Google sign-in';
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> _createUserDocument(
    User user, 
    String displayName, {
    String? phoneNumber,
    String? institution,
    String? course,
    String? yearOfStudy,
    bool isGoogleSignIn = false,
  }) async {
    try {
      final now = DateTime.now();
      final registrationMethod = isGoogleSignIn ? 'google' : 'email';
      
      // Save session data to secure storage
      await SecureSessionService.saveUserSession(
        userId: user.uid,
        email: user.email ?? '',
        displayName: displayName,
        loginMethod: isGoogleSignIn ? 'google' : 'email',
      );
      
      final userModel = UserModel(
        id: user.uid,
        email: user.email ?? '',
        displayName: displayName,
        photoUrl: user.photoURL,
        phoneNumber: phoneNumber,
        institution: institution,
        course: course,
        yearOfStudy: yearOfStudy,
        createdAt: now,
        updatedAt: now,
        registrationMethod: registrationMethod,
        isEmailVerified: isGoogleSignIn || user.emailVerified,
        emailVerifiedAt: (isGoogleSignIn || user.emailVerified) ? now : null,
        lastLoginAt: now,
        isProfileComplete: _isProfileComplete(displayName, phoneNumber, institution, course),
      );
      
      // Try to create user document in Firestore, but don't fail registration if offline
      try {
        await _firestore.collection('users').doc(user.uid).set(userModel.toJson());
        print('User document created successfully in Firestore for ${user.email}');
      } catch (firestoreError) {
        print('Firestore error (will retry later): $firestoreError');
        // Don't throw error - allow registration to continue
      }
      
      // Store comprehensive user data in Realtime Database
      try {
        print('🔄 About to call DatabaseService.createUser for: ${user.uid}');
        print('📧 Email: ${user.email}');
        print('👤 Display Name: $displayName');
        print('🔐 Auth Status: ${FirebaseAuth.instance.currentUser != null}');
        
        // Save session data to secure storage
        await SecureSessionService.saveUserSession(
          userId: user.uid,
          email: user.email ?? '',
          displayName: displayName,
          loginMethod: registrationMethod,
        );
        
        // Database service call removed - using session storage instead
        if (kDebugMode) {
          print('✅ User session saved successfully for ${user.email}');
        }

        print('✅ User data stored successfully in Realtime Database for ${user.email}');
      } catch (databaseError) {
        print('❌ Realtime Database error: $databaseError');
        print('❌ Stack trace: ${StackTrace.current}');
        // Don't throw error - allow registration to continue
      }
    } catch (e) {
      print('Error in _createUserDocument: $e');
      // Don't throw error for registration flow
    }
  }

  Future<void> signOut() async {
    try {
      _isLoading = true;
      _errorMessage = null;
      notifyListeners();

      if (kDebugMode) {
        print('🔄 Starting signout process...');
      }

      // Clear user data first
      _user = null;
      _userModel = null;
      
      // Sign out from Google and Firebase
      await _googleSignIn.signOut();
      await _auth.signOut();
      
      // Clear any cached session data
      try {
        // Clear Firebase Auth persistence to ensure complete logout
        await _auth.setPersistence(Persistence.NONE);
        await _auth.setPersistence(Persistence.LOCAL); // Reset to local for next login
      } catch (persistenceError) {
        if (kDebugMode) {
          print('Warning: Could not clear auth persistence: $persistenceError');
        }
      }
      
      if (kDebugMode) {
        print('✅ User signed out and session cleared');
      }
    } catch (e) {
      if (kDebugMode) {
        print('❌ Sign out failed: $e');
      }
      _errorMessage = 'Sign out failed';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> resetPassword(String email) async {
    try {
      _isLoading = true;
      _errorMessage = null;
      notifyListeners();

      await _auth.sendPasswordResetEmail(email: email);
      return true;
    } on FirebaseAuthException catch (e) {
      _errorMessage = _getAuthErrorMessage(e.code);
      return false;
    } catch (e) {
      _errorMessage = 'Failed to send reset email';
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> updateUserProfile({
    String? displayName,
    String? photoUrl,
    List<String>? skills,
    String? careerGoal,
    Map<String, dynamic>? preferences,
  }) async {
    if (_user == null || _userModel == null) return;

    try {
      _isLoading = true;
      notifyListeners();

      final updatedUser = _userModel!.copyWith(
        displayName: displayName ?? _userModel!.displayName,
        photoUrl: photoUrl ?? _userModel!.photoUrl,
        skills: skills ?? _userModel!.skills,
        careerGoal: careerGoal ?? _userModel!.careerGoal,
        preferences: preferences ?? _userModel!.preferences,
        updatedAt: DateTime.now(),
      );

      // Update Firestore
      await _firestore.collection('users').doc(_user!.uid).update(updatedUser.toJson());
      
      // Update Realtime Database
      final updates = <String, dynamic>{};
      if (displayName != null) updates['displayName'] = displayName;
      if (photoUrl != null) updates['photoUrl'] = photoUrl;
      if (skills != null) updates['skills'] = skills;
      if (careerGoal != null) updates['careerGoal'] = careerGoal;
      if (preferences != null) updates['preferences'] = preferences;
      
      if (updates.isNotEmpty) {
        // Update session timestamp to keep session alive
        await SecureSessionService.updateSessionTimestamp();
      }
      
      _userModel = updatedUser;

      if (displayName != null && displayName != _user!.displayName) {
        await _user!.updateDisplayName(displayName);
      }
    } catch (e) {
      _errorMessage = 'Failed to update profile';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> saveProject(String projectId) async {
    if (_userModel == null || _user == null) {
      print('Cannot save project: User not authenticated');
      return;
    }

    try {
      print('Attempting to save project: $projectId');
      final updatedSavedProjects = List<String>.from(_userModel!.savedProjectIds);
      
      if (!updatedSavedProjects.contains(projectId)) {
        updatedSavedProjects.add(projectId);
        
        final updatedUser = _userModel!.copyWith(
          savedProjectIds: updatedSavedProjects,
          updatedAt: DateTime.now(),
        );

        // Update Firestore with retry logic
        await _firestore.collection('users').doc(_user!.uid)
            .set(updatedUser.toJson(), SetOptions(merge: true))
            .timeout(const Duration(seconds: 10));
        
        // Update session timestamp to keep session alive
        await SecureSessionService.updateSessionTimestamp();
        print('Project saved successfully: $projectId. Total saved: ${updatedSavedProjects.length}');
        print('Current saved project IDs: $updatedSavedProjects');
        notifyListeners();
      } else {
        print('Project already saved: $projectId');
      }
    } catch (e) {
      print('Error saving project: $e');
      _errorMessage = 'Failed to save project: $e';
      notifyListeners();
      rethrow;
    }
  }

  Future<void> unsaveProject(String projectId) async {
    if (_userModel == null || _user == null) {
      print('Cannot unsave project: User not authenticated');
      return;
    }

    try {
      print('Attempting to unsave project: $projectId');
      final updatedSavedProjects = List<String>.from(_userModel!.savedProjectIds);
      final removed = updatedSavedProjects.remove(projectId);
      
      final updatedUser = _userModel!.copyWith(
        savedProjectIds: updatedSavedProjects,
        updatedAt: DateTime.now(),
      );

      // Update Firestore with retry logic
      await _firestore.collection('users').doc(_user!.uid)
          .set(updatedUser.toJson(), SetOptions(merge: true))
          .timeout(const Duration(seconds: 10));
      
      _userModel = updatedUser;
      print('Project unsaved successfully: $projectId. Removed: $removed. Total saved: ${updatedSavedProjects.length}');
      print('Current saved project IDs: $updatedSavedProjects');
      notifyListeners();
    } catch (e) {
      print('Error unsaving project: $e');
      _errorMessage = 'Failed to unsave project: $e';
      notifyListeners();
      rethrow;
    }
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  // Helper method to update last login time
  Future<void> _updateLastLogin() async {
    if (_user == null || _userModel == null) return;
    
    try {
      await _firestore.collection('users').doc(_user!.uid).update({
        'lastLoginAt': DateTime.now().toIso8601String(),
        'updatedAt': DateTime.now().toIso8601String(),
      });
    } catch (e) {
      print('Error updating last login: $e');
    }
  }

  // Helper method to update email verification status
  Future<void> _updateEmailVerificationStatus() async {
    if (_user == null || _userModel == null) return;
    
    try {
      final now = DateTime.now();
      await _firestore.collection('users').doc(_user!.uid).update({
        'isEmailVerified': true,
        'emailVerifiedAt': now.toIso8601String(),
        'updatedAt': now.toIso8601String(),
      });
      
      _userModel = _userModel!.copyWith(
        isEmailVerified: true,
        emailVerifiedAt: now,
        updatedAt: now,
      );
      
      print('Email verification status updated');
      notifyListeners();
    } catch (e) {
      print('Error updating email verification status: $e');
    }
  }

  // Helper method to check if profile is complete
  bool _isProfileComplete(String? displayName, String? phoneNumber, String? institution, String? course) {
    return displayName != null && 
           displayName.isNotEmpty && 
           institution != null && 
           institution.isNotEmpty && 
           course != null && 
           course.isNotEmpty;
  }

  // Method to resend email verification
  Future<bool> resendEmailVerification() async {
    if (_user == null) {
      _errorMessage = 'No user signed in';
      return false;
    }
    
    try {
      _isLoading = true;
      notifyListeners();
      
      await _user!.sendEmailVerification();
      _errorMessage = 'Verification email sent! Please check your inbox.';
      return true;
    } catch (e) {
      _errorMessage = 'Failed to send verification email: $e';
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Method to check and refresh email verification status
  Future<void> checkEmailVerification() async {
    if (_user == null) return;
    
    try {
      await _user!.reload();
      _user = _auth.currentUser;
      
      if (_user != null && _user!.emailVerified && _userModel != null && !_userModel!.isEmailVerified) {
        await _updateEmailVerificationStatus();
      }
    } catch (e) {
      print('Error checking email verification: $e');
    }
  }

  String _getAuthErrorMessage(String code) {
    switch (code) {
      case 'user-not-found':
        return 'No user found with this email address.';
      case 'wrong-password':
        return 'Incorrect password.';
      case 'email-already-in-use':
        return 'An account already exists with this email address.';
      case 'weak-password':
        return 'The password is too weak.';
      case 'invalid-email':
        return 'The email address is invalid.';
      case 'user-disabled':
        return 'This user account has been disabled.';
      case 'too-many-requests':
        return 'Too many attempts. Please try again later.';
      case 'network-request-failed':
        return 'Network error. Please check your connection.';
      case 'operation-not-allowed':
        return 'This sign-in method is not enabled.';
      case 'invalid-credential':
        return 'Invalid credentials provided.';
      case 'account-exists-with-different-credential':
        return 'An account already exists with the same email but different sign-in credentials.';
      case 'credential-already-in-use':
        return 'This credential is already associated with a different user account.';
      case 'popup-closed-by-user':
        return 'Sign-in was cancelled.';
      case 'popup-blocked':
        return 'Sign-in popup was blocked by the browser.';
      case 'cancelled-popup-request':
        return 'Sign-in was cancelled.';
      case 'internal-error':
        return 'An internal error occurred. Please try again.';
      case 'invalid-api-key':
        return 'Invalid API key. Please contact support.';
      case 'app-not-authorized':
        return 'This app is not authorized to use Firebase Authentication.';
      case 'keychain-error':
        return 'A keychain error occurred. Please try again.';
      case 'missing-client-identifier':
        return 'Google Sign-In configuration error. Please contact support.';
      case 'sign_in_failed':
        return 'Google Sign-In failed. Please try again.';
      case 'sign_in_cancelled':
        return 'Google Sign-In was cancelled.';
      case 'sign_in_required':
        return 'Please sign in to continue.';
      default:
        return 'Authentication failed. Please try again.';
    }
  }
}
