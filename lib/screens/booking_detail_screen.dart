import 'dart:math';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../core/responsive.dart';
import '../core/app_snackbar.dart';
import '../models/api_booking_model.dart';
import '../providers/auth_state.dart';
import '../services/booking_service.dart';
import '../services/ticket_pdf_service.dart';
import '../services/events_listing_service.dart';
import '../services/classes_listing_service.dart';
import '../services/programs_listing_service.dart';
import '../widgets/app_loader.dart';

class BookingDetailScreen extends StatefulWidget {
  final ApiBookingItem booking;
  final void Function(ApiBookingItem updated)? onUpdated;

  const BookingDetailScreen({
    super.key,
    required this.booking,
    this.onUpdated,
  });

  @override
  State<BookingDetailScreen> createState() => _BookingDetailScreenState();
}

class _BookingDetailScreenState extends State<BookingDetailScreen>
    with SingleTickerProviderStateMixin {
  late ApiBookingItem _booking;
  bool _cancelling = false;
  String? _coverUrl;

  late final AnimationController _animController;
  late final Animation<double> _scaleAnim;
  late final Animation<double> _fadeAnim;

  @override
  void initState() {
    super.initState();
    _booking = widget.booking;

    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    );
    _scaleAnim = CurvedAnimation(
      parent: _animController,
      curve: Curves.elasticOut,
    );
    _fadeAnim = CurvedAnimation(
      parent: _animController,
      curve: const Interval(0.0, 0.6, curve: Curves.easeIn),
    );
    if (_booking.bookingType == 'venue' ||
        _booking.bookingType == 'program' ||
        _booking.bookingType == 'class') {
      _animController.forward();
    }

    // Seed cover from list response if API already returned it
    if (widget.booking.listingCover != null) {
      _coverUrl = widget.booking.listingCover;
    }
    _loadCover();
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  Future<void> _loadCover() async {
    final token = AuthState.accessToken;
    if (token == null) return;

    try {
      // Fetch full detail — may return listingId / listingCover not in list response
      final detail = await BookingService.getBookingDetail(
          token: token, bookingId: _booking.id);
      if (!mounted) return;

      if (detail.listingCover != null) {
        setState(() => _coverUrl = detail.listingCover);
        return;
      }

      // Fall back to fetching listing cover via listingId
      final lid = detail.listingId ?? _booking.listingId;
      if (lid == null || lid.isEmpty) return;

      final cover = await _fetchListingCover(_booking.bookingType, lid);
      if (!mounted) return;
      if (cover != null) setState(() => _coverUrl = cover);
    } catch (_) {
      // Non-fatal — gradient banner is the fallback
    }
  }

  static Future<String?> _fetchListingCover(
      String bookingType, String listingId) async {
    try {
      switch (bookingType) {
        case 'event':
          final d = await EventsListingService.fetchEventDetail(listingId);
          return d.coverUrl;
        case 'class':
          final d = await ClassesListingService.fetchClassDetail(listingId);
          return d.coverUrl;
        case 'program':
          final d = await ProgramsListingService.fetchProgramDetail(listingId);
          return d.cover;
        case 'venue':
          final d = await EventsListingService.fetchVenueDetail(listingId);
          return d.cover;
        default:
          return null;
      }
    } catch (_) {
      return null;
    }
  }

  // ── Cancel flow ─────────────────────────────────────────────────────────────

  Future<void> _onCancelTap() async {
    final confirmed = await _showCancelDialog();
    if (confirmed == null || !mounted) return;

    setState(() => _cancelling = true);
    try {
      final token = AuthState.accessToken!;
      final updated = await BookingService.cancelBooking(
        token: token,
        bookingId: _booking.id,
        reason: confirmed.isNotEmpty ? confirmed : null,
      );
      if (!mounted) return;
      setState(() {
        _booking = updated;
        _cancelling = false;
      });
      widget.onUpdated?.call(updated);
      AppSnackBar.success(context, 'Booking cancelled successfully.');
    } catch (e) {
      if (!mounted) return;
      setState(() => _cancelling = false);
      AppSnackBar.error(
        context,
        e.toString().replaceFirst('Exception: ', ''),
      );
    }
  }

  /// Returns the reason string (may be empty) if user confirmed, or null if dismissed.
  Future<String?> _showCancelDialog() {
    final reasonController = TextEditingController();
    return showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        title: Text(
          'Cancel Booking',
          style: GoogleFonts.poppins(
              fontWeight: FontWeight.w500,
              fontSize: Responsive.sp(context, 17)),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Are you sure you want to cancel this booking?',
              style: GoogleFonts.poppins(
                  fontSize: Responsive.sp(context, 13.5),
                  color: Colors.grey.shade700),
            ),
            const SizedBox(height: 14),
            TextField(
              controller: reasonController,
              maxLines: 2,
              style: GoogleFonts.poppins(fontSize: Responsive.sp(context, 13)),
              decoration: InputDecoration(
                hintText: 'Reason (optional)',
                hintStyle: GoogleFonts.poppins(
                    color: Colors.grey.shade400,
                    fontSize: Responsive.sp(context, 13)),
                filled: true,
                fillColor: const Color(0xFFF5F5F5),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.symmetric(
                    horizontal: 14, vertical: 10),
              ),
            ),
          ],
        ),
        actionsPadding:
            const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, null),
            child: Text('Keep Booking',
                style: GoogleFonts.poppins(
                    color: Colors.grey.shade600,
                    fontSize: Responsive.sp(context, 13))),
          ),
          ElevatedButton(
            onPressed: () =>
                Navigator.pop(ctx, reasonController.text.trim()),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFEF4444),
              foregroundColor: Colors.white,
              elevation: 0,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10)),
            ),
            child: Text('Cancel Booking',
                style: GoogleFonts.poppins(
                    fontWeight: FontWeight.w500,
                    fontSize: Responsive.sp(context, 13))),
          ),
        ],
      ),
    );
  }

  // ── Build ────────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    if (_booking.bookingType == 'venue') {
      return _buildVenueLayout(context);
    }
    if (_booking.bookingType == 'program' ||
        _booking.bookingType == 'class') {
      return _buildProgramLayout(context);
    }
    return _buildTicketLayout(context);
  }

  Widget _buildTicketLayout(BuildContext context) {
    final safeTop = MediaQuery.of(context).padding.top;
    final safeBottom = MediaQuery.of(context).padding.bottom;

    return Scaffold(
      backgroundColor: const Color(0xFFD6E4F7),
      body: Stack(
        children: [
          Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  child: Column(
                    children: [
                      _HeaderSection(safeTop: safeTop, booking: _booking),
                      Transform.translate(
                        offset: const Offset(0, -20),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 18),
                          child: _TicketCard(
                              booking: _booking, coverUrl: _coverUrl),
                        ),
                      ),
                      const SizedBox(height: 16),
                    ],
                  ),
                ),
              ),
              _ActionBar(
                safeBottom: safeBottom,
                booking: _booking,
                cancelling: _cancelling,
                onCancelTap: _booking.isCancellable ? _onCancelTap : null,
              ),
            ],
          ),
          _floatingBackButton(safeTop),
        ],
      ),
    );
  }

  Widget _buildVenueLayout(BuildContext context) {
    final safeBottom = MediaQuery.of(context).padding.bottom;

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Stack(
          children: [
            Column(
              children: [
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: Column(
                      children: [
                        const SizedBox(height: 48),

                        // ── Animated checkmark ──────────────────────────────
                        FadeTransition(
                          opacity: _fadeAnim,
                          child: ScaleTransition(
                            scale: _scaleAnim,
                            child: Container(
                              width: 110,
                              height: 110,
                              decoration: BoxDecoration(
                                color:
                                    const Color(0xFF22C55E).withOpacity(0.12),
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
                                'Booking Details',
                                style: GoogleFonts.poppins(
                                  fontSize: Responsive.sp(context, 24),
                                  fontWeight: FontWeight.w500,
                                  color: const Color(0xFF1A1A2E),
                                ),
                              ),
                              const SizedBox(height: 6),
                              Text(
                                _booking.bookingReference,
                                style: GoogleFonts.poppins(
                                  fontSize: Responsive.sp(context, 12),
                                  color: Colors.grey.shade500,
                                ),
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 32),

                        // ── Summary card ─────────────────────────────────────
                        FadeTransition(
                          opacity: _fadeAnim,
                          child: Container(
                            width: double.infinity,
                            decoration: BoxDecoration(
                              color: const Color(0xFFF8F9FA),
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(
                                  color: const Color(0xFFEEEEEE)),
                            ),
                            child: Column(
                              children: [
                                // Yellow header strip
                                Container(
                                  width: double.infinity,
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 20, vertical: 14),
                                  decoration: BoxDecoration(
                                    color: _booking.status == 'cancelled'
                                        ? const Color(0xFFEF4444)
                                            .withOpacity(0.15)
                                        : const Color(0xFFFFCC00),
                                    borderRadius: const BorderRadius.vertical(
                                        top: Radius.circular(20)),
                                  ),
                                  child: Row(
                                    children: [
                                      const Icon(Icons.place_rounded,
                                          color: Color(0xFF1A1A2E), size: 20),
                                      const SizedBox(width: 8),
                                      Expanded(
                                        child: Text(
                                          'Venue Booking',
                                          style: GoogleFonts.poppins(
                                            fontSize:
                                                Responsive.sp(context, 13),
                                            fontWeight: FontWeight.w500,
                                            color: const Color(0xFF1A1A2E),
                                          ),
                                        ),
                                      ),
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 10, vertical: 3),
                                        decoration: BoxDecoration(
                                          color: _HeaderSection._statusColor(
                                              _booking.status),
                                          borderRadius:
                                              BorderRadius.circular(12),
                                        ),
                                        child: Text(
                                          _HeaderSection._statusLabel(
                                              _booking.status),
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
                                      _venueDetailRow(
                                        context,
                                        Icons.business_rounded,
                                        'Venue',
                                        _booking.listingTitle,
                                      ),
                                      _venueDivider(),
                                      _venueDetailRow(
                                        context,
                                        Icons.confirmation_number_outlined,
                                        'Booking Ref',
                                        _booking.bookingReference,
                                        valueColor: const Color(0xFF3B82F6),
                                        mono: true,
                                      ),
                                      _venueDivider(),
                                      _venueDetailRow(
                                        context,
                                        Icons.calendar_today_outlined,
                                        'Booked On',
                                        _fmtDate(
                                            _booking.createdAt.toLocal()),
                                      ),
                                      _venueDivider(),
                                      _venueDetailRow(
                                        context,
                                        Icons.payments_outlined,
                                        'Amount Paid',
                                        _booking.totalAmount ==
                                                _booking.totalAmount
                                                    .truncateToDouble()
                                            ? '₹${_booking.totalAmount.toInt()}'
                                            : '₹${_booking.totalAmount.toStringAsFixed(2)}',
                                      ),
                                      if (_booking.status == 'cancelled' &&
                                          _booking.cancelledAt != null) ...[
                                        _venueDivider(),
                                        _venueDetailRow(
                                          context,
                                          Icons.cancel_outlined,
                                          'Cancelled On',
                                          _fmtDate(DateTime.tryParse(
                                                      _booking.cancelledAt!)
                                                  ?.toLocal() ??
                                              DateTime.now()),
                                          valueColor:
                                              const Color(0xFFEF4444),
                                        ),
                                        if (_booking.refundAmount !=
                                            null) ...[
                                          _venueDivider(),
                                          _venueDetailRow(
                                            context,
                                            Icons.currency_rupee_rounded,
                                            'Refund Amount',
                                            '₹${_booking.refundAmount!.toStringAsFixed(0)}',
                                            valueColor:
                                                const Color(0xFF22C55E),
                                          ),
                                        ],
                                      ],
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),

                        const SizedBox(height: 24),

                        // ── Info note ─────────────────────────────────────────
                        FadeTransition(
                          opacity: _fadeAnim,
                          child: Container(
                            padding: const EdgeInsets.all(14),
                            decoration: BoxDecoration(
                              color: const Color(0xFFEFF6FF),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                  color: const Color(0xFFBFDBFE)),
                            ),
                            child: Row(
                              children: [
                                const Icon(Icons.info_outline_rounded,
                                    color: Color(0xFF3B82F6), size: 20),
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
                        ),

                        const SizedBox(height: 32),
                      ],
                    ),
                  ),
                ),
              _ActionBar(
                safeBottom: safeBottom,
                booking: _booking,
                cancelling: _cancelling,
                onCancelTap: _booking.isCancellable ? _onCancelTap : null,
              ),
            ],
          ),
            // Back button (no SafeArea offset needed — SafeArea wraps body)
            Positioned(
              top: 8,
              left: 14,
              child: GestureDetector(
                onTap: () => Navigator.of(context).pop(),
                child: Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.12),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.arrow_back_ios_new_rounded,
                    size: 16,
                    color: Color(0xFF1A1A2E),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProgramLayout(BuildContext context) {
    final safeBottom = MediaQuery.of(context).padding.bottom;
    final isProgram = _booking.bookingType == 'program';
    final accentColor =
        isProgram ? const Color(0xFF6366F1) : const Color(0xFF0284C7);
    final headerIcon = isProgram
        ? Icons.workspace_premium_outlined
        : Icons.school_rounded;
    final headerLabel = isProgram ? 'Program Booking' : 'Class Booking';
    final itemLabel = isProgram ? 'Program' : 'Class';

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Stack(
          children: [
            Column(
              children: [
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: Column(
                      children: [
                        const SizedBox(height: 48),

                        // ── Animated checkmark ──────────────────────────────
                        FadeTransition(
                          opacity: _fadeAnim,
                          child: ScaleTransition(
                            scale: _scaleAnim,
                            child: Container(
                              width: 110,
                              height: 110,
                              decoration: BoxDecoration(
                                color: _booking.status == 'cancelled'
                                    ? const Color(0xFFEF4444).withOpacity(0.12)
                                    : const Color(0xFF22C55E).withOpacity(0.12),
                                shape: BoxShape.circle,
                              ),
                              child: Center(
                                child: Container(
                                  width: 80,
                                  height: 80,
                                  decoration: BoxDecoration(
                                    color: _booking.status == 'cancelled'
                                        ? const Color(0xFFEF4444)
                                        : const Color(0xFF22C55E),
                                    shape: BoxShape.circle,
                                  ),
                                  child: Icon(
                                    _booking.status == 'cancelled'
                                        ? Icons.close_rounded
                                        : Icons.check_rounded,
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
                                'Booking Details',
                                style: GoogleFonts.poppins(
                                  fontSize: Responsive.sp(context, 24),
                                  fontWeight: FontWeight.w500,
                                  color: const Color(0xFF1A1A2E),
                                ),
                              ),
                              const SizedBox(height: 6),
                              Text(
                                _booking.bookingReference,
                                style: GoogleFonts.poppins(
                                  fontSize: Responsive.sp(context, 12),
                                  color: Colors.grey.shade500,
                                ),
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 32),

                        // ── Summary card ──────────────────────────────────────
                        FadeTransition(
                          opacity: _fadeAnim,
                          child: Container(
                            width: double.infinity,
                            decoration: BoxDecoration(
                              color: const Color(0xFFF8F9FA),
                              borderRadius: BorderRadius.circular(20),
                              border:
                                  Border.all(color: const Color(0xFFEEEEEE)),
                            ),
                            child: Column(
                              children: [
                                // Accent header strip
                                Container(
                                  width: double.infinity,
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 20, vertical: 14),
                                  decoration: BoxDecoration(
                                    color: _booking.status == 'cancelled'
                                        ? const Color(0xFFEF4444)
                                            .withOpacity(0.15)
                                        : accentColor.withOpacity(0.1),
                                    borderRadius: const BorderRadius.vertical(
                                        top: Radius.circular(20)),
                                  ),
                                  child: Row(
                                    children: [
                                      Icon(headerIcon,
                                          color: _booking.status == 'cancelled'
                                              ? const Color(0xFFEF4444)
                                              : accentColor,
                                          size: 20),
                                      const SizedBox(width: 8),
                                      Expanded(
                                        child: Text(
                                          headerLabel,
                                          style: GoogleFonts.poppins(
                                            fontSize:
                                                Responsive.sp(context, 13),
                                            fontWeight: FontWeight.w500,
                                            color: _booking.status ==
                                                    'cancelled'
                                                ? const Color(0xFFEF4444)
                                                : accentColor,
                                          ),
                                        ),
                                      ),
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 10, vertical: 3),
                                        decoration: BoxDecoration(
                                          color: _HeaderSection._statusColor(
                                              _booking.status),
                                          borderRadius:
                                              BorderRadius.circular(12),
                                        ),
                                        child: Text(
                                          _HeaderSection._statusLabel(
                                              _booking.status),
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
                                      _venueDetailRow(
                                        context,
                                        headerIcon,
                                        itemLabel,
                                        _booking.listingTitle,
                                      ),
                                      _venueDivider(),
                                      _venueDetailRow(
                                        context,
                                        Icons.confirmation_number_outlined,
                                        'Booking Ref',
                                        _booking.bookingReference,
                                        valueColor: const Color(0xFF3B82F6),
                                        mono: true,
                                      ),
                                      _venueDivider(),
                                      _venueDetailRow(
                                        context,
                                        Icons.calendar_today_outlined,
                                        'Booked On',
                                        _fmtDate(_booking.createdAt.toLocal()),
                                      ),
                                      _venueDivider(),
                                      _venueDetailRow(
                                        context,
                                        Icons.payments_outlined,
                                        'Amount Paid',
                                        _booking.totalAmount ==
                                                _booking.totalAmount
                                                    .truncateToDouble()
                                            ? '₹${_booking.totalAmount.toInt()}'
                                            : '₹${_booking.totalAmount.toStringAsFixed(2)}',
                                      ),
                                      if (_booking.status == 'cancelled' &&
                                          _booking.cancelledAt != null) ...[
                                        _venueDivider(),
                                        _venueDetailRow(
                                          context,
                                          Icons.cancel_outlined,
                                          'Cancelled On',
                                          _fmtDate(DateTime.tryParse(
                                                      _booking.cancelledAt!)
                                                  ?.toLocal() ??
                                              DateTime.now()),
                                          valueColor:
                                              const Color(0xFFEF4444),
                                        ),
                                        if (_booking.refundAmount !=
                                            null) ...[
                                          _venueDivider(),
                                          _venueDetailRow(
                                            context,
                                            Icons.currency_rupee_rounded,
                                            'Refund Amount',
                                            '₹${_booking.refundAmount!.toStringAsFixed(0)}',
                                            valueColor:
                                                const Color(0xFF22C55E),
                                          ),
                                        ],
                                      ],
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),

                        const SizedBox(height: 24),

                        // ── Info note ──────────────────────────────────────────
                        FadeTransition(
                          opacity: _fadeAnim,
                          child: Container(
                            padding: const EdgeInsets.all(14),
                            decoration: BoxDecoration(
                              color: const Color(0xFFEFF6FF),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                  color: const Color(0xFFBFDBFE)),
                            ),
                            child: Row(
                              children: [
                                const Icon(Icons.info_outline_rounded,
                                    color: Color(0xFF3B82F6), size: 20),
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
                        ),

                        const SizedBox(height: 32),
                      ],
                    ),
                  ),
                ),
                _ActionBar(
                  safeBottom: safeBottom,
                  booking: _booking,
                  cancelling: _cancelling,
                  onCancelTap: _booking.isCancellable ? _onCancelTap : null,
                ),
              ],
            ),
            Positioned(
              top: 8,
              left: 14,
              child: GestureDetector(
                onTap: () => Navigator.of(context).pop(),
                child: Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.12),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.arrow_back_ios_new_rounded,
                    size: 16,
                    color: Color(0xFF1A1A2E),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _floatingBackButton(double safeTop) {
    return Positioned(
      top: safeTop + 8,
      left: 14,
      child: GestureDetector(
        onTap: () => Navigator.of(context).pop(),
        child: Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            color: Colors.white,
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.12),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: const Icon(
            Icons.arrow_back_ios_new_rounded,
            size: 16,
            color: Color(0xFF1A1A2E),
          ),
        ),
      ),
    );
  }

  static String _fmtDate(DateTime dt) {
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
    ];
    return '${dt.day} ${months[dt.month - 1]} ${dt.year}';
  }

  Widget _venueDivider() =>
      Divider(color: Colors.grey.shade200, thickness: 1, height: 20);

  Widget _venueDetailRow(
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
              mono
                  ? Text(
                      value,
                      style: TextStyle(
                        fontFamily: 'monospace',
                        fontSize: Responsive.sp(context, 13),
                        fontWeight: FontWeight.w500,
                        color: valueColor ?? const Color(0xFF1A1A2E),
                        letterSpacing: 0.5,
                      ),
                    )
                  : Text(
                      value,
                      style: GoogleFonts.poppins(
                        fontSize: Responsive.sp(context, 13),
                        fontWeight: FontWeight.w500,
                        color: valueColor ?? const Color(0xFF1A1A2E),
                      ),
                    ),
            ],
          ),
        ),
      ],
    );
  }
}

// ── Header ───────────────────────────────────────────────────────────────────

class _HeaderSection extends StatelessWidget {
  final double safeTop;
  final ApiBookingItem booking;

  const _HeaderSection({required this.safeTop, required this.booking});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(top: safeTop + 16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(height: 12),

          // Status badge
          Container(
            padding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 5),
            decoration: BoxDecoration(
              color: _statusColor(booking.status).withOpacity(0.12),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              _statusLabel(booking.status),
              style: GoogleFonts.poppins(
                fontSize: Responsive.sp(context, 12),
                fontWeight: FontWeight.w500,
                color: _statusColor(booking.status),
              ),
            ),
          ),

          const SizedBox(height: 10),

          Text(
            'Booking Details',
            style: GoogleFonts.poppins(
              fontSize: Responsive.sp(context, 20),
              fontWeight: FontWeight.w500,
              color: const Color(0xFF1A3A8F),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            booking.bookingReference,
            style: GoogleFonts.poppins(
              fontSize: Responsive.sp(context, 12),
              color: Colors.grey.shade600,
            ),
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  static Color _statusColor(String status) {
    switch (status) {
      case 'confirmed':
      case 'attended':
        return const Color(0xFF22C55E);
      case 'hold':
        return const Color(0xFFF59E0B);
      case 'awaiting_payment':
        return const Color(0xFF3B82F6);
      case 'payment_failed':
        return const Color(0xFFEF4444);
      case 'cancelled':
        return const Color(0xFF9CA3AF);
      case 'refunded':
        return const Color(0xFF6366F1);
      default:
        return const Color(0xFF9CA3AF);
    }
  }

  static String _statusLabel(String status) {
    switch (status) {
      case 'confirmed':
        return 'Confirmed ✓';
      case 'attended':
        return 'Attended';
      case 'hold':
        return 'Awaiting Payment';
      case 'awaiting_payment':
        return 'Processing Payment…';
      case 'payment_failed':
        return 'Payment Failed';
      case 'cancelled':
        return 'Cancelled';
      case 'refunded':
        return 'Refunded';
      default:
        return status;
    }
  }
}

// ── Ticket Card ──────────────────────────────────────────────────────────────

class _TicketCard extends StatelessWidget {
  final ApiBookingItem booking;
  final String? coverUrl;
  const _TicketCard({required this.booking, this.coverUrl});

  @override
  Widget build(BuildContext context) {
    final qrSize = Responsive.w(context, 140, min: 114);

    return Stack(
      children: [
        Positioned.fill(
          child: CustomPaint(
            painter: const _TicketShapePainter(bgColor: Color(0xFFD6E4F7)),
          ),
        ),
        Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // ── Cover image (real if available, gradient banner otherwise) ──
            Padding(
              padding: const EdgeInsets.fromLTRB(4, 4, 4, 0),
              child: ClipRRect(
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(20),
                  topRight: Radius.circular(20),
                ),
                child: coverUrl != null
                    ? AspectRatio(
                        aspectRatio: 16 / 9,
                        child: Image.network(
                          coverUrl!,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) =>
                              _BookingTypeBanner(bookingType: booking.bookingType),
                        ),
                      )
                    : _BookingTypeBanner(bookingType: booking.bookingType),
              ),
            ),

            // ── Ticket content ──
            Padding(
              padding: const EdgeInsets.fromLTRB(18, 16, 18, 20),
              child: _TicketContent(booking: booking),
            ),

            // ── Notch spacer ──
            const SizedBox(height: 28),

            // ── QR section ──
            Padding(
              padding: const EdgeInsets.fromLTRB(18, 4, 18, 26),
              child: Column(
                children: [
                  Text(
                    'Scan QR Code',
                    style: GoogleFonts.poppins(
                      fontSize: Responsive.sp(context, 13),
                      fontWeight: FontWeight.w500,
                      color: const Color(0xFF1A1A2E),
                    ),
                  ),
                  const SizedBox(height: 14),
                  Container(
                    width: qrSize,
                    height: qrSize,
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      border:
                          Border.all(color: Colors.grey.shade200, width: 1),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: CustomPaint(painter: _QRCodePainter()),
                  ),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }
}

// ── Booking type banner (replaces cover image) ───────────────────────────────

class _BookingTypeBanner extends StatelessWidget {
  final String bookingType;
  const _BookingTypeBanner({required this.bookingType});

  @override
  Widget build(BuildContext context) {
    final icon = _typeIcon(bookingType);
    final color = _typeColor(bookingType);
    final label = _typeLabel(bookingType);
    return Container(
      width: double.infinity,
      height: Responsive.h(context, 160, min: 130),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [color.withOpacity(0.85), color.withOpacity(0.4)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 48, color: Colors.white.withOpacity(0.9)),
          const SizedBox(height: 8),
          Text(
            label,
            style: GoogleFonts.poppins(
              fontSize: Responsive.sp(context, 14),
              fontWeight: FontWeight.w500,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  static IconData _typeIcon(String type) {
    switch (type) {
      case 'event': return Icons.event_outlined;
      case 'class': return Icons.school_outlined;
      case 'program': return Icons.workspace_premium_outlined;
      case 'venue': return Icons.place_outlined;
      default: return Icons.confirmation_number_outlined;
    }
  }

  static Color _typeColor(String type) {
    switch (type) {
      case 'event': return const Color(0xFF6366F1);
      case 'class': return const Color(0xFF22C55E);
      case 'program': return const Color(0xFFF59E0B);
      case 'venue': return const Color(0xFFEF4444);
      default: return const Color(0xFF3B82F6);
    }
  }

  static String _typeLabel(String type) {
    switch (type) {
      case 'event': return 'Event Booking';
      case 'class': return 'Class Booking';
      case 'program': return 'Program Booking';
      case 'venue': return 'Venue Booking';
      default: return 'Booking';
    }
  }
}

// ── Ticket Content ───────────────────────────────────────────────────────────

class _TicketContent extends StatelessWidget {
  final ApiBookingItem booking;
  const _TicketContent({required this.booking});

  @override
  Widget build(BuildContext context) {
    final bookedDate = _fmtDate(booking.createdAt.toLocal());
    final amount = booking.totalAmount == booking.totalAmount.truncateToDouble()
        ? '₹${booking.totalAmount.toInt()}'
        : '₹${booking.totalAmount.toStringAsFixed(2)}';

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Title
        Text(
          booking.listingTitle,
          style: GoogleFonts.poppins(
            fontSize: Responsive.sp(context, 16),
            fontWeight: FontWeight.w500,
            color: const Color(0xFF1A1A2E),
          ),
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
        const SizedBox(height: 14),

        // Row 1: Booking Ref | Type
        Row(
          children: [
            Expanded(
              child: _Field(
                label: 'Booking Ref',
                value: booking.bookingReference,
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: _Field(
                label: 'Type',
                value: _capitalize(booking.bookingType),
              ),
            ),
          ],
        ),
        const SizedBox(height: 14),

        // Row 2: Date Booked | Amount
        Row(
          children: [
            Expanded(
              child: _Field(label: 'Booked On', value: bookedDate),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: _Field(label: 'Amount Paid', value: amount),
            ),
          ],
        ),

        // Cancellation info
        if (booking.status == 'cancelled' &&
            booking.cancelledAt != null) ...[
          const SizedBox(height: 14),
          _Field(
            label: 'Cancelled On',
            value: _fmtDate(
                DateTime.tryParse(booking.cancelledAt!)?.toLocal() ??
                    DateTime.now()),
          ),
          if (booking.refundAmount != null) ...[
            const SizedBox(height: 8),
            _Field(
              label: 'Refund Amount',
              value: '₹${booking.refundAmount!.toStringAsFixed(0)}',
            ),
          ],
        ],
      ],
    );
  }

  static String _fmtDate(DateTime dt) {
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
    ];
    return '${dt.day} ${months[dt.month - 1]} ${dt.year}';
  }

  static String _capitalize(String s) =>
      s.isEmpty ? s : s[0].toUpperCase() + s.substring(1);
}

class _Field extends StatelessWidget {
  final String label;
  final String value;
  const _Field({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.poppins(
              fontSize: Responsive.sp(context, 10),
              color: Colors.grey.shade500),
        ),
        const SizedBox(height: 3),
        Text(
          value,
          style: GoogleFonts.poppins(
            fontSize: Responsive.sp(context, 12),
            fontWeight: FontWeight.w500,
            color: const Color(0xFF1A1A2E),
          ),
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
      ],
    );
  }
}

// ── Bottom Action Bar ─────────────────────────────────────────────────────────

class _ActionBar extends StatelessWidget {
  final double safeBottom;
  final ApiBookingItem booking;
  final bool cancelling;
  final VoidCallback? onCancelTap;

  const _ActionBar({
    required this.safeBottom,
    required this.booking,
    required this.cancelling,
    this.onCancelTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.fromLTRB(
          20, 12, 20, safeBottom > 0 ? safeBottom : 16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 12,
            offset: const Offset(0, -3),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Cancel button (only when cancellable)
          if (onCancelTap != null) ...[
            SizedBox(
              width: double.infinity,
              child: cancelling
                  ? const Center(child: AppLoaderInline())
                  : OutlinedButton.icon(
                      onPressed: onCancelTap,
                      icon: const Icon(Icons.cancel_outlined,
                          size: 18, color: Color(0xFFEF4444)),
                      label: Text(
                        'Cancel Booking',
                        style: GoogleFonts.poppins(
                          fontWeight: FontWeight.w500,
                          fontSize: Responsive.sp(context, 14),
                          color: const Color(0xFFEF4444),
                        ),
                      ),
                      style: OutlinedButton.styleFrom(
                        padding:
                            const EdgeInsets.symmetric(vertical: 12),
                        side: const BorderSide(
                            color: Color(0xFFEF4444), width: 1.5),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12)),
                      ),
                    ),
            ),
            const SizedBox(height: 10),
          ],

          // Share / Download — both call the same flow; system share sheet
          // gives users save/print/forward options once the PDF is built.
          Builder(builder: (ctx) {
            final canDownload =
                booking.status == 'confirmed' || booking.status == 'attended';
            return Row(
              children: [
                Expanded(
                  child: _ActionBtn(
                    icon: Icons.share_outlined,
                    label: 'Share',
                    onTap: canDownload
                        ? () => TicketPdfService.downloadAndShare(
                              ctx,
                              bookingId: booking.id,
                            )
                        : null,
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: _ActionBtn(
                    icon: Icons.download_outlined,
                    label: 'Download',
                    onTap: canDownload
                        ? () => TicketPdfService.downloadAndShare(
                              ctx,
                              bookingId: booking.id,
                            )
                        : null,
                  ),
                ),
              ],
            );
          }),
        ],
      ),
    );
  }
}

class _ActionBtn extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback? onTap;

  const _ActionBtn({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final disabled = onTap == null;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 13),
        decoration: BoxDecoration(
          color: const Color(0xFFF5F6FA),
          borderRadius: BorderRadius.circular(14),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon,
                size: 18,
                color: disabled
                    ? const Color(0xFF9CA3AF)
                    : const Color(0xFF1A1A2E)),
            const SizedBox(width: 8),
            Text(
              label,
              style: GoogleFonts.poppins(
                fontSize: Responsive.sp(context, 14),
                fontWeight: FontWeight.w500,
                color: disabled
                    ? const Color(0xFF9CA3AF)
                    : const Color(0xFF1A1A2E),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Painters ─────────────────────────────────────────────────────────────────

class _TicketShapePainter extends CustomPainter {
  final Color bgColor;
  const _TicketShapePainter({required this.bgColor});

  static const _radius = 22.0;
  static const _notchR = 14.0;

  @override
  void paint(Canvas canvas, Size size) {
    final bodyRRect = RRect.fromRectAndRadius(
      Rect.fromLTWH(0, 0, size.width, size.height),
      const Radius.circular(_radius),
    );

    final notchY = size.height * 0.645;

    final shadowPath = Path()..addRRect(bodyRRect);
    canvas.drawShadow(shadowPath, Colors.black.withOpacity(0.25), 12, true);

    final bodyPaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;

    canvas.save();

    final clipPath = Path()..addRRect(bodyRRect);
    clipPath.addOval(
        Rect.fromCircle(center: Offset(0, notchY), radius: _notchR));
    clipPath.addOval(
        Rect.fromCircle(center: Offset(size.width, notchY), radius: _notchR));
    clipPath.fillType = PathFillType.evenOdd;

    canvas.clipPath(clipPath);
    canvas.drawRRect(bodyRRect, bodyPaint);
    canvas.restore();

    final dashPaint = Paint()
      ..color = const Color(0xFFDEDEDE)
      ..strokeWidth = 1.5
      ..style = PaintingStyle.stroke;

    double x = _notchR + 8;
    const dashLen = 6.0, gap = 4.0;
    final endX = size.width - _notchR - 8;
    while (x < endX) {
      canvas.drawLine(
        Offset(x, notchY),
        Offset((x + dashLen).clamp(0.0, endX), notchY),
        dashPaint,
      );
      x += dashLen + gap;
    }
  }

  @override
  bool shouldRepaint(covariant _TicketShapePainter old) =>
      old.bgColor != bgColor;
}

class _QRCodePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final p = Paint()
      ..color = Colors.black
      ..style = PaintingStyle.fill;
    final rand = Random(42);
    const cell = 8.0;
    final cols = (size.width / cell).floor();
    final rows = (size.height / cell).floor();

    _drawFinder(canvas, p, 0, 0, cell);
    _drawFinder(canvas, p, (cols - 7) * cell, 0, cell);
    _drawFinder(canvas, p, 0, (rows - 7) * cell, cell);

    for (int r = 0; r < rows; r++) {
      for (int c = 0; c < cols; c++) {
        if ((r < 8 && c < 8) ||
            (r < 8 && c >= cols - 8) ||
            (r >= rows - 8 && c < 8)) continue;
        if (rand.nextBool()) {
          canvas.drawRect(
            Rect.fromLTWH(c * cell, r * cell, cell - 1, cell - 1),
            p,
          );
        }
      }
    }
  }

  void _drawFinder(Canvas c, Paint p, double x, double y, double s) {
    c.drawRect(Rect.fromLTWH(x, y, s * 7, s * 7), p);
    final w = Paint()..color = Colors.white;
    c.drawRect(Rect.fromLTWH(x + s, y + s, s * 5, s * 5), w);
    c.drawRect(Rect.fromLTWH(x + s * 2, y + s * 2, s * 3, s * 3), p);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
