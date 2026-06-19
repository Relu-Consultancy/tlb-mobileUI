import '../core/responsive.dart';
import '../core/app_colors.dart';
import 'package:flutter/material.dart';
import '../widgets/auto_scroll_list.dart';
import '../core/listing_image.dart';
import '../widgets/section_divider_widget.dart';
import 'package:google_fonts/google_fonts.dart';
import '../providers/home_feed_state.dart';
import '../data/dummy_data.dart';
import '../core/listing_navigation.dart';

class ParentsFavoriteSection extends StatelessWidget {
  const ParentsFavoriteSection({super.key});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<int>(
      valueListenable: HomeFeedState.version,
      builder: (context, _, __) {
        // ── Reverted to mock data — API wiring commented out (re-enable later) ──
        // final items = HomeFeedState.section('parents_favorite');
        // if (items.isEmpty) return const SizedBox.shrink();
        final items = DummyData.parentsFavorite;
        if (items.isEmpty) return const SizedBox.shrink();
        return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SectionDividerWidget(
          title: "Parents' Favorite",
          topPadding: 30, // 30px gap from previous section's cards
          fontSize: 17,
          textColor: AppColors.textPrimary, // dark navy
        ),
        SizedBox(
          height: Responsive.h(context, 400, min: 360),
          child: AutoScrollList(
            clipBehavior: Clip.hardEdge,
            padding: const EdgeInsets.only(left: 16, right: 8),
            itemCount: items.length,
            addAutomaticKeepAlives: false,
            itemBuilder: (context, index) {
              final event = items[index];
              return GestureDetector(
                onTap: () => openListingDetail(context, event),
                child: Container(
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
                    // card; flush to the edges with a "Loved by Parents" badge.
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
                          // Top-left "Loved by Parents" gradient badge
                          Positioned(
                            top: 0,
                            left: 0,
                            child: _ShineBadge(
                              borderRadius: const BorderRadius.only(
                                topLeft: Radius.circular(16),
                                bottomRight: Radius.circular(16),
                              ),
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 7,
                                ),
                                decoration: const BoxDecoration(
                                  borderRadius: BorderRadius.only(
                                    topLeft: Radius.circular(16),
                                    bottomRight: Radius.circular(16),
                                  ),
                                  gradient: LinearGradient(
                                    colors: [
                                      Color(0xFFF53C9B), // pink
                                      Color(0xFFB13CF5), // purple
                                    ],
                                  ),
                                ),
                                child: Text(
                                  'Loved by Parents',
                                  style: GoogleFonts.poppins(
                                    fontSize: Responsive.sp(context, 13),
                                    fontWeight: FontWeight.w500,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    // Bottom Content Area — natural height (no CTA; the image
                    // above expands to fill the freed space).
                    Padding(
                      padding: const EdgeInsets.fromLTRB(12, 10, 12, 18),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Title + age range
                          Row(
                            children: [
                              Expanded(
                                child: Text(
                                  event.title,
                                  style: GoogleFonts.poppins(
                                    fontSize: Responsive.sp(context, 16),
                                    fontWeight: FontWeight.w600,
                                    color: AppColors.textPrimary,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              const SizedBox(width: 8),
                              const Icon(Icons.people_outline,
                                  size: 14, color: AppColors.textSecondary),
                              const SizedBox(width: 4),
                              Text(
                                event.description ?? '4-12 Yrs',
                                style: GoogleFonts.poppins(
                                  fontSize: Responsive.sp(context, 13),
                                  color: AppColors.textSecondary,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ));
            },
          ),
        ),
      ],
        );
      },
    );
  }
}

/// Wraps a badge with a slow diagonal "shine" that sweeps left → right across
/// it (clipped to the badge shape), pausing briefly between sweeps.
class _ShineBadge extends StatefulWidget {
  final Widget child;
  final BorderRadius borderRadius;

  const _ShineBadge({required this.child, required this.borderRadius});

  @override
  State<_ShineBadge> createState() => _ShineBadgeState();
}

class _ShineBadgeState extends State<_ShineBadge>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    // One slow sweep per loop, with a rest between sweeps.
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 3200),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: widget.borderRadius,
      child: Stack(
        children: [
          widget.child,
          Positioned.fill(
            child: IgnorePointer(
              child: AnimatedBuilder(
                animation: _controller,
                builder: (context, _) {
                  // Sweep across during the first ~45% of the loop, then the
                  // band rests off-screen (the pause) for the remainder.
                  final double p = Curves.easeInOut
                      .transform((_controller.value / 0.45).clamp(0.0, 1.0));
                  final double dx = -1.6 + 3.2 * p; // off-left → off-right
                  return DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment(dx - 0.5, -1.0),
                        end: Alignment(dx + 0.5, 1.0),
                        colors: [
                          Colors.white.withOpacity(0.0),
                          Colors.white.withOpacity(0.38),
                          Colors.white.withOpacity(0.0),
                        ],
                        stops: const [0.35, 0.5, 0.65],
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}
