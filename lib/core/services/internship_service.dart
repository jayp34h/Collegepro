import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/internship_model.dart';

class InternshipService {
  static const String _baseUrl = 'https://internshala.com/internships/api/filtered';
  static const int _timeout = 10; // seconds

  /// Fetch internships from Internshala API
  static Future<List<InternshipModel>> fetchInternships({
    int page = 1,
    String keywords = 'computer science',
    String? location,
    String? category,
  }) async {
    try {
      final queryParams = {
        'page': page.toString(),
        'keywords': keywords,
      };

      if (location != null && location.isNotEmpty) {
        queryParams['location'] = location;
      }

      if (category != null && category.isNotEmpty) {
        queryParams['category'] = category;
      }

      final uri = Uri.parse(_baseUrl).replace(queryParameters: queryParams);
      
      final response = await http.get(
        uri,
        headers: {
          'User-Agent': 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/91.0.4472.124 Safari/537.36',
          'Accept': 'application/json, text/plain, */*',
          'Accept-Language': 'en-US,en;q=0.9',
          'Referer': 'https://internshala.com/',
        },
      ).timeout(Duration(seconds: _timeout));

      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body);
        return _parseInternshipsResponse(jsonData);
      } else {
        print('Failed to fetch internships: ${response.statusCode}');
        return [];
      }
    } catch (e) {
      print('Error fetching internships: $e');
      return [];
    }
  }

  /// Parse the Internshala API response
  static List<InternshipModel> _parseInternshipsResponse(Map<String, dynamic> jsonData) {
    try {
      final List<InternshipModel> internships = [];

      // Handle different possible response structures
      if (jsonData.containsKey('internships_meta')) {
        final internshipsMeta = jsonData['internships_meta'] as Map<String, dynamic>?;
        if (internshipsMeta != null) {
          internshipsMeta.forEach((key, value) {
            if (value is Map<String, dynamic>) {
              try {
                final internship = InternshipModel.fromJson(value);
                internships.add(internship);
              } catch (e) {
                print('Error parsing internship $key: $e');
              }
            }
          });
        }
      } else if (jsonData.containsKey('data')) {
        final data = jsonData['data'];
        if (data is List) {
          for (final item in data) {
            if (item is Map<String, dynamic>) {
              try {
                final internship = InternshipModel.fromJson(item);
                internships.add(internship);
              } catch (e) {
                print('Error parsing internship item: $e');
              }
            }
          }
        }
      } else if (jsonData.containsKey('internships')) {
        final internshipsData = jsonData['internships'];
        if (internshipsData is List) {
          for (final item in internshipsData) {
            if (item is Map<String, dynamic>) {
              try {
                final internship = InternshipModel.fromJson(item);
                internships.add(internship);
              } catch (e) {
                print('Error parsing internship: $e');
              }
            }
          }
        }
      }

      return internships;
    } catch (e) {
      print('Error parsing internships response: $e');
      return [];
    }
  }

  /// Search internships with specific keywords
  static Future<List<InternshipModel>> searchInternships(String query) async {
    return await fetchInternships(keywords: query);
  }

  /// Get internships by location
  static Future<List<InternshipModel>> getInternshipsByLocation(String location) async {
    return await fetchInternships(location: location);
  }

  /// Get popular search keywords
  static List<String> getPopularKeywords() {
    return [
      'computer science',
      'software development',
      'web development',
      'mobile app development',
      'data science',
      'machine learning',
      'artificial intelligence',
      'cybersecurity',
      'digital marketing',
      'graphic design',
      'content writing',
      'business development',
      'finance',
      'human resources',
    ];
  }

  /// Get popular locations
  static List<String> getPopularLocations() {
    return [
      'Bangalore',
      'Mumbai',
      'Delhi',
      'Pune',
      'Hyderabad',
      'Chennai',
      'Kolkata',
      'Gurgaon',
      'Noida',
      'Remote',
    ];
  }

  /// Get fallback internships when API fails
  static List<InternshipModel> getFallbackInternships() {
    return [
      InternshipModel(
        id: 'fallback_1',
        title: 'Software Development Intern',
        company: 'Tech Startup',
        location: 'Bangalore',
        stipend: '₹15,000/month',
        duration: '3 months',
        applyLink: 'https://internshala.com',
        skills: ['Flutter', 'Dart', 'Mobile Development'],
        description: 'Work on mobile app development using Flutter framework.',
      ),
      InternshipModel(
        id: 'fallback_2',
        title: 'Web Development Intern',
        company: 'Digital Agency',
        location: 'Mumbai',
        stipend: '₹12,000/month',
        duration: '6 months',
        applyLink: 'https://internshala.com',
        skills: ['React', 'JavaScript', 'Node.js'],
        description: 'Build responsive web applications using modern technologies.',
      ),
      InternshipModel(
        id: 'fallback_3',
        title: 'Data Science Intern',
        company: 'Analytics Company',
        location: 'Delhi',
        stipend: '₹18,000/month',
        duration: '4 months',
        applyLink: 'https://internshala.com',
        skills: ['Python', 'Machine Learning', 'Data Analysis'],
        description: 'Work on data analysis and machine learning projects.',
      ),
      InternshipModel(
        id: 'fallback_4',
        title: 'UI/UX Design Intern',
        company: 'Design Studio',
        location: 'Pune',
        stipend: '₹10,000/month',
        duration: '3 months',
        applyLink: 'https://internshala.com',
        skills: ['Figma', 'Adobe XD', 'User Research'],
        description: 'Design user interfaces and improve user experience.',
      ),
      InternshipModel(
        id: 'fallback_5',
        title: 'Digital Marketing Intern',
        company: 'Marketing Agency',
        location: 'Remote',
        stipend: '₹8,000/month',
        duration: '2 months',
        applyLink: 'https://internshala.com',
        skills: ['SEO', 'Social Media', 'Content Marketing'],
        description: 'Manage social media campaigns and content marketing.',
      ),
    ];
  }
}
