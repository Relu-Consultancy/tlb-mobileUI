import 'package:flutter/material.dart';
import '../core/responsive.dart';
import 'package:google_fonts/google_fonts.dart';
import '../core/app_colors.dart';
import '../models/event_model.dart';
import '../screens/event_detail_screen.dart';

class WeekendEventCard extends StatelessWidget {
  final EventModel event;
  final double width;

  const WeekendEventCard({
    super.key,
    required this.event,
    this.width = 330,
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
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.black.withOpacity(0.5), width: 0.7),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.06),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: const BorderRadius.horizontal(
                left: Radius.circular(16),
              ),
              child: Image.asset(
                event.imagePath,
                width: width * 0.42,
                height: double.infinity,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => Container(
                  width: width * 0.42,
                  color: AppColors.primary.withOpacity(0.2),
                  child: const Icon(Icons.event, size: 40),
                ),
              ),
            ),
            Expanded(
              child: Padding(
                // 20px gap below the CTA button (card bottom padding).
                padding: const EdgeInsets.fromLTRB(14, 14, 12, 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
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
                    const SizedBox(height: 10),
                    if (event.eventDate != null)
                      _IconLine(
                        icon: Icons.calendar_today_outlined,
                        text: event.eventTime != null
                            ? '${event.eventDate} | ${event.eventTime}'
                            : event.eventDate!,
                      ),
                    if (event.venue.isNotEmpty) ...[
                      const SizedBox(height: 8),
                      _IconLine(
                        icon: Icons.location_on_outlined,
                        text: event.venue,
                      ),
                    ],
                    const Spacer(),
                    _BookNowButton(event: event),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _IconLine extends StatelessWidget {
  final IconData icon;
  final String text;

  const _IconLine({required this.icon, required this.text});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 14, color: AppColors.textSecondary),
        const SizedBox(width: 6),
        Expanded(
          child: Text(
            text,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: GoogleFonts.poppins(
              fontSize: Responsive.sp(context, 11.5),
              color: AppColors.textSecondary,
              height: 1.2,
            ),
          ),
        ),
      ],
    );
  }
}

class _BookNowButton extends StatelessWidget {
  final EventModel event;

  const _BookNowButton({required this.event});

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Material(
        color: const Color(0xFFFFB902),
        borderRadius: BorderRadius.circular(24),
        child: InkWell(
          borderRadius: BorderRadius.circular(24),
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => EventDetailScreen(event: event)),
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 9),
            child: Text(
              'Book Now',
              style: GoogleFonts.poppins(
                fontSize: Responsive.sp(context, 13),
                fontWeight: FontWeight.w500,
                color: const Color(0xFF1A1A2E),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
