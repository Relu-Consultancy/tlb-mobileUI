import 'dart:math';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/event_model.dart';

class BookingConfirmedScreen extends StatelessWidget {
  final EventModel event;

  const BookingConfirmedScreen({super.key, required this.event});

  String get _bookingId {
    final rand = Random();
    final letters = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ';
    final code = StringBuffer();
    for (int i = 0; i < 4; i++) {
      code.write(letters[rand.nextInt(letters.length)]);
    }
    for (int i = 0; i < 4; i++) {
      code.write(rand.nextInt(10));
    }
    return code.toString();
  }

  @override
  Widget build(BuildContext context) {
    final id = _bookingId;

    return Scaffold(
      backgroundColor: const Color(0xFFF0F4FF),
      body: SafeArea(
        child: Column(
          children: [
            // ── Scrollable content ──
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    // ── Header with balloons + checkmark ──
                    Stack(
                      alignment: Alignment.center,
                      children: [
                        Container(
                          width: double.infinity,
                          height: 220,
                          decoration: const BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              colors: [
                                Color(0xFFD6E4FF),
                                Color(0xFFF0F4FF),
                              ],
                            ),
                          ),
                          child: Image.asset(
                            event.imagePath,
                            fit: BoxFit.cover,
                            color: Colors.white.withOpacity(0.7),
                            colorBlendMode: BlendMode.lighten,
                          ),
                        ),
                        // Back button
                        Positioned(
                          top: 8,
                          left: 8,
                          child: IconButton(
                            icon: const CircleAvatar(
                              radius: 16,
                              backgroundColor: Colors.white,
                              child: Icon(Icons.arrow_back,
                                  size: 18, color: Color(0xFF1A1A2E)),
                            ),
                            onPressed: () {
                              // Pop all the way back to home
                              Navigator.of(context)
                                  .popUntil((route) => route.isFirst);
                            },
                          ),
                        ),
                        // Checkmark + text
                        Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              width: 56,
                              height: 56,
                              decoration: const BoxDecoration(
                                color: Color(0xFF4CAF50),
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(Icons.check,
                                  color: Colors.white, size: 32),
                            ),
                            const SizedBox(height: 12),
                            Text(
                              'Booking Confirmed!',
                              style: GoogleFonts.poppins(
                                fontSize: 18,
                                fontWeight: FontWeight.w700,
                                color: const Color(0xFF1A3A8F),
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              'Booking ID: $id',
                              style: GoogleFonts.poppins(
                                fontSize: 13,
                                color: Colors.grey.shade600,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),

                    const SizedBox(height: 16),

                    // ── Ticket Card ──
                    Container(
                      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.05),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: ClipPath(
                        clipper: _TicketClipper(cutoutRadius: 16),
                        child: Column(
                          children: [
                            // ── Top Half: Event Details ──
                            Padding(
                              padding: const EdgeInsets.all(16),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                          // Event image
                          ClipRRect(
                            borderRadius: BorderRadius.circular(12),
                            child: Image.asset(
                              event.imagePath,
                              height: 140,
                              width: double.infinity,
                              fit: BoxFit.cover,
                            ),
                          ),
                          const SizedBox(height: 14),
                          // Title
                          Text(
                            event.title,
                            style: GoogleFonts.poppins(
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                              color: const Color(0xFF1A1A2E),
                            ),
                          ),
                          const SizedBox(height: 12),
                          // Location
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
                                        fontSize: 11,
                                        color: Colors.grey,
                                      ),
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      event.venue,
                                      style: GoogleFonts.poppins(
                                        fontSize: 13,
                                        fontWeight: FontWeight.w500,
                                        color: const Color(0xFF1A1A2E),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              // Map button
                              OutlinedButton.icon(
                                onPressed: () {},
                                icon: Icon(Icons.location_on_outlined,
                                    size: 14, color: Colors.grey.shade600),
                                label: Text(
                                  'Map',
                                  style: GoogleFonts.poppins(
                                    fontSize: 12,
                                    color: Colors.grey.shade600,
                                  ),
                                ),
                                style: OutlinedButton.styleFrom(
                                  side: BorderSide(color: Colors.grey.shade300),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 12, vertical: 4),
                                  minimumSize: Size.zero,
                                  tapTargetSize:
                                      MaterialTapTargetSize.shrinkWrap,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 14),
                          // Date & Time row
                          Row(
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Date',
                                      style: GoogleFonts.poppins(
                                        fontSize: 11,
                                        color: Colors.grey,
                                      ),
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      'Saturday, March',
                                      style: GoogleFonts.poppins(
                                        fontSize: 13,
                                        fontWeight: FontWeight.w500,
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
                                        fontSize: 11,
                                        color: Colors.grey,
                                      ),
                                    ),
                                    const SizedBox(height: 2),
                                      Text(
                                        '3:00 pm–6:00 pm',
                                        style: GoogleFonts.poppins(
                                          fontSize: 13,
                                          fontWeight: FontWeight.w500,
                                          color: const Color(0xFF1A1A2E),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                            
                            // ── Dashed Divider ──
                            SizedBox(
                              width: double.infinity,
                              height: 1,
                              child: CustomPaint(
                                painter: _DashedLinePainter(),
                              ),
                            ),

                            // ── Bottom Half: QR Code Section ──
                            Padding(
                              padding: const EdgeInsets.all(20),
                              child: Column(
                                children: [
                                  Text(
                                    'Scan QR Code',
                                    style: GoogleFonts.poppins(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w600,
                                      color: const Color(0xFF1A1A2E),
                                    ),
                                  ),
                                  const SizedBox(height: 16),
                                  // QR Code placeholder
                                  Container(
                                    width: 160,
                                    height: 160,
                                    decoration: BoxDecoration(
                                      border: Border.all(
                                          color: Colors.grey.shade300, width: 1),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: CustomPaint(
                                      size: const Size(160, 160),
                                      painter: _QRCodePainter(),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),

            // ── Bottom buttons ──
            Container(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
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
                      icon: const Icon(Icons.open_in_new, size: 16),
                      label: Text(
                        'Share',
                        style: GoogleFonts.poppins(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: const Color(0xFF1A1A2E),
                        side: BorderSide(color: Colors.grey.shade300),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () {},
                      icon: const Icon(Icons.download_outlined, size: 16),
                      label: Text(
                        'Download',
                        style: GoogleFonts.poppins(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF1A1A2E),
                        foregroundColor: Colors.white,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Draws a simple QR-code-like pattern
class _QRCodePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.black
      ..style = PaintingStyle.fill;

    final rand = Random(42); // deterministic seed
    const cellSize = 8.0;
    final cols = (size.width / cellSize).floor();
    final rows = (size.height / cellSize).floor();

    // Corner squares
    _drawFinderPattern(canvas, paint, 0, 0, cellSize);
    _drawFinderPattern(canvas, paint, (cols - 7) * cellSize, 0, cellSize);
    _drawFinderPattern(canvas, paint, 0, (rows - 7) * cellSize, cellSize);

    // Random data cells
    for (int r = 0; r < rows; r++) {
      for (int c = 0; c < cols; c++) {
        // Skip finder pattern areas
        if ((r < 8 && c < 8) || (r < 8 && c >= cols - 8) || (r >= rows - 8 && c < 8)) {
          continue;
        }
        if (rand.nextBool()) {
          canvas.drawRect(
            Rect.fromLTWH(c * cellSize, r * cellSize, cellSize - 1, cellSize - 1),
            paint,
          );
        }
      }
    }
  }

  void _drawFinderPattern(Canvas canvas, Paint paint, double x, double y, double cell) {
    // Outer border
    canvas.drawRect(Rect.fromLTWH(x, y, cell * 7, cell * 7), paint);
    // White inner
    final whitePaint = Paint()..color = Colors.white;
    canvas.drawRect(Rect.fromLTWH(x + cell, y + cell, cell * 5, cell * 5), whitePaint);
    // Black center
    canvas.drawRect(Rect.fromLTWH(x + cell * 2, y + cell * 2, cell * 3, cell * 3), paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

/// Creates a ticket shape by clipping semi-circles on the left and right edges
class _TicketClipper extends CustomClipper<Path> {
  final double cutoutRadius;

  _TicketClipper({this.cutoutRadius = 16.0});

  @override
  Path getClip(Size size) {
    final path = Path();
    
    // Top-left
    path.lineTo(0, size.height * 0.58 - cutoutRadius);
    
    // Left notch
    path.arcToPoint(
      Offset(0, size.height * 0.58 + cutoutRadius),
      radius: Radius.circular(cutoutRadius),
      clockwise: true,
    );
    
    // Bottom-left
    path.lineTo(0, size.height);
    
    // Bottom-right
    path.lineTo(size.width, size.height);
    
    // Right notch
    path.lineTo(size.width, size.height * 0.58 + cutoutRadius);
    path.arcToPoint(
      Offset(size.width, size.height * 0.58 - cutoutRadius),
      radius: Radius.circular(cutoutRadius),
      clockwise: true,
    );
    
    // Top-right
    path.lineTo(size.width, 0);
    
    // Close path
    path.close();
    return path;
  }

  @override
  bool shouldReclip(covariant CustomClipper<Path> oldClipper) => false;
}

/// Paints a dashed line for the ticket divider
class _DashedLinePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.grey.shade300
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;

    const dashWidth = 8.0;
    const dashSpace = 6.0;
    double startX = dashWidth; // small padding
    
    while (startX < size.width - dashWidth) {
      canvas.drawLine(Offset(startX, 0), Offset(startX + dashWidth, 0), paint);
      startX += dashWidth + dashSpace;
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
