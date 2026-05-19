import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import '../core/app_colors.dart';
import '../core/responsive.dart';
import '../models/api_class_model.dart';
import '../models/event_model.dart';
import 'ticket_booking_screen.dart';

const List<Color> _kTagBg = [
  Color(0xFFCCFBF1), Color(0xFFEDE9FE), Color(0xFFDCFCE7),
  Color(0xFFFEF3C7), Color(0xFFFFE4E6),
];
const List<Color> _kTagFg = [
  Color(0xFF0F766E), Color(0xFF6D28D9), Color(0xFF15803D),
  Color(0xFFB45309), Color(0xFFBE123C),
];

const Map<String, int> _kDayNum = {
  'mon': 1, 'tue': 2, 'wed': 3, 'thu': 4, 'fri': 5, 'sat': 6, 'sun': 7,
};

String _fmt12h(String t) {
  final parts = t.split(':');
  if (parts.length < 2) return t;
  var h = int.tryParse(parts[0]) ?? 0;
  final m = parts[1];
  final ampm = h >= 12 ? 'PM' : 'AM';
  if (h > 12) h -= 12;
  if (h == 0) h = 12;
  return m == '00' ? '$h $ampm' : '$h:$m $ampm';
}

String _fmtDate(DateTime d) {
  const days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
  const months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
                  'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
  return '${days[d.weekday - 1]} ${d.day} ${months[d.month - 1]}';
}

List<String> _nextDates(ApiClassBatch batch, {int count = 5}) {
  final weekdays = batch.days
      .map((d) => _kDayNum[d.toLowerCase()] ?? 0)
      .where((n) => n > 0)
      .toSet();
  if (weekdays.isEmpty) return [];
  final result = <String>[];
  var cursor = DateTime.now();
  while (result.length < count) {
    cursor = cursor.add(const Duration(days: 1));
    if (weekdays.contains(cursor.weekday)) result.add(_fmtDate(cursor));
  }
  return result;
}

class SelectBatchScreen extends StatefulWidget {
  final EventModel event;
  final List<ApiClassBatch> batches;

  const SelectBatchScreen({
    super.key,
    required this.event,
    required this.batches,
  });

  @override
  State<SelectBatchScreen> createState() => _SelectBatchScreenState();
}

class _SelectBatchScreenState extends State<SelectBatchScreen> {
  int _batchIdx = 0;
  int _dateIdx = 0;
  List<String> _dates = const [];

  @override
  void initState() {
    super.initState();
    _refreshDates();
  }

  void _refreshDates() {
    _dates = widget.batches.isEmpty
        ? const []
        : _nextDates(widget.batches[_batchIdx]);
    _dateIdx = 0;
  }

  String get _startingFrom => _dates.isNotEmpty ? _dates[_dateIdx] : 'TBA';

  String _timeRange(ApiClassBatch b) =>
      '${_fmt12h(b.startTime)} – ${_fmt12h(b.endTime)}';

  String _dayLabel(ApiClassBatch b) => b.days
      .map((d) => d.length >= 3
          ? '${d[0].toUpperCase()}${d.substring(1, 3)}'
          : d.toUpperCase())
      .join(', ');

  @override
  Widget build(BuildContext context) {
    final top = MediaQuery.of(context).padding.top;
    final bottom = MediaQuery.of(context).padding.bottom;

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.dark,
      child: Scaffold(
        backgroundColor: Colors.white,
        body: Column(
          children: [
            _buildHeader(context, top),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildVenueCard(context),
                    const SizedBox(height: 22),
                    if (_dates.isNotEmpty) ...[
                      _buildDateSection(context),
                      const SizedBox(height: 24),
                    ],
                    _buildBatchSection(context),
                    const SizedBox(height: 8),
                    _buildStartingFromCard(context),
                  ],
                ),
              ),
            ),
            _buildContinueButton(context, bottom),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context, double safeTop) {
    return Container(
      color: Colors.white,
      padding: EdgeInsets.fromLTRB(16, safeTop + 12, 16, 14),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => Navigator.pop(context),
            child: Container(
              width: 36,
              height: 36,
              decoration: const BoxDecoration(
                color: Color(0xFFF2F4F7),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.arrow_back_ios_new_rounded,
                  size: 16, color: AppColors.textPrimary),
            ),
          ),
          const SizedBox(width: 14),
          Text(
            'Select batch',
            style: GoogleFonts.poppins(
              fontSize: Responsive.sp(context, 17),
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildVenueCard(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFEEEEEE)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.event.venue,
                  style: GoogleFonts.poppins(
                    fontSize: Responsive.sp(context, 13),
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 6),
                Row(
                  children: [
                    ...List.generate(5, (i) {
                      final r = widget.event.rating ?? 0.0;
                      return Icon(
                        i < r.floor()
                            ? Icons.star_rounded
                            : (i < r
                                ? Icons.star_half_rounded
                                : Icons.star_outline_rounded),
                        size: 15,
                        color: const Color(0xFFFFCC00),
                      );
                    }),
                    const SizedBox(width: 6),
                    if ((widget.event.reviewCount ?? '').isNotEmpty)
                      Text(
                        widget.event.reviewCount!,
                        style: GoogleFonts.poppins(
                          fontSize: Responsive.sp(context, 11),
                          color: AppColors.textSecondary,
                        ),
                      ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: Image.asset(
              'assets/images/new_home/map_thumb.png',
              width: 60,
              height: 52,
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => Container(
                width: 60,
                height: 52,
                decoration: BoxDecoration(
                  color: const Color(0xFFE8F4FD),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.map_outlined,
                    color: Color(0xFF0284C7), size: 26),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDateSection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Select Date',
          style: GoogleFonts.poppins(
            fontSize: Responsive.sp(context, 15),
            fontWeight: FontWeight.w700,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 10),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: List.generate(_dates.length, (i) {
              final sel = i == _dateIdx;
              return GestureDetector(
                onTap: () => setState(() => _dateIdx = i),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 180),
                  margin: const EdgeInsets.only(right: 10),
                  padding: const EdgeInsets.symmetric(
                      horizontal: 16, vertical: 9),
                  decoration: BoxDecoration(
                    color: sel
                        ? const Color(0xFFF0FDFB)
                        : const Color(0xFFF5F5F5),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: sel
                          ? const Color(0xFF0D9488)
                          : const Color(0xFFE5E5E5),
                      width: sel ? 1.5 : 1,
                    ),
                  ),
                  child: Text(
                    _dates[i],
                    style: GoogleFonts.poppins(
                      fontSize: Responsive.sp(context, 12),
                      fontWeight: sel ? FontWeight.w600 : FontWeight.w500,
                      color: sel
                          ? const Color(0xFF0D9488)
                          : AppColors.textSecondary,
                    ),
                  ),
                ),
              );
            }),
          ),
        ),
      ],
    );
  }

  Widget _buildBatchSection(BuildContext context) {
    final batches = widget.batches;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Available Batches',
          style: GoogleFonts.poppins(
            fontSize: Responsive.sp(context, 15),
            fontWeight: FontWeight.w700,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 12),
        if (batches.isEmpty)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 24),
            child: Center(
              child: Text(
                'No batches available at this time.',
                style: GoogleFonts.poppins(
                  fontSize: Responsive.sp(context, 13),
                  color: AppColors.textSecondary,
                ),
              ),
            ),
          )
        else
          ...List.generate(batches.length, (i) => _buildBatchCard(context, i)),
      ],
    );
  }

  Widget _buildBatchCard(BuildContext context, int i) {
    final batch = widget.batches[i];
    final sel = i == _batchIdx;
    final bg = _kTagBg[i % _kTagBg.length];
    final fg = _kTagFg[i % _kTagFg.length];

    return GestureDetector(
      onTap: () => setState(() {
        _batchIdx = i;
        _refreshDates();
      }),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.fromLTRB(16, 14, 14, 14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: sel ? const Color(0xFF06B6D4) : const Color(0xFFE5E7EB),
            width: sel ? 2 : 1,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _timeRange(batch),
                    style: GoogleFonts.poppins(
                      fontSize: Responsive.sp(context, 16),
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    _dayLabel(batch),
                    style: GoogleFonts.poppins(
                      fontSize: Responsive.sp(context, 12),
                      color: AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: bg,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      batch.name,
                      style: GoogleFonts.poppins(
                        fontSize: Responsive.sp(context, 11),
                        fontWeight: FontWeight.w600,
                        color: fg,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: 26,
              height: 26,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: sel ? AppColors.textPrimary : Colors.transparent,
                border: sel
                    ? null
                    : Border.all(
                        color: const Color(0xFFD1D5DB), width: 2),
              ),
              child: sel
                  ? const Icon(Icons.check_rounded,
                      color: Colors.white, size: 16)
                  : null,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStartingFromCard(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: const Color(0xFFE0F2FE),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          const Icon(Icons.schedule_rounded,
              size: 20, color: Color(0xFF0284C7)),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Batch starting from',
                style: GoogleFonts.poppins(
                  fontSize: Responsive.sp(context, 12),
                  fontWeight: FontWeight.w500,
                  color: const Color(0xFF0284C7),
                ),
              ),
              Text(
                _startingFrom,
                style: GoogleFonts.poppins(
                  fontSize: Responsive.sp(context, 13),
                  fontWeight: FontWeight.w700,
                  color: const Color(0xFF0369A1),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildContinueButton(BuildContext context, double safeBottom) {
    final batches = widget.batches;
    return Container(
      color: Colors.white,
      padding: EdgeInsets.fromLTRB(
          16, 12, 16, safeBottom > 0 ? safeBottom + 8 : 20),
      child: SizedBox(
        width: double.infinity,
        height: 52,
        child: ElevatedButton(
          onPressed: batches.isEmpty
              ? null
              : () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => TicketBookingScreen(
                        event: widget.event,
                        selectedDate: _startingFrom,
                        selectedTime: _timeRange(batches[_batchIdx]),
                      ),
                    ),
                  );
                },
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFFFFCC00),
            foregroundColor: AppColors.textPrimary,
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(30),
            ),
          ),
          child: Text(
            'Continue',
            style: GoogleFonts.poppins(
              fontSize: Responsive.sp(context, 15),
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
          ),
        ),
      ),
    );
  }
}
