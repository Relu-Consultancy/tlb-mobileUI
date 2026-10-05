import 'package:flutter/material.dart';
import '../widgets/app_loader.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import '../core/app_colors.dart';
import '../core/app_snackbar.dart';
import '../core/listing_filters.dart';
import '../core/listing_schedule.dart';
import '../widgets/error_retry_view.dart';
import '../core/responsive.dart';
import '../models/api_event_model.dart';
import '../models/event_model.dart';
import '../providers/location_state.dart';
import '../services/events_listing_service.dart';
import '../widgets/category_event_card.dart';
import '../widgets/category_icon_card.dart';
import '../widgets/category_screen_header.dart';
import '../widgets/filter_bottom_sheet.dart';
import '../widgets/subcategory_empty_state.dart';
import '../widgets/all_categories_popup.dart';
import '../widgets/category_skeleton_card.dart';
import '../core/user_location.dart';
import '../core/listing_source.dart';

class CategoryEventsScreen extends StatefulWidget {
  final List<Map<String, dynamic>> categories;
  final int initialCategoryIndex;

  const CategoryEventsScreen({
    super.key,
    required this.categories,
    required this.initialCategoryIndex,
  });

  @override
  State<CategoryEventsScreen> createState() => _CategoryEventsScreenState();
}

class _CategoryEventsScreenState extends State<CategoryEventsScreen> {
  late int _selectedCategoryIndex;
  int _selectedFilterIndex = 0;

  /// The Sort / Filters sheet's selections (applied to the loaded cards).
  ListingSort? _sort;
  Set<String> _pickedFilters = {};
  final ScrollController _chipScrollController = ScrollController();
  final ScrollController _listScrollController = ScrollController();
  late List<GlobalKey> _chipKeys;

  static const int _pageSize = 20;
  List<ApiEvent> _apiEvents = [];
  bool _isLoadingEvents = true;
  String? _eventsError;
  bool _isLoadingMore = false;
  bool _hasMore = false;
  int _currentPage = 1;

  @override
  void initState() {
    super.initState();
    _selectedCategoryIndex = widget.categories.isEmpty
        ? 0
        : widget.initialCategoryIndex.clamp(0, widget.categories.length - 1);
    _chipKeys = List.generate(widget.categories.length, (_) => GlobalKey());
    _listScrollController.addListener(_onScroll);
    _fetchEvents();
  }

  @override
  void dispose() {
    _chipScrollController.dispose();
    _listScrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_listScrollController.position.pixels >=
        _listScrollController.position.maxScrollExtent - 300 &&
        _hasMore && !_isLoadingMore && !_isLoadingEvents) {
      _loadMore();
    }
  }

  Future<void> _loadMore() async {
    if (_isLoadingMore || !_hasMore) return;
    setState(() => _isLoadingMore = true);
    try {
      final next = await EventsListingService.fetchEvents(
        lat: UserLocation.lat,
        lng: UserLocation.lng,
        category: _categoryTitle,
        subcategory: _selectedFilterIndex <= 0 ||
                _selectedFilterIndex >= _filters.length
            ? null
            : _filters[_selectedFilterIndex],
        city: LocationState().cityOrNull,
        page: _currentPage + 1,
        pageSize: _pageSize,
      );
      if (!mounted) return;
      setState(() {
        _apiEvents = [..._apiEvents, ...next.results];
        _currentPage += 1;
        _hasMore = _currentPage * _pageSize < next.count;
        _isLoadingMore = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() => _isLoadingMore = false);
    }
  }

  Future<void> _fetchEvents({String? subcategory}) async {
    setState(() {
      _isLoadingEvents = true;
      _eventsError = null;
      _currentPage = 1;
      _hasMore = false;
    });
    try {
      final page = await EventsListingService.fetchEvents(
        lat: UserLocation.lat,
        lng: UserLocation.lng,
        category: _categoryTitle,
        subcategory: subcategory,
        city: LocationState().cityOrNull,
        page: 1,
        pageSize: _pageSize,
      );
      if (!mounted) return;
      setState(() {
        _apiEvents = page.results;
        _hasMore = _pageSize < page.count;
        _isLoadingEvents = false;
      });
    } catch (e) {
      if (!mounted) return;
      final msg = e.toString().replaceFirst('Exception: ', '');
      setState(() {
        _apiEvents = [];
        _eventsError = msg;
        _isLoadingEvents = false;
      });
    }
  }

  // "See All" — opens the full category grid; tapping one selects it here.
  void _showAllCategories() {
    AllCategoriesPopup.show(
      context,
      widget.categories,
      lineIcons: true,
      darkBackground: true,
      onCategoryTap: (index) =>
          _selectCategory(index.clamp(0, widget.categories.length - 1)),
    );
  }

  void _selectCategory(int index) {
    setState(() {
      _selectedCategoryIndex = index;
      _selectedFilterIndex = 0;
    });
    _fetchEvents(subcategory: null);
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
      widget.categories[_selectedCategoryIndex];

  List<Color> get _currentGradient =>
      (_currentCategory['gradient'] as List<Color>);

  Color get _accentColor => _currentGradient.last;

  List<String> get _filters {
    final subs = (_currentCategory['subcategories'] as List?)?.cast<String>() ?? [];
    return ['All', ...subs];
  }

  // Ended events are deliberately still returned by the API — the client
  // decides whether to hide, grey out, or badge them. Hidden here: a
  // finished event has nothing left to book, so surfacing it as if it were
  // current just leads to a dead end when tapped.
  List<ApiEvent> get _filteredEvents {
    final live = _apiEvents
        .where((e) => !ListingSchedule.hasEnded(e.endDatetime))
        .toList();
    return ListingFilters.sort(
      ListingFilters.apply(live, _pickedFilters, _filterOptions),
      _sort,
      price: _price,
      distance: (e) => e.distanceKm,
    );
  }

  /// A free event sorts as 0 so "Low to High" leads with it.
  static double? _price(ApiEvent e) =>
      e.priceType == 'free' ? 0 : ListingFilters.parsePrice(e.priceFrom);

  static final List<ListingFilter<ApiEvent>> _filterOptions = [
    for (final f in const [
      'Workshop',
      'Camp',
      'Masterclass',
      'Competition',
      'Showcase',
      'Demo',
    ])
      ListingFilter<ApiEvent>(
          f, 'format', (e) => e.format.toLowerCase() == f.toLowerCase()),
    ListingFilter<ApiEvent>('Free', 'cost', (e) => e.priceType == 'free'),
    ListingFilter<ApiEvent>('Paid', 'cost', (e) => e.priceType != 'free'),
    ...ListingFilters.priceBands<ApiEvent>(_price),
  ];

  int get _activeFilterCount =>
      (_sort != null ? 1 : 0) + _pickedFilters.length;

  String get _categoryTitle =>
      (_currentCategory['label'] as String).replaceAll('\n', ' ');

  EventModel _toEventModel(ApiEvent event) {
    return EventModel(
      distanceKm: event.distanceKm,
      ageGroup: event.ageGroup?.displayRange,
      id: event.id,
      title: event.title,
      venue: event.city,
      imagePath: event.coverUrl ?? '',
      tag: event.subcategory?.name,
      price: event.priceFrom != null ? double.tryParse(event.priceFrom!) : null,
    );
  }

  Future<void> _showFilterSheet() async {
    final cats = _filters.where((f) => f != 'All').toList();
    final result = await FilterBottomSheet.show(
      context,
      sortOptions: [for (final o in ListingSort.forType(hasPrice: true)) o.label],
      filterOptions: [for (final f in _filterOptions) f.label],
      categoryOptions: cats,
      singleCategory: true,
      initialSort: _sort?.label,
      initialFilters: _pickedFilters.toList(),
      initialCategories: [
        if (_selectedFilterIndex > 0 && _selectedFilterIndex < _filters.length)
          _filters[_selectedFilterIndex],
      ],
    );
    if (result == null || !mounted) return;

    final sort = ListingSort.fromLabel(result.selectedSort);
    final pickedCategory = result.selectedCategories.isEmpty
        ? 0
        : _filters.indexOf(result.selectedCategories.first).clamp(0, _filters.length - 1);
    setState(() {
      _sort = sort;
      _pickedFilters = result.selectedFilters.toSet();
    });
    if (sort == ListingSort.distance && !UserLocation.isKnown) {
      AppSnackBar.show(context, 'Turn on location to sort by distance.');
    }
    // The category is the subcategory chip row: choosing one here is the same
    // as tapping its chip, so it refetches.
    if (pickedCategory != _selectedFilterIndex) {
      setState(() => _selectedFilterIndex = pickedCategory);
      _fetchEvents(subcategory: pickedCategory == 0 ? null : _filters[pickedCategory]);
    }
  }

  @override
  Widget build(BuildContext context) {
    ListingSource.mark(context, ListingSource.category);
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
                  // Explore other Categories row
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
                                  'Explore other Categories',
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
                          SizedBox(
                            // 86pt card at the shared 0.650 ratio is 132
                            // tall; +24 for the list's vertical padding, which
                            // also absorbs the selected card's 1.12 scale.
                            height: Responsive.h(context, 156),
                            child: ListView.builder(
                              controller: _chipScrollController,
                              scrollDirection: Axis.horizontal,
                              padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
                              itemCount: widget.categories.length,
                              itemBuilder: (context, index) {
                                final cat = widget.categories[index];
                                final isSelected = index == _selectedCategoryIndex;
                                return AnimatedScale(
                                  scale: isSelected ? 1.12 : 1.0,
                                  duration: const Duration(milliseconds: 200),
                                  curve: Curves.easeInOut,
                                  child: Container(
                                    key: _chipKeys[index],
                                    width: 86,
                                    margin: const EdgeInsets.only(right: 10),
                                    child: CategoryIconCard.fromCategory(
                                      cat,
                                      // "Communication" only fits an 86pt card
                                      // at 9.5 (82.6pt at 10, vs 79.1 available).
                                      labelFontSize: 9.5,
                                      selected: isSelected,
                                      onTap: () => _selectCategory(index),
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

                  // Section divider "All [Category Name]"
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(16, 22, 16, 0),
                      child: Row(
                        children: [
                          Expanded(child: Container(height: 1.5, color: AppColors.starAmber)),
                          const SizedBox(width: 10),
                          Text(
                            'All $_categoryTitle',
                            style: GoogleFonts.poppins(
                              fontSize: Responsive.sp(context, 17),
                              fontWeight: FontWeight.w600,
                              color: AppColors.textPrimary,
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(child: Container(height: 1.5, color: AppColors.starAmber)),
                        ],
                      ),
                    ),
                  ),

                  // Filter chips row
                  SliverToBoxAdapter(
                    child: SizedBox(
                      height: 42,
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Pinned: stays put while the subcategory chips
                          // scroll beside it.
                          Padding(
                            padding: const EdgeInsets.fromLTRB(16, 8, 0, 0),
                            child: GestureDetector(
                              onTap: _showFilterSheet,
                              child: Container(
                                margin: const EdgeInsets.only(right: 8),
                                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 5),
                                decoration: BoxDecoration(
                                  color: AppColors.textPrimary,
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Text(
                                      _activeFilterCount > 0 ? 'Filters ($_activeFilterCount)' : 'Filters',
                                      style: GoogleFonts.poppins(
                                        fontSize: Responsive.sp(context, 11.5),
                                        fontWeight: FontWeight.w500,
                                        color: Colors.white,
                                      ),
                                    ),
                                    const SizedBox(width: 4),
                                    const Icon(Icons.keyboard_arrow_down_rounded, size: 15, color: Colors.white),
                                  ],
                                ),
                              ),
                            ),
                          ),
                          Expanded(child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        padding: const EdgeInsets.fromLTRB(0, 8, 16, 0),
                        itemCount: _filters.length,
                        itemBuilder: (context, index) {
                          final filterIndex = index;
                          final isActive = filterIndex == _selectedFilterIndex;
                          return GestureDetector(
                            onTap: () {
                            setState(() => _selectedFilterIndex = filterIndex);
                            final sub = filterIndex == 0 ? null : _filters[filterIndex];
                            _fetchEvents(subcategory: sub);
                          },
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 180),
                              alignment: Alignment.center,
                              margin: const EdgeInsets.only(right: 8),
                              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 5),
                              decoration: BoxDecoration(
                                // Selected: transparent golden tint + dark-yellow border.
                                color: isActive ? const Color(0x26FFCC00) : Colors.white,
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(
                                  color: isActive ? const Color(0xFFE6A800) : const Color(0xFFE0E0E0),
                                  width: isActive ? 1.5 : 1,
                                ),
                              ),
                              child: Text(
                                _filters[filterIndex],
                                style: GoogleFonts.poppins(
                                  fontSize: Responsive.sp(context, 11.5),
                                  fontWeight: isActive ? FontWeight.w500 : FontWeight.w500,
                                  color: isActive ? AppColors.textPrimary : AppColors.textSecondary,
                                ),
                              ),
                            ),
                          );
                        },
                      )),
                        ],
                      ),
                    ),
                  ),

                  // Event grid
                  const SliverToBoxAdapter(child: SizedBox(height: 14)),
                  if (_isLoadingEvents)
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
                  else if (_eventsError != null)
                    SliverFillRemaining(
                      hasScrollBody: false,
                      child: ErrorRetryView(
                        message: _eventsError!,
                        onRetry: () => _fetchEvents(
                          subcategory: _selectedFilterIndex <= 0 ||
                                  _selectedFilterIndex >= _filters.length
                              ? null
                              : _filters[_selectedFilterIndex],
                        ),
                      ),
                    )
                  else if (_filteredEvents.isEmpty)
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
                            final events = _filteredEvents;
                            if (index >= events.length) return null;
                            return CategoryEventCard(
                              event: _toEventModel(events[index]),
                            );
                          },
                          childCount: _filteredEvents.length,
                        ),
                        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
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
