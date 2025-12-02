import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path/path.dart' as path;

class ImageUploadService {
  final FirebaseStorage _storage = FirebaseStorage.instance;
  final ImagePicker _picker = ImagePicker();

  /// Pick image from gallery or camera
  Future<XFile?> pickImage({ImageSource source = ImageSource.gallery}) async {
    try {
      final XFile? image = await _picker.pickImage(
        source: source,
        maxWidth: 1024,
        maxHeight: 1024,
        imageQuality: 85,
      );
      return image;
    } catch (e) {
      print('Error picking image: $e');
      return null;
    }
  }

  /// Upload image to Firebase Storage and return download URL
  Future<String?> uploadProfileImage(String userId, XFile imageFile) async {
    try {
      print('🔄 Starting image upload for user: $userId');
      
      final File file = File(imageFile.path);
      
      // Validate file exists and has content
      if (!await file.exists()) {
        print('❌ Image file does not exist: ${imageFile.path}');
        throw Exception('Image file not found. Please try selecting the image again.');
      }
      
      final int fileSize = await file.length();
      if (fileSize == 0) {
        print('❌ Image file is empty');
        throw Exception('Selected image is empty. Please choose a different image.');
      }
      
      // Check file size limit (5MB)
      if (fileSize > 5 * 1024 * 1024) {
        print('❌ Image file too large: ${fileSize} bytes');
        throw Exception('Image too large. Please select an image smaller than 5MB.');
      }
      
      print('📁 File size: ${(fileSize / 1024).toStringAsFixed(1)} KB');
      
      final String fileName = 'profile_${userId}_${DateTime.now().millisecondsSinceEpoch}${path.extension(imageFile.path)}';
      
      // Create reference to Firebase Storage
      final Reference ref = _storage.ref().child('profile_images').child(fileName);
      
      print('📤 Uploading to: profile_images/$fileName');
      
      // Determine content type based on file extension
      String contentType = 'image/jpeg';
      final extension = path.extension(imageFile.path).toLowerCase();
      if (extension == '.png') {
        contentType = 'image/png';
      } else if (extension == '.jpg' || extension == '.jpeg') {
        contentType = 'image/jpeg';
      } else if (extension == '.webp') {
        contentType = 'image/webp';
      } else {
        throw Exception('Unsupported image format. Please use JPG, PNG, or WebP.');
      }
      
      // Upload file with metadata and timeout
      final UploadTask uploadTask = ref.putFile(
        file,
        SettableMetadata(
          contentType: contentType,
          customMetadata: {
            'userId': userId,
            'uploadedAt': DateTime.now().toIso8601String(),
            'originalName': imageFile.name,
            'fileSize': fileSize.toString(),
          },
        ),
      );

      // Monitor upload progress
      uploadTask.snapshotEvents.listen((TaskSnapshot snapshot) {
        if (snapshot.totalBytes > 0) {
          final progress = (snapshot.bytesTransferred / snapshot.totalBytes) * 100;
          print('📊 Upload progress: ${progress.toStringAsFixed(1)}%');
        }
      });

      // Wait for upload to complete with timeout
      final TaskSnapshot snapshot = await uploadTask.timeout(
        const Duration(minutes: 3),
        onTimeout: () {
          print('⏰ Upload timeout after 3 minutes');
          uploadTask.cancel();
          throw Exception('Upload timeout. Please check your internet connection and try again.');
        },
      );
      
      if (snapshot.state != TaskState.success) {
        throw Exception('Upload failed. Please try again.');
      }
      
      print('✅ Upload completed successfully');
      
      // Get download URL with retry logic
      String? downloadUrl;
      for (int attempt = 1; attempt <= 3; attempt++) {
        try {
          downloadUrl = await snapshot.ref.getDownloadURL().timeout(
            const Duration(seconds: 30),
            onTimeout: () => throw Exception('Timeout getting download URL'),
          );
          break;
        } catch (e) {
          print('❌ Attempt $attempt to get download URL failed: $e');
          if (attempt == 3) {
            throw Exception('Failed to get image URL after 3 attempts. Please try again.');
          }
          await Future.delayed(Duration(seconds: attempt * 2));
        }
      }
      
      if (downloadUrl == null || downloadUrl.isEmpty) {
        throw Exception('Failed to get image URL. Please try again.');
      }
      
      print('🔗 Download URL obtained: ${downloadUrl.substring(0, 50)}...');
      
      return downloadUrl;
    } catch (e) {
      print('❌ Error uploading image: $e');
      if (e.toString().contains('storage/unauthorized')) {
        throw Exception('Permission denied. Please check Firebase Storage rules.');
      } else if (e.toString().contains('network')) {
        throw Exception('Network error. Please check your internet connection.');
      } else {
        rethrow;
      }
    }
  }

  /// Delete old profile image from Firebase Storage
  Future<bool> deleteProfileImage(String imageUrl) async {
    try {
      if (imageUrl.isEmpty || !imageUrl.contains('firebase')) {
        print('📭 No Firebase image to delete');
        return true; // Nothing to delete
      }
      
      print('🗑️ Deleting old profile image: ${imageUrl.substring(0, 50)}...');
      
      final Reference ref = _storage.refFromURL(imageUrl);
      await ref.delete().timeout(
        const Duration(seconds: 30),
        onTimeout: () => throw Exception('Timeout deleting old image'),
      );
      
      print('✅ Old profile image deleted successfully');
      return true;
    } catch (e) {
      print('⚠️ Error deleting old image: $e');
      // Don't fail the upload if we can't delete the old image
      return true;
    }
  }

  /// Show image source selection dialog
  Future<ImageSource?> showImageSourceDialog() async {
    // This will be implemented in the UI layer
    return null;
  }
}
