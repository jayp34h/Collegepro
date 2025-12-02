import 'package:flutter/foundation.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'elevenlabs_tts_service.dart';

class AryaTTSService {
  static final AryaTTSService _instance = AryaTTSService._internal();
  factory AryaTTSService() => _instance;
  AryaTTSService._internal();

  late FlutterTts _flutterTts;
  late ElevenLabsTTSService _elevenLabsService;
  bool _isInitialized = false;
  bool _isSpeaking = false;
  bool _isEnabled = true;
  String _currentLanguage = 'en-US';
  bool _useElevenLabs = true; // Use ElevenLabs by default for better quality

  // Arya's voice configuration - Fixed for better audibility
  static const double _speechRate = 0.6; // Slightly faster for better engagement
  static const double _volume = 1.0; // Maximum volume for audibility
  static const double _pitch = 1.0; // Normal pitch for clarity

  // Getters
  bool get isInitialized => _useElevenLabs ? _elevenLabsService.isInitialized : _isInitialized;
  bool get isSpeaking => _useElevenLabs ? _elevenLabsService.isSpeaking : _isSpeaking;
  bool get isEnabled => _isEnabled;
  String get currentLanguage => _currentLanguage;
  bool get useElevenLabs => _useElevenLabs;

  // Initialize TTS with Arya's voice settings
  Future<void> initialize() async {
    if (_isInitialized) return;

    try {
      // Initialize ElevenLabs service
      _elevenLabsService = ElevenLabsTTSService();
      await _elevenLabsService.initialize();
      
      // Initialize Flutter TTS as fallback
      _flutterTts = FlutterTts();

      // Set up event handlers
      _flutterTts.setStartHandler(() {
        _isSpeaking = true;
        if (kDebugMode) print('🎤 Arya started speaking');
      });

      _flutterTts.setCompletionHandler(() {
        _isSpeaking = false;
        if (kDebugMode) print('🎤 Arya finished speaking');
      });

      _flutterTts.setErrorHandler((msg) {
        _isSpeaking = false;
        if (kDebugMode) print('🎤 Arya TTS Error: $msg');
      });

      _flutterTts.setCancelHandler(() {
        _isSpeaking = false;
        if (kDebugMode) print('🎤 Arya speech cancelled');
      });

      _flutterTts.setPauseHandler(() {
        if (kDebugMode) print('🎤 Arya speech paused');
      });

      _flutterTts.setContinueHandler(() {
        if (kDebugMode) print('🎤 Arya speech continued');
      });

      // Configure Arya's voice settings
      await _configureAryaVoice();

      _isInitialized = true;
      if (kDebugMode) print('✅ Arya TTS initialized successfully');
    } catch (e) {
      if (kDebugMode) print('❌ Failed to initialize Arya TTS: $e');
      _isInitialized = false;
    }
  }

  // Configure Arya's voice with optimal settings
  Future<void> _configureAryaVoice() async {
    try {
      // Set default language
      await _flutterTts.setLanguage(_currentLanguage);

      // Set speech rate (0.0 to 1.0, where 0.5 is normal)
      await _flutterTts.setSpeechRate(_speechRate);

      // Set volume (0.0 to 1.0) - Maximum for audibility
      await _flutterTts.setVolume(_volume);

      // Set pitch (0.5 to 2.0, where 1.0 is normal)
      await _flutterTts.setPitch(_pitch);

      // Try to set a female voice if available
      await _setOptimalVoice();

      // Additional iOS/Android specific settings for better audio output
      await _setAudioSettings();

      if (kDebugMode) print('🎤 Arya voice configured successfully');
    } catch (e) {
      if (kDebugMode) print('⚠️ Some voice settings may not be available: $e');
    }
  }

  // Set audio settings for better output
  Future<void> _setAudioSettings() async {
    try {
      // Set shared instance for iOS
      await _flutterTts.setSharedInstance(true);
      
      // Set iOS audio session category for better audio output
      await _flutterTts.setIosAudioCategory(IosTextToSpeechAudioCategory.playback, [
        IosTextToSpeechAudioCategoryOptions.allowBluetooth,
        IosTextToSpeechAudioCategoryOptions.allowBluetoothA2DP,
        IosTextToSpeechAudioCategoryOptions.mixWithOthers,
        IosTextToSpeechAudioCategoryOptions.duckOthers,
      ]);

      if (kDebugMode) print('🎤 Audio settings configured for better output');
    } catch (e) {
      if (kDebugMode) print('⚠️ Platform-specific audio settings not available: $e');
    }
  }

  // Set the most suitable female voice for Arya
  Future<void> _setOptimalVoice() async {
    try {
      List<dynamic> voices = await _flutterTts.getVoices;
      
      // Preferred voices based on current language
      List<String> preferredVoices = _getPreferredVoicesForLanguage(_currentLanguage);

      String? selectedVoice;

      // Try to find the best available female voice
      for (String preferredVoice in preferredVoices) {
        for (dynamic voice in voices) {
          String voiceName = '';
          if (voice is Map) {
            voiceName = voice['name']?.toString() ?? '';
          } else {
            voiceName = voice.toString();
          }

          if (voiceName.toLowerCase().contains(preferredVoice.toLowerCase()) ||
              voiceName.toLowerCase().contains('female') ||
              voiceName.toLowerCase().contains('aria') ||
              voiceName.toLowerCase().contains('jenny') ||
              voiceName.toLowerCase().contains('samantha')) {
            selectedVoice = voiceName;
            break;
          }
        }
        if (selectedVoice != null) break;
      }

      if (selectedVoice != null) {
        await _flutterTts.setVoice({'name': selectedVoice, 'locale': _currentLanguage});
        if (kDebugMode) print('🎤 Arya voice set to: $selectedVoice');
      } else {
        if (kDebugMode) print('🎤 Using default voice for Arya');
      }
    } catch (e) {
      if (kDebugMode) print('⚠️ Could not set custom voice: $e');
    }
  }

  // Get preferred voices for specific language
  List<String> _getPreferredVoicesForLanguage(String language) {
    switch (language) {
      case 'en-US':
      case 'en-GB':
      case 'en-AU':
        return [
          'en-US-AriaNeural',      // Microsoft Azure
          'en-US-JennyNeural',     // Microsoft Azure
          'en-US-AmberNeural',     // Microsoft Azure
          'com.apple.ttsbundle.Samantha-compact', // iOS
          'com.apple.ttsbundle.Alex-compact',      // iOS fallback
          'en-us-x-sfg#female_1-local',           // Android
          'en-us-x-sfg#female_2-local',           // Android
          'female',                                // Generic female
        ];
      case 'hi-IN':
        return [
          'hi-IN-SwaraNeural',     // Microsoft Azure Hindi
          'hi-IN-MadhurNeural',    // Microsoft Azure Hindi
          'hi-in-x-hie-local',     // Android Hindi
          'hi-in-x-hie#female_1-local', // Android Hindi female
          'hi-in-x-hie#female_2-local', // Android Hindi female
          'com.apple.ttsbundle.Lekha-compact', // iOS Hindi
          'hindi-female',          // Generic Hindi female
          'female',                // Fallback
        ];
      default:
        return [
          'female',
          'en-US-AriaNeural',
          'com.apple.ttsbundle.Samantha-compact',
        ];
    }
  }

  // Arya speaks the introduction message
  Future<void> speakIntroduction() async {
    if (_useElevenLabs && _elevenLabsService.isInitialized) {
      await _elevenLabsService.speakIntroduction();
    } else {
      String message;
      if (_currentLanguage == 'hi-IN') {
        message = "नमस्ते! मैं आर्या हूँ, आपकी AI इंटरव्यूअर। मुझे जगदीश द्वारा विकसित किया गया है ताकि आप अपने इंटरव्यू कौशल का अभ्यास कर सकें और सुधार कर सकें। मैं आपके चुने गए जॉब रोल के आधार पर प्रश्न पूछूंगी और विस्तृत फीडबैक दूंगी। क्या आप मेरे साथ अपनी इंटरव्यू यात्रा शुरू करने के लिए तैयार हैं?";
      } else {
        message = "Hello! I am Arya, your AI interviewer. I was developed by Jagdish to help you practice and improve your interview skills. I will ask you questions based on your chosen job role and provide detailed feedback to help you grow. Are you ready to begin your interview journey with me?";
      }
      await speak(message);
    }
  }

  // Arya speaks a question
  Future<void> speakQuestion(String question) async {
    if (_useElevenLabs && _elevenLabsService.isInitialized) {
      await _elevenLabsService.speakQuestion(question);
    } else {
      String message;
      if (_currentLanguage == 'hi-IN') {
        message = "यहाँ आपका अगला प्रश्न है: $question। सोचने के लिए अपना समय लें और एक व्यापक उत्तर दें।";
      } else {
        message = "Here's your next question: $question. Take your time to think and provide a comprehensive answer.";
      }
      await speak(message);
    }
  }

  // Arya speaks feedback summary
  Future<void> speakFeedback(String feedback, double score) async {
    if (_useElevenLabs && _elevenLabsService.isInitialized) {
      await _elevenLabsService.speakFeedback(feedback, score);
    } else {
      String scoreComment = '';
      if (_currentLanguage == 'hi-IN') {
        if (score >= 8.0) {
          scoreComment = 'उत्कृष्ट काम!';
        } else if (score >= 6.0) {
          scoreComment = 'अच्छा काम!';
        } else if (score >= 4.0) {
          scoreComment = 'बुरा नहीं है, लेकिन सुधार की गुंजाइश है।';
        } else {
          scoreComment = 'आइए इसे मिलकर बेहतर बनाते हैं।';
        }
      } else {
        if (score >= 8.0) {
          scoreComment = 'Excellent work!';
        } else if (score >= 6.0) {
          scoreComment = 'Good job!';
        } else if (score >= 4.0) {
          scoreComment = 'Not bad, but there\'s room for improvement.';
        } else {
          scoreComment = 'Let\'s work on improving this together.';
        }
      }

      String message;
      if (_currentLanguage == 'hi-IN') {
        message = "$scoreComment आपका स्कोर 10 में से ${score.toStringAsFixed(1)} है। $feedback";
      } else {
        message = "$scoreComment You scored ${score.toStringAsFixed(1)} out of 10. $feedback";
      }
      await speak(message);
    }
  }

  // Arya speaks the final interview summary
  Future<void> speakSummary(String summary, double averageScore) async {
    if (_useElevenLabs && _elevenLabsService.isInitialized) {
      await _elevenLabsService.speakSummary(summary, averageScore);
    } else {
      String congratulations = '';
      if (averageScore >= 8.0) {
        congratulations = 'Congratulations! You performed exceptionally well in this interview.';
      } else if (averageScore >= 6.0) {
        congratulations = 'Well done! You showed good interview skills.';
      } else {
        congratulations = 'Thank you for completing the interview. Remember, practice makes perfect!';
      }

      String message = "$congratulations Your overall score is ${averageScore.toStringAsFixed(1)} out of 10. $summary";
      await speak(message);
    }
  }

  // Arya speaks encouragement during the interview
  Future<void> speakEncouragement() async {
    final encouragements = [
      "You're doing great! Keep up the good work.",
      "I can see you're thinking carefully about your answers. That's excellent!",
      "Your responses show good understanding. Let's continue!",
      "I'm impressed with your thoughtful approach to these questions.",
      "You're making excellent progress in this interview!"
    ];
    
    final message = encouragements[DateTime.now().millisecond % encouragements.length];
    await speak(message);
  }

  // Core speak function with enhanced audio settings
  Future<void> speak(String text) async {
    if (!_isEnabled || text.trim().isEmpty) {
      if (kDebugMode) print('🎤 Arya TTS: Cannot speak - enabled: $_isEnabled, text empty: ${text.trim().isEmpty}');
      return;
    }

    try {
      if (_useElevenLabs && _elevenLabsService.isInitialized) {
        // Use ElevenLabs for high-quality voice
        await _elevenLabsService.speak(text);
      } else if (_isInitialized) {
        // Fallback to Flutter TTS with enhanced settings
        // Stop any current speech
        if (_isSpeaking) {
          await stop();
          await Future.delayed(const Duration(milliseconds: 300));
        }

        // Configure TTS for better audibility with error handling
        try {
          await _flutterTts.setVolume(1.0);
        } catch (e) {
          if (kDebugMode) print('⚠️ Failed to set TTS volume: $e');
        }
        
        try {
          await _flutterTts.setSpeechRate(0.5);
        } catch (e) {
          if (kDebugMode) print('⚠️ Failed to set TTS speech rate: $e');
        }
        
        try {
          await _flutterTts.setPitch(1.0);
        } catch (e) {
          if (kDebugMode) print('⚠️ Failed to set TTS pitch: $e');
        }
        
        try {
          await _flutterTts.setLanguage(_currentLanguage);
        } catch (e) {
          if (kDebugMode) print('⚠️ Failed to set TTS language: $e');
        }
        
        // Clean and prepare text
        String cleanText = _prepareTextForSpeech(text);
        
        if (kDebugMode) {
          print('🎤 Arya speaking (Flutter TTS - ${_currentLanguage}): ${cleanText.substring(0, cleanText.length > 50 ? 50 : cleanText.length)}...');
        }

        // Enable completion awaiting for better audio handling
        await _flutterTts.awaitSpeakCompletion(true);
        
        // Speak the text
        await _flutterTts.speak(cleanText);
      } else {
        if (kDebugMode) print('🎤 Arya TTS: Not initialized');
      }
    } catch (e) {
      if (kDebugMode) print('❌ Arya TTS speak error: $e');
    }
  }

  // Prepare text for better speech synthesis
  String _prepareTextForSpeech(String text) {
    return text
        .replaceAll(RegExp(r'[^\w\s\.,!?;:\-\(\)]'), '') // Remove special characters
        .replaceAll(RegExp(r'\s+'), ' ') // Normalize whitespace
        .replaceAll('AI', 'A I') // Spell out AI for clarity
        .replaceAll('API', 'A P I') // Spell out API
        .replaceAll('UI', 'U I') // Spell out UI
        .replaceAll('UX', 'U X') // Spell out UX
        .trim();
  }

  // Stop Arya from speaking
  Future<void> stop() async {
    try {
      if (_useElevenLabs && _elevenLabsService.isInitialized) {
        await _elevenLabsService.stop();
      } else if (_isInitialized) {
        await _flutterTts.stop();
        _isSpeaking = false;
      }
      if (kDebugMode) print('🎤 Arya stopped speaking');
    } catch (e) {
      if (kDebugMode) print('❌ Error stopping Arya TTS: $e');
    }
  }

  // Pause Arya's speech
  Future<void> pause() async {
    if (!_isInitialized || !_isSpeaking) return;
    
    try {
      await _flutterTts.pause();
      if (kDebugMode) print('🎤 Arya speech paused');
    } catch (e) {
      if (kDebugMode) print('❌ Error pausing Arya TTS: $e');
    }
  }

  // Resume Arya's speech
  Future<void> resume() async {
    if (!_isInitialized) return;
    
    try {
      await _flutterTts.speak('');
      if (kDebugMode) print('🎤 Arya speech resumed');
    } catch (e) {
      if (kDebugMode) print('❌ Error resuming Arya TTS: $e');
    }
  }

  // Enable/disable Arya's voice
  void setEnabled(bool enabled) {
    _isEnabled = enabled;
    if (!enabled && _isSpeaking) {
      stop();
    }
    if (kDebugMode) print('🎤 Arya TTS ${enabled ? 'enabled' : 'disabled'}');
  }

  // Adjust Arya's speech rate
  Future<void> setSpeechRate(double rate) async {
    if (!_isInitialized) return;
    
    try {
      await _flutterTts.setSpeechRate(rate.clamp(0.1, 1.0));
      if (kDebugMode) print('🎤 Arya speech rate set to: $rate');
    } catch (e) {
      if (kDebugMode) print('❌ Error setting Arya speech rate: $e');
    }
  }

  // Adjust Arya's volume
  Future<void> setVolume(double volume) async {
    if (!_isInitialized) return;
    
    try {
      await _flutterTts.setVolume(volume.clamp(0.0, 1.0));
      if (kDebugMode) print('🎤 Arya volume set to: $volume');
    } catch (e) {
      if (kDebugMode) print('❌ Error setting Arya volume: $e');
    }
  }

  // Set language for voice selection
  Future<void> setLanguage(String language) async {
    _currentLanguage = language;
    if (kDebugMode) print('🎤 Arya language set to: $language');
    
    if (_useElevenLabs) {
      await _elevenLabsService.setLanguage(language);
    } else {
      // Update voice configuration for the new language
      await _flutterTts.setLanguage(_currentLanguage);
    }
  }

  // Get available voices for user selection
  Future<List<Map<String, String>>> getAvailableVoices() async {
    if (!_isInitialized) return [];
    
    try {
      List<dynamic> voices = await _flutterTts.getVoices;
      return voices.map((voice) {
        if (voice is Map) {
          return {
            'name': voice['name']?.toString() ?? 'Unknown',
            'locale': voice['locale']?.toString() ?? 'en-US',
          };
        }
        return {
          'name': voice.toString(),
          'locale': 'en-US',
        };
      }).toList();
    } catch (e) {
      if (kDebugMode) print('❌ Error getting available voices: $e');
      return [];
    }
  }

  // Dispose resources
  Future<void> dispose() async {
    if (_isInitialized) {
      await stop();
      _isInitialized = false;
      if (kDebugMode) print('🎤 Arya TTS disposed');
    }
  }
}
