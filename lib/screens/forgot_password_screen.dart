import 'dart:math';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../services/auth_service.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final _emailCtrl = TextEditingController();
  bool _loading = false;

  @override
  void dispose() {
    _emailCtrl.dispose();
    super.dispose();
  }

  Future<void> _onSubmit() async {
    final email = _emailCtrl.text.trim();

    if (email.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter your email address')),
      );
      return;
    }

    if (!email.contains('@')) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a valid email address')),
      );
      return;
    }

    setState(() => _loading = true);

    final result = await AuthService.forgotPassword(email: email);

    if (!mounted) return;
    setState(() => _loading = false);

    if (result['success'] == true) {
      _showEmailSentDialog(email);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(result['message'] ?? 'Failed to send reset link'),
          backgroundColor: const Color(0xFFE53935),
        ),
      );
    }
  }

  void _showEmailSentDialog(String email) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => _ResetEmailSentDialog(
        email: email,
        onOkay: () => Navigator.of(context).pop(), // back to login
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
              margin: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
              padding: const EdgeInsets.fromLTRB(24, 28, 24, 32),
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
                children: [

                  // ── Back button ──────────────────────────────────────────
                  Align(
                    alignment: Alignment.centerLeft,
                    child: GestureDetector(
                      onTap: () => Navigator.pop(context),
                      child: Container(
                        width: 38,
                        height: 38,
                        decoration: const BoxDecoration(
                          color: Color(0xFFF5F5F5),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.arrow_back_ios_new_rounded,
                            size: 16, color: Color(0xFF1A1A1A)),
                      ),
                    ),
                  ),

                  const SizedBox(height: 24),

                  // ── Illustration ─────────────────────────────────────────
                  SizedBox(
                    width: 140,
                    height: 140,
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        Container(
                          width: 120,
                          height: 120,
                          decoration: const BoxDecoration(
                            color: Color(0xFFFDE8EC),
                            shape: BoxShape.circle,
                          ),
                        ),
                        Container(
                          width: 82,
                          height: 82,
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [Color(0xFF3B82F6), Color(0xFF2563EB)],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: const Color(0xFF3B82F6).withOpacity(0.35),
                                blurRadius: 18,
                                offset: const Offset(0, 8),
                              ),
                            ],
                          ),
                          child: const Icon(
                            Icons.lock_reset_rounded,
                            color: Colors.white,
                            size: 38,
                          ),
                        ),
                        // Yellow dot top-right
                        Positioned(
                          top: 12,
                          right: 14,
                          child: Container(
                            width: 12,
                            height: 12,
                            decoration: const BoxDecoration(
                              color: Color(0xFFFFD014),
                              shape: BoxShape.circle,
                            ),
                          ),
                        ),
                        // Yellow dot bottom-left
                        Positioned(
                          bottom: 16,
                          left: 12,
                          child: Container(
                            width: 9,
                            height: 9,
                            decoration: const BoxDecoration(
                              color: Color(0xFFFFD014),
                              shape: BoxShape.circle,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 22),

                  // ── Title ────────────────────────────────────────────────
                  Text(
                    'Forgot Password?',
                    style: GoogleFonts.poppins(
                      fontSize: 22,
                      fontWeight: FontWeight.w700,
                      color: const Color(0xFF1A1A1A),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    "Enter your registered email and we'll\nsend you a reset link.",
                    style: GoogleFonts.poppins(
                      fontSize: 13,
                      color: const Color(0xFF9E9E9E),
                      height: 1.5,
                    ),
                    textAlign: TextAlign.center,
                  ),

                  const SizedBox(height: 28),

                  // ── Email field ──────────────────────────────────────────
                  Container(
                    decoration: BoxDecoration(
                      color: const Color(0xFFF5F5F5),
                      borderRadius: BorderRadius.circular(26),
                    ),
                    child: TextField(
                      controller: _emailCtrl,
                      keyboardType: TextInputType.emailAddress,
                      style: GoogleFonts.poppins(
                          fontSize: 14, color: const Color(0xFF1A1A1A)),
                      decoration: InputDecoration(
                        prefixIcon: const Icon(Icons.mail_outline_rounded,
                            size: 20, color: Color(0xFFAFAFAF)),
                        hintText: 'Enter your email',
                        hintStyle: GoogleFonts.poppins(
                            fontSize: 14, color: const Color(0xFFB8B8B8)),
                        border: InputBorder.none,
                        contentPadding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 16),
                      ),
                    ),
                  ),

                  const SizedBox(height: 24),

                  // ── Submit button ────────────────────────────────────────
                  Container(
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
                      onPressed: _loading ? null : _onSubmit,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFFFCC00),
                        foregroundColor: const Color(0xFF1A1A1A),
                        disabledBackgroundColor:
                            const Color(0xFFFFCC00).withOpacity(0.7),
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                      ),
                      child: _loading
                          ? const SizedBox(
                              width: 22,
                              height: 22,
                              child: CircularProgressIndicator(
                                strokeWidth: 2.5,
                                color: Color(0xFF1A1A1A),
                              ),
                            )
                          : Text(
                              'Send Reset Link',
                              style: GoogleFonts.poppins(
                                fontSize: 15,
                                fontWeight: FontWeight.w700,
                                color: const Color(0xFF1A1A1A),
                              ),
                            ),
                    ),
                  ),

                  const SizedBox(height: 20),

                  // ── Back to login link ────────────────────────────────────
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: RichText(
                      text: TextSpan(
                        style: GoogleFonts.poppins(
                            fontSize: 13, color: const Color(0xFF9E9E9E)),
                        children: [
                          const TextSpan(text: 'Remember your password? '),
                          TextSpan(
                            text: 'Log In',
                            style: GoogleFonts.poppins(
                              fontSize: 13,
                              fontWeight: FontWeight.w700,
                              color: const Color(0xFF1A1A1A),
                            ),
                          ),
                        ],
                      ),
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

// ── Reset email sent dialog ───────────────────────────────────────────────────

class _ResetEmailSentDialog extends StatefulWidget {
  final String email;
  final VoidCallback onOkay;

  const _ResetEmailSentDialog({required this.email, required this.onOkay});

  @override
  State<_ResetEmailSentDialog> createState() => _ResetEmailSentDialogState();
}

class _ResetEmailSentDialogState extends State<_ResetEmailSentDialog>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final List<_Particle> _particles;

  @override
  void initState() {
    super.initState();
    final rng = Random();
    _particles = List.generate(55, (_) => _Particle(rng));
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
      insetPadding: const EdgeInsets.symmetric(horizontal: 28),
      child: AnimatedBuilder(
        animation: _ctrl,
        builder: (_, __) => Stack(
          clipBehavior: Clip.none,
          alignment: Alignment.topCenter,
          children: [
            // Confetti
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
                  // Icon
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
                    'Check Your Email',
                    style: GoogleFonts.poppins(
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                    textAlign: TextAlign.center,
                  ),

                  const SizedBox(height: 12),

                  Text(
                    "We've sent a password reset link to",
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
                    'Click the link in your inbox to\nreset your password.',
                    style: GoogleFonts.poppins(
                      fontSize: 13,
                      color: Colors.white.withOpacity(0.8),
                      height: 1.5,
                    ),
                    textAlign: TextAlign.center,
                  ),

                  const SizedBox(height: 28),

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
    final cy = size.height * 0.3;

    for (final p in particles) {
      final t = progress;
      final x = cx + p.vx * t * 180;
      final y = cy + p.vy * t * 180 + 340 * t * t;
      final alpha =
          t > 0.55 ? (1.0 - (t - 0.55) / 0.45).clamp(0.0, 1.0) : 1.0;

      canvas.save();
      canvas.translate(x, y);
      canvas.rotate(p.rotation + p.rotSpeed * t);
      canvas.drawRect(
        Rect.fromCenter(
            center: Offset.zero, width: p.size, height: p.size * 0.5),
        Paint()..color = p.color.withOpacity(alpha),
      );
      canvas.restore();
    }
  }

  @override
  bool shouldRepaint(_ConfettiPainter old) => old.progress != progress;
}
