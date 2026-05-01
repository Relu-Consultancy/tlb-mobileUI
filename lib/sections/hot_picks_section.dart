import '../core/responsive.dart';
import 'package:flutter/material.dart';
import '../widgets/section_divider_widget.dart';
import 'package:google_fonts/google_fonts.dart';
import '../data/dummy_data.dart';
import '../screens/event_detail_screen.dart';

class HotPicksSection extends StatelessWidget {
  const HotPicksSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SectionDividerWidget(title: 'Hot Picks'),
        SizedBox(
          height: Responsive.h(context, 420, min: 370),
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            clipBehavior: Clip.hardEdge,
            padding: const EdgeInsets.only(left: 16, right: 8),
            itemCount: DummyData.hotPicks.length,
            addAutomaticKeepAlives: false,
            itemBuilder: (context, index) {
              final event = DummyData.hotPicks[index];
              return Container(
                width: Responsive.cardWidth(context, fraction: 0.65, max: 260),
                margin: const EdgeInsets.only(right: 16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.grey.shade200),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Top Image Area
                    Stack(
                      children: [
                        ClipRRect(
                          borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                          child: Image.asset(
                            event.imagePath,
                            height: Responsive.h(context, 190, min: 150),
                            width: double.infinity,
                            fit: BoxFit.cover,
                          ),
                        ),
                        // Top-left floating badge (Filling Fast / Bestseller)
                        if (event.tag != null)
                          Positioned(
                            top: 0,
                            left: 0,
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                              decoration: BoxDecoration(
                                borderRadius: const BorderRadius.only(
                                  topLeft: Radius.circular(16),
                                  bottomRight: Radius.circular(16),
                                ),
                                gradient: LinearGradient(
                                  colors: event.tag?.toLowerCase() == 'filling fast' 
                                      ? [const Color(0xFF5C79E8), const Color(0xFF384B99)] // Blue gradient
                                      : [const Color(0xFFE85C79), const Color(0xFF99384B)], // Red gradient
                                ),
                              ),
                              child: Text(
                                event.tag ?? 'Filling Fast',
                                style: GoogleFonts.poppins(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ),
                      ],
                    ),
                    
                    // Bottom Content Area (Flex)
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.all(12),
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
                                    fontSize: 15,
                                    fontWeight: FontWeight.bold,
                                    color: const Color(0xFF1A1A2E),
                                  ),
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                const SizedBox(height: 8),
                                
                                // Age Range Row
                                Row(
                                  children: [
                                    const Icon(Icons.people_outline, size: 14, color: Colors.grey),
                                    const SizedBox(width: 6),
                                    Text(
                                      '3-5 Yrs', // Dummy age range
                                      style: GoogleFonts.poppins(fontSize: 12, color: Colors.grey),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 6),
                                
                                // Reviews Row
                                Row(
                                  children: [
                                    Row(
                                      children: List.generate(
                                        5,
                                        (index) => const Icon(Icons.star, size: 12, color: Colors.amber),
                                      ),
                                    ),
                                    const SizedBox(width: 6),
                                    Text(
                                      event.reviewCount ?? '3.5k reviews',
                                      style: GoogleFonts.poppins(fontSize: 12, color: Colors.grey),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 6),
                                
                                // Venue Row
                                Row(
                                  children: [
                                    const Icon(Icons.location_on_outlined, size: 14, color: Colors.grey),
                                    const SizedBox(width: 6),
                                    Expanded(
                                      child: Text(
                                        event.venue,
                                        style: GoogleFonts.poppins(fontSize: 12, color: Colors.grey),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                            
                            // Bottom row with Price and Book Now button
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Expanded(
                                  child: RichText(
                                    text: TextSpan(
                                      children: [
                                        TextSpan(
                                          text: event.price != null ? '₹${event.price!.toInt()}' : '₹5000',
                                          style: GoogleFonts.poppins(
                                            fontSize: 16,
                                            fontWeight: FontWeight.bold,
                                            color: const Color(0xFF1A1A2E),
                                          ),
                                        ),
                                        TextSpan(
                                          text: ' / child',
                                          style: GoogleFonts.poppins(
                                            fontSize: 12,
                                            color: Colors.grey,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                                SizedBox(
                                  width: Responsive.w(context, 100, min: 90), 
                                  height: Responsive.h(context, 34, min: 30),
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
                                      padding: const EdgeInsets.symmetric(horizontal: 8),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(20),
                                      ),
                                    ),
                                    child: Text(
                                      'Book Now',
                                      style: GoogleFonts.poppins(
                                        fontSize: Responsive.sp(context, 11),
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
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
