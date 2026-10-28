import '../core/app_snackbar.dart';
import '../core/listing_filters.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import '../core/app_colors.dart';
import '../widgets/error_retry_view.dart';
import '../core/responsive.dart';
import '../data/dummy_data.dart';
import '../models/event_model.dart';
import '../models/api_class_model.dart';
import '../providers/location_state.dart';
import '../services/classes_listing_service.dart';
import '../widgets/category_event_card.dart';
import '../widgets/category_icon_card.dart';
import '../widgets/category_skeleton_card.dart';
import '../widgets/all_categories_popup.dart';
import '../widgets/category_screen_header.dart';
import '../widgets/filter_bottom_sheet.dart';
import '../widgets/subcategory_empty_state.dart';
import '../widgets/app_loader.dart';
import 'class_detail_screen.dart';
import '../core/user_location.dart';
import '../core/listing_source.dart';
import '../services/activity_service.dart';

class CategoryClassesScreen extends StatefulWidget {
  final int initialCategoryIndex;

  const CategoryClassesScreen({
    super.key,
    required this.initialCategoryIndex,
  });

  @override
  State<CategoryClassesScreen> createState() => _CategoryClassesScreenState();
}

class _CategoryClassesScreenState extends State<CategoryClassesScreen> {
  late int _selectedCategoryIndex;
  int _selectedFilterIndex = 0;

  /// The Sort / Filters sheet's selections (applied to the loaded cards).
  ListingSort? _sort;
  Set<String> _pickedFilters = {};
  final ScrollController _chipScrollController = ScrollController();
  final ScrollController _listScrollController = ScrollController();
  late List<GlobalKey> _chipKeys;

  static const int _pageSize = 20;
  List<ApiClass> _apiClasses = [];
  bool _isLoadingClasses = true;
  String? _classesError;
  bool _isLoadingMore = false;
  bool _hasMore = false;
  int _currentPage = 1;

  @override
  void initState() {
    super.initState();
    _selectedCategoryIndex = widget.initialCategoryIndex
        .clamp(0, DummyData.classesCategories.length - 1);
    _chipKeys = List.generate(
      DummyData.classesCategories.length,
      (_) => GlobalKey(),
    );
    _listScrollController.addListener(_onScroll);
    _fetchClasses();
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
        _hasMore && !_isLoadingMore && !_isLoadingClasses) {
      _loadMore();
    }
  }

  Future<void> _loadMore() async {
    if (_isLoadingMore || !_hasMore) return;
    setState(() => _isLoadingMore = true);
    try {
      final next = await ClassesListingService.fetchClasses(
        lat: UserLocation.lat,
        lng: UserLocation.lng,
        category: _apiCategoryName,
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
        _apiClasses = [..._apiClasses, ...next.results];
        _currentPage += 1;
        _hasMore = _currentPage * _pageSize < next.count;
        _isLoadingMore = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() => _isLoadingMore = false);
    }
  }

  Future<void> _fetchClasses({String? subcategory}) async {
    setState(() {
      _isLoadingClasses = true;
      _classesError = null;
      _currentPage = 1;
      _hasMore = false;
    });
    try {
      final page = await ClassesListingService.fetchClasses(
        lat: UserLocation.lat,
        lng: UserLocation.lng,
        category: _apiCategoryName,
        subcategory: subcategory,
        city: LocationState().cityOrNull,
        page: 1,
        pageSize: _pageSize,
      );
      if (!mounted) return;
      setState(() {
        _apiClasses = page.results;
        _hasMore = _pageSize < page.count;
        _isLoadingClasses = false;
      });
    } catch (e) {
      if (!mounted) return;
      final msg = e.toString().replaceFirst('Exception: ', '');
      setState(() {
        _apiClasses = [];
        _classesError = msg;
        _isLoadingClasses = false;
      });
    }
  }

  void _showAllCategories() {
    AllCategoriesPopup.show(
      context,
      DummyData.classesSeeAllCategories,
      lineIcons: true,
      darkBackground: true,
      cardMetrics: CategoryCardMetrics.classes,
      onCategoryTap: (index) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) => CategoryClassesScreen(
              initialCategoryIndex: index.clamp(0, DummyData.classesCategories.length - 1),
            ),
          ),
        );
      },
    );
  }

  void _selectCategory(int index) {
    setState(() {
      _selectedCategoryIndex = index;
      _selectedFilterIndex = 0;
    });
    _fetchClasses(subcategory: null);
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
      DummyData.classesCategories[_selectedCategoryIndex];

  List<Color> get _currentGradient =>
      (_currentCategory['gradient'] as List<Color>);

  Color get _accentColor => _currentGradient.last;

  List<String> get _filters =>
      DummyData.classesSubFilters[_selectedCategoryIndex];

  // Classes have no end date to filter by — they're an open-ended recurring
  // schedule, not a run with a finish line (see ListingSchedule's doc). The
  // partner-controlled "not currently bookable" signal here is is_paused
  // instead.
  List<ApiClass> get _filteredClasses {
    final live = _apiClasses.where((c) => !c.isPaused).toList();
    return ListingFilters.sort(
      ListingFilters.apply(live, _pickedFilters, _filterOptions),
      _sort,
      price: (c) => c.price,
      distance: (c) => c.distanceKm,
      // Top Picks: best rated first, then most reviewed.
      rank: (c) => c.averageRating * 1000 + c.totalReviews,
    );
  }

  static final List<ListingFilter<ApiClass>> _filterOptions = [
    ...ListingFilters.priceBands<ApiClass>((c) => c.price),
    ListingFilter<ApiClass>('Rated 4+', 'rating', (c) => c.averageRating >= 4),
  ];

  /// The applied set — category, subcategory chip, sort and Filters-tab picks
  /// — for the activity log. Once per distinct set (the service skips repeats).
  void _reportFilters() => ActivityService.trackFilters('category_classes', {
        'category': _categoryTitle,
        'subcategory': _selectedFilterIndex > 0 &&
                _selectedFilterIndex < _filters.length
            ? _filters[_selectedFilterIndex]
            : null,
        'sort': _sort?.label,
        'filters': _pickedFilters.toList(),
      });

  int get _activeFilterCount =>
      (_sort != null ? 1 : 0) + _pickedFilters.length;

  String get _categoryTitle {
    return (_currentCategory['label'] as String).replaceAll('\n', ' ');
  }

  String get _apiCategoryName {
    return (_currentCategory['apiName'] as String?) ??
        (_currentCategory['label'] as String).replaceAll('\n', ' ');
  }

  EventModel _toEventModel(ApiClass cls) {
    return EventModel(
      distanceKm: cls.distanceKm,
      id: cls.id,
      title: cls.title,
      venue: cls.category.name, // Usually city, but classes might have organizer in another field. We'll use category or city for now.
      imagePath: cls.coverUrl ?? '',
      tag: cls.category.name,
      rating: cls.averageRating,
      reviewCount: cls.totalReviews > 0 ? '${cls.averageRating} (${cls.totalReviews})' : null,
      description: cls.shortDescription,
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
    // Reported after the chip change below has been applied.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _reportFilters();
    });
    if (sort == ListingSort.distance && !UserLocation.isKnown) {
      AppSnackBar.show(context, 'Turn on location to sort by distance.');
    }
    // The category is the subcategory chip row: choosing one here is the same
    // as tapping its chip, so it refetches.
    if (pickedCategory != _selectedFilterIndex) {
      setState(() => _selectedFilterIndex = pickedCategory);
      _fetchClasses(subcategory: pickedCategory == 0 ? null : _filters[pickedCategory]);
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
                  // Explore other Categories row + tinted background
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
                              itemCount: DummyData.classesCategories.length,
                              itemBuilder: (context, index) {
                                final cat = DummyData.classesCategories[index];
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
                                      metrics: CategoryCardMetrics.classes,
                                      // Longest word ("Communication") fits an
                                      // 86pt card only at 9.5.
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

                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(16, 22, 16, 0),
                      child: Row(
                        children: [
                          Expanded(
                            child: Container(height: 1.5, color: AppColors.starAmber),
                          ),
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
                          Expanded(
                            child: Container(height: 1.5, color: AppColors.starAmber),
                          ),
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
                              _fetchClasses(subcategory: sub);
                              _reportFilters();
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

                  // Results grid
                  const SliverToBoxAdapter(child: SizedBox(height: 14)),
                  if (_isLoadingClasses)
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
                  else if (_classesError != null)
                    SliverFillRemaining(
                      hasScrollBody: false,
                      child: ErrorRetryView(
                        message: _classesError!,
                        onRetry: () => _fetchClasses(
                          subcategory: _selectedFilterIndex <= 0 ||
                                  _selectedFilterIndex >= _filters.length
                              ? null
                              : _filters[_selectedFilterIndex],
                        ),
                      ),
                    )
                  else if (_filteredClasses.isEmpty)
                    SliverFillRemaining(
                      hasScrollBody: false,
                      child: SubcategoryEmptyState(
                        onExploreOtherCategories: _showAllCategories,
                      ),
                    )
                  else
                    SliverPadding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      sliver: SliverGrid(
                        delegate: SliverChildBuilderDelegate(
                          (context, index) {
                            final classes = _filteredClasses;
                            if (index >= classes.length) return null;
                            final eventModel = _toEventModel(classes[index]);
                            return CategoryEventCard(
                              event: eventModel,
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => ClassDetailScreen(event: eventModel),
                                  ),
                                );
                              },
                            );
                          },
                          childCount: _filteredClasses.length,
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