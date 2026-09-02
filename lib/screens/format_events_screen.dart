import 'package:flutter/material.dart';
import '../core/app_snackbar.dart';
import '../core/responsive.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import '../core/app_colors.dart';
import '../core/listing_schedule.dart';
import '../data/dummy_data.dart';
import '../models/api_event_model.dart';
import '../models/event_model.dart';
import '../providers/location_state.dart';
import '../services/events_listing_service.dart';
import '../widgets/app_loader.dart';
import '../widgets/format_circle_label.dart';
import '../widgets/trending_event_card.dart';
import '../widgets/subcategory_empty_state.dart';

class FormatEventsScreen extends StatefulWidget {
  final int initialFormatIndex;

  const FormatEventsScreen({super.key, required this.initialFormatIndex});

  @override
  State<FormatEventsScreen> createState() => _FormatEventsScreenState();
}

class _FormatEventsScreenState extends State<FormatEventsScreen> {
  late int _selectedIndex;
  List<ApiEvent> _events = [];
  bool _isLoading = true;

  static const _invertMatrix = <double>[
    -1,  0,  0, 0, 255,
     0, -1,  0, 0, 255,
     0,  0, -1, 0, 255,
     0,  0,  0, 1,   0,
  ];

  @override
  void initState() {
    super.initState();
    _selectedIndex = widget.initialFormatIndex
        .clamp(0, DummyData.exploreFormats.length - 1);
    _fetchEvents();
  }

  Map<String, dynamic> get _currentFormat =>
      DummyData.exploreFormats[_selectedIndex];

  String get _formatLabel => _currentFormat['label'] as String;
  String get _formatSlug => _currentFormat['formatSlug'] as String;
  Color get _accentColor => _currentFormat['accentColor'] as Color;

  Future<void> _fetchEvents() async {
    setState(() {
      _isLoading = true;
    });
    try {
      // The backend format filter is not yet live, so fetch all events and
      // filter client-side by format slug + user's selected city.
      final page = await EventsListingService.fetchEvents(pageSize: 100);
      if (!mounted) return;
      final slug = _formatSlug;
      final city = LocationState().selectedCity.value.toLowerCase();
      setState(() {
        _events = page.results
            .where((e) =>
                e.format == slug &&
                e.city.toLowerCase() == city &&
                // A finished event has nothing left to book; keeping it in a
                // format-browse list just leads to a dead end when tapped.
                !ListingSchedule.hasEnded(e.endDatetime))
            .toList();
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      final msg = e.toString().replaceFirst('Exception: ', '');
      setState(() {
        _events = [];
        _isLoading = false;
      });
      AppSnackBar.error(context, msg);
    }
  }

  void _selectFormat(int index) {
    if (index == _selectedIndex) return;
    setState(() => _selectedIndex = index);
    _fetchEvents();
  }

  static const _months = [
    '', 'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
    'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
  ];
  static const _weekdays = [
    '', 'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun',
  ];

  EventModel _toEventModel(ApiEvent e) {
    final dt = e.startDatetime.toLocal();
    final dateLabel = '${dt.day} ${_months[dt.month]}';
    final dayLabel = _weekdays[dt.weekday];
    final timeLabel =
        '${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';

    return EventModel(
      id: e.id,
      title: e.title,
      venue: e.city,
      imagePath: e.coverUrl ?? '',
      tag: e.subcategory?.name ?? e.category.name,
      description: e.ageGroup?.displayRange,
      eventDate: '$dayLabel, $dateLabel',
      eventTime: timeLabel,
      price: e.priceFrom != null ? double.tryParse(e.priceFrom!) : null,
      isFeatured: e.priceType == 'free',
    );
  }

  Widget _formatCircle(int index) {
    final fmt = DummyData.exploreFormats[index];
    final bool isSelected = index == _selectedIndex;
    final double scale = (fmt['scale'] as double?) ?? 1.0;
    final bool invert = fmt['invertColors'] == true;
    const double size = 90;

    Widget img = Image.asset(
      fmt['image'],
      width: size,
      height: size,
      fit: BoxFit.contain,
      errorBuilder: (_, __, ___) =>
          const Icon(Icons.category, color: Colors.white54),
    );
    if (invert) {
      img = ColorFiltered(
        colorFilter: const ColorFilter.matrix(_invertMatrix),
        child: img,
      );
    }
    if (scale != 1.0) {
      img = Transform.scale(scale: scale, child: img);
    }

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
              height: size,
              // Clip.none so the selected disc's artwork may spill past the
              // tile; that growth is the selection cue.
              child: OverflowBox(
                maxWidth: size * 1.2,
                maxHeight: size * 1.2,
                child: AnimatedScale(
                  duration: const Duration(milliseconds: 220),
                  curve: Curves.easeInOut,
                  scale: isSelected ? 1.12 : 1.0,
                  child: SizedBox(width: size, height: size, child: img),
                ),
              ),
            ),
            const SizedBox(height: 8),
            // Below the disc, not engraved on it: the artwork's middle left
            // only ~65px of usable width, which is what broke "Competition"
            // across two lines mid-word.
            FormatCircleLabel(
              label: fmt['label'] as String,
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
            // ── Animated gradient header ─────────────────────────────────
            AnimatedContainer(
              duration: const Duration(milliseconds: 350),
              curve: Curves.easeInOut,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomCenter,
                  colors: [
                    _accentColor,
                    _accentColor.withOpacity(0.78),
                  ],
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(height: safeTop + 10),

                  // Back + title row
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
                                style: GoogleFonts.poppins(
                                  fontSize: Responsive.sp(context, 18),
                                  fontWeight: FontWeight.w500,
                                  color: Colors.white,
                                ),
                              ),
                              Text(
                                'Explore events by format',
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

                  // Disc (90) + gap (8) + a two-line label. The selected
                  // disc scales inside its own box rather than growing the
                  // tile, so this height does not have to allow for it.
                  SizedBox(
                    height: 90 +
                        8 +
                        FormatCircleLabel.boxHeight(context, 11),
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      itemCount: DummyData.exploreFormats.length,
                      itemBuilder: (_, i) => _formatCircle(i),
                    ),
                  ),

                  const SizedBox(height: 14),
                ],
              ),
            ),

            // ── Scrollable body ──────────────────────────────────────────
            Expanded(
              child: CustomScrollView(
                physics: const ClampingScrollPhysics(),
                slivers: [
                  // "All [Format] Events" gold divider
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(16, 20, 16, 0),
                      child: Row(
                        children: [
                          Expanded(
                              child: Container(
                                  height: 1.5,
                                  color: AppColors.starAmber)),
                          const SizedBox(width: 10),
                          Text(
                            'All $_formatLabel Events',
                            style: GoogleFonts.poppins(
                              fontSize: Responsive.sp(context, 17),
                              fontWeight: FontWeight.w600,
                              color: AppColors.textPrimary,
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                              child: Container(
                                  height: 1.5,
                                  color: AppColors.starAmber)),
                        ],
                      ),
                    ),
                  ),

                  const SliverToBoxAdapter(child: SizedBox(height: 14)),

                  // Loading / empty / grid
                  if (_isLoading)
                    const SliverFillRemaining(
                      hasScrollBody: false,
                      child: AppLoader(),
                    )
                  else if (_events.isEmpty)
                    SliverFillRemaining(
                      hasScrollBody: false,
                      child: SubcategoryEmptyState(
                        onExploreOtherCategories: () =>
                            Navigator.pop(context),
                      ),
                    )
                  else
                    SliverPadding(
                      padding:
                          const EdgeInsets.symmetric(horizontal: 16),
                      sliver: SliverList(
                        delegate: SliverChildBuilderDelegate(
                          (_, i) {
                            if (i >= _events.length) return null;
                            return Padding(
                              padding: const EdgeInsets.only(bottom: 24),
                              child: SizedBox(
                                height: Responsive.h(context, 420, min: 400),
                                child: TrendingEventCard(
                                  event: _toEventModel(_events[i]),
                                ),
                              ),
                            );
                          },
                          childCount: _events.length,
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
