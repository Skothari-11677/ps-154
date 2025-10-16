// This is a basic Flutter widget test for PCR/PoA Beneficiary Portal.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pcr_poa_beneficiary_app/screens/login_screen.dart';

// Mock Firebase for testing
void setupFirebaseAuthMocks() {
  TestWidgetsFlutterBinding.ensureInitialized();
}

void main() {
  setUpAll(() async {
    setupFirebaseAuthMocks();
  });

  testWidgets('Login screen loads correctly without Firebase', (WidgetTester tester) async {
    // Test the login screen directly (bypassing Firebase auth check)
    await tester.pumpWidget(
      const MaterialApp(
        home: LoginScreen(),
      ),
    );

    // Wait for any async operations to complete
    await tester.pumpAndSettle();

    // Verify that the login screen elements are present
    expect(find.text('PCR/PoA Beneficiary Portal'), findsOneWidget);
    expect(find.text('Sign In'), findsOneWidget);
    expect(find.byType(TextFormField), findsAtLeastNWidgets(2)); // Email and password fields
    expect(find.text('Email Address'), findsOneWidget);
    expect(find.text('Password'), findsOneWidget);
  });

  testWidgets('Login form validation works', (WidgetTester tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: LoginScreen(),
      ),
    );

    // Find the sign in button and tap it without filling the form
    final signInButton = find.text('Sign In').last; // Get the button, not the title
    await tester.tap(signInButton);
    await tester.pumpAndSettle();

    // Should show validation errors
    expect(find.text('Please enter your email'), findsOneWidget);
    expect(find.text('Please enter your password'), findsOneWidget);
  });

  testWidgets('Email validation works', (WidgetTester tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: LoginScreen(),
      ),
    );

    // Enter invalid email
    final emailField = find.byType(TextFormField).first;
    await tester.enterText(emailField, 'invalid-email');
    
    // Tap sign in button to trigger validation
    final signInButton = find.text('Sign In').last;
    await tester.tap(signInButton);
    await tester.pumpAndSettle();

    // Should show email validation error
    expect(find.text('Please enter a valid email'), findsOneWidget);
  });
}
