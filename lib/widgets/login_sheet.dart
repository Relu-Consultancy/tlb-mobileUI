import 'dart:async';
import '../core/app_colors.dart';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:firebase_auth/firebase_auth.dart' as fb;
import '../core/app_snackbar.dart';
import '../core/firebase_bootstrap.dart';
import '../core/google_auth_error.dart';
import '../widgets/app_loader.dart';
import '../services/auth_service.dart';
import '../providers/auth_state.dart';
import '../providers/saved_events_state.dart';
import '../core/responsive.dart';
import '../screens/home_screen.dart';
import '../screens/edit_profile_screen.dart';
import '../screens/otp_verification_screen.dart';
import '../screens/signup_screen.dart';
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
      AppSnackBar.show(context, 'Please enter your email address');
      return;
    }
    setState(() => _loading = true);
    // purpose: 'login' — backend rejects unregistered emails (USER_NOT_FOUND)
    // and never sends an OTP, instead of auto-creating an account.
    final result =
        await AuthService.requestOtp(identifier: email, purpose: 'login');
    if (!mounted) return;
    setState(() => _loading = false);
    if (result['success'] == true) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => OtpVerificationScreen(
            identifier: email,
            onExistingUser: showWelcomeBackDialog,
            isLoginFlow: true,
          ),
        ),
      );
    } else {
      AppSnackBar.error(context, result['message'] ?? 'Failed to send OTP');
    }
  }

  Future<void> _onGoogleSignIn() async {
    setState(() => _loading = true);
    try {
      // Make sure Firebase is initialised before any FirebaseAuth access —
      // see comment in signup_screen._onGoogleSignUp.
      await FirebaseBootstrap.ensureInitialized();

      // Force the account picker every time
      final googleSignIn = GoogleSignIn(scopes: ['email', 'profile']);
      await googleSignIn.signOut();
      final googleUser = await googleSignIn.signIn();

      if (googleUser == null) {
        // User cancelled the picker
        if (!mounted) return;
        setState(() => _loading = false);
        return;
      }

      // Get Google credentials
      final googleAuth = await googleUser.authentication;

      // Sign into Firebase with the Google credential to get a Firebase ID token.
      // The backend verifies this Firebase token, not the raw Google token.
      final credential = fb.GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );
      final fbCredential =
          await fb.FirebaseAuth.instance.signInWithCredential(credential);
      final firebaseIdToken = await fbCredential.user?.getIdToken();

      if (firebaseIdToken == null) {
        if (!mounted) return;
        setState(() => _loading = false);
        AppSnackBar.error(context, 'Google authentication failed. Please try again.');
        return;
      }

      debugPrint('[Google Login] Firebase ID token obtained, calling API...');
      final result = await AuthService.googleSignIn(idToken: firebaseIdToken);

      if (!mounted) return;
      setState(() => _loading = false);

      if (result['success'] == true) {
        AuthState.login(
          access: result['access'] as String?,
          refresh: result['refresh'] as String?,
          user: result['user'] as Map<String, dynamic>?,
        );
        SavedEventsState.loadFromApi();

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
        debugPrint('[Google Login] API error: ${result['message']}');
        AppSnackBar.error(context, result['message'] ?? 'Google sign-in failed. Please try again.');
      }
    } catch (e, stack) {
      if (!mounted) return;
      setState(() => _loading = false);
      debugPrint('[Google Login] Exception (${e.runtimeType}): $e\n$stack');
      AppSnackBar.error(context, googleAuthErrorMessage(e));
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

                  const SizedBox(height: 16),

                  // ── Illustration ────────────────────────────────────────
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
                            color: Color(0xFFFDE8EC),
                            shape: BoxShape.circle,
                          ),
                        ),
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
                        Transform.rotate(
                          angle: -0.13,
                          child: Container(
                            width: 90,
                            height: 90,
                            decoration: BoxDecoration(
                              gradient: const LinearGradient(
                                colors: [
                                  Color(0xFFFF3D7F),
                                  Color(0xFFFF8FAB)
                                ],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                              borderRadius: BorderRadius.circular(22),
                              boxShadow: [
                                BoxShadow(
                                  color:
                                      const Color(0xFFFF3D7F).withOpacity(0.35),
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
                      fontWeight: FontWeight.w500,
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

                  // ── Send OTP button ─────────────────────────────────────
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
                  _GoogleButton(
                    onTap: _loading ? null : _onGoogleSignIn,
                  ),

                  const SizedBox(height: 18),

                  // ── New user — navigate to Signup screen ────────────────
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        "New here? ",
                        style: GoogleFonts.poppins(
                          fontSize: Responsive.sp(context, 13.5),
                          color: const Color(0xFF9E9E9E),
                        ),
                      ),
                      GestureDetector(
                        onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (_) => const SignupScreen()),
                        ),
                        child: Text(
                          'Signup',
                          style: GoogleFonts.poppins(
                            fontSize: Responsive.sp(context, 13.5),
                            fontWeight: FontWeight.w500,
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
      ),
      child: ElevatedButton(
        onPressed: loading ? null : onTap,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primaryLight,
          foregroundColor: const Color(0xFF1A1A1A),
          disabledBackgroundColor: AppColors.primaryLight.withOpacity(0.7),
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(30),
          ),
        ),
        child: loading
            ? const AppLoaderInline(
                dotSize: 7, spacing: 4, color: AppColors.textPrimary)
            : Text(
                label,
                style: GoogleFonts.poppins(
                  fontSize: Responsive.sp(context, 15),
                  fontWeight: FontWeight.w500,
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
              fontSize: Responsive.sp(context, 12),
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

// ─────────────────────────────────────────────
// WELCOME BACK DIALOG
// ─────────────────────────────────────────────

void showWelcomeBackDialog(BuildContext context) {
  // Capture the ROOT navigator before the dialog is pushed. Using
  // rootNavigator:true guards against nested Navigators (e.g. inside a
  // showcase overlay) ending up with a stale reference, and also keeps
  // this safe to call from a context whose underlying route has been
  // removed by the post-dialog pushAndRemoveUntil.
  final navigator = Navigator.of(context, rootNavigator: true);
  showDialog(
    context: context,
    barrierDismissible: false,
    useRootNavigator: true,
    builder: (dialogContext) => _WelcomeBackDialog(
      onDone: () {
        // Dismiss the dialog first — pushing HomeScreen with predicate=false
        // while a dialog is still on top leaves a one-frame gap where neither
        // is painted, which manifests as a grey flash.
        Navigator.of(dialogContext, rootNavigator: true).pop();
        navigator.pushAndRemoveUntil(
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
    AppColors.primaryLight,
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
                  child: Center(
                    child: Text('👋', style: TextStyle(fontSize: Responsive.sp(context, 58))),
                  ),
                ),
                const SizedBox(height: 24),
                Text(
                  'Welcome Back!',
                  style: GoogleFonts.poppins(
                    fontSize: Responsive.sp(context, 22),
                    fontWeight: FontWeight.w500,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Great to see you again.\nReady to explore?',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.poppins(
                    fontSize: Responsive.sp(context, 13),
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
                      backgroundColor: AppColors.primaryLight,
                      foregroundColor: AppColors.textPrimary,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                      elevation: 0,
                    ),
                    child: Text(
                      "Let's Go!",
                      style: GoogleFonts.poppins(
                        fontSize: Responsive.sp(context, 16),
                        fontWeight: FontWeight.w500,
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
      final paint = Paint()
        ..color = p.color.withOpacity(alpha.clamp(0.0, 1.0));
      canvas.save();
      canvas.translate(x, y);
      canvas.rotate(p.rotation + t * p.rotSpeed);
      canvas.drawRect(
        Rect.fromCenter(
            center: Offset.zero, width: p.size, height: p.size * 0.45),
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
              'resources- tlb-ui/google.png',
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
                fontSize: Responsive.sp(context, 14.5),
                fontWeight: FontWeight.w500,
                color: const Color(0xFF3C3C3C),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
