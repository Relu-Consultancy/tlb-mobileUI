import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import '../core/app_snackbar.dart';
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

  /// True when the user arrived via the login flow. In that case, an
  /// `is_new_user: true` verify-OTP response is treated as a bug — the
  /// backend auto-created an account for a login attempt — so we surface
  /// "No account found with this email. Please sign up first." instead of
  /// silently logging the new user in and pushing them to onboarding.
  ///
  /// TODO: ideally the OTP request itself should be rejected by the backend
  /// for unregistered emails when this flag is set (no OTP delivered at all).
  final bool isLoginFlow;

  const OtpVerificationScreen({
    super.key,
    required this.identifier,
    this.onExistingUser,
    this.isLoginFlow = false,
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
      AppSnackBar.show(context, 'Please enter the 6-digit OTP');
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
      final isNew = result['is_new_user'] == true;

      // Reject before any state mutation: the user came here to LOG IN, but
      // the backend auto-created an account because the email wasn't
      // registered. Surface the error and route them to signup instead — do
      // NOT call AuthState.login(), do NOT mark the walkthrough flag.
      if (isNew && widget.isLoginFlow) {
        AppSnackBar.error(
          context,
          'No account found with this email. Please sign up first.',
        );
        Navigator.of(context).pop();
        return;
      }

      AuthState.login(
        access: result['access'] as String?,
        refresh: result['refresh'] as String?,
        user: result['user'] as Map<String, dynamic>?,
      );
      SavedEventsState.loadFromApi();

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
      AppSnackBar.error(context, result['message'] ?? 'Verification failed. Please try again.');
    }
  }

  Future<void> _onResend() async {
    _startTimer();
    final result = await AuthService.requestOtp(identifier: widget.identifier);
    if (!mounted) return;
    if (result['success'] == true) {
      AppSnackBar.success(context, 'OTP resent to ${widget.identifier}');
    } else {
      AppSnackBar.error(context, result['message'] ?? 'Failed to resend OTP');
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
                      fontWeight: FontWeight.w500,
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
                          // Focus wrapper handles backspace on an already-empty
                          // box (onChanged never fires when the value doesn't
                          // change) — moves focus back and clears the previous
                          // digit so the cursor isn't stuck.
                          child: Focus(
                            onKeyEvent: (node, event) {
                              if (event is KeyDownEvent &&
                                  event.logicalKey ==
                                      LogicalKeyboardKey.backspace &&
                                  _controllers[i].text.isEmpty &&
                                  i > 0) {
                                _controllers[i - 1].clear();
                                _focusNodes[i - 1].requestFocus();
                                return KeyEventResult.handled;
                              }
                              return KeyEventResult.ignored;
                            },
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
                                fontWeight: FontWeight.w500,
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
                                } else if (v.isNotEmpty && i == 5) {
                                  // Last digit entered — dismiss the
                                  // keyboard so the Verify button (sitting
                                  // below the boxes) becomes visible.
                                  FocusScope.of(context).unfocus();
                                }
                                // No auto-retreat on empty onChanged — the
                                // Focus.onKeyEvent above handles backspace
                                // explicitly so cursor doesn't get stuck.
                              },
                            ),
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
                                fontWeight: FontWeight.w500,
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
                          fontWeight: FontWeight.w500,
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
