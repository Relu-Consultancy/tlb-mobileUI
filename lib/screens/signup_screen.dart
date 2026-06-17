import 'dart:async';
import '../core/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:firebase_auth/firebase_auth.dart' as fb;
import '../core/app_snackbar.dart';
import '../core/firebase_bootstrap.dart';
import '../core/google_auth_error.dart';
import '../services/auth_service.dart';
import '../services/walkthrough_service.dart';
import '../providers/auth_state.dart';
import '../providers/saved_events_state.dart';
import '../core/responsive.dart';
import '../widgets/app_loader.dart';
import '../screens/otp_verification_screen.dart';
import '../screens/edit_profile_screen.dart';
import '../screens/home_screen.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final _emailController = TextEditingController();
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
    // purpose: 'register' — OTP is sent to any email; the account is created
    // on verify. (This is the signup flow.)
    final result =
        await AuthService.requestOtp(identifier: email, purpose: 'register');
    if (!mounted) return;
    setState(() => _loading = false);

    if (result['success'] == true) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => OtpVerificationScreen(
            identifier: email,
            // For existing users who land here: navigate to HomeScreen directly.
            // New users are handled inside OtpVerificationScreen (→ EditProfileScreen).
            onExistingUser: (ctx) => Navigator.of(ctx).pushAndRemoveUntil(
              MaterialPageRoute(builder: (_) => const HomeScreen()),
              (route) => false,
            ),
          ),
        ),
      );
    } else {
      AppSnackBar.error(context, result['message'] ?? 'Failed to send OTP');
    }
  }

  Future<void> _onGoogleSignUp() async {
    setState(() => _loading = true);
    try {
      // Make sure Firebase is up before any FirebaseAuth.instance access —
      // main.dart's startup init can fail transiently (e.g. cold-start
      // network blip) and we'd otherwise see "No Firebase App '[DEFAULT]'".
      await FirebaseBootstrap.ensureInitialized();

      // Force the account picker every time
      final googleSignIn = GoogleSignIn(scopes: ['email', 'profile']);
      await googleSignIn.signOut();
      final googleUser = await googleSignIn.signIn();

      if (googleUser == null) {
        if (!mounted) return;
        setState(() => _loading = false);
        return; // User cancelled
      }

      // Get Google credentials
      final googleAuth = await googleUser.authentication;

      // Sign into Firebase to get a Firebase ID token for the backend
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

      debugPrint('[Google Signup] Firebase ID token obtained, calling API...');
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
          // Existing user signed in via Google on signup screen — take them home
          Navigator.of(context).pushAndRemoveUntil(
            MaterialPageRoute(builder: (_) => const HomeScreen()),
            (route) => false,
          );
        }
      } else {
        debugPrint('[Google Signup] API error: ${result['message']}');
        AppSnackBar.error(context, result['message'] ?? 'Google sign-up failed. Please try again.');
      }
    } catch (e, stack) {
      if (!mounted) return;
      setState(() => _loading = false);
      debugPrint('[Google Signup] Exception (${e.runtimeType}): $e\n$stack');
      AppSnackBar.error(context, googleAuthErrorMessage(e));
    }
  }

  /// Partner sign-up lives in a separate web app — open it in the device's
  /// default browser. Wired to the "Continue as Event Partner" link.
  Future<void> _onContinueAsPartner() async {
    final uri = Uri.parse('https://tlbpartner.reluconsultancy.in/');
    final ok = await launchUrl(uri, mode: LaunchMode.externalApplication);
    if (!ok && mounted) {
      AppSnackBar.error(
        context,
        'Could not open the partner portal. Please try again.',
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
                    width: Responsive.w(context, 152),
                    height: Responsive.h(context, 152),
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        Container(
                          width: Responsive.w(context, 132),
                          height: Responsive.h(context, 132),
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
                      fontWeight: FontWeight.w500,
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

                  // ── Email input ───────────────────────────────────────────
                  _InputField(
                    controller: _emailController,
                    hint: 'Email Address',
                    icon: Icons.mail_outline_rounded,
                    keyboardType: TextInputType.emailAddress,
                  ),

                  const SizedBox(height: 22),

                  // ── Send OTP button ───────────────────────────────────────
                  _PrimaryButton(
                    label: 'Send OTP',
                    loading: _loading,
                    onTap: _onSendOTP,
                  ),

                  const SizedBox(height: 24),

                  // ── OR divider ────────────────────────────────────────────
                  const _OrDivider(),

                  const SizedBox(height: 24),

                  // ── Continue with Google ──────────────────────────────────
                  _GoogleButton(onTap: _loading ? null : _onGoogleSignUp),

                  const SizedBox(height: 18),

                  // ── Continue as Event Partner — external partner portal ───
                  TextButton(
                    onPressed: _loading ? null : _onContinueAsPartner,
                    style: TextButton.styleFrom(
                      minimumSize: Size.zero,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 4),
                    ),
                    child: Text(
                      'Continue as Event Partner',
                      style: GoogleFonts.poppins(
                        fontSize: Responsive.sp(context, 14),
                        fontWeight: FontWeight.w500,
                        color: const Color(0xFFE6A800),
                      ),
                    ),
                  ),

                  const SizedBox(height: 18),

                  // ── Already have an account? ──────────────────────────────
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Already have an account? ',
                        style: GoogleFonts.poppins(
                          fontSize: Responsive.sp(context, 13.5),
                          color: const Color(0xFF9E9E9E),
                        ),
                      ),
                      GestureDetector(
                        onTap: () => Navigator.pop(context),
                        child: Text(
                          'Log In',
                          style: GoogleFonts.poppins(
                            fontSize: Responsive.sp(context, 13.5),
                            fontWeight: FontWeight.w500,
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

// ── Shared UI widgets ─────────────────────────────────────────────────────────

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
          backgroundColor: AppColors.primaryLight,
          foregroundColor: const Color(0xFF1A1A1A),
          disabledBackgroundColor: AppColors.primaryLight.withOpacity(0.7),
          elevation: 0,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
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
              'resources- tlb-ui/google.png',
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

