import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../core/app_colors.dart';
import '../core/app_snackbar.dart';
import '../core/email_validation.dart';
import '../core/phone_validation.dart';
import '../core/responsive.dart';
import '../providers/auth_state.dart';
import '../services/contact_verification_service.dart';
import '../widgets/app_loader.dart';
import '../widgets/whatsapp_auth_card.dart';
import 'otp_verification_screen.dart';

enum VerifyContactKind { mobile, email }

/// "Verify later": confirm the account's mobile number (a WhatsApp code) or
/// email (an email code) from Profile / Account Settings.
///
/// A contact is verified only by a code sent to that contact — signing in with
/// an email code does not verify the mobile number, and vice versa.
class VerifyContactScreen extends StatefulWidget {
  final VerifyContactKind kind;
  const VerifyContactScreen({super.key, required this.kind});

  @override
  State<VerifyContactScreen> createState() => _VerifyContactScreenState();
}

class _VerifyContactScreenState extends State<VerifyContactScreen> {
  late final TextEditingController _input;
  bool _loading = false;

  bool get _isMobile => widget.kind == VerifyContactKind.mobile;

  @override
  void initState() {
    super.initState();
    _input = TextEditingController(text: _initialText());
    _input.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _input.dispose();
    super.dispose();
  }

  /// The contact already on the account, as typed into the field: the
  /// ten digits of a mobile number (the +91 is the field's prefix).
  String _initialText() {
    if (_isMobile) {
      final d = IndianPhone.normalise(AuthState.contactPhone);
      return d.length == IndianPhone.length ? d : '';
    }
    return AuthState.contactEmail ?? '';
  }

  String get _current => _isMobile
      ? IndianPhone.e164(_input.text)
      : _input.text.trim().toLowerCase();

  bool get _verified =>
      _isMobile ? AuthState.isPhoneVerified : AuthState.isEmailVerified;

  /// The number/email the account already has verified, as sent to the API.
  String? get _onAccount => _isMobile
      ? (AuthState.contactPhone == null
            ? null
            : IndianPhone.e164(AuthState.contactPhone))
      : AuthState.contactEmail?.toLowerCase();

  /// Verified, and the field still shows that same contact.
  bool get _showingVerified => _verified && _current == _onAccount;

  Future<void> _send() async {
    final invalid = _isMobile
        ? IndianPhone.validate(_input.text)
        : EmailAddress.validate(_input.text);
    if (invalid != null) {
      AppSnackBar.show(context, invalid);
      return;
    }
    final target = _current;
    setState(() => _loading = true);
    final result = _isMobile
        ? await ContactVerificationService.requestPhoneOtp(target)
        : await ContactVerificationService.requestEmailOtp(target);
    if (!mounted) return;
    setState(() => _loading = false);
    if (result['success'] != true) {
      AppSnackBar.error(context, result['message'] ?? 'Failed to send OTP');
      return;
    }
    final done = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (_) => OtpVerificationScreen(
          identifier: target,
          identifierType: _isMobile ? 'phone' : 'email',
          verifyOverride: (otp) => _isMobile
              ? ContactVerificationService.verifyPhone(target, otp)
              : ContactVerificationService.verifyEmail(target, otp),
          resendOverride: () => _isMobile
              ? ContactVerificationService.requestPhoneOtp(target)
              : ContactVerificationService.requestEmailOtp(target),
          onVerified: (ctx) => Navigator.of(ctx).pop(true),
        ),
      ),
    );
    if (!mounted || done != true) return;
    AppSnackBar.success(
      context,
      _isMobile ? 'Mobile number verified' : 'Email verified',
    );
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final title = _isMobile ? 'Verify Mobile Number' : 'Verify Email';
    final canSend = !_loading && !_showingVerified;

    return Scaffold(
      backgroundColor: AppColors.lightGray,
      appBar: AppBar(
        backgroundColor: AppColors.lightGray,
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.textPrimary),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          title,
          style: GoogleFonts.poppins(
            fontSize: Responsive.sp(context, 18),
            fontWeight: FontWeight.w500,
            color: AppColors.textPrimary,
          ),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 440),
              child: Container(
                padding: const EdgeInsets.fromLTRB(22, 28, 22, 26),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(24),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _hero(),
                    const SizedBox(height: 18),
                    ListenableBuilder(
                      listenable: AuthState.verificationChanged,
                      builder: (_, __) => _StatusChip(verified: _verified),
                    ),
                    const SizedBox(height: 14),
                    Text(
                      _isMobile
                          ? "We'll send a 6-digit code on WhatsApp to confirm this number."
                          : "We'll email a 6-digit code to confirm this address.",
                      textAlign: TextAlign.center,
                      style: GoogleFonts.poppins(
                        fontSize: Responsive.sp(context, 13),
                        color: const Color(0xFF9E9E9E),
                        height: 1.5,
                      ),
                    ),
                    const SizedBox(height: 22),
                    _field(),
                    const SizedBox(height: 20),
                    if (_showingVerified)
                      Text(
                        _isMobile
                            ? 'This number is verified. Enter a different one to change it.'
                            : 'This email is verified. Enter a different one to change it.',
                        textAlign: TextAlign.center,
                        style: GoogleFonts.poppins(
                          fontSize: Responsive.sp(context, 12.5),
                          color: const Color(0xFF9E9E9E),
                        ),
                      )
                    else
                      SizedBox(
                        width: double.infinity,
                        height: 52,
                        child: ElevatedButton(
                          onPressed: canSend ? _send : null,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primaryLight,
                            foregroundColor: const Color(0xFF1A1A1A),
                            disabledBackgroundColor: AppColors.primaryLight
                                .withOpacity(0.7),
                            elevation: 0,
                            shadowColor: Colors.transparent,
                            surfaceTintColor: Colors.transparent,
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
                                  _isMobile
                                      ? 'Send OTP on WhatsApp'
                                      : 'Send OTP to Email',
                                  style: GoogleFonts.poppins(
                                    fontSize: Responsive.sp(context, 15),
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _hero() {
    final green = _isMobile;
    return Container(
      width: 104,
      height: 104,
      decoration: BoxDecoration(
        color: green ? const Color(0xFFE8F8EE) : const Color(0xFFEEF2FF),
        shape: BoxShape.circle,
      ),
      child: Center(
        child: Container(
          width: 72,
          height: 72,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: green
                  ? const [kWhatsAppGreen, kWhatsAppGreenDark]
                  : const [Color(0xFF5C6BC0), Color(0xFF3949AB)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            shape: BoxShape.circle,
          ),
          child: Center(
            child: green
                ? const WhatsAppLogo(size: 36, color: Colors.white)
                : const Icon(Icons.mail_rounded, color: Colors.white, size: 34),
          ),
        ),
      ),
    );
  }

  Widget _field() {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFF5F5F5),
        borderRadius: BorderRadius.circular(26),
      ),
      child: TextField(
        controller: _input,
        keyboardType: _isMobile
            ? TextInputType.phone
            : TextInputType.emailAddress,
        inputFormatters: _isMobile ? IndianPhone.inputFormatters : null,
        textCapitalization: TextCapitalization.none,
        autocorrect: false,
        onSubmitted: (_) => _showingVerified || _loading ? null : _send(),
        style: GoogleFonts.poppins(
          fontSize: Responsive.sp(context, 14),
          color: const Color(0xFF1A1A1A),
        ),
        decoration: InputDecoration(
          prefixIcon: Padding(
            padding: EdgeInsets.only(left: Responsive.w(context, 6)),
            child: _isMobile
                ? WhatsAppLogo(
                    size: Responsive.sp(context, 20),
                    color: const Color(0xFFAFAFAF),
                  )
                : Icon(
                    Icons.mail_outline_rounded,
                    size: Responsive.sp(context, 20),
                    color: const Color(0xFFAFAFAF),
                  ),
          ),
          prefixText: _isMobile ? '${IndianPhone.dialCode} ' : null,
          prefixStyle: GoogleFonts.poppins(
            fontSize: Responsive.sp(context, 14),
            color: const Color(0xFF1A1A1A),
          ),
          hintText: _isMobile ? 'WhatsApp Number' : 'Email Address',
          hintStyle: GoogleFonts.poppins(
            fontSize: Responsive.sp(context, 14),
            color: const Color(0xFFB8B8B8),
          ),
          border: InputBorder.none,
          contentPadding: EdgeInsets.symmetric(
            horizontal: Responsive.w(context, 8),
            vertical: Responsive.h(context, 16),
          ),
        ),
      ),
    );
  }
}

/// "Verified" / "Not verified".
class _StatusChip extends StatelessWidget {
  final bool verified;
  const _StatusChip({required this.verified});

  @override
  Widget build(BuildContext context) {
    final color = verified ? const Color(0xFF1E8E3E) : const Color(0xFFB26A00);
    final bg = verified ? const Color(0xFFE6F4EA) : const Color(0xFFFFF4E0);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            verified ? Icons.verified_rounded : Icons.error_outline_rounded,
            size: 16,
            color: color,
          ),
          const SizedBox(width: 6),
          Text(
            verified ? 'Verified' : 'Not verified',
            style: GoogleFonts.poppins(
              fontSize: Responsive.sp(context, 12.5),
              fontWeight: FontWeight.w500,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}
