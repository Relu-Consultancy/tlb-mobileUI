import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import '../core/app_colors.dart';
import '../data/dummy_data.dart';
import '../models/event_model.dart';
import '../widgets/filter_bottom_sheet.dart';

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
  final List<GlobalKey> _chipKeys = List.generate(
    DummyData.venuesSeeAllCategories.length,
    (_) => GlobalKey(),
  );

  @override
  void initState() {
    super.initState();
    _selectedCategoryIndex = widget.initialCategoryIndex
        .clamp(0, DummyData.venuesSeeAllCategories.length - 1);
  }

  @override
  void dispose() {
    _chipScrollController.dispose();
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

  List<EventModel> get _filteredVenues {
    final all = DummyData.venuesByCategory[_selectedCategoryIndex];
    if (_selectedFilterIndex == 0) return all;
    final filterTag = _filters[_selectedFilterIndex];
    return all.where((e) => e.tag == filterTag).toList();
  }

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
        backgroundColor: const Color(0xFFF7F7F7),
        body: Column(
          children: [
            // ── Gradient Header ──────────────────────────────────────────
            AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [_currentGradient.first, _accentColor],
                ),
              ),
              child: Padding(
                padding: EdgeInsets.fromLTRB(16, safeTop + 12, 16, 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        GestureDetector(
                          onTap: () => Navigator.pop(context),
                          child: Container(
                            width: 36,
                            height: 36,
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.5),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.arrow_back_ios_new_rounded,
                              size: 16,
                              color: AppColors.textPrimary,
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            _categoryTitle,
                            style: GoogleFonts.poppins(
                              fontSize: 18,
                              fontWeight: FontWeight.w700,
                              color: AppColors.textPrimary,
                            ),
                          ),
                        ),
                        GestureDetector(
                          onTap: () {},
                          child: Container(
                            width: 36,
                            height: 36,
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.5),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.tune_rounded,
                              size: 18,
                              color: AppColors.textPrimary,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),
                    Container(
                      height: 44,
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.75),
                        borderRadius: BorderRadius.circular(24),
                      ),
                      child: Row(
                        children: [
                          const SizedBox(width: 14),
                          const Icon(Icons.search_rounded,
                              size: 20, color: AppColors.textSecondary),
                          const SizedBox(width: 8),
                          Expanded(
                            child: TextField(
                              decoration: InputDecoration(
                                hintText: 'Search $_categoryTitle venues...',
                                hintStyle: GoogleFonts.poppins(
                                  fontSize: 13,
                                  color: AppColors.textSecondary,
                                ),
                                border: InputBorder.none,
                                isDense: true,
                                contentPadding: EdgeInsets.zero,
                              ),
                              style: GoogleFonts.poppins(
                                  fontSize: 13,
                                  color: AppColors.textPrimary),
                            ),
                          ),
                          const SizedBox(width: 14),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // ── Scrollable Body ──────────────────────────────────────────
            Expanded(
              child: CustomScrollView(
                physics: const ClampingScrollPhysics(),
                slivers: [
                  // ── Explore other Venues label ──
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(16, 18, 16, 0),
                      child: Row(
                        children: [
                          Text(
                            'Explore other Venues',
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
                                color: const Color(0xFF2563EB),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  // ── Circle chip row ──
                  SliverToBoxAdapter(
                    child: SizedBox(
                      height: 128,
                      child: ListView.builder(
                        controller: _chipScrollController,
                        scrollDirection: Axis.horizontal,
                        padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
                        itemCount: DummyData.venuesSeeAllCategories.length,
                        itemBuilder: (context, index) {
                          final cat = DummyData.venuesSeeAllCategories[index];
                          final isSelected = index == _selectedCategoryIndex;
                          final catGradient =
                              (cat['gradient'] as List<Color>);
                          return GestureDetector(
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
                                              duration: const Duration(
                                                  milliseconds: 200),
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
                                                    ? Border.all(
                                                        color:
                                                            catGradient.last,
                                                        width: 2.5)
                                                    : null,
                                                boxShadow: [
                                                  BoxShadow(
                                                    color: catGradient.last
                                                        .withOpacity(isSelected
                                                            ? 0.50
                                                            : 0.20),
                                                    blurRadius:
                                                        isSelected ? 12 : 6,
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
                                                  Icon(Icons.place,
                                                      size: 36,
                                                      color:
                                                          catGradient.last),
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
                                        fontSize: 9.5,
                                        fontWeight: isSelected
                                            ? FontWeight.w700
                                            : FontWeight.w500,
                                        height: 1.2,
                                        color: AppColors.textPrimary,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ),

                  // ── Section divider ──
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(16, 18, 16, 0),
                      child: Row(
                        children: [
                          Container(
                              width: 28,
                              height: 1.5,
                              color: const Color(0xFFFFB902)),
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
                            child: Container(
                                height: 1.5,
                                color: const Color(0xFFFFB902)),
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
                                        fontSize: 11.5,
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
                            onTap: () => setState(
                                () => _selectedFilterIndex = filterIndex),
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
                                  fontSize: 11.5,
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

                  // ── Venue cards grid ──
                  const SliverToBoxAdapter(child: SizedBox(height: 14)),
                  if (_filteredVenues.isEmpty)
                    SliverFillRemaining(
                      hasScrollBody: false,
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(24, 40, 24, 24),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            Icon(Icons.location_city_outlined,
                                size: 48,
                                color: _accentColor.withOpacity(0.6)),
                            const SizedBox(height: 12),
                            Text(
                              'No venues in "${_filters[_selectedFilterIndex]}" yet',
                              textAlign: TextAlign.center,
                              style: GoogleFonts.poppins(
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                color: AppColors.textPrimary,
                              ),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              'Try another filter to see what\'s available.',
                              textAlign: TextAlign.center,
                              style: GoogleFonts.poppins(
                                fontSize: 11.5,
                                color: AppColors.textSecondary,
                              ),
                            ),
                          ],
                        ),
                      ),
                    )
                  else
                    SliverPadding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      sliver: SliverGrid(
                        delegate: SliverChildBuilderDelegate(
                          (context, index) {
                            final venues = _filteredVenues;
                            if (index >= venues.length) return null;
                            return _VenueCard(
                              event: venues[index],
                              accentColor: _accentColor,
                            );
                          },
                          childCount: _filteredVenues.length,
                        ),
                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          mainAxisSpacing: 14,
                          crossAxisSpacing: 14,
                          childAspectRatio: 0.72,
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

// ── Venue card widget ────────────────────────────────────────────────────────
class _VenueCard extends StatelessWidget {
  final EventModel event;
  final Color accentColor;

  const _VenueCard({required this.event, required this.accentColor});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.07),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Image with tag overlay
          Stack(
            children: [
              ClipRRect(
                borderRadius:
                    const BorderRadius.vertical(top: Radius.circular(16)),
                child: Image.asset(
                  event.imagePath,
                  height: 120,
                  width: double.infinity,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) =>
                      Container(height: 120, color: Colors.grey.shade200),
                ),
              ),
              if (event.tag != null)
                Positioned(
                  top: 8,
                  left: 8,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: accentColor.withOpacity(0.92),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      event.tag!,
                      style: GoogleFonts.poppins(
                        fontSize: 9.5,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
            ],
          ),
          // Content
          Expanded(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(10, 9, 10, 10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    event.title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.poppins(
                      fontSize: 12.5,
                      fontWeight: FontWeight.w700,
                      color: const Color(0xFF1A1A2E),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      const Icon(Icons.location_on_outlined,
                          size: 11, color: Colors.grey),
                      const SizedBox(width: 3),
                      Expanded(
                        child: Text(
                          event.venue,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: GoogleFonts.poppins(
                              fontSize: 10.5,
                              color: Colors.grey.shade500),
                        ),
                      ),
                    ],
                  ),
                  if (event.rating != null) ...[
                    const SizedBox(height: 3),
                    Row(
                      children: [
                        const Icon(Icons.star_rounded,
                            size: 12, color: Color(0xFFFFB902)),
                        const SizedBox(width: 3),
                        Text(
                          '${event.rating}',
                          style: GoogleFonts.poppins(
                            fontSize: 10.5,
                            fontWeight: FontWeight.w600,
                            color: const Color(0xFF1A1A2E),
                          ),
                        ),
                        const SizedBox(width: 3),
                        Expanded(
                          child: Text(
                            '(${event.reviewCount})',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: GoogleFonts.poppins(
                                fontSize: 10,
                                color: Colors.grey.shade500),
                          ),
                        ),
                      ],
                    ),
                  ],
                  const Spacer(),
                  SizedBox(
                    width: double.infinity,
                    height: 30,
                    child: ElevatedButton(
                      onPressed: () {},
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFFFCC00),
                        foregroundColor: const Color(0xFF1A1A2E),
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20)),
                        padding: EdgeInsets.zero,
                      ),
                      child: Text(
                        'Book Now',
                        style: GoogleFonts.poppins(
                            fontSize: 11.5,
                            fontWeight: FontWeight.w600),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
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
                style: GoogleFonts.poppins(fontSize: 13),
                decoration: InputDecoration(
                  hintText: 'Search venue categories...',
                  hintStyle: GoogleFonts.poppins(
                      fontSize: 13, color: Colors.grey.shade400),
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
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: const Color(0xFF1A1A2E)),
                ),
                const SizedBox(width: 8),
                Text(
                  '(${_filtered.length} Results Found)',
                  style: GoogleFonts.poppins(
                      fontSize: 12, color: Colors.grey.shade500),
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
                            fontSize: 14, color: Colors.grey)))
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
                                  fontSize: 11,
                                  fontWeight: FontWeight.w500,
                                  color: const Color(0xFF1A1A2E)),
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
