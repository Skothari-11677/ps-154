import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';

class FirebaseOTPService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  String? _verificationId;

  // Initialize Firebase Auth for web with reCAPTCHA
  Future<void> initializeAuth() async {
    if (kIsWeb) {
      // Set app verification disabled for testing (remove in production)
      await _auth.setSettings(
        appVerificationDisabledForTesting: false, // Set to false for production
        userAccessGroup: null,
      );
    }
  }

  // Send OTP to phone number with reCAPTCHA verification
  Future<String?> verifyPhoneNumber({
    required String phoneNumber,
    required Function(String) onCodeSent,
    required Function(String) onError,
  }) async {
    try {
      // Ensure Firebase Auth is initialized
      await initializeAuth();

      if (kIsWeb) {
        // For web, use ConfirmationResult
        final confirmationResult = await _auth.signInWithPhoneNumber(phoneNumber);
        _verificationId = confirmationResult.verificationId;
        onCodeSent(_verificationId!);
        return _verificationId;
      } else {
        // For mobile platforms
        await _auth.verifyPhoneNumber(
          phoneNumber: phoneNumber,
          verificationCompleted: (PhoneAuthCredential credential) async {
            // Auto-verification completed (Android only)
            try {
              await _auth.signInWithCredential(credential);
              onCodeSent('auto-verified');
            } catch (e) {
              onError('Auto-verification failed: $e');
            }
          },
          verificationFailed: (FirebaseAuthException e) {
            String errorMessage = _handlePhoneAuthError(e);
            onError(errorMessage);
          },
          codeSent: (String verificationId, int? resendToken) {
            _verificationId = verificationId;
            onCodeSent(verificationId);
          },
          codeAutoRetrievalTimeout: (String verificationId) {
            _verificationId = verificationId;
          },
          timeout: const Duration(seconds: 60),
        );
        return _verificationId;
      }
    } catch (e) {
      onError('Failed to send OTP: ${e.toString()}');
      return null;
    }
  }

  // Verify OTP code
  Future<bool> verifyOTP({
    required String verificationId,
    required String otp,
    required Function() onSuccess,
    required Function(String) onError,
  }) async {
    try {
      UserCredential? userCredential;

      if (kIsWeb) {
        // For web, get the ConfirmationResult and confirm with OTP
        final confirmationResult = await _auth.signInWithPhoneNumber(
          formatPhoneNumber(_getPhoneNumberFromVerificationId(verificationId)),
        );
        userCredential = await confirmationResult.confirm(otp);
      } else {
        // For mobile platforms
        final credential = PhoneAuthProvider.credential(
          verificationId: verificationId,
          smsCode: otp,
        );
        userCredential = await _auth.signInWithCredential(credential);
      }

      if (userCredential.user != null) {
        onSuccess();
        return true;
      } else {
        onError('Verification failed: No user returned');
        return false;
      }
    } on FirebaseAuthException catch (e) {
      // Use a logging framework or handle error appropriately in production
      onError(_handlePhoneAuthError(e));
      return false;
    } catch (e) {
      onError('Verification failed: ${e.toString()}');
      return false;
    }
  }

  // Improved verification for web with stored confirmation result
  Future<bool> verifyWebOTP({
    required String phoneNumber,
    required String otp,
    required Function() onSuccess,
    required Function(String) onError,
  }) async {
    try {
      final confirmationResult = await _auth.signInWithPhoneNumber(phoneNumber);
      final userCredential = await confirmationResult.confirm(otp);
      
      if (userCredential.user != null) {
        onSuccess();
        return true;
      } else {
        onError('Verification failed');
        return false;
      }
    } on FirebaseAuthException catch (e) {
      onError(_handlePhoneAuthError(e));
      return false;
    } catch (e) {
      onError('Verification failed: ${e.toString()}');
      return false;
    }
  }

  // Sign out current user
  Future<void> signOut() async {
    await _auth.signOut();
  }

  // Get current user
  User? get currentUser => _auth.currentUser;

  // Check if user is signed in
  bool get isSignedIn => _auth.currentUser != null;

  // Format phone number to E.164 format
  String formatPhoneNumber(String phoneNumber, {String countryCode = '+91'}) {
    String cleaned = phoneNumber.replaceAll(RegExp(r'[^\d]'), '');
    
    if (countryCode == '+91') {
      if (cleaned.startsWith('0')) {
        cleaned = cleaned.substring(1);
      }
      
      if (cleaned.length == 10) {
        return '+91$cleaned';
      }
    }
    
    if (cleaned.startsWith('91') && cleaned.length == 12) {
      return '+$cleaned';
    }
    
    return '$countryCode$cleaned';
  }

  // Validate phone number format
  bool isValidPhoneNumber(String phoneNumber) {
    String cleaned = phoneNumber.replaceAll(RegExp(r'[^\d]'), '');
    
    if (cleaned.length == 10) {
      return RegExp(r'^[6-9]\d{9}$').hasMatch(cleaned);
    }
    
    if (cleaned.length == 12 && cleaned.startsWith('91')) {
      String mobileNumber = cleaned.substring(2);
      return RegExp(r'^[6-9]\d{9}$').hasMatch(mobileNumber);
    }
    
    return false;
  }

  // Helper method to get phone number from verification ID (for web)
  String _getPhoneNumberFromVerificationId(String verificationId) {
    // In a real implementation, you would store the phone number
    // associated with the verification ID. For now, this is a placeholder.
    // You should modify your implementation to store this mapping.
    return ''; // This needs to be implemented based on your storage strategy
  }

  // Handle Firebase Auth errors for phone authentication
  String _handlePhoneAuthError(FirebaseAuthException e) {
    // Use a logging framework or handle error appropriately in production
    
    switch (e.code) {
      case 'invalid-phone-number':
        return 'The phone number format is invalid. Please use +91XXXXXXXXXX format.';
      case 'too-many-requests':
        return 'Too many OTP requests. Please wait before trying again.';
      case 'app-not-authorized':
        return 'App not authorized. Please check Firebase configuration.';
      case 'captcha-check-failed':
        return 'reCAPTCHA verification failed. Please try again.';
      case 'web-context-cancelled':
        return 'Verification process was cancelled.';
      case 'web-context-expired':
        return 'Verification session expired. Please try again.';
      case 'invalid-verification-code':
        return 'Invalid OTP code. Please check and try again.';
      case 'invalid-verification-id':
        return 'Invalid verification session. Please restart the process.';
      case 'session-expired':
        return 'Verification session expired. Please request a new OTP.';
      case 'quota-exceeded':
        return 'SMS quota exceeded. Please try again later.';
      case 'billing-not-enabled':
        return 'Firebase billing is not enabled. Please upgrade your Firebase plan to use Phone Authentication.';
      case 'auth/network-request-failed':
        return 'Network error occurred. Please check your connection and try again.';
      case 'auth/internal-error':
        return 'An internal error occurred. Please try again later.';
      default:
        return 'Phone verification failed: ${e.message ?? e.code}';
    }
  }

  // Configure Firebase Auth settings for web
  Future<void> configureAuthSettings({bool testMode = false}) async {
    if (kIsWeb) {
      try {
        await _auth.setSettings(
          appVerificationDisabledForTesting: testMode,
          userAccessGroup: null,
        );
      } catch (e) {
        // Use a logging framework or handle error appropriately in production
      }
    }
  }
}