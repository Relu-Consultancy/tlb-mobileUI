import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../core/app_colors.dart';
import '../core/responsive.dart';
import '../models/event_model.dart';
import 'listing_meta_rows.dart';
import '../screens/class_detail_screen.dart';
import '../screens/event_detail_screen.dart';

class BuildSkillCard extends StatelessWidget {
  final EventModel event;
  final String ctaLabel;
  final double? width;

  const BuildSkillCard({
    super.key,
    required this.event,
    this.ctaLabel = 'Start Now',
    this.width,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        if (ctaLabel == 'Send Enquiry') {
          Navigator.push(context, MaterialPageRoute(builder: (_) => ClassDetailScreen(event: event, buttonLabel: ctaLabel)));
        } else if (ctaLabel == 'Check Availability' || ctaLabel == 'View Details') {
          Navigator.push(context, MaterialPageRoute(builder: (_) => ClassDetailScreen(event: event)));
        } else {
          Navigator.push(context, MaterialPageRoute(builder: (_) => EventDetailScreen(event: event)));
        }
      },
      child: Container(
        width: width ?? Responsive.w(context, 290, min: 240),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: Colors.black.withOpacity(0.1), width: 0.7),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.07),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Padding(
          // The card body inset — keeps the image (and content) inside the
          // card with a margin all around, so the image reads as a separate
          // rounded thumbnail rather than the card's own edge.
          padding: const EdgeInsets.fromLTRB(10, 10, 10, 14),
          // No fixed inner height: the card sits in a fixed-height rail, and a
          // shorter inner box left a blank strip along the card's bottom edge.
          // Filling the rail lets the thumbnail run the card's full height and
          // gives the text column the room to spread into.
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
                // Left image — separate, fully-rounded thumbnail inside the
                // card; widened so it covers more toward the right.
                ClipRRect(
                  borderRadius: BorderRadius.circular(14),
                  child: Image.asset(
                    event.imagePath,
                    width: Responsive.w(context, 150, min: 124),
                    height: double.infinity,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => Container(
                      width: Responsive.w(context, 150, min: 124),
                      color: AppColors.primary.withOpacity(0.15),
                      child: const Icon(Icons.school_outlined, size: 40, color: AppColors.textSecondary),
                    ),
                  ),
                ),
                const SizedBox(width: 12),

                // Right content. The CTA used to close this column; without it
                // the data sat at the top with the rest of the card blank, so
                // the blocks spread to fill the inner height instead.
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      Text(
                        event.title,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: GoogleFonts.poppins(
                          fontSize: Responsive.sp(context, 16),
                          fontWeight: FontWeight.w600,
                          color: AppColors.textPrimary,
                          height: 1.25,
                        ),
                      ),

                      // Venue
                      Row(
                        children: [
                          const Icon(Icons.location_on_outlined, size: 12, color: AppColors.textSecondary),
                          const SizedBox(width: 3),
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

                      // Age Group · Date & Time · Distance (mock display data)
                      ListingMetaRows(event: event),

                      // Tag chip
                      if ((event.tag ?? '').isNotEmpty)
                        Align(
                          alignment: Alignment.centerLeft,
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                            decoration: BoxDecoration(
                              color: const Color(0xFFFCE7F3),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              event.tag!,
                              style: GoogleFonts.poppins(
                                fontSize: Responsive.sp(context, 12.5),
                                fontWeight: FontWeight.w600,
                                color: const Color(0xFFBE185D),
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
