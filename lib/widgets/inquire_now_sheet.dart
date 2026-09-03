import 'dart:math';
import '../core/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../core/app_snackbar.dart';
import '../core/phone_validation.dart';
import '../core/responsive.dart';
import 'package:google_fonts/google_fonts.dart';
import '../services/classes_listing_service.dart';
import '../services/programs_listing_service.dart';
import '../services/events_listing_service.dart';

void showInquireNow(
  BuildContext context, {
  required String listingId,
  bool isProgram = false,
  bool isVenue = false,
}) {
  showDialog(
    context: context,
    barrierDismissible: true,
    builder: (_) => _InquireNowDialog(
      listingId: listingId,
      isProgram: isProgram,
      isVenue: isVenue,
    ),
  );
}

// ── Enquiry form dialog ────────────────────────────────────────────────────

class _InquireNowDialog extends StatefulWidget {
  final String listingId;
  final bool isProgram;
  final bool isVenue;
  const _InquireNowDialog({
    required this.listingId,
    this.isProgram = false,
    this.isVenue = false,
  });

  @override
  State<_InquireNowDialog> createState() => _InquireNowDialogState();
}

class _InquireNowDialogState extends State<_InquireNowDialog> {
  final _formKey = GlobalKey<FormState>();
  final _scrollCtrl = ScrollController();

  final _attendeeName = TextEditingController();
  final _mobile = TextEditingController();
  final _message = TextEditingController();
  String? _selectedAge;
  int _msgLen = 0;
  bool _isSubmitting = false;
  // AutovalidateMode.disabled until first submit so the form doesn't show red
  // errors before the user has even tried — then switch to onUserInteraction
  // so errors clear as fields are filled.
  AutovalidateMode _autoValidate = AutovalidateMode.disabled;

  /// A venue enquiry carries no age. It is about hiring a space rather than
  /// about a particular child attending, and the venue endpoint has no
  /// `student_age` field to send one to.
  bool get _asksAge => !widget.isVenue;

  static const _ages = ['4', '5', '6', '7', '8', '9', '10', '11', '12', '13', '14', '15', '16'];

  @override
  void dispose() {
    _attendeeName.dispose();
    _mobile.dispose();
    _message.dispose();
    _scrollCtrl.dispose();
    super.dispose();
  }

  String? _requiredValidator(String? v, String label) {
    if (v == null || v.trim().isEmpty) return 'Please enter $label.';
    return null;
  }

  /// Indian mobile rules, shared with the checkout and attendee forms — the
  /// previous rule accepted any 7+ digits, so a short or malformed number
  /// reached the organiser.
  String? _mobileValidator(String? v) => IndianPhone.validate(v);

  Future<void> _submit() async {
    final ok = _formKey.currentState?.validate() ?? false;
    if (!ok) {
      setState(() => _autoValidate = AutovalidateMode.onUserInteraction);
      // Scroll to the top so the first error is visible — without this the
      // user might be focused on the Message field at the bottom and miss
      // errors on the Attendee-Details fields above.
      if (_scrollCtrl.hasClients) {
        _scrollCtrl.animateTo(
          0,
          duration: const Duration(milliseconds: 250),
          curve: Curves.easeOut,
        );
      }
      return;
    }

    setState(() => _isSubmitting = true);
    try {
      final age = _selectedAge == null ? null : int.tryParse(_selectedAge!);

      if (widget.isVenue) {
        await EventsListingService.submitVenueEnquiry(
          listingId: widget.listingId,
          attendeeName: _attendeeName.text.trim(),
          mobile: _mobile.text.trim(),
          message: _message.text.trim(),
        );
      } else if (widget.isProgram) {
        await ProgramsListingService.submitEnquiry(
          listingId: widget.listingId,
          attendeeName: _attendeeName.text.trim(),
          mobile: _mobile.text.trim(),
          studentAge: age,
          message: _message.text.trim(),
        );
      } else {
        await ClassesListingService.submitEnquiry(
          listingId: widget.listingId,
          attendeeName: _attendeeName.text.trim(),
          mobile: _mobile.text.trim(),
          studentAge: age,
          message: _message.text.trim(),
        );
      }

      if (!mounted) return;
      Navigator.pop(context);
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (_) => const _EnquirySuccessDialog(),
      );
    } catch (e) {
      if (!mounted) return;
      setState(() => _isSubmitting = false);
      AppSnackBar.error(context, e.toString().replaceFirst('Exception: ', ''));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 40),
      backgroundColor: Colors.white,
      child: SingleChildScrollView(
        controller: _scrollCtrl,
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          autovalidateMode: _autoValidate,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              // Header row
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Inquire Now',
                          style: GoogleFonts.poppins(
                            fontSize: Responsive.sp(context, 18),
                            fontWeight: FontWeight.w500,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          "Fill your Details and we'll get back to you shortly",
                          style: GoogleFonts.poppins(fontSize: Responsive.sp(context, 12), color: Colors.grey.shade500),
                        ),
                      ],
                    ),
                  ),
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade100,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.close, size: 18, color: AppColors.textPrimary),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 20),

              // ── Attendee Details ──
              // Trimmed to the minimal shape the API now accepts: a name, an
              // age where the listing type has one, and a single contact
              // number. The parent/guardian name and the locality box went
              // with it — `parent_name` and `area` no longer exist on any of
              // the three enquiry endpoints, so asking for them only took
              // something off the customer that would be thrown away.
              _sectionHeader(Icons.person_outline, 'Attendee Details',
                  required: true),
              const SizedBox(height: 10),

              _field(
                _attendeeName,
                'Attendee name*',
                validator: (v) => _requiredValidator(v, "the attendee's name"),
              ),
              const SizedBox(height: 10),

              if (_asksAge)
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: _ageDropdownFormField(
                        context,
                        value: _selectedAge,
                        onChanged: (v) => setState(() => _selectedAge = v),
                        ages: _ages,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(child: _mobileField()),
                  ],
                )
              else
                // Full width rather than half of an otherwise empty row: with
                // no age beside it, a half-width number box sits against dead
                // space and reads as a field that failed to render.
                _mobileField(),

              const SizedBox(height: 20),

              // ── Message ──
              // Required everywhere, not just on programs. `message` is a
              // field on all three trimmed endpoints, and with the enquiry
              // now down to a name and a number it is the only place the
              // customer can say what they actually want.
              _sectionHeader(
                Icons.chat_bubble_outline,
                'Message',
                required: true,
              ),
              const SizedBox(height: 10),

              Stack(
                children: [
                  TextFormField(
                    controller: _message,
                    maxLines: 4,
                    maxLength: 300,
                    buildCounter: (_,
                            {required currentLength,
                            required isFocused,
                            maxLength}) =>
                        null,
                    onChanged: (v) => setState(() => _msgLen = v.length),
                    validator: (v) => _requiredValidator(v, 'a short message'),
                    style: GoogleFonts.poppins(
                        fontSize: Responsive.sp(context, 13),
                        color: AppColors.textPrimary),
                    decoration: InputDecoration(
                      hintText: 'Ask anything...trail class? feess? timing?',
                      hintStyle: GoogleFonts.poppins(
                          fontSize: Responsive.sp(context, 12),
                          color: Colors.grey.shade400),
                      filled: true,
                      fillColor: const Color(0xFFF5F5F5),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: BorderSide.none,
                      ),
                      errorStyle: GoogleFonts.poppins(
                        fontSize: Responsive.sp(context, 11),
                        color: const Color(0xFFEF4444),
                      ),
                      contentPadding:
                          const EdgeInsets.fromLTRB(14, 12, 14, 32),
                    ),
                  ),
                  Positioned(
                    bottom: 22,
                    right: 14,
                    child: Text(
                      '$_msgLen/300',
                      style: GoogleFonts.poppins(
                          fontSize: Responsive.sp(context, 11),
                          color: Colors.grey.shade400),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 24),

              // Send button
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  onPressed: _isSubmitting ? null : _submit,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryLight,
                    foregroundColor: AppColors.textPrimary,
                    disabledBackgroundColor:
                        AppColors.primaryLight.withOpacity(0.5),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30)),
                    elevation: 0,
                  ),
                  child: _isSubmitting
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(
                                AppColors.textPrimary),
                          ),
                        )
                      : Text(
                          'Send Enquiry',
                          style: GoogleFonts.poppins(
                              fontSize: Responsive.sp(context, 16),
                              fontWeight: FontWeight.w600),
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _sectionHeader(IconData icon, String label, {bool required = false}) {
    return Row(
      children: [
        Icon(icon, size: 16, color: AppColors.textPrimary),
        const SizedBox(width: 6),
        Text.rich(
          TextSpan(children: [
            TextSpan(
              text: label,
              style: GoogleFonts.poppins(fontSize: Responsive.sp(context, 13), fontWeight: FontWeight.w500, color: AppColors.textPrimary),
            ),
            if (required)
              TextSpan(
                text: '*',
                style: GoogleFonts.poppins(fontSize: Responsive.sp(context, 13), fontWeight: FontWeight.w500, color: Colors.red),
              ),
          ]),
        ),
      ],
    );
  }

  /// Shared by both layouts — beside the age dropdown, or full width on a
  /// venue — so the two arrangements cannot drift apart.
  Widget _mobileField() => _field(
        _mobile,
        'Mobile number*',
        keyboardType: TextInputType.phone,
        inputFormatters: IndianPhone.inputFormatters,
        dialPrefix: true,
        validator: _mobileValidator,
      );

  Widget _field(
    TextEditingController controller,
    String hint, {
    TextInputType? keyboardType,
    String? Function(String?)? validator,
    List<TextInputFormatter>? inputFormatters,
    bool dialPrefix = false,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      validator: validator,
      inputFormatters: inputFormatters,
      style: GoogleFonts.poppins(
          fontSize: Responsive.sp(context, 13),
          color: AppColors.textPrimary),
      decoration: InputDecoration(
        prefixIcon: dialPrefix ? const IndianDialPrefix() : null,
        prefixIconConstraints:
            dialPrefix ? const BoxConstraints(minWidth: 0, minHeight: 0) : null,
        hintText: hint,
        hintStyle: GoogleFonts.poppins(
            fontSize: Responsive.sp(context, 13), color: Colors.grey.shade400),
        filled: true,
        fillColor: const Color(0xFFF5F5F5),
        border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: BorderSide.none),
        errorStyle: GoogleFonts.poppins(
          fontSize: Responsive.sp(context, 11),
          color: const Color(0xFFEF4444),
        ),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
      ),
    );
  }

  Widget _ageDropdownFormField(
    BuildContext context, {
    required String? value,
    required void Function(String?) onChanged,
    required List<String> ages,
  }) {
    return DropdownButtonFormField<String>(
      value: value,
      isExpanded: true,
      icon: const Icon(Icons.keyboard_arrow_down_rounded,
          color: AppColors.textPrimary, size: 20),
      dropdownColor: Colors.white,
      hint: Text(
        'Select age*',
        style: GoogleFonts.poppins(
            fontSize: Responsive.sp(context, 13),
            color: Colors.grey.shade400),
      ),
      style: GoogleFonts.poppins(
          fontSize: Responsive.sp(context, 13),
          color: AppColors.textPrimary),
      items: ages
          .map((age) => DropdownMenuItem(
                value: age,
                child: Text(age,
                    style:
                        GoogleFonts.poppins(fontSize: Responsive.sp(context, 13))),
              ))
          .toList(),
      // The closed field would otherwise show a bare number with nothing to
      // say it's an age. No leading icon here, unlike the checkout form —
      // none of this sheet's fields have one.
      selectedItemBuilder: (context) => ages
          .map((age) => Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  age == '1' ? '1 year' : '$age years',
                  style: GoogleFonts.poppins(
                    fontSize: Responsive.sp(context, 13),
                    color: AppColors.textPrimary,
                  ),
                ),
              ))
          .toList(),
      onChanged: onChanged,
      validator: (v) => (v == null || v.isEmpty) ? 'Please select an age.' : null,
      decoration: InputDecoration(
        filled: true,
        fillColor: const Color(0xFFF5F5F5),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide.none,
        ),
        errorStyle: GoogleFonts.poppins(
          fontSize: Responsive.sp(context, 11),
          color: const Color(0xFFEF4444),
        ),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
      ),
    );
  }
}

// ── Enquiry success dialog with confetti ──────────────────────────────────

class _EnquirySuccessDialog extends StatefulWidget {
  const _EnquirySuccessDialog();

  @override
  State<_EnquirySuccessDialog> createState() => _EnquirySuccessDialogState();
}

class _EnquirySuccessDialogState extends State<_EnquirySuccessDialog>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final List<_Particle> _particles;

  @override
  void initState() {
    super.initState();
    final rng = Random();
    _particles = List.generate(70, (_) {
      final angle = rng.nextDouble() * pi * 2;
      final speed = rng.nextDouble() * 2.5 + 1.0;
      return _Particle(
        vx: cos(angle) * speed,
        vy: sin(angle) * speed - 2.5,
        size: rng.nextDouble() * 9 + 4,
        rotation: rng.nextDouble() * pi * 2,
        rotSpeed: (rng.nextDouble() - 0.5) * 6,
        color: _kConfettiColors[rng.nextInt(_kConfettiColors.length)],
      );
    });

    _ctrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 2200))
      ..forward();
  }

  static const _kConfettiColors = [
    AppColors.primaryLight,
    Color(0xFFFF6B6B),
    Color(0xFF4ECDC4),
    Color(0xFF45B7D1),
    Color(0xFF96CEB4),
    Color(0xFFFF9A3C),
    Color(0xFFA78BFA),
    Colors.white,
  ];

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 30),
      child: Stack(
        alignment: Alignment.center,
        clipBehavior: Clip.none,
        children: [
          // Purple card
          Container(
            padding: const EdgeInsets.fromLTRB(24, 36, 24, 28),
            decoration: BoxDecoration(
              color: const Color(0xFF7C3AED),
              borderRadius: BorderRadius.circular(24),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Celebration circle
                Container(
                  width: 120,
                  height: 120,
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.18),
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Text('🎊', style: TextStyle(fontSize: Responsive.sp(context, 58))),
                  ),
                ),
                const SizedBox(height: 24),
                Text(
                  'Enquiry Submitted',
                  style: GoogleFonts.poppins(
                    fontSize: Responsive.sp(context, 20),
                    fontWeight: FontWeight.w500,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Our team will be in touch with\nyou soon.',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.poppins(
                    fontSize: Responsive.sp(context, 13),
                    color: Colors.white.withOpacity(0.82),
                    height: 1.55,
                  ),
                ),
                const SizedBox(height: 28),
                SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: ElevatedButton(
                    onPressed: () => Navigator.pop(context),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primaryLight,
                      foregroundColor: AppColors.textPrimary,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                      elevation: 0,
                    ),
                    child: Text(
                      'Okay, Got it!',
                      style: GoogleFonts.poppins(fontSize: Responsive.sp(context, 16), fontWeight: FontWeight.w500),
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Confetti overlay (extends beyond card bounds)
          Positioned.fill(
            child: IgnorePointer(
              child: AnimatedBuilder(
                animation: _ctrl,
                builder: (_, __) => CustomPaint(
                  painter: _ConfettiPainter(progress: _ctrl.value, particles: _particles),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Confetti particle + painter ───────────────────────────────────────────

class _Particle {
  final double vx, vy, size, rotation, rotSpeed;
  final Color color;
  const _Particle({
    required this.vx,
    required this.vy,
    required this.size,
    required this.rotation,
    required this.rotSpeed,
    required this.color,
  });
}

class _ConfettiPainter extends CustomPainter {
  final double progress;
  final List<_Particle> particles;

  _ConfettiPainter({required this.progress, required this.particles});

  @override
  void paint(Canvas canvas, Size size) {
    final cx = size.width / 2;
    final cy = size.height / 2;

    for (final p in particles) {
      final t = progress;
      final x = cx + p.vx * t * 160;
      final y = cy + p.vy * t * 160 + 320 * t * t; // gravity
      final alpha = t < 0.55 ? 1.0 : 1.0 - ((t - 0.55) / 0.45);
      if (alpha <= 0) continue;

      final paint = Paint()..color = p.color.withOpacity(alpha.clamp(0.0, 1.0));
      canvas.save();
      canvas.translate(x, y);
      canvas.rotate(p.rotation + t * p.rotSpeed);
      canvas.drawRect(
        Rect.fromCenter(center: Offset.zero, width: p.size, height: p.size * 0.45),
        paint,
      );
      canvas.restore();
    }
  }

  @override
  bool shouldRepaint(_ConfettiPainter old) => old.progress != progress;
}
