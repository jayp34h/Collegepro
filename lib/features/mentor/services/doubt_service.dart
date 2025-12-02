import 'package:firebase_database/firebase_database.dart';
import '../models/doubt_model.dart';
import '../../../core/services/notification_service.dart';

class DoubtService {
  final DatabaseReference _database = FirebaseDatabase.instance.ref();
  final NotificationService _notificationService = NotificationService();

  // Post a new doubt
  Future<String?> postDoubt(DoubtModel doubt) async {
    try {
      print('🔄 Attempting to post doubt for user: ${doubt.userId}');
      
      final doubtRef = _database.child('doubts').push();
      final doubtWithId = doubt.copyWith(id: doubtRef.key!);
      
      print('📝 Posting doubt with ID: ${doubtRef.key}');
      
      await doubtRef.set(doubtWithId.toJson()).timeout(
        const Duration(seconds: 15),
        onTimeout: () {
          print('⏰ Doubt posting timeout');
          throw Exception('Request timeout. Please check your internet connection.');
        },
      );
      
      print('✅ Doubt posted successfully: ${doubtRef.key}');
      return doubtRef.key;
    } catch (e) {
      print('❌ Error posting doubt: $e');
      if (e.toString().contains('permission') || e.toString().contains('PERMISSION_DENIED')) {
        throw Exception('Permission denied. Please check Firebase database rules.');
      } else if (e.toString().contains('timeout')) {
        throw Exception('Request timeout. Please check your internet connection.');
      } else {
        throw Exception('Failed to post doubt: ${e.toString()}');
      }
    }
  }

  // Get all doubts for a specific user with timeout
  Future<List<DoubtModel>> getUserDoubts(String userId) async {
    try {
      print('Loading doubts for user: $userId');
      
      final snapshot = await _database
          .child('doubts')
          .orderByChild('userId')
          .equalTo(userId)
          .get()
          .timeout(const Duration(seconds: 10));

      print('Snapshot exists: ${snapshot.exists}');
      
      if (snapshot.exists) {
        final doubtsMap = snapshot.value as Map<dynamic, dynamic>;
        final doubts = <DoubtModel>[];
        
        print('Found ${doubtsMap.length} doubts');

        doubtsMap.forEach((key, value) {
          try {
            final doubtData = Map<String, dynamic>.from(value);
            doubtData['id'] = key;
            doubts.add(DoubtModel.fromJson(doubtData));
          } catch (e) {
            print('Error parsing doubt $key: $e');
          }
        });

        // Sort by timestamp (newest first)
        doubts.sort((a, b) => b.timestamp.compareTo(a.timestamp));
        print('Returning ${doubts.length} parsed doubts');
        return doubts;
      }
      
      print('No doubts found for user');
      return [];
    } catch (e) {
      print('Error getting user doubts: $e');
      return [];
    }
  }

  // Update doubt status
  Future<bool> updateDoubtStatus(String doubtId, String status) async {
    try {
      await _database.child('doubts').child(doubtId).update({
        'status': status,
      });
      return true;
    } catch (e) {
      print('Error updating doubt status: $e');
      return false;
    }
  }

  // Add mentor response to doubt
  Future<bool> addMentorResponse(String doubtId, String response) async {
    try {
      await _database.child('doubts').child(doubtId).update({
        'mentorResponse': response,
        'responseTimestamp': DateTime.now().toIso8601String(),
        'status': 'Answered',
      });
      return true;
    } catch (e) {
      print('Error adding mentor response: $e');
      return false;
    }
  }

  // Listen to real-time updates for user doubts with error handling and notification monitoring
  Stream<List<DoubtModel>> getUserDoubtsStream(String userId) {
    print('Setting up real-time listener for user: $userId');
    
    return _database
        .child('doubts')
        .orderByChild('userId')
        .equalTo(userId)
        .onValue
        .map((event) {
      final doubts = <DoubtModel>[];
      
      try {
        if (event.snapshot.exists) {
          final doubtsMap = event.snapshot.value as Map<dynamic, dynamic>;
          print('Stream update: Found ${doubtsMap.length} doubts');
          
          doubtsMap.forEach((key, value) {
            try {
              final doubtData = Map<String, dynamic>.from(value);
              doubtData['id'] = key;
              final doubt = DoubtModel.fromJson(doubtData);
              doubts.add(doubt);
              
              // Check if this doubt just received a mentor response
              if (doubt.mentorResponse != null && doubt.status == 'Answered') {
                _checkAndSendMentorReplyNotification(doubt);
              }
            } catch (e) {
              print('Error parsing doubt $key in stream: $e');
            }
          });
        } else {
          print('Stream update: No doubts found');
        }
        
        // Sort by timestamp (newest first)
        doubts.sort((a, b) => b.timestamp.compareTo(a.timestamp));
        print('Stream returning ${doubts.length} doubts');
        return doubts;
      } catch (e) {
        print('Error in stream processing: $e');
        return doubts; // Return empty list on error
      }
    }).handleError((error) {
      print('Stream error: $error');
      return <DoubtModel>[]; // Return empty list on stream error
    });
  }

  // Check if we need to send a mentor reply notification
  void _checkAndSendMentorReplyNotification(DoubtModel doubt) {
    if (doubt.mentorResponse != null && 
        doubt.responseTimestamp != null &&
        doubt.status == 'Answered') {
      
      // Check if this is a recent response (within last 5 minutes)
      final now = DateTime.now();
      final responseTime = doubt.responseTimestamp!;
      final timeDiff = now.difference(responseTime).inMinutes;
      
      if (timeDiff <= 5) {
        print('🔔 Sending mentor reply notification for doubt: ${doubt.id}');
        
        _notificationService.sendMentorReplyNotification(
          doubtId: doubt.id,
          doubtTitle: doubt.title,
          studentId: doubt.userId,
          mentorId: doubt.mentorId,
          mentorName: doubt.mentorName,
          replyPreview: doubt.mentorResponse!.length > 100 
              ? '${doubt.mentorResponse!.substring(0, 100)}...'
              : doubt.mentorResponse!,
        );
      }
    }
  }

  // Delete a doubt
  Future<bool> deleteDoubt(String doubtId) async {
    try {
      print('🗑️ Attempting to delete doubt: $doubtId');
      
      await _database.child('doubts').child(doubtId).remove().timeout(
        const Duration(seconds: 10),
        onTimeout: () {
          print('⏰ Doubt deletion timeout');
          throw Exception('Request timeout. Please check your internet connection.');
        },
      );
      
      print('✅ Doubt deleted successfully: $doubtId');
      return true;
    } catch (e) {
      print('❌ Error deleting doubt: $e');
      if (e.toString().contains('permission') || e.toString().contains('PERMISSION_DENIED')) {
        throw Exception('Permission denied. Please check Firebase database rules.');
      } else if (e.toString().contains('timeout')) {
        throw Exception('Request timeout. Please check your internet connection.');
      } else {
        throw Exception('Failed to delete doubt: ${e.toString()}');
      }
    }
  }
}
