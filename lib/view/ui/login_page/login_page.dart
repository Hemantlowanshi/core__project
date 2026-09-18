import 'package:core_project/core/sessions/auth_session.dart';
import 'package:core_project/view/ui/buttompages/main_page.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({Key? key}) : super(key: key);

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _otpController = TextEditingController();

  bool _otpSent = false;
  bool _isLoading = false;

  String? _verificationId;
  int? _resendToken;

  final Color primaryBlue = const Color(0xFF4F75E9);

  @override
  void dispose() {
    _phoneController.dispose();
    _otpController.dispose();
    super.dispose();
  }

  Future<void> _sendOtp({bool isResend = false}) async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (_isLoading) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    final phoneNumber = '+91${_phoneController.text.trim()}';

    try {
      await FirebaseAuth.instance.verifyPhoneNumber(
        phoneNumber: phoneNumber,

        verificationCompleted:
            (PhoneAuthCredential credential) async {
          try {
            await FirebaseAuth.instance.signInWithCredential(
              credential,
            );

            if (!mounted) return;

            await _loginSuccess();
          } on FirebaseAuthException catch (e) {
            if (!mounted) return;

            setState(() {
              _isLoading = false;
            });

            _showError(
              e.message ?? 'Automatic verification failed.',
            );
          }
        },

        verificationFailed: (FirebaseAuthException e) {
          if (!mounted) return;

          setState(() {
            _isLoading = false;
          });

          String message;

          switch (e.code) {
            case 'invalid-phone-number':
              message = 'The phone number is invalid.';
              break;

            case 'too-many-requests':
              message =
              'Too many requests. Please try again later.';
              break;

            case 'quota-exceeded':
              message =
              'SMS quota exceeded. Please try again later.';
              break;

            default:
              message =
                  e.message ?? 'Failed to send OTP.';
          }

          _showError(message);
        },

        codeSent: (String verificationId, int? resendToken) {
          if (!mounted) return;

          setState(() {
            _verificationId = verificationId;
            _resendToken = resendToken;
            _otpSent = true;
            _isLoading = false;
          });

          _showMessage(
            isResend
                ? 'OTP resent successfully'
                : 'OTP sent successfully',
          );
        },

        codeAutoRetrievalTimeout: (String verificationId) {
          _verificationId = verificationId;
        },

        forceResendingToken: isResend ? _resendToken : null,
      );
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _isLoading = false;
      });

      _showError(
        'Something went wrong. Please try again.',
      );
    }
  }

  Future<void> _verifyOtp() async {
    final otp = _otpController.text.trim();

    if (otp.length != 6) {
      _showError('Please enter a valid 6-digit OTP.');
      return;
    }

    if (_verificationId == null) {
      _showError(
        'Verification session expired. Please request a new OTP.',
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final credential = PhoneAuthProvider.credential(
        verificationId: _verificationId!,
        smsCode: otp,
      );

      await FirebaseAuth.instance.signInWithCredential(
        credential,
      );

      if (!mounted) return;

      await _loginSuccess();
    } on FirebaseAuthException catch (e) {
      if (!mounted) return;

      setState(() {
        _isLoading = false;
      });

      String message;

      switch (e.code) {
        case 'invalid-verification-code':
          message = 'Incorrect OTP. Please try again.';
          break;

        case 'session-expired':
          message =
          'OTP expired. Please request a new OTP.';
          break;

        default:
          message =
              e.message ?? 'OTP verification failed.';
      }

      _showError(message);
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _isLoading = false;
      });

      _showError('OTP verification failed.');
    }
  }

  Future<void> _loginSuccess() async {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      if (!mounted) return;

      setState(() {
        _isLoading = false;
      });

      _showError('User authentication failed.');
      return;
    }

    await AuthSession.saveLogin(
      name: user.phoneNumber ?? 'User',
      email: '',
    );

    if (!mounted) return;

    setState(() {
      _isLoading = false;
    });

    _showMessage(
      'Phone number verified successfully',
    );

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => const MainPage(),
      ),
    );
  }

  Future<void> _resendOtp() async {
    if (_isLoading) {
      return;
    }

    await _sendOtp(isResend: true);
  }

  void _changePhoneNumber() {
    setState(() {
      _otpSent = false;
      _otpController.clear();
      _verificationId = null;
      _resendToken = null;
    });
  }

  void _showMessage(String message) {
    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
      ),
    );
  }

  void _showError(String message) {
    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(
            horizontal: 24.0,
            vertical: 40.0,
          ),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 20),

                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: primaryBlue.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    Icons.phone_android_outlined,
                    color: primaryBlue,
                    size: 32,
                  ),
                ),

                const SizedBox(height: 24),

                Text(
                  _otpSent
                      ? "Verify Your Number"
                      : "Welcome Back!",
                  style: const TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),

                const SizedBox(height: 8),

                Text(
                  _otpSent
                      ? "Enter the 6-digit OTP sent to your phone number."
                      : "Enter your phone number to sign in and continue.",
                  style: TextStyle(
                    fontSize: 15,
                    color: Colors.grey.shade600,
                  ),
                ),

                const SizedBox(height: 40),

                const Text(
                  "Phone Number",
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                ),

                const SizedBox(height: 8),

                TextFormField(
                  controller: _phoneController,
                  enabled: !_otpSent && !_isLoading,
                  keyboardType: TextInputType.phone,
                  maxLength: 10,
                  decoration: InputDecoration(
                    counterText: '',
                    hintText: 'Enter phone number',
                    hintStyle: TextStyle(
                      color: Colors.grey.shade400,
                    ),
                    prefixIcon: Icon(
                      Icons.phone_outlined,
                      color: Colors.grey.shade500,
                    ),
                    prefixText: '+91  ',
                    prefixStyle: const TextStyle(
                      color: Colors.black87,
                      fontSize: 16,
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(
                        color: Colors.grey.shade300,
                      ),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(
                        color: Colors.grey.shade300,
                      ),
                    ),
                    disabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(
                        color: Colors.grey.shade200,
                      ),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(
                        color: primaryBlue,
                        width: 1.5,
                      ),
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your phone number';
                    }

                    if (value.length != 10) {
                      return 'Please enter a valid 10-digit phone number';
                    }

                    return null;
                  },
                ),

                if (_otpSent) ...[
                  const SizedBox(height: 20),

                  const Text(
                    "OTP",
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Colors.black87,
                    ),
                  ),

                  const SizedBox(height: 8),

                  TextFormField(
                    controller: _otpController,
                    enabled: !_isLoading,
                    keyboardType: TextInputType.number,
                    maxLength: 6,
                    autofillHints: const [
                      AutofillHints.oneTimeCode,
                    ],
                    decoration: InputDecoration(
                      counterText: '',
                      hintText: 'Enter 6-digit OTP',
                      hintStyle: TextStyle(
                        color: Colors.grey.shade400,
                      ),
                      prefixIcon: Icon(
                        Icons.lock_outline,
                        color: Colors.grey.shade500,
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(
                          color: Colors.grey.shade300,
                        ),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(
                          color: Colors.grey.shade300,
                        ),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(
                          color: primaryBlue,
                          width: 1.5,
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 12),

                  Row(
                    mainAxisAlignment:
                    MainAxisAlignment.spaceBetween,
                    children: [
                      TextButton(
                        onPressed:
                        _isLoading ? null : _resendOtp,
                        style: TextButton.styleFrom(
                          padding: EdgeInsets.zero,
                        ),
                        child: Text(
                          "Resend OTP",
                          style: TextStyle(
                            color: primaryBlue,
                            fontWeight: FontWeight.w600,
                            fontSize: 14,
                          ),
                        ),
                      ),
                      TextButton(
                        onPressed:
                        _isLoading
                            ? null
                            : _changePhoneNumber,
                        style: TextButton.styleFrom(
                          padding: EdgeInsets.zero,
                        ),
                        child: Text(
                          "Change Phone Number",
                          style: TextStyle(
                            color: primaryBlue,
                            fontWeight: FontWeight.w600,
                            fontSize: 14,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],

                const SizedBox(height: 30),

                SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: ElevatedButton(
                    onPressed: _isLoading
                        ? null
                        : (_otpSent
                        ? _verifyOtp
                        : _sendOtp),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: primaryBlue,
                      disabledBackgroundColor:
                      primaryBlue.withOpacity(0.6),
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius:
                        BorderRadius.circular(12),
                      ),
                    ),
                    child: _isLoading
                        ? const SizedBox(
                      height: 22,
                      width: 22,
                      child:
                      CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                        : Text(
                      _otpSent
                          ? "Verify OTP"
                          : "Send OTP",
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 30),
              ],
            ),
          ),
        ),
      ),
    );
  }
}