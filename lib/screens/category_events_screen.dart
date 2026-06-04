import 'package:flutter/material.dart';
import '../widgets/app_loader.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import '../core/app_colors.dart';
import '../core/app_snackbar.dart';
import '../core/responsive.dart';
import '../models/api_event_model.dart';
import '../models/event_model.dart';
import '../providers/location_state.dart';
import '../services/events_listing_service.dart';
import '../widgets/category_event_card.dart';
import '../widgets/category_screen_header.dart';
import '../widgets/filter_bottom_sheet.dart';
import '../widgets/subcategory_empty_state.dart';

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
  final ScrollController _chipScrollController = ScrollController();
  final ScrollController _listScrollController = ScrollController();
  late List<GlobalKey> _chipKeys;

  static const int _pageSize = 20;
  List<ApiEvent> _apiEvents = [];
  bool _isLoadingEvents = true;
  bool _isLoadingMore = false;
  bool _hasMore = false;
  int _currentPage = 1;

  @override
  void initState() {
    super.initState();
    _selectedCategoryIndex = widget.initialCategoryIndex.clamp(0, widget.categories.length - 1);
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
        category: _categoryTitle,
        subcategory: _selectedFilterIndex == 0 ? null : _filters[_selectedFilterIndex],
        city: LocationState().selectedCity.value,
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
      _currentPage = 1;
      _hasMore = false;
    });
    try {
      final page = await EventsListingService.fetchEvents(
        category: _categoryTitle,
        subcategory: subcategory,
        city: LocationState().selectedCity.value,
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
        _isLoadingEvents = false;
      });
      AppSnackBar.error(context, 'Events: $msg');
    }
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

  List<ApiEvent> get _filteredEvents => _apiEvents;

  String get _categoryTitle =>
      (_currentCategory['label'] as String).replaceAll('\n', ' ');

  EventModel _toEventModel(ApiEvent event) {
    return EventModel(
      id: event.id,
      title: event.title,
      venue: event.city,
      imagePath: event.coverUrl ?? '',
      tag: event.subcategory?.name,
      price: event.priceFrom != null ? double.tryParse(event.priceFrom!) : null,
    );
  }

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
        'Weekly Classes',
        'Monthly Classes',
        'Term Courses',
        'Bootcamp',
        'Certification Course',
        'Trial Class',
        'Holiday Camp',
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
                                  onTap: () {},
                                  child: Text(
                                    'See All >',
                                    style: GoogleFonts.poppins(
                                      fontSize: Responsive.sp(context, 12),
                                      fontWeight: FontWeight.w500,
                                      color: const Color(0xFF5B5BD6),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          SizedBox(
                            height: Responsive.h(context, 110),
                            child: ListView.builder(
                              controller: _chipScrollController,
                              scrollDirection: Axis.horizontal,
                              padding: const EdgeInsets.fromLTRB(16, 10, 16, 4),
                              itemCount: widget.categories.length,
                              itemBuilder: (context, index) {
                                final cat = widget.categories[index];
                                final isSelected = index == _selectedCategoryIndex;
                                final catGradient = cat['gradient'] as List<Color>;
                                return AnimatedScale(
                                  scale: isSelected ? 1.12 : 1.0,
                                  duration: const Duration(milliseconds: 200),
                                  curve: Curves.easeInOut,
                                  child: GestureDetector(
                                    key: _chipKeys[index],
                                    onTap: () => _selectCategory(index),
                                    child: AnimatedContainer(
                                      duration: const Duration(milliseconds: 200),
                                      width: 86,
                                      margin: const EdgeInsets.only(right: 10),
                                      decoration: BoxDecoration(
                                        gradient: LinearGradient(
                                          begin: Alignment.topCenter,
                                          end: Alignment.bottomCenter,
                                          colors: [Colors.white, catGradient.last],
                                        ),
                                        borderRadius: BorderRadius.circular(14),
                                        border: isSelected
                                            ? Border.all(color: catGradient.last, width: 2.5)
                                            : Border.all(color: Colors.transparent, width: 2.5),
                                        boxShadow: [
                                          BoxShadow(
                                            color: catGradient.last.withOpacity(isSelected ? 0.45 : 0.15),
                                            blurRadius: isSelected ? 10 : 5,
                                            offset: const Offset(0, 3),
                                          ),
                                        ],
                                      ),
                                      child: Padding(
                                        padding: const EdgeInsets.fromLTRB(6, 7, 6, 6),
                                        child: Column(
                                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                          children: [
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
                                            Expanded(
                                              child: Image.asset(
                                                cat['image'] as String,
                                                fit: BoxFit.contain,
                                                errorBuilder: (_, __, ___) => const Icon(
                                                  Icons.category,
                                                  color: Colors.grey,
                                                  size: 28,
                                                ),
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

                  // Section divider "All [Category Name]"
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(16, 22, 16, 0),
                      child: Row(
                        children: [
                          Expanded(child: Container(height: 1.5, color: const Color(0xFFFFB902))),
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
                          Expanded(child: Container(height: 1.5, color: const Color(0xFFFFB902))),
                        ],
                      ),
                    ),
                  ),

                  // Filter chips row
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
                                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 5),
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
                                    const Icon(Icons.keyboard_arrow_down_rounded, size: 15, color: Colors.white),
                                  ],
                                ),
                              ),
                            );
                          }
                          final filterIndex = index - 1;
                          final isActive = filterIndex == _selectedFilterIndex;
                          return GestureDetector(
                            onTap: () {
                            setState(() => _selectedFilterIndex = filterIndex);
                            final sub = filterIndex == 0 ? null : _filters[filterIndex];
                            _fetchEvents(subcategory: sub);
                          },
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 180),
                              margin: const EdgeInsets.only(right: 8),
                              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 5),
                              decoration: BoxDecoration(
                                color: isActive ? const Color(0xFFFFCC00) : Colors.white,
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(
                                  color: isActive ? Colors.transparent : const Color(0xFFE0E0E0),
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
                      ),
                    ),
                  ),

                  // Event grid
                  const SliverToBoxAdapter(child: SizedBox(height: 14)),
                  if (_isLoadingEvents)
                    const SliverFillRemaining(
                      hasScrollBody: false,
                      child: AppLoader(),
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
                              badgeColor: _accentColor.withOpacity(0.9),
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
