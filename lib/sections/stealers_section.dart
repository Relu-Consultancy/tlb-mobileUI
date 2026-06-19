import 'dart:async';
import '../core/responsive.dart';
import '../core/app_colors.dart';
import 'package:flutter/material.dart';
import '../widgets/auto_scroll_list.dart';
import '../core/listing_image.dart';
import 'package:google_fonts/google_fonts.dart';
import '../widgets/section_divider_widget.dart';
import '../providers/home_feed_state.dart';
import '../data/dummy_data.dart';
import '../core/listing_navigation.dart';

class StealersSection extends StatelessWidget {
  const StealersSection({super.key});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<int>(
      valueListenable: HomeFeedState.version,
      builder: (context, _, __) {
        // ── Reverted to mock data — API wiring commented out (re-enable later) ──
        // final items = HomeFeedState.section('stealers');
        // if (items.isEmpty) return const SizedBox.shrink();
        final items = DummyData.stealers;
        if (items.isEmpty) return const SizedBox.shrink();
        return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SectionDividerWidget(
          title: 'Stealers',
          topPadding: 30, // 30px gap from previous section's cards
          fontSize: 17,
          textColor: AppColors.textPrimary, // dark navy
        ),
        SizedBox(
          height: Responsive.h(context, 420, min: 380),
          child: AutoScrollList(
            clipBehavior: Clip.hardEdge,
            padding: const EdgeInsets.only(left: 16, right: 8),
            itemCount: items.length,
            itemBuilder: (context, index) {
              final event = items[index];
              return Container(
                width: Responsive.cardWidth(context, fraction: 0.82, max: 340),
                margin: const EdgeInsets.only(right: 16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.black.withOpacity(0.1), width: 0.7),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Top Image Area — Expanded so the image dominates the
                    // card; flush to the edges, with the countdown pill at the
                    // top and the discount band at the bottom.
                    Expanded(
                      child: Stack(
                        children: [
                          Positioned.fill(
                            child: ClipRRect(
                              borderRadius: const BorderRadius.vertical(
                                top: Radius.circular(16),
                              ),
                              child: listingImage(event.imagePath,
                                width: double.infinity,
                                fit: BoxFit.cover,
                              ),
                            ),
                          ),
                          // Top yellow countdown pill ("End in ...")
                          if (event.description != null)
                            Positioned(
                              top: 0,
                              left: 0,
                              right: 0,
                              child: Center(
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 16, vertical: 6),
                                  decoration: const BoxDecoration(
                                    gradient: LinearGradient(
                                      colors: [
                                        Color(0xFFFFF176), // light yellow
                                        Color(0xFFFFEE58),
                                      ],
                                    ),
                                    borderRadius: BorderRadius.vertical(
                                        bottom: Radius.circular(12)),
                                  ),
                                  child: _CountdownText(
                                    text: event.description!,
                                    style: GoogleFonts.poppins(
                                      fontSize: Responsive.sp(context, 12),
                                      fontWeight: FontWeight.w500,
                                      color: AppColors.textPrimary,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          // Bottom pink discount band ("60% OFF")
                          if (event.tag != null)
                            Positioned(
                              bottom: 0,
                              left: 0,
                              right: 0,
                              child: ClipRect(
                                child: Stack(
                                  children: [
                                    Container(
                                      width: double.infinity,
                                      decoration: const BoxDecoration(
                                        gradient: LinearGradient(
                                          colors: [
                                            Color(0xFFE040FB), // bright pink
                                            Color(0xFFEA80FC), // lighter pink-purple
                                          ],
                                        ),
                                      ),
                                      padding: const EdgeInsets.symmetric(
                                          vertical: 6, horizontal: 12),
                                      child: Text(
                                        event.tag!,
                                        style: GoogleFonts.poppins(
                                          fontSize: Responsive.sp(context, 12),
                                          color: Colors.white,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    ),
                                    // Left→right shine sweeping across the strip.
                                    const Positioned.fill(
                                      child: IgnorePointer(
                                        child: _ShineOverlay(),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),

                    // Bottom Content Area — kept tight so the image above
                    // stretches further down (less white space).
                    Padding(
                      padding: const EdgeInsets.fromLTRB(16, 10, 16, 18),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            event.title,
                            style: GoogleFonts.poppins(
                              fontSize: Responsive.sp(context, 17),
                              fontWeight: FontWeight.w500,
                              color: AppColors.textPrimary,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 8),
                          // Grab Deal button (price label removed)
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Spacer(),
                              SizedBox(
                                height: Responsive.h(context, 30, min: 27),
                                child: ElevatedButton(
                                  onPressed: () {
                                    openListingDetail(context, event);
                                  },
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: AppColors.primaryLight,
                                    foregroundColor: AppColors.textPrimary,
                                    elevation: 0,
                                    minimumSize: Size.zero,
                                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                    padding: const EdgeInsets.symmetric(horizontal: 16),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(20),
                                    ),
                                  ),
                                  child: Text(
                                    'View Now',
                                    style: GoogleFonts.poppins(
                                      fontSize: Responsive.sp(context, 12),
                                      fontWeight: FontWeight.w500,
                                    ),
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
            },
          ),
        ),
      ],
        );
      },
    );
  }
}

/// Renders an "End in HH:MM:SS" label that ticks down once per second (a real
/// countdown). If the text has no HH:MM:SS pattern it is shown unchanged.
class _CountdownText extends StatefulWidget {
  final String text;
  final TextStyle style;

  const _CountdownText({required this.text, required this.style});

  @override
  State<_CountdownText> createState() => _CountdownTextState();
}

class _CountdownTextState extends State<_CountdownText> {
  Timer? _timer;
  Duration _remaining = Duration.zero;
  String _prefix = '';
  bool _valid = false;

  @override
  void initState() {
    super.initState();
    _parse();
    if (_valid) {
      _timer = Timer.periodic(const Duration(seconds: 1), (_) {
        if (!mounted) return;
        if (_remaining.inSeconds <= 0) {
          _timer?.cancel();
          return;
        }
        setState(() => _remaining -= const Duration(seconds: 1));
      });
    }
  }

  void _parse() {
    final m = RegExp(r'(\d{1,2}):(\d{2}):(\d{2})').firstMatch(widget.text);
    if (m == null) return;
    _remaining = Duration(
      hours: int.parse(m.group(1)!),
      minutes: int.parse(m.group(2)!),
      seconds: int.parse(m.group(3)!),
    );
    _prefix = widget.text.substring(0, m.start);
    _valid = true;
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  String _fmt(Duration d) {
    String two(int n) => n.toString().padLeft(2, '0');
    return '${two(d.inHours)}:${two(d.inMinutes % 60)}:${two(d.inSeconds % 60)}';
  }

  @override
  Widget build(BuildContext context) {
    final label = !_valid
        ? widget.text
        : (_remaining.inSeconds <= 0 ? 'Ended' : '$_prefix${_fmt(_remaining)}');
    return Text(label, style: widget.style);
  }
}

/// A soft white highlight that sweeps left→right across its parent on a loop,
/// then briefly rests — a premium "shine" on the discount strip.
class _ShineOverlay extends StatefulWidget {
  const _ShineOverlay();

  @override
  State<_ShineOverlay> createState() => _ShineOverlayState();
}

class _ShineOverlayState extends State<_ShineOverlay>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2200),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, _) {
        // Sweep across during the first ~55% of the loop, then rest off-edge.
        final p = Curves.easeInOut
            .transform((_controller.value / 0.55).clamp(0.0, 1.0));
        final dx = -1.6 + 3.2 * p;
        return DecoratedBox(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment(dx - 0.3, -1.0),
              end: Alignment(dx + 0.3, 1.0),
              colors: [
                Colors.white.withOpacity(0.0),
                Colors.white.withOpacity(0.45),
                Colors.white.withOpacity(0.0),
              ],
              stops: const [0.35, 0.5, 0.65],
            ),
          ),
        );
      },
    );
  }
}
