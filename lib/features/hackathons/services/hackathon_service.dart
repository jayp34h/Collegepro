import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/hackathon_model.dart';

class HackathonService {
  static const String _baseUrl = 'https://api.hackerearth.com/v4/events/';
  static const String _cacheCollection = 'hackathon_cache';
  static const Duration _cacheExpiry = Duration(hours: 6);

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// Fetches upcoming hackathons from HackerEarth API
  Future<List<Hackathon>> fetchUpcomingHackathons() async {
    try {
      // First try to get cached data
      final cachedHackathons = await _getCachedHackathons();
      if (cachedHackathons.isNotEmpty) {
        return cachedHackathons;
      }

      // If no cache or expired, fetch from API
      final response = await http.get(
        Uri.parse('${_baseUrl}?type=upcoming'),
        headers: {
          'Accept': 'application/json',
          'Content-Type': 'application/json',
        },
      ).timeout(const Duration(seconds: 30));

      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body);
        final hackathonResponse = HackathonResponse.fromJson(jsonData);
        
        // Filter for India-based hackathons
        final indiaHackathons = hackathonResponse.hackathons
            .where((hackathon) => hackathon.isInIndia && hackathon.isUpcoming)
            .toList();

        // Cache the results
        await _cacheHackathons(indiaHackathons);

        return indiaHackathons;
      } else {
        throw Exception('Failed to load hackathons: ${response.statusCode}');
      }
    } catch (e) {
      // If API fails, try to return cached data even if expired
      final cachedHackathons = await _getCachedHackathons(ignoreExpiry: true);
      if (cachedHackathons.isNotEmpty) {
        return cachedHackathons;
      }
      
      // If no cache available, return mock data for demonstration
      return _getMockHackathons();
    }
  }

  /// Gets cached hackathons from Firestore
  Future<List<Hackathon>> _getCachedHackathons({bool ignoreExpiry = false}) async {
    try {
      final doc = await _firestore
          .collection(_cacheCollection)
          .doc('latest_hackathons')
          .get();

      if (!doc.exists) return [];

      final data = doc.data()!;
      final cachedAt = (data['cached_at'] as Timestamp).toDate();
      
      // Check if cache is expired
      if (!ignoreExpiry && DateTime.now().difference(cachedAt) > _cacheExpiry) {
        return [];
      }

      final hackathonsJson = data['hackathons'] as List<dynamic>;
      return hackathonsJson
          .map((json) => Hackathon.fromJson(json as Map<String, dynamic>))
          .toList();
    } catch (e) {
      return [];
    }
  }

  /// Caches hackathons to Firestore
  Future<void> _cacheHackathons(List<Hackathon> hackathons) async {
    try {
      await _firestore
          .collection(_cacheCollection)
          .doc('latest_hackathons')
          .set({
        'hackathons': hackathons.map((h) => h.toJson()).toList(),
        'cached_at': FieldValue.serverTimestamp(),
        'count': hackathons.length,
      });
    } catch (e) {
      // Silently fail caching - not critical
    }
  }

  /// Returns mock hackathons for demonstration when API is unavailable
  List<Hackathon> _getMockHackathons() {
    return [
      Hackathon(
        id: 'mock_1',
        title: 'Smart India Hackathon 2024',
        description: 'National level hackathon to solve real-world problems using innovative technology solutions.',
        startDatetime: DateTime.now().add(const Duration(days: 15)),
        endDatetime: DateTime.now().add(const Duration(days: 17)),
        location: 'New Delhi, India',
        url: 'https://www.sih.gov.in/',
        imageUrl: null,
        organizerName: 'Government of India',
        tags: ['Government', 'Innovation', 'Technology'],
        isOnline: false,
      ),
      Hackathon(
        id: 'mock_2',
        title: 'HackerEarth Deep Learning Challenge',
        description: 'Build AI models to solve complex computer vision problems in healthcare.',
        startDatetime: DateTime.now().add(const Duration(days: 8)),
        endDatetime: DateTime.now().add(const Duration(days: 10)),
        location: 'Bangalore, India',
        url: 'https://www.hackerearth.com/challenges/',
        imageUrl: null,
        organizerName: 'HackerEarth',
        tags: ['AI', 'Machine Learning', 'Healthcare'],
        isOnline: true,
      ),
      Hackathon(
        id: 'mock_3',
        title: 'CodeChef SnackDown 2024',
        description: 'Global programming contest with exciting prizes and recognition.',
        startDatetime: DateTime.now().add(const Duration(days: 22)),
        endDatetime: DateTime.now().add(const Duration(days: 24)),
        location: 'Mumbai, India',
        url: 'https://www.codechef.com/snackdown',
        imageUrl: null,
        organizerName: 'CodeChef',
        tags: ['Programming', 'Competitive Coding', 'Global'],
        isOnline: false,
      ),
      Hackathon(
        id: 'mock_4',
        title: 'Flipkart GRiD 4.0',
        description: 'E-commerce innovation challenge focusing on supply chain and customer experience.',
        startDatetime: DateTime.now().add(const Duration(days: 30)),
        endDatetime: DateTime.now().add(const Duration(days: 32)),
        location: 'Hyderabad, India',
        url: 'https://dare2compete.com/o/flipkart-grid-40',
        imageUrl: null,
        organizerName: 'Flipkart',
        tags: ['E-commerce', 'Innovation', 'Supply Chain'],
        isOnline: false,
      ),
      Hackathon(
        id: 'mock_5',
        title: 'Google Solution Challenge 2024',
        description: 'Build solutions for UN Sustainable Development Goals using Google technologies.',
        startDatetime: DateTime.now().add(const Duration(days: 45)),
        endDatetime: DateTime.now().add(const Duration(days: 47)),
        location: 'Online (India Region)',
        url: 'https://developers.google.com/community/gdsc-solution-challenge',
        imageUrl: null,
        organizerName: 'Google',
        tags: ['Sustainability', 'Social Impact', 'Google Cloud'],
        isOnline: true,
      ),
    ];
  }

  /// Clears cached hackathons
  Future<void> clearCache() async {
    try {
      await _firestore
          .collection(_cacheCollection)
          .doc('latest_hackathons')
          .delete();
    } catch (e) {
      // Silently fail
    }
  }

  /// Gets cache status information
  Future<Map<String, dynamic>> getCacheInfo() async {
    try {
      final doc = await _firestore
          .collection(_cacheCollection)
          .doc('latest_hackathons')
          .get();

      if (!doc.exists) {
        return {'exists': false};
      }

      final data = doc.data()!;
      final cachedAt = (data['cached_at'] as Timestamp).toDate();
      final count = data['count'] ?? 0;
      final isExpired = DateTime.now().difference(cachedAt) > _cacheExpiry;

      return {
        'exists': true,
        'cached_at': cachedAt,
        'count': count,
        'is_expired': isExpired,
        'expires_at': cachedAt.add(_cacheExpiry),
      };
    } catch (e) {
      return {'exists': false, 'error': e.toString()};
    }
  }
}
