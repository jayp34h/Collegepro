import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../widgets/main_navigation.dart';
import '../../features/splash/splash_screen.dart';
import '../../features/onboarding/onboarding_screen.dart';
import '../../../features/auth/login_screen.dart';
import '../../../features/auth/register_screen.dart';
import '../../features/auth/forgot_password_screen.dart';
import '../../features/auth/email_verification_screen.dart';
import '../../features/project_details/project_details_screen.dart';
import '../../features/profile/profile_screen.dart';
import '../../features/ai_recommendations/ai_recommendations_screen.dart';
import '../../features/mentor/doubt_screen.dart';
import '../../features/saved_projects/saved_projects_screen.dart';
import '../../features/resume/resume_screen.dart';
import '../../features/hackathons/hackathons_screen.dart';
import '../../features/internships/internships_screen.dart';
import '../../features/scholarships/scholarships_screen.dart';
import '../../features/help/help_screen.dart';
import '../../features/settings/settings_screen.dart';
import '../../features/ai_interview/screens/ai_interview_screen.dart';
import '../../features/coding_practice/screens/coding_practice_screen.dart';
import '../../features/coding_practice/screens/coding_dashboard_screen.dart';
import '../../features/community_doubts/screens/community_doubts_screen.dart';
import '../../features/community_doubts/screens/doubt_details_screen.dart';
import '../../features/community_doubts/screens/badge_collection_screen.dart';
import '../../features/notes/screens/notes_screen.dart';
import '../../features/ai_summarizer/screens/ai_summarizer_screen.dart';

class AppRouter {
  static final GoRouter router = GoRouter(
    initialLocation: '/splash',
    routes: [
      GoRoute(
        path: '/splash',
        name: 'splash',
        builder: (context, state) => const SplashScreen(),
      ),
      GoRoute(
        path: '/onboarding',
        name: 'onboarding',
        builder: (context, state) => const OnboardingScreen(),
      ),
      GoRoute(
        path: '/login',
        name: 'login',
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: '/register',
        name: 'register',
        builder: (context, state) => const RegisterScreen(),
      ),
      GoRoute(
        path: '/forgot-password',
        name: 'forgot-password',
        builder: (context, state) => const ForgotPasswordScreen(),
      ),
      GoRoute(
        path: '/email-verification',
        name: 'email-verification',
        builder: (context, state) => const EmailVerificationScreen(),
      ),
      GoRoute(
        path: '/dashboard',
        name: 'dashboard',
        builder: (context, state) => const MainNavigation(),
      ),
      GoRoute(
        path: '/project/:projectId',
        name: 'project-details',
        builder: (context, state) {
          final projectId = state.pathParameters['projectId']!;
          return ProjectDetailsScreen(projectId: projectId);
        },
      ),
      // Drawer screens - these will be navigated to using push navigation
      GoRoute(
        path: '/saved-projects',
        name: 'saved-projects',
        builder: (context, state) => const SavedProjectsScreen(),
      ),
      GoRoute(
        path: '/profile',
        name: 'profile',
        builder: (context, state) => const ProfileScreen(),
      ),
      GoRoute(
        path: '/ai-recommendations',
        name: 'ai-recommendations',
        builder: (context, state) => const AIRecommendationsScreen(),
      ),
      GoRoute(
        path: '/doubt-screen',
        name: 'doubt-screen',
        builder: (context, state) => const DoubtScreen(),
      ),
      GoRoute(
        path: '/resume',
        name: 'resume',
        builder: (context, state) => const ResumeScreen(),
      ),
      GoRoute(
        path: '/hackathons',
        name: 'hackathons',
        builder: (context, state) => const HackathonsScreen(),
      ),
      GoRoute(
        path: '/internships',
        name: 'internships',
        builder: (context, state) => const InternshipsScreen(),
      ),
      GoRoute(
        path: '/scholarships',
        name: 'scholarships',
        builder: (context, state) => const ScholarshipsScreen(),
      ),
      GoRoute(
        path: '/help',
        name: 'help',
        builder: (context, state) => const HelpScreen(),
      ),
      GoRoute(
        path: '/settings',
        name: 'settings',
        builder: (context, state) => const SettingsScreen(),
      ),
      GoRoute(
        path: '/ai-interview',
        name: 'ai-interview',
        builder: (context, state) => const AIInterviewScreen(),
      ),
      GoRoute(
        path: '/coding-practice',
        name: 'coding-practice',
        builder: (context, state) => const CodingPracticeScreen(),
      ),
      GoRoute(
        path: '/coding-dashboard',
        name: 'coding-dashboard',
        builder: (context, state) => const CodingDashboardScreen(),
      ),
      GoRoute(
        path: '/community-doubts',
        name: 'community-doubts',
        builder: (context, state) => const CommunityDoubtsScreen(),
      ),
      GoRoute(
        path: '/doubt-details/:doubtId',
        name: 'doubt-details',
        builder: (context, state) {
          final doubtId = state.pathParameters['doubtId']!;
          return DoubtDetailsScreen(doubtId: doubtId);
        },
      ),
      GoRoute(
        path: '/badge-collection',
        name: 'badge-collection',
        builder: (context, state) => const BadgeCollectionScreen(),
      ),
      GoRoute(
        path: '/notes',
        name: 'notes',
        builder: (context, state) => const NotesScreen(),
      ),
      GoRoute(
        path: '/ai-summarizer',
        name: 'ai-summarizer',
        builder: (context, state) => const AiSummarizerScreen(),
      ),
    ],
    errorBuilder: (context, state) => Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.error_outline,
              size: 64,
              color: Colors.red,
            ),
            const SizedBox(height: 16),
            Text(
              'Page not found',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            const SizedBox(height: 8),
            Text(
              'The page you are looking for does not exist.',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () => context.go('/dashboard'),
              child: const Text('Go to Dashboard'),
            ),
          ],
        ),
      ),
    ),
  );
}
