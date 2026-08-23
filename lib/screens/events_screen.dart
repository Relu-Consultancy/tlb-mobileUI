import 'package:flutter/material.dart';
import '../core/app_colors.dart';
import '../widgets/auto_scroll_list.dart';
import '../core/responsive.dart';
import '../widgets/empty_location_widget.dart';
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
// Card renders [Colors.white -> gradient.last], so `.last` is the visible
// bottom tone — deep/saturated, matching DummyData.allCategories' colors
// (the "View All" popup) for the same category labels.
// `icon` + `circleColor` drive the line-art cards (see CategoryIconCard);
// `image` + `gradient` are kept for the gradient variant. Both the circle tones
// and the glyphs come from the approved design mock, and mirror
// DummyData.allCategories so the grid and its "View All" popup stay in step.
final _categoryAssets = <String, Map<String, dynamic>>{
  'arts-crafts': {
    'image': 'assets/images/event_subcategories/artcraft.png',
    'gradient': <Color>[const Color(0xFFA78BFA), const Color(0xFF7C3AED)], // violet
    'icon': 'assets/images/event_categories/arts_crafts.png',
    'circleColor': const Color(0xFFF4EFFD),
  },
  'performing-arts': {
    'image': 'assets/images/event_subcategories/performarts.png',
    'gradient': <Color>[const Color(0xFFF472B6), const Color(0xFFDB2777)], // pink
    'icon': 'assets/images/event_categories/performing_arts.png',
    'circleColor': const Color(0xFFFEF0F1),
  },
  'stem-innovation': {
    'image': 'assets/images/event_subcategories/stem.png',
    'gradient': <Color>[const Color(0xFFFDBA74), const Color(0xFFEA580C)], // orange
    'icon': 'assets/images/event_categories/stem_innovation.png',
    'circleColor': const Color(0xFFFEF4E6),
  },
  'sports-fitness': {
    'image': 'assets/images/event_subcategories/sports.png',
    'gradient': <Color>[const Color(0xFFFCD34D), const Color(0xFFD97706)], // amber/gold
    'icon': 'assets/images/event_categories/sports_fitness.png',
    'circleColor': const Color(0xFFFEF3DA),
  },
  'languages-communication': {
    'image': 'assets/images/event_subcategories/lang.png',
    'gradient': <Color>[const Color(0xFFF472B6), const Color(0xFFC026D3)], // magenta/fuchsia
    'icon': 'assets/images/event_categories/language_communication.png',
    'circleColor': const Color(0xFFFEEAEC),
  },
  'life-skills': {
    'image': 'assets/images/event_subcategories/lifeskills.png',
    'gradient': <Color>[const Color(0xFF38BDF8), const Color(0xFF2563EB)], // sky/blue
    'icon': 'assets/images/event_categories/life_skills.png',
    'circleColor': const Color(0xFFE6F1FD),
  },
  'mind-strategy-games': {
    'image': 'assets/images/event_subcategories/lifeskills.png',
    'gradient': <Color>[const Color(0xFF6366F1), const Color(0xFF312E81)], // indigo/navy
    'icon': 'assets/images/event_categories/mind_strategy_games.png',
    'circleColor': const Color(0xFFF2EAFD),
  },
  'edutainment-experiences': {
    'image': 'assets/images/event_subcategories/performarts.png',
    'gradient': <Color>[const Color(0xFFFCD34D), const Color(0xFFF97316)], // amber/orange
    'icon': 'assets/images/event_categories/edutainment_experiences.png',
    'circleColor': const Color(0xFFFDE6CA),
  },
  'nature-outdoors': {
    'image': 'assets/images/event_subcategories/sports.png',
    'gradient': <Color>[const Color(0xFF67E8F9), const Color(0xFF0891B2)], // cyan/teal
    'icon': 'assets/images/event_categories/nature_outdoors.png',
    'circleColor': const Color(0xFFE6F4E4),
  },
  'festivals-celebrations': {
    'image': 'assets/images/event_subcategories/artcraft.png',
    'gradient': <Color>[const Color(0xFFFDA4AF), const Color(0xFFE11D48)], // rose/red
    'icon': 'assets/images/event_categories/festivals_celebrations.png',
    'circleColor': const Color(0xFFFDEBEC),
  },
};

final _defaultCategoryAsset = <String, dynamic>{
  'image': 'assets/images/event_subcategories/artcraft.png',
  'gradient': <Color>[const Color(0xFFA78BFA), const Color(0xFF7C3AED)], // violet
  'icon': 'assets/images/event_categories/arts_crafts.png',
  'circleColor': const Color(0xFFF4EFFD),
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
        'icon': assets['icon'] as String,
        'circleColor': assets['circleColor'] as Color,
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
    AllCategoriesPopup.show(
      context,
      DummyData.allCategories,
      lineIcons: true,
      darkBackground: true,
      // Carry the popup's own list through, so the category screen's chip row
      // shows the same set the user just tapped from (the in-page grid does the
      // same with _gridCategories). CategoryEventsScreen filters by label, not
      // slug, so this list is self-sufficient.
      onCategoryTap: (index) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => CategoryEventsScreen(
              categories: DummyData.allCategories,
              initialCategoryIndex: index,
            ),
          ),
        );
      },
    );
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

    // Tall banner height (matches the Venues page): fills the viewport minus the
    // header block and the navbar area.
    final double bannerH = (screenH -
            MediaQuery.of(context).padding.top -
            156 - // header content + gap below it
            (safeBottom > 0 ? safeBottom + 15 : 30) -
            140) // navbar pill + clear gap above it
        .clamp(300.0, 700.0);
    final double bannerCardWidth = MediaQuery.of(context).size.width - 32;

    // Reveal the navbar as the top banner scrolls away, so it's visible by the
    // time the first section (Explore by Categories) is in view — tied to the
    // banner height, not a fixed fraction of the screen (the black hero is
    // taller than one screenful, so a screen-fraction revealed it far too late).
    final double heroTop = MediaQuery.of(context).padding.top + 169;
    _navFadeStart = heroTop + bannerH * 0.65;
    _navFadeEnd = heroTop + bannerH;

    return Scaffold(
      backgroundColor: Colors.white,
      // An unserviced city shows the empty state in place of this tab's whole
      // body, matching Home — which used to be the only screen that checked.
      body: LocationGate(
        emptyTitle: 'No events here yet',
        // The header and navbar sit in the same Stack as the feed, so they
        // are handed to the gate separately — swapping the Stack wholesale
        // stripped both, leaving no location chip and no way to change tab.
        header: const ColoredBox(
          color: Colors.black,
          child: SafeArea(bottom: false, child: DarkGlowHeader()),
        ),
        footer: Align(
          alignment: Alignment.bottomCenter,
          child: FloatingNavbar(
            currentIndex: 1,
            onTap: _onNavTapped,
            bottomPadding: FloatingNavbar.bottomInset(context),
          ),
        ),
        child: Stack(
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
                      // Banner — tall centered card (matches the Venues page).
                      // A black-filled box behind it casts the gold side-glow
                      // AND backs the image so the glow can't bleed through the
                      // banner's transparent areas.
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
                                  color: Colors.black,
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
                      // Reserve space at the grid's bottom so the floated pill
                      // stays INSIDE the Stack's bounds — a Positioned child
                      // hanging past the Stack isn't hit-testable (taps on the
                      // overhang are rejected), which left the button dead.
                      Stack(
                        alignment: Alignment.bottomCenter,
                        children: [
                          Padding(
                            padding: const EdgeInsets.only(bottom: 24),
                            child: RepaintBoundary(
                              child: ExploreCategoriesGrid(
                                categories: _gridCategories,
                                scrollable: true,
                                scrollHeight: 260,
                                maxScrollRows: 3, // scroll stops at the 3rd row
                                lineIcons: true,
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
                          ),
                          Positioned(
                            bottom: 0,
                            left: 0,
                            right: 0,
                            child: DarkViewAllButton(
                              onTap: () => _showAllCategoriesPopup(context),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 26),
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
                        // Poster (0.78) + title + strapline + the meta rows
                        // comes to ~559pt on a 393pt screen; the old 540 left
                        // the card's data clipped.
                        height: Responsive.h(context, 575, min: 555),
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
                // Apply easing curves so the animation feels organic rather
                // than mechanically linear. Opacity leads (appears early),
                // scale and slide follow a slightly snappier curve.
                final double easedOpacity =
                    Curves.easeOutCubic.transform(t);
                final double easedMotion =
                    Curves.easeOutQuart.transform(t);

                // Scale: the pill starts slightly smaller (0.92) and grows
                // to full size, giving the feel of rising toward the viewer.
                final double scale = 0.92 + 0.08 * easedMotion;

                // Slide: 40px upward travel (down from 60) — enough motion
                // to feel deliberate but not jarring.
                final double slideY = (1 - easedMotion) * 40;

                return IgnorePointer(
                  ignoring: t < 0.05,
                  child: Opacity(
                    opacity: easedOpacity,
                    child: Transform.translate(
                      offset: Offset(0, slideY),
                      child: Transform.scale(
                        scale: scale,
                        alignment: Alignment.bottomCenter,
                        child: child,
                      ),
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
      ),
    );
  }
}
