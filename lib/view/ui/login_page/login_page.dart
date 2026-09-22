import 'package:core_project/core/sessions/auth_session.dart';
import 'package:core_project/view/ui/buttompages/main_page.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController _phoneController =
  TextEditingController();

  final TextEditingController _otpController =
  TextEditingController();

  static const Color _primaryBlue = Color(0xFF4F75E9);

  bool _otpSent = false;
  bool _isLoading = false;

  String? _verificationId;
  int? _resendToken;

  @override
  void dispose() {
    _phoneController.dispose();
    _otpController.dispose();
    super.dispose();
  }

  // ============================================================
  // SEND OTP
  // ============================================================

  Future<void> _sendOtp({bool isResend = false}) async {
    if (!_validatePhone()) return;
    if (_isLoading) return;

    _setLoading(true);

    final phoneNumber = '+91${_phoneController.text.trim()}';

    try {
      await FirebaseAuth.instance.verifyPhoneNumber(
        phoneNumber: phoneNumber,

        // Android may automatically verify the SMS.
        verificationCompleted: _verificationCompleted,

        // OTP sending/verification failed.
        verificationFailed: _verificationFailed,

        // OTP successfully sent.
        codeSent: (verificationId, resendToken) {
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

        // Called when automatic SMS retrieval times out.
        codeAutoRetrievalTimeout: (verificationId) {
          _verificationId = verificationId;
        },

        forceResendingToken:
        isResend ? _resendToken : null,
      );
    } catch (error) {
      if (!mounted) return;

      _setLoading(false);

      _showError(
        'Something went wrong. Please try again.',
      );
    }
  }

  // ============================================================
  // AUTOMATIC OTP VERIFICATION
  // ============================================================

  Future<void> _verificationCompleted(
      PhoneAuthCredential credential,
      ) async {
    try {
      await FirebaseAuth.instance.signInWithCredential(
        credential,
      );

      if (!mounted) return;

      await _loginSuccess();
    } on FirebaseAuthException catch (error) {
      if (!mounted) return;

      _setLoading(false);

      _showError(
        error.message ??
            'Automatic verification failed.',
      );
    }
  }

  // ============================================================
  // VERIFICATION FAILED
  // ============================================================

  void _verificationFailed(
      FirebaseAuthException error,
      ) {
    if (!mounted) return;

    _setLoading(false);

    _showError(
      _getFirebaseErrorMessage(error),
    );
  }

  // ============================================================
  // VERIFY MANUAL OTP
  // ============================================================

  Future<void> _verifyOtp() async {
    final otp = _otpController.text.trim();

    if (otp.length != 6) {
      _showError(
        'Please enter a valid 6-digit OTP.',
      );
      return;
    }

    if (_verificationId == null) {
      _showError(
        'Verification session expired. '
            'Please request a new OTP.',
      );
      return;
    }

    if (_isLoading) return;

    _setLoading(true);

    try {
      final credential =
      PhoneAuthProvider.credential(
        verificationId: _verificationId!,
        smsCode: otp,
      );

      await FirebaseAuth.instance.signInWithCredential(
        credential,
      );

      if (!mounted) return;

      await _loginSuccess();
    } on FirebaseAuthException catch (error) {
      if (!mounted) return;

      _setLoading(false);

      _showError(
        _getOtpErrorMessage(error),
      );
    } catch (error) {
      if (!mounted) return;

      _setLoading(false);

      _showError(
        'OTP verification failed.',
      );
    }
  }

  // ============================================================
  // LOGIN SUCCESS
  // ============================================================

  Future<void> _loginSuccess() async {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      if (!mounted) return;

      _setLoading(false);

      _showError(
        'User authentication failed.',
      );

      return;
    }

    await AuthSession.saveLogin(
      name: user.phoneNumber ?? 'User',
      email: '',
    );

    if (!mounted) return;

    _setLoading(false);

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

  // ============================================================
  // RESEND OTP
  // ============================================================

  Future<void> _resendOtp() async {
    if (_isLoading) return;

    await _sendOtp(
      isResend: true,
    );
  }

  // ============================================================
  // CHANGE PHONE NUMBER
  // ============================================================

  void _changePhoneNumber() {
    setState(() {
      _otpSent = false;
      _otpController.clear();
      _verificationId = null;
      _resendToken = null;
    });
  }

  // ============================================================
  // VALIDATION
  // ============================================================

  bool _validatePhone() {
    return _formKey.currentState?.validate() ?? false;
  }

  // ============================================================
  // LOADING
  // ============================================================

  void _setLoading(bool value) {
    if (!mounted) return;

    setState(() {
      _isLoading = value;
    });
  }

  // ============================================================
  // FIREBASE ERROR MESSAGE
  // ============================================================

  String _getFirebaseErrorMessage(
      FirebaseAuthException error,
      ) {
    switch (error.code) {
      case 'invalid-phone-number':
        return 'The phone number is invalid.';

      case 'too-many-requests':
        return 'Too many requests. Please try again later.';

      case 'quota-exceeded':
        return 'SMS quota exceeded. Please try again later.';

      default:
        return error.message ?? 'Failed to send OTP.';
    }
  }

  // ============================================================
  // OTP ERROR MESSAGE
  // ============================================================

  String _getOtpErrorMessage(
      FirebaseAuthException error,
      ) {
    switch (error.code) {
      case 'invalid-verification-code':
        return 'Incorrect OTP. Please try again.';

      case 'session-expired':
        return 'OTP expired. Please request a new OTP.';

      default:
        return error.message ??
            'OTP verification failed.';
    }
  }

  // ============================================================
  // SNACKBAR
  // ============================================================

  void _showMessage(String message) {
    if (!mounted) return;

    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(message),
        ),
      );
  }

  void _showError(String message) {
    if (!mounted) return;

    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: Colors.red,
        ),
      );
  }

  // ============================================================
  // INPUT DECORATION
  // ============================================================

  InputDecoration _inputDecoration({
    required String hintText,
    required IconData icon,
  }) {
    return InputDecoration(
      counterText: '',
      hintText: hintText,
      hintStyle: TextStyle(
        color: Colors.grey.shade400,
      ),
      prefixIcon: Icon(
        icon,
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
      disabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(
          color: Colors.grey.shade200,
        ),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(
          color: _primaryBlue,
          width: 1.5,
        ),
      ),
    );
  }

  // ============================================================
  // BUILD
  // ============================================================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(
            horizontal: 24,
            vertical: 40,
          ),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment:
              CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 20),

                _buildPhoneIcon(),

                const SizedBox(height: 24),

                _buildTitle(),

                const SizedBox(height: 8),

                _buildSubtitle(),

                const SizedBox(height: 40),

                _buildPhoneLabel(),

                const SizedBox(height: 8),

                _buildPhoneField(),

                if (_otpSent) ...[
                  const SizedBox(height: 20),
                  _buildOtpSection(),
                ],

                const SizedBox(height: 30),

                _buildMainButton(),

                const SizedBox(height: 30),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ============================================================
  // PHONE ICON
  // ============================================================

  Widget _buildPhoneIcon() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: _primaryBlue.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: const Icon(
        Icons.phone_android_outlined,
        color: _primaryBlue,
        size: 32,
      ),
    );
  }

  // ============================================================
  // TITLE
  // ============================================================

  Widget _buildTitle() {
    return Text(
      _otpSent
          ? 'Verify Your Number'
          : 'Welcome Back!',
      style: const TextStyle(
        fontSize: 28,
        fontWeight: FontWeight.bold,
        color: Colors.black87,
      ),
    );
  }

  // ============================================================
  // SUBTITLE
  // ============================================================

  Widget _buildSubtitle() {
    return Text(
      _otpSent
          ? 'Enter the 6-digit OTP sent to your phone number.'
          : 'Enter your phone number to sign in and continue.',
      style: TextStyle(
        fontSize: 15,
        color: Colors.grey.shade600,
      ),
    );
  }

  // ============================================================
  // PHONE LABEL
  // ============================================================

  Widget _buildPhoneLabel() {
    return const Text(
      'Phone Number',
      style: TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w600,
        color: Colors.black87,
      ),
    );
  }

  // ============================================================
  // PHONE FIELD
  // ============================================================

  Widget _buildPhoneField() {
    return TextFormField(
      controller: _phoneController,
      enabled: !_otpSent && !_isLoading,
      keyboardType: TextInputType.phone,
      maxLength: 10,
      decoration: _inputDecoration(
        hintText: 'Enter phone number',
        icon: Icons.phone_outlined,
      ).copyWith(
        prefixText: '+91  ',
        prefixStyle: const TextStyle(
          color: Colors.black87,
          fontSize: 16,
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
    );
  }

  // ============================================================
  // OTP SECTION
  // ============================================================

  Widget _buildOtpSection() {
    return Column(
      crossAxisAlignment:
      CrossAxisAlignment.start,
      children: [
        const Text(
          'OTP',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Colors.black87,
          ),
        ),

        const SizedBox(height: 8),

        _buildOtpField(),

        const SizedBox(height: 12),

        _buildOtpActions(),
      ],
    );
  }

  // ============================================================
  // OTP FIELD
  // ============================================================

  Widget _buildOtpField() {
    return TextFormField(
      controller: _otpController,
      enabled: !_isLoading,
      keyboardType: TextInputType.number,
      maxLength: 6,
      autofillHints: const [
        AutofillHints.oneTimeCode,
      ],
      decoration: _inputDecoration(
        hintText: 'Enter 6-digit OTP',
        icon: Icons.lock_outline,
      ),
    );
  }

  // ============================================================
  // OTP ACTIONS
  // ============================================================

  Widget _buildOtpActions() {
    return Row(
      mainAxisAlignment:
      MainAxisAlignment.spaceBetween,
      children: [
        TextButton(
          onPressed:
          _isLoading ? null : _resendOtp,
          style: TextButton.styleFrom(
            padding: EdgeInsets.zero,
          ),
          child: const Text(
            'Resend OTP',
            style: TextStyle(
              color: _primaryBlue,
              fontWeight: FontWeight.w600,
              fontSize: 14,
            ),
          ),
        ),
        TextButton(
          onPressed:
          _isLoading ? null : _changePhoneNumber,
          style: TextButton.styleFrom(
            padding: EdgeInsets.zero,
          ),
          child: const Text(
            'Change Phone Number',
            style: TextStyle(
              color: _primaryBlue,
              fontWeight: FontWeight.w600,
              fontSize: 14,
            ),
          ),
        ),
      ],
    );
  }

  // ============================================================
  // MAIN BUTTON
  // ============================================================

  Widget _buildMainButton() {
    return SizedBox(
      width: double.infinity,
      height: 52,
      child: ElevatedButton(
        onPressed: _isLoading
            ? null
            : (_otpSent
            ? _verifyOtp
            : _sendOtp),
        style: ElevatedButton.styleFrom(
          backgroundColor: _primaryBlue,
          disabledBackgroundColor:
          _primaryBlue.withOpacity(0.6),
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        child: _isLoading
            ? const SizedBox(
          height: 22,
          width: 22,
          child: CircularProgressIndicator(
            strokeWidth: 2,
            color: Colors.white,
          ),
        )
            : Text(
          _otpSent
              ? 'Verify OTP'
              : 'Send OTP',
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      ),
    );
  }
}