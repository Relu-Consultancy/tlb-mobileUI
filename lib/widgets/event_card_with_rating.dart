import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:google_fonts/google_fonts.dart';
import '../core/app_colors.dart';
import '../core/saved_events_state.dart';
import '../models/event_model.dart';
import 'package:like_button/like_button.dart';
import '../screens/event_detail_screen.dart';

class EventCardWithRating extends StatelessWidget {
  final EventModel event;

  const EventCardWithRating({super.key, required this.event});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => EventDetailScreen(event: event)),
      ),
      child: Container(
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Image with bookmark
          Stack(
            children: [
              ClipRRect(
                borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                child: AspectRatio(
                  aspectRatio: 1,
                  child: Image.asset(
                    event.imagePath,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        color: AppColors.primary.withOpacity(0.2),
                        child: const Icon(Icons.event, size: 40),
                      );
                    },
                  ),
                ),
              ),
              Positioned(
                top: 8,
                right: 8,
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
                            color: isLiked ? const Color(0xFFFFB902) : Colors.white,
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
          Padding(
            padding: const EdgeInsets.all(10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  event.title,
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Text(
                  event.reviewCount ?? '',
                  style: GoogleFonts.poppins(
                    fontSize: 12,
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 4),
                RatingBarIndicator(
                  rating: event.rating ?? 0,
                  itemBuilder: (context, _) => const Icon(
                    Icons.star,
                    color: AppColors.starFilled,
                  ),
                  unratedColor: AppColors.starEmpty,
                  itemCount: 5,
                  itemSize: 18,
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
