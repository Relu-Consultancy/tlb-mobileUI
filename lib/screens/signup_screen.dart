import 'dart:async';
import 'dart:io';
import 'dart:math';
import 'package:flutter/material.dart';
import '../widgets/app_loader.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_sign_in/google_sign_in.dart';
import '../services/auth_service.dart';
import '../services/walkthrough_service.dart';
import '../providers/auth_state.dart';
import '../providers/saved_events_state.dart';
import '../core/responsive.dart';
import '../widgets/login_sheet.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _contactController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  String? _passwordError;
  bool _loading = false;

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _contactController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _onSignUp() async {
    final firstName = _firstNameController.text.trim();
    final email = _contactController.text.trim();
    final password = _passwordController.text;
    final confirmPassword = _confirmPasswordController.text;

    if (firstName.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('First name is required')),
      );
      return;
    }

    if (email.isEmpty || password.isEmpty || confirmPassword.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill in all required fields')),
      );
      return;
    }

    if (password != confirmPassword) {
      setState(() => _passwordError = 'Passwords do not match');
      return;
    }

    setState(() {
      _passwordError = null;
      _loading = true;
    });

    final result = await AuthService.requestOtp(identifier: email);

    if (!mounted) return;
    setState(() => _loading = false);

    if (result['success'] == true) {
      await WalkthroughService.markAsNewUser();
      if (!mounted) return;
      _showEmailVerificationDialog(email);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(result['message'] ?? 'Signup failed'),
          backgroundColor: const Color(0xFFE53935),
        ),
      );
    }
  }

  void _showEmailVerificationDialog(String email) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => _EmailVerificationDialog(
        email: email,
        onOkay: () {
          Navigator.of(context).pushAndRemoveUntil(
            MaterialPageRoute(builder: (_) => const LoginScreen()),
            (route) => false,
          );
        },
      ),
    );
  }

  Future<void> _onGoogleSignUp() async {
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
      final idToken = googleAuth.idToken;

      if (idToken == null) {
        if (!mounted) return;
        setState(() => _loading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Google sign-up failed. Try again.')),
        );
        return;
      }

      final result = await AuthService.googleSignIn(idToken: idToken);

      if (!mounted) return;
      setState(() => _loading = false);

      if (result['success'] == true) {
        AuthState.login(
          access: result['access'] as String?,
          refresh: result['refresh'] as String?,
          user: result['user'] as Map<String, dynamic>?,
        );
        SavedEventsState.loadFromApi(); // fire-and-forget
        if (result['is_new_user'] == true) {
          await WalkthroughService.markAsNewUser();
        }
        if (!mounted) return;
        showWelcomeBackDialog(context);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(result['message'] ?? 'Google sign-up failed'),
            backgroundColor: const Color(0xFFE53935),
          ),
        );
      }
    } catch (e) {
      if (!mounted) return;
      setState(() => _loading = false);
      final msg = e is SocketException
          ? 'No internet connection. Please check and try again.'
          : e is TimeoutException
              ? 'Connection timed out. Please try again.'
              : 'Google sign-up failed. Please try again.';
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(msg),
          backgroundColor: const Color(0xFFE53935),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFD9D9D9),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            child: Container(
              width: Responsive.cardWidth(context, fraction: 0.88, max: 400),
              margin: EdgeInsets.symmetric(
                  horizontal: Responsive.w(context, 22),
                  vertical: Responsive.h(context, 32)),
              padding: EdgeInsets.fromLTRB(
                Responsive.w(context, 24),
                Responsive.h(context, 20),
                Responsive.w(context, 24),
                Responsive.h(context, 28),
              ),
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

                  // ── Illustration ──────────────────────────────────────────
                  SizedBox(
                    width: 152,
                    height: 152,
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        Container(
                          width: 132,
                          height: 132,
                          decoration: const BoxDecoration(
                            color: Color(0xFFFDE3D8),
                            shape: BoxShape.circle,
                          ),
                        ),
                        Container(
                          width: 98,
                          height: 98,
                          decoration: const BoxDecoration(
                            color: Color(0xFFFFF9D0),
                            shape: BoxShape.circle,
                          ),
                        ),
                        const Icon(
                          Icons.person_add_alt_1_rounded,
                          color: Color(0xFF1A73E8),
                          size: 44,
                        ),
                        Positioned(
                          top: 18,
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
                        Positioned(
                          bottom: 18,
                          right: 12,
                          child: Container(
                            width: 14,
                            height: 14,
                            decoration: const BoxDecoration(
                              color: Color(0xFFFFD014),
                              shape: BoxShape.circle,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                  // ── Title ─────────────────────────────────────────────────
                  Text(
                    'Create Account',
                    style: GoogleFonts.poppins(
                      fontSize: Responsive.sp(context, 22),
                      fontWeight: FontWeight.w700,
                      color: const Color(0xFF1A1A1A),
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Join us to find the best events!',
                    style: GoogleFonts.poppins(
                      fontSize: Responsive.sp(context, 13),
                      color: const Color(0xFF9E9E9E),
                    ),
                    textAlign: TextAlign.center,
                  ),

                  const SizedBox(height: 26),

                  // ── Input fields ──────────────────────────────────────────
                  _InputField(
                    controller: _firstNameController,
                    hint: 'First Name *',
                    icon: Icons.person_outline_rounded,
                    keyboardType: TextInputType.name,
                  ),
                  const SizedBox(height: 14),
                  _InputField(
                    controller: _lastNameController,
                    hint: 'Last Name (optional)',
                    icon: Icons.person_outline_rounded,
                    keyboardType: TextInputType.name,
                  ),
                  const SizedBox(height: 14),
                  _InputField(
                    controller: _contactController,
                    hint: 'Email',
                    icon: Icons.mail_outline_rounded,
                    keyboardType: TextInputType.emailAddress,
                  ),
                  const SizedBox(height: 14),
                  _InputField(
                    controller: _passwordController,
                    hint: 'Create Password',
                    icon: Icons.lock_outline_rounded,
                    obscureText: _obscurePassword,
                    suffix: GestureDetector(
                      onTap: () =>
                          setState(() => _obscurePassword = !_obscurePassword),
                      child: Icon(
                        _obscurePassword
                            ? Icons.visibility_off_outlined
                            : Icons.visibility_outlined,
                        size: 20,
                        color: const Color(0xFFAFAFAF),
                      ),
                    ),
                  ),
                  const SizedBox(height: 14),
                  _InputField(
                    controller: _confirmPasswordController,
                    hint: 'Confirm Password',
                    icon: Icons.lock_outline_rounded,
                    obscureText: _obscureConfirmPassword,
                    hasError: _passwordError != null,
                    suffix: GestureDetector(
                      onTap: () => setState(
                          () => _obscureConfirmPassword = !_obscureConfirmPassword),
                      child: Icon(
                        _obscureConfirmPassword
                            ? Icons.visibility_off_outlined
                            : Icons.visibility_outlined,
                        size: 20,
                        color: const Color(0xFFAFAFAF),
                      ),
                    ),
                  ),
                  if (_passwordError != null) ...[
                    const SizedBox(height: 6),
                    Padding(
                      padding: const EdgeInsets.only(left: 16),
                      child: Row(
                        children: [
                          const Icon(Icons.error_outline_rounded,
                              size: 14, color: Color(0xFFE53935)),
                          const SizedBox(width: 5),
                          Text(
                            _passwordError!,
                            style: GoogleFonts.poppins(
                              fontSize: 12,
                              color: const Color(0xFFE53935),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],

                  const SizedBox(height: 22),

                  // ── Sign up button ────────────────────────────────────────
                  _PrimaryButton(
                    label: 'Create Account',
                    loading: _loading,
                    onTap: _onSignUp,
                  ),

                  const SizedBox(height: 24),

                  // ── OR divider ────────────────────────────────────────────
                  const _OrDivider(),

                  const SizedBox(height: 24),

                  // ── Continue with Google ──────────────────────────────────
                  _GoogleButton(onTap: _loading ? null : _onGoogleSignUp),

                  const SizedBox(height: 22),

                  // ── Already have an account? ──────────────────────────────
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Already have an account? ',
                        style: GoogleFonts.poppins(
                          fontSize: 13.5,
                          color: const Color(0xFF9E9E9E),
                        ),
                      ),
                      GestureDetector(
                        onTap: () {
                          if (Navigator.canPop(context)) {
                            Navigator.pop(context);
                          } else {
                            Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(
                                  builder: (_) => const LoginScreen()),
                            );
                          }
                        },
                        child: Text(
                          'Log In',
                          style: GoogleFonts.poppins(
                            fontSize: 13.5,
                            fontWeight: FontWeight.w700,
                            color: const Color(0xFF1A1A1A),
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 4),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ── Email verification success dialog ────────────────────────────────────────

class _EmailVerificationDialog extends StatefulWidget {
  final String email;
  final VoidCallback onOkay;

  const _EmailVerificationDialog({required this.email, required this.onOkay});

  @override
  State<_EmailVerificationDialog> createState() =>
      _EmailVerificationDialogState();
}

class _EmailVerificationDialogState extends State<_EmailVerificationDialog>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final List<_Particle> _particles;

  @override
  void initState() {
    super.initState();
    final rng = Random();
    _particles = List.generate(60, (_) => _Particle(rng));
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2400),
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
      insetPadding: const EdgeInsets.symmetric(horizontal: 28),
      child: AnimatedBuilder(
        animation: _ctrl,
        builder: (_, __) => Stack(
          clipBehavior: Clip.none,
          alignment: Alignment.topCenter,
          children: [
            // Confetti layer
            Positioned.fill(
              child: CustomPaint(
                painter: _ConfettiPainter(_ctrl.value, _particles),
              ),
            ),

            // Card
            Container(
              decoration: BoxDecoration(
                color: const Color(0xFF1D4ED8),
                borderRadius: BorderRadius.circular(24),
              ),
              padding: const EdgeInsets.fromLTRB(24, 32, 24, 28),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Email icon circle
                  Container(
                    width: 72,
                    height: 72,
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.15),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.mark_email_read_rounded,
                      color: Colors.white,
                      size: 38,
                    ),
                  ),

                  const SizedBox(height: 20),

                  Text(
                    'Verify Your Email',
                    style: GoogleFonts.poppins(
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                    textAlign: TextAlign.center,
                  ),

                  const SizedBox(height: 12),

                  Text(
                    "We've sent a verification link to",
                    style: GoogleFonts.poppins(
                      fontSize: 13,
                      color: Colors.white.withOpacity(0.8),
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    widget.email,
                    style: GoogleFonts.poppins(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Click the link in your inbox to\nactivate your account.',
                    style: GoogleFonts.poppins(
                      fontSize: 13,
                      color: Colors.white.withOpacity(0.8),
                      height: 1.5,
                    ),
                    textAlign: TextAlign.center,
                  ),

                  const SizedBox(height: 28),

                  // Okay button
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.of(context).pop();
                        widget.onOkay();
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFFFCC00),
                        foregroundColor: const Color(0xFF1A1A2E),
                        elevation: 0,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                      ),
                      child: Text(
                        'Okay, Got it!',
                        style: GoogleFonts.poppins(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Confetti ──────────────────────────────────────────────────────────────────

class _Particle {
  final double vx, vy, size, rotation, rotSpeed;
  final Color color;

  _Particle(Random rng)
      : vx = (rng.nextDouble() - 0.5) * 2.8,
        vy = -(rng.nextDouble() * 2.2 + 0.6),
        size = rng.nextDouble() * 8 + 4,
        rotation = rng.nextDouble() * 2 * pi,
        rotSpeed = (rng.nextDouble() - 0.5) * 6,
        color = [
          const Color(0xFFFFCC00),
          const Color(0xFF60A5FA),
          const Color(0xFF34D399),
          const Color(0xFFF472B6),
          const Color(0xFFA78BFA),
          Colors.white,
        ][rng.nextInt(6)];
}

class _ConfettiPainter extends CustomPainter {
  final double progress;
  final List<_Particle> particles;

  _ConfettiPainter(this.progress, this.particles);

  @override
  void paint(Canvas canvas, Size size) {
    final cx = size.width / 2;
    final cy = size.height * 0.35;

    for (final p in particles) {
      final t = progress;
      final x = cx + p.vx * t * 180;
      final y = cy + p.vy * t * 180 + 340 * t * t;
      final alpha = t > 0.55 ? (1.0 - (t - 0.55) / 0.45).clamp(0.0, 1.0) : 1.0;

      canvas.save();
      canvas.translate(x, y);
      canvas.rotate(p.rotation + p.rotSpeed * t);
      canvas.drawRect(
        Rect.fromCenter(center: Offset.zero, width: p.size, height: p.size * 0.5),
        Paint()..color = p.color.withOpacity(alpha),
      );
      canvas.restore();
    }
  }

  @override
  bool shouldRepaint(_ConfettiPainter old) => old.progress != progress;
}

// ── Shared UI widgets ─────────────────────────────────────────────────────────

class _InputField extends StatelessWidget {
  final TextEditingController controller;
  final String hint;
  final IconData icon;
  final TextInputType? keyboardType;
  final bool obscureText;
  final bool hasError;
  final Widget? suffix;

  const _InputField({
    required this.controller,
    required this.hint,
    required this.icon,
    this.keyboardType,
    this.obscureText = false,
    this.hasError = false,
    this.suffix,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: hasError ? const Color(0xFFFFF0F0) : const Color(0xFFF5F5F5),
        borderRadius: BorderRadius.circular(26),
        border: hasError
            ? Border.all(color: const Color(0xFFE53935), width: 1.2)
            : null,
      ),
      child: TextField(
        controller: controller,
        keyboardType: keyboardType,
        obscureText: obscureText,
        style: GoogleFonts.poppins(
            fontSize: Responsive.sp(context, 14),
            color: const Color(0xFF1A1A1A)),
        decoration: InputDecoration(
          prefixIcon: Padding(
            padding: EdgeInsets.only(left: Responsive.w(context, 6)),
            child: Icon(icon,
                size: Responsive.sp(context, 20),
                color: const Color(0xFFAFAFAF)),
          ),
          hintText: hint,
          hintStyle: GoogleFonts.poppins(
              fontSize: Responsive.sp(context, 14),
              color: const Color(0xFFB8B8B8)),
          border: InputBorder.none,
          contentPadding: EdgeInsets.symmetric(
              horizontal: Responsive.w(context, 8),
              vertical: Responsive.h(context, 16)),
          suffixIcon: suffix == null
              ? null
              : Padding(
                  padding: const EdgeInsets.only(right: 14), child: suffix),
          suffixIconConstraints:
              const BoxConstraints(minWidth: 24, minHeight: 24),
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
      height: Responsive.h(context, 52, min: 48),
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
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
        ),
        child: loading
            ? const AppLoaderInline(dotSize: 7, spacing: 4, color: Color(0xFF1A1A2E))
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
        const Expanded(
            child: Divider(color: Color(0xFFE8E8E8), thickness: 1.2)),
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
        const Expanded(
            child: Divider(color: Color(0xFFE8E8E8), thickness: 1.2)),
      ],
    );
  }
}

class _GoogleButton extends StatelessWidget {
  final VoidCallback? onTap;
  const _GoogleButton({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: Responsive.h(context, 52, min: 48),
      child: OutlinedButton(
        onPressed: onTap,
        style: OutlinedButton.styleFrom(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
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
                  size: 34),
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
