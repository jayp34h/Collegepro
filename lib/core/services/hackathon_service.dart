import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/hackathon_model.dart';

class HackathonService {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  static const String _collection = 'hackathons';
  
  /// Fetch hackathons from Firestore with fallback data
  static Future<List<HackathonModel>> fetchHackathons({
    int limit = 50,
    String? lastDocumentId,
  }) async {
    try {
      print('Attempting to fetch hackathons from Firestore...');
      
      // Set a shorter timeout to avoid long waits
      final testQuery = await _firestore
          .collection(_collection)
          .limit(1)
          .get()
          .timeout(const Duration(seconds: 5));
      
      if (testQuery.docs.isEmpty) {
        print('No documents found in $_collection collection, initializing with sample data');
        await _initializeHackathonsCollection();
        // Fetch again after initialization
        return await _fetchFromFirestore(limit: limit, lastDocumentId: lastDocumentId);
      }

      return await _fetchFromFirestore(limit: limit, lastDocumentId: lastDocumentId);
    } catch (e) {
      print('Error fetching hackathons: $e');
      print('Loading fallback hackathon data...');
      return _getFallbackHackathons();
    }
  }

  /// Fetch hackathons from Firestore
  static Future<List<HackathonModel>> _fetchFromFirestore({
    int limit = 50,
    String? lastDocumentId,
  }) async {
    Query query = _firestore
        .collection(_collection)
        .limit(limit);

    // Try to order by created_at, fallback to no ordering
    try {
      query = query.orderBy('created_at', descending: true);
    } catch (e) {
      print('Warning: created_at field not found, using default order');
    }

    if (lastDocumentId != null) {
      try {
        final lastDoc = await _firestore
            .collection(_collection)
            .doc(lastDocumentId)
            .get()
            .timeout(const Duration(seconds: 3));
        if (lastDoc.exists) {
          query = query.startAfterDocument(lastDoc);
        }
      } catch (e) {
        print('Warning: Could not fetch last document, ignoring pagination');
      }
    }

    final querySnapshot = await query
        .get()
        .timeout(const Duration(seconds: 8));
    
    final hackathons = querySnapshot.docs
        .map((doc) => HackathonModel.fromFirestore(doc.data() as Map<String, dynamic>))
        .toList();
        
    print('Successfully fetched ${hackathons.length} hackathons from Firestore');
    return hackathons;
  }

  /// Add a new hackathon to Firestore
  static Future<bool> addHackathon(HackathonModel hackathon) async {
    try {
      await _firestore
          .collection(_collection)
          .doc(hackathon.id)
          .set(hackathon.toFirestore());
      
      print('Successfully added hackathon: ${hackathon.title}');
      return true;
    } catch (e) {
      print('Error adding hackathon: $e');
      return false;
    }
  }

  /// Update an existing hackathon in Firestore
  static Future<bool> updateHackathon(HackathonModel hackathon) async {
    try {
      final updateData = hackathon.toFirestore();
      updateData['updated_at'] = DateTime.now().toIso8601String();
      
      await _firestore
          .collection(_collection)
          .doc(hackathon.id)
          .update(updateData);
      
      print('Successfully updated hackathon: ${hackathon.title}');
      return true;
    } catch (e) {
      print('Error updating hackathon: $e');
      return false;
    }
  }

  /// Delete a hackathon from Firestore
  static Future<bool> deleteHackathon(String hackathonId) async {
    try {
      await _firestore
          .collection(_collection)
          .doc(hackathonId)
          .delete();
      
      print('Successfully deleted hackathon: $hackathonId');
      return true;
    } catch (e) {
      print('Error deleting hackathon: $e');
      return false;
    }
  }

  /// Initialize hackathons collection with sample data
  static Future<void> _initializeHackathonsCollection() async {
    try {
      print('Initializing hackathons collection with sample data...');
      
      final sampleHackathons = _getFallbackHackathons();
      
      for (final hackathon in sampleHackathons) {
        await _firestore
            .collection(_collection)
            .doc(hackathon.id)
            .set(hackathon.toFirestore());
      }
      
      print('Successfully initialized hackathons collection with ${sampleHackathons.length} hackathons');
    } catch (e) {
      print('Error initializing hackathons collection: $e');
    }
  }


  /// Fallback hackathons for 2025 India
  static List<HackathonModel> _getFallbackHackathons() {
    return [
      HackathonModel(
        id: 'fallback_1',
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
        id: 'fallback_2',
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
        id: 'fallback_3',
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
        id: 'fallback_4',
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
        id: 'fallback_5',
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
  }
}
