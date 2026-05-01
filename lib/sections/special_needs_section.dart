import '../core/responsive.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../widgets/wishlist_button.dart';
import '../widgets/section_divider_widget.dart';
import '../data/dummy_data.dart';
import '../screens/event_detail_screen.dart';

class SpecialNeedsSection extends StatelessWidget {
  const SpecialNeedsSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SectionDividerWidget(title: 'Special Needs Kids'),
        SizedBox(
          height: Responsive.h(context, 200, min: 160),
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            clipBehavior: Clip.hardEdge,
            padding: const EdgeInsets.only(left: 16, right: 8),
            itemCount: DummyData.specialNeeds.length > 1 
                ? DummyData.specialNeeds.length 
                : 3, // Duplicate for scroll test if only 1
            itemBuilder: (context, index) {
              final modelIndex = index % DummyData.specialNeeds.length;
              final event = DummyData.specialNeeds[modelIndex];
              return Container(
                width: Responsive.cardWidth(context, fraction: 0.85, max: 340),
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
                child: Row(
                  children: [
                    // Left Image Area
                    SizedBox(
                      width: Responsive.w(context, 140, min: 120),
                      child: Stack(
                        children: [
                          ClipRRect(
                            borderRadius: const BorderRadius.horizontal(left: Radius.circular(16)),
                            child: Image.asset(
                              event.imagePath,
                              height: double.infinity,
                              width: double.infinity,
                              fit: BoxFit.cover,
                            ),
                          ),
                          // Heart Icon
                          Positioned(
                            top: 8,
                            right: 8,
                            child: WishlistButton(event: event, containerSize: 28, showShadow: true),
                          ),
                          // Bottom black banner
                          if (event.tag != null)
                            Positioned(
                              bottom: 0,
                              left: 0,
                              right: 0,
                              child: Container(
                                color: Colors.black.withOpacity(0.8),
                                padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
                                child: Text(
                                  event.tag!,
                                  style: GoogleFonts.poppins(
                                    fontSize: 10,
                                    color: Colors.white,
                                    fontWeight: FontWeight.w500,
                                  ),
                                  textAlign: TextAlign.center,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                    
                    // Right Content Area
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
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
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                    color: const Color(0xFF1A1A2E),
                                  ),
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
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
                                        fontSize: 11,
                                        color: Colors.grey,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  'Price - ₹${event.price?.toInt() ?? 200}',
                                  style: GoogleFonts.poppins(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w700,
                                    color: const Color(0xFF1A1A2E),
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ],
                            ),
                            
                            // Button row
                            SizedBox(
                              width: double.infinity,
                              height: Responsive.h(context, 38, min: 32),
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
                                  'Shop Now',
                                  style: GoogleFonts.poppins(
                                    fontSize: Responsive.sp(context, 12),
                                    fontWeight: FontWeight.w600,
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
