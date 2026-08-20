import 'package:flutter/material.dart';
import '../core/app_colors.dart';
import 'package:google_fonts/google_fonts.dart';
import '../core/responsive.dart';
import '../widgets/booking_qr.dart';
import '../models/event_model.dart';
import '../services/ticket_pdf_service.dart';
import 'home_screen.dart';
import 'bookings_screen.dart';

class VenueBookingConfirmedScreen extends StatefulWidget {
  final EventModel event;
  final String selectedDate;
  final String selectedTime;
  final String bookingReference;
  final String? bookingId;

  const VenueBookingConfirmedScreen({
    super.key,
    required this.event,
    required this.selectedDate,
    required this.selectedTime,
    required this.bookingReference,
    this.bookingId,
  });

  @override
  State<VenueBookingConfirmedScreen> createState() =>
      _VenueBookingConfirmedScreenState();
}

class _VenueBookingConfirmedScreenState
    extends State<VenueBookingConfirmedScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnim;
  late Animation<double> _fadeAnim;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    );
    _scaleAnim = CurvedAnimation(
      parent: _controller,
      curve: Curves.elasticOut,
    );
    _fadeAnim = CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.0, 0.6, curve: Curves.easeIn),
    );
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      child: Scaffold(
        backgroundColor: Colors.white,
        body: SafeArea(
          child: Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Column(
                    children: [
                      const SizedBox(height: 48),

                      // ── Animated checkmark ─────────────────────────────────
                      FadeTransition(
                        opacity: _fadeAnim,
                        child: ScaleTransition(
                          scale: _scaleAnim,
                          child: Container(
                            width: 110,
                            height: 110,
                            decoration: BoxDecoration(
                              color: const Color(0xFF22C55E).withOpacity(0.12),
                              shape: BoxShape.circle,
                            ),
                            child: Center(
                              child: Container(
                                width: 80,
                                height: 80,
                                decoration: const BoxDecoration(
                                  color: Color(0xFF22C55E),
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(
                                  Icons.check_rounded,
                                  color: Colors.white,
                                  size: 44,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(height: 24),

                      FadeTransition(
                        opacity: _fadeAnim,
                        child: Column(
                          children: [
                            Text(
                              'Booking Confirmed!',
                              style: GoogleFonts.poppins(
                                fontSize: Responsive.sp(context, 24),
                                fontWeight: FontWeight.w500,
                                color: AppColors.textPrimary,
                              ),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              'Your venue has been successfully booked.',
                              textAlign: TextAlign.center,
                              style: GoogleFonts.poppins(
                                fontSize: Responsive.sp(context, 13),
                                color: Colors.grey.shade500,
                                height: 1.4,
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 32),

                      // ── Booking summary card ───────────────────────────────
                      FadeTransition(
                        opacity: _fadeAnim,
                        child: Container(
                          width: double.infinity,
                          decoration: BoxDecoration(
                            color: const Color(0xFFF8F9FA),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: const Color(0xFFEEEEEE),
                            ),
                          ),
                          child: Column(
                            children: [
                              // Header strip
                              Container(
                                width: double.infinity,
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 20,
                                  vertical: 14,
                                ),
                                decoration: const BoxDecoration(
                                  color: AppColors.primaryLight,
                                  borderRadius: BorderRadius.vertical(
                                    top: Radius.circular(20),
                                  ),
                                ),
                                child: Row(
                                  children: [
                                    const Icon(
                                      Icons.place_rounded,
                                      color: AppColors.textPrimary,
                                      size: 20,
                                    ),
                                    const SizedBox(width: 8),
                                    Expanded(
                                      child: Text(
                                        'Venue Booking',
                                        style: GoogleFonts.poppins(
                                          fontSize:
                                              Responsive.sp(context, 13),
                                          fontWeight: FontWeight.w500,
                                          color: AppColors.textPrimary,
                                        ),
                                      ),
                                    ),
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 10,
                                        vertical: 3,
                                      ),
                                      decoration: BoxDecoration(
                                        color: const Color(0xFF22C55E),
                                        borderRadius:
                                            BorderRadius.circular(12),
                                      ),
                                      child: Text(
                                        'Confirmed ✓',
                                        style: GoogleFonts.poppins(
                                          fontSize:
                                              Responsive.sp(context, 10),
                                          fontWeight: FontWeight.w500,
                                          color: Colors.white,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),

                              Padding(
                                padding: const EdgeInsets.all(20),
                                child: Column(
                                  children: [
                                    _detailRow(
                                      context,
                                      Icons.business_rounded,
                                      'Venue',
                                      widget.event.title,
                                    ),
                                    _divider(),
                                    _detailRow(
                                      context,
                                      Icons.location_on_outlined,
                                      'Location',
                                      widget.event.venue,
                                    ),
                                    _divider(),
                                    _detailRow(
                                      context,
                                      Icons.calendar_today_outlined,
                                      'Date',
                                      widget.selectedDate,
                                    ),
                                    _divider(),
                                    _detailRow(
                                      context,
                                      Icons.access_time_rounded,
                                      'Time',
                                      widget.selectedTime,
                                    ),
                                    _divider(),
                                    _detailRow(
                                      context,
                                      Icons.confirmation_number_outlined,
                                      'Booking Ref',
                                      widget.bookingReference,
                                      valueColor:
                                          AppColors.blue,
                                      mono: true,
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),

                      const SizedBox(height: 24),

                      // ── Check-in QR ────────────────────────────────────────
                      BookingQrCard(bookingId: widget.bookingId),

                      if (widget.bookingId != null &&
                          widget.bookingId!.isNotEmpty)
                        const SizedBox(height: 24),

                      // ── Info note ──────────────────────────────────────────
                      Container(
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: const Color(0xFFEFF6FF),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: const Color(0xFFBFDBFE),
                          ),
                        ),
                        child: Row(
                          children: [
                            const Icon(
                              Icons.info_outline_rounded,
                              color: AppColors.blue,
                              size: 20,
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Text(
                                'A confirmation has been sent to you. '
                                'Please save your booking reference for check-in.',
                                style: GoogleFonts.poppins(
                                  fontSize: Responsive.sp(context, 11.5),
                                  color: const Color(0xFF1D4ED8),
                                  height: 1.4,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 32),
                    ],
                  ),
                ),
              ),

              // ── Action buttons ─────────────────────────────────────────────
              Padding(
                padding: EdgeInsets.fromLTRB(
                  24,
                  0,
                  24,
                  24 + MediaQuery.of(context).padding.bottom,
                ),
                child: Column(
                  children: [
                    if (widget.bookingId != null &&
                        widget.bookingId!.isNotEmpty) ...[
                      SizedBox(
                        width: double.infinity,
                        height: 52,
                        child: OutlinedButton.icon(
                          onPressed: () => TicketPdfService.downloadAndShare(
                            context,
                            bookingId: widget.bookingId!,
                          ),
                          icon: const Icon(Icons.download_outlined,
                              size: 18, color: AppColors.textPrimary),
                          label: Text(
                            'Download Ticket',
                            style: GoogleFonts.poppins(
                              fontSize: Responsive.sp(context, 15),
                              fontWeight: FontWeight.w500,
                              color: AppColors.textPrimary,
                            ),
                          ),
                          style: OutlinedButton.styleFrom(
                            side: const BorderSide(
                                color: AppColors.textPrimary, width: 1.2),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(28),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                    ],
                    SizedBox(
                      width: double.infinity,
                      height: 52,
                      child: ElevatedButton(
                        onPressed: () => Navigator.pushAndRemoveUntil(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const BookingsScreen(),
                          ),
                          (route) => route.isFirst,
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primaryLight,
                          foregroundColor: AppColors.textPrimary,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(28),
                          ),
                          elevation: 0,
                        ),
                        child: Text(
                          'View My Bookings',
                          style: GoogleFonts.poppins(
                            fontSize: Responsive.sp(context, 15),
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    SizedBox(
                      width: double.infinity,
                      height: 52,
                      child: OutlinedButton(
                        onPressed: () => Navigator.pushAndRemoveUntil(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const HomeScreen(),
                          ),
                          (_) => false,
                        ),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: AppColors.textPrimary,
                          side: const BorderSide(
                            color: Color(0xFFDDDDDD),
                            width: 1.5,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(28),
                          ),
                        ),
                        child: Text(
                          'Explore More',
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
            ],
          ),
        ),
      ),
    );
  }

  Widget _divider() => Divider(
        color: Colors.grey.shade200,
        thickness: 1,
        height: 20,
      );

  Widget _detailRow(
    BuildContext context,
    IconData icon,
    String label,
    String value, {
    Color? valueColor,
    bool mono = false,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 18, color: Colors.grey.shade400),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: GoogleFonts.poppins(
                  fontSize: Responsive.sp(context, 11),
                  color: Colors.grey.shade500,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: mono
                    ? TextStyle(
                        fontFamily: 'monospace',
                        fontSize: Responsive.sp(context, 13),
                        fontWeight: FontWeight.w500,
                        color: valueColor ?? AppColors.textPrimary,
                        letterSpacing: 0.5,
                      )
                    : GoogleFonts.poppins(
                        fontSize: Responsive.sp(context, 13),
                        fontWeight: FontWeight.w500,
                        color: valueColor ?? AppColors.textPrimary,
                      ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
