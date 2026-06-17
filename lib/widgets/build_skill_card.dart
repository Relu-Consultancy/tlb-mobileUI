import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../core/app_colors.dart';
import '../core/responsive.dart';
import '../models/event_model.dart';
import '../screens/class_detail_screen.dart';
import '../screens/event_detail_screen.dart';
import 'inquire_now_sheet.dart';

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
        } else if (ctaLabel == 'Check Availability') {
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
          // rounded thumbnail rather than the card's own edge. 18px below the
          // pinned CTA (universal card bottom gap).
          padding: const EdgeInsets.fromLTRB(10, 10, 10, 18),
          child: SizedBox(
            // Fixed inner height so the CTA can be pinned to the bottom.
            height: Responsive.h(context, 168, min: 156),
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

                // Right content — top group + CTA pinned to the bottom; 10px
                // gaps between the data rows.
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            event.title,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: GoogleFonts.poppins(
                              fontSize: Responsive.sp(context, 14),
                              fontWeight: FontWeight.w600,
                              color: AppColors.textPrimary,
                              height: 1.25,
                            ),
                          ),
                          const SizedBox(height: 10),

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

                          // Rating + reviews
                          if (event.rating != null) ...[
                            const SizedBox(height: 10),
                            Row(
                              children: [
                                const Icon(Icons.star_rounded, size: 13, color: AppColors.starAmber),
                                const SizedBox(width: 3),
                                Text(
                                  event.rating!.toStringAsFixed(1),
                                  style: GoogleFonts.poppins(
                                    fontSize: Responsive.sp(context, 11),
                                    fontWeight: FontWeight.w500,
                                    color: AppColors.textPrimary,
                                  ),
                                ),
                                if ((event.reviewCount ?? '').isNotEmpty) ...[
                                  const SizedBox(width: 3),
                                  Text(
                                    event.reviewCount!,
                                    style: GoogleFonts.poppins(
                                      fontSize: Responsive.sp(context, 10.5),
                                      color: AppColors.textSecondary,
                                    ),
                                  ),
                                ],
                              ],
                            ),
                          ],

                          // Tag chip
                          if ((event.tag ?? '').isNotEmpty) ...[
                            const SizedBox(height: 10),
                            Align(
                              alignment: Alignment.centerLeft,
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFFCE7F3),
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Text(
                                  event.tag!,
                                  style: GoogleFonts.poppins(
                                    fontSize: Responsive.sp(context, 10.5),
                                    fontWeight: FontWeight.w500,
                                    color: const Color(0xFFBE185D),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),

                      // CTA pinned to the bottom of the card.
                      Material(
                        color: AppColors.primaryLight,
                        borderRadius: BorderRadius.circular(22),
                        child: InkWell(
                          borderRadius: BorderRadius.circular(22),
                          onTap: () {
                            if (ctaLabel == 'Send Enquiry') {
                              showInquireNow(context, listingId: event.id);
                            } else if (ctaLabel == 'Check Availability') {
                              Navigator.push(context, MaterialPageRoute(builder: (_) => ClassDetailScreen(event: event)));
                            } else {
                              Navigator.push(context, MaterialPageRoute(builder: (_) => EventDetailScreen(event: event)));
                            }
                          },
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 9),
                            child: Text(
                              ctaLabel,
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
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
