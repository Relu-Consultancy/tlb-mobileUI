import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import '../core/app_colors.dart';
import '../models/event_model.dart';

class _Batch {
  final String timeRange;
  final String days;
  final int slotsLeft;
  final String tag;
  final Color tagBg;
  final Color tagText;

  const _Batch({
    required this.timeRange,
    required this.days,
    required this.slotsLeft,
    required this.tag,
    required this.tagBg,
    required this.tagText,
  });
}

const _kBatches = [
  _Batch(
    timeRange: '4:00 – 5:00 PM',
    days: 'Mon, Wed, Fri',
    slotsLeft: 8,
    tag: 'Beginners Friendly',
    tagBg: Color(0xFFCCFBF1),
    tagText: Color(0xFF0F766E),
  ),
  _Batch(
    timeRange: '5:00 – 6:00 PM',
    days: 'Mon, Wed, Fri',
    slotsLeft: 5,
    tag: 'Most Popular',
    tagBg: Color(0xFFEDE9FE),
    tagText: Color(0xFF6D28D9),
  ),
  _Batch(
    timeRange: '7:00 – 8:00 PM',
    days: 'Sat, Sun',
    slotsLeft: 10,
    tag: 'Weekend Batch',
    tagBg: Color(0xFFDCFCE7),
    tagText: Color(0xFF15803D),
  ),
];

const _kDates = ['Mon 9 May', 'Wed 10 May', 'Fri 16 May'];

class SelectBatchScreen extends StatefulWidget {
  final EventModel event;

  const SelectBatchScreen({super.key, required this.event});

  @override
  State<SelectBatchScreen> createState() => _SelectBatchScreenState();
}

class _SelectBatchScreenState extends State<SelectBatchScreen> {
  int _selectedDateIndex = 0;
  int _selectedBatchIndex = 0;

  @override
  Widget build(BuildContext context) {
    final safeTop = MediaQuery.of(context).padding.top;
    final safeBottom = MediaQuery.of(context).padding.bottom;

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.dark,
      child: Scaffold(
        backgroundColor: Colors.white,
        body: Column(
          children: [
            // ── Header ──────────────────────────────────────────────────
            Container(
              color: Colors.white,
              padding: EdgeInsets.fromLTRB(16, safeTop + 12, 16, 14),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        color: const Color(0xFFF2F4F7),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.arrow_back_ios_new_rounded,
                        size: 16,
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ),
                  const SizedBox(width: 14),
                  Text(
                    'Select batch',
                    style: GoogleFonts.poppins(
                      fontSize: 17,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ],
              ),
            ),

            // ── Scrollable Content ───────────────────────────────────────
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Venue info card
                    Container(
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
                                    fontSize: 13,
                                    fontWeight: FontWeight.w600,
                                    color: AppColors.textPrimary,
                                  ),
                                ),
                                const SizedBox(height: 6),
                                Row(
                                  children: [
                                    ...List.generate(5, (i) {
                                      final rating = widget.event.rating ?? 4.5;
                                      return Icon(
                                        i < rating.floor()
                                            ? Icons.star_rounded
                                            : (i < rating
                                                ? Icons.star_half_rounded
                                                : Icons.star_outline_rounded),
                                        size: 15,
                                        color: const Color(0xFFFFCC00),
                                      );
                                    }),
                                    const SizedBox(width: 6),
                                    Text(
                                      '(${widget.event.reviewCount ?? '124 reviews'})',
                                      style: GoogleFonts.poppins(
                                        fontSize: 11,
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
                                child: const Icon(
                                  Icons.map_outlined,
                                  color: Color(0xFF0284C7),
                                  size: 26,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 22),

                    // Select Date
                    Text(
                      'Select Date',
                      style: GoogleFonts.poppins(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Row(
                      children: List.generate(_kDates.length, (i) {
                        final isSelected = i == _selectedDateIndex;
                        return GestureDetector(
                          onTap: () => setState(() => _selectedDateIndex = i),
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 180),
                            margin: const EdgeInsets.only(right: 10),
                            padding: const EdgeInsets.symmetric(
                                horizontal: 16, vertical: 9),
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? const Color(0xFFF0FDFB)
                                  : const Color(0xFFF5F5F5),
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(
                                color: isSelected
                                    ? const Color(0xFF0D9488)
                                    : const Color(0xFFE5E5E5),
                                width: isSelected ? 1.5 : 1,
                              ),
                            ),
                            child: Text(
                              _kDates[i],
                              style: GoogleFonts.poppins(
                                fontSize: 12,
                                fontWeight: isSelected
                                    ? FontWeight.w600
                                    : FontWeight.w500,
                                color: isSelected
                                    ? const Color(0xFF0D9488)
                                    : AppColors.textSecondary,
                              ),
                            ),
                          ),
                        );
                      }),
                    ),

                    const SizedBox(height: 24),

                    // Available Batches
                    Text(
                      'Available Batches',
                      style: GoogleFonts.poppins(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 12),

                    ...List.generate(_kBatches.length, (i) {
                      final batch = _kBatches[i];
                      final isSelected = i == _selectedBatchIndex;
                      return GestureDetector(
                        onTap: () => setState(() => _selectedBatchIndex = i),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          margin: const EdgeInsets.only(bottom: 12),
                          padding: const EdgeInsets.fromLTRB(16, 14, 14, 14),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(
                              color: isSelected
                                  ? const Color(0xFF06B6D4)
                                  : const Color(0xFFE5E7EB),
                              width: isSelected ? 2 : 1,
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
                                      batch.timeRange,
                                      style: GoogleFonts.poppins(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w700,
                                        color: AppColors.textPrimary,
                                      ),
                                    ),
                                    const SizedBox(height: 3),
                                    Text(
                                      '${batch.days} · ${batch.slotsLeft} slots left',
                                      style: GoogleFonts.poppins(
                                        fontSize: 12,
                                        color: AppColors.textSecondary,
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 10, vertical: 4),
                                      decoration: BoxDecoration(
                                        color: batch.tagBg,
                                        borderRadius: BorderRadius.circular(20),
                                      ),
                                      child: Text(
                                        batch.tag,
                                        style: GoogleFonts.poppins(
                                          fontSize: 11,
                                          fontWeight: FontWeight.w600,
                                          color: batch.tagText,
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
                                  color: isSelected
                                      ? AppColors.textPrimary
                                      : Colors.transparent,
                                  border: isSelected
                                      ? null
                                      : Border.all(
                                          color: const Color(0xFFD1D5DB),
                                          width: 2,
                                        ),
                                ),
                                child: isSelected
                                    ? const Icon(Icons.check_rounded,
                                        color: Colors.white, size: 16)
                                    : null,
                              ),
                            ],
                          ),
                        ),
                      );
                    }),

                    const SizedBox(height: 8),

                    // Batch starting from
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 14),
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
                                  fontSize: 12,
                                  fontWeight: FontWeight.w500,
                                  color: const Color(0xFF0284C7),
                                ),
                              ),
                              Text(
                                _kDates[_selectedDateIndex],
                                style: GoogleFonts.poppins(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w700,
                                  color: const Color(0xFF0369A1),
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
            ),

            // ── Continue Button ──────────────────────────────────────────
            Container(
              color: Colors.white,
              padding: EdgeInsets.fromLTRB(
                  16, 12, 16, safeBottom > 0 ? safeBottom + 8 : 20),
              child: SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  onPressed: () {},
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
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary,
                    ),
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
