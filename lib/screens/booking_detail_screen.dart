import 'dart:math';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../core/responsive.dart';
import '../providers/booked_events_state.dart';

/// Shows a ticket-style view for a previously booked event.
/// Uses the same ticket-shape design as BookingConfirmedScreen.
class BookingDetailScreen extends StatelessWidget {
  final BookingEntry booking;

  const BookingDetailScreen({super.key, required this.booking});

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
                      // ── Header: status badge + title + booking ID ──
                      _HeaderSection(
                        safeTop: safeTop,
                        booking: booking,
                      ),

                      // ── Ticket card (overlaps header by 20px) ──
                      Transform.translate(
                        offset: const Offset(0, -20),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 18),
                          child: _TicketCard(booking: booking),
                        ),
                      ),

                      const SizedBox(height: 16),
                    ],
                  ),
                ),
              ),

              // ── Bottom action bar ──
              _ActionButtons(safeBottom: safeBottom),
            ],
          ),

          // ── Back button (floating, top-left) ──
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

// ── 1. Header Section ────────────────────────────────────────────────────────

class _HeaderSection extends StatelessWidget {
  final double safeTop;
  final BookingEntry booking;

  const _HeaderSection({required this.safeTop, required this.booking});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(top: safeTop + 16, bottom: 0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(height: 12),

          // ── Status badge ──
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 5),
            decoration: BoxDecoration(
              color: _statusColor(booking.status).withOpacity(0.12),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              booking.status,
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
            'Booking ID: ${booking.bookingId}',
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

  Color _statusColor(String status) {
    switch (status) {
      case 'Confirmed':
        return const Color(0xFF4CAF50);
      case 'Pending':
        return const Color(0xFFFFC107);
      case 'Completed':
        return Colors.grey;
      default:
        return const Color(0xFF4CAF50);
    }
  }
}

// ── 2. Ticket Card ───────────────────────────────────────────────────────────

class _TicketCard extends StatelessWidget {
  final BookingEntry booking;

  const _TicketCard({required this.booking});

  @override
  Widget build(BuildContext context) {
    final qrSize = Responsive.w(context, 140, min: 114);

    return Stack(
      children: [
        // ── Layer 1: White ticket shape (CustomPainter) ──
        Positioned.fill(
          child: CustomPaint(
            painter: const _TicketShapePainter(
              bgColor: Color(0xFFD6E4F7),
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
                  child: Image.asset(
                    booking.event.imagePath,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => Container(
                      color: Colors.grey.shade200,
                      child:
                          const Icon(Icons.event, size: 40, color: Colors.grey),
                    ),
                  ),
                ),
              ),
            ),

            // ── Event details: title + location + date/time ──
            Padding(
              padding: const EdgeInsets.fromLTRB(18, 16, 18, 20),
              child: _TicketContent(booking: booking),
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

// ── Ticket content: title + location + date/time ─────────────────────────────

class _TicketContent extends StatelessWidget {
  final BookingEntry booking;

  const _TicketContent({required this.booking});

  @override
  Widget build(BuildContext context) {
    final event = booking.event;

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // ── Event title ──
        Text(
          event.title,
          style: GoogleFonts.poppins(
            fontSize: Responsive.sp(context, 16),
            fontWeight: FontWeight.w700,
            color: const Color(0xFF1A1A2E),
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
                      fontWeight: FontWeight.w600,
                      color: const Color(0xFF1A1A2E),
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
                    booking.date,
                    style: GoogleFonts.poppins(
                      fontSize: Responsive.sp(context, 12),
                      fontWeight: FontWeight.w600,
                      color: const Color(0xFF1A1A2E),
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
                    booking.time,
                    style: GoogleFonts.poppins(
                      fontSize: Responsive.sp(context, 12),
                      fontWeight: FontWeight.w600,
                      color: const Color(0xFF1A1A2E),
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

  const _ActionButtons({required this.safeBottom});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding:
          EdgeInsets.fromLTRB(20, 12, 20, safeBottom > 0 ? safeBottom : 16),
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

/// Draws the full ticket shape: white rounded rect with semicircle notch
/// cutouts on left/right edges + a dashed divider between them.
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
    final notchY = size.height * 0.645;

    // ── 2. Shadow (draw before clipping) ──
    final shadowPath = Path()..addRRect(bodyRRect);
    canvas.drawShadow(shadowPath, Colors.black.withOpacity(0.25), 12, true);

    // ── 3. White fill with notch cutouts ──
    final bodyPaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;

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
            (r >= rows - 8 && c < 8)) {
          continue;
        }
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
