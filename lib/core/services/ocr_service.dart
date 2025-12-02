import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;

class OCRService {
  static const String _apiKey = 'K86212518488957';
  static const String _baseUrl = 'https://api.ocr.space/parse/image';

  /// Extract text from resume image/PDF using OCR.space API
  static Future<String> extractTextFromResume(File resumeFile) async {
    try {
      var request = http.MultipartRequest('POST', Uri.parse(_baseUrl));
      
      // Add API key
      request.fields['apikey'] = _apiKey;
      
      // Add file
      request.files.add(await http.MultipartFile.fromPath('file', resumeFile.path));
      
      // Additional parameters for better OCR
      request.fields['language'] = 'eng';
      request.fields['isOverlayRequired'] = 'false';
      request.fields['detectOrientation'] = 'false';
      request.fields['isTable'] = 'false';
      request.fields['scale'] = 'true';
      request.fields['OCREngine'] = '2'; // Use OCR Engine 2 for better accuracy
      
      var response = await request.send();
      var responseBody = await response.stream.bytesToString();
      
      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonResponse = jsonDecode(responseBody);
        
        if (jsonResponse['IsErroredOnProcessing'] == false && 
            jsonResponse['ParsedResults'] != null && 
            jsonResponse['ParsedResults'].isNotEmpty) {
          
          String extractedText = jsonResponse['ParsedResults'][0]['ParsedText'] ?? '';
          
          // Clean up the extracted text
          extractedText = _cleanExtractedText(extractedText);
          
          if (extractedText.trim().isEmpty) {
            throw Exception('No text could be extracted from the resume');
          }
          
          return extractedText;
        } else {
          String errorMessage = jsonResponse['ErrorMessage'] ?? 'Unknown OCR error';
          throw Exception('OCR processing failed: $errorMessage');
        }
      } else {
        throw Exception('OCR API request failed with status: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Failed to extract text from resume: $e');
    }
  }

  /// Clean and format the extracted text for better readability
  static String _cleanExtractedText(String rawText) {
    String cleaned = rawText;
    
    // Remove excessive whitespace and line breaks
    cleaned = cleaned.replaceAll(RegExp(r'\s+'), ' ');
    cleaned = cleaned.replaceAll(RegExp(r'\n\s*\n'), '\n');
    
    // Fix common OCR errors
    cleaned = cleaned.replaceAll(RegExp(r'\|'), 'I'); // Common OCR mistake
    cleaned = cleaned.replaceAll(RegExp(r'0'), 'O'); // In names/words
    cleaned = cleaned.replaceAll(RegExp(r'5'), 'S'); // In words
    
    // Remove special characters that don't belong in resumes
    cleaned = cleaned.replaceAll(RegExp(r'[^\w\s\.\,\-\@\(\)\+\:\;\/]'), '');
    
    // Trim and return
    return cleaned.trim();
  }

  /// Validate if the extracted text looks like a resume
  static bool isValidResumeText(String text) {
    if (text.trim().length < 100) return false;
    
    // Check for common resume keywords
    final resumeKeywords = [
      'experience', 'education', 'skills', 'work', 'project', 
      'university', 'college', 'email', 'phone', 'address',
      'objective', 'summary', 'qualification', 'achievement'
    ];
    
    int keywordCount = 0;
    String lowerText = text.toLowerCase();
    
    for (String keyword in resumeKeywords) {
      if (lowerText.contains(keyword)) {
        keywordCount++;
      }
    }
    
    // Should contain at least 3 resume-related keywords
    return keywordCount >= 3;
  }
}
