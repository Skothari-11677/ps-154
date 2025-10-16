import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class UserService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Create user profile in Firestore
  Future<void> createUserProfile({
    required String userId,
    required String name,
    required String email,
    required String aadhaarNumber,
    String? phoneNumber,
  }) async {
    try {
      final profileData = {
        'name': name,
        'email': email,
        'aadhaarNumber': aadhaarNumber,
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
        'isVerified': false,
        'profileComplete': true,
      };
      
      if (phoneNumber != null) {
        profileData['phoneNumber'] = phoneNumber;
        profileData['phoneVerified'] = true; // Phone was verified during OTP process
      }
      
      await _firestore.collection('users').doc(userId).set(profileData);
    } catch (e) {
      throw 'Failed to create user profile: $e';
    }
  }

  // Get user profile from Firestore
  Future<Map<String, dynamic>?> getUserProfile(String userId) async {
    try {
      final doc = await _firestore.collection('users').doc(userId).get();
      if (doc.exists) {
        return doc.data();
      }
      return null;
    } catch (e) {
      throw 'Failed to get user profile: $e';
    }
  }

  // Update user profile
  Future<void> updateUserProfile({
    required String userId,
    Map<String, dynamic>? updates,
  }) async {
    try {
      if (updates != null && updates.isNotEmpty) {
        await _firestore.collection('users').doc(userId).update({
          ...updates,
          'updatedAt': FieldValue.serverTimestamp(),
        });
      }
    } catch (e) {
      throw 'Failed to update user profile: $e';
    }
  }

  // Check if Aadhaar number is already registered
  Future<bool> isAadhaarRegistered(String aadhaarNumber) async {
    try {
      final querySnapshot = await _firestore
          .collection('users')
          .where('aadhaarNumber', isEqualTo: aadhaarNumber)
          .limit(1)
          .get();
      
      return querySnapshot.docs.isNotEmpty;
    } catch (e) {
      throw 'Failed to check Aadhaar registration: $e';
    }
  }

  // Get current user profile
  Future<Map<String, dynamic>?> getCurrentUserProfile() async {
    final user = _auth.currentUser;
    if (user != null) {
      return await getUserProfile(user.uid);
    }
    return null;
  }

  // Delete user profile (for account deletion)
  Future<void> deleteUserProfile(String userId) async {
    try {
      await _firestore.collection('users').doc(userId).delete();
    } catch (e) {
      throw 'Failed to delete user profile: $e';
    }
  }
}