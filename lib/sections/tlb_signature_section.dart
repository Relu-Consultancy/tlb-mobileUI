import '../core/responsive.dart';
import 'package:flutter/material.dart';
import '../widgets/auto_scroll_list.dart';
import '../core/listing_image.dart';
import 'package:google_fonts/google_fonts.dart';
import '../widgets/section_divider_widget.dart';
import '../providers/home_feed_state.dart';
import '../data/dummy_data.dart';
import '../core/listing_navigation.dart';
import '../widgets/animated_gradient_tag.dart';

class TlbSignatureSection extends StatelessWidget {
  const TlbSignatureSection({super.key});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<int>(
      valueListenable: HomeFeedState.version,
      builder: (context, _, __) {
        // ── Reverted to mock data — API wiring commented out (re-enable later) ──
        // final items = HomeFeedState.section('tlb_signature');
        // if (items.isEmpty) return const SizedBox.shrink();
        final items = DummyData.tlbSignature;
        return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SectionDividerWidget(
          title: 'TLB Signature',
          topPadding: 30, // 30px gap from previous section's cards
          fontSize: 17,
          textColor: Color(0xFF1A1A2E), // dark navy
        ),
        SizedBox(
          height: Responsive.h(context, 480, min: 430),
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
                    // Top Image Area — Expanded so the poster dominates the
                    // card; flush to the edges with the "TLB Originals" pill
                    // centered at the top.
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
                          // "TLB Originals" pill (top-center) — slim white
                          // border with an endlessly colour-cycling gradient.
                          const Positioned(
                            top: 12,
                            left: 0,
                            right: 0,
                            child: Center(
                              child: AnimatedGradientTag(
                                text: 'TLB Originals',
                                fontSize: 13,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    // Bottom Content — natural height.
                    Padding(
                      // 20px gap below the CTA button (card bottom padding).
                      padding: const EdgeInsets.fromLTRB(16, 16, 16, 20),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            event.title,
                            style: GoogleFonts.poppins(
                              fontSize: Responsive.sp(context, 16),
                              fontWeight: FontWeight.w600,
                              color: const Color(0xFF1A1A2E),
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            event.venue, // venue holds the subtitle/description
                            style: GoogleFonts.poppins(
                              fontSize: Responsive.sp(context, 13),
                              color: Color(0xFF333333),
                              height: 1.4,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 14),
                          SizedBox(
                            width: double.infinity,
                            height: Responsive.h(context, 42, min: 40),
                            child: ElevatedButton(
                              onPressed: () {
                                openListingDetail(context, event);
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFFFFCC00),
                                foregroundColor: const Color(0xFF1A1A2E),
                                elevation: 0,
                                // Let the SizedBox drive the height instead of the
                                // default 48px padded tap target (which squished
                                // the button at the previous 32–36px height).
                                minimumSize: Size.zero,
                                padding: const EdgeInsets.symmetric(horizontal: 16),
                                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(20),
                                ),
                              ),
                              child: Text(
                                'View Now',
                                style: GoogleFonts.poppins(
                                  fontSize: Responsive.sp(context, 14),
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
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
