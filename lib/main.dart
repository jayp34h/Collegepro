import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter/scheduler.dart';
import 'package:provider/provider.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'core/theme/app_theme.dart';
import 'core/providers/auth_provider.dart';
import 'core/providers/project_provider.dart';
import 'core/providers/user_provider.dart';
import 'core/providers/scholarship_provider.dart';
import 'core/providers/internship_provider.dart';
import 'core/providers/hackathon_provider.dart';
import 'core/providers/connectivity_provider.dart';
import 'core/providers/feedback_provider.dart';
import 'core/providers/notification_provider.dart';
import 'features/ai_interview/providers/ai_interview_provider.dart';
import 'features/coding_practice/providers/coding_practice_provider.dart';
import 'features/mentor/providers/doubt_provider.dart';
import 'features/community_doubts/providers/community_doubts_provider.dart';
import 'features/notes/providers/notes_provider.dart';
import 'features/ai_summarizer/providers/ai_summarizer_provider.dart';
import 'features/learn/providers/learn_provider.dart';
import 'features/quiz/providers/quiz_provider.dart';
import 'features/quiz/services/quiz_data_manager.dart';
import 'core/providers/user_progress_provider.dart';
import 'core/providers/project_ideas_provider.dart';
import 'core/providers/theme_provider.dart';
import 'core/router/app_router.dart';
import 'core/widgets/app_error_boundary.dart';
import 'core/widgets/app_loading_screen.dart';
import 'core/utils/performance_utils.dart';
import 'core/security/security_manager.dart';
import 'core/services/fcm_service.dart';
import 'core/services/onesignal_service.dart';
import 'core/services/firestore_listener_service.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Add debugging for main thread blocking
  if (kDebugMode) {
    SchedulerBinding.instance.addTimingsCallback((List<FrameTiming> timings) {
      for (final timing in timings) {
        if (timing.totalSpan.inMilliseconds > 16) {
          print('🐌 Frame took ${timing.totalSpan.inMilliseconds}ms (should be <16ms)');
          print('   Build: ${timing.buildDuration.inMilliseconds}ms');
          print('   Raster: ${timing.rasterDuration.inMilliseconds}ms');
        }
      }
    });
  }
  
  // Optimize app performance (minimal operations only)
  await _optimizeAppPerformance();
  
  // Add error handling for the entire app - store original handler
  final originalOnError = FlutterError.onError;
  FlutterError.onError = (FlutterErrorDetails details) {
    if (kDebugMode) {
      print('Flutter Error: ${details.exception}');
    }
    // Call original handler if it exists
    originalOnError?.call(details);
  };
  
  // Initialize Hive (fast local storage)
  await Hive.initFlutter();
  
  // Skip security manager initialization during startup for faster boot
  bool securityInitialized = true; // Will initialize later in background
  
  // Initialize Firebase with proper duplicate app handling
  bool firebaseInitialized = false;
  
  try {
    // Check if Firebase is already initialized
    if (Firebase.apps.isEmpty) {
      if (kDebugMode) {
        print('🔄 Initializing Firebase...');
      }
      await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform,
      ).timeout(PerformanceUtils.platformOptimizedTimeout);
      firebaseInitialized = true;
      if (kDebugMode) {
        print('🔥 Firebase initialized successfully');
      }

      // Set up Firebase Cloud Messaging background handler (fast)
      FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);
      
      // Initialize lightweight services only during startup
      final oneSignalService = OneSignalService();
      await oneSignalService.initialize();
      
      // Initialize other services in background after app loads
      _initializeBackgroundServices();
    } else {
      // Firebase already initialized (hot reload case)
      firebaseInitialized = true;
      if (kDebugMode) {
        print('✅ Firebase already initialized');
      }
    }
  } catch (e) {
    if (e.toString().contains('duplicate-app')) {
      // Firebase already initialized, this is fine
      firebaseInitialized = true;
      if (kDebugMode) {
        print('✅ Firebase already initialized (duplicate app detected)');
      }
    } else {
      if (kDebugMode) {
        print('❌ Firebase initialization failed: $e');
      }
      firebaseInitialized = false;
    }
  }
  
  runApp(FinalYearProjectFinderApp(
    firebaseInitialized: firebaseInitialized,
    securityInitialized: securityInitialized,
  ));
}

/// Initialize background services after app startup to avoid blocking UI
Future<void> _initializeBackgroundServices() async {
  // Run in background without blocking main thread
  Future.microtask(() async {
    try {
      if (kDebugMode) {
        print('🔄 Initializing background services...');
      }
      
      // Initialize security manager
      final securityManager = SecurityManager();
      await securityManager.initialize();
      
      // Initialize quiz data in Firebase
      await QuizDataManager.initializeOnAppStart();
      
      // Initialize FCM service
      final fcmService = FCMService();
      await fcmService.initialize();
      
      // Initialize Firestore listener service
      final firestoreListenerService = FirestoreListenerService();
      await firestoreListenerService.initialize();
      
      if (kDebugMode) {
        print('✅ Background services initialized');
      }
    } catch (e) {
      if (kDebugMode) {
        print('⚠️ Background service initialization error: $e');
      }
    }
  });
}

/// Optimize app performance on startup
Future<void> _optimizeAppPerformance() async {
  // Set preferred orientations for mobile
  if (!kIsWeb) {
    await SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
  }
  
  // Set system UI overlay style
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
      systemNavigationBarColor: Colors.transparent,
    ),
  );
}

class FinalYearProjectFinderApp extends StatelessWidget {
  final bool firebaseInitialized;
  final bool securityInitialized;
  
  const FinalYearProjectFinderApp({
    super.key,
    required this.firebaseInitialized,
    required this.securityInitialized,
  });

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      child: MultiProvider(
        providers: [
          // Initialize lightweight providers first
          ChangeNotifierProvider(create: (_) => ConnectivityProvider()),
          // ThemeProvider - initialize early for theme management
          ChangeNotifierProvider(create: (_) => ThemeProvider()..initialize()),
          // UserProvider loads SharedPreferences with timeout - initialize early
          ChangeNotifierProvider(create: (_) => UserProvider()),
          // AuthProvider - only create if Firebase is initialized
          ChangeNotifierProvider(create: (_) {
            if (firebaseInitialized) {
              final authProvider = AuthProvider();
              if (kDebugMode) {
                print('✅ AuthProvider created with Firebase initialized');
              }
              return authProvider;
            } else {
              if (kDebugMode) {
                print('⚠️ Creating dummy AuthProvider - Firebase not available');
              }
              // Return a basic AuthProvider that won't try to use Firebase
              return AuthProvider();
            }
          }),
          // Other providers - don't initialize data in constructor
          ChangeNotifierProvider(create: (_) => ProjectProvider()),
          ChangeNotifierProvider(create: (_) => FeedbackProvider()),
          ChangeNotifierProvider(create: (_) => NotificationProvider()),
          ChangeNotifierProvider(create: (_) => ScholarshipProvider()),
          ChangeNotifierProvider(create: (_) => InternshipProvider()),
          ChangeNotifierProvider(create: (_) => HackathonProvider()),
          ChangeNotifierProvider(create: (_) => AIInterviewProvider()),
          ChangeNotifierProvider(create: (_) => CodingPracticeProvider()),
          ChangeNotifierProvider(create: (_) => DoubtProvider()),
          ChangeNotifierProxyProvider3<AuthProvider, NotificationProvider, UserProgressProvider, CommunityDoubtsProvider>(
            create: (context) => CommunityDoubtsProvider(null, null),
            update: (context, authProvider, notificationProvider, progressProvider, previous) {
              final provider = previous ?? CommunityDoubtsProvider(authProvider, notificationProvider);
              provider.setProgressProvider(progressProvider);
              return provider;
            },
          ),
          ChangeNotifierProvider(create: (_) => NotesProvider()),
          ChangeNotifierProvider(create: (_) => AiSummarizerProvider()),
          ChangeNotifierProvider(create: (_) => UserProgressProvider()),
          ChangeNotifierProvider(create: (_) => LearnProvider()),
          ChangeNotifierProvider(create: (_) => QuizProvider()),
          ChangeNotifierProvider(create: (_) => ProjectIdeasProvider()),
        ],
        child: AppErrorBoundary(
          child: Builder(
            builder: (context) {
              return Consumer<ThemeProvider>(
                builder: (context, themeProvider, child) {
                  return MaterialApp.router(
                    title: 'CollegePro',
                    debugShowCheckedModeBanner: false,
                    theme: AppTheme.lightTheme,
                    darkTheme: AppTheme.darkTheme,
                    themeMode: themeProvider.themeMode,
                    routerConfig: AppRouter.router,
                    builder: (context, child) {
                      // Always show the app, even if Firebase fails
                      // The splash screen will handle Firebase status internally
                      Widget finalChild = child ?? RepaintBoundary(
                        child: const AppLoadingScreen(
                          message: 'Loading CollegePro...',
                        ),
                      );
                      
                      // Add platform-specific wrappers for consistent rendering
                      if (kIsWeb) {
                        // Web-specific optimizations
                        return RepaintBoundary(
                          child: MediaQuery(
                            data: MediaQuery.of(context).copyWith(
                              textScaleFactor: MediaQuery.of(context).textScaleFactor.clamp(0.8, 1.2),
                            ),
                            child: finalChild,
                          ),
                        );
                      } else {
                        // Mobile-specific optimizations
                        return RepaintBoundary(
                          child: finalChild,
                        );
                      }
                    },
                  );
                },
              );
            },
          ),
        ),
      ),
    );
  }
}
