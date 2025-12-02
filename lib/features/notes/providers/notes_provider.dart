import 'package:flutter/foundation.dart';
import 'package:share_plus/share_plus.dart';
import 'dart:io';
import '../models/note_model.dart';
import '../services/notes_service.dart';
import '../../../core/services/user_progress_service.dart';
import '../../../core/providers/user_progress_provider.dart';
import 'package:firebase_auth/firebase_auth.dart';

class NotesProvider extends ChangeNotifier {
  final NotesService _notesService = NotesService();
  UserProgressProvider? _progressProvider;
  
  List<NoteModel> _notes = [];
  Map<String, double> _downloadProgress = {};
  Map<String, bool> _downloadingStates = {};
  String? _errorMessage;
  bool _isLoading = false;
  
  // Set progress provider for activity tracking
  void setProgressProvider(UserProgressProvider progressProvider) {
    _progressProvider = progressProvider;
  }

  List<NoteModel> get notes => _notes;
  Map<String, double> get downloadProgress => _downloadProgress;
  Map<String, bool> get downloadingStates => _downloadingStates;
  String? get errorMessage => _errorMessage;
  bool get isLoading => _isLoading;

  NotesProvider() {
    _initializeNotes();
  }

  void _initializeNotes() async {
    _isLoading = true;
    notifyListeners();

    try {
      _notes = NotesService.allNotes;
      
      // Check which files are already downloaded
      for (int i = 0; i < _notes.length; i++) {
        final isDownloaded = await _notesService.isFileDownloaded(_notes[i]);
        final localPath = await _notesService.getLocalFilePath(_notes[i]);
        
        _notes[i] = _notes[i].copyWith(
          isDownloaded: isDownloaded,
          localPath: localPath,
          downloadedAt: isDownloaded ? DateTime.now() : null,
        );
      }
      
      _errorMessage = null;
    } catch (e) {
      _errorMessage = 'Failed to initialize notes: ${e.toString()}';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> downloadNote(NoteModel note) async {
    try {
      _downloadingStates[note.id] = true;
      _downloadProgress[note.id] = 0.0;
      _errorMessage = null;
      notifyListeners();

      await _notesService.downloadNote(
        note: note,
        onProgress: (progress) {
          _downloadProgress[note.id] = progress;
          notifyListeners();
        },
      );

      // Update note status
      final noteIndex = _notes.indexWhere((n) => n.id == note.id);
      if (noteIndex != -1) {
        _notes[noteIndex] = _notes[noteIndex].copyWith(isDownloaded: true);
      }
      
      // Track download activity for progress
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        try {
          if (_progressProvider != null) {
            await _progressProvider!.trackActivity(user.uid, 'note_downloaded');
            debugPrint('✅ Tracked note download activity for user: ${user.uid}');
          } else {
            await UserProgressService().trackActivity(user.uid, 'note_downloaded');
          }
        } catch (e) {
          if (kDebugMode) {
            debugPrint('❌ Failed to track note download activity: $e');
          }
        }
      }
    } catch (e) {
      _errorMessage = 'Failed to download ${note.title}: $e';
      if (kDebugMode) {
        print('Download error: $e');
      }
    } finally {
      _downloadingStates[note.id] = false;
      _downloadProgress.remove(note.id);
      notifyListeners();
    }
  }

  Future<void> openNote(NoteModel note) async {
    try {
      _errorMessage = null;
      
      String? filePath = note.localPath;
      
      // If not downloaded, check if file exists locally
      if (filePath == null || !note.isDownloaded) {
        filePath = await _notesService.getLocalFilePath(note);
      }
      
      if (filePath != null) {
        await _notesService.openFile(filePath);
      } else {
        _errorMessage = 'File not found. Please download first.';
        notifyListeners();
      }
    } catch (e) {
      _errorMessage = 'Failed to open file: ${e.toString()}';
      notifyListeners();
    }
  }

  Future<void> deleteNote(NoteModel note) async {
    try {
      _errorMessage = null;
      
      final success = await _notesService.deleteDownloadedFile(note);
      
      if (success) {
        // Update the note in the list
        final index = _notes.indexWhere((n) => n.id == note.id);
        if (index != -1) {
          _notes[index] = _notes[index].copyWith(
            isDownloaded: false,
            localPath: null,
            downloadedAt: null,
          );
        }
      }
      
      notifyListeners();
    } catch (e) {
      _errorMessage = 'Failed to delete file: ${e.toString()}';
      notifyListeners();
    }
  }

  bool isDownloading(String noteId) {
    return _downloadingStates[noteId] ?? false;
  }

  double getDownloadProgress(String noteId) {
    return _downloadProgress[noteId] ?? 0.0;
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  Future<void> refreshNotes() async {
    _initializeNotes();
  }

  List<NoteModel> getNotesForSubject(String subject) {
    return _notes.where((note) => note.subject == subject).toList();
  }

  List<String> get availableSubjects {
    return _notes.map((note) => note.subject).toSet().toList()..sort();
  }

  List<NoteModel> get downloadedNotes {
    return _notes.where((note) => note.isDownloaded).toList();
  }

  /// Share note as PDF file if downloaded, otherwise share note information
  Future<void> shareNote(NoteModel note) async {
    try {
      _errorMessage = null;
      
      if (note.isDownloaded && note.localPath != null) {
        // Share the actual PDF file
        final file = File(note.localPath!);
        if (await file.exists()) {
          final shareText = '''📚 Study Note from CollegePro

📖 Subject: ${note.subject}
📝 Title: ${note.title}

🎓 Shared via CollegePro - Your ultimate education companion!''';
          
          await Share.shareXFiles(
            [XFile(note.localPath!)],
            text: shareText,
            subject: '${note.subject} - ${note.title}',
          );
          
          // Track note sharing activity for file share
          final user = FirebaseAuth.instance.currentUser;
          if (user != null) {
            try {
              if (_progressProvider != null) {
                await _progressProvider!.trackActivity(user.uid, 'note_shared');
                debugPrint('✅ Tracked note sharing activity for user: ${user.uid}');
              } else {
                await UserProgressService().trackActivity(user.uid, 'note_shared');
              }
            } catch (e) {
              debugPrint('❌ Failed to track note sharing activity: $e');
            }
          }
          return;
        }
      }
      
      // Fallback to sharing note information if file not available
      final text = '''📚 Study Note from CollegePro

📖 Subject: ${note.subject}
📝 Title: ${note.title}
📄 File: ${note.fileName}

🎓 Download this note and many more from CollegePro - Your ultimate education companion!

#StudyNotes #Education #CollegePro''';

      await Share.share(text);
      
      // Track note sharing activity for text share
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        try {
          if (_progressProvider != null) {
            await _progressProvider!.trackActivity(user.uid, 'note_shared');
            debugPrint('✅ Tracked note sharing activity for user: ${user.uid}');
          } else {
            await UserProgressService().trackActivity(user.uid, 'note_shared');
          }
        } catch (e) {
          debugPrint('❌ Failed to track note sharing activity: $e');
        }
      }
    } catch (e) {
      _errorMessage = 'Failed to share note: ${e.toString()}';
      notifyListeners();
      if (kDebugMode) {
        print('Share error: $e');
      }
    }
  }

  /// Share note to WhatsApp as PDF file if downloaded
  Future<void> shareNoteToWhatsApp(NoteModel note) async {
    try {
      _errorMessage = null;
      
      if (note.isDownloaded && note.localPath != null) {
        // Share the actual PDF file to WhatsApp
        final file = File(note.localPath!);
        if (await file.exists()) {
          final shareText = '''📚 *Study Note from CollegePro*

📖 *Subject:* ${note.subject}
📝 *Title:* ${note.title}

🎓 Shared via CollegePro - Your ultimate education companion!

#StudyNotes #Education #CollegePro''';
          
          await Share.shareXFiles(
            [XFile(note.localPath!)],
            text: shareText,
            subject: '${note.subject} - ${note.title}',
          );
          
          // Track WhatsApp note sharing activity for file share
          final user = FirebaseAuth.instance.currentUser;
          if (user != null) {
            try {
              if (_progressProvider != null) {
                await _progressProvider!.trackActivity(user.uid, 'note_shared');
                debugPrint('✅ Tracked WhatsApp note sharing activity for user: ${user.uid}');
              } else {
                await UserProgressService().trackActivity(user.uid, 'note_shared');
              }
            } catch (e) {
              debugPrint('❌ Failed to track WhatsApp note sharing activity: $e');
            }
          }
          return;
        }
      }
      
      // Fallback to sharing note information if file not available
      final text = '''📚 *Study Note from CollegePro*

📖 *Subject:* ${note.subject}
📝 *Title:* ${note.title}
📄 *File:* ${note.fileName}

🎓 Download this note and many more from CollegePro - Your ultimate education companion!

#StudyNotes #Education #CollegePro''';

      await Share.share(text);
      
      // Track WhatsApp note sharing activity for text share
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        try {
          if (_progressProvider != null) {
            await _progressProvider!.trackActivity(user.uid, 'note_shared');
            debugPrint('✅ Tracked WhatsApp note sharing activity for user: ${user.uid}');
          } else {
            await UserProgressService().trackActivity(user.uid, 'note_shared');
          }
        } catch (e) {
          debugPrint('❌ Failed to track WhatsApp note sharing activity: $e');
        }
      }
    } catch (e) {
      _errorMessage = 'Failed to share note to WhatsApp: ${e.toString()}';
      notifyListeners();
      if (kDebugMode) {
        print('WhatsApp share error: $e');
      }
    }
  }
}
