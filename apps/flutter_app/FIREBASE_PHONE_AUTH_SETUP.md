# Firebase Phone Authentication Setup Guide

This guide will help you enable Firebase Phone Authentication with reCAPTCHA verification for your Flutter web app.

## 🔥 Step 1: Upgrade to Firebase Blaze Plan

Phone Authentication requires a paid Firebase plan:

1. **Go to Firebase Console**: https://console.firebase.google.com
2. **Select your project**: `ps154-a4a41`
3. **Click "Upgrade" in the left sidebar**
4. **Choose "Blaze (Pay as you go)" plan**
5. **Complete billing setup**

> 💡 **Cost**: First 10,000 phone authentications per month are FREE!

---

## 📱 Step 2: Enable Phone Authentication

1. **In Firebase Console**, go to **Authentication** → **Sign-in method**
2. **Click "Phone"** in the sign-in providers list
3. **Toggle "Enable"** to turn on phone authentication
4. **Click "Save"**

---

## 🌐 Step 3: Configure Authorized Domains (Web)

For web apps, you need to add authorized domains:

1. **In Authentication settings**, scroll to **Authorized domains**
2. **Add these domains**:
   - `localhost` (for local development)
   - `127.0.0.1` (for local development)
   - `your-domain.com` (for production)
3. **Click "Add domain"** for each

---

## 🛡️ Step 4: App Verification Setup

Firebase uses these methods to verify your app:

### For Web (Chrome):
- **reCAPTCHA verification** will automatically appear
- No additional setup needed for web platforms

### For Android (if needed later):
1. **Get your app's SHA-256 fingerprint**:
   ```bash
   keytool -list -v -keystore ~/.android/debug.keystore -alias androiddebugkey -storepass android -keypass android
   ```

2. **Add SHA-256 to Firebase**:
   - Go to **Project Settings** → **Your apps**
   - Click **Android app** → **Add fingerprint**
   - Paste SHA-256 fingerprint

---

## 🧪 Step 5: Testing Setup

### Production Testing:
- Use real phone numbers
- reCAPTCHA will appear for verification
- SMS will be sent to the phone

### Development Testing:
Add test phone numbers in Firebase Console:

1. **Go to Authentication** → **Sign-in method** → **Phone**
2. **Scroll to "Phone numbers for testing"**
3. **Add test numbers**:
   - Phone: `+1 650-555-3434`
   - Code: `123456`
   - Phone: `+91 9876543210`
   - Code: `654321`

---

## ⚙️ Step 6: Flutter Configuration

Your Flutter app is already configured with:

✅ **Firebase Core** initialized  
✅ **Firebase Auth** configured  
✅ **Phone Authentication service** ready  
✅ **reCAPTCHA verification** enabled for web

---

## 🚀 Step 7: Test Your Setup

1. **Run your Flutter app**: `flutter run -d chrome`
2. **Enter a phone number** (real or test number)
3. **Complete reCAPTCHA verification** (will appear automatically)
4. **Enter the OTP** received via SMS
5. **Verify successful authentication**

---

## 🐛 Troubleshooting

### Common Issues:

**# Firebase Phone Authentication Setup Guide

## Current Issue: OTP Not Sending
The "[BILLING_NOT_ENABLED]" error occurs because Firebase Phone Authentication requires the **Blaze plan**, even though the first 10,000 verifications per month are completely FREE.

## Why You're Not Getting OTP
1. **Firebase Project needs Blaze Plan upgrade** (free for first 10K/month)
2. **Phone Authentication provider not enabled**
3. **Domain not authorized for web applications**
4. **reCAPTCHA verification required for web****
- Solution: Upgrade to Blaze plan (Step 1)

**"Invalid phone number" Error:**
- Solution: Use E.164 format (+91XXXXXXXXXX)

**reCAPTCHA not appearing:**
- Solution: Check authorized domains (Step 3)

**"App not authorized" Error:**
- Solution: Verify Firebase project configuration

### Firebase Console Links:
- **Main Console**: https://console.firebase.google.com/project/ps154-a4a41
- **Authentication**: https://console.firebase.google.com/project/ps154-a4a41/authentication
- **Billing**: https://console.firebase.google.com/project/ps154-a4a41/usage

---

## 📋 Quick Checklist

Before testing, ensure:

- [ ] ✅ Upgraded to Blaze plan
- [ ] ✅ Phone authentication enabled
- [ ] ✅ Authorized domains added (localhost, etc.)
- [ ] ✅ Test phone numbers added (optional)
- [ ] ✅ Flutter app running successfully

---

## 🎯 Expected User Flow

1. **User enters phone number** → Firebase validates format
2. **reCAPTCHA appears** → User completes verification
3. **SMS sent** → User receives 6-digit OTP
4. **User enters OTP** → Firebase verifies code
5. **Authentication successful** → User signed in

Your Firebase Phone Authentication is now ready! 🎉