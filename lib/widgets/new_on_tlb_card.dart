import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../core/app_colors.dart';
import '../core/responsive.dart';
import '../models/event_model.dart';
import 'listing_meta_rows.dart';
import '../screens/class_detail_screen.dart';
import '../screens/event_detail_screen.dart';

class NewOnTlbCard extends StatelessWidget {
  final EventModel event;
  final String buttonLabel;

  const NewOnTlbCard({
    super.key,
    required this.event,
    this.buttonLabel = 'Book Now',
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        if (buttonLabel == 'Send Enquiry') {
          Navigator.push(context, MaterialPageRoute(builder: (_) => ClassDetailScreen(event: event, buttonLabel: buttonLabel)));
        } else if (buttonLabel == 'Check Availability' || buttonLabel == 'View Details') {
          Navigator.push(context, MaterialPageRoute(builder: (_) => ClassDetailScreen(event: event)));
        } else {
          Navigator.push(context, MaterialPageRoute(builder: (_) => EventDetailScreen(event: event)));
        }
      },
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.black.withOpacity(0.1), width: 0.7),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.07),
              blurRadius: 14,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              ClipRRect(
                borderRadius: const BorderRadius.horizontal(
                  left: Radius.circular(20),
                ),
                child: Image.asset(
                  event.imagePath,
                  width: Responsive.w(context, 155, min: 130),
                  height: double.infinity,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => Container(
                    width: Responsive.w(context, 155, min: 130),
                    color: AppColors.primary.withOpacity(0.2),
                    child: const Icon(Icons.event, size: 44),
                  ),
                ),
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 18, 16, 14),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    // The CTA used to close this column; without it the content
                    // sat at the top with ~80pt blank underneath. Spreading the
                    // blocks lets the data occupy the card's full height.
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
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
                      Row(
                        children: [
                          const Icon(
                            Icons.location_on_outlined,
                            size: 15,
                            color: AppColors.textSecondary,
                          ),
                          const SizedBox(width: 4),
                          Expanded(
                            child: Text(
                              event.venue,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: GoogleFonts.poppins(
                                fontSize: Responsive.sp(context, 12.5),
                                color: AppColors.textSecondary,
                              ),
                            ),
                          ),
                        ],
                      ),
                      // Age Group · Date & Time · Distance (mock display data)
                      ListingMetaRows(
                        event: event,
                        iconSize: 14,
                        fontSize: 12,
                        rowGap: 6,
                      ),
                    ],
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
