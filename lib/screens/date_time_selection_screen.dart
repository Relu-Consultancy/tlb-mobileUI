import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../core/responsive.dart';
import '../models/event_model.dart';
import 'ticket_booking_screen.dart';

class DateTimeSelectionScreen extends StatefulWidget {
  final EventModel event;

  const DateTimeSelectionScreen({super.key, required this.event});

  @override
  State<DateTimeSelectionScreen> createState() =>
      _DateTimeSelectionScreenState();
}

class _DateTimeSelectionScreenState extends State<DateTimeSelectionScreen> {
  int? _selectedDateIndex;
  int? _selectedTimeIndex;

  final List<String> _dates = [
    'Sun 21 Feb',
    'Mon 23 Feb',
    'Tue 24 Feb',
    'Thu 25 Feb',
    'Fri 28 Feb',
    'Sat 27 Feb',
  ];

  final List<String> _times = [
    '11:00 AM',
    '12:00 AM',
    '01:00 PM',
    '02:00 PM',
    '03:00 PM',
    '04:00 PM',
  ];

  bool get _canContinue =>
      _selectedDateIndex != null && _selectedTimeIndex != null;

  @override
  Widget build(BuildContext context) {
    final event = widget.event;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF1A1A2E)),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          event.title,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: GoogleFonts.poppins(
            fontSize: 16,
            fontWeight: FontWeight.w700,
            color: const Color(0xFF1A1A2E),
          ),
        ),
      ),
      body: Column(
        children: [
          // ── Venue & rating ──
          Container(
            width: double.infinity,
            color: Colors.white,
            child: Stack(
              children: [
                // Right side map image (blended)
                Positioned(
                  right: 0,
                  top: 0,
                  bottom: 0,
                  width: Responsive.w(context, 140, min: 100),
                  child: ShaderMask(
                    shaderCallback: (Rect bounds) {
                      return LinearGradient(
                        colors: [Colors.white, Colors.white.withOpacity(0.0)],
                        stops: const [0.0, 0.4],
                        begin: Alignment.centerLeft,
                        end: Alignment.centerRight,
                      ).createShader(bounds);
                    },
                    blendMode: BlendMode.dstOut,
                    child: Opacity(
                      opacity: 0.8,
                      child: Image.asset(
                        'assets/images/map_bg.png', // Assuming map image is available, fallback if not
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => Container(color: Colors.grey.shade100),
                      ),
                    ),
                  ),
                ),
                
                // Content
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 4, 16, 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        event.venue,
                        style: GoogleFonts.poppins(
                          fontSize: 13,
                          color: Colors.grey.shade600,
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
                              fontSize: 12,
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
          ),

          // ── Scrollable content ──
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
              child: Column(
                children: [
                  // ── Select Date ──
                  _buildSelectionCard(
                    title: 'Select Date',
                    items: _dates,
                    selectedIndex: _selectedDateIndex,
                    onSelect: (i) => setState(() => _selectedDateIndex = i),
                  ),

                  const SizedBox(height: 20),

                  // ── Select Time ──
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
            height: Responsive.h(context, 48, min: 40),
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
                          ),
                        ),
                      );
                    }
                  : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFFFCC00), // Golden yellow
                foregroundColor: const Color(0xFF1A1A2E), // Dark text
                disabledBackgroundColor: Colors.grey.shade300,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(28),
                  // Removed the outline border to match reference image
                ),
              ),
              child: Text(
                'Continue',
                style: GoogleFonts.poppins(
                  fontSize: Responsive.sp(context, 16),
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
        ),
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
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: GoogleFonts.poppins(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: const Color(0xFF1A1A2E),
            ),
          ),
          const SizedBox(height: 20),
          Column(
            children: [
              for (int row = 0; row < (items.length / 3).ceil(); row++) ...[
                if (row > 0) const SizedBox(height: 14),
                Row(
                  children: [
                    for (int col = 0; col < 3; col++) ...[
                      if (col > 0) const SizedBox(width: 8),
                      Expanded(
                        child: (row * 3 + col < items.length)
                            ? GestureDetector(
                                onTap: () => onSelect(row * 3 + col),
                                child: Container(
                                  alignment: Alignment.center,
                                  padding: const EdgeInsets.symmetric(vertical: 8),
                                  decoration: BoxDecoration(
                                    color: selectedIndex == (row * 3 + col)
                                        ? const Color(0xFFFFCC00)
                                        : Colors.white,
                                    borderRadius: BorderRadius.circular(10),
                                    border: selectedIndex == (row * 3 + col)
                                        ? null
                                        : Border.all(
                                            color: Colors.grey.shade300,
                                            width: 1.0,
                                          ),
                                    boxShadow: [
                                      if (selectedIndex == (row * 3 + col))
                                        BoxShadow(
                                          color: const Color(0xFFFFCC00).withOpacity(0.3),
                                          blurRadius: 8,
                                          offset: const Offset(0, 4),
                                        ),
                                    ],
                                  ),
                                  child: Text(
                                    items[row * 3 + col],
                                    style: GoogleFonts.poppins(
                                      fontSize: 11,
                                      fontWeight: selectedIndex == (row * 3 + col) ? FontWeight.w600 : FontWeight.w400,
                                      color: const Color(0xFF1A1A2E),
                                    ),
                                  ),
                                ),
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
}
