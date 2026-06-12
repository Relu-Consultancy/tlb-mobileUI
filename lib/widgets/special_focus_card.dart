import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:google_fonts/google_fonts.dart';
import '../core/app_colors.dart';
import '../core/responsive.dart';
import '../models/event_model.dart';
import '../screens/event_detail_screen.dart';

class SpecialFocusCard extends StatelessWidget {
  final EventModel event;
  final Color accentColor;

  const SpecialFocusCard({
    super.key,
    required this.event,
    this.accentColor = const Color(0xFF7C3AED),
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => EventDetailScreen(event: event)),
      ),
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.black.withOpacity(0.15), width: 0.7),
          boxShadow: [
            BoxShadow(
              color: accentColor.withOpacity(0.10),
              blurRadius: 14,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: SizedBox(
          height: Responsive.h(context, 155, min: 130),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Left accent strip
              Container(
                width: 6,
                decoration: BoxDecoration(
                  color: accentColor,
                  borderRadius: const BorderRadius.horizontal(left: Radius.circular(20)),
                ),
              ),

              // Content
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(14, 12, 10, 12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Tag badge
                      if ((event.tag ?? '').isNotEmpty)
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: accentColor.withOpacity(0.10),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            event.tag!,
                            style: GoogleFonts.poppins(
                              fontSize: Responsive.sp(context, 10.5),
                              fontWeight: FontWeight.w500,
                              color: accentColor,
                              letterSpacing: 0.4,
                            ),
                          ),
                        ),
                      const SizedBox(height: 6),

                      // Title
                      Text(
                        event.title,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: GoogleFonts.poppins(
                          fontSize: Responsive.sp(context, 14),
                          fontWeight: FontWeight.w500,
                          color: AppColors.textPrimary,
                          height: 1.25,
                        ),
                      ),
                      const SizedBox(height: 5),

                      // Age group
                      if ((event.reviewCount ?? '').isNotEmpty)
                        Row(
                          children: [
                            Icon(Icons.people_outline_rounded, size: 13, color: accentColor),
                            const SizedBox(width: 4),
                            Text(
                              event.reviewCount!,
                              style: GoogleFonts.poppins(
                                fontSize: Responsive.sp(context, 11),
                                color: AppColors.textSecondary,
                              ),
                            ),
                          ],
                        ),
                      const SizedBox(height: 3),

                      // Venue
                      Row(
                        children: [
                          const Icon(Icons.location_on_outlined, size: 12, color: AppColors.textSecondary),
                          const SizedBox(width: 4),
                          Expanded(
                            child: Text(
                              event.venue,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: GoogleFonts.poppins(
                                fontSize: Responsive.sp(context, 11),
                                color: AppColors.textSecondary,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 3),

                      // Rating
                      if (event.rating != null)
                        RatingBarIndicator(
                          rating: event.rating!,
                          itemBuilder: (_, __) => const Icon(Icons.star, color: AppColors.starFilled),
                          unratedColor: AppColors.starEmpty,
                          itemCount: 5,
                          itemSize: 12,
                        ),

                      // Description
                      if ((event.description ?? '').isNotEmpty) ...[
                        const SizedBox(height: 4),
                        Text(
                          event.description!,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: GoogleFonts.poppins(
                            fontSize: Responsive.sp(context, 10.5),
                            color: AppColors.textDescription,
                            height: 1.4,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),

              // Right image
              ClipRRect(
                borderRadius: const BorderRadius.horizontal(right: Radius.circular(20)),
                child: Image.asset(
                  event.imagePath,
                  width: Responsive.w(context, 120, min: 96),
                  height: double.infinity,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => Container(
                    width: Responsive.w(context, 120, min: 96),
                    color: accentColor.withOpacity(0.12),
                    child: Icon(Icons.favorite_border_rounded, size: 40, color: accentColor),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
