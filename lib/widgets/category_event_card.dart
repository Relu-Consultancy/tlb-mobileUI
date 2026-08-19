import 'package:flutter/material.dart';
import '../core/responsive.dart';
import 'package:google_fonts/google_fonts.dart';
import '../core/app_colors.dart';
import '../models/event_model.dart';
import '../screens/event_detail_screen.dart';

class CategoryEventCard extends StatelessWidget {
  final EventModel event;
  final Color badgeColor;
  final VoidCallback? onTap;

  const CategoryEventCard({
    super.key,
    required this.event,
    required this.badgeColor,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      // This card has no card-shaped background of its own (image + bare text
      // below), so a deferToChild hit test would only catch the image and the
      // glyphs — the gaps between the meta rows, and the space right of a
      // short title, would silently do nothing. Opaque makes the card's whole
      // rectangle tappable.
      behavior: HitTestBehavior.opaque,
      onTap: onTap ?? () => Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => EventDetailScreen(event: event)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Image with badge overlay — rounded corners, no card wrapper
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Stack(
              children: [
                AspectRatio(
                  aspectRatio: 1.05,
                  child: event.imagePath.startsWith('http')
                      ? Image.network(
                          event.imagePath,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => Container(
                            color: AppColors.primary.withOpacity(0.15),
                            child: const Icon(Icons.event, size: 36, color: AppColors.textSecondary),
                          ),
                        )
                      : Image.asset(
                          event.imagePath,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => Container(
                            color: AppColors.primary.withOpacity(0.15),
                            child: const Icon(Icons.event, size: 36, color: AppColors.textSecondary),
                          ),
                        ),
                ),
                if ((event.tag ?? '').isNotEmpty)
                  Positioned(
                    bottom: 0,
                    left: 0,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: const BoxDecoration(
                        // Warm-orange tab attached flush to the image's
                        // bottom-left corner: outer corner rounded to match the
                        // image, inner corner rounded for the tab look.
                        // Fixed orange (not the faint per-category accent) so the
                        // white label stays clearly visible on every category.
                        color: Color(0xFFE8941A),
                        borderRadius: BorderRadius.only(
                          bottomLeft: Radius.circular(12),
                          topRight: Radius.circular(10),
                        ),
                      ),
                      child: Text(
                        event.tag!,
                        style: GoogleFonts.poppins(
                          fontSize: Responsive.sp(context, 9.5),
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
          // Info section — sits directly on white background
          Padding(
            padding: const EdgeInsets.fromLTRB(2, 8, 2, 0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  event.title,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.poppins(
                    fontSize: Responsive.sp(context, 12.5),
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                    height: 1.3,
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Icon(Icons.location_on, size: 13, color: AppColors.textPrimary),
                    const SizedBox(width: 2),
                    Expanded(
                      child: Text(
                        event.venue,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: GoogleFonts.poppins(
                          fontSize: Responsive.sp(context, 10.5),
                          color: AppColors.textSecondary,
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
  }
}
