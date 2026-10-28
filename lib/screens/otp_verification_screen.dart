import 'dart:async';
import '../core/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import '../core/app_snackbar.dart';
import '../core/phone_validation.dart';
import '../core/responsive.dart';
import '../models/otp_delivery_model.dart';
import '../services/auth_service.dart';
import '../providers/auth_state.dart';
import '../providers/saved_events_state.dart';
import '../services/walkthrough_service.dart';
import '../widgets/app_dialog.dart';
import '../widgets/app_loader.dart';
import '../widgets/fallback_email_dialog.dart';
import '../widgets/login_sheet.dart' show showWelcomeNewUserDialog;
import '../widgets/whatsapp_auth_card.dart' show WhatsAppLogo;
import 'whatsapp_login_screen.dart';

/// Shared OTP verification screen used by both login and signup flows.
///
/// [identifier]     — where the OTP was sent: an email, or an E.164 phone
///                    number (the code arrives on WhatsApp).
/// [identifierType] — `phone` or `email`.
/// [onExistingUser] — called when an EXISTING user verifies OTP successfully.
///                    Pass `showWelcomeBackDialog` from login_sheet.dart.
///                    Falls back to HomeScreen push when null.
class OtpVerificationScreen extends StatefulWidget {
  final String identifier;
  final String identifierType;
  final void Function(BuildContext context)? onExistingUser;

  /// True when the user arrived via the login flow. In that case, verifying
  /// OTP for an email that isn't a real registered account (the backend
  /// auto-creates one, or the account never completed signup) is treated as a
  /// bug: we surface "No account found with this email. Please signup first."
  /// instead of silently logging them in. "Not a real account" is detected by
  /// `is_new_user` AND, because that flag can't be trusted alone, a profile
  /// completeness cross-check (see AuthService.isAccountRegistered).
  ///
  /// NOTE: the real fix belongs in the backend — `POST /auth/request-otp/`
  /// should reject unregistered emails so no OTP is ever delivered, and
  /// `verify-otp` should not auto-create accounts on the login path. This
  /// client guard is defense-in-depth, not a substitute for that.
  final bool isLoginFlow;

  /// "Verify later" mode — the customer is already signed in and is only
  /// confirming a contact. These replace the sign-in calls: [verifyOverride]
  /// checks the code, [resendOverride] sends a new one, and [onVerified] runs
  /// on success (instead of logging in and routing home).
  final Future<Map<String, dynamic>> Function(String otp)? verifyOverride;
  final Future<Map<String, dynamic>> Function()? resendOverride;
  final void Function(BuildContext context)? onVerified;

  /// Delivery state from the `request-otp` call that opened this screen.
  ///
  /// Carries the `otp_id` that delivery polling and both channel-switch
  /// endpoints need, so without it this screen behaves exactly as it did
  /// before any of that existed: no status line, no fallback offer. Null on a
  /// server that does not send `otp_id`, and in "verify later" mode, whose
  /// endpoints have no delivery tracking.
  final OtpDelivery? delivery;

  const OtpVerificationScreen({
    super.key,
    required this.identifier,
    this.identifierType = 'email',
    this.onExistingUser,
    this.isLoginFlow = false,
    this.verifyOverride,
    this.resendOverride,
    this.onVerified,
    this.delivery,
  });

  @override
  State<OtpVerificationScreen> createState() => _OtpVerificationScreenState();
}

class _OtpVerificationScreenState extends State<OtpVerificationScreen> {
  /// The code was sent on WhatsApp to a phone number.
  bool get _isPhone => widget.identifierType == 'phone';

  /// WhatsApp's brand greens — the screen says where the code is, and this is
  /// how people recognise it.
  static const _waGreen = Color(0xFF25D366);
  static const _waGreenDark = Color(0xFF128C7E);

  final List<TextEditingController> _controllers =
      List.generate(6, (_) => TextEditingController());
  final List<FocusNode> _focusNodes = List.generate(6, (_) => FocusNode());

  int _resendSeconds = 30;
  Timer? _resendTimer;
  bool _loading = false;

  /// How often delivery state is checked, and how long for. WhatsApp settles
  /// within seconds when it is going to; past a minute the answer is not
  /// coming and the customer is better served by the fallback button than by
  /// a spinner.
  static const _pollInterval = Duration(seconds: 3);
  static const _pollWindow = Duration(seconds: 60);

  /// Latest known delivery state for the code on screen. Replaced wholesale
  /// on every poll, resend and channel switch; null means this screen has no
  /// `otp_id` to work with and the delivery UI stays off entirely.
  OtpDelivery? _delivery;

  Timer? _pollTimer;
  int _polledSeconds = 0;

  /// A channel switch is in flight — keeps the button from being tapped twice
  /// (the second call would only earn an `*_ALREADY_SENT`).
  bool _switching = false;

  /// This code has already been sent to the fallback email / to WhatsApp.
  /// Tracked here as well as in [OtpDelivery] because the "already sent"
  /// rejections carry no delivery object to learn it from, and each code may
  /// only be switched once. Both reset when a resend mints a new code.
  bool _emailRequested = false;
  bool _whatsAppRequested = false;

  @override
  void initState() {
    super.initState();
    _delivery = widget.delivery;
    _startTimer();
    _startPolling();
  }

  void _startTimer({int seconds = 30}) {
    _resendSeconds = seconds;
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
    _pollTimer?.cancel();
    for (final c in _controllers) { c.dispose(); }
    for (final f in _focusNodes) { f.dispose(); }
    super.dispose();
  }

  // ── Delivery tracking ──────────────────────────────────────────────────────

  /// Watches the WhatsApp send until it settles, the window closes, or the
  /// customer submits a code.
  ///
  /// Only the WhatsApp flow polls. An email login's delivery state cannot
  /// change on its own — the API has no bounce feedback — so there would be
  /// nothing to learn, and "verify later" mode runs against the contact
  /// endpoints, which have no `otp_id` at all.
  void _startPolling() {
    _pollTimer?.cancel();
    if (!_isPhone || widget.verifyOverride != null) return;
    final delivery = _delivery;
    if (delivery == null || delivery.status.isSettled) return;
    _polledSeconds = 0;
    _pollTimer = Timer.periodic(_pollInterval, _poll);
  }

  Future<void> _poll(Timer timer) async {
    final otpId = _delivery?.otpId;
    if (otpId == null) {
      timer.cancel();
      return;
    }
    _polledSeconds += _pollInterval.inSeconds;
    if (_polledSeconds > _pollWindow.inSeconds) {
      timer.cancel();
      return;
    }
    final result = await AuthService.otpDeliveryStatus(otpId: otpId);
    if (!mounted) {
      timer.cancel();
      return;
    }
    final delivery = result['delivery'];
    // Ignore a failed poll (offline, or an id replaced by a resend mid-flight)
    // rather than clearing what is on screen: the code the customer is holding
    // may well still work, and a wrong "failed" would send them round again.
    if (delivery is! OtpDelivery || delivery.otpId != _delivery?.otpId) return;
    setState(() => _delivery = delivery);
    if (delivery.status.isSettled) timer.cancel();
  }

  /// Folds a finished delivery request back into the screen: the new state,
  /// whether a channel can still be switched to, and the end of the spinner.
  ///
  /// [sent] names the channel this call was trying to reach, so a success —
  /// or an "already sent" rejection, which carries no delivery object to read
  /// it from — retires that one offer. Each code may only be switched once.
  /// [newCode] is for a request that minted a fresh code, which makes both
  /// offers live again.
  void _applyResult(
    Map<String, dynamic> result, {
    String? sent,
    bool newCode = false,
  }) {
    final delivery = result['delivery'];
    final code = '${result['code']}';
    final done = result['success'] == true;
    setState(() {
      _switching = false;
      if (delivery is OtpDelivery) _delivery = delivery;
      if (newCode) {
        _emailRequested = false;
        _whatsAppRequested = false;
      }
      if (sent == 'email' && (done || code == 'EMAIL_ALREADY_SENT')) {
        _emailRequested = true;
      }
      if (sent == 'whatsapp' && (done || code == 'WHATSAPP_ALREADY_SENT')) {
        _whatsAppRequested = true;
      }
    });
  }

  // ── Channel fallback ─────────────────────────────────────────────────────

  /// Whether the "send it by email instead" button belongs on screen.
  bool get _canSendByEmail =>
      !_emailRequested && (_delivery?.canSendToEmail ?? false);

  /// WhatsApp failed with no address on file, so one has to be asked for.
  bool get _needsEmailAddress => _delivery?.needsEmailAddress ?? false;

  OtpAlternate? get _alternate => _isPhone ? null : _delivery?.alternate;

  /// Sends the *same* code to the address the server already holds. Verify
  /// still uses the phone number this screen started with.
  Future<void> _sendByEmail() async {
    final otpId = _delivery?.otpId;
    if (otpId == null || _switching) return;
    setState(() => _switching = true);
    final result = await AuthService.sendOtpViaEmail(otpId: otpId);
    if (!mounted) return;
    _applyResult(result, sent: 'email');
    if (result['success'] == true) {
      final hint = _delivery?.emailHint;
      AppSnackBar.success(
        context,
        hint == null ? 'Code sent to your email.' : 'Code sent to $hint',
      );
    } else {
      AppSnackBar.error(context,
          result['message'] ?? "Couldn't email the code. Please try again.");
    }
  }

  /// Asks for an address, then starts over with it attached.
  ///
  /// `fallback_email` is only read by `request-otp`, so this necessarily
  /// mints a new code — anything already delivered stops working, which is
  /// why the boxes are cleared.
  Future<void> _sendByNewEmail() async {
    if (_switching) return;
    final email = await showFallbackEmailDialog(context);
    if (email == null || !mounted) return;
    setState(() => _switching = true);
    _pollTimer?.cancel();
    final result = await AuthService.requestOtp(
      identifier: widget.identifier,
      identifierType: widget.identifierType,
      purpose: widget.isLoginFlow ? 'login' : 'register',
      fallbackEmail: email,
    );
    if (!mounted) return;
    _applyResult(result, newCode: result['success'] == true);
    if (result['success'] == true) {
      _clearBoxes();
      _startTimer();
      _startPolling();
      AppSnackBar.success(context, 'Sending a new code to $email');
    } else {
      AppSnackBar.error(context,
          result['message'] ?? "Couldn't send the code. Please try again.");
    }
  }

  /// Email login: sends the *same* code to the account's verified number.
  /// Verify still uses the email this screen started with.
  Future<void> _sendToWhatsApp() async {
    final otpId = _delivery?.otpId;
    if (otpId == null || _switching) return;
    setState(() => _switching = true);
    final result = await AuthService.sendOtpViaWhatsApp(otpId: otpId);
    if (!mounted) return;
    _applyResult(result, sent: 'whatsapp');
    if (result['success'] == true) {
      final hint = _alternate?.phoneHint;
      AppSnackBar.success(
        context,
        hint == null
            ? 'Code sent on WhatsApp.'
            : 'Code sent on WhatsApp to $hint',
      );
    } else {
      AppSnackBar.error(
          context,
          result['message'] ??
              "Couldn't send the code on WhatsApp. Please try again.");
    }
  }

  /// Email login with no verified number: the server has nowhere to send, so
  /// the only way on is a fresh phone login.
  ///
  /// Warned about first, because it is not account recovery: it signs in to
  /// whatever account owns that number, which may be a different one from
  /// this email, or none yet.
  Future<void> _signInWithWhatsApp() async {
    final ok = await showAppConfirmDialog(
      context,
      title: 'Sign in with WhatsApp instead?',
      message: 'This signs you in with a phone number, which may be a '
          'different account from ${widget.identifier} — or a new one. It '
          "won't open the account for this email address.",
      confirmLabel: 'Continue',
      cancelLabel: 'Stay here',
      icon: Icons.swap_horiz_rounded,
    );
    if (!ok || !mounted) return;
    _pollTimer?.cancel();
    _resendTimer?.cancel();
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => const WhatsAppLoginScreen()),
    );
  }

  Future<void> _onVerify() async {
    final otp = _controllers.map((c) => c.text).join();
    if (otp.length < 6) {
      AppSnackBar.show(context, 'Please enter the 6-digit OTP');
      return;
    }
    // The customer has the code, so delivery state no longer tells anyone
    // anything worth a request.
    _pollTimer?.cancel();
    setState(() => _loading = true);
    final verifyOverride = widget.verifyOverride;
    if (verifyOverride != null) {
      final result = await verifyOverride(otp);
      if (!mounted) return;
      setState(() => _loading = false);
      if (result['success'] == true) {
        widget.onVerified?.call(context);
      } else {
        if ('${result['code']}'.startsWith('OTP_')) _clearBoxes();
        AppSnackBar.error(context,
            result['message'] ?? 'Verification failed. Please try again.');
      }
      return;
    }
    final result = await AuthService.verifyOtp(
      identifier: widget.identifier,
      identifierType: widget.identifierType,
      otp: otp,
    );
    if (!mounted) return;

    if (result['success'] == true) {
      // Decide whether this account has actually completed signup. The
      // backend sends no `is_new_user` flag, so a freshly auto-created
      // account would look like a returning user; AuthService.isNewAccount
      // cross-checks the real profile instead.
      // (Keep the spinner up through this extra call so Verify can't be
      // double-tapped mid-request.)
      final needsSignup = await AuthService.isNewAccount(result);
      if (!mounted) return;
      setState(() => _loading = false);

      // Reject before any state mutation: the user came here to LOG IN, but
      // the backend auto-created (or never completed) an account because the
      // email wasn't registered. Surface the error and route them to signup
      // instead — do NOT call AuthState.login(), do NOT mark the walkthrough.
      if (needsSignup && widget.isLoginFlow) {
        AppSnackBar.error(
          context,
          _isPhone
              ? 'No account found with this number. Please signup first.'
              : 'No account found with this email. Please signup first.',
        );
        Navigator.of(context).pop();
        return;
      }

      final isNew = needsSignup;

      AuthState.login(
        access: result['access'] as String?,
        refresh: result['refresh'] as String?,
        user: result['user'] as Map<String, dynamic>?,
      );
      SavedEventsState.loadFromApi();

      if (isNew) {
        await WalkthroughService.markAsNewUser();
        if (!mounted) return;
        showWelcomeNewUserDialog(context);
      } else {
        if (widget.onExistingUser != null) {
          widget.onExistingUser!(context);
        } else {
          // Fallback — should not happen since callers always provide the callback.
          Navigator.of(context).popUntil((route) => route.isFirst);
        }
      }
    } else {
      setState(() => _loading = false);
      // A wrong, expired or locked code is no use to edit digit by digit.
      if ('${result['code']}'.startsWith('OTP_')) _clearBoxes();
      AppSnackBar.error(context, result['message'] ?? 'Verification failed. Please try again.');
    }
  }

  void _clearBoxes() {
    for (final c in _controllers) {
      c.clear();
    }
    if (_focusNodes.isNotEmpty) _focusNodes.first.requestFocus();
  }

  Future<void> _onResend() async {
    _startTimer();
    // Every resend mints a new code and kills the old one, so the id being
    // polled is already stale.
    _pollTimer?.cancel();
    // Preserve the original purpose so a login resend stays gated to
    // registered accounts (and a signup resend keeps auto-create behaviour).
    final result = widget.resendOverride != null
        ? await widget.resendOverride!()
        : await AuthService.requestOtp(
            identifier: widget.identifier,
            identifierType: widget.identifierType,
            purpose: widget.isLoginFlow ? 'login' : 'register',
          );
    if (!mounted) return;
    _applyResult(result, newCode: result['success'] == true);
    if (!mounted) return;
    if (result['success'] == true) {
      _clearBoxes();
      _startPolling();
      AppSnackBar.success(
        context,
        _isPhone
            ? 'OTP resent on WhatsApp'
            : 'OTP resent to ${widget.identifier}',
      );
    } else {
      // Resending is capped per number and per hour. Hold the button down for
      // a full minute instead of letting them hammer a closed door.
      if ('${result['code']}' == 'RATE_LIMIT_EXCEEDED') _startTimer(seconds: 60);
      AppSnackBar.error(context, result['message'] ?? 'Failed to resend OTP');
    }
  }

  // ── Delivery UI ────────────────────────────────────────────────────────────

  /// What is actually known about the send, in the customer's words — or null
  /// when there is nothing worth a line (no delivery tracking, or an email
  /// login, whose state never changes on its own).
  ///
  /// The point is to never overclaim: WhatsApp accepting a message says
  /// nothing about it arriving, so "Sending…" stays up until the provider
  /// confirms, and a silence that outlasts the window is reported as a
  /// silence rather than a failure.
  Widget? _buildDeliveryNotice() {
    final delivery = _delivery;
    if (delivery == null || !_isPhone) return null;
    final hint = delivery.emailHint;
    final emailed = ' to $hint';

    if (delivery.status == OtpDeliveryStatus.failed) {
      return _notice(
        icon: Icons.error_outline_rounded,
        background: const Color(0xFFFDECEC),
        foreground: const Color(0xFFB4232A),
        text: delivery.emailSent
            ? "WhatsApp couldn't deliver the code, so we've emailed it"
                "${hint == null ? '' : emailed} instead."
            : "WhatsApp couldn't deliver the code.",
      );
    }
    if (delivery.status == OtpDeliveryStatus.unconfirmed) {
      return _notice(
        icon: Icons.schedule_rounded,
        background: const Color(0xFFFFF6D6),
        foreground: const Color(0xFF8A6A00),
        text: delivery.emailSent
            ? "WhatsApp hasn't confirmed delivery, so we've also emailed the "
                "code${hint == null ? '' : emailed}."
            : "WhatsApp hasn't confirmed delivery yet.",
      );
    }
    if (delivery.emailSent) {
      return _notice(
        icon: Icons.mark_email_read_outlined,
        background: const Color(0xFFEEF2FF),
        foreground: const Color(0xFF3949AB),
        text: "We've also emailed the code${hint == null ? '' : emailed}.",
      );
    }
    if (delivery.status == OtpDeliveryStatus.delivered) {
      return _notice(
        icon: Icons.check_circle_outline_rounded,
        background: const Color(0xFFE8F8EE),
        foreground: const Color(0xFF0E7A46),
        text: 'Delivered on WhatsApp.',
      );
    }
    return _notice(
      icon: null,
      background: const Color(0xFFF5F5F5),
      foreground: const Color(0xFF6B6B6B),
      text: 'Sending the code on WhatsApp…',
    );
  }

  /// One status line. [icon] null draws a small spinner instead, for the
  /// states that are still waiting on the provider.
  Widget _notice({
    required IconData? icon,
    required Color background,
    required Color foreground,
    required String text,
  }) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(top: 14),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (icon != null)
            Icon(icon, size: Responsive.sp(context, 16), color: foreground)
          else
            SizedBox(
              width: Responsive.sp(context, 14),
              height: Responsive.sp(context, 14),
              child: CircularProgressIndicator(
                strokeWidth: 2,
                valueColor: AlwaysStoppedAnimation<Color>(foreground),
              ),
            ),
          const SizedBox(width: 8),
          Flexible(
            child: Text(
              text,
              style: GoogleFonts.poppins(
                fontSize: Responsive.sp(context, 12.5),
                color: foreground,
                height: 1.35,
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// The one channel-switch offer that applies right now, or null.
  ///
  /// Never more than one: only one can be true at a time anyway — the phone
  /// and email flows have separate fallbacks — and a screen with two ways out
  /// makes the customer choose where the app should have.
  Widget? _buildFallbackAction() {
    if (widget.verifyOverride != null) return null;
    if (_switching) {
      return const Padding(
        padding: EdgeInsets.only(top: 6),
        child: AppLoaderInline(dotSize: 6, spacing: 4),
      );
    }
    if (_isPhone) {
      if (_canSendByEmail) {
        return _fallbackButton(
          icon: Icons.alternate_email_rounded,
          label: 'Send the code by email instead',
          onTap: _sendByEmail,
        );
      }
      if (_needsEmailAddress) {
        return _fallbackButton(
          icon: Icons.alternate_email_rounded,
          label: 'Get the code by email',
          onTap: _sendByNewEmail,
        );
      }
      return null;
    }
    final alternate = _alternate;
    if (alternate == null || _whatsAppRequested) return null;
    if (alternate.canSendToWhatsApp) {
      final hint = alternate.phoneHint;
      return _fallbackButton(
        icon: null,
        label: hint == null
            ? 'Send the code on WhatsApp'
            : 'Send the code on WhatsApp to $hint',
        onTap: _sendToWhatsApp,
      );
    }
    if (alternate.needsPhoneLogin) {
      return _fallbackButton(
        icon: Icons.swap_horiz_rounded,
        label: 'Sign in with WhatsApp instead',
        onTap: _signInWithWhatsApp,
      );
    }
    return null;
  }

  /// [icon] null uses the WhatsApp mark, for the offers that lead there.
  Widget _fallbackButton({
    required IconData? icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return TextButton.icon(
      onPressed: onTap,
      style: TextButton.styleFrom(
        foregroundColor: const Color(0xFF1A1A1A),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      ),
      icon: icon == null
          ? const WhatsAppLogo(size: 17)
          : Icon(icon, size: Responsive.sp(context, 17)),
      label: Text(
        label,
        textAlign: TextAlign.center,
        style: GoogleFonts.poppins(
          fontSize: Responsive.sp(context, 13.5),
          fontWeight: FontWeight.w500,
          color: const Color(0xFF1A1A1A),
        ),
      ),
    );
  }

  // ── Build ─────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final notice = _buildDeliveryNotice();
    final fallback = _buildFallbackAction();
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
                          decoration: BoxDecoration(
                            color: _isPhone
                                ? const Color(0xFFE8F8EE)
                                : const Color(0xFFEEF2FF),
                            shape: BoxShape.circle,
                          ),
                        ),
                        Container(
                          width: 76,
                          height: 76,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: _isPhone
                                  ? const [_waGreen, _waGreenDark]
                                  : const [Color(0xFF5C6BC0), Color(0xFF3949AB)],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: (_isPhone
                                        ? _waGreen
                                        : const Color(0xFF5C6BC0))
                                    .withOpacity(0.35),
                                blurRadius: 16,
                                offset: const Offset(0, 8),
                              ),
                            ],
                          ),
                          child: Center(
                            child: _isPhone
                                ? const WhatsAppLogo(
                                    size: 36, color: Colors.white)
                                : const Icon(Icons.verified_user_rounded,
                                    color: Colors.white, size: 34),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 24),

                  Text(
                    _isPhone ? 'WhatsApp Verification' : 'OTP Verification',
                    style: GoogleFonts.poppins(
                      fontSize: Responsive.sp(context, 22),
                      fontWeight: FontWeight.w500,
                      color: const Color(0xFF1A1A1A),
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    _isPhone
                        ? 'Enter the 6-digit code we sent on WhatsApp to\n${IndianPhone.display(widget.identifier)}'
                        : 'Enter the 6-digit code sent to\n${widget.identifier}',
                    style: GoogleFonts.poppins(
                        fontSize: Responsive.sp(context, 13), color: const Color(0xFF9E9E9E)),
                    textAlign: TextAlign.center,
                  ),

                  // Delivery is only ever best-effort on either channel, so
                  // say where it stands rather than leaving a silent screen.
                  ?notice,
                  if (!_isPhone)
                    Padding(
                      padding: const EdgeInsets.only(top: 6),
                      child: Text(
                        "Not there? Check your spam folder.",
                        style: GoogleFonts.poppins(
                          fontSize: Responsive.sp(context, 12),
                          color: const Color(0xFFB0B0B0),
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),

                  SizedBox(height: notice == null ? 36 : 24),

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
                                }
                                // Whenever all six boxes are filled — by
                                // sequential typing, editing, paste or SMS
                                // autofill — dismiss the keyboard so the Verify
                                // button below becomes visible. Checking the
                                // whole set (not just box 6) makes this fire
                                // reliably regardless of which box was edited
                                // last. Done after the frame so the pending
                                // requestFocus above can't reopen the keyboard.
                                if (_controllers.every((c) => c.text.isNotEmpty)) {
                                  WidgetsBinding.instance.addPostFrameCallback((_) {
                                    if (mounted) {
                                      FocusManager.instance.primaryFocus?.unfocus();
                                    }
                                  });
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
                  SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: ElevatedButton(
                      onPressed: _loading ? null : _onVerify,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primaryLight,
                        foregroundColor: const Color(0xFF1A1A1A),
                        disabledBackgroundColor:
                            AppColors.primaryLight.withOpacity(0.7),
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                      ),
                      child: _loading
                          ? const AppLoaderInline(
                              dotSize: 7,
                              spacing: 4,
                              color: AppColors.textPrimary,
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

                  // The other channel, when the server says there is one.
                  ?fallback,
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
