import 'dart:async';
import 'dart:developer';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_database/firebase_database.dart';
import 'onesignal_service.dart';

class FirestoreListenerService {
  static final FirestoreListenerService _instance = FirestoreListenerService._internal();
  factory FirestoreListenerService() => _instance;
  FirestoreListenerService._internal();

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final OneSignalService _oneSignalService = OneSignalService();
  
  StreamSubscription<QuerySnapshot>? _internshipsSubscription;
  StreamSubscription<QuerySnapshot>? _hackathonsSubscription;
  StreamSubscription<QuerySnapshot>? _scholarshipsSubscription;
  StreamSubscription<DatabaseEvent>? _mentorRepliesSubscription;
  
  bool _isInitialized = false;
  final Set<String> _processedInternships = {};
  final Set<String> _processedHackathons = {};
  final Set<String> _processedScholarships = {};
  final Set<String> _processedReplies = {};

  /// Initialize all Firestore listeners
  Future<void> initialize() async {
    if (_isInitialized) return;

    try {
      // Initialize OneSignal first
      await _oneSignalService.initialize();

      // Start listening to collections
      await _startInternshipListener();
      await _startHackathonListener();
      await _startScholarshipListener();
      await _startMentorReplyListener();

      _isInitialized = true;
      log('FirestoreListenerService: All listeners initialized');
    } catch (e) {
      log('FirestoreListenerService: Initialization error: $e');
    }
  }

  /// Listen for new internships (API-based, no Firestore storage)
  Future<void> _startInternshipListener() async {
    try {
      // Internships are fetched from API (Internshala), not stored in Firestore
      // Since they're not stored in database, we can't listen for real-time changes
      // This would require a different approach - perhaps periodic checks or manual triggers
      
      log('FirestoreListenerService: Internship listener skipped - data comes from API, not Firestore');
      
      // For testing purposes, we can simulate notifications
      // In production, you'd need to implement a different strategy:
      // 1. Store internships in Firestore after fetching from API
      // 2. Use a scheduled function to check for new internships periodically
      // 3. Manually trigger notifications when new internships are found
      
    } catch (e) {
      log('FirestoreListenerService: Error in internship listener: $e');
    }
  }

  /// Listen for new hackathons
  Future<void> _startHackathonListener() async {
    try {
      // Try to get existing hackathons, but handle if collection doesn't exist
      try {
        final existingSnapshot = await _firestore
            .collection('hackathons')
            .orderBy('created_at', descending: true)
            .limit(50)
            .get()
            .timeout(const Duration(seconds: 5));

        for (final doc in existingSnapshot.docs) {
          _processedHackathons.add(doc.id);
        }
      } catch (e) {
        log('FirestoreListenerService: Hackathons collection may not exist yet, starting fresh listener');
      }

      // Listen for new hackathons
      _hackathonsSubscription = _firestore
          .collection('hackathons')
          .snapshots()
          .listen((snapshot) {
        for (final docChange in snapshot.docChanges) {
          if (docChange.type == DocumentChangeType.added) {
            final doc = docChange.doc;
            
            // Skip if already processed
            if (_processedHackathons.contains(doc.id)) continue;
            
            _processedHackathons.add(doc.id);
            _handleNewHackathon(doc);
          }
        }
      });

      log('FirestoreListenerService: Hackathon listener started');
    } catch (e) {
      log('FirestoreListenerService: Error starting hackathon listener: $e');
    }
  }

  /// Listen for new scholarships
  Future<void> _startScholarshipListener() async {
    try {
      // Try to get existing scholarships, but handle if collection doesn't exist
      try {
        final existingSnapshot = await _firestore
            .collection('scholarships')
            .orderBy('created_at', descending: true)
            .limit(50)
            .get()
            .timeout(const Duration(seconds: 5));

        for (final doc in existingSnapshot.docs) {
          _processedScholarships.add(doc.id);
        }
      } catch (e) {
        log('FirestoreListenerService: Scholarships collection may not exist yet, starting fresh listener');
      }

      // Listen for new scholarships
      _scholarshipsSubscription = _firestore
          .collection('scholarships')
          .snapshots()
          .listen((snapshot) {
        for (final docChange in snapshot.docChanges) {
          if (docChange.type == DocumentChangeType.added) {
            final doc = docChange.doc;
            
            // Skip if already processed
            if (_processedScholarships.contains(doc.id)) continue;
            
            _processedScholarships.add(doc.id);
            _handleNewScholarship(doc);
          }
        }
      });

      log('FirestoreListenerService: Scholarship listener started');
    } catch (e) {
      log('FirestoreListenerService: Error starting scholarship listener: $e');
    }
  }

  /// Listen for mentor replies to student doubts (Firebase Realtime Database)
  Future<void> _startMentorReplyListener() async {
    try {
      final database = FirebaseDatabase.instance;
      
      // Get existing doubts to avoid notifying for old ones
      final existingSnapshot = await database
          .ref('doubts')
          .orderByChild('responseTimestamp')
          .limitToLast(100)
          .get();

      if (existingSnapshot.exists && existingSnapshot.value is Map) {
        final doubtsMap = existingSnapshot.value as Map;
        doubtsMap.forEach((key, value) {
          if (value is Map && value['mentorResponse'] != null) {
            _processedReplies.add(key.toString());
          }
        });
      }

      // Listen for changes in doubts collection
      _mentorRepliesSubscription = database
          .ref('doubts')
          .onValue
          .listen(
        (DatabaseEvent event) {
          try {
            if (event.snapshot.exists && event.snapshot.value != null) {
              final dynamic snapshotValue = event.snapshot.value;
              
              if (snapshotValue is Map) {
                final Map<dynamic, dynamic> doubtsMap = snapshotValue;
                
                doubtsMap.forEach((dynamic key, dynamic value) {
                  if (value is Map<dynamic, dynamic>) {
                    final Map<String, dynamic> doubtData = Map<String, dynamic>.from(value);
                    final String doubtKey = key.toString();
                    
                    if (doubtData['mentorResponse'] != null && 
                        doubtData['status'] == 'Answered' &&
                        !_processedReplies.contains(doubtKey)) {
                      
                      _processedReplies.add(doubtKey);
                      _handleNewMentorReplyFromDatabase(doubtKey, doubtData);
                    }
                  }
                });
              }
            }
          } catch (e) {
            log('FirestoreListenerService: Error processing mentor reply update: $e');
          }
        },
        onError: (Object error) {
          log('FirestoreListenerService: Mentor reply listener error: $error');
        },
      );

      log('FirestoreListenerService: Mentor reply listener started (Firebase Realtime Database)');
    } catch (e) {
      log('FirestoreListenerService: Error starting mentor reply listener: $e');
    }
  }


  /// Handle new hackathon added
  void _handleNewHackathon(DocumentSnapshot doc) {
    try {
      final data = doc.data() as Map<String, dynamic>?;
      if (data == null) return;

      final title = data['title'] as String? ?? 'New Hackathon';
      final organizer = data['organizer'] as String? ?? 'Organizer';
      final createdAt = data['created_at'];

      // Only notify for recent hackathons (within last 5 minutes)
      if (createdAt != null) {
        final now = DateTime.now();
        DateTime docTime;
        
        if (createdAt is Timestamp) {
          docTime = createdAt.toDate();
        } else if (createdAt is String) {
          docTime = DateTime.parse(createdAt);
        } else {
          docTime = now; // Default to now if can't parse
        }
        
        final difference = now.difference(docTime).inMinutes;

        if (difference > 5) {
          log('FirestoreListenerService: Skipping old hackathon: $title');
          return;
        }
      }

      log('FirestoreListenerService: New hackathon detected: $title');
      
      _oneSignalService.sendNewHackathonNotification(
        title: title,
        organizer: organizer,
        hackathonId: doc.id,
      );
    } catch (e) {
      log('FirestoreListenerService: Error handling new hackathon: $e');
    }
  }

  /// Handle new scholarship added
  void _handleNewScholarship(DocumentSnapshot doc) {
    try {
      final data = doc.data() as Map<String, dynamic>?;
      if (data == null) return;

      final title = data['title'] as String? ?? 'New Scholarship';
      final provider = data['provider'] as String? ?? 'Provider';
      final createdAt = data['created_at'] as Timestamp?;

      // Only notify for recent scholarships (within last 5 minutes)
      if (createdAt != null) {
        final now = DateTime.now();
        final docTime = createdAt.toDate();
        final difference = now.difference(docTime).inMinutes;

        if (difference > 5) {
          log('FirestoreListenerService: Skipping old scholarship: $title');
          return;
        }
      }

      log('FirestoreListenerService: New scholarship detected: $title');
      
      _oneSignalService.sendNewScholarshipNotification(
        title: title,
        provider: provider,
        scholarshipId: doc.id,
      );
    } catch (e) {
      log('FirestoreListenerService: Error handling new scholarship: $e');
    }
  }

  /// Handle new mentor reply from Firebase Realtime Database
  void _handleNewMentorReplyFromDatabase(String doubtId, Map<String, dynamic> doubtData) {
    try {
      final mentorName = doubtData['mentorName'] as String? ?? 'Mentor';
      final studentUid = doubtData['userId'] as String?;
      final doubtTitle = doubtData['title'] as String? ?? 'Your doubt';
      final responseTimestamp = doubtData['responseTimestamp'] as String?;

      // Only notify for recent replies (within last 5 minutes)
      if (responseTimestamp != null) {
        final now = DateTime.now();
        final responseTime = DateTime.parse(responseTimestamp);
        final difference = now.difference(responseTime).inMinutes;

        if (difference > 5) {
          log('FirestoreListenerService: Skipping old mentor reply');
          return;
        }
      }

      if (studentUid == null) {
        log('FirestoreListenerService: No student UID in mentor reply');
        return;
      }

      log('FirestoreListenerService: New mentor reply detected for student: $studentUid');

      _oneSignalService.sendMentorReplyNotification(
        studentFirebaseUid: studentUid,
        mentorName: mentorName,
        doubtTitle: doubtTitle,
        doubtId: doubtId,
      );
    } catch (e) {
      log('FirestoreListenerService: Error handling mentor reply: $e');
    }
  }

  /// Manually trigger internship notification (for testing)
  Future<void> triggerInternshipNotification({
    required String title,
    required String company,
  }) async {
    await _oneSignalService.sendNewInternshipNotification(
      title: title,
      company: company,
      internshipId: 'test_${DateTime.now().millisecondsSinceEpoch}',
    );
  }

  /// Manually trigger hackathon notification (for testing)
  Future<void> triggerHackathonNotification({
    required String title,
    required String organizer,
  }) async {
    await _oneSignalService.sendNewHackathonNotification(
      title: title,
      organizer: organizer,
      hackathonId: 'test_${DateTime.now().millisecondsSinceEpoch}',
    );
  }

  /// Manually trigger scholarship notification (for testing)
  Future<void> triggerScholarshipNotification({
    required String title,
    required String provider,
  }) async {
    await _oneSignalService.sendNewScholarshipNotification(
      title: title,
      provider: provider,
      scholarshipId: 'test_${DateTime.now().millisecondsSinceEpoch}',
    );
  }

  /// Manually trigger mentor reply notification (for testing)
  Future<void> triggerMentorReplyNotification({
    required String studentUid,
    required String mentorName,
    required String doubtTitle,
  }) async {
    await _oneSignalService.sendMentorReplyNotification(
      studentFirebaseUid: studentUid,
      mentorName: mentorName,
      doubtTitle: doubtTitle,
      doubtId: 'test_${DateTime.now().millisecondsSinceEpoch}',
    );
  }

  /// Stop all listeners and cleanup
  Future<void> dispose() async {
    await _internshipsSubscription?.cancel();
    await _hackathonsSubscription?.cancel();
    await _scholarshipsSubscription?.cancel();
    await _mentorRepliesSubscription?.cancel();
    
    _processedInternships.clear();
    _processedHackathons.clear();
    _processedScholarships.clear();
    _processedReplies.clear();
    
    _isInitialized = false;
    log('FirestoreListenerService: Disposed all listeners');
  }

  /// Restart all listeners
  Future<void> restart() async {
    await dispose();
    await initialize();
  }

  /// Check if service is initialized
  bool get isInitialized => _isInitialized;
}
