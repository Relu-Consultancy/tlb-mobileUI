import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../core/app_colors.dart';
import '../core/email_validation.dart';
import '../core/responsive.dart';

/// Asks for an email address to send the OTP to, after WhatsApp could not
/// deliver it and the server has no address on file for the number.
///
/// Returns the trimmed address, or null if the customer backed out. Styled to
/// match `app_dialog.dart` — same badge, radius and button pair — because it
/// appears in the middle of that same verification flow.
///
/// Deliberately asked here rather than on the login screen: an optional email
/// field on "Login with WhatsApp" is friction for everyone, while this is only
/// ever shown to the few whose WhatsApp actually failed.
Future<String?> showFallbackEmailDialog(BuildContext context) {
  return showGeneralDialog<String>(
    context: context,
    barrierDismissible: true,
    barrierLabel: MaterialLocalizations.of(context).modalBarrierDismissLabel,
    barrierColor: Colors.black.withOpacity(0.45),
    transitionDuration: const Duration(milliseconds: 240),
    pageBuilder: (_, __, ___) => const SizedBox.shrink(),
    transitionBuilder: (ctx, anim, _, __) {
      final curved = CurvedAnimation(parent: anim, curve: Curves.easeOutBack);
      return Opacity(
        opacity: anim.value.clamp(0.0, 1.0),
        child: ScaleTransition(
          scale: Tween<double>(begin: 0.85, end: 1.0).animate(curved),
          child: const _FallbackEmailDialog(),
        ),
      );
    },
  );
}

class _FallbackEmailDialog extends StatefulWidget {
  const _FallbackEmailDialog();

  @override
  State<_FallbackEmailDialog> createState() => _FallbackEmailDialogState();
}

class _FallbackEmailDialogState extends State<_FallbackEmailDialog> {
  final _controller = TextEditingController();

  /// Shown under the field once the address has been rejected; null while it
  /// has not been submitted yet, so nobody is told off for an empty box.
  String? _error;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _submit() {
    final email = _controller.text.trim();
    final invalid = EmailAddress.validate(email);
    if (invalid != null) {
      setState(() => _error = invalid);
      return;
    }
    Navigator.pop(context, email);
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32),
        child: Material(
          color: Colors.transparent,
          child: Container(
            constraints: const BoxConstraints(maxWidth: 380),
            padding: const EdgeInsets.fromLTRB(24, 26, 24, 20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(24),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.20),
                  blurRadius: 30,
                  offset: const Offset(0, 12),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 62,
                  height: 62,
                  decoration: const BoxDecoration(
                    color: Color(0xFFFFF6D6),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.alternate_email_rounded,
                      color: AppColors.primaryLight, size: 30),
                ),
                const SizedBox(height: 18),
                Text(
                  "Couldn't send on WhatsApp",
                  textAlign: TextAlign.center,
                  style: GoogleFonts.poppins(
                    fontSize: Responsive.sp(context, 18),
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Enter your email address and we will send the code there instead.',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.poppins(
                    fontSize: Responsive.sp(context, 13.5),
                    color: Colors.grey.shade600,
                    height: 1.45,
                  ),
                ),
                const SizedBox(height: 18),
                Container(
                  decoration: BoxDecoration(
                    color: const Color(0xFFF5F5F5),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: TextField(
                    controller: _controller,
                    autofocus: true,
                    keyboardType: TextInputType.emailAddress,
                    textInputAction: TextInputAction.done,
                    onSubmitted: (_) => _submit(),
                    style: GoogleFonts.poppins(
                      fontSize: Responsive.sp(context, 14),
                      color: AppColors.textPrimary,
                    ),
                    decoration: InputDecoration(
                      hintText: 'Email Address',
                      hintStyle: GoogleFonts.poppins(
                        fontSize: Responsive.sp(context, 14),
                        color: const Color(0xFFB8B8B8),
                      ),
                      border: InputBorder.none,
                      contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 14),
                    ),
                  ),
                ),
                if (_error != null) ...[
                  const SizedBox(height: 8),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      _error!,
                      style: GoogleFonts.poppins(
                        fontSize: Responsive.sp(context, 12),
                        color: const Color(0xFFEF4444),
                      ),
                    ),
                  ),
                ],
                const SizedBox(height: 20),
                Row(
                  children: [
                    Expanded(
                      child: SizedBox(
                        height: 48,
                        child: OutlinedButton(
                          onPressed: () => Navigator.pop(context),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: AppColors.textPrimary,
                            side: BorderSide(color: Colors.grey.shade300),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                          ),
                          child: Text(
                            'Cancel',
                            style: GoogleFonts.poppins(
                              fontSize: Responsive.sp(context, 14),
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: SizedBox(
                        height: 48,
                        child: ElevatedButton(
                          onPressed: _submit,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primaryLight,
                            foregroundColor: AppColors.textPrimary,
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                          ),
                          child: Text(
                            'Send code',
                            style: GoogleFonts.poppins(
                              fontSize: Responsive.sp(context, 14),
                              fontWeight: FontWeight.w600,
                            ),
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
    );
  }
}
