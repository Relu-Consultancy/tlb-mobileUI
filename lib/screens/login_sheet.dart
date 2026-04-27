import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import '../core/auth_state.dart';
import '../core/responsive.dart';
import 'signup_screen.dart';

void showLoginSheet(BuildContext context) {
  Navigator.push(
    context,
    MaterialPageRoute(builder: (_) => const LoginScreen()),
  );
}

// ─────────────────────────────────────────────
// LOGIN SCREEN
// ─────────────────────────────────────────────
class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _isPasswordMode = false;
  bool _obscurePassword = true;

  @override
  void dispose() {
    _phoneController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _onSendOTP() {
    final phone = _phoneController.text.trim();
    if (phone.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter phone number or email')),
      );
      return;
    }
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => _OTPVerificationScreen(phoneOrEmail: phone)),
    );
  }

  void _onSignInWithPassword() {
    final phone = _phoneController.text.trim();
    final password = _passwordController.text;
    if (phone.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter phone/email and password')),
      );
      return;
    }
    AuthState.login(phone: phone);
    final messenger = ScaffoldMessenger.of(context);
    Navigator.popUntil(context, (route) => route.isFirst);
    messenger.showSnackBar(
      const SnackBar(content: Text('Signed in successfully!')),
    );
  }

  void _onGoogleSignIn() {
    AuthState.login(name: 'Google User');
    final messenger = ScaffoldMessenger.of(context);
    Navigator.popUntil(context, (route) => route.isFirst);
    messenger.showSnackBar(
      const SnackBar(content: Text('Signed in with Google!')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Light grey background matches design
      backgroundColor: const Color(0xFFD9D9D9),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            child: Container(
              width: Responsive.cardWidth(context, fraction: 0.88, max: 400),
              margin: EdgeInsets.symmetric(
                  horizontal: Responsive.w(context, 16),
                  vertical: Responsive.h(context, 32)),
              padding: EdgeInsets.fromLTRB(
                  Responsive.w(context, 24),
                  Responsive.h(context, 12),
                  Responsive.w(context, 24),
                  Responsive.h(context, 28)),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(32),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.10),
                    blurRadius: 32,
                    spreadRadius: 0,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [

                  // ── Skip ───────────────────────────────────────────────
                  Align(
                    alignment: Alignment.centerRight,
                    child: TextButton(
                      onPressed: () => Navigator.popUntil(context, (r) => r.isFirst),
                      style: TextButton.styleFrom(
                        minimumSize: Size.zero,
                        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
                      ),
                      child: Text(
                        'Skip',
                        style: GoogleFonts.poppins(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: const Color(0xFF2F80ED),
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 8),

                  // ── Illustration ────────────────────────────────────────
                  SizedBox(
                    width: 152,
                    height: 152,
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        // Soft pink outer circle
                        Container(
                          width: 132,
                          height: 132,
                          decoration: const BoxDecoration(
                            color: Color(0xFFFDE8EC),
                            shape: BoxShape.circle,
                          ),
                        ),
                        // Yellow dot — top right
                        Positioned(
                          top: 14,
                          right: 18,
                          child: Container(
                            width: 14,
                            height: 14,
                            decoration: const BoxDecoration(
                              color: Color(0xFFFFD014),
                              shape: BoxShape.circle,
                            ),
                          ),
                        ),
                        // Yellow dot — bottom left
                        Positioned(
                          bottom: 20,
                          left: 14,
                          child: Container(
                            width: 10,
                            height: 10,
                            decoration: const BoxDecoration(
                              color: Color(0xFFFFD014),
                              shape: BoxShape.circle,
                            ),
                          ),
                        ),
                        // Tilted hot-pink rounded square with party popper
                        Transform.rotate(
                          angle: -0.13,
                          child: Container(
                            width: 90,
                            height: 90,
                            decoration: BoxDecoration(
                              gradient: const LinearGradient(
                                colors: [Color(0xFFFF3D7F), Color(0xFFFF8FAB)],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                              borderRadius: BorderRadius.circular(22),
                              boxShadow: [
                                BoxShadow(
                                  color: const Color(0xFFFF3D7F).withOpacity(0.35),
                                  blurRadius: 18,
                                  offset: const Offset(0, 8),
                                ),
                              ],
                            ),
                            child: Stack(
                              children: [
                                Positioned(
                                  top: -8,
                                  right: -8,
                                  child: Container(
                                    width: 32,
                                    height: 32,
                                    decoration: BoxDecoration(
                                      color: Colors.white.withOpacity(0.12),
                                      shape: BoxShape.circle,
                                    ),
                                  ),
                                ),
                                const Center(
                                  child: Icon(
                                    Icons.celebration_rounded,
                                    color: Colors.white,
                                    size: 44,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 22),

                  // ── Title ───────────────────────────────────────────────
                  Text(
                    "Let's Get Started!",
                    style: GoogleFonts.poppins(
                      fontSize: Responsive.sp(context, 22),
                      fontWeight: FontWeight.w700,
                      color: const Color(0xFF1A1A1A),
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Login to explore amazing kids events!',
                    style: GoogleFonts.poppins(
                      fontSize: Responsive.sp(context, 13),
                      color: const Color(0xFF9E9E9E),
                    ),
                    textAlign: TextAlign.center,
                  ),

                  const SizedBox(height: 28),

                  // ── Phone / Email input ─────────────────────────────────
                  _InputField(
                    controller: _phoneController,
                    hint: 'Phone Number / Email',
                    icon: Icons.mail_outline_rounded,
                    keyboardType: TextInputType.emailAddress,
                  ),

                  if (_isPasswordMode) ...[
                    const SizedBox(height: 14),
                    _InputField(
                      controller: _passwordController,
                      hint: 'Password',
                      icon: Icons.lock_outline_rounded,
                      obscureText: _obscurePassword,
                      suffix: GestureDetector(
                        onTap: () => setState(() => _obscurePassword = !_obscurePassword),
                        child: Icon(
                          _obscurePassword
                              ? Icons.visibility_off_outlined
                              : Icons.visibility_outlined,
                          size: 20,
                          color: const Color(0xFFAFAFAF),
                        ),
                      ),
                    ),
                  ],

                  const SizedBox(height: 18),

                  // ── Primary button ──────────────────────────────────────
                  _PrimaryButton(
                    label: _isPasswordMode ? 'Sign In' : 'Send OTP',
                    onTap: _isPasswordMode ? _onSignInWithPassword : _onSendOTP,
                  ),

                  const SizedBox(height: 10),

                  // ── Toggle mode link ────────────────────────────────────
                  TextButton(
                    onPressed: () => setState(() {
                      _isPasswordMode = !_isPasswordMode;
                      _passwordController.clear();
                      _obscurePassword = true;
                    }),
                    style: TextButton.styleFrom(
                      minimumSize: Size.zero,
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    ),
                    child: Text(
                      _isPasswordMode ? 'Use OTP instead' : 'Sign in with Password',
                      style: GoogleFonts.poppins(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: const Color(0xFF5B5BD6),
                      ),
                    ),
                  ),

                  const SizedBox(height: 14),

                  // ── OR divider ──────────────────────────────────────────
                  const _OrDivider(),

                  const SizedBox(height: 24),

                  // ── Continue with Google ────────────────────────────────
                  _GoogleButton(onTap: _onGoogleSignIn),

                  const SizedBox(height: 18),

                  // ── Continue as Event Partner ───────────────────────────
                  TextButton(
                    onPressed: () {},
                    style: TextButton.styleFrom(
                      minimumSize: Size.zero,
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    ),
                    child: Text(
                      'Continue as Event Partner',
                      style: GoogleFonts.poppins(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: const Color(0xFFE6A800),
                      ),
                    ),
                  ),

                  const SizedBox(height: 18),

                  // ── Don't have an account? ──────────────────────────────
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        "Don't have an account? ",
                        style: GoogleFonts.poppins(
                          fontSize: 13.5,
                          color: const Color(0xFF9E9E9E),
                        ),
                      ),
                      GestureDetector(
                        onTap: () {
                          // push (not pushReplacement) so Login stays in stack
                          // — this lets the "Log In" button on Signup pop back here
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (_) => const SignupScreen()),
                          );
                        },
                        child: Text(
                          'Sign Up',
                          style: GoogleFonts.poppins(
                            fontSize: 13.5,
                            fontWeight: FontWeight.w700,
                            color: const Color(0xFF1A1A1A),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────
// OTP VERIFICATION SCREEN
// ─────────────────────────────────────────────
class _OTPVerificationScreen extends StatefulWidget {
  final String phoneOrEmail;
  const _OTPVerificationScreen({required this.phoneOrEmail});

  @override
  State<_OTPVerificationScreen> createState() => _OTPVerificationScreenState();
}

class _OTPVerificationScreenState extends State<_OTPVerificationScreen> {
  final List<TextEditingController> _otpControllers =
      List.generate(6, (_) => TextEditingController());
  final List<FocusNode> _otpFocusNodes = List.generate(6, (_) => FocusNode());

  int _resendSeconds = 30;
  Timer? _resendTimer;

  @override
  void initState() {
    super.initState();
    _startResendTimer();
  }

  void _startResendTimer() {
    _resendSeconds = 30;
    _resendTimer?.cancel();
    _resendTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_resendSeconds <= 0) {
        timer.cancel();
      } else {
        setState(() => _resendSeconds--);
      }
    });
  }

  @override
  void dispose() {
    _resendTimer?.cancel();
    for (final c in _otpControllers) { c.dispose(); }
    for (final f in _otpFocusNodes) { f.dispose(); }
    super.dispose();
  }

  void _onVerify() {
    final otp = _otpControllers.map((c) => c.text).join();
    if (otp.length < 6) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter the 6-digit OTP')),
      );
      return;
    }
    AuthState.login(phone: widget.phoneOrEmail);
    final messenger = ScaffoldMessenger.of(context);
    Navigator.popUntil(context, (route) => route.isFirst);
    messenger.showSnackBar(
      const SnackBar(content: Text('OTP Verified! Logged in successfully.')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFD9D9D9),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 22, vertical: 32),
              padding: const EdgeInsets.fromLTRB(24, 20, 24, 32),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(32),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.10),
                    blurRadius: 32,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Align(
                    alignment: Alignment.centerLeft,
                    child: GestureDetector(
                      onTap: () => Navigator.pop(context),
                      child: Container(
                        width: 38,
                        height: 38,
                        decoration: BoxDecoration(
                          color: const Color(0xFFF5F5F5),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.arrow_back_ios_new_rounded,
                            size: 16, color: Color(0xFF1A1A1A)),
                      ),
                    ),
                  ),
                  const SizedBox(height: 28),
                  // OTP Illustration
                  SizedBox(
                    width: 130,
                    height: 130,
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        Container(
                          width: 110,
                          height: 110,
                          decoration: const BoxDecoration(
                            color: Color(0xFFEEF2FF),
                            shape: BoxShape.circle,
                          ),
                        ),
                        Container(
                          width: 76,
                          height: 76,
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [Color(0xFF5C6BC0), Color(0xFF3949AB)],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: const Color(0xFF5C6BC0).withOpacity(0.35),
                                blurRadius: 16,
                                offset: const Offset(0, 8),
                              ),
                            ],
                          ),
                          child: const Icon(Icons.verified_user_rounded,
                              color: Colors.white, size: 34),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                  Text(
                    'OTP Verification',
                    style: GoogleFonts.poppins(
                        fontSize: 22,
                        fontWeight: FontWeight.w700,
                        color: const Color(0xFF1A1A1A)),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Enter the 6-digit code sent to\n${widget.phoneOrEmail}',
                    style: GoogleFonts.poppins(
                        fontSize: 13, color: const Color(0xFF9E9E9E)),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 36),
                  LayoutBuilder(builder: (context, constraints) {
                    final boxW = ((constraints.maxWidth - 50) / 6).clamp(36.0, 50.0);
                    return Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: List.generate(6, (i) {
                        return SizedBox(
                          width: boxW,
                          height: boxW * 1.25,
                          child: TextField(
                            controller: _otpControllers[i],
                            focusNode: _otpFocusNodes[i],
                            textAlign: TextAlign.center,
                            keyboardType: TextInputType.number,
                            maxLength: 1,
                            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                            style: GoogleFonts.poppins(
                                fontSize: 20,
                                fontWeight: FontWeight.w700,
                                color: const Color(0xFF1A1A1A)),
                            decoration: InputDecoration(
                              counterText: '',
                              filled: true,
                              fillColor: const Color(0xFFF5F5F5),
                              contentPadding: EdgeInsets.zero,
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide.none,
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: const BorderSide(
                                    color: Color(0xFFFFD014), width: 2),
                              ),
                            ),
                            onChanged: (v) {
                              if (v.isNotEmpty && i < 5) {
                                _otpFocusNodes[i + 1].requestFocus();
                              } else if (v.isEmpty && i > 0) {
                                _otpFocusNodes[i - 1].requestFocus();
                              }
                            },
                          ),
                        );
                      }),
                    );
                  }),
                  const SizedBox(height: 32),
                  _PrimaryButton(label: 'Verify & Continue', onTap: _onVerify),
                  const SizedBox(height: 24),
                  if (_resendSeconds > 0)
                    Text(
                      'Resend in 00:${_resendSeconds.toString().padLeft(2, '0')}',
                      style: GoogleFonts.poppins(
                          fontSize: 13, color: const Color(0xFF9E9E9E)),
                    )
                  else
                    TextButton(
                      onPressed: _startResendTimer,
                      child: Text(
                        'Resend OTP',
                        style: GoogleFonts.poppins(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: const Color(0xFFFFD014)),
                      ),
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────
// SHARED WIDGETS
// ─────────────────────────────────────────────

class _InputField extends StatelessWidget {
  final TextEditingController controller;
  final String hint;
  final IconData icon;
  final TextInputType? keyboardType;
  final bool obscureText;
  final Widget? suffix;

  const _InputField({
    required this.controller,
    required this.hint,
    required this.icon,
    this.keyboardType,
    this.obscureText = false,
    this.suffix,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFF5F5F5),
        borderRadius: BorderRadius.circular(26),
      ),
      child: TextField(
        controller: controller,
        keyboardType: keyboardType,
        textCapitalization: TextCapitalization.none,
        obscureText: obscureText,
        style: GoogleFonts.poppins(fontSize: Responsive.sp(context, 14), color: const Color(0xFF1A1A1A)),
        decoration: InputDecoration(
          prefixIcon: Padding(
            padding: EdgeInsets.only(left: Responsive.w(context, 6)),
            child: Icon(icon, size: Responsive.sp(context, 20), color: const Color(0xFFAFAFAF)),
          ),
          hintText: hint,
          hintStyle: GoogleFonts.poppins(fontSize: Responsive.sp(context, 14), color: const Color(0xFFB8B8B8)),
          border: InputBorder.none,
          contentPadding: EdgeInsets.symmetric(horizontal: Responsive.w(context, 8), vertical: Responsive.h(context, 16)),
          suffixIcon: suffix == null
              ? null
              : Padding(padding: const EdgeInsets.only(right: 14), child: suffix),
          suffixIconConstraints: const BoxConstraints(minWidth: 24, minHeight: 24),
        ),
      ),
    );
  }
}

class _PrimaryButton extends StatelessWidget {
  final String label;
  final VoidCallback onTap;

  const _PrimaryButton({required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: 52,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(30),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFFFD014).withOpacity(0.5),
            blurRadius: 18,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: ElevatedButton(
        onPressed: onTap,
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFFFFD014),
          foregroundColor: const Color(0xFF1A1A1A),
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(30),
          ),
        ),
        child: Text(
          label,
          style: GoogleFonts.poppins(
            fontSize: 15,
            fontWeight: FontWeight.w700,
            color: const Color(0xFF1A1A1A),
          ),
        ),
      ),
    );
  }
}

class _OrDivider extends StatelessWidget {
  const _OrDivider();

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const Expanded(child: Divider(color: Color(0xFFE8E8E8), thickness: 1.2)),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14),
          child: Text(
            'OR',
            style: GoogleFonts.poppins(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: const Color(0xFFBBBBBB),
            ),
          ),
        ),
        const Expanded(child: Divider(color: Color(0xFFE8E8E8), thickness: 1.2)),
      ],
    );
  }
}

class _GoogleButton extends StatelessWidget {
  final VoidCallback onTap;
  const _GoogleButton({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: Responsive.h(context, 52, min: 48),
      child: OutlinedButton(
        onPressed: onTap,
        style: OutlinedButton.styleFrom(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(30),
          ),
          side: const BorderSide(color: Color(0xFFE0E0E0), width: 1.5),
          backgroundColor: Colors.white,
          padding: EdgeInsets.zero,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(
              'assets/images/google_logo.png',
              width: 20,
              height: 20,
              errorBuilder: (_, __, ___) => const Icon(
                Icons.g_mobiledata,
                color: Color(0xFFDB4437),
                size: 34,
              ),
            ),
            const SizedBox(width: 10),
            Text(
              'Continue with Google',
              style: GoogleFonts.poppins(
                fontSize: 14.5,
                fontWeight: FontWeight.w600,
                color: const Color(0xFF3C3C3C),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
