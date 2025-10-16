import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';

class SimpleFirebaseOTPService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  String? _currentPhoneNumber;

  // Get current user
  User? get currentUser => _auth.currentUser;
  bool get isSignedIn => _auth.currentUser != null;

  // Format phone number to international format
  String formatPhoneNumber(String phoneNumber) {
    // Remove any existing country code and formatting
    String cleaned = phoneNumber.replaceAll(RegExp(r'[^\d]'), '');
    
    // Remove leading +91 if present
    if (cleaned.startsWith('91') && cleaned.length == 12) {
      cleaned = cleaned.substring(2);
    }
    
    // Add +91 country code
    return '+91$cleaned';
  }

  // Validate phone number format
  bool isValidPhoneNumber(String phoneNumber) {
    String cleaned = phoneNumber.replaceAll(RegExp(r'[^\d]'), '');
    return cleaned.length == 10 && cleaned.startsWith(RegExp(r'[6-9]'));
  }

  // Send OTP - Simplified for web
  Future<String?> sendOTP({
    required String phoneNumber,
    required Function(String) onCodeSent,
    required Function(String) onError,
  }) async {
    try {
      _currentPhoneNumber = formatPhoneNumber(phoneNumber);
      
      if (kIsWeb) {
        // For web, we need to handle this differently
        // Create a simple verification flow
        final mockVerificationId = 'web_verification_${DateTime.now().millisecondsSinceEpoch}';
        
        // Simulate sending OTP (for demo purposes)
        await Future.delayed(const Duration(seconds: 1));
        
        onCodeSent(mockVerificationId);
        return mockVerificationId;
      } else {
        // Mobile implementation
        await _auth.verifyPhoneNumber(
          phoneNumber: _currentPhoneNumber!,
          verificationCompleted: (PhoneAuthCredential credential) async {
            await _auth.signInWithCredential(credential);
          },
          verificationFailed: (FirebaseAuthException e) {
            onError(_getErrorMessage(e));
          },
          codeSent: (String verificationId, int? resendToken) {
            onCodeSent(verificationId);
          },
          codeAutoRetrievalTimeout: (String verificationId) {
            // Auto-retrieval timeout
          },
        );
        
        return null;
      }
    } catch (e) {
      onError('Failed to send OTP: ${e.toString()}');
      return null;
    }
  }

  // Verify OTP
  Future<bool> verifyOTP({
    required String verificationId,
    required String otp,
    required Function() onSuccess,
    required Function(String) onError,
  }) async {
    try {
      if (kIsWeb) {
        // For web demo, simulate verification
        // In real implementation, you would use Firebase's web API
        await Future.delayed(const Duration(seconds: 1));
        
        // Simulate successful verification for demo
        // You can replace this with actual Firebase web verification
        if (otp.length == 6) {
          onSuccess();
          return true;
        } else {
          onError('Invalid OTP format');
          return false;
        }
      } else {
        // Mobile implementation
        final credential = PhoneAuthProvider.credential(
          verificationId: verificationId,
          smsCode: otp,
        );
        
        await _auth.signInWithCredential(credential);
        onSuccess();
        return true;
      }
    } on FirebaseAuthException catch (e) {
      onError(_getErrorMessage(e));
      return false;
    } catch (e) {
      onError('Verification failed: ${e.toString()}');
      return false;
    }
  }

  // Sign out
  Future<void> signOut() async {
    await _auth.signOut();
    _currentPhoneNumber = null;
  }

  // Get user-friendly error messages
  String _getErrorMessage(FirebaseAuthException e) {
    switch (e.code) {
      case 'invalid-phone-number':
        return 'Invalid phone number format. Use +91XXXXXXXXXX';
      case 'too-many-requests':
        return 'Too many requests. Please try again later';
      case 'app-not-authorized':
        return 'App not authorized for this operation';
      case 'billing-not-enabled':
        return 'Firebase billing not enabled. Please upgrade to Blaze plan';
      case 'invalid-verification-code':
        return 'Invalid OTP code. Please check and try again';
      case 'session-expired':
        return 'Verification session expired. Please request a new OTP';
      default:
        return 'Authentication error: ${e.message ?? 'Unknown error'}';
    }
  }
}