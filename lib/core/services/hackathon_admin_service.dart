import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/hackathon_model.dart';

/// Admin service for managing hackathons in Firestore
class HackathonAdminService {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  static const String _collection = 'hackathons';

  /// Add multiple hackathons at once (useful for bulk import)
  static Future<bool> addMultipleHackathons(List<HackathonModel> hackathons) async {
    try {
      final batch = _firestore.batch();
      
      for (final hackathon in hackathons) {
        final docRef = _firestore.collection(_collection).doc(hackathon.id);
        batch.set(docRef, hackathon.toFirestore());
      }
      
      await batch.commit();
      print('Successfully added ${hackathons.length} hackathons to Firestore');
      return true;
    } catch (e) {
      print('Error adding multiple hackathons: $e');
      return false;
    }
  }

  /// Create a new hackathon with auto-generated ID
  static Future<String?> createHackathon({
    required String title,
    required String organizer,
    required String description,
    required String prize,
    required String registrationUrl,
    DateTime? startDate,
    DateTime? endDate,
    DateTime? registrationEndDate,
    List<String> tags = const [],
    String difficulty = 'All Levels',
    String? location,
    bool isOnline = false,
    String? logoUrl,
    int? participantCount,
  }) async {
    try {
      final docRef = _firestore.collection(_collection).doc();
      final hackathonId = docRef.id;
      
      final hackathon = HackathonModel(
        id: hackathonId,
        title: title,
        organizer: organizer,
        description: description,
        prize: prize,
        registrationUrl: registrationUrl,
        startDate: startDate,
        endDate: endDate,
        registrationEndDate: registrationEndDate,
        tags: tags,
        difficulty: difficulty,
        location: location,
        isOnline: isOnline,
        logoUrl: logoUrl,
        participantCount: participantCount,
      );
      
      await docRef.set(hackathon.toFirestore());
      print('Successfully created hackathon: $title with ID: $hackathonId');
      return hackathonId;
    } catch (e) {
      print('Error creating hackathon: $e');
      return null;
    }
  }

  /// Get all hackathons for admin management
  static Future<List<HackathonModel>> getAllHackathons() async {
    try {
      final querySnapshot = await _firestore
          .collection(_collection)
          .orderBy('created_at', descending: true)
          .get();
      
      return querySnapshot.docs
          .map((doc) => HackathonModel.fromFirestore(doc.data()))
          .toList();
    } catch (e) {
      print('Error fetching all hackathons: $e');
      return [];
    }
  }

  /// Search hackathons by title or organizer
  static Future<List<HackathonModel>> searchHackathons(String searchTerm) async {
    try {
      if (searchTerm.isEmpty) {
        return await getAllHackathons();
      }

      // Firestore doesn't support full-text search, so we'll fetch all and filter
      final allHackathons = await getAllHackathons();
      
      final searchLower = searchTerm.toLowerCase();
      return allHackathons.where((hackathon) {
        return hackathon.title.toLowerCase().contains(searchLower) ||
               hackathon.organizer.toLowerCase().contains(searchLower) ||
               hackathon.tags.any((tag) => tag.toLowerCase().contains(searchLower));
      }).toList();
    } catch (e) {
      print('Error searching hackathons: $e');
      return [];
    }
  }

  /// Update hackathon status (useful for marking as ended, etc.)
  static Future<bool> updateHackathonStatus(String hackathonId, Map<String, dynamic> updates) async {
    try {
      updates['updated_at'] = DateTime.now().toIso8601String();
      
      await _firestore
          .collection(_collection)
          .doc(hackathonId)
          .update(updates);
      
      print('Successfully updated hackathon: $hackathonId');
      return true;
    } catch (e) {
      print('Error updating hackathon: $e');
      return false;
    }
  }

  /// Get hackathon statistics
  static Future<Map<String, dynamic>> getHackathonStats() async {
    try {
      final hackathons = await getAllHackathons();
      
      final stats = {
        'total': hackathons.length,
        'upcoming': 0,
        'active': 0,
        'ended': 0,
        'online': 0,
        'offline': 0,
        'by_organizer': <String, int>{},
      };

      for (final hackathon in hackathons) {
        // Count by status
        if (hackathon.isUpcoming) {
          stats['upcoming'] = (stats['upcoming'] as int) + 1;
        } else if (hackathon.isActive) {
          stats['active'] = (stats['active'] as int) + 1;
        } else {
          stats['ended'] = (stats['ended'] as int) + 1;
        }

        // Count by type
        if (hackathon.isOnline) {
          stats['online'] = (stats['online'] as int) + 1;
        } else {
          stats['offline'] = (stats['offline'] as int) + 1;
        }

        // Count by organizer
        final organizers = stats['by_organizer'] as Map<String, int>;
        organizers[hackathon.organizer] = (organizers[hackathon.organizer] ?? 0) + 1;
      }

      return stats;
    } catch (e) {
      print('Error getting hackathon stats: $e');
      return {'total': 0};
    }
  }

  /// Initialize collection with sample data (one-time setup)
  static Future<bool> initializeWithSampleData() async {
    try {
      // Check if collection already has data
      final existingDocs = await _firestore
          .collection(_collection)
          .limit(1)
          .get();
      
      if (existingDocs.docs.isNotEmpty) {
        print('Hackathons collection already has data, skipping initialization');
        return true;
      }

      // Use the sample data from HackathonService
      final sampleHackathons = [
        HackathonModel(
          id: 'hackathon_2025_001',
          title: 'HackerEarth India Championship 2025',
          description: 'The biggest coding championship in India with exciting prizes and opportunities to showcase your skills.',
          organizer: 'HackerEarth',
          startDate: DateTime(2025, 2, 15),
          endDate: DateTime(2025, 2, 17),
          registrationEndDate: DateTime(2025, 2, 14),
          location: 'Bangalore, India',
          isOnline: false,
          registrationUrl: 'https://www.hackerearth.com/challenges/',
          tags: ['India', '2025', 'Championship', 'Coding', 'Offline'],
          prize: '₹5,00,000',
        ),
        HackathonModel(
          id: 'hackathon_2025_002',
          title: 'Smart India Hackathon 2025',
          description: 'Government initiative to solve real-world problems through innovative technology solutions.',
          organizer: 'Government of India',
          startDate: DateTime(2025, 3, 10),
          endDate: DateTime(2025, 3, 12),
          registrationEndDate: DateTime(2025, 3, 9),
          location: 'Online',
          isOnline: true,
          registrationUrl: 'https://www.sih.gov.in/',
          tags: ['India', '2025', 'Government', 'Innovation', 'Online'],
          prize: '₹1,00,000',
        ),
        HackathonModel(
          id: 'hackathon_2025_003',
          title: 'TechGig Code Gladiators 2025',
          description: 'India\'s biggest coding competition with multiple rounds and exciting programming challenges.',
          organizer: 'TechGig',
          startDate: DateTime(2025, 4, 5),
          endDate: DateTime(2025, 4, 7),
          registrationEndDate: DateTime(2025, 4, 4),
          location: 'Online',
          isOnline: true,
          registrationUrl: 'https://www.techgig.com/codegladiators',
          tags: ['India', '2025', 'Online', 'Competition', 'Programming'],
          prize: '₹3,00,000',
        ),
        HackathonModel(
          id: 'hackathon_2025_004',
          title: 'Microsoft Imagine Cup India 2025',
          description: 'Build innovative solutions using Microsoft technologies and compete on a global stage.',
          organizer: 'Microsoft India',
          startDate: DateTime(2025, 5, 20),
          endDate: DateTime(2025, 5, 22),
          registrationEndDate: DateTime(2025, 5, 19),
          location: 'Hyderabad, India',
          isOnline: false,
          registrationUrl: 'https://imaginecup.microsoft.com/',
          tags: ['India', '2025', 'Microsoft', 'Global', 'Offline'],
          prize: '\$25,000',
        ),
        HackathonModel(
          id: 'hackathon_2025_005',
          title: 'Google Summer of Code 2025',
          description: 'Work with open source organizations on exciting projects during the summer break.',
          organizer: 'Google',
          startDate: DateTime(2025, 6, 1),
          endDate: DateTime(2025, 8, 31),
          registrationEndDate: DateTime(2025, 5, 31),
          location: 'Online',
          isOnline: true,
          registrationUrl: 'https://summerofcode.withgoogle.com/',
          tags: ['India', '2025', 'Google', 'Open Source', 'Online'],
          prize: '\$3,000',
        ),
      ];

      return await addMultipleHackathons(sampleHackathons);
    } catch (e) {
      print('Error initializing hackathons collection: $e');
      return false;
    }
  }
}
