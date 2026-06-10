import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:google_fonts/google_fonts.dart';
import '../core/app_colors.dart';
import '../core/responsive.dart';
import '../models/event_model.dart';
import 'wishlist_button.dart';
import '../screens/class_detail_screen.dart';
import '../screens/event_detail_screen.dart';
import 'inquire_now_sheet.dart';

/// Vertical event card matching the design:
/// Image (with date badge + heart), title, tag pill, age range, rating + count, venue, Book Now.
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
        } else if (buttonLabel == 'Check Availability') {
          Navigator.push(context, MaterialPageRoute(builder: (_) => ClassDetailScreen(event: event)));
        } else {
          Navigator.push(context, MaterialPageRoute(builder: (_) => EventDetailScreen(event: event)));
        }
      },
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.cardBackground,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.black.withOpacity(0.15), width: 0.7),
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
            Stack(
              children: [
                ClipRRect(
                  borderRadius:
                      const BorderRadius.vertical(top: Radius.circular(16)),
                  child: AspectRatio(
                    aspectRatio: 1.15,
                    child: Image.asset(
                      event.imagePath,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => Container(
                        color: AppColors.primary.withOpacity(0.15),
                        child: const Icon(Icons.event, size: 40),
                      ),
                    ),
                  ),
                ),
                // Date badge (top-left)
                Positioned(
                  top: 10,
                  left: 10,
                  child: Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: Colors.black.withOpacity(0.15), width: 0.7),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.08),
                          blurRadius: 6,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Column(
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

            // ── Content below image ──
            Expanded(
              child: Padding(
                // 20px gap below the CTA button (card bottom padding).
                padding: const EdgeInsets.fromLTRB(10, 8, 10, 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Title
                    Text(
                      event.title,
                      style: GoogleFonts.poppins(
                        fontSize: Responsive.sp(context, 14),
                        fontWeight: FontWeight.w500,
                        color: AppColors.textPrimary,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 8),

                    // Tag pill (e.g. "Workshop")
                    if (event.tag != null)
                      Container(
                        margin: const EdgeInsets.only(bottom: 3),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: AppColors.primary,
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          event.tag!,
                          style: GoogleFonts.poppins(
                            fontSize: Responsive.sp(context, 9),
                            fontWeight: FontWeight.w500,
                            color: Colors.white,
                          ),
                        ),
                      ),

                    // Age range
                    if (event.reviewCount != null)
                      Row(
                        children: [
                          const Icon(Icons.people_outline,
                              size: 13, color: AppColors.textSecondary),
                          const SizedBox(width: 3),
                          Text(
                            event.reviewCount!,
                            style: GoogleFonts.poppins(
                              fontSize: Responsive.sp(context, 11),
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    const SizedBox(height: 8),

                    // Rating row
                    Row(
                      children: [
                        RatingBarIndicator(
                          rating: event.rating ?? 0,
                          itemBuilder: (_, __) =>
                              const Icon(Icons.star, color: AppColors.starFilled),
                          unratedColor: AppColors.starEmpty,
                          itemCount: 5,
                          itemSize: 14,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '${event.rating?.toStringAsFixed(1) ?? '0'} reviews',
                          style: GoogleFonts.poppins(
                            fontSize: Responsive.sp(context, 10),
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),

                    // Venue
                    Row(
                      children: [
                        const Icon(Icons.location_on_outlined,
                            size: 13, color: AppColors.textSecondary),
                        const SizedBox(width: 3),
                        Expanded(
                          child: Text(
                            event.venue,
                            style: GoogleFonts.poppins(
                              fontSize: Responsive.sp(context, 11),
                              color: AppColors.textSecondary,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),

                    const Spacer(),

                    // Book Now button
                    SizedBox(
                      width: double.infinity,
                      height: Responsive.h(context, 32, min: 28),
                      child: ElevatedButton(
                        onPressed: () {
                          if (onTap != null) {
                            onTap!();
                          } else if (buttonLabel == 'Send Enquiry') {
                            showInquireNow(context, listingId: event.id);
                          } else if (buttonLabel == 'Check Availability') {
                            Navigator.push(context, MaterialPageRoute(builder: (_) => ClassDetailScreen(event: event)));
                          } else {
                            Navigator.push(context, MaterialPageRoute(builder: (_) => EventDetailScreen(event: event)));
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primaryLight,
                          foregroundColor: const Color(0xFF1A1A2E),
                          elevation: 0,
                          padding: EdgeInsets.zero,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                          ),
                        ),
                        child: Text(
                          buttonLabel,
                          style: GoogleFonts.poppins(
                            fontSize: Responsive.sp(context, 11),
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
