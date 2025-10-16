import 'package:flutter/material.dart';
import '../services/firebase_otp_service.dart';

class FirebaseOTPTestScreen extends StatefulWidget {
  const FirebaseOTPTestScreen({super.key});

  @override
  State<FirebaseOTPTestScreen> createState() => _FirebaseOTPTestScreenState();
}

class _FirebaseOTPTestScreenState extends State<FirebaseOTPTestScreen>
    with TickerProviderStateMixin {
  final _phoneController = TextEditingController();
  final _firebaseOTPService = FirebaseOTPService();

  // Animation controllers
  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;

  // State management
  bool _isLoading = false;
  String _errorMessage = '';
  String _successMessage = '';
  bool _otpSent = false;
  String? _verificationId;
  String? _phoneNumber;

  // OTP input
  final List<TextEditingController> _otpControllers =
      List.generate(6, (index) => TextEditingController());
  final List<FocusNode> _otpFocusNodes =
      List.generate(6, (index) => FocusNode());

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _initializeFirebase();
  }

  void _initializeAnimations() {
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeInOut,
    ));
    _fadeController.forward();
  }

  Future<void> _initializeFirebase() async {
    try {
      await _firebaseOTPService.initializeAuth();
    } catch (e) {
      _showError('Firebase initialization failed: $e');
    }
  }

  @override
  void dispose() {
    _phoneController.dispose();
    _fadeController.dispose();
    for (var controller in _otpControllers) {
      controller.dispose();
    }
    for (var focusNode in _otpFocusNodes) {
      focusNode.dispose();
    }
    super.dispose();
  }

  void _showError(String message) {
    setState(() {
      _errorMessage = message;
      _successMessage = '';
    });
  }

  void _showSuccess(String message) {
    setState(() {
      _successMessage = message;
      _errorMessage = '';
    });
  }

  void _clearMessages() {
    setState(() {
      _errorMessage = '';
      _successMessage = '';
    });
  }

  Future<void> _sendOTP() async {
    final phoneText = _phoneController.text.trim();

    if (phoneText.isEmpty) {
      _showError('Please enter a phone number');
      return;
    }

    if (!_firebaseOTPService.isValidPhoneNumber(phoneText)) {
      _showError('Please enter a valid 10-digit mobile number');
      return;
    }

    setState(() {
      _isLoading = true;
      _clearMessages();
    });

    try {
      final formattedPhone = _firebaseOTPService.formatPhoneNumber(phoneText);

      await _firebaseOTPService.verifyPhoneNumber(
        phoneNumber: formattedPhone,
        onCodeSent: (verificationId) {
          setState(() {
            _isLoading = false;
            _otpSent = true;
            _verificationId = verificationId;
            _phoneNumber = formattedPhone;
          });
          _showSuccess('OTP sent to $formattedPhone');
          _otpFocusNodes[0].requestFocus();
        },
        onError: (error) {
          setState(() {
            _isLoading = false;
          });

          if (error.contains('billing') || error.contains('BILLING_NOT_ENABLED')) {
            _showBillingDialog();
          } else {
            _showError(error);
          }
        },
      );
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      _showError('Failed to send OTP: $e');
    }
  }

  Future<void> _verifyOTP() async {
    final otp = _otpControllers.map((c) => c.text).join();

    if (otp.length != 6) {
      _showError('Please enter complete 6-digit OTP');
      return;
    }

    if (_verificationId == null) {
      _showError('Verification session expired. Please try again.');
      return;
    }

    setState(() {
      _isLoading = true;
      _clearMessages();
    });

    try {
      await _firebaseOTPService.verifyOTP(
        verificationId: _verificationId!,
        otp: otp,
        onSuccess: () {
          setState(() {
            _isLoading = false;
          });
          _showVerificationSuccess();
        },
        onError: (error) {
          setState(() {
            _isLoading = false;
          });
          _showError(error);
          _clearOTPFields();
        },
      );
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      _showError('Verification failed: $e');
      _clearOTPFields();
    }
  }

  Future<void> _resendOTP() async {
    if (_phoneNumber == null) return;

    setState(() {
      _isLoading = true;
      _clearMessages();
    });

    try {
      await _firebaseOTPService.verifyPhoneNumber(
        phoneNumber: _phoneNumber!,
        onCodeSent: (verificationId) {
          setState(() {
            _isLoading = false;
            _verificationId = verificationId;
          });
          _showSuccess('OTP resent successfully');
          _clearOTPFields();
          _otpFocusNodes[0].requestFocus();
        },
        onError: (error) {
          setState(() {
            _isLoading = false;
          });
          _showError('Failed to resend OTP: $error');
        },
      );
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      _showError('Error resending OTP: $e');
    }
  }

  void _clearOTPFields() {
    for (var controller in _otpControllers) {
      controller.clear();
    }
    _otpFocusNodes[0].requestFocus();
  }

  void _onOTPChanged(String value, int index) {
    _clearMessages();

    if (value.isNotEmpty && index < 5) {
      _otpFocusNodes[index + 1].requestFocus();
    } else if (value.isNotEmpty && index == 5) {
      _otpFocusNodes[index].unfocus();
      // Auto-verify when all digits are entered
      final otp = _otpControllers.map((c) => c.text).join();
      if (otp.length == 6) {
        _verifyOTP();
      }
    }
  }

  void _showVerificationSuccess() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: const BoxDecoration(
                color: Colors.green,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.check,
                color: Colors.white,
                size: 40,
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              'Verification Successful!',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.green,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 10),
            Text(
              'Phone number ${_phoneNumber ?? ''} verified successfully.',
              style: const TextStyle(color: Colors.grey),
              textAlign: TextAlign.center,
            ),
          ],
        ),
        actions: [
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              _resetToPhoneInput();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            child: const Text('Continue'),
          ),
        ],
      ),
    );
  }

  void _resetToPhoneInput() {
    setState(() {
      _otpSent = false;
      _verificationId = null;
      _phoneNumber = null;
      _phoneController.clear();
      _clearMessages();
    });
    for (var controller in _otpControllers) {
      controller.clear();
    }
  }

  void _showBillingDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Firebase Billing Required'),
        content: const Text(
          'Phone Authentication requires Firebase Blaze plan.\n\n'
          'Please upgrade to Blaze plan in Firebase Console to send SMS.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text('Phone Verification'),
        backgroundColor: Colors.blue[600],
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const SizedBox(height: 40),

                // Header Icon
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Colors.blue[600]!, Colors.blue[800]!],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.blue.withValues(alpha: 0.3),
                        spreadRadius: 3,
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.phone_android,
                    size: 60,
                    color: Colors.white,
                  ),
                ),

                const SizedBox(height: 32),

                // Title
                Text(
                  _otpSent ? 'Enter Verification Code' : 'Verify Your Phone',
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: Colors.grey[800],
                      ),
                  textAlign: TextAlign.center,
                ),

                const SizedBox(height: 16),

                // Subtitle
                Text(
                  _otpSent
                      ? 'We sent a 6-digit code to ${_phoneNumber ?? ''}'
                      : 'Enter your phone number to receive a verification code',
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        color: Colors.grey[600],
                      ),
                  textAlign: TextAlign.center,
                ),

                const SizedBox(height: 48),

                // Phone Input Section
                if (!_otpSent) ...[
                  Container(
                    padding: const EdgeInsets.all(32),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withValues(alpha: 0.1),
                          spreadRadius: 2,
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        // Phone Input Field
                        TextFormField(
                          controller: _phoneController,
                          keyboardType: TextInputType.phone,
                          maxLength: 10,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w500,
                          ),
                          decoration: InputDecoration(
                            labelText: 'Phone Number',
                            prefixIcon: const Icon(Icons.phone),
                            prefixText: '+91 ',
                            counterText: '',
                            hintText: '9876543210',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide(color: Colors.grey[300]!),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide(color: Colors.blue[600]!),
                            ),
                          ),
                        ),

                        const SizedBox(height: 32),

                        // Send OTP Button
                        SizedBox(
                          width: double.infinity,
                          height: 56,
                          child: ElevatedButton(
                            onPressed: _isLoading ? null : _sendOTP,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.blue[600],
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              elevation: 2,
                              shadowColor: Colors.blue.withValues(alpha: 0.3),
                            ),
                            child: _isLoading
                                ? const SizedBox(
                                    height: 24,
                                    width: 24,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                    ),
                                  )
                                : const Text(
                                    'Send Verification Code',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],

                // OTP Input Section
                if (_otpSent) ...[
                  Container(
                    padding: const EdgeInsets.all(32),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withValues(alpha: 0.1),
                          spreadRadius: 2,
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        // OTP Input Fields
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: List.generate(
                            6,
                            (index) => Container(
                              width: 40,
                              height: 50,
                              margin: const EdgeInsets.symmetric(horizontal: 4),
                              child: TextFormField(
                                controller: _otpControllers[index],
                                focusNode: _otpFocusNodes[index],
                                keyboardType: TextInputType.number,
                                textAlign: TextAlign.center,
                                maxLength: 1,
                                style: const TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                ),
                                decoration: InputDecoration(
                                  counterText: '',
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  enabledBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                    borderSide: BorderSide(color: Colors.grey[300]!),
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                    borderSide: BorderSide(color: Colors.blue[600]!, width: 2),
                                  ),
                                  filled: true,
                                  fillColor: Colors.grey[50],
                                ),
                                onChanged: (value) => _onOTPChanged(value, index),
                              ),
                            ),
                          ),
                        ),

                        const SizedBox(height: 32),

                        // Verify Button
                        SizedBox(
                          width: double.infinity,
                          height: 56,
                          child: ElevatedButton(
                            onPressed: _isLoading ? null : _verifyOTP,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.green[600],
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              elevation: 2,
                              shadowColor: Colors.green.withValues(alpha: 0.3),
                            ),
                            child: _isLoading
                                ? const SizedBox(
                                    height: 24,
                                    width: 24,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                    ),
                                  )
                                : const Text(
                                    'Verify Code',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                          ),
                        ),

                        const SizedBox(height: 24),

                        // Resend Button
                        TextButton(
                          onPressed: _isLoading ? null : _resendOTP,
                          style: TextButton.styleFrom(
                            foregroundColor: Colors.blue[600],
                          ),
                          child: const Text(
                            'Didn\'t receive code? Resend',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Back to Phone Input
                  TextButton.icon(
                    onPressed: _resetToPhoneInput,
                    icon: const Icon(Icons.arrow_back),
                    label: const Text('Change Phone Number'),
                    style: TextButton.styleFrom(
                      foregroundColor: Colors.grey[600],
                    ),
                  ),
                ],

                const SizedBox(height: 32),

                // Messages
                if (_errorMessage.isNotEmpty)
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.red[50],
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.red[200]!),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.error_outline, color: Colors.red[600]),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            _errorMessage,
                            style: TextStyle(color: Colors.red[700]),
                          ),
                        ),
                      ],
                    ),
                  ),

                if (_successMessage.isNotEmpty)
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.green[50],
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.green[200]!),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.check_circle_outline, color: Colors.green[600]),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            _successMessage,
                            style: TextStyle(color: Colors.green[700]),
                          ),
                        ),
                      ],
                    ),
                  ),

                const SizedBox(height: 32),

                // User Status
                if (_firebaseOTPService.isSignedIn)
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.green[50],
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.green[200]!),
                    ),
                    child: Column(
                      children: [
                        Icon(Icons.verified_user, color: Colors.green[600], size: 32),
                        const SizedBox(height: 12),
                        Text(
                          'Phone Verified',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.green[700],
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Number: ${_firebaseOTPService.currentUser?.phoneNumber ?? ''}',
                          style: TextStyle(color: Colors.green[600]),
                        ),
                        const SizedBox(height: 12),
                        ElevatedButton(
                          onPressed: () async {
                            await _firebaseOTPService.signOut();
                            setState(() {});
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.green[600],
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          child: const Text('Sign Out'),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}