import 'package:flutter/material.dart';
import '../core/app_colors.dart';
import 'package:google_fonts/google_fonts.dart';
import '../core/app_snackbar.dart';
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
      AppSnackBar.show(context, "Please enter the planner's name");
      return;
    }
    if (_selectedOccasion == null) {
      AppSnackBar.show(context, 'Please select an occasion');
      return;
    }
    if (_selectedSlot == null) {
      final msg = _selectedDateStr == null
          ? 'Please select a date and time slot'
          : 'Please select a time slot';
      AppSnackBar.show(context, msg);
      return;
    }

    final attendeeText = _attendeeController.text.trim();
    final attendeeCount = int.tryParse(attendeeText);
    if (attendeeCount == null || attendeeCount <= 0) {
      AppSnackBar.show(context, 'Please enter a valid number of attendees');
      return;
    }
    final minCap = widget.venueDetail?.minCapacity;
    final maxCap = widget.venueDetail?.maxCapacity;
    if (minCap != null && attendeeCount < minCap) {
      AppSnackBar.show(context, 'Minimum $minCap attendees required for this venue');
      return;
    }
    if (maxCap != null && attendeeCount > maxCap) {
      AppSnackBar.show(context, 'This venue can accommodate up to $maxCap guests');
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

  // ── Design tokens ──────────────────────────────────────────────────────────
  static const Color _bg = Color(0xFFF2F3F5);
  static const Color _ink = AppColors.textPrimary;
  static const Color _hairline = Color(0xFFE7E7EC);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bg,
      appBar: AppBar(
        backgroundColor: _bg,
        surfaceTintColor: _bg,
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: Padding(
          padding: const EdgeInsets.only(left: 12),
          child: GestureDetector(
            onTap: () => Navigator.pop(context),
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.06),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: const Icon(Icons.arrow_back, color: _ink, size: 20),
            ),
          ),
        ),
        title: Text(
          'Plan Your Idea',
          style: GoogleFonts.poppins(
            fontSize: Responsive.sp(context, 17),
            fontWeight: FontWeight.w600,
            color: _ink,
          ),
        ),
        centerTitle: true,
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _venueCard(context),
                  const SizedBox(height: 14),
                  _plannerCard(context),
                  const SizedBox(height: 14),
                  _occasionCard(context),
                  const SizedBox(height: 14),
                  _dateCard(context),
                  if (_selectedDateStr != null &&
                      _slotsForSelectedDate.isNotEmpty) ...[
                    const SizedBox(height: 14),
                    _slotCard(context),
                  ],
                  const SizedBox(height: 14),
                  _attendeesCard(context),
                ],
              ),
            ),
          ),
          _continueBar(context),
        ],
      ),
    );
  }

  // ── Shared card shell ──────────────────────────────────────────────────────
  /// Every section uses this. The page previously mixed bare labels sitting on
  /// the grey background with self-contained white cards, so the sections read
  /// as two unrelated designs stacked together.
  Widget _card({
    required Widget child,
    EdgeInsets padding = const EdgeInsets.all(16),
  }) {
    return Container(
      width: double.infinity,
      padding: padding,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: _hairline, width: 0.8),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: child,
    );
  }

  Widget _cardTitle(BuildContext context, IconData icon, String label,
      {String? hint}) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 18, color: _ink),
        const SizedBox(width: 9),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: GoogleFonts.poppins(
                  fontSize: Responsive.sp(context, 14.5),
                  fontWeight: FontWeight.w600,
                  color: _ink,
                ),
              ),
              if (hint != null) ...[
                const SizedBox(height: 2),
                Text(
                  hint,
                  style: GoogleFonts.poppins(
                    fontSize: Responsive.sp(context, 11.5),
                    color: Colors.grey.shade600,
                  ),
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }

  /// Shared field chrome, so the two text inputs match.
  InputDecoration _fieldDecoration(BuildContext context, String hint,
      {IconData? icon}) {
    return InputDecoration(
      hintText: hint,
      hintStyle: GoogleFonts.poppins(
        fontSize: Responsive.sp(context, 13.5),
        color: Colors.grey.shade400,
      ),
      prefixIcon: icon == null
          ? null
          : Icon(icon, color: Colors.grey.shade500, size: 20),
      filled: true,
      fillColor: const Color(0xFFF6F6F8),
      contentPadding:
          const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none,
      ),
    );
  }

  // ── Venue header ───────────────────────────────────────────────────────────
  /// The venue's own photo, replacing a hand-drawn decorative mini-map that
  /// showed no real location and told the customer nothing.
  Widget _venueCard(BuildContext context) {
    final image = widget.event.imagePath;
    final isNetwork = image.startsWith('http');

    Widget fallback() => Container(
          color: const Color(0xFFF1F1F4),
          child: Icon(Icons.storefront_outlined,
              size: 26, color: Colors.grey.shade400),
        );

    return _card(
      padding: const EdgeInsets.all(12),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: SizedBox(
              width: 68,
              height: 68,
              child: image.isEmpty
                  ? fallback()
                  : isNetwork
                      ? Image.network(image,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => fallback())
                      : Image.asset(image,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => fallback()),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  widget.event.title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.poppins(
                    fontSize: Responsive.sp(context, 15),
                    fontWeight: FontWeight.w600,
                    color: _ink,
                  ),
                ),
                const SizedBox(height: 3),
                Row(
                  children: [
                    Icon(Icons.location_on_outlined,
                        size: 13, color: Colors.grey.shade500),
                    const SizedBox(width: 3),
                    Expanded(
                      child: Text(
                        widget.event.venue,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: GoogleFonts.poppins(
                          fontSize: Responsive.sp(context, 12),
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Row(
                  children: [
                    const Icon(Icons.star_rounded,
                        color: Color(0xFFFFB902), size: 15),
                    const SizedBox(width: 3),
                    Text(
                      (widget.event.rating ?? 4.5).toStringAsFixed(1),
                      style: GoogleFonts.poppins(
                        fontSize: Responsive.sp(context, 12),
                        fontWeight: FontWeight.w600,
                        color: _ink,
                      ),
                    ),
                    const SizedBox(width: 5),
                    Expanded(
                      child: Text(
                        widget.event.reviewCount ?? '(124 reviews)',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: GoogleFonts.poppins(
                          fontSize: Responsive.sp(context, 11.5),
                          color: Colors.grey.shade500,
                        ),
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

  // ── Planner's name ─────────────────────────────────────────────────────────
  Widget _plannerCard(BuildContext context) {
    return _card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _cardTitle(context, Icons.person_outline, "Planner's Name"),
          const SizedBox(height: 12),
          TextField(
            controller: _childNameController,
            textCapitalization: TextCapitalization.words,
            style: GoogleFonts.poppins(
              fontSize: Responsive.sp(context, 14),
              color: _ink,
            ),
            decoration: _fieldDecoration(context, "Who's planning this?"),
          ),
        ],
      ),
    );
  }

  // ── Occasion ───────────────────────────────────────────────────────────────
  /// Full-width selectable rows rather than bare radio buttons floating on the
  /// page background — the whole row is the tap target, not just the dot.
  Widget _occasionCard(BuildContext context) {
    return _card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _cardTitle(context, Icons.celebration_outlined, 'Occasion'),
          const SizedBox(height: 12),
          for (int i = 0; i < _occasions.length; i++) ...[
            if (i > 0) const SizedBox(height: 8),
            _occasionRow(context, _occasions[i]),
          ],
        ],
      ),
    );
  }

  Widget _occasionRow(BuildContext context, String occasion) {
    final selected = _selectedOccasion == occasion;
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () => setState(() => _selectedOccasion = occasion),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
        decoration: BoxDecoration(
          color: selected ? const Color(0xFFF3F3F7) : const Color(0xFFFAFAFC),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: selected ? _ink : _hairline,
            width: selected ? 1.4 : 0.8,
          ),
        ),
        child: Row(
          children: [
            Icon(
              selected
                  ? Icons.radio_button_checked
                  : Icons.radio_button_unchecked,
              size: 20,
              color: selected ? _ink : Colors.grey.shade400,
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                occasion,
                style: GoogleFonts.poppins(
                  fontSize: Responsive.sp(context, 13.5),
                  fontWeight: selected ? FontWeight.w600 : FontWeight.w500,
                  color: _ink,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── Date ───────────────────────────────────────────────────────────────────
  Widget _dateCard(BuildContext context) {
    return _card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _cardTitle(context, Icons.calendar_today_outlined, 'Select Date'),
          const SizedBox(height: 14),
          if (!_hasApiAvailability)
            _emptyState(
              context,
              Icons.event_busy_outlined,
              'No availability slots found for this venue',
            )
          else
            Wrap(
              spacing: 10,
              runSpacing: 10,
              children: _availableDates
                  .map((d) => _choiceChip(
                        context,
                        label: _formatDateChip(d),
                        selected: _selectedDateStr == d,
                        onTap: () => _selectDate(d),
                      ))
                  .toList(),
            ),
        ],
      ),
    );
  }

  // ── Time slot ──────────────────────────────────────────────────────────────
  Widget _slotCard(BuildContext context) {
    final note = _slotsForSelectedDate
        .where((s) => s.note?.isNotEmpty == true)
        .map((s) => s.note!)
        .firstOrNull;

    return _card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _cardTitle(context, Icons.schedule_outlined, 'Select Time Slot'),
          const SizedBox(height: 14),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: _slotsForSelectedDate
                .map((slot) => _choiceChip(
                      context,
                      label: _formatTimeSlot(slot),
                      selected: _selectedSlot?.id == slot.id,
                      onTap: () => setState(() => _selectedSlot = slot),
                    ))
                .toList(),
          ),
          if (note != null) ...[
            const SizedBox(height: 12),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(Icons.info_outline, size: 14, color: Colors.grey.shade500),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    note,
                    style: GoogleFonts.poppins(
                      fontSize: Responsive.sp(context, 11.5),
                      color: Colors.grey.shade600,
                      height: 1.4,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  // ── Attendees ──────────────────────────────────────────────────────────────
  Widget _attendeesCard(BuildContext context) {
    final hasCapacity = widget.venueDetail?.maxCapacity != null;
    return _card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _cardTitle(
            context,
            Icons.groups_outlined,
            'Number of Attendees',
            // The capacity line used to sit outside the field, where the
            // sticky button clipped it.
            hint: hasCapacity ? _capacitySubtext : null,
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _attendeeController,
            keyboardType: TextInputType.number,
            style: GoogleFonts.poppins(
              fontSize: Responsive.sp(context, 14),
              color: _ink,
            ),
            decoration: _fieldDecoration(
              context,
              _capacityHint,
              icon: Icons.people_outline,
            ),
          ),
        ],
      ),
    );
  }

  // ── Small parts ────────────────────────────────────────────────────────────
  /// Selected state is a solid ink fill, matching the date/time selection
  /// screen. The gold it replaced is the Continue button's colour, and using
  /// it for both blurred which one was the action.
  Widget _choiceChip(
    BuildContext context, {
    required String label,
    required bool selected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 11),
        decoration: BoxDecoration(
          color: selected ? _ink : Colors.white,
          borderRadius: BorderRadius.circular(11),
          border: Border.all(color: selected ? _ink : _hairline),
          boxShadow: selected
              ? [
                  BoxShadow(
                    color: _ink.withOpacity(0.18),
                    blurRadius: 10,
                    offset: const Offset(0, 3),
                  ),
                ]
              : null,
        ),
        child: Text(
          label,
          style: GoogleFonts.poppins(
            fontSize: Responsive.sp(context, 12.5),
            fontWeight: FontWeight.w500,
            color: selected ? Colors.white : _ink,
          ),
        ),
      ),
    );
  }

  Widget _emptyState(BuildContext context, IconData icon, String message) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 14),
        child: Column(
          children: [
            Icon(icon, size: 34, color: Colors.grey.shade300),
            const SizedBox(height: 8),
            Text(
              message,
              textAlign: TextAlign.center,
              style: GoogleFonts.poppins(
                fontSize: Responsive.sp(context, 12.5),
                color: Colors.grey.shade500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Sits in the layout rather than floating over it — the old Positioned bar
  /// let content scroll underneath and clipped the capacity line. The hairline
  /// gives the scrolling content a clear edge to end against.
  Widget _continueBar(BuildContext context) {
    return Container(
      padding: EdgeInsets.fromLTRB(
        16,
        12,
        16,
        12 + MediaQuery.of(context).padding.bottom,
      ),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: _hairline)),
      ),
      child: SizedBox(
        width: double.infinity,
        height: 54,
        child: ElevatedButton(
          onPressed: _onContinue,
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primaryLight,
            foregroundColor: _ink,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(30),
            ),
            elevation: 0,
          ),
          child: Text(
            'Continue',
            style: GoogleFonts.poppins(
              fontSize: Responsive.sp(context, 16),
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ),
    );
  }
}
