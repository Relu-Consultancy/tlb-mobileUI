import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../core/responsive.dart';
import '../core/saved_events_state.dart';
import '../sections/home_header.dart';
import '../models/event_model.dart';
import '../sections/browse_by_categories_section.dart';
import '../sections/discover_near_you_section.dart';
import '../sections/family_feels_section.dart';
import '../sections/tlb_signature_section.dart';
import '../sections/app_footer.dart';
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
    'Spaces', // Changed from Venues to match the design image
    'Shop',
  ];

  // Dummy event data based on the second image design
  final List<EventModel> _categoryEvents = [
    EventModel(
      title: 'Kids party',
      venue: 'FULL PROGRAM', // using venue to store the bottom-left text
      imagePath: 'assets/images/new_home/eventposter1.jpg',
      price: 800,
      tag: '2 Weeks', // using for first pill
      description: 'Age 8-14', // using for second pill
    ),
    EventModel(
      title: 'Adventure Camp',
      venue: 'SUMMER SPECIAL',
      imagePath: 'assets/images/new_home/eventposter2.jpg',
      price: 1200,
      tag: '1 Week',
      description: 'Age 10-15',
    ),
  ];

  @override
  void initState() {
    super.initState();
    _selectedCategory = widget.initialCategory;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFF8EE),
      body: Column(
        children: [
          // Reuse Home Header exactly as is
          const HomeHeader(),

          // Main Scrollable Content
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  // Categories horizontal list (now scrollable with page)
                  _buildCategoryTabs(),

                  // Events List
                  ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: _categoryEvents.length,
                    itemBuilder: (context, index) {
                      return _buildEventCard(_categoryEvents[index]);
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
        ],
      ),
    );
  }

  Widget _buildCategoryTabs() {
    return Container(
      height: Responsive.h(context, 125, min: 100),
      padding: const EdgeInsets.only(top: 12, bottom: 4),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: _categories.length,
        itemBuilder: (context, index) {
          final cat = _categories[index];
          final isSelected = cat == _selectedCategory;
          final isHome = cat == 'Home';

          return GestureDetector(
            onTap: () {
              if (isHome) {
                Navigator.pop(context);
              } else {
                setState(() {
                  _selectedCategory = cat;
                });
              }
            },
            child: Container(
              margin: const EdgeInsets.only(right: 8),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _buildCategoryItem(cat, isSelected, isHome),
                  const SizedBox(height: 4),
                  if (!isHome)
                    Text(
                      cat,
                      style: GoogleFonts.poppins(
                        fontSize: 12,
                        fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                        color: const Color(0xFF333333),
                      ),
                    ),
                  if (isHome) // placeholder for spacing
                    const SizedBox(height: 18),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildCategoryItem(String cat, bool isSelected, bool isHome) {
    if (isHome) {
      return Container(
        width: 50,
        height: 70, // Match visual center of other elements
        alignment: Alignment.center,
        child: const Icon(Icons.home_rounded, color: Color(0xFF333333), size: 30),
      );
    }

    const double squircleSize = 52;
    const double haloSize = 78;

    Widget squircle = Container(
      width: squircleSize,
      height: squircleSize,
      clipBehavior: Clip.hardEdge,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        gradient: isSelected
            ? const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Color(0xFFEAA100),
                  Color(0xFFD67300),
                ],
              )
            : null,
        color: isSelected ? null : const Color(0xFFFFF4D4),
      ),
      child: Stack(
        children: [
          if (!isSelected)
            Positioned(
              top: -8,
              right: -8,
              child: Container(
                width: 30,
                height: 30,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  color: Color(0xFFFDE9B7),
                ),
              ),
            ),
          Positioned(
            bottom: -15,
            left: 0,
            right: 0,
            child: Container(
              height: 30,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isSelected ? const Color(0xFFFFCE54) : const Color(0xFFFDE9B7),
              ),
            ),
          ),
          Center(
            child: _getCategoryIcon(cat, isSelected),
          ),
        ],
      ),
    );

    if (isSelected) {
      return SizedBox(
        width: haloSize,
        height: haloSize,
        child: Stack(
          alignment: Alignment.center,
          children: [
            Container(
              width: haloSize - 6,
              height: haloSize - 6,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.04),
                    blurRadius: 10,
                    spreadRadius: 2,
                  )
                ],
              ),
            ),
            Positioned(
              top: 6,
              right: 12,
              child: Container(
                width: 8,
                height: 8,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  color: Color(0xFFFFD54F),
                ),
              ),
            ),
            Positioned(
              bottom: 12,
              left: 6,
              child: Container(
                width: 6,
                height: 6,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  color: Color(0xFFFF9800),
                ),
              ),
            ),
            squircle,
          ],
        ),
      );
    }

    return SizedBox(
      width: haloSize,
      height: haloSize,
      child: Center(child: squircle),
    );
  }

  Widget _getCategoryIcon(String category, bool isSelected) {
    IconData iconData;
    switch (category) {
      case 'Events':
        iconData = Icons.assignment_outlined;
        break;
      case 'Classes':
        iconData = Icons.person_outline;
        break;
      case 'Program':
        iconData = Icons.emoji_events_outlined;
        break;
      case 'Venues':
      case 'Spaces':
        iconData = Icons.maps_home_work_outlined;
        break;
      case 'Shop':
        iconData = Icons.storefront_outlined;
        break;
      default:
        iconData = Icons.star_outline;
    }

    return Icon(
      iconData,
      color: isSelected ? Colors.white : const Color(0xFF333333),
      size: 20,
    );
  }

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
              // Heart icon - adds to Favorites
              Positioned(
                top: 16,
                right: 16,
                child: GestureDetector(
                  onTap: () => SavedEventsState.toggle(event, context),
                  child: ValueListenableBuilder<List<EventModel>>(
                    valueListenable: SavedEventsState.savedEvents,
                    builder: (context, _, __) {
                      final isSaved = SavedEventsState.isSaved(event);
                      return Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.9),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          isSaved ? Icons.favorite : Icons.favorite_border,
                          size: 20,
                          color: isSaved ? const Color(0xFFFFB902) : const Color(0xFF1A1A2E),
                        ),
                      );
                    },
                  ),
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
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF1A1A2E),
                  ),
                ),
                const SizedBox(height: 8),
                // Tags
                Row(
                  children: [
                    if (event.tag != null) _buildPill(event.tag!),
                    const SizedBox(width: 8),
                    if (event.description != null) _buildPill(event.description!),
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
                              fontSize: 18,
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
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                          ),
                          padding: const EdgeInsets.symmetric(horizontal: 24),
                        ),
                        child: Text(
                          'View Details',
                          style: GoogleFonts.poppins(
                            fontSize: 13,
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
      ),
    );
  }
}
