import 'package:flutter/material.dart';
import '../widgets/app_loader.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import '../core/app_colors.dart';
import '../widgets/error_retry_view.dart';
import '../core/responsive.dart';
import '../data/dummy_data.dart';
import '../models/api_category_model.dart';
import '../models/api_venue_model.dart';
import '../models/event_model.dart';
import '../providers/location_state.dart';
import '../services/events_listing_service.dart';
import '../widgets/category_event_card.dart';
import '../widgets/category_screen_header.dart';
import '../widgets/category_skeleton_card.dart';
import '../widgets/filter_bottom_sheet.dart';
import '../widgets/subcategory_empty_state.dart';
import 'venue_detail_screen.dart';

class CategoryVenuesScreen extends StatefulWidget {
  final int initialCategoryIndex;

  const CategoryVenuesScreen({
    super.key,
    required this.initialCategoryIndex,
  });

  @override
  State<CategoryVenuesScreen> createState() => _CategoryVenuesScreenState();
}

class _CategoryVenuesScreenState extends State<CategoryVenuesScreen> {
  late int _selectedCategoryIndex;
  int _selectedFilterIndex = 0;
  final ScrollController _chipScrollController = ScrollController();
  final ScrollController _listScrollController = ScrollController();
  final List<GlobalKey> _chipKeys = List.generate(
    DummyData.venuesSeeAllCategories.length,
    (_) => GlobalKey(),
  );

  static const int _pageSize = 20;
  List<ApiCategory>? _apiCategories;
  List<ApiVenue> _apiVenues = [];
  bool _isLoadingVenues = false;
  String? _venuesError;
  bool _isLoadingMore = false;
  bool _hasMore = false;
  int _currentPage = 1;

  @override
  void initState() {
    super.initState();
    _selectedCategoryIndex = widget.initialCategoryIndex
        .clamp(0, DummyData.venuesSeeAllCategories.length - 1);
    _listScrollController.addListener(_onScroll);
    _loadApiCategoriesThenFetch();
  }

  Future<void> _loadApiCategoriesThenFetch() async {
    try {
      final cats = await EventsListingService.fetchVenueCategories();
      if (!mounted) return;
      _apiCategories = cats;
    } catch (_) {
      // Categories metadata endpoint may not be live yet — proceed without it.
    }
    _fetchVenues();
  }

  int? _matchedCategoryId() {
    if (_apiCategories == null || _apiCategories!.isEmpty) return null;
    final label = _categoryTitle.toLowerCase();
    for (final cat in _apiCategories!) {
      final name = cat.name.toLowerCase();
      if (name == label) return cat.id;
    }
    for (final cat in _apiCategories!) {
      final name = cat.name.toLowerCase();
      final words = label.split(' ').where((w) => w.length > 3);
      if (words.any((w) => name.contains(w))) return cat.id;
    }
    return null;
  }

  Future<void> _fetchVenues() async {
    setState(() {
      _isLoadingVenues = true;
      _venuesError = null;
      _currentPage = 1;
      _hasMore = false;
    });
    try {
      final page = await EventsListingService.fetchVenues(
        categoryId: _matchedCategoryId(),
        city: LocationState().selectedCity.value,
        page: 1,
        pageSize: _pageSize,
      );
      if (!mounted) return;
      setState(() {
        _apiVenues = page.results;
        _hasMore = _pageSize < page.count;
        _isLoadingVenues = false;
      });
    } catch (e) {
      if (!mounted) return;
      final msg = e.toString().replaceFirst('Exception: ', '');
      setState(() {
        _apiVenues = [];
        _venuesError = msg;
        _isLoadingVenues = false;
      });
    }
  }

  void _onScroll() {
    if (_listScrollController.position.pixels >=
        _listScrollController.position.maxScrollExtent - 300 &&
        _hasMore && !_isLoadingMore && !_isLoadingVenues) {
      _loadMore();
    }
  }

  Future<void> _loadMore() async {
    if (_isLoadingMore || !_hasMore) return;
    setState(() => _isLoadingMore = true);
    try {
      final next = await EventsListingService.fetchVenues(
        categoryId: _matchedCategoryId(),
        city: LocationState().selectedCity.value,
        page: _currentPage + 1,
        pageSize: _pageSize,
      );
      if (!mounted) return;
      setState(() {
        _apiVenues = [..._apiVenues, ...next.results];
        _currentPage += 1;
        _hasMore = _currentPage * _pageSize < next.count;
        _isLoadingMore = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() => _isLoadingMore = false);
    }
  }

  EventModel _toEventModel(ApiVenue venue) => EventModel(
        id: venue.id,
        title: venue.title,
        venue: [venue.area, venue.city]
            .where((s) => s != null && s.isNotEmpty)
            .join(', '),
        imagePath: venue.cover ?? '',
        tag: venue.category.name.isNotEmpty ? venue.category.name : null,
      );

  @override
  void dispose() {
    _chipScrollController.dispose();
    _listScrollController.dispose();
    super.dispose();
  }

  void _showAllCategories() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _VenuesAllCategoriesSheet(
        categories: DummyData.venuesSeeAllCategories,
        onCategoryTap: (index) {
          Navigator.pop(context);
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (_) => CategoryVenuesScreen(
                initialCategoryIndex:
                    index.clamp(0, DummyData.venuesSeeAllCategories.length - 1),
              ),
            ),
          );
        },
      ),
    );
  }

  void _selectCategory(int index) {
    setState(() {
      _selectedCategoryIndex = index;
      _selectedFilterIndex = 0;
    });
    _fetchVenues();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final key = _chipKeys[index];
      if (key.currentContext != null) {
        Scrollable.ensureVisible(
          key.currentContext!,
          alignment: 0.3,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
        );
      }
    });
  }

  Map<String, dynamic> get _currentCategory =>
      DummyData.venuesSeeAllCategories[_selectedCategoryIndex];

  List<Color> get _currentGradient =>
      (_currentCategory['gradient'] as List<Color>);

  Color get _accentColor => _currentGradient.last;

  List<String> get _filters =>
      DummyData.venuesSubFilters[_selectedCategoryIndex];

  String get _categoryTitle =>
      (_currentCategory['label'] as String).replaceAll('\n', ' ');

  void _showFilterSheet() {
    final cats = _filters.where((f) => f != 'All').toList();
    FilterBottomSheet.show(
      context,
      sortOptions: const [
        'Top Picks',
        'Distance- Near to Far',
        'Price- Low to High',
        'Price- High to Low',
      ],
      filterOptions: const [
        'Soft Play',
        'Trampoline Parks',
        'Ninja Courses',
        'Climbing Walls',
        'Arcade & tags',
        'VR & Simulation',
        'Escape Rooms',
      ],
      categoryOptions: cats,
    );
  }

  @override
  Widget build(BuildContext context) {
    final safeTop = MediaQuery.of(context).padding.top;

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.dark,
      child: Scaffold(
        backgroundColor: Colors.white,
        body: Column(
          children: [
            // ── Header ──────────────────────────────────────────────────
            CategoryScreenHeader(
              title: _categoryTitle,
              safeTop: safeTop,
              onBack: () => Navigator.pop(context),
              onFilterTap: _showFilterSheet,
              gradientColors: _currentGradient,
            ),

            // ── Scrollable Body ──────────────────────────────────────────
            Expanded(
              child: CustomScrollView(
                controller: _listScrollController,
                physics: const ClampingScrollPhysics(),
                slivers: [
                  // ── Explore other Venues label + tinted background ──
                  SliverToBoxAdapter(
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      curve: Curves.easeInOut,
                      decoration: BoxDecoration(
                        color: _accentColor.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Padding(
                            padding: const EdgeInsets.fromLTRB(16, 18, 16, 0),
                            child: Row(
                              children: [
                                Text(
                                  'Explore other Venues',
                                  style: GoogleFonts.poppins(
                                    fontSize: Responsive.sp(context, 13),
                                    fontWeight: FontWeight.w500,
                                    color: AppColors.textPrimary,
                                  ),
                                ),
                                const Spacer(),
                                GestureDetector(
                                  onTap: _showAllCategories,
                                  child: Text(
                                    'See All >',
                                    style: GoogleFonts.poppins(
                                      fontSize: Responsive.sp(context, 12),
                                      fontWeight: FontWeight.w500,
                                      color: AppColors.seeAllBlue,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          // ── Circle chip row ──
                          SizedBox(
                            height: Responsive.h(context, 142),
                            child: ListView.builder(
                              controller: _chipScrollController,
                              scrollDirection: Axis.horizontal,
                              padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
                              itemCount: DummyData.venuesSeeAllCategories.length,
                              itemBuilder: (context, index) {
                                final cat = DummyData.venuesSeeAllCategories[index];
                                final isSelected = index == _selectedCategoryIndex;
                                final catGradient = (cat['gradient'] as List<Color>);
                                return AnimatedScale(
                                  scale: isSelected ? 1.12 : 1.0,
                                  duration: const Duration(milliseconds: 200),
                                  curve: Curves.easeInOut,
                                  child: GestureDetector(
                                    key: _chipKeys[index],
                                    onTap: () => _selectCategory(index),
                                    child: Padding(
                                      padding: const EdgeInsets.only(right: 16),
                                      child: SizedBox(
                                        width: 78,
                                        child: Column(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            // Circle with overflow image
                                            SizedBox(
                                              width: 78,
                                              height: 88,
                                              child: Stack(
                                                clipBehavior: Clip.none,
                                                alignment: Alignment.bottomCenter,
                                                children: [
                                                  Positioned(
                                                    bottom: 0,
                                                    left: 5,
                                                    right: 5,
                                                    child: AnimatedContainer(
                                                      duration: const Duration(milliseconds: 200),
                                                      width: 68,
                                                      height: 68,
                                                      decoration: BoxDecoration(
                                                        shape: BoxShape.circle,
                                                        gradient: LinearGradient(
                                                          begin: Alignment.topLeft,
                                                          end: Alignment.bottomRight,
                                                          colors: catGradient,
                                                        ),
                                                        border: isSelected
                                                            ? Border.all(color: catGradient.last, width: 2.5)
                                                            : Border.all(color: Colors.black.withOpacity(0.07), width: 2.5),
                                                        boxShadow: [
                                                          BoxShadow(
                                                            color: catGradient.last.withOpacity(isSelected ? 0.50 : 0.20),
                                                            blurRadius: isSelected ? 12 : 6,
                                                            offset: const Offset(0, 4),
                                                          ),
                                                        ],
                                                      ),
                                                    ),
                                                  ),
                                                  Positioned(
                                                    bottom: 2,
                                                    child: Image.asset(
                                                      cat['image'] as String,
                                                      width: 78,
                                                      height: 84,
                                                      fit: BoxFit.contain,
                                                      errorBuilder: (_, __, ___) =>
                                                          Icon(Icons.place, size: 36, color: catGradient.last),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                            const SizedBox(height: 5),
                                            Text(
                                              cat['label'] as String,
                                              textAlign: TextAlign.center,
                                              maxLines: 2,
                                              overflow: TextOverflow.ellipsis,
                                              style: GoogleFonts.poppins(
                                                fontSize: Responsive.sp(context, 9.5),
                                                fontWeight: isSelected ? FontWeight.w500 : FontWeight.w500,
                                                height: 1.2,
                                                color: AppColors.textPrimary,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  // ── Section divider ──
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(16, 18, 16, 0),
                      child: Row(
                        children: [
                          Expanded(
                            child: Container(height: 1.5, color: AppColors.starAmber),
                          ),
                          const SizedBox(width: 10),
                          Text(
                            'All $_categoryTitle',
                            style: GoogleFonts.poppins(
                              fontSize: Responsive.sp(context, 14.5),
                              fontWeight: FontWeight.w500,
                              color: AppColors.textPrimary,
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Container(height: 1.5, color: AppColors.starAmber),
                          ),
                        ],
                      ),
                    ),
                  ),

                  // ── Filter chips ──
                  SliverToBoxAdapter(
                    child: SizedBox(
                      height: 42,
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
                        itemCount: _filters.length + 1,
                        itemBuilder: (context, index) {
                          if (index == 0) {
                            return GestureDetector(
                              onTap: _showFilterSheet,
                              child: Container(
                                margin: const EdgeInsets.only(right: 8),
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 14, vertical: 5),
                                decoration: BoxDecoration(
                                  color: AppColors.textPrimary,
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Text(
                                      'Filters',
                                      style: GoogleFonts.poppins(
                                        fontSize: Responsive.sp(context, 11.5),
                                        fontWeight: FontWeight.w500,
                                        color: Colors.white,
                                      ),
                                    ),
                                    const SizedBox(width: 4),
                                    const Icon(
                                        Icons.keyboard_arrow_down_rounded,
                                        size: 15,
                                        color: Colors.white),
                                  ],
                                ),
                              ),
                            );
                          }
                          final filterIndex = index - 1;
                          final isActive =
                              filterIndex == _selectedFilterIndex;
                          return GestureDetector(
                            onTap: () => setState(
                                () => _selectedFilterIndex = filterIndex),
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 180),
                              alignment: Alignment.center,
                              margin: const EdgeInsets.only(right: 8),
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 14, vertical: 5),
                              decoration: BoxDecoration(
                                // Selected: transparent golden tint + dark-yellow border.
                                color: isActive
                                    ? const Color(0x26FFCC00)
                                    : Colors.white,
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(
                                  color: isActive
                                      ? const Color(0xFFE6A800)
                                      : const Color(0xFFE0E0E0),
                                  width: isActive ? 1.5 : 1,
                                ),
                              ),
                              child: Text(
                                _filters[filterIndex],
                                style: GoogleFonts.poppins(
                                  fontSize: Responsive.sp(context, 11.5),
                                  fontWeight: isActive
                                      ? FontWeight.w500
                                      : FontWeight.w500,
                                  color: isActive
                                      ? AppColors.textPrimary
                                      : AppColors.textSecondary,
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ),

                  // ── Venue cards grid (API) ──
                  const SliverToBoxAdapter(child: SizedBox(height: 14)),
                  if (_isLoadingVenues)
                    SliverPadding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      sliver: SliverGrid(
                        delegate: SliverChildBuilderDelegate(
                          (context, index) => const CategorySkeletonCard(),
                          childCount: 6,
                        ),
                        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          mainAxisSpacing: 14,
                          crossAxisSpacing: 14,
                          childAspectRatio: 0.62,
                        ),
                      ),
                    )
                  else if (_venuesError != null)
                    SliverFillRemaining(
                      hasScrollBody: false,
                      child: ErrorRetryView(
                        message: _venuesError!,
                        onRetry: _fetchVenues,
                      ),
                    )
                  else if (_apiVenues.isEmpty)
                    SliverFillRemaining(
                      hasScrollBody: false,
                      child: SubcategoryEmptyState(
                        onExploreOtherCategories: () => Navigator.pop(context),
                      ),
                    )
                  else
                    SliverPadding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      sliver: SliverGrid(
                        delegate: SliverChildBuilderDelegate(
                          (context, index) {
                            if (index >= _apiVenues.length) return null;
                            final venue = _apiVenues[index];
                            final em = _toEventModel(venue);
                            return CategoryEventCard(
                              event: em,
                              badgeColor: _accentColor.withOpacity(0.9),
                              onTap: () => Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => VenueDetailScreen(event: em),
                                ),
                              ),
                            );
                          },
                          childCount: _apiVenues.length,
                        ),
                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          mainAxisSpacing: 14,
                          crossAxisSpacing: 14,
                          childAspectRatio: 0.62,
                        ),
                      ),
                    ),
                  if (_isLoadingMore)
                    const SliverToBoxAdapter(
                      child: Padding(
                        padding: EdgeInsets.symmetric(vertical: 20),
                        child: Center(child: AppLoaderInline()),
                      ),
                    ),
                  const SliverToBoxAdapter(child: SizedBox(height: 40)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}


// ── All Categories bottom sheet ──────────────────────────────────────────────
class _VenuesAllCategoriesSheet extends StatefulWidget {
  final List<Map<String, dynamic>> categories;
  final ValueChanged<int> onCategoryTap;

  const _VenuesAllCategoriesSheet({
    required this.categories,
    required this.onCategoryTap,
  });

  @override
  State<_VenuesAllCategoriesSheet> createState() =>
      _VenuesAllCategoriesSheetState();
}

class _VenuesAllCategoriesSheetState
    extends State<_VenuesAllCategoriesSheet> {
  late List<(int, Map<String, dynamic>)> _filtered;
  final TextEditingController _controller = TextEditingController();

  @override
  void initState() {
    super.initState();
    _filtered =
        widget.categories.indexed.map((e) => (e.$1, e.$2)).toList();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _onSearch(String q) {
    setState(() {
      _filtered = q.isEmpty
          ? widget.categories.indexed.map((e) => (e.$1, e.$2)).toList()
          : widget.categories.indexed
              .where((e) => (e.$2['label'] as String)
                  .toLowerCase()
                  .contains(q.toLowerCase()))
              .map((e) => (e.$1, e.$2))
              .toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.82,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              margin: const EdgeInsets.only(top: 12, bottom: 8),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(2)),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
            child: Container(
              decoration: BoxDecoration(
                color: const Color(0xFFF5F5F5),
                borderRadius: BorderRadius.circular(30),
              ),
              child: TextField(
                controller: _controller,
                onChanged: _onSearch,
                style: GoogleFonts.poppins(fontSize: Responsive.sp(context, 13)),
                decoration: InputDecoration(
                  hintText: 'Search venue categories...',
                  hintStyle: GoogleFonts.poppins(
                      fontSize: Responsive.sp(context, 13), color: Colors.grey.shade400),
                  prefixIcon:
                      const Icon(Icons.search, color: Colors.grey, size: 20),
                  suffixIcon: GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child:
                        const Icon(Icons.close, color: Colors.grey, size: 20),
                  ),
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16, vertical: 14),
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                Text(
                  'All Categories',
                  style: GoogleFonts.poppins(
                      fontSize: Responsive.sp(context, 16),
                      fontWeight: FontWeight.w500,
                      color: AppColors.textPrimary),
                ),
                const SizedBox(width: 8),
                Text(
                  '(${_filtered.length} Results Found)',
                  style: GoogleFonts.poppins(
                      fontSize: Responsive.sp(context, 12), color: Colors.grey.shade500),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          Expanded(
            child: _filtered.isEmpty
                ? Center(
                    child: Text('No categories found',
                        style: GoogleFonts.poppins(
                            fontSize: Responsive.sp(context, 14), color: Colors.grey)))
                : GridView.builder(
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 3,
                      mainAxisSpacing: 14,
                      crossAxisSpacing: 14,
                      childAspectRatio: 0.88,
                    ),
                    itemCount: _filtered.length,
                    itemBuilder: (_, i) {
                      final (originalIndex, cat) = _filtered[i];
                      final colors =
                          (cat['gradient'] as List).cast<Color>();
                      return GestureDetector(
                        onTap: () => widget.onCategoryTap(originalIndex),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              child: Container(
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(14),
                                  gradient: LinearGradient(
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                    colors: colors,
                                  ),
                                ),
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(14),
                                  child: Image.asset(
                                    cat['image'] as String,
                                    fit: BoxFit.contain,
                                    errorBuilder: (_, __, ___) => const Icon(
                                        Icons.place,
                                        size: 40,
                                        color: Colors.grey),
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(height: 5),
                            Text(
                              cat['label'] as String,
                              style: GoogleFonts.poppins(
                                  fontSize: Responsive.sp(context, 11),
                                  fontWeight: FontWeight.w500,
                                  color: AppColors.textPrimary),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
