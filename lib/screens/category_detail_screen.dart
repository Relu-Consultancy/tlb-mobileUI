import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/event_model.dart';
import '../data/dummy_data.dart';
import '../widgets/filter_bottom_sheet.dart';
import '../widgets/category_detail/category_header.dart';
import '../widgets/category_detail/explore_categories_widget.dart';
import '../widgets/category_detail/horizontal_filter_chips.dart';
import '../widgets/category_detail/category_grid_event_card.dart';
import '../widgets/floating_navbar.dart';
import 'events_screen.dart';

class CategoryDetailScreen extends StatefulWidget {
  final String title;
  final String imagePath;
  final List<Color> backgroundColors;

  const CategoryDetailScreen({
    super.key,
    required this.title,
    required this.imagePath,
    required this.backgroundColors,
  });

  @override
  State<CategoryDetailScreen> createState() => _CategoryDetailScreenState();
}

class _CategoryDetailScreenState extends State<CategoryDetailScreen> {
  final TextEditingController _searchController = TextEditingController();
  final List<String> _filters = ['All', 'Painting', 'Pottery', 'Crafting', 'Digital Art'];
  String _selectedFilter = 'All';
  bool _showAllCategories = false;

  final List<Map<String, dynamic>> _otherCategories = [
    {
      'title': 'Creative art',
      'image': 'assets/images/new_home/eventcategory1.png',
      'colors': [Colors.white, const Color(0xFFFFEBEB)],
    },
    {
      'title': 'Family Time',
      'image': 'assets/images/new_home/eventcategory2.png',
      'colors': [Colors.white, const Color(0xFFFFE4E1)],
    },
    {
      'title': 'Seasonal Special',
      'image': 'assets/images/new_home/eventcategory3.png',
      'colors': [Colors.white, const Color(0xFFE8F0FE)],
    },
    {
      'title': 'Science & STEM',
      'image': 'assets/images/new_home/eventcategory4.png',
      'colors': [Colors.white, const Color(0xFFE0F7FA)],
    },
    {
      'title': 'Health & Wellness',
      'image': 'assets/images/new_home/eventcategory5.png',
      'colors': [Colors.white, const Color(0xFFFFE4E1)],
    },
    {
      'title': 'Play & Adventure',
      'image': 'assets/images/new_home/eventcategory1.png', // fallback
      'colors': [Colors.white, const Color(0xFFF1F8E9)],
    },
  ];

  Map<String, bool> _activeFilters = {
    'Within 5km': false,
    'This Weekend': false,
    'Distance - Near to Far': false,
    'Age group (5-14)': false,
    'Popular': false,
    'Price- Low to High': false,
  };

  void _showFilterBottomSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return FilterBottomSheet(
          initialFilters: _activeFilters,
          onApply: (selectedFilters) {
            setState(() {
              _activeFilters = selectedFilters;
            });
          },
        );
      },
    );
  }

  void _onNavTapped(int index) {
    if (index == 0) {
      // Home
      Navigator.popUntil(context, (route) => route.isFirst);
      return;
    }
    if (index == 1) {
      // Events
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(
          builder: (context) => const EventsScreen(),
        ),
        (route) => route.isFirst,
      );
      return;
    }
    // Cannot cleanly transition to other categories structurally from here without a larger refactor,
    // so we just return to home or events top level screen for now.
  }

  @override
  Widget build(BuildContext context) {
    final List<EventModel> eventsToDisplay = DummyData.categoryEventsExtra;
    final safeBottom = MediaQuery.of(context).padding.bottom;

    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          CustomScrollView(
            slivers: [
              // Header
              SliverToBoxAdapter(
                child: CategoryHeader(
                  title: widget.title,
                  imagePath: widget.imagePath,
                  backgroundColors: widget.backgroundColors,
                  searchController: _searchController,
                  onFilterTap: _showFilterBottomSheet,
                  onBackTap: () => Navigator.pop(context),
                ),
              ),
              
              const SliverToBoxAdapter(child: SizedBox(height: 10)),

              // Explore other categories
              SliverToBoxAdapter(
                child: ExploreCategoriesWidget(
                  categories: _otherCategories,
                  currentCategoryTitle: widget.title,
                  showAllCategories: _showAllCategories,
                  onToggleShowAll: () {
                    setState(() {
                      _showAllCategories = !_showAllCategories;
                    });
                  },
                ),
              ),

              // Divider / Section Title
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 24.0, horizontal: 16),
                  child: Row(
                    children: [
                      Expanded(
                        child: Container(
                          height: 1,
                          decoration: const BoxDecoration(
                            gradient: LinearGradient(
                              colors: [Colors.transparent, Color(0xFFFFD54F)],
                            ),
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16.0),
                        child: Text(
                          'All ${widget.title}',
                          style: GoogleFonts.poppins(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            color: const Color(0xFF1A1A2E),
                          ),
                        ),
                      ),
                      Expanded(
                        child: Container(
                          height: 1,
                          decoration: const BoxDecoration(
                            gradient: LinearGradient(
                              colors: [Color(0xFFFFD54F), Colors.transparent],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // Horizontal Filter Chips
              SliverToBoxAdapter(
                child: HorizontalFilterChips(
                  filters: _filters,
                  selectedFilter: _selectedFilter,
                  onFilterSelect: (filter) {
                    setState(() {
                      _selectedFilter = filter;
                    });
                  },
                  onOpenFiltersSheet: _showFilterBottomSheet,
                ),
              ),
              
              const SliverToBoxAdapter(child: SizedBox(height: 16)),

              // Events Grid
              SliverPadding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                sliver: SliverGrid(
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    mainAxisSpacing: 16,
                    crossAxisSpacing: 16,
                    childAspectRatio: 0.65,
                  ),
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      return CategoryGridEventCard(event: eventsToDisplay[index]);
                    },
                    childCount: eventsToDisplay.length,
                  ),
                ),
              ),
              
              SliverToBoxAdapter(child: SizedBox(height: 120 + safeBottom)), // Bottom padding for navbar
            ],
          ),
          Positioned(
            bottom: safeBottom > 0 ? safeBottom + 15 : 30, // 15px above native nav
            left: 0,
            right: 0,
            child: Align(
              alignment: Alignment.center,
              child: FloatingNavbar(
                currentIndex: 1, // Treat sub-category as under "Events" root
                onTap: _onNavTapped,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
