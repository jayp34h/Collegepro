import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class UserProvider extends ChangeNotifier {
  SharedPreferences? _prefs;
  bool _hasCompletedOnboarding = false;
  bool _isDarkMode = false;
  String _selectedLanguage = 'en';
  bool _isInitialized = false;

  // Add a future that can be awaited to know when preferences are loaded
  Future<void>? _initFuture;
  
  bool get hasCompletedOnboarding => _hasCompletedOnboarding;
  bool get isDarkMode => _isDarkMode;
  String get selectedLanguage => _selectedLanguage;
  bool get isInitialized => _isInitialized;
  Future<void>? get initializationFuture => _initFuture;

  UserProvider() {
    _initFuture = _loadPreferences();
  }

  Future<void> _loadPreferences() async {
    try {
      _prefs = await SharedPreferences.getInstance()
          .timeout(const Duration(seconds: 3));
      _hasCompletedOnboarding = _prefs?.getBool('onboarding_completed') ?? false;
      _isDarkMode = _prefs?.getBool('dark_mode') ?? false;
      _selectedLanguage = _prefs?.getString('selected_language') ?? 'en';
      _isInitialized = true;
      notifyListeners();
    } catch (e) {
      print('SharedPreferences failed, using defaults: $e');
      // If SharedPreferences fails, use defaults and mark as initialized
      _hasCompletedOnboarding = false;
      _isDarkMode = false;
      _selectedLanguage = 'en';
      _isInitialized = true;
      notifyListeners();
    }
  }

  // Check if user has completed onboarding by checking both SharedPreferences and Firestore
  Future<bool> checkOnboardingStatus() async {
    if (!_isInitialized) {
      await _initFuture;
    }
    return _hasCompletedOnboarding;
  }

  Future<void> completeOnboarding() async {
    _hasCompletedOnboarding = true;
    await _prefs?.setBool('onboarding_completed', true);
    notifyListeners();
  }

  // Mark onboarding as completed for returning authenticated users
  Future<void> markOnboardingCompleted() async {
    if (!_hasCompletedOnboarding) {
      _hasCompletedOnboarding = true;
      await _prefs?.setBool('onboarding_completed', true);
      notifyListeners();
    }
  }

  Future<void> toggleDarkMode() async {
    _isDarkMode = !_isDarkMode;
    await _prefs?.setBool('dark_mode', _isDarkMode);
    notifyListeners();
  }

  Future<void> setLanguage(String languageCode) async {
    _selectedLanguage = languageCode;
    await _prefs?.setString('selected_language', languageCode);
    notifyListeners();
  }

  Future<void> clearUserData() async {
    await _prefs?.clear();
    _hasCompletedOnboarding = false;
    _isDarkMode = false;
    _selectedLanguage = 'en';
    notifyListeners();
  }
}
