import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../core/responsive.dart';
import '../core/saved_events_state.dart';
import '../models/event_model.dart';
import 'event_detail_screen.dart';

class SavedEventsScreen extends StatelessWidget {
  const SavedEventsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF1A1A2E)),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Saved Events',
          style: GoogleFonts.poppins(
            fontSize: 16,
            fontWeight: FontWeight.w700,
            color: const Color(0xFF1A1A2E),
          ),
        ),
      ),
      body: ValueListenableBuilder<List<EventModel>>(
        valueListenable: SavedEventsState.savedEvents,
        builder: (context, saved, _) {
          if (saved.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.bookmark_border,
                      size: 80, color: Colors.grey.shade300),
                  const SizedBox(height: 16),
                  Text(
                    'No saved events yet',
                    style: GoogleFonts.poppins(
                      fontSize: Responsive.sp(context, 18),
                      fontWeight: FontWeight.w600,
                      color: Colors.grey.shade400,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Tap the bookmark icon on any event\nto save it here',
                    textAlign: TextAlign.center,
                    style: GoogleFonts.poppins(
                      fontSize: 13,
                      color: Colors.grey.shade400,
                    ),
                  ),
                ],
              ),
            );
          }

          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: saved.length,
            separatorBuilder: (_, __) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              final event = saved[index];
              return GestureDetector(
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (_) => EventDetailScreen(event: event)),
                ),
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(14),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      // Image
                      ClipRRect(
                        borderRadius: const BorderRadius.horizontal(
                            left: Radius.circular(14)),
                        child: Image.asset(
                          event.imagePath,
                          width: Responsive.w(context, 100, min: 75),
                          height: Responsive.h(context, 90, min: 70),
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => Container(
                            width: Responsive.w(context, 100, min: 75),
                            height: Responsive.h(context, 90, min: 70),
                            color: const Color(0xFFFFF0C8),
                            child: const Icon(Icons.event,
                                color: Color(0xFFFFB902)),
                          ),
                        ),
                      ),
                      // Content
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 10),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                event.title,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: GoogleFonts.poppins(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                  color: const Color(0xFF1A1A2E),
                                ),
                              ),
                              const SizedBox(height: 2),
                              Row(
                                children: [
                                  const Icon(Icons.location_on_outlined,
                                      size: 13, color: Colors.grey),
                                  const SizedBox(width: 2),
                                  Expanded(
                                    child: Text(
                                      event.venue,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: GoogleFonts.poppins(
                                          fontSize: 11, color: Colors.grey),
                                    ),
                                  ),
                                ],
                              ),
                              if (event.price != null) ...[
                                const SizedBox(height: 4),
                                Text(
                                  '₹${event.price!.toInt()}',
                                  style: GoogleFonts.poppins(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w700,
                                    color: const Color(0xFFFFB902),
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ),
                      ),
                      // Remove button
                      IconButton(
                        icon: const Icon(Icons.bookmark,
                            color: Color(0xFFFFB902), size: 24),
                        onPressed: () => SavedEventsState.remove(event),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
