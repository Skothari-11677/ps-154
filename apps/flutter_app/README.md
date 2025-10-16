# PCR/PoA Beneficiary Portal

A Flutter application for beneficiaries under the Protection of Civil Rights (PCR) Act, 1955 and the Scheduled Castes and the Scheduled Tribes (Prevention of Atrocities) Act, 1989.

## Features

- **Firebase Authentication**: Secure login system with email/password
- **User Dashboard**: Clean, government-standard interface for beneficiaries
- **Responsive Design**: Works on mobile devices and tablets
- **Security**: Government-grade security with Firebase backend

## Current Implementation

This initial version includes:

✅ **Login Screen**
- Email/password authentication
- Form validation
- Password visibility toggle
- Forgot password functionality
- Professional government-style UI

✅ **Dashboard Screen**
- Welcome message with user information
- Account verification status
- Coming soon placeholder for future features
- Secure logout functionality

✅ **Authentication Service**
- Firebase Auth integration
- Error handling for common auth scenarios
- Session management

## Getting Started

### Prerequisites

- Flutter SDK (latest stable version)
- Dart SDK
- Firebase project (for production use)

### Installation

1. **Install dependencies**
   ```bash
   flutter pub get
   ```

2. **Firebase Setup** (Required for production)
   
   To fully configure Firebase authentication:
   
   a. Create a Firebase project at [Firebase Console](https://console.firebase.google.com/)
   
   b. Add your Flutter app to the Firebase project
   
   c. Download configuration files:
      - `google-services.json` (for Android) → Place in `android/app/`
      - `GoogleService-Info.plist` (for iOS) → Place in `ios/Runner/`
   
   d. Run Firebase CLI setup:
   ```bash
   flutter pub global activate flutterfire_cli
   flutterfire configure
   ```
   
   e. Enable Authentication in Firebase Console:
      - Go to Authentication > Sign-in method
      - Enable "Email/Password" provider

3. **Run the application**
   ```bash
   flutter run
   ```

### Demo Mode

The app currently runs in demo mode without Firebase configuration. To test:

- The login screen is fully functional (UI-wise)
- Firebase authentication will not work until properly configured
- The dashboard shows a "coming soon" message

### Project Structure

```
lib/
├── main.dart                 # App entry point with Firebase initialization
├── screens/
│   ├── login_screen.dart     # Login page with authentication
│   └── dashboard_screen.dart # Main dashboard (blank/coming soon)
└── services/
    └── auth_service.dart     # Firebase authentication service
```

## Future Development

The app is designed to be expanded with:

- **Benefit Management**: Apply for and track benefits
- **Document Upload**: Secure document submission
- **Status Tracking**: Real-time status updates
- **Grievance System**: Report issues and track resolution
- **Multi-language Support**: Regional language support
- **Offline Capabilities**: Basic functionality without internet

## Security Features

- **Firebase Authentication**: Industry-standard authentication
- **Data Encryption**: All data transmitted securely
- **Session Management**: Automatic logout and session handling
- **Input Validation**: Comprehensive form validation
- **Error Handling**: Secure error messages without sensitive information

## Government Compliance

This app is designed to meet:
- Government of India security standards
- Accessibility guidelines (WCAG 2.1)
- Data protection requirements
- Digital India initiative compliance

---

**Disclaimer**: This is a prototype application for demonstration purposes. Production deployment requires proper Firebase configuration and security reviews.
