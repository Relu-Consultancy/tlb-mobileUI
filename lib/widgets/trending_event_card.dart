import 'package:flutter/material.dart';
import '../core/app_colors.dart';
import 'package:google_fonts/google_fonts.dart';
import '../core/responsive.dart';
import '../models/event_model.dart';
import '../screens/event_detail_screen.dart';
import 'wishlist_button.dart';

/// Vertical "Trending Events" card:
/// image-dominant (date badge top-left + heart top-right), then title,
/// a [Workshop tag · age] row, rating, and a [location · Book Now] row.
class TrendingEventCard extends StatelessWidget {
  final EventModel event;

  const TrendingEventCard({super.key, required this.event});

  @override
  Widget build(BuildContext context) {
    // eventDate is "Day, DD Mon" → split into weekday + date for the badge.
    final dateParts = (event.eventDate ?? 'Sat, 21 Mar').split(',');
    final String dayLabel = dateParts.first.trim();
    final String dateLabel =
        dateParts.length > 1 ? dateParts[1].trim() : '21 Mar';

    void openDetail() => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => EventDetailScreen(event: event)),
        );

    return GestureDetector(
      onTap: openDetail,
      child: Container(
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
            // ── Image (dominant) with date badge + heart ──
            Expanded(
              child: Stack(
                children: [
                  Positioned.fill(
                    child: ClipRRect(
                      borderRadius: const BorderRadius.vertical(
                        top: Radius.circular(16),
                      ),
                      child: Image.asset(
                        event.imagePath,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => Container(
                          color: AppColors.primaryLight.withOpacity(0.15),
                          child: const Icon(Icons.event, size: 40),
                        ),
                      ),
                    ),
                  ),
                  // Date badge (top-left)
                  Positioned(
                    top: 12,
                    left: 12,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 7),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 6,
                          ),
                        ],
                      ),
                      child: Column(
                        children: [
                          Text(
                            dayLabel,
                            style: GoogleFonts.poppins(
                              fontSize: Responsive.sp(context, 13),
                              fontWeight: FontWeight.w500,
                              color: AppColors.textPrimary,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            dateLabel,
                            style: GoogleFonts.poppins(
                              fontSize: Responsive.sp(context, 12),
                              fontWeight: FontWeight.w500,
                              color: const Color(0xFF0066CC),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  // Heart (top-right)
                  Positioned(
                    top: 12,
                    right: 12,
                    child: WishlistButton(
                      event: event,
                      containerSize: 36,
                      showShadow: true,
                      iconType: WishlistIconType.favorite,
                    ),
                  ),
                ],
              ),
            ),

            // ── Content ──
            Padding(
              // 18px gap below the CTA button (card bottom padding).
              padding: const EdgeInsets.fromLTRB(14, 12, 14, 18),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
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

                  // Tag chip + age range
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 14, vertical: 6),
                        decoration: BoxDecoration(
                          color: const Color(0xFFE8EAFF), // light lavender
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          event.tag ?? 'Workshop',
                          style: GoogleFonts.poppins(
                            fontSize: Responsive.sp(context, 13),
                            fontWeight: FontWeight.w600,
                            color: const Color(0xFF5B6CF0), // indigo
                          ),
                        ),
                      ),
                      const Spacer(),
                      const Icon(Icons.people_outline,
                          size: 15, color: AppColors.textPrimary),
                      const SizedBox(width: 4),
                      Text(
                        event.description ?? '4-12 Yrs',
                        style: GoogleFonts.poppins(
                          fontSize: Responsive.sp(context, 12),
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),

                  // Location + Book Now
                  Row(
                    children: [
                      const Icon(Icons.location_on_outlined,
                          size: 15, color: AppColors.textPrimary),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          event.venue,
                          style: GoogleFonts.poppins(
                            fontSize: Responsive.sp(context, 12),
                            color: AppColors.textSecondary,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const SizedBox(width: 8),
                      SizedBox(
                        height: Responsive.h(context, 38, min: 34),
                        child: ElevatedButton(
                          onPressed: openDetail,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primaryLight,
                            foregroundColor: AppColors.textPrimary,
                            elevation: 0,
                            padding:
                                const EdgeInsets.symmetric(horizontal: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20),
                            ),
                          ),
                          child: Text(
                            'Book Now',
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
      ),
    );
  }
}
