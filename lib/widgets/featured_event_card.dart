import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../core/app_colors.dart';
import '../core/responsive.dart';
import '../core/saved_events_state.dart';
import '../models/event_model.dart';
import 'package:like_button/like_button.dart';
import '../screens/event_detail_screen.dart';

class FeaturedEventCard extends StatelessWidget {
  final EventModel event;
  final double? width;

  const FeaturedEventCard({
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
      width: width ?? (MediaQuery.of(context).size.width * 0.6 > 200 ? 200 : MediaQuery.of(context).size.width * 0.6),
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
          // Image with Featured badge
          Stack(
            children: [
              ClipRRect(
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(16),
                ),
                child: Image.asset(
                  event.imagePath,
                  width: width ?? double.infinity,
                  height: Responsive.h(context, 180, min: 130),
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      width: width ?? double.infinity,
                      height: Responsive.h(context, 180, min: 130),
                      color: AppColors.primary.withOpacity(0.2),
                      child: const Icon(Icons.event, size: 40),
                    );
                  },
                ),
              ),
              if (event.isFeatured)
                Positioned(
                  top: 10,
                  right: 10,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.tagFeatured,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      'Featured',
                      style: GoogleFonts.poppins(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              Positioned(
                top: 8,
                left: 8,
                child: ValueListenableBuilder<List<EventModel>>(
                  valueListenable: SavedEventsState.savedEvents,
                  builder: (context, _, __) {
                    final isSaved = SavedEventsState.isSaved(event);
                    return Container(
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.35),
                        shape: BoxShape.circle,
                      ),
                      child: LikeButton(
                        size: 20,
                        isLiked: isSaved,
                        circleColor: const CircleColor(start: Color(0xFFFF5252), end: Colors.red),
                        bubblesColor: const BubblesColor(
                          dotPrimaryColor: Colors.red,
                          dotSecondaryColor: Colors.redAccent,
                        ),
                        onTap: (bool isLiked) async {
                          SavedEventsState.toggle(event, context);
                          return !isLiked;
                        },
                        likeBuilder: (bool isLiked) {
                          return Icon(
                            isLiked ? Icons.bookmark : Icons.bookmark_border,
                            color: isLiked ? Colors.red : Colors.white,
                            size: 18,
                          );
                        },
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
          // Content
          Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  event.title,
                  style: GoogleFonts.poppins(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
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
              ],
            ),
          ),
        ],
      ),
      ),
    );
  }
}
