import 'package:flutter/material.dart';
import '../core/responsive.dart';
import 'package:google_fonts/google_fonts.dart';
import '../core/app_colors.dart';
import '../models/event_model.dart';
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
                            fontSize: Responsive.sp(context, 14.5),
                            fontWeight: FontWeight.w500,
                            color: AppColors.textPrimary,
                          ),
                        ),
                      ),
                      if ((event.tag ?? '').isNotEmpty) ...[
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 14,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(0xFFE0F2FE),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Text(
                            event.tag!,
                            style: GoogleFonts.poppins(
                              fontSize: Responsive.sp(context, 12.5),
                              fontWeight: FontWeight.w600,
                              color: const Color(0xFF0284C7),
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                  if ((event.description ?? '').isNotEmpty) ...[
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        const Icon(
                          Icons.people_outline,
                          size: 14,
                          color: AppColors.textSecondary,
                        ),
                        const SizedBox(width: 6),
                        Flexible(
                          child: Text(
                            event.description!,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: GoogleFonts.poppins(
                              fontSize: Responsive.sp(context, 11.5),
                              color: AppColors.textDescription,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                  if ((event.eventDate ?? '').isNotEmpty) ...[
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        Icon(
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
                          ),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
