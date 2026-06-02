import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../core/app_snackbar.dart';
import '../core/responsive.dart';
import '../models/help_ticket_model.dart';
import '../providers/auth_state.dart';
import '../services/help_service.dart';
import 'ticket_detail_screen.dart';

/// Form for raising a new support ticket. Used in two modes:
///  • Standalone — user picks a category themselves
///  • Pre-filled — opened from a Help Centre topic tile with the
///    category locked (still editable, since DRF will validate)
class NewTicketScreen extends StatefulWidget {
  final HelpCategory? initialCategory;
  final String? initialBookingId; // when launched from a booking screen
  final String? initialBookingLabel; // for display only

  const NewTicketScreen({
    super.key,
    this.initialCategory,
    this.initialBookingId,
    this.initialBookingLabel,
  });

  @override
  State<NewTicketScreen> createState() => _NewTicketScreenState();
}

class _NewTicketScreenState extends State<NewTicketScreen> {
  final _formKey = GlobalKey<FormState>();
  final _subjectCtrl = TextEditingController();
  final _bodyCtrl = TextEditingController();
  late HelpCategory _category;
  bool _submitting = false;
  AutovalidateMode _autovalidate = AutovalidateMode.disabled;

  @override
  void initState() {
    super.initState();
    _category = widget.initialCategory ?? HelpCategory.general;
  }

  @override
  void dispose() {
    _subjectCtrl.dispose();
    _bodyCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) {
      setState(() => _autovalidate = AutovalidateMode.onUserInteraction);
      return;
    }
    final token = AuthState.accessToken;
    if (token == null) {
      AppSnackBar.error(context, 'Please log in to raise a ticket.');
      return;
    }
    setState(() => _submitting = true);
    final result = await HelpService.createTicket(
      accessToken: token,
      subject: _subjectCtrl.text.trim(),
      category: _category.slug,
      body: _bodyCtrl.text.trim(),
      bookingId: widget.initialBookingId,
    );
    if (!mounted) return;
    setState(() => _submitting = false);

    if (result['success'] == true) {
      final HelpTicket ticket = result['ticket'] as HelpTicket;
      AppSnackBar.success(context, 'Ticket created. Our team will respond soon.');
      // Replace the form with the chat view so the user can immediately
      // see the ticket they just opened.
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (_) => TicketDetailScreen(ticket: ticket),
        ),
      );
    } else {
      AppSnackBar.error(
        context,
        (result['message'] as String?) ?? 'Could not create ticket.',
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF2F2F7),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF2F2F7),
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF1A1A2E)),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'New Ticket',
          style: GoogleFonts.poppins(
            fontSize: Responsive.sp(context, 18),
            fontWeight: FontWeight.w700,
            color: const Color(0xFF1A1A2E),
          ),
        ),
      ),
      body: Form(
        key: _formKey,
        autovalidateMode: _autovalidate,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
          children: [
            _label('Category'),
            const SizedBox(height: 6),
            DropdownButtonFormField<HelpCategory>(
              value: _category,
              decoration: _inputDecoration(),
              borderRadius: BorderRadius.circular(12),
              items: HelpCategory.all
                  .map((c) => DropdownMenuItem(
                        value: c,
                        child: Text(
                          c.label,
                          style: GoogleFonts.poppins(fontSize: 14),
                        ),
                      ))
                  .toList(),
              onChanged: _submitting
                  ? null
                  : (v) => setState(() => _category = v ?? _category),
            ),
            if (widget.initialBookingLabel != null) ...[
              const SizedBox(height: 16),
              _label('Linked Booking'),
              const SizedBox(height: 6),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                decoration: BoxDecoration(
                  color: const Color(0xFFEDF4FF),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.link, color: Color(0xFF2563EB), size: 18),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        widget.initialBookingLabel!,
                        style: GoogleFonts.poppins(
                          fontSize: 13,
                          color: const Color(0xFF1A1A2E),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
            const SizedBox(height: 16),
            _label('Subject'),
            const SizedBox(height: 6),
            TextFormField(
              controller: _subjectCtrl,
              enabled: !_submitting,
              maxLength: 120,
              decoration: _inputDecoration(hint: 'Brief summary of the issue'),
              style: GoogleFonts.poppins(fontSize: 14),
              validator: (v) {
                final t = (v ?? '').trim();
                if (t.isEmpty) return 'Please add a subject';
                if (t.length < 4) return 'Subject is too short';
                return null;
              },
            ),
            const SizedBox(height: 16),
            _label('How can we help?'),
            const SizedBox(height: 6),
            TextFormField(
              controller: _bodyCtrl,
              enabled: !_submitting,
              maxLines: 6,
              maxLength: 2000,
              decoration: _inputDecoration(
                hint: 'Describe the issue in detail. Include dates, booking '
                    'references and any error messages you saw.',
              ),
              style: GoogleFonts.poppins(fontSize: 14),
              validator: (v) {
                final t = (v ?? '').trim();
                if (t.isEmpty) return 'Please describe the issue';
                if (t.length < 10) {
                  return 'A few more details will help us resolve it faster';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 50,
              child: ElevatedButton(
                onPressed: _submitting ? null : _submit,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF2563EB),
                  foregroundColor: Colors.white,
                  disabledBackgroundColor:
                      const Color(0xFF2563EB).withOpacity(0.5),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                child: _submitting
                    ? const SizedBox(
                        width: 22,
                        height: 22,
                        child: CircularProgressIndicator(
                          strokeWidth: 2.5,
                          valueColor:
                              AlwaysStoppedAnimation<Color>(Colors.white),
                        ),
                      )
                    : Text(
                        'Submit Ticket',
                        style: GoogleFonts.poppins(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Our team typically responds within a few hours during '
              'business hours (Mon–Sun, 9 AM – 9 PM IST).',
              textAlign: TextAlign.center,
              style: GoogleFonts.poppins(
                fontSize: 11.5,
                color: Colors.grey.shade500,
                height: 1.4,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _label(String text) => Text(
        text,
        style: GoogleFonts.poppins(
          fontSize: 13,
          fontWeight: FontWeight.w600,
          color: const Color(0xFF1A1A2E),
        ),
      );

  InputDecoration _inputDecoration({String? hint}) => InputDecoration(
        hintText: hint,
        hintStyle: GoogleFonts.poppins(
          fontSize: 13,
          color: Colors.grey.shade400,
        ),
        filled: true,
        fillColor: Colors.white,
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFF2563EB), width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFFEF4444)),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFFEF4444), width: 1.5),
        ),
        errorStyle: GoogleFonts.poppins(
          fontSize: 11.5,
          color: const Color(0xFFEF4444),
        ),
      );
}
