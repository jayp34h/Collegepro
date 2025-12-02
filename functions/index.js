const functions = require('firebase-functions');
const admin = require('firebase-admin');

admin.initializeApp();

// Send push notification when a new notification is added to Firebase
exports.sendPushNotification = functions.database.ref('/notifications/{userId}/{notificationId}')
  .onCreate(async (snapshot, context) => {
    const { userId, notificationId } = context.params;
    const notification = snapshot.val();
    
    try {
      console.log(`📱 Sending push notification to user: ${userId}`);
      
      // Get user's FCM token
      const tokenSnapshot = await admin.database()
        .ref(`user_fcm_tokens/${userId}`)
        .once('value');
      
      if (!tokenSnapshot.exists()) {
        console.log(`❌ No FCM token found for user: ${userId}`);
        return null;
      }
      
      const tokenData = tokenSnapshot.val();
      const fcmToken = tokenData.token;
      
      // Create FCM message
      const message = {
        token: fcmToken,
        notification: {
          title: notification.title,
          body: notification.message,
        },
        data: {
          notificationId: notificationId,
          type: notification.type,
          actionUrl: notification.actionUrl || '',
          ...notification.data
        },
        android: {
          notification: {
            icon: 'ic_notification',
            color: '#7C3AED',
            channelId: getChannelId(notification.type),
            priority: 'high',
            defaultSound: true,
          },
        },
        apns: {
          payload: {
            aps: {
              badge: 1,
              sound: 'default',
              'content-available': 1,
            },
          },
        },
      };
      
      // Send the message
      const response = await admin.messaging().send(message);
      console.log(`✅ Push notification sent successfully: ${response}`);
      
      return response;
    } catch (error) {
      console.error(`❌ Error sending push notification:`, error);
      return null;
    }
  });

// Send push notification when mentor replies to doubt
exports.sendMentorReplyNotification = functions.database.ref('/doubts/{doubtId}')
  .onUpdate(async (change, context) => {
    const { doubtId } = context.params;
    const before = change.before.val();
    const after = change.after.val();
    
    // Check if mentorResponse was added
    if (!before.mentorResponse && after.mentorResponse && after.status === 'Answered') {
      try {
        console.log(`🎓 Mentor replied to doubt: ${doubtId}`);
        
        // Get student's FCM token
        const tokenSnapshot = await admin.database()
          .ref(`user_fcm_tokens/${after.userId}`)
          .once('value');
        
        if (!tokenSnapshot.exists()) {
          console.log(`❌ No FCM token found for student: ${after.userId}`);
          return null;
        }
        
        const tokenData = tokenSnapshot.val();
        const fcmToken = tokenData.token;
        
        // Create notification message
        const message = {
          token: fcmToken,
          notification: {
            title: '🎓 Mentor Replied!',
            body: `${after.mentorName} replied to your doubt: "${after.title}"`,
          },
          data: {
            type: 'mentor_reply',
            doubtId: doubtId,
            mentorId: after.mentorId,
            actionUrl: `/mentor/doubts/${doubtId}`,
          },
          android: {
            notification: {
              icon: 'ic_notification',
              color: '#7C3AED',
              channelId: 'doubt_notifications',
              priority: 'high',
              defaultSound: true,
            },
          },
          apns: {
            payload: {
              aps: {
                badge: 1,
                sound: 'default',
                'content-available': 1,
              },
            },
          },
        };
        
        // Send the message
        const response = await admin.messaging().send(message);
        console.log(`✅ Mentor reply notification sent: ${response}`);
        
        return response;
      } catch (error) {
        console.error(`❌ Error sending mentor reply notification:`, error);
        return null;
      }
    }
    
    return null;
  });

// Send push notification when someone answers community doubt
exports.sendCommunityDoubtAnswerNotification = functions.database.ref('/doubt_answers/{answerId}')
  .onCreate(async (snapshot, context) => {
    const { answerId } = context.params;
    const answer = snapshot.val();
    
    try {
      console.log(`💡 New answer posted for doubt: ${answer.doubtId}`);
      
      // Get the original doubt to find the author
      const doubtSnapshot = await admin.database()
        .ref(`community_doubts/${answer.doubtId}`)
        .once('value');
      
      if (!doubtSnapshot.exists()) {
        console.log(`❌ Doubt not found: ${answer.doubtId}`);
        return null;
      }
      
      const doubt = doubtSnapshot.val();
      
      // Don't send notification if answering own doubt
      if (doubt.userId === answer.userId) {
        return null;
      }
      
      // Get doubt author's FCM token
      const tokenSnapshot = await admin.database()
        .ref(`user_fcm_tokens/${doubt.userId}`)
        .once('value');
      
      if (!tokenSnapshot.exists()) {
        console.log(`❌ No FCM token found for doubt author: ${doubt.userId}`);
        return null;
      }
      
      const tokenData = tokenSnapshot.val();
      const fcmToken = tokenData.token;
      
      // Create notification message
      const message = {
        token: fcmToken,
        notification: {
          title: '💡 Your Doubt Got Answered!',
          body: `${answer.userName} answered your doubt: "${doubt.title}"`,
        },
        data: {
          type: 'doubt_answered',
          doubtId: answer.doubtId,
          answerId: answerId,
          actionUrl: `/community-doubts/details/${answer.doubtId}#answer-${answerId}`,
        },
        android: {
          notification: {
            icon: 'ic_notification',
            color: '#7C3AED',
            channelId: 'doubt_notifications',
            priority: 'high',
            defaultSound: true,
          },
        },
        apns: {
          payload: {
            aps: {
              badge: 1,
              sound: 'default',
              'content-available': 1,
            },
          },
        },
      };
      
      // Send the message
      const response = await admin.messaging().send(message);
      console.log(`✅ Community doubt answer notification sent: ${response}`);
      
      return response;
    } catch (error) {
      console.error(`❌ Error sending community doubt answer notification:`, error);
      return null;
    }
  });

// Send push notification when someone replies to feedback
exports.sendFeedbackReplyNotification = functions.database.ref('/project_feedbacks/{projectId}/{feedbackId}/replies/{replyId}')
  .onCreate(async (snapshot, context) => {
    const { projectId, feedbackId, replyId } = context.params;
    const reply = snapshot.val();
    
    try {
      console.log(`💬 New reply posted for feedback: ${feedbackId}`);
      
      // Get the original feedback to find the author
      const feedbackSnapshot = await admin.database()
        .ref(`project_feedbacks/${projectId}/${feedbackId}`)
        .once('value');
      
      if (!feedbackSnapshot.exists()) {
        console.log(`❌ Feedback not found: ${feedbackId}`);
        return null;
      }
      
      const feedback = feedbackSnapshot.val();
      
      // Don't send notification if replying to own feedback
      if (feedback.userId === reply.userId) {
        return null;
      }
      
      // Get feedback author's FCM token
      const tokenSnapshot = await admin.database()
        .ref(`user_fcm_tokens/${feedback.userId}`)
        .once('value');
      
      if (!tokenSnapshot.exists()) {
        console.log(`❌ No FCM token found for feedback author: ${feedback.userId}`);
        return null;
      }
      
      const tokenData = tokenSnapshot.val();
      const fcmToken = tokenData.token;
      
      // Get project title (you might need to adjust this based on your data structure)
      const projectSnapshot = await admin.database()
        .ref(`projects/${projectId}`)
        .once('value');
      
      const projectTitle = projectSnapshot.exists() ? 
        projectSnapshot.val().title || 'Your Project' : 'Your Project';
      
      // Create notification message
      const message = {
        token: fcmToken,
        notification: {
          title: '💬 Reply to Your Feedback!',
          body: `${reply.userName} replied to your feedback on "${projectTitle}"`,
        },
        data: {
          type: 'feedback_reply',
          projectId: projectId,
          feedbackId: feedbackId,
          replyId: replyId,
          actionUrl: `/project-details/${projectId}#feedback-${feedbackId}-reply-${replyId}`,
        },
        android: {
          notification: {
            icon: 'ic_notification',
            color: '#7C3AED',
            channelId: 'feedback_notifications',
            priority: 'high',
            defaultSound: true,
          },
        },
        apns: {
          payload: {
            aps: {
              badge: 1,
              sound: 'default',
              'content-available': 1,
            },
          },
        },
      };
      
      // Send the message
      const response = await admin.messaging().send(message);
      console.log(`✅ Feedback reply notification sent: ${response}`);
      
      return response;
    } catch (error) {
      console.error(`❌ Error sending feedback reply notification:`, error);
      return null;
    }
  });

// Helper function to get appropriate channel ID
function getChannelId(notificationType) {
  switch (notificationType) {
    case 'doubtPosted':
    case 'doubtAnswered':
    case 'mentor_reply':
      return 'doubt_notifications';
    case 'feedbackReceived':
    case 'feedbackReply':
      return 'feedback_notifications';
    default:
      return 'general_notifications';
  }
}
