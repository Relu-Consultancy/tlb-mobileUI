import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/api_venue_model.dart';
import '../models/event_model.dart';
import '../core/responsive.dart';
import 'venue_checkout_screen.dart';

class PlanPartyScreen extends StatefulWidget {
  final EventModel event;
  final ApiVenueDetail? venueDetail;

  const PlanPartyScreen({
    super.key,
    required this.event,
    this.venueDetail,
  });

  @override
  State<PlanPartyScreen> createState() => _PlanPartyScreenState();
}

class _PlanPartyScreenState extends State<PlanPartyScreen> {
  final _childNameController = TextEditingController();
  final _attendeeController = TextEditingController();
  String? _selectedOccasion;
  String? _selectedDateStr;
  ApiVenueAvailability? _selectedSlot;

  static const _fallbackOccasions = ['Birthday', 'Playdate', 'Celebration'];

  List<String> get _occasions {
    final apiOccasions = widget.venueDetail?.occasions ?? [];
    if (apiOccasions.isNotEmpty) {
      return apiOccasions.map((o) => o.name).toList();
    }
    return _fallbackOccasions;
  }

  // Unique sorted available dates from API
  List<String> get _availableDates {
    final slots = widget.venueDetail?.availability ?? [];
    final dates = slots.map((s) => s.date).toSet().toList();
    dates.sort();
    return dates;
  }

  // All slots for the currently selected date
  List<ApiVenueAvailability> get _slotsForSelectedDate {
    if (_selectedDateStr == null) return [];
    return (widget.venueDetail?.availability ?? [])
        .where((s) => s.date == _selectedDateStr)
        .toList();
  }

  bool get _hasApiAvailability =>
      (widget.venueDetail?.availability ?? []).isNotEmpty;

  String get _capacityHint {
    final min = widget.venueDetail?.minCapacity;
    final max = widget.venueDetail?.maxCapacity;
    if (min != null && max != null) return 'Enter between $min – $max';
    if (max != null) return 'Enter up to $max';
    return 'Enter number of attendees';
  }

  String get _capacitySubtext {
    final min = widget.venueDetail?.minCapacity;
    final max = widget.venueDetail?.maxCapacity;
    if (min != null && max != null) return 'Capacity: $min – $max guests';
    if (max != null) return 'Max capacity: $max guests';
    return '';
  }

  @override
  void dispose() {
    _childNameController.dispose();
    _attendeeController.dispose();
    super.dispose();
  }

  void _selectDate(String dateStr) {
    final slots = (widget.venueDetail?.availability ?? [])
        .where((s) => s.date == dateStr)
        .toList();
    setState(() {
      _selectedDateStr = dateStr;
      // Auto-select when only one time slot exists for this date
      _selectedSlot = slots.length == 1 ? slots.first : null;
    });
  }

  void _onContinue() {
    if (_childNameController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please enter the planner's name")),
      );
      return;
    }
    if (_selectedOccasion == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select an occasion')),
      );
      return;
    }
    if (_selectedSlot == null) {
      final msg = _selectedDateStr == null
          ? 'Please select a date and time slot'
          : 'Please select a time slot';
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(msg)),
      );
      return;
    }

    final attendeeText = _attendeeController.text.trim();
    final attendeeCount = int.tryParse(attendeeText);
    if (attendeeCount == null || attendeeCount <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a valid number of attendees')),
      );
      return;
    }
    final minCap = widget.venueDetail?.minCapacity;
    final maxCap = widget.venueDetail?.maxCapacity;
    if (minCap != null && attendeeCount < minCap) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Minimum $minCap attendees required for this venue')),
      );
      return;
    }
    if (maxCap != null && attendeeCount > maxCap) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('This venue can accommodate up to $maxCap guests')),
      );
      return;
    }

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => VenueCheckoutScreen(
          event: widget.event,
          venueDetail: widget.venueDetail,
          childName: _childNameController.text.trim(),
          occasion: _selectedOccasion!,
          selectedSlot: _selectedSlot,
          attendeeCount: attendeeCount,
        ),
      ),
    );
  }

  // "2026-05-25" → "Sun 25 May"
  String _formatDateChip(String dateStr) {
    try {
      final dt = DateTime.parse(dateStr);
      const days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
      const months = [
        'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
        'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
      ];
      return '${days[dt.weekday - 1]} ${dt.day} ${months[dt.month - 1]}';
    } catch (_) {
      return dateStr;
    }
  }

  String _formatTimeSlot(ApiVenueAvailability slot) {
    return '${_fmtTime(slot.startTime)} – ${_fmtTime(slot.endTime)}';
  }

  // "06:00:00" → "6:00 AM"
  String _fmtTime(String t) {
    try {
      final parts = t.split(':');
      final h = int.parse(parts[0]);
      final m = int.parse(parts[1]);
      final period = h >= 12 ? 'PM' : 'AM';
      final hour = h > 12 ? h - 12 : (h == 0 ? 12 : h);
      return '$hour:${m.toString().padLeft(2, '0')} $period';
    } catch (_) {
      return t;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF2F3F5),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: GestureDetector(
          onTap: () => Navigator.pop(context),
          child: Container(
            margin: const EdgeInsets.all(10),
            decoration: const BoxDecoration(
              color: Color(0xFFF5F5F5),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.arrow_back,
              color: Color(0xFF1A1A2E),
              size: 20,
            ),
          ),
        ),
        title: Text(
          "Plan Your Idea",
          style: GoogleFonts.poppins(
            fontSize: Responsive.sp(context, 16),
            fontWeight: FontWeight.w700,
            color: const Color(0xFF1A1A2E),
          ),
        ),
        centerTitle: true,
      ),
      body: Stack(
        children: [
          SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ── Venue info card ────────────────────────────────────────
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  padding: const EdgeInsets.all(12),
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              widget.event.title,
                              style: GoogleFonts.poppins(
                                fontSize: Responsive.sp(context, 13),
                                fontWeight: FontWeight.w700,
                                color: const Color(0xFF1A1A2E),
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              widget.event.venue,
                              style: GoogleFonts.poppins(
                                fontSize: Responsive.sp(context, 11),
                                color: Colors.grey.shade500,
                              ),
                            ),
                            const SizedBox(height: 6),
                            Row(
                              children: [
                                ...List.generate(
                                  4,
                                  (_) => const Icon(
                                    Icons.star_rounded,
                                    color: Colors.amber,
                                    size: 14,
                                  ),
                                ),
                                const Icon(
                                  Icons.star_half_rounded,
                                  color: Colors.amber,
                                  size: 14,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  widget.event.reviewCount ?? '(124 reviews)',
                                  style: GoogleFonts.poppins(
                                    fontSize: Responsive.sp(context, 11),
                                    color: Colors.grey.shade500,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 12),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: SizedBox(
                          width: 64,
                          height: 64,
                          child: CustomPaint(painter: _MiniMapPainter()),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 20),

                // ── Child Name ─────────────────────────────────────────────
                _sectionLabel(Icons.school_rounded, "Planner's Name"),
                const SizedBox(height: 10),
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: TextField(
                    controller: _childNameController,
                    style: GoogleFonts.poppins(
                      fontSize: Responsive.sp(context, 14),
                      color: const Color(0xFF1A1A2E),
                    ),
                    decoration: InputDecoration(
                      hintText: "Enter planner's name",
                      hintStyle: GoogleFonts.poppins(
                        fontSize: Responsive.sp(context, 14),
                        color: Colors.grey.shade400,
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 14,
                      ),
                      border: InputBorder.none,
                    ),
                  ),
                ),

                const SizedBox(height: 20),

                // ── Occasion ───────────────────────────────────────────────
                _sectionLabel(Icons.celebration_rounded, 'Occasion'),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 20,
                  runSpacing: 12,
                  children: _occasions.map((occasion) {
                    final isSelected = _selectedOccasion == occasion;
                    return GestureDetector(
                      onTap: () =>
                          setState(() => _selectedOccasion = occasion),
                      child: Row(
                          children: [
                            Container(
                              width: 20,
                              height: 20,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: isSelected
                                      ? const Color(0xFF1A1A2E)
                                      : Colors.grey.shade400,
                                  width: 2,
                                ),
                              ),
                              child: isSelected
                                  ? Center(
                                      child: Container(
                                        width: 9,
                                        height: 9,
                                        decoration: const BoxDecoration(
                                          shape: BoxShape.circle,
                                          color: Color(0xFF1A1A2E),
                                        ),
                                      ),
                                    )
                                  : null,
                            ),
                            const SizedBox(width: 6),
                            Text(
                              occasion,
                              style: GoogleFonts.poppins(
                                fontSize: Responsive.sp(context, 13),
                                fontWeight: FontWeight.w500,
                                color: const Color(0xFF1A1A2E),
                              ),
                            ),
                          ],
                        ),
                      );
                  }).toList(),
                ),

                const SizedBox(height: 20),

                // ── Select Date ────────────────────────────────────────────
                Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Select Date',
                        style: GoogleFonts.poppins(
                          fontSize: Responsive.sp(context, 14),
                          fontWeight: FontWeight.w700,
                          color: const Color(0xFF1A1A2E),
                        ),
                      ),
                      const SizedBox(height: 14),
                      if (!_hasApiAvailability)
                        Center(
                          child: Padding(
                            padding:
                                const EdgeInsets.symmetric(vertical: 12),
                            child: Column(
                              children: [
                                Icon(
                                  Icons.event_busy_outlined,
                                  size: 36,
                                  color: Colors.grey.shade300,
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  'No availability slots found for this venue',
                                  style: GoogleFonts.poppins(
                                    fontSize: Responsive.sp(context, 12.5),
                                    color: Colors.grey.shade400,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              ],
                            ),
                          ),
                        )
                      else
                        Wrap(
                          spacing: 10,
                          runSpacing: 10,
                          children: _availableDates.map((dateStr) {
                            final isSelected =
                                _selectedDateStr == dateStr;
                            return GestureDetector(
                              onTap: () => _selectDate(dateStr),
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 14,
                                  vertical: 10,
                                ),
                                decoration: BoxDecoration(
                                  color: isSelected
                                      ? const Color(0xFFFFCC00)
                                      : Colors.white,
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(
                                    color: isSelected
                                        ? const Color(0xFFFFCC00)
                                        : const Color(0xFFE0E0E0),
                                  ),
                                ),
                                child: Text(
                                  _formatDateChip(dateStr),
                                  style: GoogleFonts.poppins(
                                    fontSize: Responsive.sp(context, 12),
                                    fontWeight: isSelected
                                        ? FontWeight.w700
                                        : FontWeight.w500,
                                    color: const Color(0xFF1A1A2E),
                                  ),
                                ),
                              ),
                            );
                          }).toList(),
                        ),
                    ],
                  ),
                ),

                // ── Select Time Slot ───────────────────────────────────────
                if (_selectedDateStr != null &&
                    _slotsForSelectedDate.isNotEmpty) ...[
                  const SizedBox(height: 16),
                  Container(
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Select Time Slot',
                          style: GoogleFonts.poppins(
                            fontSize: Responsive.sp(context, 14),
                            fontWeight: FontWeight.w700,
                            color: const Color(0xFF1A1A2E),
                          ),
                        ),
                        const SizedBox(height: 14),
                        Wrap(
                          spacing: 10,
                          runSpacing: 10,
                          children: _slotsForSelectedDate.map((slot) {
                            final isSelected =
                                _selectedSlot?.id == slot.id;
                            return GestureDetector(
                              onTap: () =>
                                  setState(() => _selectedSlot = slot),
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 14,
                                  vertical: 10,
                                ),
                                decoration: BoxDecoration(
                                  color: isSelected
                                      ? const Color(0xFFFFCC00)
                                      : Colors.white,
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(
                                    color: isSelected
                                        ? const Color(0xFFFFCC00)
                                        : const Color(0xFFE0E0E0),
                                  ),
                                ),
                                child: Text(
                                  _formatTimeSlot(slot),
                                  style: GoogleFonts.poppins(
                                    fontSize: Responsive.sp(context, 13),
                                    fontWeight: isSelected
                                        ? FontWeight.w700
                                        : FontWeight.w500,
                                    color: const Color(0xFF1A1A2E),
                                  ),
                                ),
                              ),
                            );
                          }).toList(),
                        ),
                        if (_slotsForSelectedDate.any(
                            (s) => s.note?.isNotEmpty == true))
                          Padding(
                            padding: const EdgeInsets.only(top: 10),
                            child: Text(
                              _slotsForSelectedDate
                                      .firstWhere(
                                          (s) => s.note?.isNotEmpty == true)
                                      .note ??
                                  '',
                              style: GoogleFonts.poppins(
                                fontSize: Responsive.sp(context, 11),
                                color: Colors.grey.shade500,
                                fontStyle: FontStyle.italic,
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                ],

                const SizedBox(height: 20),

                // ── Number of Attendees ────────────────────────────────────
                _sectionLabel(Icons.groups_rounded, 'Number of Attendees'),
                const SizedBox(height: 10),
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: TextField(
                    controller: _attendeeController,
                    keyboardType: TextInputType.number,
                    style: GoogleFonts.poppins(
                      fontSize: Responsive.sp(context, 14),
                      color: const Color(0xFF1A1A2E),
                    ),
                    decoration: InputDecoration(
                      hintText: _capacityHint,
                      hintStyle: GoogleFonts.poppins(
                        fontSize: Responsive.sp(context, 14),
                        color: Colors.grey.shade400,
                      ),
                      prefixIcon: const Icon(
                        Icons.people_outline,
                        color: Color(0xFF1A1A2E),
                        size: 20,
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 14,
                      ),
                      border: InputBorder.none,
                    ),
                  ),
                ),
                if (widget.venueDetail?.maxCapacity != null) ...[
                  const SizedBox(height: 6),
                  Padding(
                    padding: const EdgeInsets.only(left: 4),
                    child: Text(
                      _capacitySubtext,
                      style: GoogleFonts.poppins(
                        fontSize: Responsive.sp(context, 11),
                        color: Colors.grey.shade500,
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),

          // ── Sticky Continue button ─────────────────────────────────────
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: Container(
              padding: EdgeInsets.fromLTRB(
                16,
                12,
                16,
                16 + MediaQuery.of(context).padding.bottom,
              ),
              color: const Color(0xFFF2F3F5),
              child: SizedBox(
                width: double.infinity,
                height: 54,
                child: ElevatedButton(
                  onPressed: _onContinue,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFFFCC00),
                    foregroundColor: const Color(0xFF1A1A2E),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                    elevation: 0,
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
        ],
      ),
    );
  }

  Widget _sectionLabel(IconData icon, String label) {
    return Row(
      children: [
        Icon(icon, size: 18, color: const Color(0xFF1A1A2E)),
        const SizedBox(width: 8),
        Text(
          label,
          style: GoogleFonts.poppins(
            fontSize: Responsive.sp(context, 14),
            fontWeight: FontWeight.w700,
            color: const Color(0xFF1A1A2E),
          ),
        ),
      ],
    );
  }
}

// ── Mini map painter (unchanged) ─────────────────────────────────────────────

class _MiniMapPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final bg = Paint()..color = const Color(0xFFE8F0E8);
    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), bg);

    final road = Paint()
      ..color = const Color(0xFFC8D0C8)
      ..strokeWidth = 1.5
      ..style = PaintingStyle.stroke;

    for (double y = 0; y < size.height; y += 12) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), road);
    }
    for (double x = 0; x < size.width; x += 16) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), road);
    }

    final pin = Paint()..color = Colors.red.shade600;
    canvas.drawCircle(Offset(size.width / 2, size.height / 2), 5, pin);
    final stem = Paint()
      ..color = Colors.red.shade600
      ..strokeWidth = 2;
    canvas.drawLine(
      Offset(size.width / 2, size.height / 2 + 5),
      Offset(size.width / 2, size.height / 2 + 12),
      stem,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
