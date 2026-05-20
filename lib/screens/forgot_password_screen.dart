import 'dart:math';
import 'package:flutter/material.dart';
import '../widgets/app_loader.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import '../core/responsive.dart';
import '../services/auth_service.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  int _step = 0;
  String _identifier = '';
  String _resetToken = '';
  bool _loading = false;

  // Step 0
  final _emailCtrl = TextEditingController();

  // Step 1 — OTP
  final List<TextEditingController> _otpCtrl =
      List.generate(6, (_) => TextEditingController());
  final List<FocusNode> _otpFocus = List.generate(6, (_) => FocusNode());

  // Step 2
  final _newPassCtrl = TextEditingController();
  final _confirmPassCtrl = TextEditingController();
  bool _showNewPass = false;
  bool _showConfirmPass = false;

  @override
  void dispose() {
    _emailCtrl.dispose();
    for (final c in _otpCtrl) { c.dispose(); }
    for (final f in _otpFocus) { f.dispose(); }
    _newPassCtrl.dispose();
    _confirmPassCtrl.dispose();
    super.dispose();
  }

  void _handleBack() {
    if (_step == 0) {
      Navigator.pop(context);
    } else {
      setState(() => _step--);
    }
  }

  // ── Step 0 ─────────────────────────────────────────────────────────────────

  Future<void> _onSendOtp() async {
    final email = _emailCtrl.text.trim();
    if (email.isEmpty || !email.contains('@')) {
      _snack('Please enter a valid email address');
      return;
    }
    setState(() => _loading = true);
    final result = await AuthService.forgotPassword(email: email);
    if (!mounted) return;
    setState(() => _loading = false);
    if (result['success'] == true) {
      setState(() {
        _identifier = email;
        _step = 1;
      });
    } else {
      _snack(result['message'] ?? 'Failed to send OTP', isError: true);
    }
  }

  // ── Step 1 ─────────────────────────────────────────────────────────────────

  Future<void> _onVerifyOtp() async {
    final code = _otpCtrl.map((c) => c.text).join();
    if (code.length < 6) {
      _snack('Enter all 6 digits');
      return;
    }
    setState(() => _loading = true);
    final result =
        await AuthService.verifyResetOtp(identifier: _identifier, code: code);
    if (!mounted) return;
    setState(() => _loading = false);
    if (result['success'] == true) {
      setState(() {
        _resetToken = result['reset_token'] as String? ?? '';
        _step = 2;
      });
    } else {
      _snack(result['message'] ?? 'Invalid OTP', isError: true);
    }
  }

  Future<void> _onResendOtp() async {
    final result = await AuthService.forgotPassword(email: _identifier);
    if (!mounted) return;
    if (result['success'] == true) {
      _snack('OTP resent to $_identifier');
    } else {
      _snack(result['message'] ?? 'Failed to resend OTP', isError: true);
    }
  }

  // ── Step 2 ─────────────────────────────────────────────────────────────────

  Future<void> _onSetPassword() async {
    final newPass = _newPassCtrl.text;
    final confirmPass = _confirmPassCtrl.text;
    if (newPass.isEmpty || confirmPass.isEmpty) {
      _snack('Please fill in both password fields');
      return;
    }
    if (newPass != confirmPass) {
      _snack('Passwords do not match', isError: true);
      return;
    }
    setState(() => _loading = true);
    final result = await AuthService.confirmPasswordReset(
      resetToken: _resetToken,
      newPassword: newPass,
      newPasswordConfirm: confirmPass,
    );
    if (!mounted) return;
    setState(() => _loading = false);
    if (result['success'] == true) {
      _showSuccessDialog();
    } else {
      _snack(result['message'] ?? 'Failed to reset password', isError: true);
    }
  }

  void _showSuccessDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => _PasswordResetSuccessDialog(
        onOkay: () {
          Navigator.of(context).pop(); // pop forgot screen → back to login
        },
      ),
    );
  }

  void _snack(String msg, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(msg),
      backgroundColor: isError ? const Color(0xFFE53935) : null,
    ));
  }

  // ── Build ───────────────────────────────────────────────────────────────────

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
                  // Back button
                  Align(
                    alignment: Alignment.centerLeft,
                    child: GestureDetector(
                      onTap: _handleBack,
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

                  if (_step == 0) _buildStep0(),
                  if (_step == 1) _buildStep1(),
                  if (_step == 2) _buildStep2(),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  // ── Step 0 widget ───────────────────────────────────────────────────────────

  Widget _buildStep0() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        _illustration(Icons.lock_reset_rounded),
        const SizedBox(height: 22),
        Text(
          'Forgot Password?',
          style: GoogleFonts.poppins(
            fontSize: Responsive.sp(context, 22),
            fontWeight: FontWeight.w700,
            color: const Color(0xFF1A1A1A),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          "Enter your registered email and we'll\nsend you a verification code.",
          style: GoogleFonts.poppins(
            fontSize: Responsive.sp(context, 13),
            color: const Color(0xFF9E9E9E),
            height: 1.5,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 28),
        _emailField(),
        const SizedBox(height: 24),
        _primaryButton(
          label: 'Send OTP',
          onTap: _loading ? null : _onSendOtp,
          loading: _loading,
        ),
        const SizedBox(height: 20),
        _backToLoginLink(),
      ],
    );
  }

  // ── Step 1 widget ───────────────────────────────────────────────────────────

  Widget _buildStep1() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        _illustration(Icons.verified_rounded),
        const SizedBox(height: 22),
        Text(
          'Enter OTP',
          style: GoogleFonts.poppins(
            fontSize: Responsive.sp(context, 22),
            fontWeight: FontWeight.w700,
            color: const Color(0xFF1A1A1A),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          "We've sent a 6-digit code to",
          style: GoogleFonts.poppins(
            fontSize: Responsive.sp(context, 13),
            color: const Color(0xFF9E9E9E),
            height: 1.5,
          ),
          textAlign: TextAlign.center,
        ),
        Text(
          _identifier,
          style: GoogleFonts.poppins(
            fontSize: Responsive.sp(context, 13),
            fontWeight: FontWeight.w600,
            color: const Color(0xFF1A1A1A),
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 28),
        _otpBoxes(),
        const SizedBox(height: 16),
        TextButton(
          onPressed: _onResendOtp,
          child: Text(
            'Resend OTP',
            style: GoogleFonts.poppins(
              fontSize: Responsive.sp(context, 13),
              fontWeight: FontWeight.w600,
              color: const Color(0xFF3B82F6),
            ),
          ),
        ),
        const SizedBox(height: 8),
        _primaryButton(
          label: 'Verify OTP',
          onTap: _loading ? null : _onVerifyOtp,
          loading: _loading,
        ),
      ],
    );
  }

  // ── Step 2 widget ───────────────────────────────────────────────────────────

  Widget _buildStep2() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        _illustration(Icons.lock_reset_rounded),
        const SizedBox(height: 22),
        Text(
          'Set New Password',
          style: GoogleFonts.poppins(
            fontSize: Responsive.sp(context, 22),
            fontWeight: FontWeight.w700,
            color: const Color(0xFF1A1A1A),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Choose a strong new password',
          style: GoogleFonts.poppins(
            fontSize: Responsive.sp(context, 13),
            color: const Color(0xFF9E9E9E),
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 28),
        _passwordField(
          controller: _newPassCtrl,
          hint: 'New Password',
          obscure: !_showNewPass,
          onToggle: () => setState(() => _showNewPass = !_showNewPass),
        ),
        const SizedBox(height: 14),
        _passwordField(
          controller: _confirmPassCtrl,
          hint: 'Confirm Password',
          obscure: !_showConfirmPass,
          onToggle: () =>
              setState(() => _showConfirmPass = !_showConfirmPass),
        ),
        const SizedBox(height: 24),
        _primaryButton(
          label: 'Set New Password',
          onTap: _loading ? null : _onSetPassword,
          loading: _loading,
        ),
      ],
    );
  }

  // ── Shared sub-widgets ──────────────────────────────────────────────────────

  Widget _illustration(IconData icon) {
    final ctx = context;
    return SizedBox(
      width: Responsive.w(ctx, 140),
      height: Responsive.h(ctx, 140),
      child: Stack(
        alignment: Alignment.center,
        children: [
          Container(
            width: Responsive.w(ctx, 120),
            height: Responsive.h(ctx, 120),
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
            child: Icon(icon, color: Colors.white, size: 38),
          ),
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
    );
  }

  Widget _emailField() {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFF5F5F5),
        borderRadius: BorderRadius.circular(26),
      ),
      child: TextField(
        controller: _emailCtrl,
        keyboardType: TextInputType.emailAddress,
        style: GoogleFonts.poppins(fontSize: Responsive.sp(context, 14), color: const Color(0xFF1A1A1A)),
        decoration: InputDecoration(
          prefixIcon: const Icon(Icons.mail_outline_rounded,
              size: 20, color: Color(0xFFAFAFAF)),
          hintText: 'Enter your email',
          hintStyle:
              GoogleFonts.poppins(fontSize: Responsive.sp(context, 14), color: const Color(0xFFB8B8B8)),
          border: InputBorder.none,
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 8, vertical: 16),
        ),
      ),
    );
  }

  Widget _otpBoxes() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: List.generate(6, (i) {
        return SizedBox(
          width: 44,
          height: 52,
          child: Focus(
            onKeyEvent: (node, event) {
              if (event is KeyDownEvent &&
                  event.logicalKey == LogicalKeyboardKey.backspace &&
                  _otpCtrl[i].text.isEmpty &&
                  i > 0) {
                _otpCtrl[i - 1].clear();
                _otpFocus[i - 1].requestFocus();
                return KeyEventResult.handled;
              }
              return KeyEventResult.ignored;
            },
            child: TextFormField(
              controller: _otpCtrl[i],
              focusNode: _otpFocus[i],
              textAlign: TextAlign.center,
              keyboardType: TextInputType.number,
              inputFormatters: [
                FilteringTextInputFormatter.digitsOnly,
                LengthLimitingTextInputFormatter(1),
              ],
              style: GoogleFonts.poppins(
                fontSize: Responsive.sp(context, 20),
                fontWeight: FontWeight.w700,
                color: const Color(0xFF1A1A1A),
              ),
              decoration: InputDecoration(
                filled: true,
                fillColor: const Color(0xFFF5F5F5),
                counterText: '',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(
                      color: Color(0xFFFFD014), width: 2),
                ),
                contentPadding: EdgeInsets.zero,
              ),
              onChanged: (val) {
                if (val.isNotEmpty && i < 5) {
                  _otpFocus[i + 1].requestFocus();
                }
              },
            ),
          ),
        );
      }),
    );
  }

  Widget _passwordField({
    required TextEditingController controller,
    required String hint,
    required bool obscure,
    required VoidCallback onToggle,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFF5F5F5),
        borderRadius: BorderRadius.circular(26),
      ),
      child: TextField(
        controller: controller,
        obscureText: obscure,
        keyboardType: TextInputType.visiblePassword,
        style: GoogleFonts.poppins(fontSize: Responsive.sp(context, 14), color: const Color(0xFF1A1A1A)),
        decoration: InputDecoration(
          prefixIcon: const Icon(Icons.lock_outline_rounded,
              size: 20, color: Color(0xFFAFAFAF)),
          suffixIcon: IconButton(
            icon: Icon(
              obscure ? Icons.visibility_off_outlined : Icons.visibility_outlined,
              size: 20,
              color: const Color(0xFFAFAFAF),
            ),
            onPressed: onToggle,
          ),
          hintText: hint,
          hintStyle:
              GoogleFonts.poppins(fontSize: Responsive.sp(context, 14), color: const Color(0xFFB8B8B8)),
          border: InputBorder.none,
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 8, vertical: 16),
        ),
      ),
    );
  }

  Widget _primaryButton({
    required String label,
    required VoidCallback? onTap,
    required bool loading,
  }) {
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
          backgroundColor: const Color(0xFFFFCC00),
          foregroundColor: const Color(0xFF1A1A1A),
          disabledBackgroundColor: const Color(0xFFFFCC00).withOpacity(0.7),
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(30),
          ),
        ),
        child: loading
            ? const AppLoaderInline(dotSize: 7, spacing: 4, color: Color(0xFF1A1A2E))
            : Text(
                label,
                style: GoogleFonts.poppins(
                  fontSize: Responsive.sp(context, 15),
                  fontWeight: FontWeight.w700,
                  color: const Color(0xFF1A1A1A),
                ),
              ),
      ),
    );
  }

  Widget _backToLoginLink() {
    return GestureDetector(
      onTap: () => Navigator.pop(context),
      child: RichText(
        text: TextSpan(
          style: GoogleFonts.poppins(
              fontSize: Responsive.sp(context, 13), color: const Color(0xFF9E9E9E)),
          children: [
            const TextSpan(text: 'Remember your password? '),
            TextSpan(
              text: 'Log In',
              style: GoogleFonts.poppins(
                fontSize: Responsive.sp(context, 13),
                fontWeight: FontWeight.w700,
                color: const Color(0xFF1A1A1A),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Password reset success dialog ─────────────────────────────────────────────

class _PasswordResetSuccessDialog extends StatefulWidget {
  final VoidCallback onOkay;

  const _PasswordResetSuccessDialog({required this.onOkay});

  @override
  State<_PasswordResetSuccessDialog> createState() =>
      _PasswordResetSuccessDialogState();
}

class _PasswordResetSuccessDialogState
    extends State<_PasswordResetSuccessDialog>
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
            Positioned.fill(
              child: CustomPaint(
                painter: _ConfettiPainter(_ctrl.value, _particles),
              ),
            ),
            Container(
              decoration: BoxDecoration(
                color: const Color(0xFF1D4ED8),
                borderRadius: BorderRadius.circular(24),
              ),
              padding: const EdgeInsets.fromLTRB(24, 32, 24, 28),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 72,
                    height: 72,
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.15),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.check_circle_rounded,
                      color: Colors.white,
                      size: 38,
                    ),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    'Password Reset!',
                    style: GoogleFonts.poppins(
                      fontSize: Responsive.sp(context, 20),
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Your password has been successfully\nreset. You can now log in.',
                    style: GoogleFonts.poppins(
                      fontSize: Responsive.sp(context, 13),
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
                        'Back to Login',
                        style: GoogleFonts.poppins(
                          fontSize: Responsive.sp(context, 14),
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
