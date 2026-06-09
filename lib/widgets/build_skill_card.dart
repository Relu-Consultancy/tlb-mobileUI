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
          border: Border.all(color: Colors.black.withOpacity(0.5), width: 0.7),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.07),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: IntrinsicHeight(
          child: Row(
            children: [
              // Left image
              ClipRRect(
                borderRadius: const BorderRadius.horizontal(left: Radius.circular(18)),
                child: Image.asset(
                  event.imagePath,
                  width: Responsive.w(context, 120, min: 96),
                  height: double.infinity,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => Container(
                    width: Responsive.w(context, 120, min: 96),
                    color: AppColors.primary.withOpacity(0.15),
                    child: const Icon(Icons.school_outlined, size: 40, color: AppColors.textSecondary),
                  ),
                ),
              ),

              // Right content
              Expanded(
                child: Padding(
                  // 20px gap below the CTA button (card bottom padding).
                  padding: const EdgeInsets.fromLTRB(12, 12, 12, 20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        event.title,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: GoogleFonts.poppins(
                          fontSize: Responsive.sp(context, 13.5),
                          fontWeight: FontWeight.w500,
                          color: AppColors.textPrimary,
                          height: 1.25,
                        ),
                      ),
                      const SizedBox(height: 8),

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
                      const SizedBox(height: 8),

                      // Rating + reviews
                      if (event.rating != null)
                        Row(
                          children: [
                            const Icon(Icons.star_rounded, size: 13, color: Color(0xFFFFB902)),
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

                      // Tag chip
                      if ((event.tag ?? '').isNotEmpty) ...[
                        const SizedBox(height: 8),
                        Container(
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
                      ],

                      const Spacer(),

                      // CTA
                      Material(
                        color: const Color(0xFFFFCC00),
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
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                            child: Text(
                              ctaLabel,
                              style: GoogleFonts.poppins(
                                fontSize: Responsive.sp(context, 12),
                                fontWeight: FontWeight.w500,
                                color: const Color(0xFF1A1A2E),
                              ),
                            ),
                          ),
                        ),
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
