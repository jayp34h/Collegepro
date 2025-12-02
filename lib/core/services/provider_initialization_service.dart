import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/project_provider.dart';
import '../providers/internship_provider.dart';
import '../../features/hackathons/providers/hackathon_provider.dart';
import '../../features/ai_interview/providers/ai_interview_provider.dart';
import '../../features/coding_practice/providers/coding_practice_provider.dart';

/// Service to handle provider initialization with proper error handling and timeouts
class ProviderInitializationService {
  static const Duration _initializationTimeout = Duration(seconds: 30);
  
  /// Initialize all providers that need async setup
  static Future<void> initializeProviders(BuildContext context) async {
    try {
      print('🔄 Starting provider initialization...');
      
      // Get all providers from context
      final projectProvider = Provider.of<ProjectProvider>(context, listen: false);
      final internshipProvider = Provider.of<InternshipProvider>(context, listen: false);
      final hackathonProvider = Provider.of<HackathonProvider>(context, listen: false);
      final aiInterviewProvider = Provider.of<AIInterviewProvider>(context, listen: false);
      final codingPracticeProvider = Provider.of<CodingPracticeProvider>(context, listen: false);
      
      // Initialize providers in parallel with timeout protection
      await Future.wait([
        _initializeProvider('ProjectProvider', () => projectProvider.initialize()),
        _initializeProvider('InternshipProvider', () => internshipProvider.initialize()),
        _initializeProvider('HackathonProvider', () => hackathonProvider.initialize()),
        _initializeProvider('AIInterviewProvider', () => aiInterviewProvider.initialize()),
        _initializeProvider('CodingPracticeProvider', () => codingPracticeProvider.initialize()),
      ]).timeout(_initializationTimeout);
      
      print('✅ All providers initialized successfully');
    } catch (e) {
      print('⚠️ Provider initialization completed with some errors: $e');
      // Don't throw error - app should still work with fallback data
    }
  }
  
  /// Initialize a single provider with error handling
  static Future<void> _initializeProvider(String name, Future<void> Function() initializer) async {
    try {
      await initializer();
      print('✅ $name initialized successfully');
    } catch (e) {
      print('⚠️ $name initialization failed: $e');
      // Continue with other providers - don't let one failure stop others
    }
  }
  
  /// Initialize providers lazily when first accessed
  static Future<void> initializeProviderLazily(BuildContext context, String providerName) async {
    try {
      switch (providerName) {
        case 'ProjectProvider':
          final provider = Provider.of<ProjectProvider>(context, listen: false);
          await _initializeProvider('ProjectProvider', () => provider.initialize());
          break;
        case 'InternshipProvider':
          final provider = Provider.of<InternshipProvider>(context, listen: false);
          await _initializeProvider('InternshipProvider', () => provider.initialize());
          break;
        case 'HackathonProvider':
          final provider = Provider.of<HackathonProvider>(context, listen: false);
          await _initializeProvider('HackathonProvider', () => provider.initialize());
          break;
        case 'AIInterviewProvider':
          final provider = Provider.of<AIInterviewProvider>(context, listen: false);
          await _initializeProvider('AIInterviewProvider', () => provider.initialize());
          break;
        case 'CodingPracticeProvider':
          final provider = Provider.of<CodingPracticeProvider>(context, listen: false);
          await _initializeProvider('CodingPracticeProvider', () => provider.initialize());
          break;
        default:
          print('⚠️ Unknown provider: $providerName');
      }
    } catch (e) {
      print('⚠️ Lazy initialization failed for $providerName: $e');
    }
  }
  
  /// Check if a provider needs initialization
  static bool needsInitialization(String providerName) {
    // These providers have initialize() methods and should be initialized
    return [
      'ProjectProvider',
      'InternshipProvider', 
      'HackathonProvider',
      'AIInterviewProvider',
      'CodingPracticeProvider'
    ].contains(providerName);
  }
}
