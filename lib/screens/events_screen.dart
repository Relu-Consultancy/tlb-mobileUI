import 'package:flutter/material.dart';
import '../core/responsive.dart';
import '../data/dummy_data.dart';
import '../models/api_category_model.dart';
import '../sections/home_header.dart';
import '../services/events_listing_service.dart';
import '../widgets/banner_carousel.dart';
import '../widgets/section_divider_widget.dart';
import '../widgets/explore_categories_grid.dart';
import '../widgets/explore_format_row.dart';
import '../widgets/partner_portrait_card.dart';
import '../widgets/event_card_with_rating.dart';

import '../widgets/holiday_special_card.dart';
import '../widgets/new_on_tlb_card.dart';
import 'format_events_screen.dart';
import '../widgets/online_event_card.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';

import '../widgets/weekend_event_card.dart';
import '../sections/app_footer.dart';
import '../widgets/floating_navbar.dart';
import 'classes_screen.dart';
import 'programs_screen.dart';
import 'venues_screen.dart';
import '../widgets/all_categories_popup.dart';
import 'category_events_screen.dart';

// Slug → local asset + gradient palette.
// New API categories that don't yet have dedicated assets fall back to a
// visually distinct colour + the closest existing image.
final _categoryAssets = <String, Map<String, dynamic>>{
  'arts-crafts': {
    'image': 'assets/images/event_subcategories/artcraft.png',
    'gradient': <Color>[const Color(0xFFE8E0FF), const Color(0xFFD4BFFF)],
  },
  'performing-arts': {
    'image': 'assets/images/event_subcategories/performarts.png',
    'gradient': <Color>[const Color(0xFFFFE0E0), const Color(0xFFFFB3B3)],
  },
  'stem-innovation': {
    'image': 'assets/images/event_subcategories/stem.png',
    'gradient': <Color>[const Color(0xFFFFF0D4), const Color(0xFFFFDB99)],
  },
  'sports-fitness': {
    'image': 'assets/images/event_subcategories/sports.png',
    'gradient': <Color>[const Color(0xFFFFF8D4), const Color(0xFFFFEDA1)],
  },
  'languages-communication': {
    'image': 'assets/images/event_subcategories/lang.png',
    'gradient': <Color>[const Color(0xFFFFE8E0), const Color(0xFFFFC2AD)],
  },
  'life-skills': {
    'image': 'assets/images/event_subcategories/lifeskills.png',
    'gradient': <Color>[const Color(0xFFE0F0FF), const Color(0xFFADD4FF)],
  },
  'mind-strategy-games': {
    'image': 'assets/images/event_subcategories/lifeskills.png',
    'gradient': <Color>[const Color(0xFFE8F5E9), const Color(0xFFA5D6A7)],
  },
  'edutainment-experiences': {
    'image': 'assets/images/event_subcategories/performarts.png',
    'gradient': <Color>[const Color(0xFFFCE4EC), const Color(0xFFF48FB1)],
  },
  'nature-outdoors': {
    'image': 'assets/images/event_subcategories/sports.png',
    'gradient': <Color>[const Color(0xFFE8F5E0), const Color(0xFFA5D6A0)],
  },
  'festivals-celebrations': {
    'image': 'assets/images/event_subcategories/artcraft.png',
    'gradient': <Color>[const Color(0xFFFFF8E1), const Color(0xFFFFCC80)],
  },
};

final _defaultCategoryAsset = <String, dynamic>{
  'image': 'assets/images/event_subcategories/artcraft.png',
  'gradient': <Color>[const Color(0xFFE8E0FF), const Color(0xFFD4BFFF)],
};

class EventsScreen extends StatefulWidget {
  const EventsScreen({super.key});

  @override
  State<EventsScreen> createState() => _EventsScreenState();
}

// Slugs matching DummyData.exploreCategories order
const _kFallbackSlugs = [
  'arts-crafts',
  'performing-arts',
  'stem-innovation',
  'sports-fitness',
  'languages-communication',
  'life-skills',
];

class _EventsScreenState extends State<EventsScreen> {
  int _currentNavIndex = 1;
  final PageController _newOnTlbController = PageController(viewportFraction: 0.92);

  // ── Explore by Categories ────────────────────────────────────────────────
  // Starts with dummy fallback so the section is always visible immediately.
  // API call in initState silently replaces with live data when available.
  late List<Map<String, dynamic>> _gridCategories = _buildFallbackCategories();

  List<Map<String, dynamic>> _buildFallbackCategories() {
    return List.generate(DummyData.exploreCategories.length, (i) {
      final cat = DummyData.exploreCategories[i];
      return <String, dynamic>{
        ...cat,
        'slug': i < _kFallbackSlugs.length ? _kFallbackSlugs[i] : '',
        'id': i + 1,
        'subcategories': <String>[],
      };
    });
  }

  @override
  void initState() {
    super.initState();
    _loadCategories();
  }

  Future<void> _loadCategories() async {
    try {
      final apiCats = await EventsListingService.fetchCategories();
      if (!mounted) return;
      if (apiCats.isNotEmpty) {
        setState(() => _gridCategories = _toGridFormat(apiCats));
      }
    } catch (_) {
      // Keep fallback categories — no error state needed
    }
  }

  /// Transforms the API category list into the Map format that
  /// [ExploreCategoriesGrid] already understands.
  List<Map<String, dynamic>> _toGridFormat(List<ApiCategory> cats) {
    return cats.map((cat) {
      final assets = _categoryAssets[cat.slug] ?? _defaultCategoryAsset;
      return <String, dynamic>{
        'label': _formatLabel(cat.name),
        'image': assets['image'] as String,
        'gradient': assets['gradient'] as List<Color>,
        'slug': cat.slug,
        'id': cat.id,
        'subcategories': cat.subcategories.map((s) => s.name).toList(),
      };
    }).toList();
  }

  /// Inserts a line-break after " & " so long category names wrap neatly
  /// inside the compact grid cards (mirrors the dummy-data convention).
  String _formatLabel(String name) => name.replaceAll(' & ', ' &\n');

  // ────────────────────────────────────────────────────────────────────────

  void _showAllCategoriesPopup(BuildContext context) {
    AllCategoriesPopup.show(context, DummyData.allCategories);
  }

  @override
  void dispose() {
    _newOnTlbController.dispose();
    super.dispose();
  }

  void _onNavTapped(int index) {
    if (index == 0) {
      Navigator.popUntil(context, (route) => route.isFirst);
    } else if (index == 2) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const ClassesScreen()),
      );
    } else if (index == 3) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const ProgramsScreen()),
      );
    } else if (index == 4) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const VenuesScreen()),
      );
    } else if (index != _currentNavIndex) {
      setState(() => _currentNavIndex = index);
    }
  }

  @override
  Widget build(BuildContext context) {
    final safeBottom = MediaQuery.of(context).padding.bottom;

    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          // Single scroll view — header scrolls with the rest of the page
          // (Session-48 fix for "partial scroll" bug).
          SingleChildScrollView(
            physics: const ClampingScrollPhysics(),
            child: Column(
              children: [
                Container(
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Color(0xFFFFF5E0),
                        Color(0xFFFFF5E0),
                        Color(0xFFFFFAF0),
                        Colors.white,
                      ],
                      stops: [0.0, 0.55, 0.80, 1.0],
                    ),
                  ),
                  child: const Column(
                    children: [
                      HomeHeader(),
                      SizedBox(height: 16),
                    ],
                  ),
                ),
                      // Spotlight Banner
                      RepaintBoundary(
                        child: BannerCarousel(
                          events: DummyData.eventsScreenBanners,
                          height: Responsive.h(context, 386, min: 286),
                          showGlow: false,
                          overlayStyle: true,
                        ),
                      ),

                      // ── Explore by Categories ─────────────────────────
                      const SectionDividerWidget(title: 'Explore by Categories'),
                      RepaintBoundary(
                        child: ExploreCategoriesGrid(
                          categories: _gridCategories,
                          scrollable: true,
                          scrollHeight: 260,
                          childAspectRatio: 0.8,
                          onViewAll: () => _showAllCategoriesPopup(context),
                          onCategoryTap: (index) {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => CategoryEventsScreen(
                                  categories: _gridCategories,
                                  initialCategoryIndex: index,
                                ),
                              ),
                            );
                          },
                        ),
                      ),

                      const SectionDividerWidget(title: 'Trending Events'),
                      SizedBox(
                        height: Responsive.h(context, 420, min: 400),
                        child: ListView.builder(
                          scrollDirection: Axis.horizontal,
                          padding: const EdgeInsets.only(left: 16),
                          itemCount: DummyData.hotPicks.length,
                          itemBuilder: (context, index) {
                            return Padding(
                              padding: const EdgeInsets.only(right: 16),
                              child: SizedBox(
                                width: Responsive.cardWidth(context, fraction: 0.82, max: 340),
                                child: EventCardWithRating(
                                  event: DummyData.hotPicks[index],
                                ),
                              ),
                            );
                          },
                        ),
                      ),

                      const SectionDividerWidget(title: 'Explore by Format'),
                      RepaintBoundary(
                        child: ExploreFormatRow(
                          onFormatTap: (index) => Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => FormatEventsScreen(
                                initialFormatIndex: index,
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),

                      const SectionDividerWidget(title: 'Happening This Weekend'),
                      SizedBox(
                        height: Responsive.h(context, 190, min: 170),
                        child: ListView.builder(
                          scrollDirection: Axis.horizontal,
                          padding: const EdgeInsets.only(left: 16),
                          itemCount: DummyData.weekendSpecial.length,
                          itemBuilder: (context, index) {
                            return Padding(
                              padding: const EdgeInsets.only(right: 14),
                              child: WeekendEventCard(
                                event: DummyData.weekendSpecial[index],
                                width: Responsive.cardWidth(context, fraction: 0.92, max: 380),
                              ),
                            );
                          },
                        ),
                      ),

                      const SectionDividerWidget(title: 'Holiday Special'),
                      SizedBox(
                        height: Responsive.h(context, 460, min: 430),
                        child: ListView.builder(
                          scrollDirection: Axis.horizontal,
                          padding: const EdgeInsets.only(left: 16),
                          itemCount: DummyData.holidaySpecials.length,
                          itemBuilder: (context, index) {
                            return Padding(
                              padding: const EdgeInsets.only(right: 14),
                              child: RepaintBoundary(
                                child: HolidaySpecialCard(
                                  event: DummyData.holidaySpecials[index],
                                  width: Responsive.cardWidth(context, fraction: 0.82, max: 340),
                                ),
                              ),
                            );
                          },
                        ),
                      ),

                      const SectionDividerWidget(title: 'Featured Partners'),
                      SizedBox(
                        height: Responsive.h(context, 540, min: 520),
                        child: ListView.builder(
                          scrollDirection: Axis.horizontal,
                          padding: const EdgeInsets.only(left: 16),
                          itemCount: DummyData.featuredPartners.length,
                          itemBuilder: (context, index) {
                            return PartnerPortraitCard(
                              event: DummyData.featuredPartners[index],
                              width: Responsive.cardWidth(context, fraction: 0.82, max: 340),
                            );
                          },
                        ),
                      ),

                      const SectionDividerWidget(title: 'New On TLB'),
                      SizedBox(
                        height: Responsive.h(context, 190, min: 170),
                        child: PageView.builder(
                          controller: _newOnTlbController,
                          itemCount: DummyData.newOnTlb.length,
                          itemBuilder: (context, index) {
                            return Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 6),
                              child: NewOnTlbCard(event: DummyData.newOnTlb[index]),
                            );
                          },
                        ),
                      ),
                      const SizedBox(height: 12),
                      Center(
                        child: SmoothPageIndicator(
                          controller: _newOnTlbController,
                          count: DummyData.newOnTlb.length,
                          effect: const WormEffect(
                            dotHeight: 7,
                            dotWidth: 7,
                            activeDotColor: Color(0xFF1A1A2E),
                            dotColor: Color(0xFFE0E0E0),
                            spacing: 5,
                          ),
                        ),
                      ),

                      const SectionDividerWidget(title: 'Online Events'),
                      SizedBox(
                        height: Responsive.h(context, 370, min: 340),
                        child: ListView.builder(
                          scrollDirection: Axis.horizontal,
                          padding: const EdgeInsets.only(left: 16),
                          itemCount: DummyData.onlineEvents.length,
                          itemBuilder: (context, index) {
                            return Padding(
                              padding: const EdgeInsets.only(right: 14),
                              child: OnlineEventCard(
                                event: DummyData.onlineEvents[index],
                                width: Responsive.cardWidth(context, fraction: 0.82, max: 340),
                              ),
                            );
                          },
                        ),
                      ),

                const AppFooter(),
                // Clear the floating navbar.
                SizedBox(
                    height: (safeBottom > 0 ? safeBottom + 15.0 : 30.0) + 64),
              ],
            ),
          ),
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Align(
              alignment: Alignment.center,
              child: FloatingNavbar(
                currentIndex: _currentNavIndex,
                onTap: _onNavTapped,
                bottomPadding: safeBottom > 0 ? safeBottom + 15 : 30,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
