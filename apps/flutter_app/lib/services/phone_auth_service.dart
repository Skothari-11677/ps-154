import 'package:firebase_auth/firebase_auth.dart';

class PhoneAuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  String? _verificationId;

  // Send OTP to phone number
  Future<void> verifyPhoneNumber({
    required String phoneNumber,
    required Function(String verificationId) onCodeSent,
    required Function(String error) onError,
    Function(PhoneAuthCredential credential)? onVerificationCompleted,
  }) async {
    try {
      await _auth.verifyPhoneNumber(
        phoneNumber: phoneNumber,
        verificationCompleted: (PhoneAuthCredential credential) async {
          // Auto-verification completed (Android only)
          if (onVerificationCompleted != null) {
            onVerificationCompleted(credential);
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
    } catch (e) {
      onError('Failed to send OTP: $e');
    }
  }

  // Verify OTP code
  Future<PhoneAuthCredential?> verifyOTP({
    required String verificationId,
    required String smsCode,
  }) async {
    try {
      final credential = PhoneAuthProvider.credential(
        verificationId: verificationId,
        smsCode: smsCode,
      );
      return credential;
    } catch (e) {
      throw 'Invalid OTP code: $e';
    }
  }

  // Link phone credential with existing user
  Future<User?> linkPhoneWithCurrentUser(PhoneAuthCredential credential) async {
    try {
      final user = _auth.currentUser;
      if (user != null) {
        final userCredential = await user.linkWithCredential(credential);
        return userCredential.user;
      }
      return null;
    } on FirebaseAuthException catch (e) {
      throw _handlePhoneAuthError(e);
    } catch (e) {
      throw 'Failed to link phone number: $e';
    }
  }

  // Sign in with phone credential (for phone-only authentication)
  Future<UserCredential?> signInWithPhone(PhoneAuthCredential credential) async {
    try {
      final userCredential = await _auth.signInWithCredential(credential);
      return userCredential;
    } on FirebaseAuthException catch (e) {
      throw _handlePhoneAuthError(e);
    } catch (e) {
      throw 'Failed to sign in with phone: $e';
    }
  }

  // Update phone number for existing user
  Future<void> updatePhoneNumber(PhoneAuthCredential credential) async {
    try {
      final user = _auth.currentUser;
      if (user != null) {
        await user.updatePhoneNumber(credential);
      } else {
        throw 'No authenticated user found';
      }
    } on FirebaseAuthException catch (e) {
      throw _handlePhoneAuthError(e);
    } catch (e) {
      throw 'Failed to update phone number: $e';
    }
  }

  // Get current verification ID
  String? get verificationId => _verificationId;

  // Handle Firebase Auth errors for phone authentication
  String _handlePhoneAuthError(FirebaseAuthException e) {
    switch (e.code) {
      case 'invalid-phone-number':
        return 'The phone number format is invalid. Please check and try again.';
      case 'too-many-requests':
        return 'Too many OTP requests. Please wait before trying again.';
      case 'app-not-authorized':
        return 'App not authorized to use Firebase Authentication.';
      case 'captcha-check-failed':
        return 'reCAPTCHA verification failed. Please try again.';
      case 'web-context-cancelled':
        return 'Verification process was cancelled.';
      case 'web-context-expired':
        return 'Verification session expired. Please try again.';
      case 'invalid-verification-code':
        return 'Invalid verification code. Please check and try again.';
      case 'invalid-verification-id':
        return 'Invalid verification session. Please restart the process.';
      case 'session-expired':
        return 'Verification session expired. Please request a new OTP.';
      case 'quota-exceeded':
        return 'SMS quota exceeded. Please try again later.';
      case 'credential-already-in-use':
        return 'This phone number is already linked to another account.';
      case 'provider-already-linked':
        return 'Phone number is already linked to this account.';
      default:
        return 'Phone verification failed: ${e.message ?? 'Unknown error'}';
    }
  }

  // Format phone number to E.164 format
  static String formatPhoneNumber(String phoneNumber, {String countryCode = '+91'}) {
    // Remove any non-digit characters
    String cleaned = phoneNumber.replaceAll(RegExp(r'[^\d]'), '');
    
    // Handle Indian phone numbers
    if (countryCode == '+91') {
      // Remove leading 0 if present
      if (cleaned.startsWith('0')) {
        cleaned = cleaned.substring(1);
      }
      
      // Indian mobile numbers should be 10 digits
      if (cleaned.length == 10) {
        return '+91$cleaned';
      }
    }
    
    // If already has country code, return as is
    if (cleaned.startsWith('91') && cleaned.length == 12) {
      return '+$cleaned';
    }
    
    return '$countryCode$cleaned';
  }

  // Validate phone number format
  static bool isValidPhoneNumber(String phoneNumber) {
    // Remove any non-digit characters
    String cleaned = phoneNumber.replaceAll(RegExp(r'[^\d]'), '');
    
    // Indian mobile number validation
    if (cleaned.length == 10) {
      // Indian mobile numbers start with 6, 7, 8, or 9
      return RegExp(r'^[6-9]\d{9}$').hasMatch(cleaned);
    }
    
    // With country code (91)
    if (cleaned.length == 12 && cleaned.startsWith('91')) {
      String mobileNumber = cleaned.substring(2);
      return RegExp(r'^[6-9]\d{9}$').hasMatch(mobileNumber);
    }
    
    return false;
  }
}