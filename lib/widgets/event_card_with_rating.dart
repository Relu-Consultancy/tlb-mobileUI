import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../core/app_colors.dart';
import '../core/responsive.dart';
import '../models/event_model.dart';
import 'listing_meta_rows.dart';
import 'wishlist_button.dart';
import '../screens/class_detail_screen.dart';
import '../screens/event_detail_screen.dart';

/// Vertical event card matching the design:
/// Image (with date badge + heart), title, tag pill, and the meta block.
/// Whole card is tappable — routes according to [buttonLabel]/[onTap].
///
/// The card is always placed in a fixed-height rail, so the image is [Expanded]
/// rather than given a fixed aspect ratio: it takes whatever height the content
/// beneath doesn't need, leaving no blank strip at the card's foot.
class EventCardWithRating extends StatelessWidget {
  final EventModel event;
  final String buttonLabel;
  final VoidCallback? onTap;

  const EventCardWithRating({
    super.key,
    required this.event,
    this.buttonLabel = 'Book Now',
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        if (onTap != null) {
          onTap!();
        } else if (buttonLabel == 'Send Enquiry') {
          Navigator.push(context, MaterialPageRoute(builder: (_) => ClassDetailScreen(event: event, buttonLabel: buttonLabel)));
        } else if (buttonLabel == 'Check Availability' || buttonLabel == 'View Details') {
          Navigator.push(context, MaterialPageRoute(builder: (_) => ClassDetailScreen(event: event)));
        } else {
          Navigator.push(context, MaterialPageRoute(builder: (_) => EventDetailScreen(event: event)));
        }
      },
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.cardBackground,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.black.withOpacity(0.1), width: 0.7),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.06),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Image with date badge & wishlist ──
            Expanded(
              child: Stack(
                fit: StackFit.expand,
                children: [
                  ClipRRect(
                    borderRadius:
                        const BorderRadius.vertical(top: Radius.circular(16)),
                    child: Image.asset(
                      event.imagePath,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => Container(
                        color: AppColors.primary.withOpacity(0.15),
                        child: const Icon(Icons.event, size: 40),
                      ),
                    ),
                  ),
                  // Date badge (top-left)
                  Positioned(
                    top: 10,
                    left: 10,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 6),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                            color: Colors.black.withOpacity(0.1), width: 0.7),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.08),
                            blurRadius: 6,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            'Sat',
                            style: GoogleFonts.poppins(
                              fontSize: Responsive.sp(context, 11),
                              fontWeight: FontWeight.w500,
                              color: const Color(0xFF1E293B),
                            ),
                          ),
                          Text(
                            '12 Aug',
                            style: GoogleFonts.poppins(
                              fontSize: Responsive.sp(context, 10),
                              fontWeight: FontWeight.w500,
                              color: AppColors.primary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  // Wishlist heart (top-right)
                  Positioned(
                    top: 10,
                    right: 10,
                    child: WishlistButton(
                      event: event,
                      containerSize: 34,
                      iconType: WishlistIconType.favorite,
                    ),
                  ),
                ],
              ),
            ),

            // ── Content below image — sized to itself, so the image above
            // absorbs the rest of the rail's height. ──
            Padding(
              padding: const EdgeInsets.fromLTRB(10, 10, 10, 14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Title
                  Text(
                    event.title,
                    style: GoogleFonts.poppins(
                      fontSize: Responsive.sp(context, 16),
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 8),

                  // Tag pill (e.g. "Workshop")
                  if (event.tag != null) ...[
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 4),
                      decoration: BoxDecoration(
                        color: AppColors.primary,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        event.tag!,
                        style: GoogleFonts.poppins(
                          fontSize: Responsive.sp(context, 11),
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),
                  ],

                  // Two-column meta: Age + Date·Time on the left, Location +
                  // Distance on the right.
                  ListingMetaRows(
                    event: event,
                    showLocation: true,
                    twoColumn: true,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
