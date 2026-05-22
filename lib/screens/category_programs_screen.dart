import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import '../core/app_colors.dart';
import '../core/app_snackbar.dart';
import '../core/responsive.dart';
import '../data/dummy_data.dart';
import '../models/event_model.dart';
import '../providers/location_state.dart';
import '../widgets/category_event_card.dart';
import '../widgets/all_categories_popup.dart';
import '../widgets/category_screen_header.dart';
import '../widgets/filter_bottom_sheet.dart';
import '../widgets/subcategory_empty_state.dart';
import '../models/api_category_model.dart';
import '../models/api_program_model.dart';
import '../services/programs_listing_service.dart';
import '../widgets/app_loader.dart';
import 'program_detail_screen.dart';

class CategoryProgramsScreen extends StatefulWidget {
  final int initialCategoryIndex;

  const CategoryProgramsScreen({
    super.key,
    required this.initialCategoryIndex,
  });

  @override
  State<CategoryProgramsScreen> createState() => _CategoryProgramsScreenState();
}

class _CategoryProgramsScreenState extends State<CategoryProgramsScreen> {
  late int _selectedCategoryIndex;
  int _selectedFilterIndex = 0;
  final ScrollController _chipScrollController = ScrollController();
  final ScrollController _listScrollController = ScrollController();
  late List<GlobalKey> _chipKeys;

  // API category metadata
  List<ApiCategory> _apiCategories = [];
  int? _selectedCategoryId;
  int? _selectedSubcategoryId;
  List<ApiSubcategory> _currentSubcategories = [];

  static const int _pageSize = 20;
  List<ApiProgram> _apiPrograms = [];
  bool _isLoadingPrograms = true;
  bool _isLoadingMore = false;
  bool _hasMore = false;
  int _currentPage = 1;

  @override
  void initState() {
    super.initState();
    _selectedCategoryIndex = widget.initialCategoryIndex
        .clamp(0, DummyData.programsCategories.length - 1);
    _chipKeys = List.generate(
      DummyData.programsCategories.length,
      (_) => GlobalKey(),
    );
    _listScrollController.addListener(_onScroll);
    _fetchApiCategories();
  }

  Future<void> _fetchApiCategories() async {
    try {
      final cats = await ProgramsListingService.fetchProgramCategories();
      if (!mounted) return;
      setState(() => _apiCategories = cats);
    } catch (_) {}
    _resolveAndFetch();
  }

  void _resolveAndFetch() {
    _selectedCategoryId = _resolveId(_categoryTitle);
    _currentSubcategories = _resolveSubs(_selectedCategoryId);
    _fetchPrograms();
  }

  // Normalise names for fuzzy matching (strip newlines, lowercase, collapse whitespace)
  static String _norm(String s) =>
      s.replaceAll('\n', ' ').trim().toLowerCase().replaceAll(RegExp(r'\s+'), ' ');

  int? _resolveId(String label) {
    final needle = _norm(label);
    for (final cat in _apiCategories) {
      final hay = _norm(cat.name);
      // Exact match or one is a prefix of the other (handles truncated dummy labels)
      if (hay == needle || hay.startsWith(needle) || needle.startsWith(hay)) {
        return cat.id;
      }
    }
    return null;
  }

  List<ApiSubcategory> _resolveSubs(int? categoryId) {
    if (categoryId == null) return [];
    try {
      return _apiCategories.firstWhere((c) => c.id == categoryId).subcategories;
    } catch (_) {
      return [];
    }
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
        _hasMore && !_isLoadingMore && !_isLoadingPrograms) {
      _loadMore();
    }
  }

  Future<void> _loadMore() async {
    if (_isLoadingMore || !_hasMore) return;
    setState(() => _isLoadingMore = true);
    try {
      final next = await ProgramsListingService.fetchPrograms(
        categoryId: _selectedCategoryId,
        subcategoryId: _selectedSubcategoryId,
        city: LocationState().selectedCity.value,
        page: _currentPage + 1,
        pageSize: _pageSize,
      );
      if (!mounted) return;
      setState(() {
        _apiPrograms = [..._apiPrograms, ...next.results];
        _currentPage += 1;
        _hasMore = _currentPage * _pageSize < next.count;
        _isLoadingMore = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() => _isLoadingMore = false);
    }
  }

  void _showAllCategories() {
    AllCategoriesPopup.show(
      context,
      DummyData.programsSeeAllCategories,
      onCategoryTap: (index) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) => CategoryProgramsScreen(
              initialCategoryIndex:
                  index.clamp(0, DummyData.programsCategories.length - 1),
            ),
          ),
        );
      },
    );
  }

  Future<void> _fetchPrograms({int? subcategoryId}) async {
    setState(() {
      _isLoadingPrograms = true;
      _currentPage = 1;
      _hasMore = false;
    });
    try {
      final page = await ProgramsListingService.fetchPrograms(
        categoryId: _selectedCategoryId,
        subcategoryId: subcategoryId,
        city: LocationState().selectedCity.value,
        page: 1,
        pageSize: _pageSize,
      );
      if (!mounted) return;
      setState(() {
        _apiPrograms = page.results;
        _hasMore = _pageSize < page.count;
        _isLoadingPrograms = false;
      });
    } catch (e) {
      if (!mounted) return;
      final msg = e.toString().replaceFirst('Exception: ', '');
      setState(() {
        _apiPrograms = [];
        _isLoadingPrograms = false;
      });
      AppSnackBar.error(context, 'Programs: $msg');
    }
  }

  void _selectCategory(int index) {
    setState(() {
      _selectedCategoryIndex = index;
      _selectedFilterIndex = 0;
      _selectedSubcategoryId = null;
    });
    final newTitle = (DummyData.programsCategories[index]['label'] as String)
        .replaceAll('\n', ' ');
    _selectedCategoryId = _resolveId(newTitle);
    _currentSubcategories = _resolveSubs(_selectedCategoryId);
    _fetchPrograms();
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
      DummyData.programsCategories[_selectedCategoryIndex];

  List<Color> get _currentGradient =>
      (_currentCategory['gradient'] as List<Color>);

  Color get _accentColor => _currentGradient.last;

  // Use API subcategories when available, fall back to dummy strings as display-only
  List<String> get _filters => _currentSubcategories.isNotEmpty
      ? ['All', ..._currentSubcategories.map((s) => s.name)]
      : DummyData.programsSubFilters[_selectedCategoryIndex];

  List<ApiProgram> get _filteredPrograms => _apiPrograms;

  EventModel _toEventModel(ApiProgram prg) {
    return EventModel(
      id: prg.id,
      title: prg.title,
      venue: prg.city ?? prg.category?.name ?? 'Multiple',
      imagePath: prg.cover ?? '',
      tag: prg.category?.name,
      rating: prg.averageRating,
      reviewCount: prg.totalReviews > 0 ? '${prg.averageRating} (${prg.totalReviews})' : null,
      description: prg.shortDescription,
    );
  }

  String get _categoryTitle {
    return (_currentCategory['label'] as String).replaceAll('\n', ' ');
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
                  // Explore other Programs row + tinted background
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
                                  'Explore other Programs',
                                  style: GoogleFonts.poppins(
                                    fontSize: Responsive.sp(context, 13),
                                    fontWeight: FontWeight.w600,
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
                                      color: const Color(0xFF5B5BD6),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          SizedBox(
                            height: Responsive.h(context, 132),
                            child: ListView.builder(
                              controller: _chipScrollController,
                              scrollDirection: Axis.horizontal,
                              padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
                              itemCount: DummyData.programsCategories.length,
                              itemBuilder: (context, index) {
                                final cat = DummyData.programsCategories[index];
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
                                      width: 98,
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
                                        padding: const EdgeInsets.fromLTRB(6, 6, 6, 5),
                                        child: Column(
                                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                          children: [
                                            Text(
                                              (cat['label'] as String),
                                              textAlign: TextAlign.center,
                                              maxLines: 2,
                                              overflow: TextOverflow.ellipsis,
                                              style: GoogleFonts.poppins(
                                                fontSize: Responsive.sp(context, 9.5),
                                                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w600,
                                                height: 1.2,
                                                color: AppColors.textPrimary,
                                              ),
                                            ),
                                            Expanded(
                                              child: Image.asset(
                                                cat['image'] as String,
                                                fit: BoxFit.contain,
                                                errorBuilder: (_, __, ___) => const Icon(
                                                  Icons.workspace_premium_outlined,
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

                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(16, 22, 16, 0),
                      child: Row(
                        children: [
                          Expanded(
                            child: Container(height: 1.5, color: const Color(0xFFFFB902)),
                          ),
                          const SizedBox(width: 10),
                          Text(
                            'All $_categoryTitle',
                            style: GoogleFonts.poppins(
                              fontSize: Responsive.sp(context, 14.5),
                              fontWeight: FontWeight.w700,
                              color: AppColors.textPrimary,
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Container(height: 1.5, color: const Color(0xFFFFB902)),
                          ),
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
                        padding:
                            const EdgeInsets.fromLTRB(16, 8, 16, 0),
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
                                        fontWeight: FontWeight.w600,
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
                            onTap: () {
                              int? subId;
                              if (filterIndex > 0 && _currentSubcategories.isNotEmpty) {
                                // filterIndex 1+ maps to _currentSubcategories[filterIndex - 1]
                                subId = _currentSubcategories[filterIndex - 1].id;
                              }
                              setState(() {
                                _selectedFilterIndex = filterIndex;
                                _selectedSubcategoryId = subId;
                              });
                              _fetchPrograms(subcategoryId: subId);
                            },
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 180),
                              margin: const EdgeInsets.only(right: 8),
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 14, vertical: 5),
                              decoration: BoxDecoration(
                                color: isActive
                                    ? const Color(0xFFFFCC00)
                                    : Colors.white,
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(
                                  color: isActive
                                      ? Colors.transparent
                                      : const Color(0xFFE0E0E0),
                                ),
                              ),
                              child: Text(
                                _filters[filterIndex],
                                style: GoogleFonts.poppins(
                                  fontSize: Responsive.sp(context, 11.5),
                                  fontWeight: isActive
                                      ? FontWeight.w700
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

                  // Results grid
                  const SliverToBoxAdapter(child: SizedBox(height: 14)),
                  if (_isLoadingPrograms)
                    const SliverFillRemaining(
                      hasScrollBody: false,
                      child: Center(
                        child: Padding(
                          padding: EdgeInsets.only(top: 40),
                          child: AppLoader(),
                        ),
                      ),
                    )
                  else if (_filteredPrograms.isEmpty)
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
                            final prg = _filteredPrograms[index];
                            final eventModel = _toEventModel(prg);
                            return CategoryEventCard(
                              event: eventModel,
                              badgeColor: _accentColor.withOpacity(0.9),
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(builder: (_) => ProgramDetailScreen(event: eventModel)),
                                );
                              },
                            );
                          },
                          childCount: _filteredPrograms.length,
                        ),
                        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          mainAxisSpacing: 14,
                          crossAxisSpacing: 14,
                          childAspectRatio: 0.55,
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
