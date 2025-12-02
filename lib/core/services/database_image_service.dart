import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:firebase_database/firebase_database.dart';
import 'package:image_picker/image_picker.dart';
import 'package:image/image.dart' as img;

class DatabaseImageService {
  final DatabaseReference _database = FirebaseDatabase.instance.ref();
  final ImagePicker _picker = ImagePicker();

  /// Pick and compress image for database storage
  Future<XFile?> pickImage({ImageSource source = ImageSource.gallery}) async {
    try {
      final XFile? image = await _picker.pickImage(
        source: source,
        maxWidth: 512,
        maxHeight: 512,
        imageQuality: 70,
      );
      return image;
    } catch (e) {
      print('Error picking image: $e');
      return null;
    }
  }

  /// Upload profile image to Realtime Database as base64
  Future<String?> uploadProfileImageToDatabase(String userId, XFile imageFile) async {
    try {
      print('🔄 Starting database image upload for user: $userId');
      
      final File file = File(imageFile.path);
      
      // Validate file exists
      if (!await file.exists()) {
        throw Exception('Image file not found. Please try selecting the image again.');
      }
      
      // Read and compress image
      final Uint8List imageBytes = await file.readAsBytes();
      
      // Compress image using image package
      img.Image? image = img.decodeImage(imageBytes);
      if (image == null) {
        throw Exception('Invalid image format. Please select a valid image.');
      }
      
      // Resize if too large
      if (image.width > 400 || image.height > 400) {
        image = img.copyResize(image, width: 400, height: 400);
      }
      
      // Convert to JPEG with compression
      final List<int> compressedBytes = img.encodeJpg(image, quality: 70);
      
      // Check final size (limit to 500KB for database storage)
      if (compressedBytes.length > 500 * 1024) {
        throw Exception('Image too large after compression. Please select a smaller image.');
      }
      
      // Convert to base64
      final String base64Image = base64Encode(compressedBytes);
      final String imageUrl = 'data:image/jpeg;base64,$base64Image';
      
      print('📁 Compressed image size: ${(compressedBytes.length / 1024).toStringAsFixed(1)} KB');
      
      // Store in database
      final imageRef = _database.child('user_profiles').child(userId).child('profileImage');
      await imageRef.set({
        'imageData': base64Image,
        'contentType': 'image/jpeg',
        'uploadedAt': DateTime.now().toIso8601String(),
        'size': compressedBytes.length,
      }).timeout(
        const Duration(seconds: 15),
        onTimeout: () => throw Exception('Upload timeout. Please check your internet connection.'),
      );
      
      print('✅ Image uploaded to database successfully');
      return imageUrl;
      
    } catch (e) {
      print('❌ Error uploading image to database: $e');
      if (e.toString().contains('permission') || e.toString().contains('PERMISSION_DENIED')) {
        throw Exception('Permission denied. Please check Firebase database rules.');
      } else {
        rethrow;
      }
    }
  }

  /// Get profile image from database
  Future<String?> getProfileImageFromDatabase(String userId) async {
    try {
      final snapshot = await _database
          .child('user_profiles')
          .child(userId)
          .child('profileImage')
          .get();
      
      if (snapshot.exists) {
        final data = Map<String, dynamic>.from(snapshot.value as Map);
        final String base64Image = data['imageData'] ?? '';
        if (base64Image.isNotEmpty) {
          return 'data:image/jpeg;base64,$base64Image';
        }
      }
      return null;
    } catch (e) {
      print('❌ Error getting profile image from database: $e');
      return null;
    }
  }

  /// Delete profile image from database
  Future<bool> deleteProfileImageFromDatabase(String userId) async {
    try {
      await _database
          .child('user_profiles')
          .child(userId)
          .child('profileImage')
          .remove();
      print('✅ Profile image deleted from database');
      return true;
    } catch (e) {
      print('❌ Error deleting profile image from database: $e');
      return false;
    }
  }
}
