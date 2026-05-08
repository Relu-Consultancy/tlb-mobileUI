import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import '../core/app_colors.dart';
import '../data/dummy_data.dart';
import '../models/event_model.dart';
import '../widgets/category_event_card.dart';
import '../widgets/all_categories_popup.dart';
import '../widgets/category_screen_header.dart';
import '../widgets/filter_bottom_sheet.dart';
import '../widgets/subcategory_empty_state.dart';

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
  final ScrollController _chipScrollController = ScrollController();
  final List<GlobalKey> _chipKeys = List.generate(
    DummyData.classesCategories.length,
    (_) => GlobalKey(),
  );

  @override
  void initState() {
    super.initState();
    _selectedCategoryIndex = widget.initialCategoryIndex
        .clamp(0, DummyData.classesCategories.length - 1);
  }

  @override
  void dispose() {
    _chipScrollController.dispose();
    super.dispose();
  }

  void _showAllCategories() {
    AllCategoriesPopup.show(
      context,
      DummyData.classesSeeAllCategories,
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

  List<EventModel> get _filteredEvents {
    final all = DummyData.classesByCategory[_selectedCategoryIndex];
    if (_selectedFilterIndex == 0) return all;
    final filterTag = _filters[_selectedFilterIndex];
    return all.where((e) => e.tag == filterTag).toList();
  }

  String get _categoryTitle {
    return (_currentCategory['label'] as String).replaceAll('\n', ' ');
  }

  void _showFilterSheet() {
    // Remove 'All' from sub-filters for the Categories tab
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
                                    fontSize: 13,
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
                                      fontSize: 12,
                                      fontWeight: FontWeight.w500,
                                      color: const Color(0xFF5B5BD6),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          SizedBox(
                            height: 110,
                            child: ListView.builder(
                              controller: _chipScrollController,
                              scrollDirection: Axis.horizontal,
                              padding: const EdgeInsets.fromLTRB(16, 10, 16, 4),
                              itemCount: DummyData.classesCategories.length,
                              itemBuilder: (context, index) {
                                final cat = DummyData.classesCategories[index];
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
                                              (cat['label'] as String),
                                              textAlign: TextAlign.center,
                                              maxLines: 2,
                                              overflow: TextOverflow.ellipsis,
                                              style: GoogleFonts.poppins(
                                                fontSize: 9.5,
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
                                                  Icons.school_outlined,
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
                              fontSize: 14.5,
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
                                        fontSize: 11.5,
                                        fontWeight: FontWeight.w600,
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
                            onTap: () => setState(() => _selectedFilterIndex = filterIndex),
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
                                  fontSize: 11.5,
                                  fontWeight: isActive ? FontWeight.w700 : FontWeight.w500,
                                  color: isActive ? AppColors.textPrimary : AppColors.textSecondary,
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
                  if (_filteredEvents.isEmpty)
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
                            final events = _filteredEvents;
                            if (index >= events.length) return null;
                            return CategoryEventCard(
                              event: events[index],
                              badgeColor: _accentColor.withOpacity(0.9),
                            );
                          },
                          childCount: _filteredEvents.length,
                        ),
                        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          mainAxisSpacing: 14,
                          crossAxisSpacing: 14,
                          childAspectRatio: 0.58,
                        ),
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