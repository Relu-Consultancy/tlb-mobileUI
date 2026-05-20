import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import '../core/responsive.dart';
import '../services/auth_service.dart';
import '../providers/auth_state.dart';
import '../providers/saved_events_state.dart';
import '../services/walkthrough_service.dart';
import '../widgets/app_loader.dart';
import 'edit_profile_screen.dart';

/// Shared OTP verification screen used by both login and signup flows.
///
/// [identifier]     — the email the OTP was sent to.
/// [onExistingUser] — called when an EXISTING user verifies OTP successfully.
///                    Pass `showWelcomeBackDialog` from login_sheet.dart.
///                    Falls back to HomeScreen push when null.
class OtpVerificationScreen extends StatefulWidget {
  final String identifier;
  final void Function(BuildContext context)? onExistingUser;

  const OtpVerificationScreen({
    super.key,
    required this.identifier,
    this.onExistingUser,
  });

  @override
  State<OtpVerificationScreen> createState() => _OtpVerificationScreenState();
}

class _OtpVerificationScreenState extends State<OtpVerificationScreen> {
  final List<TextEditingController> _controllers =
      List.generate(6, (_) => TextEditingController());
  final List<FocusNode> _focusNodes = List.generate(6, (_) => FocusNode());

  int _resendSeconds = 30;
  Timer? _resendTimer;
  bool _loading = false;

  @override
  void initState() {
    super.initState();
    _startTimer();
  }

  void _startTimer() {
    _resendSeconds = 30;
    _resendTimer?.cancel();
    _resendTimer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (!mounted) {
        t.cancel();
        return;
      }
      if (_resendSeconds <= 0) {
        t.cancel();
      } else {
        setState(() => _resendSeconds--);
      }
    });
  }

  @override
  void dispose() {
    _resendTimer?.cancel();
    for (final c in _controllers) { c.dispose(); }
    for (final f in _focusNodes) { f.dispose(); }
    super.dispose();
  }

  Future<void> _onVerify() async {
    final otp = _controllers.map((c) => c.text).join();
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
        if (widget.onExistingUser != null) {
          widget.onExistingUser!(context);
        } else {
          // Fallback — should not happen since callers always provide the callback.
          Navigator.of(context).popUntil((route) => route.isFirst);
        }
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
              result['message'] ?? 'Verification failed. Please try again.'),
          backgroundColor: const Color(0xFFE53935),
        ),
      );
    }
  }

  Future<void> _onResend() async {
    _startTimer();
    final result = await AuthService.requestOtp(identifier: widget.identifier);
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          result['success'] == true
              ? 'OTP resent to ${widget.identifier}'
              : (result['message'] ?? 'Failed to resend OTP'),
        ),
        backgroundColor:
            result['success'] == true ? null : const Color(0xFFE53935),
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
                  // ── Back button ────────────────────────────────────────────
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

                  const SizedBox(height: 28),

                  // ── Illustration ───────────────────────────────────────────
                  SizedBox(
                    width: Responsive.w(context, 130),
                    height: Responsive.h(context, 130),
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
                                color:
                                    const Color(0xFF5C6BC0).withOpacity(0.35),
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
                      fontSize: Responsive.sp(context, 22),
                      fontWeight: FontWeight.w700,
                      color: const Color(0xFF1A1A1A),
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Enter the 6-digit code sent to\n${widget.identifier}',
                    style: GoogleFonts.poppins(
                        fontSize: Responsive.sp(context, 13), color: const Color(0xFF9E9E9E)),
                    textAlign: TextAlign.center,
                  ),

                  const SizedBox(height: 36),

                  // ── OTP boxes ──────────────────────────────────────────────
                  LayoutBuilder(builder: (context, constraints) {
                    final boxW =
                        ((constraints.maxWidth - 50) / 6).clamp(36.0, 50.0);
                    return Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: List.generate(6, (i) {
                        return SizedBox(
                          width: boxW,
                          height: boxW * 1.25,
                          child: TextField(
                            controller: _controllers[i],
                            focusNode: _focusNodes[i],
                            textAlign: TextAlign.center,
                            keyboardType: TextInputType.number,
                            maxLength: 1,
                            inputFormatters: [
                              FilteringTextInputFormatter.digitsOnly
                            ],
                            style: GoogleFonts.poppins(
                              fontSize: Responsive.sp(context, 20),
                              fontWeight: FontWeight.w700,
                              color: const Color(0xFF1A1A1A),
                            ),
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
                                _focusNodes[i + 1].requestFocus();
                              } else if (v.isEmpty && i > 0) {
                                _focusNodes[i - 1].requestFocus();
                              }
                            },
                          ),
                        );
                      }),
                    );
                  }),

                  const SizedBox(height: 32),

                  // ── Verify button ──────────────────────────────────────────
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
                      onPressed: _loading ? null : _onVerify,
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
                          ? const AppLoaderInline(
                              dotSize: 7,
                              spacing: 4,
                              color: Color(0xFF1A1A2E),
                            )
                          : Text(
                              'Verify & Continue',
                              style: GoogleFonts.poppins(
                                fontSize: Responsive.sp(context, 15),
                                fontWeight: FontWeight.w700,
                                color: const Color(0xFF1A1A1A),
                              ),
                            ),
                    ),
                  ),

                  const SizedBox(height: 24),

                  // ── Resend countdown / button ──────────────────────────────
                  if (_resendSeconds > 0)
                    Text(
                      'Resend in 00:${_resendSeconds.toString().padLeft(2, '0')}',
                      style: GoogleFonts.poppins(
                          fontSize: Responsive.sp(context, 13), color: const Color(0xFF9E9E9E)),
                    )
                  else
                    TextButton(
                      onPressed: _onResend,
                      child: Text(
                        'Resend OTP',
                        style: GoogleFonts.poppins(
                          fontSize: Responsive.sp(context, 14),
                          fontWeight: FontWeight.w600,
                          color: const Color(0xFFFFD014),
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
