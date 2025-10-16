# Firebase Setup Guide for PCR/PoA Beneficiary App

## Overview
This guide will walk you through setting up Firebase for your Flutter application to enable authentication and other Firebase services.

## Prerequisites
- Flutter SDK installed
- Google account
- Firebase CLI (optional but recommended)

## Step-by-Step Setup

### 1. Create Firebase Project

1. **Go to Firebase Console**
   - Visit: https://console.firebase.google.com/
   - Sign in with your Google account

2. **Create New Project**
   - Click "Add project"
   - Enter project name (e.g., "pcr-poa-beneficiary-app")
   - Choose whether to enable Google Analytics (recommended)
   - Click "Create project"

### 2. Add Flutter App to Firebase Project

#### For Android:

1. **In Firebase Console:**
   - Click "Add app" and select Android icon
   - Enter package name: `com.example.pcr_poa_beneficiary_app`
   - Enter app nickname: "PCR PoA Beneficiary App"
   - Click "Register app"

2. **Download google-services.json:**
   - Download the `google-services.json` file
   - Place it in: `android/app/google-services.json`

3. **Add Firebase SDK to Android:**
   - Open `android/build.gradle` and add:
   ```gradle
   buildscript {
       dependencies {
           classpath 'com.google.gms:google-services:4.3.15'
       }
   }
   ```
   
   - Open `android/app/build.gradle` and add:
   ```gradle
   apply plugin: 'com.google.gms.google-services'
   
   dependencies {
       implementation platform('com.google.firebase:firebase-bom:32.2.2')
   }
   ```

#### For iOS:

1. **In Firebase Console:**
   - Click "Add app" and select iOS icon
   - Enter bundle ID: `com.example.pcrPoaBeneficiaryApp`
   - Enter app nickname: "PCR PoA Beneficiary App iOS"
   - Click "Register app"

2. **Download GoogleService-Info.plist:**
   - Download the `GoogleService-Info.plist` file
   - Place it in: `ios/Runner/GoogleService-Info.plist`

#### For Web:

1. **In Firebase Console:**
   - Click "Add app" and select Web icon
   - Enter app nickname: "PCR PoA Beneficiary Web"
   - Click "Register app"
   - Copy the Firebase config object

### 3. Get Firebase Configuration

After adding your platforms, you'll get configuration details. Update the `lib/firebase_options.dart` file with your actual values:

**From Firebase Console > Project Settings > Your apps > SDK setup and configuration**

Replace the placeholder values in `firebase_options.dart`:

```dart
// Replace YOUR_PROJECT_ID with your actual Firebase project ID
// Replace YOUR_API_KEY with your actual API key
// Replace YOUR_APP_ID with your actual app ID
// etc.
```

### 4. Enable Authentication

1. **In Firebase Console:**
   - Go to "Authentication" in left sidebar
   - Click "Get started"
   - Go to "Sign-in method" tab
   - Click on "Email/Password"
   - Enable "Email/Password" authentication
   - Click "Save"

### 5. Configure Security Rules (Optional)

For enhanced security, you can set up Firestore security rules:

1. Go to "Firestore Database" > "Rules"
2. Set appropriate rules based on your requirements

### 6. Test the Setup

1. **Run the app:**
   ```bash
   flutter run
   ```

2. **Create a test user:**
   - In Firebase Console > Authentication > Users
   - Click "Add user"
   - Enter email and password
   - Use these credentials to test login

### 7. Alternative: Using FlutterFire CLI (Recommended)

If you have Firebase CLI installed and configured:

1. **Login to Firebase:**
   ```bash
   firebase login
   ```

2. **Configure FlutterFire:**
   ```bash
   flutterfire configure
   ```

3. **Follow the interactive prompts** to:
   - Select or create Firebase project
   - Choose platforms (Android, iOS, Web)
   - Automatically generate `firebase_options.dart`

## Configuration Files Location

After setup, you should have these files:

```
android/app/google-services.json          # Android config
ios/Runner/GoogleService-Info.plist       # iOS config
lib/firebase_options.dart                 # Flutter config
```

## Troubleshooting

### Common Issues:

1. **"No Firebase App '[DEFAULT]' has been created"**
   - Ensure `Firebase.initializeApp()` is called in `main()`
   - Check that config files are in correct locations

2. **Build errors on Android:**
   - Verify `google-services.json` is in `android/app/`
   - Check Gradle plugin versions are compatible

3. **iOS build errors:**
   - Ensure `GoogleService-Info.plist` is added to Xcode project
   - Verify bundle ID matches Firebase configuration

4. **Authentication not working:**
   - Check that Email/Password is enabled in Firebase Console
   - Verify network connectivity
   - Check Firebase project is active

### Debug Steps:

1. **Check Firebase initialization:**
   ```dart
   // Add this to main() for debugging
   print('Firebase apps: ${Firebase.apps}');
   ```

2. **Enable Firebase debug logging:**
   ```bash
   flutter run --dart-define=FLUTTER_FIREBASE_DEBUG=true
   ```

## Security Considerations

1. **Never commit sensitive keys** to version control
2. **Use environment variables** for sensitive configuration
3. **Set up proper security rules** in Firebase Console
4. **Enable App Check** for production apps
5. **Use Firebase Security Rules** to protect data

## Next Steps

After Firebase is configured:

1. **Test authentication** with the login screen
2. **Add additional Firebase services** as needed:
   - Firestore for data storage
   - Cloud Storage for file uploads
   - Cloud Functions for backend logic
   - Cloud Messaging for notifications

## Resources

- [Firebase Documentation](https://firebase.google.com/docs)
- [FlutterFire Documentation](https://firebase.flutter.dev/)
- [Firebase Console](https://console.firebase.google.com/)
- [Firebase CLI Documentation](https://firebase.google.com/docs/cli)

---

**Note:** This app is configured to work without Firebase initially (demo mode). Follow this guide to enable full Firebase functionality.