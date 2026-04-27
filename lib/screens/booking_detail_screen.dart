import 'dart:math';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../core/responsive.dart';
import '../core/booked_events_state.dart';

/// Shows a ticket-style view for a previously booked event.
class BookingDetailScreen extends StatelessWidget {
  final BookingEntry booking;

  const BookingDetailScreen({super.key, required this.booking});

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    const bottomBarH = 72.0;
    final ticketHPad = screenWidth * 0.045;

    return Scaffold(
      backgroundColor: const Color(0xFFD6E4F7),
      body: SafeArea(
        child: Stack(
          children: [
            Column(
              children: [
                Expanded(
                  child: SingleChildScrollView(
                    child: Padding(
                      padding: EdgeInsets.symmetric(horizontal: ticketHPad, vertical: 24),
                      child: LayoutBuilder(
                        builder: (context, outerBox) {
                          final ticketW = outerBox.maxWidth;
                          
                          return IntrinsicHeight(
                            child: Stack(
                              children: [
                                Positioned.fill(
                                  child: Image.asset(
                                    'assets/images/updated_ticket.png',
                                    fit: BoxFit.fill,
                                    errorBuilder: (_, __, ___) => Container(
                                      decoration: BoxDecoration(
                                        color: Colors.white,
                                        borderRadius: BorderRadius.circular(16),
                                      ),
                                    ),
                                  ),
                                ),
                                Padding(
                                  padding: EdgeInsets.only(
                                    top: ticketW * 0.06,
                                    bottom: ticketW * 0.10,
                                    left: ticketW * 0.08,
                                    right: ticketW * 0.08,
                                  ),
                                  child: _BookingBody(booking: booking),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                ),
                Container(
                  height: bottomBarH,
                  padding: const EdgeInsets.fromLTRB(20, 10, 20, 14),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 8,
                        offset: const Offset(0, -2),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () {},
                          icon: const Icon(Icons.share_outlined, size: 18),
                          label: Text('Share',
                              style: GoogleFonts.poppins(
                                  fontSize: 14, fontWeight: FontWeight.w600)),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: const Color(0xFF1A1A2E),
                            side: BorderSide(color: Colors.grey.shade300),
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12)),
                            padding:
                                const EdgeInsets.symmetric(vertical: 12),
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () {},
                          icon:
                              const Icon(Icons.download_outlined, size: 18),
                          label: Text('Download',
                              style: GoogleFonts.poppins(
                                  fontSize: 14, fontWeight: FontWeight.w600)),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: const Color(0xFF1A1A2E),
                            side: BorderSide(color: Colors.grey.shade300),
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12)),
                            padding:
                                const EdgeInsets.symmetric(vertical: 12),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),

            // Back button on screen top-left
            Positioned(
              top: 8,
              left: 12,
              child: GestureDetector(
                onTap: () => Navigator.of(context).pop(),
                child: Container(
                  width: 38,
                  height: 38,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 6,
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.arrow_back,
                    size: 19,
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
}

class _BookingBody extends StatelessWidget {
  final BookingEntry booking;

  const _BookingBody({required this.booking});

  @override
  Widget build(BuildContext context) {
    final event = booking.event;
    final imageH = Responsive.h(context, 120, min: 100);
    final qrSize = Responsive.w(context, 130, min: 105);
    final gap = Responsive.h(context, 12, min: 8);
    final gapSm = Responsive.h(context, 8, min: 5);

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(height: gap),

              // Status badge
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
                decoration: BoxDecoration(
                  color: _statusColor(booking.status).withOpacity(0.12),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  booking.status,
                  style: GoogleFonts.poppins(
                    fontSize: Responsive.sp(context, 11),
                    fontWeight: FontWeight.w600,
                    color: _statusColor(booking.status),
                  ),
                ),
              ),
              SizedBox(height: gapSm),
              Text(
                'Booking Details',
                style: GoogleFonts.poppins(
                  fontSize: Responsive.sp(context, 16),
                  fontWeight: FontWeight.w700,
                  color: const Color(0xFF1A3A8F),
                ),
              ),
              SizedBox(height: gapSm * 0.5),
              Text(
                'Booking ID: ${booking.bookingId}',
                style: GoogleFonts.poppins(
                  fontSize: Responsive.sp(context, 10.5),
                  color: Colors.grey.shade600,
                ),
              ),

              SizedBox(height: gap),

              // Event image
              ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: Image.asset(
                  event.imagePath,
                  height: imageH,
                  width: double.infinity,
                  fit: BoxFit.cover,
                ),
              ),

              SizedBox(height: gap),

              // Title
              Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  event.title,
                  style: GoogleFonts.poppins(
                    fontSize: Responsive.sp(context, 13.5),
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFF1A1A2E),
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),

              SizedBox(height: gapSm),

              // Location
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Location',
                            style: GoogleFonts.poppins(
                                fontSize: Responsive.sp(context, 9),
                                color: Colors.grey)),
                        const SizedBox(height: 1),
                        Text(
                          event.venue,
                          style: GoogleFonts.poppins(
                            fontSize: Responsive.sp(context, 11),
                            fontWeight: FontWeight.w500,
                            color: const Color(0xFF1A1A2E),
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 6),
                  OutlinedButton.icon(
                    onPressed: () {},
                    icon: Icon(Icons.location_on_outlined,
                        size: 14, color: Colors.grey.shade600),
                    label: Text('Map',
                        style: GoogleFonts.poppins(
                            fontSize: 10, color: Colors.grey.shade600)),
                    style: OutlinedButton.styleFrom(
                      side: BorderSide(color: Colors.grey.shade300),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20)),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 2),
                      minimumSize: Size.zero,
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                  ),
                ],
              ),

              SizedBox(height: gapSm),

              // Date & Time
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Date',
                            style: GoogleFonts.poppins(
                                fontSize: Responsive.sp(context, 9),
                                color: Colors.grey)),
                        const SizedBox(height: 1),
                        Text(booking.date,
                            style: GoogleFonts.poppins(
                                fontSize: Responsive.sp(context, 11),
                                fontWeight: FontWeight.w500,
                                color: const Color(0xFF1A1A2E))),
                      ],
                    ),
                  ),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Time',
                            style: GoogleFonts.poppins(
                                fontSize: Responsive.sp(context, 9),
                                color: Colors.grey)),
                        const SizedBox(height: 1),
                        Text(booking.time,
                            style: GoogleFonts.poppins(
                                fontSize: Responsive.sp(context, 11),
                                fontWeight: FontWeight.w500,
                                color: const Color(0xFF1A1A2E))),
                      ],
                    ),
                  ),
                ],
              ),

              SizedBox(height: gap * 1.2),

              // Dashed divider
              SizedBox(
                width: double.infinity,
                height: 1,
                child: CustomPaint(painter: _DashedLinePainter()),
              ),

              SizedBox(height: gap * 1.2),

              // QR Code
              Text(
                'Scan QR Code',
                style: GoogleFonts.poppins(
                  fontSize: Responsive.sp(context, 12.5),
                  fontWeight: FontWeight.w600,
                  color: const Color(0xFF1A1A2E),
                ),
              ),
              SizedBox(height: gapSm),
              Container(
                width: qrSize,
                height: qrSize,
                decoration: BoxDecoration(
                  border:
                      Border.all(color: Colors.grey.shade200, width: 1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: CustomPaint(
                  size: Size(qrSize, qrSize),
                  painter: _QRCodePainter(),
                ),
              ),
              SizedBox(height: gap),
            ],
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

// ─────────────────── Painters ───────────────────

class _QRCodePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.black
      ..style = PaintingStyle.fill;

    final rand = Random(42);
    const cellSize = 8.0;
    final cols = (size.width / cellSize).floor();
    final rows = (size.height / cellSize).floor();

    _drawFinder(canvas, paint, 0, 0, cellSize);
    _drawFinder(canvas, paint, (cols - 7) * cellSize, 0, cellSize);
    _drawFinder(canvas, paint, 0, (rows - 7) * cellSize, cellSize);

    for (int r = 0; r < rows; r++) {
      for (int c = 0; c < cols; c++) {
        if ((r < 8 && c < 8) ||
            (r < 8 && c >= cols - 8) ||
            (r >= rows - 8 && c < 8)) {
          continue;
        }
        if (rand.nextBool()) {
          canvas.drawRect(
            Rect.fromLTWH(
                c * cellSize, r * cellSize, cellSize - 1, cellSize - 1),
            paint,
          );
        }
      }
    }
  }

  void _drawFinder(Canvas canvas, Paint p, double x, double y, double c) {
    canvas.drawRect(Rect.fromLTWH(x, y, c * 7, c * 7), p);
    final w = Paint()..color = Colors.white;
    canvas.drawRect(Rect.fromLTWH(x + c, y + c, c * 5, c * 5), w);
    canvas.drawRect(Rect.fromLTWH(x + c * 2, y + c * 2, c * 3, c * 3), p);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _DashedLinePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.grey.shade300
      ..strokeWidth = 1.5
      ..style = PaintingStyle.stroke;

    const dashW = 8.0;
    const gapW = 5.0;
    double x = 0;
    while (x < size.width) {
      canvas.drawLine(Offset(x, 0), Offset(x + dashW, 0), paint);
      x += dashW + gapW;
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
