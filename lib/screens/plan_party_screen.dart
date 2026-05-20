import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/event_model.dart';
import '../core/responsive.dart';

class PlanPartyScreen extends StatefulWidget {
  final EventModel event;
  const PlanPartyScreen({super.key, required this.event});

  @override
  State<PlanPartyScreen> createState() => _PlanPartyScreenState();
}

class _PlanPartyScreenState extends State<PlanPartyScreen> {
  final _childNameController = TextEditingController();
  String? _selectedOccasion;
  String? _selectedDate;
  String? _selectedTime;
  String _selectedKidsRange = '40 - 50';

  static const _occasions = ['Birthday', 'Playdate', 'Celebration'];
  static const _times = ['Morning', 'Afternoon', 'Evening'];
  static const _kidsRanges = ['0 - 10', '10 - 20', '20 - 30', '30 - 40', '40 - 50', '50+'];

  List<Map<String, String>> get _dates {
    final days = ['Sun', 'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat'];
    final months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    final now = DateTime.now();
    return List.generate(6, (i) {
      final d = now.add(Duration(days: i + 1));
      return {
        'label': '${days[d.weekday % 7]} ${d.day} ${months[d.month - 1]}',
        'iso': d.toIso8601String(),
      };
    });
  }

  @override
  void dispose() {
    _childNameController.dispose();
    super.dispose();
  }

  void _onContinue() {
    if (_childNameController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter the child\'s name')),
      );
      return;
    }
    if (_selectedOccasion == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select an occasion')),
      );
      return;
    }
    if (_selectedDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a date')),
      );
      return;
    }
    if (_selectedTime == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a time slot')),
      );
      return;
    }
    // TODO: navigate to booking confirmation
  }

  @override
  Widget build(BuildContext context) {
    final dates = _dates;

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
            child: const Icon(Icons.arrow_back, color: Color(0xFF1A1A2E), size: 20),
          ),
        ),
        title: Text(
          "Plan Your kid's Party",
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
                                  (_) => const Icon(Icons.star_rounded, color: Colors.amber, size: 14),
                                ),
                                const Icon(Icons.star_half_rounded, color: Colors.amber, size: 14),
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
                      // Map thumbnail
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
                _sectionLabel(Icons.school_rounded, 'Child Name'),
                const SizedBox(height: 10),
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: TextField(
                    controller: _childNameController,
                    style: GoogleFonts.poppins(fontSize: Responsive.sp(context, 14), color: const Color(0xFF1A1A2E)),
                    decoration: InputDecoration(
                      hintText: 'Enter child\'s name',
                      hintStyle: GoogleFonts.poppins(fontSize: Responsive.sp(context, 14), color: Colors.grey.shade400),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                      border: InputBorder.none,
                    ),
                  ),
                ),

                const SizedBox(height: 20),

                // ── Occasion ───────────────────────────────────────────────
                _sectionLabel(Icons.celebration_rounded, 'Occasion'),
                const SizedBox(height: 12),
                Row(
                  children: _occasions.map((occasion) {
                    final isSelected = _selectedOccasion == occasion;
                    return Padding(
                      padding: const EdgeInsets.only(right: 24),
                      child: GestureDetector(
                        onTap: () => setState(() => _selectedOccasion = occasion),
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
                      ),
                    );
                  }).toList(),
                ),

                const SizedBox(height: 20),

                // ── Select Date ────────────────────────────────────────────
                Container(
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
                      GridView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: dates.length,
                        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 3,
                          crossAxisSpacing: 10,
                          mainAxisSpacing: 10,
                          childAspectRatio: 2.4,
                        ),
                        itemBuilder: (context, i) {
                          final date = dates[i];
                          final isSelected = _selectedDate == date['iso'];
                          return GestureDetector(
                            onTap: () => setState(() => _selectedDate = date['iso']),
                            child: Container(
                              alignment: Alignment.center,
                              decoration: BoxDecoration(
                                color: isSelected ? const Color(0xFFFFCC00) : Colors.white,
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(
                                  color: isSelected
                                      ? const Color(0xFFFFCC00)
                                      : const Color(0xFFE0E0E0),
                                ),
                              ),
                              child: Text(
                                date['label']!,
                                style: GoogleFonts.poppins(
                                  fontSize: Responsive.sp(context, 11.5),
                                  fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                                  color: const Color(0xFF1A1A2E),
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 16),

                // ── Select Time ────────────────────────────────────────────
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Select Time',
                        style: GoogleFonts.poppins(
                          fontSize: Responsive.sp(context, 14),
                          fontWeight: FontWeight.w700,
                          color: const Color(0xFF1A1A2E),
                        ),
                      ),
                      const SizedBox(height: 14),
                      Row(
                        children: _times.map((time) {
                          final isSelected = _selectedTime == time;
                          return Expanded(
                            child: Padding(
                              padding: EdgeInsets.only(right: time != _times.last ? 10 : 0),
                              child: GestureDetector(
                                onTap: () => setState(() => _selectedTime = time),
                                child: Container(
                                  height: 40,
                                  alignment: Alignment.center,
                                  decoration: BoxDecoration(
                                    color: isSelected ? const Color(0xFFFFCC00) : Colors.white,
                                    borderRadius: BorderRadius.circular(8),
                                    border: Border.all(
                                      color: isSelected
                                          ? const Color(0xFFFFCC00)
                                          : const Color(0xFFE0E0E0),
                                    ),
                                  ),
                                  child: Text(
                                    time,
                                    style: GoogleFonts.poppins(
                                      fontSize: Responsive.sp(context, 13),
                                      fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                                      color: const Color(0xFF1A1A2E),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 20),

                // ── Number of Kids ─────────────────────────────────────────
                _sectionLabel(Icons.groups_rounded, 'Number of Kids'),
                const SizedBox(height: 10),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      value: _selectedKidsRange,
                      isExpanded: true,
                      icon: const Icon(Icons.keyboard_arrow_down_rounded, color: Color(0xFF1A1A2E)),
                      dropdownColor: Colors.white,
                      style: GoogleFonts.poppins(fontSize: Responsive.sp(context, 14), color: const Color(0xFF1A1A2E)),
                      items: _kidsRanges
                          .map((r) => DropdownMenuItem(
                                value: r,
                                child: Text(r, style: GoogleFonts.poppins(fontSize: Responsive.sp(context, 14), color: const Color(0xFF1A1A2E))),
                              ))
                          .toList(),
                      onChanged: (v) {
                        if (v != null) setState(() => _selectedKidsRange = v);
                      },
                    ),
                  ),
                ),
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
                16, 12, 16, 16 + MediaQuery.of(context).padding.bottom,
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
