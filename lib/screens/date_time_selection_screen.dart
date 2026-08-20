import 'package:flutter/material.dart';
import '../core/app_colors.dart';
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

  /// Every day the event runs, in device-local time. An event with a
  /// start and end a month apart yields a month of days, not one.
  late List<DateTime> _days;

  /// Local start/end of the event window. Null when the caller gave us no
  /// real dates and we're showing placeholder options.
  DateTime? _start;
  DateTime? _end;

  /// Placeholder times, used only when there is no real event window.
  List<String>? _fallbackTimes;

  static const Color _bg = Color(0xFFF2F3F5);
  static const Color _dark = AppColors.textPrimary;

  static const _months = [
    'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
    'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
  ];
  static const _weekdays = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];

  static String _fmtDate(DateTime dt) =>
      '${_weekdays[dt.weekday - 1]} ${dt.day} ${_months[dt.month - 1]}';

  static String _fmtTime(DateTime dt) {
    final h = dt.hour > 12 ? dt.hour - 12 : (dt.hour == 0 ? 12 : dt.hour);
    final m = dt.minute.toString().padLeft(2, '0');
    final ampm = dt.hour >= 12 ? 'PM' : 'AM';
    return '$h:$m $ampm';
  }

  static DateTime _dateOnly(DateTime d) => DateTime(d.year, d.month, d.day);

  @override
  void initState() {
    super.initState();
    final startUtc = widget.eventDateTime;

    if (startUtc != null) {
      // Convert UTC → device local time (handles IST and any other timezone).
      _start = startUtc.toLocal();
      _end = widget.eventEndDateTime?.toLocal();

      final firstDay = _dateOnly(_start!);
      final lastDay = _dateOnly(_end ?? _start!);

      // Don't offer days that have already passed on a run that's under way.
      final today = _dateOnly(DateTime.now());
      final from = firstDay.isBefore(today) ? today : firstDay;

      if (lastDay.isBefore(from)) {
        // Wholly in the past — keep the event's own day rather than an
        // empty strip, so the screen still says what it was.
        _days = [firstDay];
      } else {
        _days = List.generate(
          lastDay.difference(from).inDays + 1,
          (i) => from.add(Duration(days: i)),
        );
      }
    } else {
      final today = _dateOnly(DateTime.now());
      _days = List.generate(6, (i) => today.add(Duration(days: i)));
      final baseTime = widget.event.eventTime ?? '11:00 AM';
      _fallbackTimes = [
        baseTime, '12:00 PM', '01:00 PM', '02:00 PM', '03:00 PM', '04:00 PM',
      ];
    }

    _selectedDateIndex = 0;
    _selectedTimeIndex = 0;
  }

  bool get _isMultiDay => _days.length > 1;

  /// What can be booked on the selected day.
  ///
  /// The API gives a single window (`start_datetime` → `end_datetime`) and no
  /// per-day sessions, so a multi-day event is described honestly rather than
  /// inventing daily hours: the first day opens at the start time, the last
  /// closes at the end time, and the days between run right through.
  List<String> get _timeOptions {
    if (_fallbackTimes != null) return _fallbackTimes!;
    final start = _start;
    if (start == null) return const [];

    final end = _end;
    if (end == null) return [_fmtTime(start)];

    if (!_isMultiDay) return ['${_fmtTime(start)} – ${_fmtTime(end)}'];

    final day = _days[_selectedDateIndex ?? 0];
    if (day == _dateOnly(start)) return ['From ${_fmtTime(start)}'];
    if (day == _dateOnly(end)) return ['Until ${_fmtTime(end)}'];
    return const ['Open all day'];
  }

  void _selectDate(int i) {
    setState(() {
      _selectedDateIndex = i;
      // The options differ per day on a multi-day run, so a held-over index
      // could point at a slot that no longer exists.
      _selectedTimeIndex = 0;
    });
  }

  bool get _canContinue =>
      _selectedDateIndex != null &&
      _selectedTimeIndex != null &&
      _timeOptions.isNotEmpty;

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
                  _buildDateCard(context),
                  const SizedBox(height: 18),
                  _buildTimeCard(context),
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
                            selectedDate: _fmtDate(_days[_selectedDateIndex!]),
                            selectedTime: _timeOptions[_selectedTimeIndex!],
                            apiTickets: widget.apiTickets,
                          ),
                        ),
                      );
                    }
                  : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryLight,
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

  // ── Address (dark) + rating ──
  Widget _buildHeader(BuildContext context, EventModel event) {
    return SizedBox(
      width: double.infinity,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            // Full width now: the address used to be held to 240pt to keep it
            // clear of a decorative map that sat in the top-right corner.
            Text(
              event.venue,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: GoogleFonts.poppins(
                fontSize: Responsive.sp(context, 13.5),
                fontWeight: FontWeight.w500,
                color: _dark, // dark coloured address
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
    );
  }

  // ── Date strip ─────────────────────────────────────────────────────────────
  Widget _buildDateCard(BuildContext context) {
    return _sectionCard(
      context,
      title: 'Select Date',
      // Trailing count only earns its place on a run long enough that the
      // strip scrolls.
      trailing: _days.length > 3 ? '${_days.length} days' : null,
      // Full-bleed so the strip can scroll past the card's padding rather
      // than stopping short of the edge.
      childPadding: EdgeInsets.zero,
      child: SizedBox(
        height: 84,
        child: ListView.separated(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.fromLTRB(18, 0, 18, 4),
          itemCount: _days.length,
          separatorBuilder: (_, __) => const SizedBox(width: 10),
          itemBuilder: (context, i) => _DateChip(
            day: _days[i],
            selected: _selectedDateIndex == i,
            onTap: () => _selectDate(i),
          ),
        ),
      ),
    );
  }

  // ── Time options ───────────────────────────────────────────────────────────
  Widget _buildTimeCard(BuildContext context) {
    final options = _timeOptions;
    return _sectionCard(
      context,
      title: 'Select Time',
      child: options.isEmpty
          ? Text(
              'Timing will be confirmed by the organiser.',
              style: GoogleFonts.poppins(
                fontSize: Responsive.sp(context, 12.5),
                color: Colors.grey.shade600,
              ),
            )
          : Wrap(
              spacing: 10,
              runSpacing: 10,
              children: [
                for (int i = 0; i < options.length; i++)
                  _TimeChip(
                    label: options[i],
                    selected: _selectedTimeIndex == i,
                    onTap: () => setState(() => _selectedTimeIndex = i),
                  ),
              ],
            ),
    );
  }

  Widget _sectionCard(
    BuildContext context, {
    required String title,
    required Widget child,
    String? trailing,
    EdgeInsets childPadding = const EdgeInsets.fromLTRB(18, 0, 18, 18),
  }) {
    return Container(
      width: double.infinity,
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
          Padding(
            padding: const EdgeInsets.fromLTRB(18, 18, 18, 14),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    title,
                    style: GoogleFonts.poppins(
                      fontSize: Responsive.sp(context, 16),
                      fontWeight: FontWeight.w700,
                      color: _dark,
                    ),
                  ),
                ),
                if (trailing != null)
                  Text(
                    trailing,
                    style: GoogleFonts.poppins(
                      fontSize: Responsive.sp(context, 11.5),
                      fontWeight: FontWeight.w500,
                      color: Colors.grey.shade500,
                    ),
                  ),
              ],
            ),
          ),
          Padding(padding: childPadding, child: child),
        ],
      ),
    );
  }
}

/// One day in the horizontal date strip — weekday, day number, month.
///
/// Selected state is a solid ink fill rather than the previous gold gradient:
/// repeated across a scrolling strip that gradient fought the page, and the
/// amber is already spoken for by the Continue button.
class _DateChip extends StatelessWidget {
  final DateTime day;
  final bool selected;
  final VoidCallback onTap;

  const _DateChip({
    required this.day,
    required this.selected,
    required this.onTap,
  });

  static const Color _ink = AppColors.textPrimary;

  @override
  Widget build(BuildContext context) {
    final today = _DateTimeSelectionScreenState._dateOnly(DateTime.now());
    final isToday = day == today;

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 160),
        curve: Curves.easeOut,
        width: 62,
        decoration: BoxDecoration(
          color: selected ? _ink : Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: selected ? _ink : const Color(0xFFE7E7EC),
            width: 1,
          ),
          boxShadow: selected
              ? [
                  BoxShadow(
                    color: _ink.withOpacity(0.22),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ]
              : null,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              isToday
                  ? 'Today'
                  : _DateTimeSelectionScreenState._weekdays[day.weekday - 1],
              style: GoogleFonts.poppins(
                fontSize: Responsive.sp(context, 10.5),
                fontWeight: FontWeight.w500,
                color: selected ? Colors.white70 : Colors.grey.shade500,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              '${day.day}',
              style: GoogleFonts.poppins(
                fontSize: Responsive.sp(context, 19),
                fontWeight: FontWeight.w700,
                height: 1.2,
                color: selected ? Colors.white : _ink,
              ),
            ),
            const SizedBox(height: 1),
            Text(
              _DateTimeSelectionScreenState._months[day.month - 1],
              style: GoogleFonts.poppins(
                fontSize: Responsive.sp(context, 10.5),
                fontWeight: FontWeight.w500,
                color: selected ? Colors.white70 : Colors.grey.shade500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// A bookable time on the chosen day.
class _TimeChip extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _TimeChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  static const Color _ink = AppColors.textPrimary;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 160),
        curve: Curves.easeOut,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: selected ? _ink : Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: selected ? _ink : const Color(0xFFE7E7EC),
            width: 1,
          ),
          boxShadow: selected
              ? [
                  BoxShadow(
                    color: _ink.withOpacity(0.20),
                    blurRadius: 10,
                    offset: const Offset(0, 3),
                  ),
                ]
              : null,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.schedule,
              size: 15,
              color: selected ? Colors.white70 : Colors.grey.shade500,
            ),
            const SizedBox(width: 7),
            Text(
              label,
              style: GoogleFonts.poppins(
                fontSize: Responsive.sp(context, 13),
                fontWeight: FontWeight.w500,
                color: selected ? Colors.white : _ink,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
