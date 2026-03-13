import 'dart:math';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../core/responsive.dart';
import '../core/booked_events_state.dart';
import '../models/event_model.dart';
import 'event_detail_screen.dart';

class BookingConfirmedScreen extends StatefulWidget {
  final EventModel event;
  final String selectedDate;
  final String selectedTime;

  const BookingConfirmedScreen({
    super.key,
    required this.event,
    this.selectedDate = 'Saturday, March',
    this.selectedTime = '3:00 pm–6:00 pm',
  });

  @override
  State<BookingConfirmedScreen> createState() => _BookingConfirmedScreenState();
}

class _BookingConfirmedScreenState extends State<BookingConfirmedScreen>
    with SingleTickerProviderStateMixin {
  late final String _bookingId;
  bool _revealed = false;
  late final AnimationController _animCtrl;
  late final Animation<double> _flipAnimation;
  late final Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _bookingId = BookingEntry.generateId();
    BookedEventsState.addBooking(
      widget.event,
      bookingId: _bookingId,
      date: widget.selectedDate,
      time: widget.selectedTime,
    );

    _animCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );

    _flipAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _animCtrl, curve: Curves.easeInOutCubic),
    );

    _scaleAnimation = TweenSequence<double>([
      TweenSequenceItem(tween: Tween(begin: 1.0, end: 0.92), weight: 30),
      TweenSequenceItem(tween: Tween(begin: 0.92, end: 1.0), weight: 70),
    ]).animate(CurvedAnimation(parent: _animCtrl, curve: Curves.easeInOutCubic));
  }

  @override
  void dispose() {
    _animCtrl.dispose();
    super.dispose();
  }

  void _onReveal() {
    if (_revealed) return;
    _animCtrl.forward().then((_) {
      setState(() => _revealed = true);
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_revealed) {
      return _TicketScreen(
        event: widget.event,
        bookingId: _bookingId,
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

    return _ClickHereTeaser(
      flipAnimation: _flipAnimation,
      scaleAnimation: _scaleAnimation,
      onTap: _onReveal,
      child: _TicketScreen(
        event: widget.event,
        bookingId: _bookingId,
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
      ),
    );
  }
}

class _ClickHereTeaser extends StatelessWidget {
  final Animation<double> flipAnimation;
  final Animation<double> scaleAnimation;
  final VoidCallback onTap;
  final Widget child;

  const _ClickHereTeaser({
    required this.flipAnimation,
    required this.scaleAnimation,
    required this.onTap,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    final safeTop = MediaQuery.of(context).padding.top;

    return AnimatedBuilder(
      animation: flipAnimation,
      builder: (context, _) {
        final progress = flipAnimation.value;
        final showBack = progress > 0.5;

        return Stack(
          children: [
            if (showBack) child,
            if (!showBack)
              Scaffold(
                backgroundColor: const Color(0xFFD6E4F7),
                body: GestureDetector(
                  onTap: onTap,
                  child: Center(
                    child: Transform.scale(
                      scale: scaleAnimation.value,
                      child: Opacity(
                        opacity: (1.0 - progress * 2).clamp(0.0, 1.0),
                        child: Padding(
                          padding: EdgeInsets.only(top: safeTop),
                          child: Image.asset(
                            'assets/images/click_here_ticket.png',
                            fit: BoxFit.contain,
                            errorBuilder: (_, __, ___) => const Icon(Icons.confirmation_num, size: 60, color: Colors.grey),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
          ],
        );
      },
    );
  }
}

/// Shared ticket layout used by BookingConfirmedScreen (and BookingDetailScreen).
class _TicketScreen extends StatelessWidget {
  final EventModel event;
  final String bookingId;
  final String selectedDate;
  final String selectedTime;
  final bool showConfirmation;
  final VoidCallback? onBack;

  const _TicketScreen({
    required this.event,
    required this.bookingId,
    this.selectedDate = 'Saturday, March',
    this.selectedTime = '3:00 pm–6:00 pm',
    this.showConfirmation = false,
    this.onBack,
  });

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final ticketHPad = screenWidth * 0.05;
    final safeTop = MediaQuery.of(context).padding.top;

    return Scaffold(
      backgroundColor: const Color(0xFFD6E4F7),
      body: Stack(
        children: [
          Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      if (showConfirmation)
                        _buildHeader(context, safeTop),
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: ticketHPad),
                        child: _buildTicket(context),
                      ),
                      const SizedBox(height: 12),
                    ],
                  ),
                ),
              ),
              SafeArea(
                top: false,
                child: _buildBottomBar(context),
              ),
            ],
          ),
          Positioned(
            top: safeTop + 6,
            left: 12,
            child: GestureDetector(
              onTap: onBack ?? () => Navigator.of(context).pop(),
              child: Container(
                width: Responsive.w(context, 36, min: 30),
                height: Responsive.w(context, 36, min: 30),
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
    );
  }

  /// Balloon background header with checkmark + confirmation text.
  Widget _buildHeader(BuildContext context, double safeTop) {
    final headerH = Responsive.h(context, 230, min: 190) + safeTop;

    return SizedBox(
      width: double.infinity,
      height: headerH,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Balloon background – extends behind status bar
          Positioned.fill(
            child: Image.asset(
              'assets/images/booking_back.png',
              fit: BoxFit.cover,
              alignment: Alignment.topCenter,
              errorBuilder: (_, __, ___) => Container(color: const Color(0xFFD6E4F7)),
            ),
          ),
          // Tall gradient fade for seamless blend into blue bg
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            height: headerH * 0.45,
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  stops: const [0.0, 0.5, 1.0],
                  colors: [
                    const Color(0xFFD6E4F7).withOpacity(0.0),
                    const Color(0xFFD6E4F7).withOpacity(0.6),
                    const Color(0xFFD6E4F7),
                  ],
                ),
              ),
            ),
          ),
          // Checkmark + text – pushed down by safeTop
          Positioned(
            top: safeTop + 30,
            left: 0,
            right: 0,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: Responsive.w(context, 48, min: 38),
                  height: Responsive.w(context, 48, min: 38),
                  decoration: const BoxDecoration(
                    color: Color(0xFF4CAF50),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.check, color: Colors.white, size: 30),
                ),
                SizedBox(height: Responsive.h(context, 55, min: 40)),
                Text(
                  'Booking Confirmed!',
                  style: GoogleFonts.poppins(
                    fontSize: Responsive.sp(context, 18),
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFF1A3A8F),
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  'Booking ID: $bookingId',
                  style: GoogleFonts.poppins(
                    fontSize: Responsive.sp(context, 12),
                    color: Colors.grey.shade700,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// The ticket card with event details inside.
  Widget _buildTicket(BuildContext context) {
    return LayoutBuilder(
      builder: (context, outerBox) {
        final ticketW = outerBox.maxWidth;
        // Let content determine height via IntrinsicHeight
        return IntrinsicHeight(
          child: Stack(
            children: [
              // Ticket background stretched to fit content
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
              // Content with proper margins inside the white area
              Padding(
                padding: EdgeInsets.only(
                  top: ticketW * 0.06,
                  bottom: ticketW * 0.10,
                  left: ticketW * 0.08,
                  right: ticketW * 0.08,
                ),
                child: _TicketContent(
                  event: event,
                  bookingId: bookingId,
                  selectedDate: selectedDate,
                  selectedTime: selectedTime,
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildBottomBar(BuildContext context) {
    return Container(
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
                padding: const EdgeInsets.symmetric(vertical: 12),
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: OutlinedButton.icon(
              onPressed: () {},
              icon: const Icon(Icons.download_outlined, size: 18),
              label: Text('Download',
                  style: GoogleFonts.poppins(
                      fontSize: 14, fontWeight: FontWeight.w600)),
              style: OutlinedButton.styleFrom(
                foregroundColor: const Color(0xFF1A1A2E),
                side: BorderSide(color: Colors.grey.shade300),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
                padding: const EdgeInsets.symmetric(vertical: 12),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Event details content inside the ticket.
class _TicketContent extends StatelessWidget {
  final EventModel event;
  final String bookingId;
  final String selectedDate;
  final String selectedTime;

  const _TicketContent({
    required this.event,
    required this.bookingId,
    this.selectedDate = 'Saturday, March',
    this.selectedTime = '3:00 pm–6:00 pm',
  });

  @override
  Widget build(BuildContext context) {
    final qrSize = Responsive.w(context, 130, min: 100);

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Event image with margins
        Padding(
          padding: const EdgeInsets.only(top: 12, left: 4, right: 4),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Image.asset(
              event.imagePath,
              height: Responsive.h(context, 120, min: 90),
              width: double.infinity,
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => Container(
                height: Responsive.h(context, 120, min: 90),
                color: Colors.grey.shade200,
                child: const Icon(Icons.event, size: 40, color: Colors.grey),
              ),
            ),
          ),
        ),

        const SizedBox(height: 14),

        // Event title
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4),
          child: Align(
            alignment: Alignment.centerLeft,
            child: Text(
              event.title,
              style: GoogleFonts.poppins(
                fontSize: Responsive.sp(context, 14),
                fontWeight: FontWeight.w700,
                color: const Color(0xFF1A1A2E),
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ),

        const SizedBox(height: 10),

        // Location
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Location',
                        style: GoogleFonts.poppins(
                            fontSize: Responsive.sp(context, 9.5),
                            color: Colors.grey)),
                    const SizedBox(height: 2),
                    Text(
                      event.venue,
                      style: GoogleFonts.poppins(
                        fontSize: Responsive.sp(context, 11.5),
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
        ),

        const SizedBox(height: 10),

        // Date & Time
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Date',
                        style: GoogleFonts.poppins(
                            fontSize: Responsive.sp(context, 9.5),
                            color: Colors.grey)),
                    const SizedBox(height: 2),
                    Text(selectedDate,
                        style: GoogleFonts.poppins(
                            fontSize: Responsive.sp(context, 11.5),
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
                            fontSize: Responsive.sp(context, 9.5),
                            color: Colors.grey)),
                    const SizedBox(height: 2),
                    Text(selectedTime,
                        style: GoogleFonts.poppins(
                            fontSize: Responsive.sp(context, 11.5),
                            fontWeight: FontWeight.w500,
                            color: const Color(0xFF1A1A2E))),
                  ],
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 18),

        // Dashed divider
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4),
          child: SizedBox(
            width: double.infinity,
            height: 1,
            child: CustomPaint(painter: _DashedLinePainter()),
          ),
        ),

        const SizedBox(height: 18),

        // QR Code
        Text(
          'Scan QR Code',
          style: GoogleFonts.poppins(
            fontSize: Responsive.sp(context, 13),
            fontWeight: FontWeight.w600,
            color: const Color(0xFF1A1A2E),
          ),
        ),
        const SizedBox(height: 15),
        Container(
          width: qrSize,
          height: qrSize,
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey.shade200, width: 1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: CustomPaint(
            size: Size(qrSize, qrSize),
            painter: _QRCodePainter(),
          ),
        ),
        const SizedBox(height: 8),
      ],
    );
  }
}

// ─────────────────────────── Painters ───────────────────────────

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
