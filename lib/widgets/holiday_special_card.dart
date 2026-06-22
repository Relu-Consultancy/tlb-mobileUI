import 'package:flutter/material.dart';
import '../core/responsive.dart';
import 'package:google_fonts/google_fonts.dart';
import '../core/app_colors.dart';
import '../models/event_model.dart';
import 'animated_gradient_tag.dart';
import 'listing_meta_rows.dart';
import '../screens/class_detail_screen.dart';
import '../screens/event_detail_screen.dart';
import 'inquire_now_sheet.dart';

class HolidaySpecialCard extends StatelessWidget {
  final EventModel event;
  final double width;
  final String buttonLabel;

  const HolidaySpecialCard({
    super.key,
    required this.event,
    this.width = 280,
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
        width: width,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.black.withOpacity(0.1), width: 0.7),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.06),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.max,
          children: [
            // Image fills the extra card height (stretches downwards); the
            // content below keeps a fixed 20px gap to the card bottom.
            Expanded(
              child: ClipRRect(
                borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    Image.asset(
                      event.imagePath,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => Container(
                        color: AppColors.primary.withOpacity(0.2),
                        child: const Center(child: Icon(Icons.event, size: 48)),
                      ),
                    ),
                    if ((event.tag ?? '').isNotEmpty)
                      Positioned(
                        top: 0,
                        left: 0,
                        right: 0,
                        child: Align(
                        alignment: Alignment.topCenter,
                        // Animated red → purple gradient that slides very
                        // slowly and continuously (same idea as the TLB
                        // Signature tag); shape kept as the current top tag.
                        child: AnimatedGradientTag(
                          text: event.tag!,
                          fontSize: 12,
                          period: const Duration(seconds: 6),
                          showChrome: false,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 18,
                            vertical: 6,
                          ),
                          borderRadius: const BorderRadius.only(
                            bottomLeft: Radius.circular(14),
                            bottomRight: Radius.circular(14),
                          ),
                          gradientColors: const [
                            Color(0xFFE11D48), // red
                            Color(0xFF9333EA), // purple
                            Color(0xFFE11D48), // red (loops seamlessly)
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            // Content
            Padding(
              // 18px gap below the CTA button (card bottom padding).
              padding: const EdgeInsets.fromLTRB(14, 12, 14, 18),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    event.title,
                    style: GoogleFonts.poppins(
                      fontSize: Responsive.sp(context, 15),
                      fontWeight: FontWeight.w500,
                      color: AppColors.textPrimary,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 8),
                  if ((event.eventDate ?? '').isNotEmpty)
                    Row(
                      children: [
                        const Icon(
                          Icons.calendar_today_outlined,
                          size: 13,
                          color: AppColors.textSecondary,
                        ),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Text(
                            event.eventDate!,
                            style: GoogleFonts.poppins(
                              fontSize: Responsive.sp(context, 11.5),
                              color: AppColors.textSecondary,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  const SizedBox(height: 8),
                  // Age Group + Distance (Date already shown above; venue below)
                  ListingMetaRows(
                    event: event,
                    showDateTime: false,
                  ),
                  const SizedBox(height: 10),
                  // Bottom row: venue + Book Now button
                  Row(
                    children: [
                      const Icon(
                        Icons.location_on_outlined,
                        size: 13,
                        color: AppColors.textSecondary,
                      ),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          event.venue,
                          style: GoogleFonts.poppins(
                            fontSize: Responsive.sp(context, 11.5),
                            color: AppColors.textSecondary,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      Material(
                        color: AppColors.primaryLight,
                        borderRadius: BorderRadius.circular(22),
                        child: InkWell(
                          borderRadius: BorderRadius.circular(22),
                          onTap: () {
                            if (buttonLabel == 'Send Enquiry') {
                              showInquireNow(context, listingId: event.id);
                            } else if (buttonLabel == 'Check Availability' || buttonLabel == 'View Details') {
                              Navigator.push(context, MaterialPageRoute(builder: (_) => ClassDetailScreen(event: event)));
                            } else {
                              Navigator.push(context, MaterialPageRoute(builder: (_) => EventDetailScreen(event: event)));
                            }
                          },
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 7,
                            ),
                            child: Text(
                              buttonLabel,
                              style: GoogleFonts.poppins(
                                fontSize: Responsive.sp(context, 12),
                                fontWeight: FontWeight.w500,
                                color: AppColors.textPrimary,
                              ),
                            ),
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
