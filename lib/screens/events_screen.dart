import 'package:flutter/material.dart';
import '../core/app_colors.dart';
import '../widgets/auto_scroll_list.dart';
import '../core/responsive.dart';
import '../data/dummy_data.dart';
import '../models/api_category_model.dart';
import '../providers/saved_events_state.dart';
import '../services/events_listing_service.dart';
import '../widgets/banner_carousel.dart';
import '../widgets/dark_category_section.dart';
import '../widgets/dark_glow_header.dart';
import '../widgets/section_divider_widget.dart';
import '../widgets/explore_categories_grid.dart';
import '../widgets/explore_format_row.dart';
import '../widgets/partner_portrait_card.dart';
import '../widgets/trending_event_card.dart';

import '../widgets/holiday_special_card.dart';
import '../widgets/new_on_tlb_card.dart';
import 'format_events_screen.dart';
import '../widgets/online_event_card.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';

import '../widgets/weekend_event_card.dart';
import '../sections/app_footer.dart';
import '../widgets/app_refresh_indicator.dart';
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

  // Scroll-driven floating navbar: hidden over the black hero (header → banner →
  // Explore by Categories), then fades + slides into view as that region
  // scrolls away — same behaviour as the Home screen. Thresholds are set from
  // the viewport height in build() (the black region is roughly one screenful).
  final ScrollController _scrollController = ScrollController();
  final ValueNotifier<double> _navReveal = ValueNotifier<double>(0.0);
  double _navFadeStart = 400;
  double _navFadeEnd = 700;

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
    _scrollController.addListener(_onScroll);
    _loadCategories();
  }

  void _onScroll() {
    final double offset = _scrollController.offset;
    final double t = ((offset - _navFadeStart) / (_navFadeEnd - _navFadeStart))
        .clamp(0.0, 1.0);
    if (_navReveal.value != t) _navReveal.value = t;
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
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    _navReveal.dispose();
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

  // Pull-to-refresh: re-fetch live categories + wishlist state, then rebuild.
  Future<void> _handleRefresh() async {
    await Future.wait([
      _loadCategories(),
      SavedEventsState.loadFromApi(),
    ]);
    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final double screenH = MediaQuery.of(context).size.height;
    final double safeBottom = MediaQuery.of(context).padding.bottom;
    // Reveal the navbar once the tall black hero (~one screenful of banner +
    // the categories below it) has scrolled away.
    _navFadeStart = screenH * 0.70;
    _navFadeEnd = screenH * 0.95;

    // Tall banner height (matches the Venues page): fills the viewport minus the
    // header block and the navbar area.
    final double bannerH = (screenH -
            MediaQuery.of(context).padding.top -
            156 - // header content + gap below it
            (safeBottom > 0 ? safeBottom + 15 : 30) -
            140) // navbar pill + clear gap above it
        .clamp(300.0, 700.0);
    final double bannerCardWidth = MediaQuery.of(context).size.width - 32;

    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          // Single scroll view — header scrolls with the rest of the page
          // (Session-48 fix for "partial scroll" bug).
          AppRefreshIndicator(
            onRefresh: _handleRefresh,
            child: SingleChildScrollView(
              controller: _scrollController,
              physics: const AlwaysScrollableScrollPhysics(),
              child: Column(
                children: [
                // ── Black "night theatre" region: header → categories ──
                // Same treatment as the Home hero (dark glow header on black).
                ColoredBox(
                  color: Colors.black,
                  child: Column(
                    children: [
                      const DarkGlowHeader(),
                      const SizedBox(height: 14),
                      // Banner — tall centered card (matches the Venues page
                      // banner). Behind it, a transparent rounded box carries a
                      // side-biased gold glow that spills out the card's left &
                      // right edges (same look as the Home Spotlight card).
                      SizedBox(
                        height: bannerH,
                        child: Stack(
                          alignment: Alignment.center,
                          children: [
                            Center(
                              child: Container(
                                width: bannerCardWidth,
                                height: bannerH,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(22),
                                  boxShadow: goldBannerSideGlow(),
                                ),
                              ),
                            ),
                            RepaintBoundary(
                              child: BannerCarousel(
                                events: DummyData.eventsScreenBanners,
                                height: bannerH,
                                showGlow: false,
                                overlayStyle: true,
                                fixedCardWidth: bannerCardWidth,
                                cornerRadius: 22,
                                overlayDots: true,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 26),
                      // Centered ornamental title (matches the Home sections).
                      const DarkCategoryTitle('Explore by Categories'),
                      const SizedBox(height: 18),
                      // Grid with the "View All" pill floated over the bottom
                      // row (seamlessly blended, per the reference).
                      Stack(
                        alignment: Alignment.bottomCenter,
                        clipBehavior: Clip.none,
                        children: [
                          RepaintBoundary(
                            child: ExploreCategoriesGrid(
                              categories: _gridCategories,
                              scrollable: true,
                              scrollHeight: 260,
                              maxScrollRows: 3, // scroll stops at the 3rd row
                              childAspectRatio: 0.8,
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
                          Positioned(
                            bottom: -4,
                            child: DarkViewAllButton(
                              onTap: () => _showAllCategoriesPopup(context),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 30),
                    ],
                  ),
                ),

                      const SectionDividerWidget(topPadding: 30, title: 'Trending Events'),
                      SizedBox(
                        height: Responsive.h(context, 420, min: 400),
                        child: AutoScrollList(
                          padding: const EdgeInsets.only(left: 16),
                          itemCount: DummyData.trendingEvents.length,
                          itemBuilder: (context, index) {
                            return Padding(
                              padding: const EdgeInsets.only(right: 16),
                              child: SizedBox(
                                width: Responsive.cardWidth(context, fraction: 0.85, max: 360),
                                child: TrendingEventCard(
                                  event: DummyData.trendingEvents[index],
                                ),
                              ),
                            );
                          },
                        ),
                      ),

                      const SectionDividerWidget(topPadding: 30, title: 'Explore by Format'),
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
                      const SectionDividerWidget(topPadding: 30, title: 'Happening This Weekend'),
                      SizedBox(
                        // Tightened so the card hugs its content (was 190 — left
                        // ~30px of white below the Book Now button).
                        height: Responsive.h(context, 162, min: 150),
                        child: AutoScrollList(
                          padding: const EdgeInsets.only(left: 16),
                          itemCount: DummyData.weekendSpecial.length,
                          itemBuilder: (context, index) {
                            return Padding(
                              padding: const EdgeInsets.only(right: 14),
                              child: WeekendEventCard(
                                event: DummyData.weekendSpecial[index],
                                width: Responsive.cardWidth(context, fraction: 0.85, max: 360),
                              ),
                            );
                          },
                        ),
                      ),

                      const SectionDividerWidget(topPadding: 30, title: 'Holiday Special'),
                      SizedBox(
                        height: Responsive.h(context, 460, min: 430),
                        child: AutoScrollList(
                          padding: const EdgeInsets.only(left: 16),
                          itemCount: DummyData.holidaySpecials.length,
                          itemBuilder: (context, index) {
                            return Padding(
                              padding: const EdgeInsets.only(right: 14),
                              child: RepaintBoundary(
                                child: HolidaySpecialCard(
                                  event: DummyData.holidaySpecials[index],
                                  width: Responsive.cardWidth(context, fraction: 0.85, max: 360),
                                ),
                              ),
                            );
                          },
                        ),
                      ),

                      const SectionDividerWidget(topPadding: 30, title: 'Featured Partners'),
                      SizedBox(
                        height: Responsive.h(context, 540, min: 520),
                        child: AutoScrollList(
                          padding: const EdgeInsets.only(left: 16),
                          itemCount: DummyData.featuredPartners.length,
                          itemBuilder: (context, index) {
                            return PartnerPortraitCard(
                              event: DummyData.featuredPartners[index],
                              width: Responsive.cardWidth(context, fraction: 0.85, max: 360),
                            );
                          },
                        ),
                      ),

                      const SectionDividerWidget(topPadding: 30, title: 'New On TLB'),
                      SizedBox(
                        height: Responsive.h(context, 230, min: 210),
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
                            activeDotColor: AppColors.textPrimary,
                            dotColor: Color(0xFFE0E0E0),
                            spacing: 5,
                          ),
                        ),
                      ),

                      const SectionDividerWidget(topPadding: 30, title: 'Online Events'),
                      SizedBox(
                        height: Responsive.h(context, 372, min: 342),
                        child: AutoScrollList(
                          padding: const EdgeInsets.only(left: 16),
                          itemCount: DummyData.onlineEvents.length,
                          itemBuilder: (context, index) {
                            return Padding(
                              padding: const EdgeInsets.only(right: 14),
                              child: OnlineEventCard(
                                event: DummyData.onlineEvents[index],
                                width: Responsive.cardWidth(context, fraction: 0.85, max: 360),
                              ),
                            );
                          },
                        ),
                      ),

                // The full black starry footer (quote, logo, links).
                AppFooter(bottomExtra: FloatingNavbar.clearance(context)),
              ],
            ),
          ),
          ),
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            // Hidden over the black hero; fades + slides up into view as the
            // Explore by Categories region scrolls away.
            child: ValueListenableBuilder<double>(
              valueListenable: _navReveal,
              builder: (context, t, child) {
                return IgnorePointer(
                  ignoring: t < 0.05,
                  child: Opacity(
                    opacity: t,
                    child: Transform.translate(
                      offset: Offset(0, (1 - t) * 60),
                      child: child,
                    ),
                  ),
                );
              },
              child: Align(
                alignment: Alignment.center,
                child: FloatingNavbar(
                  currentIndex: _currentNavIndex,
                  onTap: _onNavTapped,
                  bottomPadding: FloatingNavbar.bottomInset(context),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
