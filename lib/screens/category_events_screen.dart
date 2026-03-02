import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../sections/home_header.dart';
import '../models/event_model.dart';

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
    'Venues',
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

          // Categories horizontal list
          _buildCategoryTabs(),

          // Vertical ListView for events
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              itemCount: _categoryEvents.length,
              itemBuilder: (context, index) {
                return _buildEventCard(_categoryEvents[index]);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryTabs() {
    return Container(
      height: 90,
      padding: const EdgeInsets.symmetric(vertical: 12),
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
              margin: const EdgeInsets.only(right: 20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Icon container
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: isSelected && !isHome
                          ? const Color(0xFFFFCC00)
                          : const Color(0xFFFFF0D0),
                      boxShadow: isSelected && !isHome
                          ? [
                              BoxShadow(
                                color: const Color(0xFFFFCC00).withOpacity(0.4),
                                blurRadius: 8,
                                offset: const Offset(0, 4),
                              )
                            ]
                          : [],
                    ),
                    child: Center(
                      child: isHome
                          ? const Icon(Icons.home, color: Color(0xFF1A1A2E), size: 24)
                          : _getCategoryIcon(cat, isSelected),
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    cat,
                    style: GoogleFonts.poppins(
                      fontSize: 11,
                      fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                      color: const Color(0xFF1A1A2E),
                    ),
                  )
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _getCategoryIcon(String category, bool isSelected) {
    IconData iconData;
    switch (category) {
      case 'Events':
        iconData = Icons.event_note;
        break;
      case 'Classes':
        iconData = Icons.school_outlined;
        break;
      case 'Program':
        iconData = Icons.emoji_events_outlined;
        break;
      case 'Venues':
        iconData = Icons.storefront_outlined;
        break;
      case 'Shop':
        iconData = Icons.shopping_bag_outlined;
        break;
      default:
        iconData = Icons.star_outline;
    }

    return Icon(
      iconData,
      color: isSelected ? Colors.white : const Color(0xFFDE7104),
      size: 22,
    );
  }

  Widget _buildEventCard(EventModel event) {
    return Container(
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
                  height: 220,
                  width: double.infinity,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      height: 220,
                      color: Colors.grey.shade300,
                      child: const Center(child: Icon(Icons.image, size: 50, color: Colors.grey)),
                    );
                  },
                ),
              ),
              // Heart icon
              Positioned(
                top: 16,
                right: 16,
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.9),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.favorite_border,
                    size: 20,
                    color: Color(0xFF1A1A2E),
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
                        onPressed: () {},
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
