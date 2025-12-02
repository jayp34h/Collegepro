# Google Sign-In Authentication Fix

## 🚨 Current Issue
The error "An unexpected error occurred during Google sign-in" is caused by invalid OAuth client configuration.

## 🔧 Required Steps to Fix

### Step 1: Get Your SHA-1 Certificate Fingerprint
Run this command in your project directory:

```bash
cd android
./gradlew signingReport
```

Look for the SHA1 fingerprint under "Variant: debug" - it will look like:
```
SHA1: A1:B2:C3:D4:E5:F6:07:18:29:3A:4B:5C:6D:7E:8F:90:A1:B2:C3:D4
```

### Step 2: Configure Firebase Console
1. Go to [Firebase Console](https://console.firebase.google.com/)
2. Select your `collegepro-5affd` project
3. Go to **Project Settings** → **General** tab
4. Scroll to **Your apps** section
5. Click on your Android app
6. Add your SHA-1 fingerprint from Step 1
7. **Download the new `google-services.json`**

### Step 3: Replace Configuration Files
1. Replace `android/app/google-services.json` with the downloaded file
2. The new file will have proper OAuth client IDs

### Step 4: Update Web Client ID
1. In Firebase Console → **Authentication** → **Sign-in method**
2. Enable **Google** sign-in provider
3. Copy the **Web client ID**
4. Update `android/app/src/main/res/values/strings.xml`:
```xml
<string name="default_web_client_id">YOUR_ACTUAL_WEB_CLIENT_ID</string>
```

### Step 5: Clean and Rebuild
```bash
flutter clean
flutter pub get
flutter build apk
```

## 🎯 Alternative Quick Fix (For Testing)
If you can't access Firebase Console right now, you can temporarily disable Google Sign-In and use only email/password authentication by commenting out the Google Sign-In button in the login screen.

## 📱 Testing
After implementing the fix:
1. Try Google Sign-In - should work without errors
2. Check debug logs for successful authentication flow
3. User should be able to sign in and access the dashboard

The current placeholder OAuth client IDs in your `google-services.json` are not valid, which is why authentication fails.
