import 'dart:io';
import 'package:dio/dio.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:open_filex/open_filex.dart';
import '../models/note_model.dart';

class NotesService {
  static final NotesService _instance = NotesService._internal();
  factory NotesService() => _instance;
  NotesService._internal();


  // Predefined notes data
  static List<NoteModel> get allNotes => [
    NoteModel(
      id: 'gen_ai_001',
      title: 'Generative AI Notes',
      subject: 'Generative AI',
      driveUrl: 'https://drive.google.com/file/d/1IPk5DvJ6mYpOU8GydtrKTJY7UL6irgAT/view?usp=drive_link',
      fileName: 'Generative_AI_Notes.pdf',
      fileExtension: 'pdf',
    ),
    NoteModel(
      id: 'full_stack_001',
      title: 'Full Stack Development Notes',
      subject: 'Full Stack',
      driveUrl: 'https://drive.google.com/file/d/1YNjVb9dGf97kuyR-77OKll_IBKTB5Nnr/view?usp=drive_link',
      fileName: 'Full_Stack_Notes.pdf',
      fileExtension: 'pdf',
    ),
    NoteModel(
      id: 'dsa_001',
      title: 'Data Structures & Algorithms Notes',
      subject: 'DSA',
      driveUrl: 'https://drive.google.com/file/d/1JYVXHL0NGmdPzAr_KsH_m_6ohRP32y3r/view?usp=drive_link',
      fileName: 'DSA_Notes.pdf',
      fileExtension: 'pdf',
    ),
    NoteModel(
      id: 'data_science_001',
      title: 'Data Science Notes',
      subject: 'Data Science',
      driveUrl: 'https://drive.google.com/file/d/1cLDFhF2Qp03-cpqGlu1cP5N-L1yvU7DJ/view?usp=drive_link',
      fileName: 'Data_Science_Notes.pdf',
      fileExtension: 'pdf',
    ),
    NoteModel(
      id: 'data_analytics_001',
      title: 'Data Analytics Notes',
      subject: 'Data Analytics',
      driveUrl: 'https://drive.google.com/file/d/18vfkwc0p4DrHukgu6UDYlscZmmkeed-9/view?usp=drive_link',
      fileName: 'Data_Analytics_Notes.pdf',
      fileExtension: 'pdf',
    ),
    NoteModel(
      id: 'cyber_security_001',
      title: 'Cyber Security Notes',
      subject: 'Cyber Security',
      driveUrl: 'https://drive.google.com/file/d/1OLufUlej2ta7BAS9BhlGvYHTszAiaUT5/view?usp=drive_link',
      fileName: 'Cyber_Security_Notes.pdf',
      fileExtension: 'pdf',
    ),
    NoteModel(
      id: 'cloud_computing_001',
      title: 'Cloud Computing Notes',
      subject: 'Cloud Computing',
      driveUrl: 'https://drive.google.com/file/d/1BjcTMBQiUz4SnxqkZomZuEtcR9AUCpOH/view?usp=sharing',
      fileName: 'Cloud_Computing_Notes.pdf',
      fileExtension: 'pdf',
    ),
    NoteModel(
      id: 'cpp_001',
      title: 'C++ Programming Notes',
      subject: 'C++ Language',
      driveUrl: 'https://drive.google.com/file/d/1MJmdo2VCikXmAkOmcbRgbjufXT_w-gxG/view?usp=drive_link',
      fileName: 'CPP_Notes.pdf',
      fileExtension: 'pdf',
    ),
    NoteModel(
      id: 'c_001',
      title: 'C Programming Notes',
      subject: 'C Language',
      driveUrl: 'https://drive.google.com/file/d/1MiPSBDjd8OTkHv9GA8pVzS4HAsYxd8J4/view?usp=drive_link',
      fileName: 'C_Notes.pdf',
      fileExtension: 'pdf',
    ),
    NoteModel(
      id: 'java_001',
      title: 'Java Programming Notes',
      subject: 'Java',
      driveUrl: 'https://drive.google.com/file/d/1t0lDtRiImW1aFZiEpi6qczChliWwXMRZ/view?usp=drive_link',
      fileName: 'Java_Notes.pdf',
      fileExtension: 'pdf',
    ),
  ];

  /// Convert Google Drive share URL to direct download URL
  String _convertToDirectDownloadUrl(String driveUrl) {
    try {
      // Extract file ID from Google Drive URL
      final RegExp regExp = RegExp(r'/file/d/([a-zA-Z0-9-_]+)');
      final match = regExp.firstMatch(driveUrl);
      
      if (match != null) {
        final fileId = match.group(1);
        // Use the direct download URL that works better
        return 'https://drive.google.com/uc?export=download&id=$fileId&confirm=t';
      }
      
      // If URL format is different, try another pattern
      final RegExp regExp2 = RegExp(r'id=([a-zA-Z0-9-_]+)');
      final match2 = regExp2.firstMatch(driveUrl);
      
      if (match2 != null) {
        final fileId = match2.group(1);
        return 'https://drive.google.com/uc?export=download&id=$fileId&confirm=t';
      }
      
      // Try to extract from sharing URL
      final RegExp regExp3 = RegExp(r'sharing\.([a-zA-Z0-9-_]+)');
      final match3 = regExp3.firstMatch(driveUrl);
      
      if (match3 != null) {
        final fileId = match3.group(1);
        return 'https://drive.google.com/uc?export=download&id=$fileId&confirm=t';
      }
      
      return driveUrl; // Return original if no pattern matches
    } catch (e) {
      print('Error converting Drive URL: $e');
      return driveUrl;
    }
  }

  /// Request storage permission
  Future<bool> _requestStoragePermission() async {
    if (Platform.isAndroid) {
      final status = await Permission.storage.request();
      return status.isGranted;
    }
    return true; // iOS doesn't need explicit storage permission for app documents
  }

  /// Get downloads directory path
  Future<String> _getDownloadsPath() async {
    if (Platform.isAndroid) {
      // Try to get external storage directory
      final directory = await getExternalStorageDirectory();
      if (directory != null) {
        final downloadsPath = '${directory.path}/Downloads';
        final downloadsDir = Directory(downloadsPath);
        if (!await downloadsDir.exists()) {
          await downloadsDir.create(recursive: true);
        }
        return downloadsPath;
      }
    }
    
    // Fallback to documents directory
    final directory = await getApplicationDocumentsDirectory();
    final downloadsPath = '${directory.path}/Downloads';
    final downloadsDir = Directory(downloadsPath);
    if (!await downloadsDir.exists()) {
      await downloadsDir.create(recursive: true);
    }
    return downloadsPath;
  }

  /// Download file with progress callback
  Future<String?> downloadNote({
    required NoteModel note,
    required Function(double progress) onProgress,
  }) async {
    try {
      // Request permission
      final hasPermission = await _requestStoragePermission();
      if (!hasPermission) {
        throw Exception('Storage permission denied');
      }

      // Get download path
      final downloadsPath = await _getDownloadsPath();
      final filePath = '$downloadsPath/${note.fileName}';

      // Check if file already exists
      final file = File(filePath);
      if (await file.exists()) {
        return filePath;
      }

      // Convert Google Drive URL to direct download URL
      final downloadUrl = _convertToDirectDownloadUrl(note.driveUrl);
      print('Downloading from URL: $downloadUrl');

      // Configure Dio with better settings for Google Drive
      final dio = Dio();
      dio.options.connectTimeout = const Duration(seconds: 30);
      dio.options.receiveTimeout = const Duration(minutes: 5);
      dio.options.sendTimeout = const Duration(seconds: 30);

      // Download file with progress and better error handling
      await dio.download(
        downloadUrl,
        filePath,
        onReceiveProgress: (received, total) {
          if (total > 0) {
            final progress = received / total;
            onProgress(progress.clamp(0.0, 1.0));
            print('Download progress: ${(progress * 100).toStringAsFixed(1)}%');
          } else {
            // If total is unknown, show indeterminate progress
            onProgress(0.5);
          }
        },
        options: Options(
          followRedirects: true,
          maxRedirects: 10,
          validateStatus: (status) => status! < 400,
          headers: {
            'User-Agent': 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/91.0.4472.124 Safari/537.36',
            'Accept': 'text/html,application/xhtml+xml,application/xml;q=0.9,image/webp,*/*;q=0.8',
            'Accept-Language': 'en-US,en;q=0.5',
            'Accept-Encoding': 'gzip, deflate',
            'Connection': 'keep-alive',
            'Upgrade-Insecure-Requests': '1',
          },
        ),
      );

      // Verify file was downloaded successfully
      if (await file.exists() && await file.length() > 0) {
        print('File downloaded successfully: ${await file.length()} bytes');
        return filePath;
      } else {
        throw Exception('Downloaded file is empty or corrupted');
      }
    } catch (e) {
      print('Download error: $e');
      // Clean up any partial download
      try {
        final file = File('${await _getDownloadsPath()}/${note.fileName}');
        if (await file.exists()) {
          await file.delete();
        }
      } catch (_) {}
      throw Exception('Download failed: ${e.toString()}');
    }
  }

  /// Open file using default app
  Future<void> openFile(String filePath) async {
    try {
      final result = await OpenFilex.open(filePath);
      if (result.type != ResultType.done) {
        throw Exception('Could not open file: ${result.message}');
      }
    } catch (e) {
      throw Exception('Failed to open file: ${e.toString()}');
    }
  }

  /// Check if file exists locally
  Future<bool> isFileDownloaded(NoteModel note) async {
    try {
      final downloadsPath = await _getDownloadsPath();
      final filePath = '$downloadsPath/${note.fileName}';
      final file = File(filePath);
      return await file.exists();
    } catch (e) {
      return false;
    }
  }

  /// Get local file path if exists
  Future<String?> getLocalFilePath(NoteModel note) async {
    try {
      final downloadsPath = await _getDownloadsPath();
      final filePath = '$downloadsPath/${note.fileName}';
      final file = File(filePath);
      if (await file.exists()) {
        return filePath;
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  /// Delete downloaded file
  Future<bool> deleteDownloadedFile(NoteModel note) async {
    try {
      final downloadsPath = await _getDownloadsPath();
      final filePath = '$downloadsPath/${note.fileName}';
      final file = File(filePath);
      if (await file.exists()) {
        await file.delete();
        return true;
      }
      return false;
    } catch (e) {
      return false;
    }
  }

  /// Get file size
  Future<int?> getFileSize(String filePath) async {
    try {
      final file = File(filePath);
      if (await file.exists()) {
        return await file.length();
      }
      return null;
    } catch (e) {
      return null;
    }
  }
}
