import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import '../core/app_colors.dart';
import '../core/phone_validation.dart';
import '../core/responsive.dart';
import '../models/api_program_model.dart';
import '../models/event_model.dart';
import 'review_pay_screen.dart';

class AttendeeDetailsScreen extends StatefulWidget {
  final EventModel event;
  final ApiProgramBatch batch;
  final String selectedDate;
  final String selectedTime;
  final String bookingType; // 'program' or 'class'

  const AttendeeDetailsScreen({
    super.key,
    required this.event,
    required this.batch,
    required this.selectedDate,
    required this.selectedTime,
    this.bookingType = 'program',
  });

  @override
  State<AttendeeDetailsScreen> createState() => _AttendeeDetailsScreenState();
}

class _AttendeeDetailsScreenState extends State<AttendeeDetailsScreen> {
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  String? _selectedAge;

  bool get _isValid =>
      _nameController.text.trim().isNotEmpty &&
      _selectedAge != null &&
      IndianPhone.isValid(_phoneController.text);

  double get _fee {
    final batchFee = double.tryParse(widget.batch.fee ?? '');
    if (batchFee != null && batchFee > 0) return batchFee;
    return widget.event.price ?? 0.0;
  }

  String get _feeDisplay {
    if (_fee <= 0) return 'Free';
    return '₹${_fee == _fee.truncateToDouble() ? _fee.toInt() : _fee.toStringAsFixed(2)}';
  }

  @override
  void initState() {
    super.initState();
    _nameController.addListener(() => setState(() {}));
    _phoneController.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  void _onContinue() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ReviewPayScreen(
          event: widget.event,
          selectedDate: widget.selectedDate,
          selectedTime: widget.selectedTime,
          ticketDetails: '1 × ${widget.batch.name}',
          subtotal: _fee,
          lineItems: const [],
          attendee: {
            'name': _nameController.text.trim(),
            'age': _selectedAge!,
            'phone': _phoneController.text.trim(),
          },
          bookingType: widget.bookingType,
          batchId: widget.batch.id,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final safeTop = MediaQuery.of(context).padding.top;
    final safeBottom = MediaQuery.of(context).padding.bottom;

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.dark,
      child: Scaffold(
        backgroundColor: Colors.white,
        body: Column(
          children: [
            _buildHeader(context, safeTop),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildBatchSummaryCard(context),
                    const SizedBox(height: 24),
                    _buildFormSection(context),
                  ],
                ),
              ),
            ),
            _buildContinueButton(context, safeBottom),
          ],
        ),
      ),
    );
  }

  // ── Header ──────────────────────────────────────────────────────────────────

  Widget _buildHeader(BuildContext context, double safeTop) {
    return Container(
      color: Colors.white,
      padding: EdgeInsets.fromLTRB(16, safeTop + 12, 16, 14),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => Navigator.pop(context),
            child: Container(
              width: 36,
              height: 36,
              decoration: const BoxDecoration(
                color: Color(0xFFF2F4F7),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.arrow_back_ios_new_rounded,
                  size: 16, color: AppColors.textPrimary),
            ),
          ),
          const SizedBox(width: 14),
          Text(
            'Attendee Details',
            style: GoogleFonts.poppins(
              fontSize: Responsive.sp(context, 17),
              fontWeight: FontWeight.w500,
              color: AppColors.textPrimary,
            ),
          ),
        ],
      ),
    );
  }

  // ── Batch summary card ───────────────────────────────────────────────────────

  Widget _buildBatchSummaryCard(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFF0F9FF),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFBAE6FD)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(9),
                decoration: BoxDecoration(
                  color: const Color(0xFF0284C7).withOpacity(0.12),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  widget.bookingType == 'program'
                      ? Icons.workspace_premium_outlined
                      : Icons.school_rounded,
                  size: 20,
                  color: const Color(0xFF0284C7),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.event.title,
                      style: GoogleFonts.poppins(
                        fontSize: Responsive.sp(context, 14),
                        fontWeight: FontWeight.w500,
                        color: AppColors.textPrimary,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      widget.batch.name,
                      style: GoogleFonts.poppins(
                        fontSize: Responsive.sp(context, 12),
                        fontWeight: FontWeight.w500,
                        color: const Color(0xFF0284C7),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Text(
                _feeDisplay,
                style: GoogleFonts.poppins(
                  fontSize: Responsive.sp(context, 17),
                  fontWeight: FontWeight.w500,
                  color: const Color(0xFF0369A1),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Divider(color: const Color(0xFFBAE6FD), height: 1),
          const SizedBox(height: 12),
          Wrap(
            spacing: 16,
            runSpacing: 6,
            children: [
              _infoChip(Icons.calendar_month_rounded, widget.selectedDate),
              _infoChip(Icons.access_time_rounded, widget.selectedTime),
            ],
          ),
        ],
      ),
    );
  }

  Widget _infoChip(IconData icon, String label) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 14, color: const Color(0xFF0284C7)),
        const SizedBox(width: 4),
        Text(
          label,
          style: GoogleFonts.poppins(
            fontSize: Responsive.sp(context, 12),
            fontWeight: FontWeight.w500,
            color: const Color(0xFF0369A1),
          ),
        ),
      ],
    );
  }

  // ── Form ─────────────────────────────────────────────────────────────────────

  Widget _buildFormSection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Attendee Information',
          style: GoogleFonts.poppins(
            fontSize: Responsive.sp(context, 15),
            fontWeight: FontWeight.w500,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          'Who will be attending?',
          style: GoogleFonts.poppins(
            fontSize: Responsive.sp(context, 13),
            color: AppColors.textSecondary,
          ),
        ),
        const SizedBox(height: 16),

        _textField(
          controller: _nameController,
          icon: Icons.person_outline_rounded,
          hint: 'Full name',
          keyboardType: TextInputType.name,
        ),
        const SizedBox(height: 12),

        _ageDropdown(context),
        const SizedBox(height: 12),

        _textField(
          controller: _phoneController,
          icon: Icons.phone_outlined,
          hint: 'Contact number',
          keyboardType: TextInputType.phone,
          inputFormatters: IndianPhone.inputFormatters,
          dialPrefix: true,
          errorText:
              IndianPhone.validate(_phoneController.text, required: false),
        ),
      ],
    );
  }

  Widget _textField({
    required TextEditingController controller,
    required IconData icon,
    required String hint,
    TextInputType keyboardType = TextInputType.text,
    List<TextInputFormatter>? inputFormatters,
    bool dialPrefix = false,
    String? errorText,
  }) {
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      inputFormatters: inputFormatters,
      style: GoogleFonts.poppins(
        fontSize: Responsive.sp(context, 14),
        color: AppColors.textPrimary,
      ),
      decoration: InputDecoration(
        prefixIcon: dialPrefix
            ? const IndianDialPrefix(icon: Icons.phone_outlined)
            : Icon(icon, size: 20, color: Colors.grey.shade500),
        prefixIconConstraints:
            dialPrefix ? const BoxConstraints(minWidth: 0, minHeight: 0) : null,
        errorText: errorText,
        hintText: hint,
        hintStyle: GoogleFonts.poppins(
          fontSize: Responsive.sp(context, 13),
          color: Colors.grey.shade400,
        ),
        filled: true,
        fillColor: const Color(0xFFF5F5F5),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide:
              const BorderSide(color: Color(0xFF0284C7), width: 1.5),
        ),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      ),
    );
  }

  Widget _ageDropdown(BuildContext context) {
    return Container(
      height: 52,
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: const Color(0xFFF5F5F5),
        borderRadius: BorderRadius.circular(12),
        border: _selectedAge != null
            ? const Border.fromBorderSide(
                BorderSide(color: Color(0xFF0284C7), width: 1.5))
            : null,
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: _selectedAge,
          hint: Row(
            children: [
              Icon(Icons.cake_outlined,
                  size: 18, color: Colors.grey.shade500),
              const SizedBox(width: 8),
              Text(
                'Age',
                style: GoogleFonts.poppins(
                  fontSize: Responsive.sp(context, 13),
                  color: Colors.grey.shade400,
                ),
              ),
            ],
          ),
          isExpanded: true,
          icon: Icon(Icons.keyboard_arrow_down,
              color: Colors.grey.shade500),
          items: List.generate(18, (i) => '${i + 1}')
              .map((age) => DropdownMenuItem(
                    value: age,
                    child: Text(
                      '$age years',
                      style: GoogleFonts.poppins(
                          fontSize: Responsive.sp(context, 14)),
                    ),
                  ))
              .toList(),
          onChanged: (v) => setState(() => _selectedAge = v),
        ),
      ),
    );
  }

  // ── Continue button ───────────────────────────────────────────────────────────

  Widget _buildContinueButton(BuildContext context, double safeBottom) {
    return Container(
      color: Colors.white,
      padding: EdgeInsets.fromLTRB(
          16, 12, 16, safeBottom > 0 ? safeBottom + 8 : 20),
      child: SizedBox(
        width: double.infinity,
        height: 52,
        child: ElevatedButton(
          onPressed: _isValid ? _onContinue : null,
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primaryLight,
            foregroundColor: AppColors.textPrimary,
            disabledBackgroundColor: Colors.grey.shade200,
            disabledForegroundColor: Colors.grey.shade400,
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(30),
            ),
          ),
          child: Text(
            'Continue',
            style: GoogleFonts.poppins(
              fontSize: Responsive.sp(context, 15),
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ),
    );
  }
}
