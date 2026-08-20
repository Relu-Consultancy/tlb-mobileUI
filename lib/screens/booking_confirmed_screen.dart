import '../core/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../core/responsive.dart';
import '../widgets/booking_qr.dart';
import '../providers/booked_events_state.dart';
import '../models/event_model.dart';
import '../services/ticket_pdf_service.dart';
import 'event_detail_screen.dart';

class BookingConfirmedScreen extends StatefulWidget {
  final EventModel event;
  final String selectedDate;
  final String selectedTime;
  final String? bookingReference;
  final String? bookingId;

  const BookingConfirmedScreen({
    super.key,
    required this.event,
    this.selectedDate = 'Saturday, March',
    this.selectedTime = '3:00 pm–6:00 pm',
    this.bookingReference,
    this.bookingId,
  });

  @override
  State<BookingConfirmedScreen> createState() => _BookingConfirmedScreenState();
}

class _BookingConfirmedScreenState extends State<BookingConfirmedScreen> {
  late final String _bookingId;

  @override
  void initState() {
    super.initState();
    _bookingId = widget.bookingReference ?? BookingEntry.generateId();
    BookedEventsState.addBooking(
      widget.event,
      bookingId: _bookingId,
      date: widget.selectedDate,
      time: widget.selectedTime,
    );
  }

  @override
  Widget build(BuildContext context) {
    // Straight to the ticket. A "Click Here" card used to sit in front of this
    // with a flip animation; the venue and program confirmations never had one,
    // so this now matches them.
    return _TicketScreen(
      event: widget.event,
      bookingId: _bookingId,
      apiBookingId: widget.bookingId,
      selectedDate: widget.selectedDate,
      selectedTime: widget.selectedTime,
      showConfirmation: true,
      onBack: () {
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(
            builder: (_) => EventDetailScreen(event: widget.event),
          ),
          (route) => route.isFirst,
        );
      },
    );
  }
}

// ── Main ticket screen ───────────────────────────────────────────────────────

class _TicketScreen extends StatelessWidget {
  final EventModel event;
  final String bookingId;
  final String? apiBookingId;
  final String selectedDate;
  final String selectedTime;
  final bool showConfirmation;
  final VoidCallback? onBack;

  const _TicketScreen({
    required this.event,
    required this.bookingId,
    this.apiBookingId,
    this.selectedDate = 'Saturday, March',
    this.selectedTime = '3:00 pm–6:00 pm',
    this.showConfirmation = false,
    this.onBack,
  });

  @override
  Widget build(BuildContext context) {
    final safeTop = MediaQuery.of(context).padding.top;
    final safeBottom = MediaQuery.of(context).padding.bottom;

    return Scaffold(
      backgroundColor: const Color(0xFFD6E4F7),
      body: Stack(
        children: [
          // ── Scrollable body ──
          Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  child: Column(
                    children: [
                      // ── Header (balloon bg + confirmation text) ──
                      if (showConfirmation)
                        _HeaderSection(
                          safeTop: safeTop,
                          bookingId: bookingId,
                        ),

                      // ── Ticket card (overlaps header by 36px) ──
                      Transform.translate(
                        offset: const Offset(0, -36),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 18),
                          child: _TicketCard(
                            event: event,
                            bookingId: bookingId,
                            apiBookingId: apiBookingId,
                            selectedDate: selectedDate,
                            selectedTime: selectedTime,
                          ),
                        ),
                      ),

                      const SizedBox(height: 16),
                    ],
                  ),
                ),
              ),

              // ── Bottom action bar ──
              _ActionButtons(
                safeBottom: safeBottom,
                bookingId: apiBookingId,
              ),
            ],
          ),

          // ── Back button (floating, top-left) ──
          Positioned(
            top: safeTop + 8,
            left: 14,
            child: GestureDetector(
              onTap: onBack ?? () => Navigator.of(context).pop(),
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
                  color: AppColors.textPrimary,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── 1. Header Section ────────────────────────────────────────────────────────

class _HeaderSection extends StatelessWidget {
  final double safeTop;
  final String bookingId;

  const _HeaderSection({required this.safeTop, required this.bookingId});

  @override
  Widget build(BuildContext context) {
    final headerH = safeTop + 240.0;

    return SizedBox(
      width: double.infinity,
      height: headerH,
      child: Stack(
        children: [
          // Balloon background image
          Positioned.fill(
            child: Image.asset(
              'assets/images/booking_back.png',
              fit: BoxFit.cover,
              alignment: Alignment.topCenter,
              errorBuilder: (_, __, ___) =>
                  Container(color: const Color(0xFFD6E4F7)),
            ),
          ),

          // White tint overlay — washes out the balloons so text is readable
          Positioned.fill(
            child: Container(
              color: Colors.white.withOpacity(0.50),
            ),
          ),

          // Bottom fade to blend into scaffold background
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            height: 90,
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    const Color(0xFFD6E4F7).withOpacity(0),
                    const Color(0xFFD6E4F7),
                  ],
                ),
              ),
            ),
          ),

          // Confirmation content – checkmark + title + booking ID
          Positioned(
            top: safeTop + 20,
            left: 0,
            right: 0,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // ── White-ringed green success badge ──
                Container(
                  width: 66,
                  height: 66,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.successGreen.withOpacity(0.28),
                        blurRadius: 16,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Center(
                    child: Container(
                      width: 50,
                      height: 50,
                      decoration: const BoxDecoration(
                        color: AppColors.successGreen,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.check_rounded,
                          color: Colors.white, size: 28),
                    ),
                  ),
                ),

                const SizedBox(height: 14),

                Text(
                  'Booking Confirmed!',
                  style: GoogleFonts.poppins(
                    fontSize: Responsive.sp(context, 20),
                    fontWeight: FontWeight.w500,
                    color: const Color(0xFF1A3A8F),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Booking ID: $bookingId',
                  style: GoogleFonts.poppins(
                    fontSize: Responsive.sp(context, 12),
                    color: Colors.grey.shade600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ── 2. Ticket Card ───────────────────────────────────────────────────────────

class _TicketCard extends StatelessWidget {
  final EventModel event;
  final String bookingId;

  /// API booking uuid — what the ticket/QR endpoint is keyed on. [bookingId]
  /// above is the human-readable reference and can't be used for the fetch.
  final String? apiBookingId;

  final String selectedDate;
  final String selectedTime;

  const _TicketCard({
    required this.event,
    required this.bookingId,
    this.apiBookingId,
    required this.selectedDate,
    required this.selectedTime,
  });

  @override
  Widget build(BuildContext context) {
    final qrSize = Responsive.w(context, 140, min: 114);

    return Stack(
      children: [
        // ── Layer 1: White ticket shape (CustomPainter) ──
        // Draws the full ticket body, notch cutouts, and dashed divider.
        // The painter is sized by the Column content via Positioned.fill.
        Positioned.fill(
          child: CustomPaint(
            painter: _TicketShapePainter(
              bgColor: const Color(0xFFD6E4F7),
            ),
          ),
        ),

        // ── Layer 2: Content on top ──
        Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // ── Event image: rounded top matching ticket shape ──
            Padding(
              padding: const EdgeInsets.fromLTRB(4, 4, 4, 0),
              child: ClipRRect(
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(20),
                  topRight: Radius.circular(20),
                ),
                child: AspectRatio(
                  aspectRatio: 16 / 9,
                  // The booked event's image is a network URL after a real
                  // booking (and a bundled asset for mock data) — branch so the
                  // confirmed ticket shows the real cover, not the placeholder.
                  child: event.imagePath.startsWith('http')
                      ? Image.network(
                          event.imagePath,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => Container(
                            color: Colors.grey.shade200,
                            child: const Icon(Icons.event,
                                size: 40, color: Colors.grey),
                          ),
                        )
                      : Image.asset(
                          event.imagePath,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => Container(
                            color: Colors.grey.shade200,
                            child: const Icon(Icons.event,
                                size: 40, color: Colors.grey),
                          ),
                        ),
                ),
              ),
            ),

            // ── Event details: title + location + date/time ──
            Padding(
              padding: const EdgeInsets.fromLTRB(18, 16, 18, 20),
              child: _TicketContent(
                event: event,
                bookingId: bookingId,
                selectedDate: selectedDate,
                selectedTime: selectedTime,
              ),
            ),

            // ── Notch area spacer (painter draws the notches + dashed line here) ──
            const SizedBox(height: 28),

            // ── QR code section ──
            Padding(
              padding: const EdgeInsets.fromLTRB(18, 4, 18, 26),
              child: Column(
                children: [
                  Text(
                    'Scan QR Code',
                    style: GoogleFonts.poppins(
                      fontSize: Responsive.sp(context, 13),
                      fontWeight: FontWeight.w500,
                      color: AppColors.textPrimary,
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
                    child: BookingQr(bookingId: apiBookingId, size: qrSize - 12),
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

// ── Ticket content: title + location + date/time ─────────────────────────────

class _TicketContent extends StatelessWidget {
  final EventModel event;
  final String bookingId;
  final String selectedDate;
  final String selectedTime;

  const _TicketContent({
    required this.event,
    required this.bookingId,
    required this.selectedDate,
    required this.selectedTime,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // ── Event title ──
        Text(
          event.title,
          style: GoogleFonts.poppins(
            fontSize: Responsive.sp(context, 16),
            fontWeight: FontWeight.w500,
            color: AppColors.textPrimary,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),

        const SizedBox(height: 14),

        // ── Location row ──
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Location',
                    style: GoogleFonts.poppins(
                        fontSize: Responsive.sp(context, 10), color: Colors.grey.shade500),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    event.venue,
                    style: GoogleFonts.poppins(
                      fontSize: Responsive.sp(context, 12),
                      fontWeight: FontWeight.w500,
                      color: AppColors.textPrimary,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            // Map button
            Container(
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey.shade300),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.location_on_outlined,
                        size: 13, color: Colors.grey.shade600),
                    const SizedBox(width: 3),
                    Text(
                      'Map',
                      style: GoogleFonts.poppins(
                          fontSize: Responsive.sp(context, 10), color: Colors.grey.shade600),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),

        const SizedBox(height: 14),

        // ── Date & Time (2 columns) ──
        Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Date',
                    style: GoogleFonts.poppins(
                        fontSize: Responsive.sp(context, 10), color: Colors.grey.shade500),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    selectedDate,
                    style: GoogleFonts.poppins(
                      fontSize: Responsive.sp(context, 12),
                      fontWeight: FontWeight.w500,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Time',
                    style: GoogleFonts.poppins(
                        fontSize: Responsive.sp(context, 10), color: Colors.grey.shade500),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    selectedTime,
                    style: GoogleFonts.poppins(
                      fontSize: Responsive.sp(context, 12),
                      fontWeight: FontWeight.w500,
                      color: AppColors.textPrimary,
                    ),
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

// ── 3. Bottom Action Buttons ─────────────────────────────────────────────────

class _ActionButtons extends StatelessWidget {
  final double safeBottom;
  final String? bookingId;

  const _ActionButtons({required this.safeBottom, this.bookingId});

  @override
  Widget build(BuildContext context) {
    final canDownload = bookingId != null && bookingId!.isNotEmpty;
    return Container(
      padding: EdgeInsets.fromLTRB(20, 12, 20, safeBottom > 0 ? safeBottom : 16),
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
      child: Row(
        children: [
          Expanded(
            child: _ActionBtn(
              icon: Icons.share_outlined,
              label: 'Share',
              onTap: canDownload
                  ? () => TicketPdfService.downloadAndShare(
                        context,
                        bookingId: bookingId!,
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
                        context,
                        bookingId: bookingId!,
                      )
                  : null,
            ),
          ),
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
                    : AppColors.textPrimary),
            const SizedBox(width: 8),
            Text(
              label,
              style: GoogleFonts.poppins(
                fontSize: Responsive.sp(context, 14),
                fontWeight: FontWeight.w500,
                color: disabled
                    ? const Color(0xFF9CA3AF)
                    : AppColors.textPrimary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Painters ─────────────────────────────────────────────────────────────────

/// Draws the full ticket shape: white rounded rect with semicircle notch
/// cutouts on left/right edges + a dashed divider between them.
/// [bgColor] is painted into the notch circles so they match the scaffold.
class _TicketShapePainter extends CustomPainter {
  final Color bgColor;
  const _TicketShapePainter({required this.bgColor});

  static const _radius = 22.0;
  static const _notchR = 14.0;

  @override
  void paint(Canvas canvas, Size size) {
    // ── 1. Ticket body path (rounded rect) ──
    final bodyRRect = RRect.fromRectAndRadius(
      Rect.fromLTWH(0, 0, size.width, size.height),
      const Radius.circular(_radius),
    );

    // Notch center Y — aligned with the 28px spacer between details and QR.
    // We approximate it at roughly 65% of the total card height.
    final notchY = size.height * 0.645;

    // ── 2. Shadow (draw before clipping) ──
    final shadowPath = Path()..addRRect(bodyRRect);
    canvas.drawShadow(shadowPath, Colors.black.withOpacity(0.25), 12, true);

    // ── 3. White fill with notch cutouts ──
    // We draw the rounded rect, then subtract (punch out) the two semicircles.
    final bodyPaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;

    // Save, clip to body minus notches, then fill
    canvas.save();

    final clipPath = Path()..addRRect(bodyRRect);
    // Subtract left notch
    clipPath.addOval(Rect.fromCircle(
      center: Offset(0, notchY),
      radius: _notchR,
    ));
    // Subtract right notch
    clipPath.addOval(Rect.fromCircle(
      center: Offset(size.width, notchY),
      radius: _notchR,
    ));
    clipPath.fillType = PathFillType.evenOdd;

    canvas.clipPath(clipPath);
    canvas.drawRRect(bodyRRect, bodyPaint);
    canvas.restore();

    // ── 4. Dashed line between notches ──
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
