import '../core/responsive.dart';
import 'package:flutter/material.dart';
import '../widgets/section_divider_widget.dart';
import 'package:google_fonts/google_fonts.dart';
import '../data/dummy_data.dart';
import '../screens/event_detail_screen.dart';

class FamilyFeelsSection extends StatelessWidget {
  const FamilyFeelsSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SectionDividerWidget(title: 'Family Feels'),
        SizedBox(
          height: Responsive.h(context, 200, min: 170),
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            clipBehavior: Clip.hardEdge,
            padding: const EdgeInsets.only(left: 16, right: 8),
            itemCount: DummyData.familyFeels.length,
            addAutomaticKeepAlives: false,
            itemBuilder: (context, index) {
              final event = DummyData.familyFeels[index];
              return Container(
                width: Responsive.cardWidth(context, fraction: 0.92, max: 380),
                margin: const EdgeInsets.only(right: 16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.grey.shade200),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.04),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    // Left Image Area
                    Padding(
                      padding: const EdgeInsets.all(12.0),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(16),
                        child: Image.asset(
                          event.imagePath,
                          width: Responsive.w(context, 130, min: 110),
                          height: double.infinity,
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                    
                    // Right Content Area
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(0, 12, 12, 12),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  event.title,
                                  style: GoogleFonts.poppins(
                                    fontSize: Responsive.sp(context, 14),
                                    fontWeight: FontWeight.w500,
                                    color: const Color(0xFF1A1A2E),
                                  ),
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                const SizedBox(height: 6),
                                
                                // Location Row
                                Row(
                                  children: [
                                    const Icon(Icons.location_on_outlined, size: 14, color: Colors.grey),
                                    const SizedBox(width: 4),
                                    Expanded(
                                      child: Text(
                                        event.venue,
                                        style: GoogleFonts.poppins(
                                          fontSize: Responsive.sp(context, 12),
                                          color: Colors.grey,
                                          fontWeight: FontWeight.w500,
                                        ),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 6),
                                
                                // Stars + review count
                                Row(
                                  children: [
                                    const Icon(Icons.star, size: 14, color: Colors.amber),
                                    const SizedBox(width: 4),
                                    Text(
                                      event.reviewCount ?? '3.5k reviews',
                                      style: GoogleFonts.poppins(
                                        fontSize: Responsive.sp(context, 12),
                                        color: Colors.grey,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 6),
                                
                                // Pricing Text
                                Text(
                                  'Starting from ₹${event.price?.toInt() ?? 200}',
                                  style: GoogleFonts.poppins(
                                    fontSize: Responsive.sp(context, 12),
                                    fontWeight: FontWeight.w500,
                                    color: const Color(0xFF4A4A68),
                                    decoration: TextDecoration.underline,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ],
                            ),
                            
                            // Button row
                            SizedBox(
                              width: double.infinity,
                              height: Responsive.h(context, 36, min: 32),
                              child: ElevatedButton(
                                onPressed: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) => EventDetailScreen(event: event),
                                    ),
                                  );
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFFFFCC00),
                                  foregroundColor: const Color(0xFF1A1A2E),
                                  elevation: 0,
                                  padding: EdgeInsets.zero,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                ),
                                child: Text(
                                  'Book Now',
                                  style: GoogleFonts.poppins(
                                    fontSize: Responsive.sp(context, 12),
                                    fontWeight: FontWeight.w500,
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
              );
            },
          ),
        ),
      ],
    );
  }
}
