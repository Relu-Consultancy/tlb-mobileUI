import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import '../services/auth_service.dart';
import '../providers/auth_state.dart';
import '../core/responsive.dart';
import '../screens/home_screen.dart';
import '../screens/edit_profile_screen.dart';
import '../services/walkthrough_service.dart';

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
  final TextEditingController _emailController = TextEditingController();
  bool _loading = false;

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _onSendOTP() async {
    final email = _emailController.text.trim();
    if (email.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter your email address')),
      );
      return;
    }
    setState(() => _loading = true);
    final result = await AuthService.requestOtp(identifier: email);
    if (!mounted) return;
    setState(() => _loading = false);
    if (result['success'] == true) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => _OTPVerificationScreen(identifier: email)),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(result['message'] ?? 'Failed to send OTP'),
          backgroundColor: const Color(0xFFE53935),
        ),
      );
    }
  }

  Future<void> _onGoogleSignIn() async {
    setState(() => _loading = true);
    try {
      final googleSignIn = GoogleSignIn(
        serverClientId: '690253990877-jqog76u6vcre0a9qbd9d8p0g7o47scue.apps.googleusercontent.com',
        scopes: ['email', 'profile'],
      );
      await googleSignIn.signOut();
      final googleUser = await googleSignIn.signIn();
      if (googleUser == null) {
        setState(() => _loading = false);
        return; // user cancelled
      }

      final googleAuth = await googleUser.authentication;
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      final fbCredential =
          await FirebaseAuth.instance.signInWithCredential(credential);
      final firebaseToken = await fbCredential.user?.getIdToken();

      if (firebaseToken == null) {
        if (!mounted) return;
        setState(() => _loading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Google sign-in failed. Try again.')),
        );
        return;
      }

      final result = await AuthService.googleSignIn(firebaseIdToken: firebaseToken);

      if (!mounted) return;
      setState(() => _loading = false);

      if (result['success'] == true) {
        AuthState.login(
          access: result['access'] as String?,
          refresh: result['refresh'] as String?,
          user: result['user'] as Map<String, dynamic>?,
        );
        final isNew = result['is_new_user'] == true;
        if (isNew) {
          await WalkthroughService.markAsNewUser();
          if (!mounted) return;
          Navigator.of(context).pushAndRemoveUntil(
            MaterialPageRoute(
              builder: (_) => const EditProfileScreen(isOnboarding: true),
            ),
            (route) => false,
          );
        } else {
          showWelcomeBackDialog(context);
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(result['message'] ?? 'Google sign-in failed'),
            backgroundColor: const Color(0xFFE53935),
          ),
        );
      }
    } catch (e) {
      if (!mounted) return;
      setState(() => _loading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Google sign-in error: ${e.toString()}'),
          backgroundColor: const Color(0xFFE53935),
        ),
      );
    }
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

                  // ── Email input ─────────────────────────────────────────
                  _InputField(
                    controller: _emailController,
                    hint: 'Email Address',
                    icon: Icons.mail_outline_rounded,
                    keyboardType: TextInputType.emailAddress,
                  ),

                  const SizedBox(height: 18),

                  // ── Primary button ──────────────────────────────────────
                  _PrimaryButton(
                    label: 'Send OTP',
                    loading: _loading,
                    onTap: _onSendOTP,
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

                  // ── New user prompt ─────────────────────────────────────
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        "New here? ",
                        style: GoogleFonts.poppins(
                          fontSize: 13.5,
                          color: const Color(0xFF9E9E9E),
                        ),
                      ),
                      GestureDetector(
                        onTap: _onSendOTP,
                        child: Text(
                          'Sign Up with OTP',
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
  final String identifier;
  const _OTPVerificationScreen({required this.identifier});

  @override
  State<_OTPVerificationScreen> createState() => _OTPVerificationScreenState();
}

class _OTPVerificationScreenState extends State<_OTPVerificationScreen> {
  final List<TextEditingController> _otpControllers =
      List.generate(6, (_) => TextEditingController());
  final List<FocusNode> _otpFocusNodes = List.generate(6, (_) => FocusNode());

  int _resendSeconds = 30;
  Timer? _resendTimer;
  bool _loading = false;

  @override
  void initState() {
    super.initState();
    _startResendTimer();
  }

  void _startResendTimer() {
    _resendSeconds = 30;
    _resendTimer?.cancel();
    _resendTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) { timer.cancel(); return; }
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

  Future<void> _onVerify() async {
    final otp = _otpControllers.map((c) => c.text).join();
    if (otp.length < 6) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter the 6-digit OTP')),
      );
      return;
    }
    setState(() => _loading = true);
    final result = await AuthService.verifyOtp(
      identifier: widget.identifier,
      otp: otp,
    );
    if (!mounted) return;
    setState(() => _loading = false);

    if (result['success'] == true) {
      AuthState.login(
        access: result['access'] as String?,
        refresh: result['refresh'] as String?,
        user: result['user'] as Map<String, dynamic>?,
      );
      final isNew = result['is_new_user'] == true;
      if (isNew) {
        await WalkthroughService.markAsNewUser();
        if (!mounted) return;
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(
            builder: (_) => const EditProfileScreen(isOnboarding: true),
          ),
          (route) => false,
        );
      } else {
        showWelcomeBackDialog(context);
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(result['message'] ?? 'Verification failed. Please try again.'),
          backgroundColor: const Color(0xFFE53935),
        ),
      );
    }
  }

  Future<void> _onResendOtp() async {
    _startResendTimer();
    final result = await AuthService.requestOtp(identifier: widget.identifier);
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          result['success'] == true
              ? 'OTP resent to ${widget.identifier}'
              : (result['message'] ?? 'Failed to resend OTP'),
        ),
        backgroundColor: result['success'] == true ? null : const Color(0xFFE53935),
      ),
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
                    'Enter the 6-digit code sent to\n${widget.identifier}',
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
                  _PrimaryButton(label: 'Verify & Continue', loading: _loading, onTap: _onVerify),
                  const SizedBox(height: 24),
                  if (_resendSeconds > 0)
                    Text(
                      'Resend in 00:${_resendSeconds.toString().padLeft(2, '0')}',
                      style: GoogleFonts.poppins(
                          fontSize: 13, color: const Color(0xFF9E9E9E)),
                    )
                  else
                    TextButton(
                      onPressed: _onResendOtp,
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

  const _InputField({
    required this.controller,
    required this.hint,
    required this.icon,
    this.keyboardType,
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
        ),
      ),
    );
  }
}

class _PrimaryButton extends StatelessWidget {
  final String label;
  final VoidCallback onTap;
  final bool loading;

  const _PrimaryButton({
    required this.label,
    required this.onTap,
    this.loading = false,
  });

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
        onPressed: loading ? null : onTap,
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFFFFCC00),
          foregroundColor: const Color(0xFF1A1A1A),
          disabledBackgroundColor: const Color(0xFFFFCC00).withOpacity(0.7),
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(30),
          ),
        ),
        child: loading
            ? const SizedBox(
                width: 22,
                height: 22,
                child: CircularProgressIndicator(
                  strokeWidth: 2.5,
                  color: Color(0xFF1A1A1A),
                ),
              )
            : Text(
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

// ─────────────────────────────────────────────
// WELCOME BACK DIALOG
// ─────────────────────────────────────────────

void showWelcomeBackDialog(BuildContext context) {
  showDialog(
    context: context,
    barrierDismissible: false,
    builder: (_) => _WelcomeBackDialog(
      onDone: () {
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (_) => const HomeScreen()),
          (route) => false,
        );
      },
    ),
  );
}

class _WelcomeBackDialog extends StatefulWidget {
  final VoidCallback onDone;
  const _WelcomeBackDialog({required this.onDone});

  @override
  State<_WelcomeBackDialog> createState() => _WelcomeBackDialogState();
}

class _WelcomeBackDialogState extends State<_WelcomeBackDialog>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final List<_WbParticle> _particles;

  static const _kColors = [
    Color(0xFFFFCC00),
    Color(0xFFFF6B6B),
    Color(0xFF4ECDC4),
    Color(0xFF45B7D1),
    Color(0xFF96CEB4),
    Color(0xFFFF9A3C),
    Color(0xFFA78BFA),
    Colors.white,
  ];

  @override
  void initState() {
    super.initState();
    final rng = Random();
    _particles = List.generate(70, (_) {
      final angle = rng.nextDouble() * pi * 2;
      final speed = rng.nextDouble() * 2.5 + 1.0;
      return _WbParticle(
        vx: cos(angle) * speed,
        vy: sin(angle) * speed - 2.5,
        size: rng.nextDouble() * 9 + 4,
        rotation: rng.nextDouble() * pi * 2,
        rotSpeed: (rng.nextDouble() - 0.5) * 6,
        color: _kColors[rng.nextInt(_kColors.length)],
      );
    });
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2200),
    )..forward();
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 30),
      child: Stack(
        alignment: Alignment.center,
        clipBehavior: Clip.none,
        children: [
          Container(
            padding: const EdgeInsets.fromLTRB(24, 36, 24, 28),
            decoration: BoxDecoration(
              color: const Color(0xFF7C3AED),
              borderRadius: BorderRadius.circular(24),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 120,
                  height: 120,
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.18),
                    shape: BoxShape.circle,
                  ),
                  child: const Center(
                    child: Text('👋', style: TextStyle(fontSize: 58)),
                  ),
                ),
                const SizedBox(height: 24),
                Text(
                  'Welcome Back!',
                  style: GoogleFonts.poppins(
                    fontSize: 22,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Great to see you again.\nReady to explore?',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.poppins(
                    fontSize: 13,
                    color: Colors.white.withOpacity(0.82),
                    height: 1.55,
                  ),
                ),
                const SizedBox(height: 28),
                SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: ElevatedButton(
                    onPressed: widget.onDone,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFFFCC00),
                      foregroundColor: const Color(0xFF1A1A2E),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                      elevation: 0,
                    ),
                    child: Text(
                      "Let's Go!",
                      style: GoogleFonts.poppins(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          Positioned.fill(
            child: IgnorePointer(
              child: AnimatedBuilder(
                animation: _ctrl,
                builder: (_, __) => CustomPaint(
                  painter: _WbConfettiPainter(
                    progress: _ctrl.value,
                    particles: _particles,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _WbParticle {
  final double vx, vy, size, rotation, rotSpeed;
  final Color color;
  const _WbParticle({
    required this.vx,
    required this.vy,
    required this.size,
    required this.rotation,
    required this.rotSpeed,
    required this.color,
  });
}

class _WbConfettiPainter extends CustomPainter {
  final double progress;
  final List<_WbParticle> particles;

  _WbConfettiPainter({required this.progress, required this.particles});

  @override
  void paint(Canvas canvas, Size size) {
    final cx = size.width / 2;
    final cy = size.height / 2;
    for (final p in particles) {
      final t = progress;
      final x = cx + p.vx * t * 160;
      final y = cy + p.vy * t * 160 + 320 * t * t;
      final alpha = t < 0.55 ? 1.0 : 1.0 - ((t - 0.55) / 0.45);
      if (alpha <= 0) continue;
      final paint = Paint()..color = p.color.withOpacity(alpha.clamp(0.0, 1.0));
      canvas.save();
      canvas.translate(x, y);
      canvas.rotate(p.rotation + t * p.rotSpeed);
      canvas.drawRect(
        Rect.fromCenter(center: Offset.zero, width: p.size, height: p.size * 0.45),
        paint,
      );
      canvas.restore();
    }
  }

  @override
  bool shouldRepaint(_WbConfettiPainter old) => old.progress != progress;
}

// ─────────────────────────────────────────────

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
