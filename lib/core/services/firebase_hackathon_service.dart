import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import '../models/hackathon_model.dart';

class FirebaseHackathonService {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  static const String _collection = 'hackathons';

  /// Add a new hackathon to Firebase
  static Future<bool> addHackathon(HackathonModel hackathon) async {
    try {
      await _firestore.collection(_collection).doc(hackathon.id).set({
        'id': hackathon.id,
        'title': hackathon.title,
        'organizer': hackathon.organizer,
        'description': hackathon.description,
        'prize': hackathon.prize,
        'registrationUrl': hackathon.registrationUrl,
        'startDate': hackathon.startDate?.toIso8601String(),
        'endDate': hackathon.endDate?.toIso8601String(),
        'registrationEndDate': hackathon.registrationEndDate?.toIso8601String(),
        'tags': hackathon.tags,
        'difficulty': hackathon.difficulty,
        'location': hackathon.location,
        'isOnline': hackathon.isOnline,
        'logoUrl': hackathon.logoUrl,
        'participantCount': hackathon.participantCount,
        'createdAt': FieldValue.serverTimestamp(),
        'isActive': true,
      });
      
      if (kDebugMode) print('✅ Hackathon added successfully: ${hackathon.title}');
      return true;
    } catch (e) {
      if (kDebugMode) print('❌ Error adding hackathon: $e');
      return false;
    }
  }

  /// Get all hackathons from Firebase
  static Future<List<HackathonModel>> getAllHackathons() async {
    try {
      final querySnapshot = await _firestore
          .collection(_collection)
          .where('isActive', isEqualTo: true)
          .orderBy('createdAt', descending: true)
          .get();

      if (kDebugMode) print('🔍 Firebase query returned ${querySnapshot.docs.length} hackathons');

      final hackathons = querySnapshot.docs.map((doc) {
        final data = doc.data();
        if (kDebugMode) print('📄 Processing hackathon: ${doc.id} - ${data['title']}');
        
        return HackathonModel(
          id: data['id'] ?? doc.id,
          title: data['title'] ?? '',
          organizer: data['organizer'] ?? '',
          description: data['description'] ?? '',
          prize: data['prize'] ?? 'Recognition',
          registrationUrl: data['registrationUrl'] ?? '',
          startDate: data['startDate'] != null ? DateTime.parse(data['startDate']) : null,
          endDate: data['endDate'] != null ? DateTime.parse(data['endDate']) : null,
          registrationEndDate: data['registrationEndDate'] != null ? DateTime.parse(data['registrationEndDate']) : null,
          tags: List<String>.from(data['tags'] ?? []),
          difficulty: data['difficulty'] ?? 'All Levels',
          location: data['location'],
          isOnline: data['isOnline'] ?? false,
          logoUrl: data['logoUrl'],
          participantCount: data['participantCount'],
        );
      }).toList();

      if (kDebugMode) print('✅ Loaded ${hackathons.length} hackathons from Firebase');
      return hackathons;
    } catch (e) {
      if (kDebugMode) print('❌ Error fetching hackathons: $e');
      return [];
    }
  }

  /// Get real-time stream of hackathons
  static Stream<List<HackathonModel>> getHackathonsStream() {
    return _firestore
        .collection(_collection)
        .where('isActive', isEqualTo: true)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) {
      if (kDebugMode) print('📡 Real-time update: ${snapshot.docs.length} hackathons');
      
      return snapshot.docs.map((doc) {
        final data = doc.data();
        return HackathonModel(
          id: data['id'] ?? doc.id,
          title: data['title'] ?? '',
          organizer: data['organizer'] ?? '',
          description: data['description'] ?? '',
          prize: data['prize'] ?? 'Recognition',
          registrationUrl: data['registrationUrl'] ?? '',
          startDate: data['startDate'] != null ? DateTime.parse(data['startDate']) : null,
          endDate: data['endDate'] != null ? DateTime.parse(data['endDate']) : null,
          registrationEndDate: data['registrationEndDate'] != null ? DateTime.parse(data['registrationEndDate']) : null,
          tags: List<String>.from(data['tags'] ?? []),
          difficulty: data['difficulty'] ?? 'All Levels',
          location: data['location'],
          isOnline: data['isOnline'] ?? false,
          logoUrl: data['logoUrl'],
          participantCount: data['participantCount'],
        );
      }).toList();
    });
  }

  /// Search hackathons by keywords
  static Future<List<HackathonModel>> searchHackathons(String query) async {
    try {
      final querySnapshot = await _firestore
          .collection(_collection)
          .where('isActive', isEqualTo: true)
          .get();

      final allHackathons = querySnapshot.docs.map((doc) {
        final data = doc.data();
        return HackathonModel(
          id: data['id'] ?? doc.id,
          title: data['title'] ?? '',
          organizer: data['organizer'] ?? '',
          description: data['description'] ?? '',
          prize: data['prize'] ?? 'Recognition',
          registrationUrl: data['registrationUrl'] ?? '',
          startDate: data['startDate'] != null ? DateTime.parse(data['startDate']) : null,
          endDate: data['endDate'] != null ? DateTime.parse(data['endDate']) : null,
          registrationEndDate: data['registrationEndDate'] != null ? DateTime.parse(data['registrationEndDate']) : null,
          tags: List<String>.from(data['tags'] ?? []),
          difficulty: data['difficulty'] ?? 'All Levels',
          location: data['location'],
          isOnline: data['isOnline'] ?? false,
          logoUrl: data['logoUrl'],
          participantCount: data['participantCount'],
        );
      }).toList();

      // Filter hackathons based on search query
      final filteredHackathons = allHackathons.where((hackathon) {
        final searchLower = query.toLowerCase();
        return hackathon.title.toLowerCase().contains(searchLower) ||
               hackathon.organizer.toLowerCase().contains(searchLower) ||
               hackathon.tags.any((tag) => tag.toLowerCase().contains(searchLower)) ||
               (hackathon.description.toLowerCase().contains(searchLower));
      }).toList();

      if (kDebugMode) print('✅ Found ${filteredHackathons.length} hackathons matching "$query"');
      return filteredHackathons;
    } catch (e) {
      if (kDebugMode) print('❌ Error searching hackathons: $e');
      return [];
    }
  }

  /// Get hackathons by difficulty
  static Future<List<HackathonModel>> getHackathonsByDifficulty(String difficulty) async {
    try {
      final querySnapshot = await _firestore
          .collection(_collection)
          .where('isActive', isEqualTo: true)
          .where('difficulty', isEqualTo: difficulty)
          .orderBy('createdAt', descending: true)
          .get();

      final hackathons = querySnapshot.docs.map((doc) {
        final data = doc.data();
        return HackathonModel(
          id: data['id'] ?? doc.id,
          title: data['title'] ?? '',
          organizer: data['organizer'] ?? '',
          description: data['description'] ?? '',
          prize: data['prize'] ?? 'Recognition',
          registrationUrl: data['registrationUrl'] ?? '',
          startDate: data['startDate'] != null ? DateTime.parse(data['startDate']) : null,
          endDate: data['endDate'] != null ? DateTime.parse(data['endDate']) : null,
          registrationEndDate: data['registrationEndDate'] != null ? DateTime.parse(data['registrationEndDate']) : null,
          tags: List<String>.from(data['tags'] ?? []),
          difficulty: data['difficulty'] ?? 'All Levels',
          location: data['location'],
          isOnline: data['isOnline'] ?? false,
          logoUrl: data['logoUrl'],
          participantCount: data['participantCount'],
        );
      }).toList();

      if (kDebugMode) print('✅ Found ${hackathons.length} hackathons with difficulty: $difficulty');
      return hackathons;
    } catch (e) {
      if (kDebugMode) print('❌ Error fetching hackathons by difficulty: $e');
      return [];
    }
  }

  /// Update a hackathon
  static Future<bool> updateHackathon(HackathonModel hackathon) async {
    try {
      await _firestore.collection(_collection).doc(hackathon.id).update({
        'title': hackathon.title,
        'organizer': hackathon.organizer,
        'description': hackathon.description,
        'prize': hackathon.prize,
        'registrationUrl': hackathon.registrationUrl,
        'startDate': hackathon.startDate?.toIso8601String(),
        'endDate': hackathon.endDate?.toIso8601String(),
        'registrationEndDate': hackathon.registrationEndDate?.toIso8601String(),
        'tags': hackathon.tags,
        'difficulty': hackathon.difficulty,
        'location': hackathon.location,
        'isOnline': hackathon.isOnline,
        'logoUrl': hackathon.logoUrl,
        'participantCount': hackathon.participantCount,
        'updatedAt': FieldValue.serverTimestamp(),
      });
      
      if (kDebugMode) print('✅ Hackathon updated successfully: ${hackathon.title}');
      return true;
    } catch (e) {
      if (kDebugMode) print('❌ Error updating hackathon: $e');
      return false;
    }
  }

  /// Delete a hackathon (soft delete)
  static Future<bool> deleteHackathon(String hackathonId) async {
    try {
      await _firestore.collection(_collection).doc(hackathonId).update({
        'isActive': false,
        'deletedAt': FieldValue.serverTimestamp(),
      });
      
      if (kDebugMode) print('✅ Hackathon deleted successfully: $hackathonId');
      return true;
    } catch (e) {
      if (kDebugMode) print('❌ Error deleting hackathon: $e');
      return false;
    }
  }

  /// Get popular hackathon categories
  static List<String> getPopularCategories() {
    return [
      'Web Development',
      'Mobile App Development',
      'AI/ML',
      'Blockchain',
      'IoT',
      'Cybersecurity',
      'Game Development',
      'Data Science',
      'Cloud Computing',
      'Open Source',
    ];
  }

  /// Get difficulty levels
  static List<String> getDifficultyLevels() {
    return [
      'All Levels',
      'Beginner',
      'Intermediate',
      'Advanced',
    ];
  }
}
