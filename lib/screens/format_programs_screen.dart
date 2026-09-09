import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

import '../core/app_colors.dart';
import '../core/app_snackbar.dart';
import '../core/responsive.dart';
import '../data/dummy_data.dart';
import '../models/api_program_model.dart';
import '../models/event_model.dart';
import '../providers/location_state.dart';
import '../services/programs_listing_service.dart';
import '../widgets/category_event_card.dart';
import '../widgets/category_skeleton_card.dart';
import '../widgets/error_retry_view.dart';
import '../widgets/format_circle_label.dart';
import '../widgets/subcategory_empty_state.dart';
import '../core/user_location.dart';

/// Listing grid shared with the category, format and pace screens — two up,
/// 0.62 ratio — so every "browse a slice of the catalogue" screen presents its
/// results the same way.
const SliverGridDelegateWithFixedCrossAxisCount _kListingGrid =
    SliverGridDelegateWithFixedCrossAxisCount(
  crossAxisCount: 2,
  mainAxisSpacing: 14,
  crossAxisSpacing: 14,
  childAspectRatio: 0.62,
);

/// Programs filtered by the shape the programme takes — the "Find Your Fit"
/// row on the Programs tab, which until now was inert artwork.
///
/// Deliberately the same shape as [FormatEventsScreen] and
/// [PaceClassesScreen]: a tinted header carrying the format discs, a divider,
/// then the two-up grid. Browsing by format, by pace and by fit are the same
/// task on a different axis, so they should not look like different features.
class FormatProgramsScreen extends StatefulWidget {
  final int initialFormatIndex;

  const FormatProgramsScreen({super.key, required this.initialFormatIndex});

  @override
  State<FormatProgramsScreen> createState() => _FormatProgramsScreenState();
}

class _FormatProgramsScreenState extends State<FormatProgramsScreen> {
  late int _selectedIndex;
  List<ApiProgram> _programs = [];
  bool _isLoading = true;
  String? _error;

  /// Bumped on every fetch. A response whose generation is stale is dropped:
  /// tapping through several formats quickly issues overlapping requests, and
  /// they do not necessarily come back in the order they were sent.
  int _generation = 0;

  @override
  void initState() {
    super.initState();
    _selectedIndex =
        widget.initialFormatIndex.clamp(0, DummyData.findYourFit.length - 1);
    _fetchPrograms();
  }

  Map<String, dynamic> get _currentFormat =>
      DummyData.findYourFit[_selectedIndex];

  /// The disc labels wrap over two lines ("Batch\nProgram"); the heading wants
  /// that as one.
  String get _formatLabel =>
      (_currentFormat['label'] as String).replaceAll('\n', ' ');

  String get _formatSlug => _currentFormat['formatSlug'] as String;
  Color get _accentColor => _currentFormat['accentColor'] as Color;

  Future<void> _fetchPrograms() async {
    final generation = ++_generation;
    setState(() {
      _isLoading = true;
      _error = null;
    });
    try {
      // Filtered server-side on program_format, whose enum is exactly the
      // seven discs of this row.
      final page = await ProgramsListingService.fetchPrograms(
        lat: UserLocation.lat,
        lng: UserLocation.lng,
        programFormat: _formatSlug,
        city: LocationState().selectedCity.value,
        pageSize: 50,
      );
      if (!mounted || generation != _generation) return;
      setState(() {
        _programs = page.results;
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted || generation != _generation) return;
      final msg = e.toString().replaceFirst('Exception: ', '');
      setState(() {
        _programs = [];
        _error = msg;
        _isLoading = false;
      });
      AppSnackBar.error(context, msg);
    }
  }

  void _selectFormat(int index) {
    if (index == _selectedIndex) return;
    setState(() => _selectedIndex = index);
    _fetchPrograms();
  }

  EventModel _toEventModel(ApiProgram p) => EventModel(
        distanceKm: p.distanceKm,
        id: p.id,
        title: p.title,
        venue: p.city ?? p.category?.name ?? '',
        imagePath: p.cover ?? '',
        tag: p.category?.name,
        rating: p.averageRating,
        reviewCount: p.totalReviews > 0
            ? '${p.averageRating} (${p.totalReviews})'
            : null,
        description: p.shortDescription,
        listingType: 'program',
      );

  Widget _formatCircle(int index) {
    final format = DummyData.findYourFit[index];
    final isSelected = index == _selectedIndex;
    const double size = 90;

    return GestureDetector(
      onTap: () => _selectFormat(index),
      child: Container(
        width: size,
        margin: const EdgeInsets.only(right: 14),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              width: size,
              // Tall enough for the grown disc, so the row's viewport does
              // not clip its top edge. Every tile reserves the same height,
              // so the labels stay on one line together.
              height: size * FormatCircleLabel.selectedScale,
              child: OverflowBox(
                maxWidth: size * 1.2,
                maxHeight: size * 1.2,
                child: AnimatedScale(
                  duration: const Duration(milliseconds: 220),
                  curve: Curves.easeInOut,
                  scale: isSelected ? FormatCircleLabel.selectedScale : 1.0,
                  // The artwork fills the disc edge to edge, the way the same
                  // images are drawn in the Find Your Fit row on the Programs
                  // tab. Insetting them and fitting by `contain` left a white
                  // ring around every icon. The white fill stays as the
                  // backdrop for the fallback glyph, and is covered whenever
                  // the image loads.
                  child: Container(
                    width: size,
                    height: size,
                    clipBehavior: Clip.antiAlias,
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.white,
                    ),
                    alignment: Alignment.center,
                    child: Image.asset(
                      format['image'] as String,
                      width: size,
                      height: size,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => const Icon(
                        Icons.workspace_premium_outlined,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 8),
            FormatCircleLabel(
              label: (format['label'] as String).replaceAll('\n', ' '),
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
                                _formatLabel,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: GoogleFonts.poppins(
                                  fontSize: Responsive.sp(context, 18),
                                  fontWeight: FontWeight.w500,
                                  color: Colors.white,
                                ),
                              ),
                              Text(
                                'Browse programs by fit',
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
                    height: FormatCircleLabel.rowHeight(context, 90, 11),
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      itemCount: DummyData.findYourFit.length,
                      itemBuilder: (_, i) => _formatCircle(i),
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
                              'All $_formatLabel',
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
                        onRetry: _fetchPrograms,
                      ),
                    )
                  else if (_programs.isEmpty)
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
                            if (index >= _programs.length) return null;
                            return CategoryEventCard(
                              event: _toEventModel(_programs[index]),
                            );
                          },
                          childCount: _programs.length,
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
