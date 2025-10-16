# User Registration Guide - PCR/PoA Beneficiary Portal

## Overview
This guide explains the new user registration system with Aadhaar integration for first-time users of the PCR/PoA Beneficiary Portal.

## New Features Added

### ✅ **Registration Screen**
- **Aadhaar-based Registration**: Users must provide valid 12-digit Aadhaar number
- **Complete Profile Setup**: Full name, email, password, and Aadhaar verification
- **Advanced Validation**: Implements Verhoeff algorithm for Aadhaar validation
- **Duplicate Prevention**: Prevents multiple registrations with same Aadhaar number

### ✅ **Enhanced Login Screen**
- **Registration Button**: "Create New Account" button for new users
- **Clear Navigation**: Easy access to registration for first-time users
- **User-friendly Design**: Government portal standard interface

### ✅ **Data Storage Integration**
- **Firestore Integration**: Secure storage of user profile data
- **User Profile Management**: Complete user information with Aadhaar linking
- **Data Validation**: Server-side duplicate checking and validation

## How to Use

### For New Users (Registration):

1. **Access Registration**:
   - Open the PCR/PoA Beneficiary Portal
   - On the login screen, click "Create New Account"

2. **Fill Registration Form**:
   - **Full Name**: Enter your complete legal name
   - **Aadhaar Number**: Enter your 12-digit Aadhaar number
   - **Email Address**: Provide a valid email for communication
   - **Password**: Create a strong password (minimum 6 characters)
   - **Confirm Password**: Re-enter password for confirmation

3. **Validation Process**:
   - System validates Aadhaar number using Verhoeff algorithm
   - Checks for duplicate Aadhaar registrations
   - Validates email format and password strength

4. **Account Creation**:
   - If validation passes, Firebase account is created
   - User profile is stored in Firestore with Aadhaar linking
   - Automatic redirect to dashboard upon successful registration

### For Existing Users (Login):

1. **Standard Login**:
   - Enter registered email and password
   - Click "Sign In"
   - Access dashboard if credentials are valid

2. **If Authentication Fails**:
   - Check if you have registered before
   - Use "Create New Account" if you're a first-time user
   - Use "Forgot Password" if you've forgotten credentials

## Security Features

### **Aadhaar Validation**
- **Verhoeff Algorithm**: Mathematical validation of Aadhaar number format
- **Checksum Verification**: Ensures Aadhaar number is mathematically valid
- **Duplicate Prevention**: Prevents multiple accounts with same Aadhaar

### **Data Protection**
- **Firebase Security**: Industry-standard authentication and data storage
- **Encrypted Storage**: All user data encrypted in Firestore
- **Secure Transmission**: HTTPS encryption for all data transmission

### **Validation Layers**
1. **Client-side Validation**: Immediate feedback on form inputs
2. **Server-side Validation**: Backend verification of all data
3. **Database Constraints**: Firestore rules prevent invalid data storage

## Error Handling

### **Common Registration Errors**:

1. **"Please enter a valid Aadhaar number"**
   - Check that Aadhaar number is exactly 12 digits
   - Ensure no spaces or special characters
   - Verify the number using Aadhaar card

2. **"This Aadhaar number is already registered"**
   - Aadhaar already linked to another account
   - Use "Sign In" instead if you have an existing account
   - Contact support if you believe this is an error

3. **"Email already in use"**
   - Email address already registered
   - Use "Sign In" or "Forgot Password" for existing accounts
   - Use different email address if needed

4. **"Passwords do not match"**
   - Ensure password and confirm password fields are identical
   - Check for typing errors or caps lock

## Technical Implementation

### **Files Added/Modified**:

1. **`lib/screens/registration_screen.dart`**
   - Complete registration form with Aadhaar validation
   - Verhoeff algorithm implementation
   - Firebase integration for user creation

2. **`lib/services/user_service.dart`**
   - Firestore integration for user profile management
   - Duplicate Aadhaar checking
   - User profile CRUD operations

3. **`lib/screens/login_screen.dart`** (Updated)
   - Added registration navigation button
   - Enhanced UI with registration card

### **Dependencies Added**:
- **`cloud_firestore`**: For user profile data storage and management

### **Database Structure** (Firestore):
```
users/{userId} {
  name: string,
  email: string,
  aadhaarNumber: string,
  createdAt: timestamp,
  updatedAt: timestamp,
  isVerified: boolean,
  profileComplete: boolean
}
```

## Next Steps

### **For Further Development**:

1. **Aadhaar OTP Verification**: Integrate with UIDAI for OTP-based verification
2. **Document Upload**: Allow users to upload supporting documents
3. **Profile Completion**: Multi-step registration with additional details
4. **Admin Panel**: Backend system for user management and verification
5. **Offline Support**: Local storage for areas with poor connectivity

## Troubleshooting

### **Common Issues**:

1. **App not loading after registration**
   - Ensure stable internet connection
   - Check Firebase/Firestore configuration
   - Verify authentication is enabled in Firebase Console

2. **Registration button not visible**
   - Update app to latest version
   - Check screen size and scroll down on mobile devices

3. **Aadhaar validation failing**
   - Double-check Aadhaar number from official document
   - Ensure no leading zeros are omitted
   - Contact support if official Aadhaar still fails validation

## Support

For technical issues:
- Check Firebase Console for authentication and Firestore status
- Verify internet connectivity
- Contact development team for persistent issues

For Aadhaar-related queries:
- Visit UIDAI official website
- Use Aadhaar helpline for card verification
- Ensure Aadhaar card is not blocked or suspended

---

**Note**: This registration system is designed specifically for beneficiaries under the PCR Act, 1955 and SC/ST (Prevention of Atrocities) Act, 1989. Proper Aadhaar verification is mandatory for accessing government benefits and services.