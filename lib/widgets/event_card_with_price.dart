import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../core/app_colors.dart';
import '../core/responsive.dart';
import '../models/event_model.dart';
import 'wishlist_button.dart';
import '../screens/event_detail_screen.dart';

class EventCardWithPrice extends StatelessWidget {
  final EventModel event;
  final double? width;

  const EventCardWithPrice({
    super.key,
    required this.event,
    this.width,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => EventDetailScreen(event: event)),
      ),
      child: Container(
      width: width ?? (MediaQuery.of(context).size.width * 0.8 > 300 ? 300 : MediaQuery.of(context).size.width * 0.8),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(16),
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
        mainAxisSize: MainAxisSize.min,
        children: [
          // Image with bookmark
          Stack(
            children: [
              ClipRRect(
                borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                child: Image.asset(
                  event.imagePath,
                  width: width ?? double.infinity,
                  height: Responsive.h(context, 200, min: 140),
                  fit: BoxFit.cover,
                  cacheWidth: width != null ? (width! * 2).toInt() : null,
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      width: width ?? double.infinity,
                      height: Responsive.h(context, 200, min: 140),
                      color: AppColors.primary.withOpacity(0.2),
                      child: const Icon(Icons.event, size: 48),
                    );
                  },
                ),
              ),
              Positioned(
                top: 8,
                right: 8,
                child: WishlistButton(
                  event: event,
                  containerSize: 32,
                  iconType: WishlistIconType.bookmark,
                ),
              ),
            ],
          ),
          // Content
          Padding(
            padding: const EdgeInsets.all(14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  event.title,
                  style: GoogleFonts.poppins(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    const Icon(
                      Icons.location_on_outlined,
                      size: 14,
                      color: AppColors.textSecondary,
                    ),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        event.venue,
                        style: GoogleFonts.poppins(
                          fontSize: 12,
                          color: AppColors.textSecondary,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                // Price and Book Now
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    RichText(
                      text: TextSpan(
                        children: [
                          TextSpan(
                            text: '₹${event.price?.toInt() ?? 0}',
                            style: GoogleFonts.poppins(
                              fontSize: Responsive.sp(context, 20),
                              fontWeight: FontWeight.w700,
                              color: AppColors.textPrimary,
                            ),
                          ),
                          TextSpan(
                            text: ' / Person',
                            style: GoogleFonts.poppins(
                              fontSize: 13,
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                    ElevatedButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => EventDetailScreen(event: event)),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: Colors.white,
                        minimumSize: const Size(0, 46),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 10,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(24),
                        ),
                        elevation: 0,
                      ),
                      child: Text(
                        'Book Now',
                        style: GoogleFonts.poppins(
                          fontSize: Responsive.sp(context, 13),
                          fontWeight: FontWeight.w600,
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
