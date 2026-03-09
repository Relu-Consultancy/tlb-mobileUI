import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../core/responsive.dart';
import '../core/saved_events_state.dart';
import '../models/event_model.dart';

class HorizontalCardWidget extends StatelessWidget {
  final String imagePath;
  final String distance;
  final String title;
  final String location;
  final String reviewCount;
  final String description;
  final String buttonText;
  final String? badgeText;
  final VoidCallback? onTapBtn;
  final EventModel? event;

  const HorizontalCardWidget({
    super.key,
    required this.imagePath,
    required this.distance,
    required this.title,
    required this.location,
    required this.reviewCount,
    required this.description,
    required this.buttonText,
    this.badgeText,
    this.onTapBtn,
    this.event,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: MediaQuery.of(context).size.width * 0.70 > 280 ? 280 : MediaQuery.of(context).size.width * 0.70,
      margin: const EdgeInsets.only(right: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Image Area with gradient overlay
          Stack(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: Image.asset(
                  imagePath,
                  height: Responsive.h(context, 180, min: 140),
                  width: double.infinity,
                  fit: BoxFit.cover,
                ),
              ),
              if (event != null)
                Positioned(
                  top: 8,
                  right: 8,
                  child: GestureDetector(
                    onTap: () => SavedEventsState.toggle(event!, context),
                    child: ValueListenableBuilder<List<EventModel>>(
                      valueListenable: SavedEventsState.savedEvents,
                      builder: (context, _, __) {
                        final isSaved = SavedEventsState.isSaved(event!);
                        return Container(
                          padding: const EdgeInsets.all(6),
                          decoration: BoxDecoration(
                            color: Colors.black.withOpacity(0.35),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            isSaved ? Icons.favorite : Icons.favorite_border,
                            size: 18,
                            color: isSaved ? const Color(0xFFFFB902) : Colors.white,
                          ),
                        );
                      },
                    ),
                  ),
                ),
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  decoration: BoxDecoration(
                    borderRadius: const BorderRadius.vertical(bottom: Radius.circular(16)),
                    gradient: LinearGradient(
                      colors: [
                        Colors.pink.shade100.withOpacity(0.9),
                        Colors.white.withOpacity(0.9),
                      ],
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                    ),
                  ),
                  child: Center(
                    child: Text(
                      distance,
                      style: GoogleFonts.poppins(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: const Color(0xFF1A1A2E),
                      ),
                    ),
                  ),
                ),
              )
            ],
          ),
          
          const SizedBox(height: 8),
          
          // Header Row (Title and Badge)
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  title,
                  style: GoogleFonts.poppins(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF1A1A2E),
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              if (badgeText != null) ...[
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade200,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    badgeText!,
                    style: GoogleFonts.poppins(
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                      color: const Color(0xFF1A1A2E),
                    ),
                  ),
                ),
              ]
            ],
          ),
          
          const SizedBox(height: 6),
          Row(
            children: [
              const Icon(Icons.location_on_outlined, size: 14, color: Colors.grey),
              const SizedBox(width: 4),
              Expanded(
                child: Text(
                  location,
                  style: GoogleFonts.poppins(fontSize: 12, color: Colors.grey),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 6),
          Row(
            children: [
              Row(
                children: List.generate(
                  5,
                  (index) => const Icon(Icons.star, size: 14, color: Colors.amber),
                ),
              ),
              const SizedBox(width: 8),
              Flexible(
                child: Text(
                  reviewCount,
                  style: GoogleFonts.poppins(fontSize: 12, color: Colors.grey),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 4),
          RichText(
             maxLines: 2,
             overflow: TextOverflow.ellipsis,
             text: TextSpan(
              children: [
                TextSpan(
                  text: 'Description - ',
                  style: GoogleFonts.poppins(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF1A1A2E),
                  ),
                ),
                TextSpan(
                  text: description,
                  style: GoogleFonts.poppins(
                    fontSize: 12,
                    color: Colors.grey.shade600,
                  ),
                ),
              ],
             ),
          ),
          
          const SizedBox(height: 8),
          SizedBox(
            width: double.infinity,
            height: Responsive.h(context, 44, min: 38),
            child: ElevatedButton(
              onPressed: onTapBtn ?? () {},
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFFFCC00),
                foregroundColor: const Color(0xFF1A1A2E),
                elevation: 0,
                minimumSize: const Size(0, 46),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
              ),
              child: Text(
                buttonText,
                style: GoogleFonts.poppins(
                  fontSize: Responsive.sp(context, 13),
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
