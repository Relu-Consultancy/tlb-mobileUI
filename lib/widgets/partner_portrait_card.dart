import 'package:flutter/material.dart';
import '../core/responsive.dart';
import 'package:google_fonts/google_fonts.dart';
import '../core/app_colors.dart';
import '../models/event_model.dart';
import 'listing_meta_rows.dart';
import '../screens/event_detail_screen.dart';

class PartnerPortraitCard extends StatelessWidget {
  final EventModel event;
  final double width;

  const PartnerPortraitCard({
    super.key,
    required this.event,
    this.width = 260,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => EventDetailScreen(event: event)),
      ),
      child: Container(
        width: width,
        margin: const EdgeInsets.only(right: 14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.black.withOpacity(0.1), width: 0.7),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.08),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Poster image — portrait aspect ratio so full design is visible
            ClipRRect(
              borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
              child: AspectRatio(
                aspectRatio: 0.78, // portrait poster
                child: Image.asset(
                  event.imagePath,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => Container(
                    color: Colors.indigo.shade100,
                    child: const Icon(Icons.image, color: Colors.white),
                  ),
                ),
              ),
            ),
            // Content block under the poster
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    event.title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.poppins(
                      fontSize: Responsive.sp(context, 16),
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    event.venue, // subtitle
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.poppins(
                      fontSize: Responsive.sp(context, 12.5),
                      color: AppColors.textSecondary,
                      height: 1.3,
                    ),
                  ),
                  const SizedBox(height: 10),
                  // Age Group · Date & Time · Distance, as the other section
                  // cards show. Location is off: on this card `venue` carries
                  // the partner's strapline, not a place.
                  ListingMetaRows(event: event),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
