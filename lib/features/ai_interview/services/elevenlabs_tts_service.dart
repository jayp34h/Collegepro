import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:audioplayers/audioplayers.dart';

class ElevenLabsTTSService {
  static final ElevenLabsTTSService _instance = ElevenLabsTTSService._internal();
  factory ElevenLabsTTSService() => _instance;
  ElevenLabsTTSService._internal();

  // ElevenLabs API Configuration
  static const String _apiKey = 'sk_4ed86b6ddfe1060a3789a795cf49875c5bdf47c7a51e826b';
  static const String _baseUrl = 'https://api.elevenlabs.io/v1';
  static const String _model = 'eleven_multilingual_v2';
  
  // Voice IDs for different languages and styles - Updated for Arya
  static const String _hindiVoiceId = 'EXAVITQu4vr4xnSDxMaL'; // Bella - Female Hindi voice
  static const String _aryaVoiceId = 'AZnzlk1XvdvUeBnXmlld'; // Primary Arya voice
  
  late AudioPlayer _audioPlayer;
  bool _isInitialized = false;
  bool _isSpeaking = false;
  bool _isEnabled = true;
  String _currentLanguage = 'en-US';

  // Getters
  bool get isInitialized => _isInitialized;
  bool get isSpeaking => _isSpeaking;
  bool get isEnabled => _isEnabled;
  String get currentLanguage => _currentLanguage;

  // Initialize ElevenLabs TTS service
  Future<void> initialize() async {
    if (_isInitialized) return;

    try {
      _audioPlayer = AudioPlayer();
      
      // Configure audio player for better compatibility and volume
      await _audioPlayer.setReleaseMode(ReleaseMode.release);
      await _audioPlayer.setPlayerMode(PlayerMode.mediaPlayer);
      await _audioPlayer.setVolume(1.0); // Set maximum volume
      
      // Set up audio player event handlers
      _audioPlayer.onPlayerStateChanged.listen((PlayerState state) {
        switch (state) {
          case PlayerState.playing:
            _isSpeaking = true;
            if (kDebugMode) print('🎤 Arya (ElevenLabs) started speaking');
            break;
          case PlayerState.completed:
          case PlayerState.stopped:
            _isSpeaking = false;
            if (kDebugMode) print('🎤 Arya (ElevenLabs) finished speaking');
            break;
          case PlayerState.paused:
            if (kDebugMode) print('🎤 Arya (ElevenLabs) paused');
            break;
          case PlayerState.disposed:
            _isSpeaking = false;
            if (kDebugMode) print('🎤 Arya (ElevenLabs) disposed');
            break;
        }
      });

      _audioPlayer.onPlayerComplete.listen((_) {
        _isSpeaking = false;
        if (kDebugMode) print('🎤 Arya (ElevenLabs) playback completed');
      });

      _isInitialized = true;
      if (kDebugMode) print('✅ ElevenLabs TTS initialized successfully');
    } catch (e) {
      if (kDebugMode) print('❌ Failed to initialize ElevenLabs TTS: $e');
      _isInitialized = false;
    }
  }

  // Set language for voice selection
  Future<void> setLanguage(String language) async {
    _currentLanguage = language;
    if (kDebugMode) print('🎤 ElevenLabs language set to: $language');
  }

  // Get voice ID based on current language
  String _getVoiceId() {
    switch (_currentLanguage) {
      case 'hi-IN':
        return _hindiVoiceId;
      case 'en-US':
      case 'en-GB':
      case 'en-AU':
      default:
        return _aryaVoiceId; // Use Arya's dedicated voice
    }
  }

  // Core speak method that handles ElevenLabs TTS
  Future<void> speak(String text) async {
    if (!_isInitialized || !_isEnabled || text.trim().isEmpty) {
      if (kDebugMode) print('🎤 ElevenLabs TTS: Cannot speak - initialized: $_isInitialized, enabled: $_isEnabled, text empty: ${text.trim().isEmpty}');
      return;
    }

    try {
      // Stop any current playback
      if (_isSpeaking) {
        await _audioPlayer.stop();
        await Future.delayed(const Duration(milliseconds: 300));
      }

      // Ensure volume is at maximum
      await _audioPlayer.setVolume(1.0);

      if (kDebugMode) print('🎤 ElevenLabs TTS: Generating speech for text (${text.length} chars): "${text.substring(0, text.length > 50 ? 50 : text.length)}..."');

      // Generate audio from ElevenLabs API
      final audioData = await _generateSpeech(text);
      
      if (audioData != null && audioData.isNotEmpty) {
        if (kDebugMode) print('🎤 ElevenLabs TTS: Audio data generated successfully (${audioData.length} bytes)');
        // Play the generated audio
        await _playAudioData(audioData);
      } else {
        if (kDebugMode) print('❌ ElevenLabs TTS: Failed to generate audio data or empty response');
        // Fallback to Flutter TTS if ElevenLabs fails
        throw Exception('ElevenLabs audio generation failed');
      }
    } catch (e) {
      if (kDebugMode) print('❌ ElevenLabs TTS speak error: $e');
      // Don't rethrow - let the calling service handle fallback
    }
  }

  // Generate audio using ElevenLabs API
  Future<Uint8List?> _generateSpeech(String text) async {
    try {
      final voiceId = _getVoiceId();
      final url = '$_baseUrl/text-to-speech/$voiceId';
      
      final headers = {
        'Accept': 'audio/mpeg',
        'Content-Type': 'application/json',
        'xi-api-key': _apiKey,
      };

      final body = jsonEncode({
        'text': text,
        'model_id': _model,
        'voice_settings': {
          'stability': 0.6,
          'similarity_boost': 0.8,
          'style': 0.2,
          'use_speaker_boost': true,
        },
      });

      if (kDebugMode) print('🎤 Making ElevenLabs API request...');
      
      final response = await http.post(
        Uri.parse(url),
        headers: headers,
        body: body,
      );

      if (response.statusCode == 200) {
        if (kDebugMode) print('✅ ElevenLabs API request successful (${response.bodyBytes.length} bytes)');
        if (response.bodyBytes.isEmpty) {
          if (kDebugMode) print('❌ ElevenLabs API returned empty audio data');
          return null;
        }
        return response.bodyBytes;
      } else {
        if (kDebugMode) print('❌ ElevenLabs API error: ${response.statusCode} - ${response.body}');
        return null;
      }
    } catch (e) {
      if (kDebugMode) print('❌ ElevenLabs API request failed: $e');
      return null;
    }
  }

  // Play audio data using AudioPlayer
  Future<void> _playAudioData(Uint8List audioData) async {
    try {
      if (kDebugMode) print('🎤 Audio data size: ${audioData.length} bytes');
      
      // Try BytesSource first (most reliable for audio data)
      try {
        if (kDebugMode) print('🎤 Trying BytesSource playback...');
        await _audioPlayer.play(BytesSource(audioData));
        if (kDebugMode) print('✅ BytesSource playback successful');
        return;
      } catch (bytesError) {
        if (kDebugMode) print('❌ BytesSource failed: $bytesError');
      }
      
      // Fallback: Try platform-specific approaches
      await _tryPlatformSpecificPlayback(audioData);
    } catch (e) {
      if (kDebugMode) print('❌ Error in audio playback: $e');
      rethrow;
    }
  }

  // Platform-specific audio playback fallbacks
  Future<void> _tryPlatformSpecificPlayback(Uint8List audioData) async {
    try {
      if (kDebugMode) print('🎤 Trying platform-specific audio playback...');
      
      // Try base64 data URL approach
      try {
        if (kDebugMode) print('🎤 Converting audio data to base64 URL...');
        final base64Audio = base64Encode(audioData);
        final dataUrl = 'data:audio/mpeg;base64,$base64Audio';
        
        if (kDebugMode) print('🎤 Playing audio from data URL...');
        await _audioPlayer.play(UrlSource(dataUrl));
        if (kDebugMode) print('✅ Data URL playback successful');
        return;
      } catch (dataUrlError) {
        if (kDebugMode) print('❌ Data URL failed: $dataUrlError');
      }
      
      // Try creating temporary file with proper path
      try {
        final tempDir = Directory.systemTemp;
        final fileName = 'arya_${DateTime.now().millisecondsSinceEpoch}.mp3';
        final file = File('${tempDir.path}/$fileName');
        
        await file.writeAsBytes(audioData);
        
        if (kDebugMode) print('🎤 Playing from temp file: ${file.path}');
        
        await _audioPlayer.play(DeviceFileSource(file.path));
        
        // Clean up after delay
        Future.delayed(const Duration(seconds: 30), () {
          try {
            if (file.existsSync()) {
              file.deleteSync();
              if (kDebugMode) print('🗑️ Cleaned up audio file');
            }
          } catch (cleanupError) {
            if (kDebugMode) print('⚠️ Cleanup error: $cleanupError');
          }
        });
        
        if (kDebugMode) print('✅ File-based playback successful');
        return;
      } catch (fileError) {
        if (kDebugMode) print('❌ File-based playback failed: $fileError');
      }
      
      // Final fallback: Use Flutter TTS
      if (kDebugMode) print('🔄 All audio methods failed, falling back to Flutter TTS');
      throw Exception('All audio playback methods failed');
      
    } catch (e) {
      if (kDebugMode) print('❌ All platform-specific playback methods failed: $e');
      rethrow;
    }
  }


  // Arya speaks the introduction message
  Future<void> speakIntroduction() async {
    String message;
    if (_currentLanguage == 'hi-IN') {
      message = "नमस्ते! मैं आर्या हूँ, आपकी AI इंटरव्यूअर। मुझे जगदीश द्वारा विकसित किया गया है ताकि आप अपने इंटरव्यू कौशल का अभ्यास कर सकें और सुधार कर सकें। मैं आपके चुने गए जॉब रोल के आधार पर प्रश्न पूछूंगी और विस्तृत फीडबैक दूंगी। क्या आप मेरे साथ अपनी इंटरव्यू यात्रा शुरू करने के लिए तैयार हैं?";
    } else {
      message = "Hello! I am Arya, your AI interviewer. I was developed by Jagdish to help you practice and improve your interview skills. I will ask you questions based on your chosen job role and provide detailed feedback to help you grow. Are you ready to begin your interview journey with me?";
    }
    await speak(message);
  }

  // Arya speaks a question
  Future<void> speakQuestion(String question) async {
    String message;
    if (_currentLanguage == 'hi-IN') {
      message = "यहाँ आपका अगला प्रश्न है: $question। सोचने के लिए अपना समय लें और एक व्यापक उत्तर दें।";
    } else {
      message = "Here's your next question: $question. Take your time to think and provide a comprehensive answer.";
    }
    await speak(message);
  }

  // Arya speaks feedback summary
  Future<void> speakFeedback(String feedback, double score) async {
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

  // Arya speaks the final interview summary
  Future<void> speakSummary(String summary, double averageScore) async {
    String congratulations = '';
    if (_currentLanguage == 'hi-IN') {
      if (averageScore >= 8.0) {
        congratulations = 'बधाई हो! आपने इस इंटरव्यू में असाधारण प्रदर्शन किया है।';
      } else if (averageScore >= 6.0) {
        congratulations = 'बहुत बढ़िया! आपने अच्छे इंटरव्यू कौशल दिखाए हैं।';
      } else {
        congratulations = 'इंटरव्यू पूरा करने के लिए धन्यवाद। याद रखें, अभ्यास से ही सिद्धि मिलती है!';
      }
    } else {
      if (averageScore >= 8.0) {
        congratulations = 'Congratulations! You performed exceptionally well in this interview.';
      } else if (averageScore >= 6.0) {
        congratulations = 'Well done! You showed good interview skills.';
      } else {
        congratulations = 'Thank you for completing the interview. Remember, practice makes perfect!';
      }
    }

    String message;
    if (_currentLanguage == 'hi-IN') {
      message = "$congratulations आपका समग्र स्कोर 10 में से ${averageScore.toStringAsFixed(1)} है। $summary";
    } else {
      message = "$congratulations Your overall score is ${averageScore.toStringAsFixed(1)} out of 10. $summary";
    }
    await speak(message);
  }

  // Stop Arya from speaking
  Future<void> stop() async {
    if (!_isInitialized) return;
    
    try {
      await _audioPlayer.stop();
      _isSpeaking = false;
      if (kDebugMode) print('🎤 Arya (ElevenLabs) stopped speaking');
    } catch (e) {
      if (kDebugMode) print('❌ Error stopping ElevenLabs TTS: $e');
    }
  }

  // Pause Arya's speech
  Future<void> pause() async {
    if (!_isInitialized || !_isSpeaking) return;
    
    try {
      await _audioPlayer.pause();
      if (kDebugMode) print('🎤 Arya (ElevenLabs) speech paused');
    } catch (e) {
      if (kDebugMode) print('❌ Error pausing ElevenLabs TTS: $e');
    }
  }

  // Resume Arya's speech
  Future<void> resume() async {
    if (!_isInitialized) return;
    
    try {
      await _audioPlayer.resume();
      if (kDebugMode) print('🎤 Arya (ElevenLabs) speech resumed');
    } catch (e) {
      if (kDebugMode) print('❌ Error resuming ElevenLabs TTS: $e');
    }
  }

  // Enable/disable Arya's voice
  void setEnabled(bool enabled) {
    _isEnabled = enabled;
    if (!enabled && _isSpeaking) {
      stop();
    }
    if (kDebugMode) print('🎤 Arya (ElevenLabs) TTS ${enabled ? 'enabled' : 'disabled'}');
  }

  // Dispose resources
  Future<void> dispose() async {
    if (_isInitialized) {
      await stop();
      await _audioPlayer.dispose();
      _isInitialized = false;
      if (kDebugMode) print('🎤 Arya (ElevenLabs) TTS disposed');
    }
  }
}
