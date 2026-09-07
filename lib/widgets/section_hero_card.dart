import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../core/app_colors.dart';
import '../core/listing_image.dart';
import '../core/listing_navigation.dart';
import '../core/responsive.dart';
import '../models/event_model.dart';
import 'wishlist_button.dart';

/// The one listing an admin flagged as a section's hero, drawn as a
/// full-width banner above that section's rail.
///
/// The admin panel calls this slot the section's "top banner" and previews it
/// as a large featured card, so it gets its own treatment rather than sitting
/// in the rail as another identical card — there it was indistinguishable
/// from the listings around it, which is the same as not being featured.
class SectionHeroCard extends StatelessWidget {
  final EventModel event;

  const SectionHeroCard({super.key, required this.event});

  @override
  Widget build(BuildContext context) {
    // Wide and short: a banner, not a poster. The rail below it carries the
    // tall cards.
    final double height = Responsive.h(context, 178, min: 158);

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () => openListingDetail(context, event),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: SizedBox(
            height: height,
            width: double.infinity,
            child: Stack(
              fit: StackFit.expand,
              children: [
                listingImage(event.imagePath, fit: BoxFit.cover),
                // Dark foot so the title stays legible over any artwork.
                const DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Color(0x00000000),
                        Color(0x33000000),
                        Color(0xCC000000),
                      ],
                      stops: [0.35, 0.6, 1.0],
                    ),
                  ),
                ),
                Positioned(top: 12, left: 12, child: _featuredPill(context)),
                Positioned(
                  top: 8,
                  right: 8,
                  child: WishlistButton(
                    event: event,
                    containerSize: 34,
                    iconSize: 18,
                    backgroundColor: Colors.black.withOpacity(0.35),
                    borderColor: Colors.white.withOpacity(0.45),
                    unlikedColor: Colors.white,
                  ),
                ),
                Positioned(
                  left: 14,
                  right: 14,
                  bottom: 12,
                  child: _caption(context),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _featuredPill(BuildContext context) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        decoration: BoxDecoration(
          color: AppColors.primaryLight,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.star_rounded,
                size: 13, color: AppColors.textPrimary),
            const SizedBox(width: 4),
            Text(
              'FEATURED',
              style: GoogleFonts.poppins(
                fontSize: Responsive.sp(context, 9.5),
                fontWeight: FontWeight.w700,
                letterSpacing: 0.8,
                color: AppColors.textPrimary,
              ),
            ),
          ],
        ),
      );

  Widget _caption(BuildContext context) {
    // Whichever of these the listing actually has — the feed leaves any of
    // them out, and an empty line reads as a broken card.
    final meta = [
      if ((event.eventDate ?? '').isNotEmpty) event.eventDate!,
      if (event.venue.isNotEmpty) event.venue,
    ].join('  •  ');

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          event.title,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: GoogleFonts.poppins(
            fontSize: Responsive.sp(context, 17),
            fontWeight: FontWeight.w600,
            height: 1.2,
            color: Colors.white,
          ),
        ),
        if (meta.isNotEmpty) ...[
          const SizedBox(height: 4),
          Text(
            meta,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: GoogleFonts.poppins(
              fontSize: Responsive.sp(context, 11.5),
              color: Colors.white.withOpacity(0.85),
            ),
          ),
        ],
      ],
    );
  }
}
