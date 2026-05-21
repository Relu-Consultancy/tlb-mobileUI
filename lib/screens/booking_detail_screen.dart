import 'dart:math';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../core/responsive.dart';
import '../core/app_snackbar.dart';
import '../models/api_booking_model.dart';
import '../providers/auth_state.dart';
import '../services/booking_service.dart';
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

class _BookingDetailScreenState extends State<BookingDetailScreen> {
  late ApiBookingItem _booking;
  bool _cancelling = false;
  String? _coverUrl;

  @override
  void initState() {
    super.initState();
    _booking = widget.booking;
    // Seed cover from list response if API already returned it
    if (widget.booking.listingCover != null) {
      _coverUrl = widget.booking.listingCover;
    }
    _loadCover();
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
              fontWeight: FontWeight.w700,
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
                    fontWeight: FontWeight.w600,
                    fontSize: Responsive.sp(context, 13))),
          ),
        ],
      ),
    );
  }

  // ── Build ────────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
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
                          padding:
                              const EdgeInsets.symmetric(horizontal: 18),
                          child: _TicketCard(booking: _booking, coverUrl: _coverUrl),
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
                onCancelTap:
                    _booking.isCancellable ? _onCancelTap : null,
              ),
            ],
          ),

          // Floating back button
          Positioned(
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
          ),
        ],
      ),
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
                fontWeight: FontWeight.w600,
                color: _statusColor(booking.status),
              ),
            ),
          ),

          const SizedBox(height: 10),

          Text(
            'Booking Details',
            style: GoogleFonts.poppins(
              fontSize: Responsive.sp(context, 20),
              fontWeight: FontWeight.w700,
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
                      fontWeight: FontWeight.w600,
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
              fontWeight: FontWeight.w600,
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
            fontWeight: FontWeight.w700,
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
            fontWeight: FontWeight.w600,
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
                          fontWeight: FontWeight.w600,
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

          // Share / Download
          Row(
            children: [
              Expanded(
                child: _ActionBtn(
                  icon: Icons.share_outlined,
                  label: 'Share',
                  onTap: () {},
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: _ActionBtn(
                  icon: Icons.download_outlined,
                  label: 'Download',
                  onTap: () {},
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _ActionBtn extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _ActionBtn({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
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
            Icon(icon, size: 18, color: const Color(0xFF1A1A2E)),
            const SizedBox(width: 8),
            Text(
              label,
              style: GoogleFonts.poppins(
                fontSize: Responsive.sp(context, 14),
                fontWeight: FontWeight.w600,
                color: const Color(0xFF1A1A2E),
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
