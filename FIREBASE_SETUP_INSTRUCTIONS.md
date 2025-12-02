# 🔥 URGENT: Firebase Database Rules Update Required

## ❌ Current Issue
**PERMISSION_DENIED** error when posting/fetching Community Doubts because Firebase Console rules are restrictive.

## ✅ Solution Steps

### 1. Open Firebase Console
- Go to [Firebase Console](https://console.firebase.google.com)
- Select your CollegePro project

### 2. Navigate to Realtime Database Rules
- Click "Realtime Database" in left sidebar
- Click "Rules" tab

### 3. Replace Current Rules
Copy the **ENTIRE CONTENT** from `database-rules.json` and paste it in Firebase Console:

```json
{
  "rules": {
    ".read": false,
    ".write": false,
    
    "users": {
      "$uid": {
        ".read": "auth != null && auth.uid == $uid",
        ".write": "auth != null && auth.uid == $uid"
      }
    },
    
    "user_profiles": {
      "$uid": {
        ".read": "auth != null && (auth.uid == $uid || root.child('user_profiles').child($uid).child('privacy').child('profileVisible').val() == true)",
        ".write": "auth != null && auth.uid == $uid"
      }
    },
    
    "user_preferences": {
      "$uid": {
        ".read": "auth != null && auth.uid == $uid",
        ".write": "auth != null && auth.uid == $uid"
      }
    },
    
    "user_projects": {
      "$uid": {
        ".read": "auth != null && auth.uid == $uid",
        ".write": "auth != null && auth.uid == $uid"
      }
    },
    
    "user_activities": {
      "$uid": {
        ".read": "auth != null && auth.uid == $uid",
        ".write": "auth != null && auth.uid == $uid"
      }
    },
    
    "test": {
      ".read": "auth != null",
      ".write": "auth != null"
    },
    
    "community_doubts": {
      ".read": "auth != null",
      ".write": "auth != null",
      ".indexOn": ["timestamp", "subject", "difficulty", "isResolved", "authorId"]
    },
    
    "community_answers": {
      ".read": "auth != null",
      ".write": "auth != null",
      ".indexOn": ["timestamp", "doubtId", "authorId"]
    },
    
    "user_progress": {
      "$uid": {
        ".read": "auth != null",
        ".write": "auth != null && auth.uid == $uid"
      }
    },
    
    "leaderboard": {
      ".read": "auth != null",
      ".write": false,
      ".indexOn": ["totalPoints", "level"]
    }
  }
}
```

### 4. Publish Rules
- Click **"Publish"** button
- Wait for confirmation message

### 5. Verify Fix
- Restart your Flutter app
- Try posting a doubt
- Check if existing doubts load properly

## 🎯 What This Fixes
- ✅ Permission denied errors
- ✅ Index not defined warnings  
- ✅ Posting new doubts
- ✅ Fetching existing doubts
- ✅ Filtering and searching
- ✅ Leaderboard functionality

## ⚠️ Important Notes
- **MUST** be done in Firebase Console, not just local file
- Rules take effect immediately after publishing
- All Community Doubts features depend on this fix
