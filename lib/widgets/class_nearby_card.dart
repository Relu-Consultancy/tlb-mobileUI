import 'package:flutter/material.dart';
import '../core/responsive.dart';
import 'package:google_fonts/google_fonts.dart';
import '../core/app_colors.dart';
import '../models/event_model.dart';
import '../screens/class_detail_screen.dart';
import '../screens/event_detail_screen.dart';
import 'inquire_now_sheet.dart';

class ClassNearbyCard extends StatelessWidget {
  final EventModel event;
  final double width;
  final String? buttonLabel;
  final Color? tagColor;
  final VoidCallback? onTap;

  const ClassNearbyCard({
    super.key,
    required this.event,
    this.width = 310,
    this.buttonLabel = 'Join Now',
    this.tagColor,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        if (onTap != null) {
          onTap!();
        } else if (buttonLabel == 'Send Enquiry') {
          Navigator.push(context, MaterialPageRoute(builder: (_) => ClassDetailScreen(event: event, buttonLabel: buttonLabel!)));
        } else if (buttonLabel == 'Check Availability') {
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
              color: Colors.black.withOpacity(0.07),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            // Image with km-away pill at bottom-center
            ClipRRect(
              borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
              child: Stack(
                children: [
                  AspectRatio(
                    aspectRatio: 1.6,
                    child: Image.asset(
                      event.imagePath,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => Container(
                        color: AppColors.primary.withOpacity(0.15),
                        child: const Icon(Icons.place, size: 48, color: AppColors.textSecondary),
                      ),
                    ),
                  ),
                  if ((event.tag ?? '').isNotEmpty)
                    Positioned(
                      bottom: 10,
                      left: 12,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
                        decoration: BoxDecoration(
                          color: tagColor ?? Colors.black.withOpacity(0.58),
                          borderRadius: BorderRadius.circular(30),
                        ),
                        child: Text(
                          event.tag!,
                          style: GoogleFonts.poppins(
                            fontSize: Responsive.sp(context, 11.5),
                            fontWeight: FontWeight.w500,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),

            // Content
            Padding(
              // 18px gap below the CTA button (card bottom padding).
              padding: const EdgeInsets.fromLTRB(14, 12, 14, 18),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Title + age chip
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Text(
                          event.title,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: GoogleFonts.poppins(
                            fontSize: Responsive.sp(context, 15),
                            fontWeight: FontWeight.w500,
                            color: AppColors.textPrimary,
                            height: 1.2,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),

                  // Venue
                  Row(
                    children: [
                      const Icon(Icons.location_on_outlined, size: 13, color: AppColors.textSecondary),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          event.venue,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: GoogleFonts.poppins(
                            fontSize: Responsive.sp(context, 11.5),
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),

                  // Join Now button
                  if (buttonLabel != null)
                    Material(
                      color: AppColors.primaryLight,
                      borderRadius: BorderRadius.circular(24),
                      child: InkWell(
                        borderRadius: BorderRadius.circular(24),
                        onTap: () {
                          if (onTap != null) {
                            onTap!();
                          } else if (buttonLabel == 'Send Enquiry') {
                            showInquireNow(context, listingId: event.id);
                          } else if (buttonLabel == 'Check Availability') {
                            Navigator.push(context, MaterialPageRoute(builder: (_) => ClassDetailScreen(event: event)));
                          } else {
                            Navigator.push(context, MaterialPageRoute(builder: (_) => EventDetailScreen(event: event)));
                          }
                        },
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                          child: Text(
                            buttonLabel!,
                            style: GoogleFonts.poppins(
                              fontSize: Responsive.sp(context, 13),
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
    );
  }
}
