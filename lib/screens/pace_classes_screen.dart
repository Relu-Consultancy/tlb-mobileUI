import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

import '../core/app_colors.dart';
import '../core/app_snackbar.dart';
import '../core/responsive.dart';
import '../data/dummy_data.dart';
import '../models/api_class_model.dart';
import '../models/event_model.dart';
import '../providers/location_state.dart';
import '../services/classes_listing_service.dart';
import '../widgets/category_event_card.dart';
import '../widgets/category_skeleton_card.dart';
import '../widgets/error_retry_view.dart';
import '../widgets/format_circle_label.dart';
import '../widgets/subcategory_empty_state.dart';

/// Listing grid shared with the category and format screens — two up, 0.62
/// ratio — so every "browse a slice of the catalogue" screen presents its
/// results the same way.
const SliverGridDelegateWithFixedCrossAxisCount _kListingGrid =
    SliverGridDelegateWithFixedCrossAxisCount(
  crossAxisCount: 2,
  mainAxisSpacing: 14,
  crossAxisSpacing: 14,
  childAspectRatio: 0.62,
);

/// Classes filtered by how long a commitment they ask for — the "Pick Your
/// Pace" row on the Classes tab, which until now was inert artwork.
///
/// Deliberately the same shape as [FormatEventsScreen]: a tinted header
/// carrying the pace discs, a divider, then the two-up grid. Browsing by pace
/// and browsing by format are the same task on a different axis, so they
/// should not look like different features.
class PaceClassesScreen extends StatefulWidget {
  final int initialPaceIndex;

  const PaceClassesScreen({super.key, required this.initialPaceIndex});

  @override
  State<PaceClassesScreen> createState() => _PaceClassesScreenState();
}

class _PaceClassesScreenState extends State<PaceClassesScreen> {
  late int _selectedIndex;
  List<ApiClass> _classes = [];
  bool _isLoading = true;
  String? _error;

  /// Bumped on every fetch. A response whose generation is stale is dropped:
  /// tapping through several paces quickly issues overlapping requests, and
  /// the filtered ones do not necessarily come back in the order they were
  /// sent.
  int _generation = 0;

  @override
  void initState() {
    super.initState();
    _selectedIndex =
        widget.initialPaceIndex.clamp(0, DummyData.pickYourPace.length - 1);
    _fetchClasses();
  }

  Map<String, dynamic> get _currentPace =>
      DummyData.pickYourPace[_selectedIndex];

  /// The disc labels wrap over two lines ("Weekly\nClasses"); the heading
  /// wants that as one.
  String get _paceLabel =>
      (_currentPace['label'] as String).replaceAll('\n', ' ');

  String get _paceSlug => _currentPace['paceSlug'] as String;
  Color get _accentColor => _currentPace['accentColor'] as Color;

  Future<void> _fetchClasses() async {
    final generation = ++_generation;
    setState(() {
      _isLoading = true;
      _error = null;
    });
    try {
      // Filtered server-side: unlike events, a class list row carries no
      // format field, so it could not be narrowed after the fact anyway.
      final page = await ClassesListingService.fetchClasses(
        format: _paceSlug,
        city: LocationState().selectedCity.value,
        pageSize: 50,
      );
      if (!mounted || generation != _generation) return;
      setState(() {
        _classes = page.results.where((c) => !c.isPaused).toList();
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted || generation != _generation) return;
      final msg = e.toString().replaceFirst('Exception: ', '');
      setState(() {
        _classes = [];
        _error = msg;
        _isLoading = false;
      });
      AppSnackBar.error(context, msg);
    }
  }

  void _selectPace(int index) {
    if (index == _selectedIndex) return;
    setState(() => _selectedIndex = index);
    _fetchClasses();
  }

  EventModel _toEventModel(ApiClass cls) => EventModel(
        id: cls.id,
        title: cls.title,
        venue: cls.category.name,
        imagePath: cls.coverUrl ?? '',
        tag: cls.category.name,
        rating: cls.averageRating,
        reviewCount: cls.totalReviews > 0
            ? '${cls.averageRating} (${cls.totalReviews})'
            : null,
        description: cls.shortDescription,
      );

  Widget _paceCircle(int index) {
    final pace = DummyData.pickYourPace[index];
    final isSelected = index == _selectedIndex;
    const double size = 90;

    return GestureDetector(
      onTap: () => _selectPace(index),
      child: Container(
        width: size,
        margin: const EdgeInsets.only(right: 14),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              width: size,
              height: size,
              child: OverflowBox(
                maxWidth: size * 1.2,
                maxHeight: size * 1.2,
                child: AnimatedScale(
                  duration: const Duration(milliseconds: 220),
                  curve: Curves.easeInOut,
                  scale: isSelected ? 1.12 : 1.0,
                  child: Container(
                    width: size,
                    height: size,
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.white,
                    ),
                    padding: const EdgeInsets.all(10),
                    child: Image.asset(
                      pace['image'] as String,
                      fit: BoxFit.contain,
                      errorBuilder: (_, __, ___) => const Icon(
                        Icons.school_outlined,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 8),
            FormatCircleLabel(
              label: (pace['label'] as String).replaceAll('\n', ' '),
              fontSize: 11,
              selected: isSelected,
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final safeTop = MediaQuery.of(context).padding.top;

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light,
      child: Scaffold(
        backgroundColor: Colors.white,
        body: Column(
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 350),
              curve: Curves.easeInOut,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomCenter,
                  colors: [_accentColor, _accentColor.withOpacity(0.78)],
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(height: safeTop + 10),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Row(
                      children: [
                        GestureDetector(
                          onTap: () => Navigator.pop(context),
                          child: Container(
                            width: 38,
                            height: 38,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: Colors.white.withOpacity(0.18),
                            ),
                            child: const Icon(
                              Icons.arrow_back_ios_new_rounded,
                              color: Colors.white,
                              size: 17,
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                _paceLabel,
                                style: GoogleFonts.poppins(
                                  fontSize: Responsive.sp(context, 18),
                                  fontWeight: FontWeight.w500,
                                  color: Colors.white,
                                ),
                              ),
                              Text(
                                'Browse classes by pace',
                                style: GoogleFonts.poppins(
                                  fontSize: Responsive.sp(context, 11),
                                  color: Colors.white.withOpacity(0.75),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 18),
                  SizedBox(
                    height: 90 + 8 + FormatCircleLabel.boxHeight(context, 11),
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      itemCount: DummyData.pickYourPace.length,
                      itemBuilder: (_, i) => _paceCircle(i),
                    ),
                  ),
                  const SizedBox(height: 14),
                ],
              ),
            ),
            Expanded(
              child: CustomScrollView(
                physics: const ClampingScrollPhysics(),
                slivers: [
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(16, 20, 16, 0),
                      child: Row(
                        children: [
                          Expanded(
                            child: Container(
                                height: 1.5, color: AppColors.starAmber),
                          ),
                          const SizedBox(width: 10),
                          Flexible(
                            child: Text(
                              'All $_paceLabel',
                              textAlign: TextAlign.center,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: GoogleFonts.poppins(
                                fontSize: Responsive.sp(context, 17),
                                fontWeight: FontWeight.w600,
                                color: AppColors.textPrimary,
                              ),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Container(
                                height: 1.5, color: AppColors.starAmber),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SliverToBoxAdapter(child: SizedBox(height: 14)),
                  if (_isLoading)
                    SliverPadding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      sliver: SliverGrid(
                        delegate: SliverChildBuilderDelegate(
                          (context, index) => const CategorySkeletonCard(),
                          childCount: 6,
                        ),
                        gridDelegate: _kListingGrid,
                      ),
                    )
                  else if (_error != null)
                    SliverFillRemaining(
                      hasScrollBody: false,
                      child: ErrorRetryView(
                        message: _error!,
                        onRetry: _fetchClasses,
                      ),
                    )
                  else if (_classes.isEmpty)
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
                            if (index >= _classes.length) return null;
                            return CategoryEventCard(
                              event: _toEventModel(_classes[index]),
                            );
                          },
                          childCount: _classes.length,
                        ),
                        gridDelegate: _kListingGrid,
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
