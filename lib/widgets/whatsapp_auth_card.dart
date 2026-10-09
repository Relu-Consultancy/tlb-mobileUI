import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';

import '../core/app_colors.dart';
import '../core/app_snackbar.dart';
import '../core/phone_validation.dart';
import '../core/responsive.dart';
import '../services/auth_service.dart';
import 'app_loader.dart';

/// WhatsApp's brand greens — the code arrives there, and this is how people
/// recognise it.
const Color kWhatsAppGreen = Color(0xFF25D366);
const Color kWhatsAppGreenDark = Color(0xFF128C7E);

/// The WhatsApp logo glyph (assets/images/whatsapp.svg, from Simple Icons),
/// tinted to [color].
class WhatsAppLogo extends StatelessWidget {
  final double size;
  final Color color;
  const WhatsAppLogo({
    super.key,
    this.size = 22,
    this.color = kWhatsAppGreen,
  });

  @override
  Widget build(BuildContext context) {
    return SvgPicture.asset(
      'assets/images/whatsapp.svg',
      width: size,
      height: size,
      semanticsLabel: 'WhatsApp',
      colorFilter: ColorFilter.mode(color, BlendMode.srcIn),
    );
  }
}

/// "Continue with WhatsApp" — the entry to the WhatsApp login / sign-up
/// screens, styled to sit beside the Google button.
class WhatsAppEntryButton extends StatelessWidget {
  final VoidCallback? onTap;
  final String label;
  const WhatsAppEntryButton({
    super.key,
    required this.onTap,
    this.label = 'Continue with WhatsApp',
  });

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
            const WhatsAppLogo(size: 22),
            const SizedBox(width: 10),
            Text(
              label,
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

/// The card shared by the WhatsApp login and WhatsApp sign-up screens: a
/// number field and "Send OTP on WhatsApp".
///
/// Validates the number, asks the API to send the code (`purpose` decides
/// whether an unknown number is refused — login — or allowed — register) and
/// hands the E.164 number to [onSent] once it is on its way.
class WhatsAppAuthCard extends StatefulWidget {
  final String title;
  final String subtitle;

  /// `login` or `register` — see POST /auth/request-otp/.
  final String purpose;
  final void Function(String e164Phone) onSent;

  /// Switch to the other WhatsApp screen ("New here? Signup").
  final String switchPrompt;
  final String switchAction;
  final VoidCallback onSwitch;

  const WhatsAppAuthCard({
    super.key,
    required this.title,
    required this.subtitle,
    required this.purpose,
    required this.onSent,
    required this.switchPrompt,
    required this.switchAction,
    required this.onSwitch,
  });

  @override
  State<WhatsAppAuthCard> createState() => _WhatsAppAuthCardState();
}

class _WhatsAppAuthCardState extends State<WhatsAppAuthCard> {
  final _phone = TextEditingController();
  bool _loading = false;

  @override
  void dispose() {
    _phone.dispose();
    super.dispose();
  }

  Future<void> _send() async {
    // Checked here so a malformed number never reaches the server.
    final invalid = IndianPhone.validate(_phone.text);
    if (invalid != null) {
      AppSnackBar.show(context, invalid);
      return;
    }
    final e164 = IndianPhone.e164(_phone.text);
    setState(() => _loading = true);
    final result = await AuthService.requestOtp(
      identifier: e164,
      identifierType: 'phone',
      purpose: widget.purpose,
    );
    if (!mounted) return;
    setState(() => _loading = false);
    if (result['success'] == true) {
      widget.onSent(e164);
    } else {
      AppSnackBar.error(context, result['message'] ?? 'Failed to send OTP');
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
                vertical: Responsive.h(context, 32),
              ),
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
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Align(
                    alignment: Alignment.centerLeft,
                    child: GestureDetector(
                      onTap: () => Navigator.maybePop(context),
                      child: Container(
                        width: 38,
                        height: 38,
                        decoration: const BoxDecoration(
                          color: Color(0xFFF5F5F5),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.arrow_back_ios_new_rounded,
                          size: 16,
                          color: Color(0xFF1A1A1A),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Container(
                    width: 110,
                    height: 110,
                    decoration: const BoxDecoration(
                      color: Color(0xFFE8F8EE),
                      shape: BoxShape.circle,
                    ),
                    child: Center(
                      child: Container(
                        width: 76,
                        height: 76,
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [kWhatsAppGreen, kWhatsAppGreenDark],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: kWhatsAppGreen.withOpacity(0.35),
                              blurRadius: 16,
                              offset: const Offset(0, 8),
                            ),
                          ],
                        ),
                        child: const Center(
                          child: WhatsAppLogo(size: 38, color: Colors.white),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 22),
                  Text(
                    widget.title,
                    style: GoogleFonts.poppins(
                      fontSize: Responsive.sp(context, 22),
                      fontWeight: FontWeight.w500,
                      color: const Color(0xFF1A1A1A),
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    widget.subtitle,
                    textAlign: TextAlign.center,
                    style: GoogleFonts.poppins(
                      fontSize: Responsive.sp(context, 13),
                      color: const Color(0xFF9E9E9E),
                    ),
                  ),
                  const SizedBox(height: 26),
                  Container(
                    decoration: BoxDecoration(
                      color: const Color(0xFFF5F5F5),
                      borderRadius: BorderRadius.circular(26),
                    ),
                    child: TextField(
                      controller: _phone,
                      keyboardType: TextInputType.phone,
                      inputFormatters: IndianPhone.inputFormatters,
                      onSubmitted: (_) => _loading ? null : _send(),
                      style: GoogleFonts.poppins(
                        fontSize: Responsive.sp(context, 14),
                        color: const Color(0xFF1A1A1A),
                      ),
                      decoration: InputDecoration(
                        prefixIcon: Padding(
                          padding: EdgeInsets.only(
                            left: Responsive.w(context, 6),
                          ),
                          child: WhatsAppLogo(
                            size: Responsive.sp(context, 20),
                            color: const Color(0xFFAFAFAF),
                          ),
                        ),
                        prefixText: '${IndianPhone.dialCode} ',
                        prefixStyle: GoogleFonts.poppins(
                          fontSize: Responsive.sp(context, 14),
                          color: const Color(0xFF1A1A1A),
                        ),
                        hintText: 'WhatsApp Number',
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
                  ),
                  const SizedBox(height: 20),
                  SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: ElevatedButton(
                      onPressed: _loading ? null : _send,
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
                              'Send OTP on WhatsApp',
                              style: GoogleFonts.poppins(
                                fontSize: Responsive.sp(context, 15),
                                fontWeight: FontWeight.w500,
                                color: const Color(0xFF1A1A1A),
                              ),
                            ),
                    ),
                  ),
                  const SizedBox(height: 18),
                  // A Wrap, not a Row: the longer prompt/action pairs ("Already
                  // have an account? Login with WhatsApp") don't fit one line on
                  // a narrow screen or a large font, and break onto a second,
                  // centred line instead of overflowing.
                  Wrap(
                    alignment: WrapAlignment.center,
                    crossAxisAlignment: WrapCrossAlignment.center,
                    children: [
                      Text(
                        widget.switchPrompt.trimRight(),
                        textAlign: TextAlign.center,
                        style: GoogleFonts.poppins(
                          fontSize: Responsive.sp(context, 13.5),
                          color: const Color(0xFF9E9E9E),
                        ),
                      ),
                      GestureDetector(
                        behavior: HitTestBehavior.opaque,
                        onTap: _loading ? null : widget.onSwitch,
                        child: Padding(
                          padding: const EdgeInsets.only(
                            left: 4,
                            top: 4,
                            bottom: 4,
                          ),
                          child: Text(
                            widget.switchAction,
                            textAlign: TextAlign.center,
                            style: GoogleFonts.poppins(
                              fontSize: Responsive.sp(context, 13.5),
                              fontWeight: FontWeight.w500,
                              color: const Color(0xFF1A1A1A),
                            ),
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
