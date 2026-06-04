import '../core/responsive.dart';
import 'package:flutter/material.dart';
import '../widgets/section_divider_widget.dart';
import 'package:google_fonts/google_fonts.dart';
import '../data/dummy_data.dart';
import '../screens/event_detail_screen.dart';

class DiscoverNearYouSection extends StatelessWidget {
  const DiscoverNearYouSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SectionDividerWidget(
          title: 'Discover Near You',
          fontSize: 17,
          fontWeight: FontWeight.w600,
          textColor: Color(0xFF1A1A2E), // dark navy
        ),
        SizedBox(
          height: Responsive.h(context, 420, min: 370),
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            clipBehavior: Clip.hardEdge,
            padding: const EdgeInsets.only(left: 16, right: 8),
            itemCount: DummyData.discoverNearYou.length,
            addAutomaticKeepAlives: false,
            itemBuilder: (context, index) {
              final event = DummyData.discoverNearYou[index];
              return Container(
                width: Responsive.cardWidth(context, fraction: 0.82, max: 340),
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
                    // Top Image Area — Expanded so the image dominates the
                    // card; flush to the card edges with a distance band at
                    // the bottom edge.
                    Expanded(
                      child: Stack(
                        children: [
                          Positioned.fill(
                            child: ClipRRect(
                              borderRadius: const BorderRadius.vertical(
                                top: Radius.circular(16),
                              ),
                              child: Image.asset(
                                event.imagePath,
                                width: double.infinity,
                                fit: BoxFit.cover,
                              ),
                            ),
                          ),
                          // Pink gradient distance band at the bottom
                          Positioned(
                            bottom: 0,
                            left: 0,
                            right: 0,
                            child: Container(
                              padding: const EdgeInsets.symmetric(vertical: 8),
                              decoration: BoxDecoration(
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
                                  event.tag ?? '0.5 km away', // distance
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

                    // Bottom Content Area — natural height.
                    Padding(
                      padding: const EdgeInsets.all(12),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Title & Badge row
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                                child: Text(
                                  event.title,
                                  style: GoogleFonts.poppins(
                                    fontSize: Responsive.sp(context, 15),
                                    fontWeight: FontWeight.w500,
                                    color: const Color(0xFF1A1A2E),
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              const SizedBox(width: 6),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 8, vertical: 4),
                                decoration: BoxDecoration(
                                  color: Colors.grey.shade200,
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Text(
                                  'Outdoor Play',
                                  style: GoogleFonts.poppins(
                                    fontSize: Responsive.sp(context, 10),
                                    fontWeight: FontWeight.w500,
                                    color: const Color(0xFF1A1A2E),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 6),

                          // Venue Row
                          Row(
                            children: [
                              const Icon(Icons.location_on_outlined,
                                  size: 14, color: Colors.grey),
                              const SizedBox(width: 4),
                              Expanded(
                                child: Text(
                                  event.venue,
                                  style: GoogleFonts.poppins(
                                      fontSize: Responsive.sp(context, 12),
                                      color: Colors.grey),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
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
                                  (index) => const Icon(Icons.star,
                                      size: 14, color: Colors.amber),
                                ),
                              ),
                              const SizedBox(width: 6),
                              Text(
                                event.reviewCount ?? '3.5k reviews',
                                style: GoogleFonts.poppins(
                                    fontSize: Responsive.sp(context, 12),
                                    color: Colors.grey),
                              ),
                            ],
                          ),
                          const SizedBox(height: 6),

                          // Description
                          RichText(
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            text: TextSpan(
                              children: [
                                TextSpan(
                                  text: 'Description – ',
                                  style: GoogleFonts.poppins(
                                    fontSize: Responsive.sp(context, 12),
                                    fontWeight: FontWeight.w500,
                                    color: const Color(0xFF1A1A2E),
                                  ),
                                ),
                                TextSpan(
                                  text: event.description ??
                                      'Slides, Splash Zone, Mini zipline & shaded picnic areas.',
                                  style: GoogleFonts.poppins(
                                    fontSize: Responsive.sp(context, 12),
                                    color: Colors.grey.shade600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 12),

                          // Book Now button (bottom-left)
                          SizedBox(
                            width: Responsive.w(context, 140, min: 120),
                            height: Responsive.h(context, 38, min: 32),
                            child: ElevatedButton(
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) =>
                                        EventDetailScreen(event: event),
                                  ),
                                );
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFFFFCC00),
                                foregroundColor: const Color(0xFF1A1A2E),
                                elevation: 0,
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
