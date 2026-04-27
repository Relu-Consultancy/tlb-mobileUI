import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../core/app_colors.dart';
import '../models/event_model.dart';
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
          mainAxisSize: MainAxisSize.min,
          children: [
            // Image + pink overlay tag at top-center
            ClipRRect(
              borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
              child: Stack(
                children: [
                  AspectRatio(
                    aspectRatio: 1.0, // square image area
                    child: Image.asset(
                      event.imagePath,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => Container(
                        color: AppColors.primary.withOpacity(0.2),
                        child: const Icon(Icons.event, size: 48),
                      ),
                    ),
                  ),
                  if ((event.tag ?? '').isNotEmpty)
                    Positioned(
                      top: 0,
                      left: 0,
                      right: 0,
                      child: Align(
                        alignment: Alignment.topCenter,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 18,
                            vertical: 6,
                          ),
                          decoration: const BoxDecoration(
                            color: Color(0xFFEC407A), // Pink tag
                            borderRadius: BorderRadius.only(
                              bottomLeft: Radius.circular(14),
                              bottomRight: Radius.circular(14),
                            ),
                          ),
                          child: Text(
                            event.tag!,
                            style: GoogleFonts.poppins(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
            // Content
            Padding(
              padding: const EdgeInsets.fromLTRB(14, 12, 14, 14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    event.title,
                    style: GoogleFonts.poppins(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
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
                              fontSize: 11.5,
                              color: AppColors.textSecondary,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
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
                            fontSize: 11.5,
                            color: AppColors.textSecondary,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      Material(
                        color: const Color(0xFFFFCC00),
                        borderRadius: BorderRadius.circular(22),
                        child: InkWell(
                          borderRadius: BorderRadius.circular(22),
                          onTap: () {
                            if (buttonLabel == 'Send Enquiry') {
                              showInquireNow(context);
                            } else if (buttonLabel == 'Check Availability') {
                              Navigator.push(context, MaterialPageRoute(builder: (_) => ClassDetailScreen(event: event)));
                            } else {
                              Navigator.push(context, MaterialPageRoute(builder: (_) => EventDetailScreen(event: event)));
                            }
                          },
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 18,
                              vertical: 7,
                            ),
                            child: Text(
                              buttonLabel,
                              style: GoogleFonts.poppins(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: const Color(0xFF1A1A2E),
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
