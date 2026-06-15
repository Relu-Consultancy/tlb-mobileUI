import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../core/responsive.dart';
import '../models/api_event_model.dart';
import '../models/event_model.dart';
import 'ticket_booking_screen.dart';

class DateTimeSelectionScreen extends StatefulWidget {
  final EventModel event;
  final List<ApiEventTicket>? apiTickets;
  final DateTime? eventDateTime;
  final DateTime? eventEndDateTime;

  const DateTimeSelectionScreen({
    super.key,
    required this.event,
    this.apiTickets,
    this.eventDateTime,
    this.eventEndDateTime,
  });

  @override
  State<DateTimeSelectionScreen> createState() =>
      _DateTimeSelectionScreenState();
}

class _DateTimeSelectionScreenState extends State<DateTimeSelectionScreen> {
  int? _selectedDateIndex;
  int? _selectedTimeIndex;

  late List<String> _dates;
  late List<String> _times;

  static const Color _bg = Color(0xFFF2F3F5);
  static const Color _dark = Color(0xFF1A1A2E);

  static String _fmtDate(DateTime dt) {
    const months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    const days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    return '${days[dt.weekday - 1]} ${dt.day} ${months[dt.month - 1]}';
  }

  static String _fmtTime(DateTime dt) {
    final h = dt.hour > 12 ? dt.hour - 12 : (dt.hour == 0 ? 12 : dt.hour);
    final m = dt.minute.toString().padLeft(2, '0');
    final ampm = dt.hour >= 12 ? 'PM' : 'AM';
    return '$h:$m $ampm';
  }

  @override
  void initState() {
    super.initState();
    if (widget.eventDateTime != null) {
      // Convert UTC → device local time (handles IST and any other timezone)
      final start = widget.eventDateTime!.toLocal();
      final end = widget.eventEndDateTime?.toLocal();

      // Single session: show only the real event date
      _dates = [_fmtDate(start)];

      // Show time range if end time is known, otherwise just start time
      _times = [
        end != null ? '${_fmtTime(start)} – ${_fmtTime(end)}' : _fmtTime(start),
      ];
    } else {
      final baseDate = widget.event.eventDate ?? 'Sat 27 Feb';
      _dates = [baseDate, 'Sun 28 Feb', 'Mon 1 Mar', 'Tue 2 Mar', 'Thu 4 Mar', 'Fri 5 Mar'];
      final baseTime = widget.event.eventTime ?? '11:00 AM';
      _times = [baseTime, '12:00 PM', '01:00 PM', '02:00 PM', '03:00 PM', '04:00 PM'];
    }
    _selectedDateIndex = 0;
    _selectedTimeIndex = 0;
  }

  bool get _canContinue =>
      _selectedDateIndex != null && _selectedTimeIndex != null;

  @override
  Widget build(BuildContext context) {
    final event = widget.event;

    return Scaffold(
      backgroundColor: _bg,
      appBar: AppBar(
        backgroundColor: _bg,
        surfaceTintColor: _bg,
        elevation: 0,
        scrolledUnderElevation: 0,
        leadingWidth: 60,
        leading: Padding(
          padding: const EdgeInsets.only(left: 14),
          child: GestureDetector(
            onTap: () => Navigator.pop(context),
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.08),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: const Icon(Icons.arrow_back, color: _dark, size: 20),
            ),
          ),
        ),
        titleSpacing: 4,
        title: Text(
          event.title,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: GoogleFonts.poppins(
            fontSize: Responsive.sp(context, 18),
            fontWeight: FontWeight.w700,
            color: _dark,
          ),
        ),
      ),
      body: Column(
        children: [
          _buildHeader(context, event),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
              child: Column(
                children: [
                  _buildSelectionCard(
                    title: 'Select Date',
                    items: _dates,
                    selectedIndex: _selectedDateIndex,
                    onSelect: (i) => setState(() => _selectedDateIndex = i),
                  ),
                  const SizedBox(height: 18),
                  _buildSelectionCard(
                    title: 'Select Time',
                    items: _times,
                    selectedIndex: _selectedTimeIndex,
                    onSelect: (i) => setState(() => _selectedTimeIndex = i),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
          child: SizedBox(
            width: double.infinity,
            height: Responsive.h(context, 52, min: 46),
            child: ElevatedButton(
              onPressed: _canContinue
                  ? () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => TicketBookingScreen(
                            event: event,
                            selectedDate: _dates[_selectedDateIndex!],
                            selectedTime: _times[_selectedTimeIndex!],
                            apiTickets: widget.apiTickets,
                          ),
                        ),
                      );
                    }
                  : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFFFCC00),
                foregroundColor: _dark,
                disabledBackgroundColor: Colors.grey.shade300,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(28),
                ),
              ),
              child: Text(
                'Continue',
                style: GoogleFonts.poppins(
                  fontSize: Responsive.sp(context, 16),
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  // ── Address (dark) + rating, with a map graphic blended in on the right ──
  Widget _buildHeader(BuildContext context, EventModel event) {
    return SizedBox(
      width: double.infinity,
      child: Stack(
        children: [
          // Map graphic tucked into the top-right corner, fading (seamless)
          // toward the bottom-left so there are no hard edges.
          Positioned(
            right: 0,
            top: 0,
            width: Responsive.w(context, 160, min: 130),
            height: Responsive.h(context, 92, min: 80),
            child: ShaderMask(
              blendMode: BlendMode.dstIn,
              shaderCallback: (rect) => const RadialGradient(
                center: Alignment.topRight,
                radius: 1.15,
                colors: [Colors.white, Colors.transparent],
                stops: [0.42, 1.0],
              ).createShader(rect),
              child: CustomPaint(painter: _MiniMapPainter()),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                SizedBox(
                  width: Responsive.w(context, 240, min: 180),
                  child: Text(
                    event.venue,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.poppins(
                      fontSize: Responsive.sp(context, 13.5),
                      fontWeight: FontWeight.w500,
                      color: _dark, // dark coloured address
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    ...List.generate(
                      5,
                      (i) => Icon(
                        i < (event.rating?.round() ?? 4)
                            ? Icons.star
                            : Icons.star_border,
                        size: 16,
                        color: Colors.amber,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      '(${event.reviewCount ?? "124 reviews"})',
                      style: GoogleFonts.poppins(
                        fontSize: Responsive.sp(context, 12),
                        color: Colors.grey.shade500,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSelectionCard({
    required String title,
    required List<String> items,
    required int? selectedIndex,
    required ValueChanged<int> onSelect,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: GoogleFonts.poppins(
              fontSize: Responsive.sp(context, 16),
              fontWeight: FontWeight.w700,
              color: _dark,
            ),
          ),
          const SizedBox(height: 16),
          Column(
            children: [
              for (int row = 0; row < (items.length / 3).ceil(); row++) ...[
                if (row > 0) const SizedBox(height: 12),
                Row(
                  children: [
                    for (int col = 0; col < 3; col++) ...[
                      if (col > 0) const SizedBox(width: 10),
                      Expanded(
                        child: (row * 3 + col < items.length)
                            ? _optionBox(
                                items[row * 3 + col],
                                selectedIndex == (row * 3 + col),
                                () => onSelect(row * 3 + col),
                              )
                            : const SizedBox(),
                      ),
                    ],
                  ],
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }

  // Rectangular option box. Selected → static premium golden-shine gradient.
  Widget _optionBox(String label, bool selected, VoidCallback onTap) {
    final text = FittedBox(
      fit: BoxFit.scaleDown,
      child: Text(
        label,
        style: GoogleFonts.poppins(
          fontSize: Responsive.sp(context, 12.5),
          fontWeight: selected ? FontWeight.w500 : FontWeight.w400,
          color: _dark,
        ),
      ),
    );

    return GestureDetector(
      onTap: onTap,
      child: Container(
        alignment: Alignment.center,
        padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 6),
        decoration: selected
            ? BoxDecoration(
                borderRadius: BorderRadius.circular(9),
                // Lighter golden gradient (left → right), keeping the soft
                // shine highlight blended through the middle.
                gradient: const LinearGradient(
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                  colors: [
                    Color(0xFFFAC83F), // light gold (left)
                    Color(0xFFFFD862), // gold
                    Color(0xFFFFF1C8), // soft shine (middle)
                    Color(0xFFFFE189), // light gold
                    Color(0xFFFFDE7E), // soft warm gold (right)
                  ],
                  stops: [0.0, 0.30, 0.52, 0.76, 1.0],
                ),
                // A little darker (but soft) golden boundary to define the box.
                border: Border.all(color: const Color(0xFFE0A92E), width: 1.1),
                boxShadow: [
                  // Soft, restrained golden glow.
                  BoxShadow(
                    color: const Color(0xFFFFC107).withOpacity(0.32),
                    blurRadius: 12,
                    offset: const Offset(0, 3),
                  ),
                ],
              )
            : BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(9),
                border: Border.all(color: const Color(0xFFF1EFEA)),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.035),
                    blurRadius: 6,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
        child: text,
      ),
    );
  }
}

/// A subtle, stylised mini-map used as a blended decoration on the right of the
/// header — a small street network with buildings, a park, a river, a route and
/// a pin. No external asset required.
class _MiniMapPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;
    Offset p(double x, double y) => Offset(w * x, h * y);
    Rect r(double x, double y, double bw, double bh) =>
        Rect.fromLTWH(w * x, h * y, w * bw, h * bh);

    // Warm map base (Google-Maps-like tan/grey).
    canvas.drawRect(
        Offset.zero & size, Paint()..color = const Color(0xFFECE9E2));

    // ── Park (green) ──
    final park = Paint()..color = const Color(0xFFD8E4CC);
    canvas.drawRRect(
        RRect.fromRectAndRadius(r(0.04, 0.10, 0.26, 0.30),
            const Radius.circular(6)),
        park);

    // ── River / water (soft blue) running diagonally ──
    final water = Paint()
      ..color = const Color(0xFFCFE0EC)
      ..style = PaintingStyle.stroke
      ..strokeWidth = w * 0.085
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;
    canvas.drawPath(
      Path()
        ..moveTo(w * 0.02, h * 0.92)
        ..quadraticBezierTo(w * 0.40, h * 0.70, w * 0.58, h * 0.96),
      water,
    );

    // ── Building blocks (varied rounded rects) ──
    final block = Paint()..color = const Color(0xFFE1DDD3);
    final block2 = Paint()..color = const Color(0xFFDBD6CB);
    final blocks = <Rect>[
      r(0.36, 0.06, 0.16, 0.14), r(0.55, 0.05, 0.13, 0.12),
      r(0.72, 0.08, 0.16, 0.15), r(0.36, 0.24, 0.14, 0.13),
      r(0.54, 0.22, 0.16, 0.16), r(0.74, 0.28, 0.15, 0.14),
      r(0.34, 0.46, 0.15, 0.16), r(0.55, 0.46, 0.13, 0.13),
      r(0.72, 0.50, 0.17, 0.16), r(0.10, 0.50, 0.16, 0.16),
      r(0.12, 0.72, 0.18, 0.16), r(0.40, 0.70, 0.15, 0.15),
      r(0.62, 0.72, 0.16, 0.14),
    ];
    for (int i = 0; i < blocks.length; i++) {
      canvas.drawRRect(
        RRect.fromRectAndRadius(blocks[i], const Radius.circular(3)),
        i.isEven ? block : block2,
      );
    }

    // ── Roads ── light casing under white fill for a layered look.
    void road(List<Offset> pts, double width) {
      final path = Path()..moveTo(pts.first.dx, pts.first.dy);
      for (final o in pts.skip(1)) {
        path.lineTo(o.dx, o.dy);
      }
      canvas.drawPath(
          path,
          Paint()
            ..color = const Color(0xFFD7CFC0)
            ..style = PaintingStyle.stroke
            ..strokeWidth = width + 2
            ..strokeCap = StrokeCap.round
            ..strokeJoin = StrokeJoin.round);
      canvas.drawPath(
          path,
          Paint()
            ..color = Colors.white
            ..style = PaintingStyle.stroke
            ..strokeWidth = width
            ..strokeCap = StrokeCap.round
            ..strokeJoin = StrokeJoin.round);
    }

    // Primary roads (thicker).
    road([p(-0.05, 0.38), p(0.5, 0.42), p(1.05, 0.34)], 5);
    road([p(0.50, -0.05), p(0.46, 0.5), p(0.52, 1.05)], 5);
    // Secondary roads (thinner).
    road([p(-0.05, 0.66), p(1.05, 0.70)], 3);
    road([p(0.24, -0.05), p(0.26, 1.05)], 3);
    road([p(0.74, -0.05), p(0.72, 1.05)], 3);
    road([p(-0.05, 0.14), p(1.05, 0.12)], 2.5);

    // ── Highlighted route ── casing + blue line.
    final routePts = [
      p(0.22, 0.92),
      p(0.40, 0.62),
      p(0.58, 0.52),
      p(0.70, 0.30),
      p(0.80, 0.16),
    ];
    final routePath = Path()..moveTo(routePts.first.dx, routePts.first.dy);
    for (final o in routePts.skip(1)) {
      routePath.lineTo(o.dx, o.dy);
    }
    canvas.drawPath(
        routePath,
        Paint()
          ..color = Colors.white
          ..style = PaintingStyle.stroke
          ..strokeWidth = 6
          ..strokeCap = StrokeCap.round
          ..strokeJoin = StrokeJoin.round);
    canvas.drawPath(
        routePath,
        Paint()
          ..color = const Color(0xFF4A90E2)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 3.2
          ..strokeCap = StrokeCap.round
          ..strokeJoin = StrokeJoin.round);

    // ── Location pin (teardrop) at the route end ──
    final pin = p(0.80, 0.16);
    final pinPaint = Paint()..color = const Color(0xFFEF4444);
    final pinPath = Path()
      ..moveTo(pin.dx, pin.dy + 9)
      ..cubicTo(pin.dx - 7, pin.dy - 2, pin.dx - 6, pin.dy - 10, pin.dx,
          pin.dy - 10)
      ..cubicTo(pin.dx + 6, pin.dy - 10, pin.dx + 7, pin.dy - 2, pin.dx,
          pin.dy + 9)
      ..close();
    canvas.drawPath(pinPath, pinPaint);
    canvas.drawCircle(
        Offset(pin.dx, pin.dy - 3), 2.6, Paint()..color = Colors.white);
  }

  @override
  bool shouldRepaint(covariant _MiniMapPainter oldDelegate) => false;
}
