import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../core/responsive.dart';
import '../widgets/wishlist_button.dart';
import '../sections/home_header.dart';
import '../models/event_model.dart';
import '../sections/browse_by_categories_section.dart';
import '../sections/discover_near_you_section.dart';
import '../sections/family_feels_section.dart';
import '../sections/tlb_signature_section.dart';
import '../sections/app_footer.dart';
import '../data/dummy_data.dart';
import '../widgets/floating_navbar.dart';
import 'event_detail_screen.dart';

class CategoryEventsScreen extends StatefulWidget {
  final String initialCategory;

  const CategoryEventsScreen({
    super.key,
    required this.initialCategory,
  });

  @override
  State<CategoryEventsScreen> createState() => _CategoryEventsScreenState();
}

class _CategoryEventsScreenState extends State<CategoryEventsScreen> {
  late String _selectedCategory;

  final List<String> _categories = [
    'Home', // To navigate back
    'Events',
    'Classes',
    'Program',
    'Spaces',
    'Shop',
  ];

  /// Maps incoming category names (e.g. from PopularCategoriesSection) to a
  /// matching tab in this screen. Unknown names fall back to 'Events'.
  static String _mapCategoryToTab(String input) {
    final normalized = input.toLowerCase().trim();
    const mapping = {
      'creative arts': 'Classes',
      'creative art': 'Classes',        // Browse category
      'play & adventure': 'Events',
      'play &\nadventure': 'Events',
      'events': 'Events',
      'classes': 'Classes',
      'program': 'Program',
      'spaces': 'Spaces',
      'shop': 'Shop',
      'home': 'Home',
      'family time': 'Program',         // Browse category
      'seasonal special': 'Events',     // Browse category
      'science & stem': 'Classes',      // Browse category
      'health & wellness': 'Spaces',    // Browse category
    };
    return mapping[normalized] ?? 'Events';
  }

  /// Pre-built category → events map (avoids re-creating lists on every build).
  static final Map<String, List<EventModel>> _categoryEvents = {
    'Events': [...DummyData.categoryEventsExtra, ...DummyData.weekendSpecial],
    'Classes': [...DummyData.hotPicks, ...DummyData.familyFeels],
    'Program': [...DummyData.tlbSignature, ...DummyData.weekendSpecial],
    'Spaces': [...DummyData.discoverNearYou, ...DummyData.familyFeels],
    'Shop': [...DummyData.stealers, ...DummyData.specialNeeds],
  };

  List<EventModel> _getEventsForCategory(String category) {
    return _categoryEvents[category] ?? DummyData.categoryEventsExtra;
  }

  @override
  void initState() {
    super.initState();
    _selectedCategory = _mapCategoryToTab(widget.initialCategory);
  }

  int get _currentNavIndex {
    final idx = _categories.indexOf(_selectedCategory);
    return idx >= 0 ? idx : 1; // Default to Events if not found
  }

  void _onNavTapped(int index) {
    if (index == 0) {
      Navigator.popUntil(context, (route) => route.isFirst);
      return;
    }
    setState(() {
      _selectedCategory = _categories[index];
    });
  }

  @override
  Widget build(BuildContext context) {
    final safeBottom = MediaQuery.of(context).padding.bottom;

    return Scaffold(
      backgroundColor: const Color(0xFFFFF8EE),
      body: Stack(
        children: [
          Column(
            children: [
              // Reuse Home Header exactly as is
              const HomeHeader(),

              // Main Scrollable Content
              Expanded(
                child: SingleChildScrollView(
                  child: Padding(
                    padding: EdgeInsets.only(bottom: 120 + safeBottom), // clear navbar
                    child: Column(
                      children: [
                        // Events List
                        Builder(
                          builder: (context) {
                            final events = _getEventsForCategory(_selectedCategory);
                            return ListView.builder(
                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              itemCount: events.length,
                              itemBuilder: (context, index) {
                                return _buildEventCard(events[index]);
                              },
                            );
                          },
                        ),
                        
                        // Browse by Categories
                        const BrowseByCategoriesSection(),
                        const SizedBox(height: 24),

                        // Discover Near You
                        const RepaintBoundary(child: DiscoverNearYouSection()),
                        const SizedBox(height: 16),

                        // Family Feels
                        const RepaintBoundary(child: FamilyFeelsSection()),
                        const SizedBox(height: 16),

                        // TLB Signature
                        const RepaintBoundary(child: TlbSignatureSection()),
                        const SizedBox(height: 16),

                        // AppFooter
                        const AppFooter(),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
          Positioned(
            bottom: safeBottom > 0 ? safeBottom + 15 : 30, // 15px above native nav
            left: 0,
            right: 0,
            child: Align(
              alignment: Alignment.center,
              child: FloatingNavbar(
                currentIndex: _currentNavIndex,
                onTap: _onNavTapped,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Start of _buildEventCard

  Widget _buildEventCard(EventModel event) {
    return GestureDetector(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => EventDetailScreen(event: event)),
      ),
      child: Container(
      margin: const EdgeInsets.only(bottom: 24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Image Area
          Stack(
            children: [
              ClipRRect(
                borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
                child: Image.asset(
                  event.imagePath,
                  height: Responsive.h(context, 220, min: 160),
                  width: double.infinity,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      height: Responsive.h(context, 220, min: 160),
                      color: Colors.grey.shade300,
                      child: const Center(child: Icon(Icons.image, size: 50, color: Colors.grey)),
                    );
                  },
                ),
              ),
              // Heart icon - LikeButton with disperse animation
              Positioned(
                top: 16,
                right: 16,
                child: WishlistButton(
                  event: event,
                  containerSize: 36,
                ),
              ),
            ],
          ),
          
          // Details Area
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  event.title,
                  style: GoogleFonts.poppins(
                    fontSize: Responsive.sp(context, 17),
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF1A1A2E),
                  ),
                ),
                const SizedBox(height: 8),
                // Tags
                Row(
                  children: [
                    if (event.tag != null) Flexible(child: _buildPill(event.tag!)),
                    const SizedBox(width: 8),
                    if (event.description != null) Flexible(child: _buildPill(event.description!)),
                  ],
                ),
                const SizedBox(height: 20),
                // Bottom row: Program type, Price, View Details button
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            event.venue.toUpperCase(),
                            style: GoogleFonts.poppins(
                              fontSize: 10,
                              fontWeight: FontWeight.w600,
                              color: Colors.grey.shade600,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '₹${event.price?.toInt() ?? 0}',
                            style: GoogleFonts.poppins(
                              fontSize: Responsive.sp(context, 17),
                              fontWeight: FontWeight.w800,
                              color: const Color(0xFF1A1A2E),
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(
                      height: 40,
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
                          minimumSize: const Size(0, 46),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                          ),
                          padding: const EdgeInsets.symmetric(horizontal: 24),
                        ),
                        child: Text(
                          'View Details',
                          style: GoogleFonts.poppins(
                            fontSize: Responsive.sp(context, 13),
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
        ],
      ),
      ),
    );
  }

  Widget _buildPill(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: const Color(0xFFF0F0F0),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        text,
        style: GoogleFonts.poppins(
          fontSize: 11,
          fontWeight: FontWeight.w500,
          color: const Color(0xFF6B6B6B),
        ),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
    );
  }
}
