import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../core/auth_state.dart';
import '../core/responsive.dart';
import 'home_screen.dart';
import 'signup_otp_screen.dart';
import 'login_sheet.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final _nameController = TextEditingController();
  final _contactController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;

  @override
  void dispose() {
    _nameController.dispose();
    _contactController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _onSendOTP() {
    final name = _nameController.text.trim();
    final contact = _contactController.text.trim();
    final password = _passwordController.text;

    if (name.isEmpty || contact.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill in all fields')),
      );
      return;
    }

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => SignupOtpScreen(
          email: contact.contains('@') ? contact : '',
          phone: contact.contains('@') ? '' : contact,
        ),
      ),
    );
  }

  void _onGoogleSignIn() {
    AuthState.login(name: 'Google User');
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => const HomeScreen()),
      (route) => false,
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

                  // ── Illustration ────────────────────────────────────────
                  SizedBox(
                    width: 152,
                    height: 152,
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        // Outer pale peach circle
                        Container(
                          width: 132,
                          height: 132,
                          decoration: const BoxDecoration(
                            color: Color(0xFFFDE3D8),
                            shape: BoxShape.circle,
                          ),
                        ),
                        // Inner pale yellow circle
                        Container(
                          width: 98,
                          height: 98,
                          decoration: const BoxDecoration(
                            color: Color(0xFFFFF9D0),
                            shape: BoxShape.circle,
                          ),
                        ),
                        // Blue user+ icon (floats freely — not inside a solid circle)
                        const Icon(
                          Icons.person_add_alt_1_rounded,
                          color: Color(0xFF1A73E8),
                          size: 44,
                        ),
                        // Yellow dot — top left
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
                        // Yellow dot — bottom right (larger)
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

                  // ── Title ───────────────────────────────────────────────
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

                  // ── Input fields ────────────────────────────────────────
                  _InputField(
                    controller: _nameController,
                    hint: 'Full Name',
                    icon: Icons.person_outline_rounded,
                    textCapitalization: TextCapitalization.words,
                  ),
                  const SizedBox(height: 14),
                  _InputField(
                    controller: _contactController,
                    hint: 'Phone Number / Email',
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

                  const SizedBox(height: 22),

                  // ── Send OTP button ─────────────────────────────────────
                  _PrimaryButton(label: 'Send OTP', onTap: _onSendOTP),

                  const SizedBox(height: 24),

                  // ── OR divider ──────────────────────────────────────────
                  const _OrDivider(),

                  const SizedBox(height: 24),

                  // ── Continue with Google ────────────────────────────────
                  _GoogleButton(onTap: _onGoogleSignIn),

                  const SizedBox(height: 22),

                  // ── Already have an account? ────────────────────────────
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
                        // pop to login (works because Login uses push, not pushReplacement)
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

// Shared UI components (mirror the ones in login_sheet.dart)
// These are separate classes so signup_screen.dart compiles standalone.

class _InputField extends StatelessWidget {
  final TextEditingController controller;
  final String hint;
  final IconData icon;
  final TextInputType? keyboardType;
  final TextCapitalization textCapitalization;
  final bool obscureText;
  final Widget? suffix;

  const _InputField({
    required this.controller,
    required this.hint,
    required this.icon,
    this.keyboardType,
    this.textCapitalization = TextCapitalization.none,
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
        textCapitalization: textCapitalization,
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
          contentPadding: EdgeInsets.symmetric(
              horizontal: Responsive.w(context, 8),
              vertical: Responsive.h(context, 16)),
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
        onPressed: onTap,
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFFFFCC00),
          foregroundColor: const Color(0xFF1A1A1A),
          elevation: 0,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
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
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
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
              errorBuilder: (_, __, ___) =>
                  const Icon(Icons.g_mobiledata, color: Color(0xFFDB4437), size: 34),
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
