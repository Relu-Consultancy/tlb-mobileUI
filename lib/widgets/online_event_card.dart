import 'package:flutter/material.dart';
import '../core/responsive.dart';
import 'package:google_fonts/google_fonts.dart';
import '../core/app_colors.dart';
import '../models/event_model.dart';
import 'listing_meta_rows.dart';
import '../screens/event_detail_screen.dart';

class OnlineEventCard extends StatelessWidget {
  final EventModel event;
  final double width;

  const OnlineEventCard({
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
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: Colors.black.withOpacity(0.1), width: 0.7),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.06),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisSize: MainAxisSize.max,
          children: [
            // Image fills the extra card height; the content below keeps a
            // fixed 20px gap to the card bottom.
            Expanded(
              child: ClipRRect(
                borderRadius: const BorderRadius.vertical(top: Radius.circular(18)),
                child: Image.asset(
                  event.imagePath,
                  width: double.infinity,
                  height: double.infinity,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => Container(
                    color: AppColors.primary.withOpacity(0.2),
                    child: const Center(child: Icon(Icons.event, size: 40)),
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(14, 12, 14, 18),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          event.title,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: GoogleFonts.poppins(
                            fontSize: Responsive.sp(context, 16),
                            fontWeight: FontWeight.w600,
                            color: AppColors.textPrimary,
                          ),
                        ),
                      ),
                      if ((event.tag ?? '').isNotEmpty) ...[
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 11,
                            vertical: 5,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(0xFFE0F2FE),
                            borderRadius: BorderRadius.circular(9),
                          ),
                          child: Text(
                            event.tag!,
                            style: GoogleFonts.poppins(
                              fontSize: Responsive.sp(context, 11),
                              fontWeight: FontWeight.w600,
                              color: const Color(0xFF0284C7),
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 8),
                  // Two-column meta: Age + Date·Time left, Location + Distance right.
                  ListingMetaRows(
                    event: event,
                    showLocation: true,
                    twoColumn: true,
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
