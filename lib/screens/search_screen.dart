import 'dart:async';
import '../core/app_colors.dart';
import '../core/listing_schedule.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../core/responsive.dart';
import '../providers/location_state.dart';
import '../widgets/empty_location_widget.dart';
import '../models/event_model.dart';
import '../services/events_listing_service.dart';
import '../services/classes_listing_service.dart';
import '../services/programs_listing_service.dart';
import 'event_detail_screen.dart';
import 'class_detail_screen.dart';
import 'program_detail_screen.dart';
import 'venue_detail_screen.dart';

enum _EntityType { event, klass, program, venue }

class _SearchItem {
  final _EntityType type;
  final EventModel eventModel;
  final String title;
  final String subtitle;
  final String? coverUrl;

  const _SearchItem({
    required this.type,
    required this.eventModel,
    required this.title,
    required this.subtitle,
    this.coverUrl,
  });

  Color get typeColor => switch (type) {
    _EntityType.event   => const Color(0xFF3949AB),
    _EntityType.klass   => const Color(0xFF7B2FBE),
    _EntityType.program => const Color(0xFF0F9D58),
    _EntityType.venue   => const Color(0xFFE53935),
  };

  String get typeLabel => switch (type) {
    _EntityType.event   => 'Event',
    _EntityType.klass   => 'Class',
    _EntityType.program => 'Program',
    _EntityType.venue   => 'Venue',
  };
}

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final TextEditingController _searchController = TextEditingController();
  int _selectedChip = 0;
  Timer? _debounce;
  bool _loading = false;
  bool _hasError = false;
  List<_SearchItem> _allResults = [];
  String _query = '';

  // Filter state (retained for future use — not yet wired to API)
  String? _selectedMode;
  final Set<String> _ageGroupSelected = {};
  final Set<String> _dateSelected = {};

  final List<String> _chips = ['All', 'Events', 'Classes', 'Programs', 'Venues'];

  static const _ageGroups  = ['0-3 years', '3-5 years', '6-8 years', '9-12 years', '13-16 years'];
  static const _modes      = ['Offline', 'Hybrid', 'Online'];
  static const _dateOptions = ['Today', 'This Weekend', 'This Week', 'Upcoming'];

  List<_SearchItem> get _filteredResults {
    if (_selectedChip == 0) return _allResults;
    final target = const [null, _EntityType.event, _EntityType.klass, _EntityType.program, _EntityType.venue][_selectedChip];
    return _allResults.where((r) => r.type == target).toList();
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged(String value) {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 500), () => _doSearch(value.trim()));
  }

  Future<void> _doSearch(String q) async {
    if (q.isEmpty) {
      setState(() { _query = ''; _allResults = []; _loading = false; _hasError = false; });
      return;
    }
    setState(() { _query = q; _loading = true; _hasError = false; });

    // Each entity type is fetched independently and fault-tolerantly. A failure
    // in one source (e.g. the backend returns 404 / an error for a query that
    // simply has no matches) returns null and must NOT fail the whole search —
    // otherwise an empty result set is wrongly shown as a network error.
    // We only treat it as a real network error when EVERY source fails.
    final lists = await Future.wait<List<_SearchItem>?>([
      _fetchEventItems(q),
      _fetchClassItems(q),
      _fetchProgramItems(q),
      _fetchVenueItems(q),
    ]);

    if (!mounted) return;

    final failureCount = lists.where((l) => l == null).length;
    if (failureCount == lists.length) {
      // Nothing could be reached at all — genuine connectivity problem.
      setState(() { _loading = false; _hasError = true; });
      return;
    }

    final items = <_SearchItem>[
      for (final l in lists)
        if (l != null) ...l,
    ];

    // Relevance guard: the backend `search` param drives relevance, but if it
    // returns unrelated rows we still want to keep things on-topic — WITHOUT
    // discarding genuine matches (the old "title/subtitle contains the whole
    // query" check dropped valid hits like "art class" → "Art & Craft Class").
    // So match is token-based (every query word must appear) across the title,
    // subtitle AND tag/category, in any order.
    final tokens = q
        .toLowerCase()
        .split(RegExp(r'\s+'))
        .where((t) => t.isNotEmpty)
        .toList();
    final relevant = items.where((item) {
      final haystack =
          '${item.title} ${item.subtitle} ${item.eventModel.tag ?? ''}'
              .toLowerCase();
      return tokens.every(haystack.contains);
    }).toList();

    setState(() { _allResults = relevant; _loading = false; });
  }

  /// Returns the mapped items for a source, or `null` if that source's request
  /// failed — so the caller can distinguish "no matches" from "couldn't fetch".
  Future<List<_SearchItem>?> _fetchEventItems(String q) async {
    try {
      final page = await EventsListingService.fetchEvents(search: q, pageSize: 10);
      return [
        // Same reasoning as every other events list: a finished event has
        // nothing left to book, tapping in from a search result is as much
        // of a dead end as tapping in from a browse list.
        for (final e in page.results)
          if (!ListingSchedule.hasEnded(e.endDatetime))
            _SearchItem(
              type: _EntityType.event,
              eventModel: EventModel(
                id: e.id,
                title: e.title,
                venue: e.city,
                imagePath: e.coverUrl ?? '',
                tag: e.subcategory?.name,
                price: e.priceFrom != null ? double.tryParse(e.priceFrom!) : null,
              ),
              title: e.title,
              subtitle: e.city,
              coverUrl: e.coverUrl,
            ),
      ];
    } catch (_) {
      return null;
    }
  }

  Future<List<_SearchItem>?> _fetchClassItems(String q) async {
    try {
      final page = await ClassesListingService.fetchClasses(search: q, pageSize: 10);
      return [
        // Classes have no end date to filter by (open-ended recurring
        // schedule) — is_paused is the partner-controlled "not currently
        // bookable" signal instead.
        for (final c in page.results)
          if (!c.isPaused)
            _SearchItem(
              type: _EntityType.klass,
              eventModel: EventModel(
                id: c.id,
                title: c.title,
                venue: c.category.name,
                imagePath: c.coverUrl ?? '',
                tag: c.category.name,
                rating: c.averageRating,
              ),
              title: c.title,
              subtitle: c.category.name,
              coverUrl: c.coverUrl,
            ),
      ];
    } catch (_) {
      return null;
    }
  }

  Future<List<_SearchItem>?> _fetchProgramItems(String q) async {
    try {
      final page = await ProgramsListingService.fetchPrograms(search: q, pageSize: 10);
      return [
        // Same reasoning as events: a finished program (every batch over)
        // has nothing left to book.
        for (final p in page.results)
          if (!ListingSchedule.hasEnded(p.endDatetime))
            _SearchItem(
              type: _EntityType.program,
              eventModel: EventModel(
                id: p.id,
                title: p.title,
                venue: p.city ?? p.category?.name ?? '',
                imagePath: p.cover ?? '',
                tag: p.category?.name,
                rating: p.averageRating,
              ),
              title: p.title,
              subtitle: p.city ?? p.category?.name ?? '',
              coverUrl: p.cover,
            ),
      ];
    } catch (_) {
      return null;
    }
  }

  Future<List<_SearchItem>?> _fetchVenueItems(String q) async {
    try {
      final page = await EventsListingService.fetchVenues(search: q, pageSize: 10);
      return [
        for (final v in page.results)
          _SearchItem(
            type: _EntityType.venue,
            eventModel: EventModel(
              id: v.id,
              title: v.title,
              venue: [v.area, v.city].where((s) => s != null && s.isNotEmpty).join(', '),
              imagePath: v.cover ?? '',
              tag: v.category.name.isNotEmpty ? v.category.name : null,
            ),
            title: v.title,
            subtitle: [v.area, v.city].where((s) => s != null && s.isNotEmpty).join(', '),
            coverUrl: v.cover,
          ),
      ];
    } catch (_) {
      return null;
    }
  }

  void _onTap(_SearchItem item) {
    final Widget screen = switch (item.type) {
      _EntityType.event   => EventDetailScreen(event: item.eventModel),
      _EntityType.klass   => ClassDetailScreen(event: item.eventModel),
      _EntityType.program => ProgramDetailScreen(event: item.eventModel),
      _EntityType.venue   => VenueDetailScreen(event: item.eventModel),
    };
    Navigator.push(context, MaterialPageRoute(builder: (_) => screen));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.textPrimary),
          onPressed: () => Navigator.pop(context),
        ),
        title: SizedBox(
          height: 40,
          child: TextField(
            controller: _searchController,
            autofocus: true,
            onChanged: _onSearchChanged,
            decoration: InputDecoration(
              hintText: 'Search events, classes, venues...',
              hintStyle: GoogleFonts.poppins(fontSize: Responsive.sp(context, 14), color: Colors.grey),
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              suffixIcon: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (_searchController.text.isNotEmpty)
                    GestureDetector(
                      onTap: () {
                        _searchController.clear();
                        _onSearchChanged('');
                      },
                      child: const Padding(
                        padding: EdgeInsets.only(right: 4),
                        child: Icon(Icons.close, size: 18, color: Colors.grey),
                      ),
                    ),
                  IconButton(
                    icon: const Icon(Icons.tune, color: Colors.black),
                    onPressed: () => _showFiltersBottomSheet(context),
                  ),
                ],
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(24),
                borderSide: const BorderSide(color: AppColors.textPrimary, width: 1.5),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(24),
                borderSide: const BorderSide(color: AppColors.textPrimary, width: 1.5),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(24),
                borderSide: const BorderSide(color: AppColors.textPrimary, width: 1.5),
              ),
            ),
            style: GoogleFonts.poppins(fontSize: Responsive.sp(context, 14)),
          ),
        ),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 8),
          // ── Entity filter chips ──────────────────────────────────────────────
          SizedBox(
            height: 40,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: _chips.length,
              separatorBuilder: (_, __) => const SizedBox(width: 10),
              itemBuilder: (context, index) {
                final isSelected = index == _selectedChip;
                return GestureDetector(
                  onTap: () => setState(() => _selectedChip = index),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                    decoration: BoxDecoration(
                      color: isSelected ? AppColors.textPrimary : Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: AppColors.textPrimary, width: 1.5),
                    ),
                    child: Text(
                      _chips[index],
                      style: GoogleFonts.poppins(
                        fontSize: Responsive.sp(context, 13),
                        fontWeight: FontWeight.w500,
                        color: isSelected ? Colors.white : AppColors.textPrimary,
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          _buildActiveFilterRow(),
          const SizedBox(height: 8),
          Expanded(child: _buildBody()),
        ],
      ),
    );
  }

  // ── Active filters ─────────────────────────────────────────────────────────

  /// One selected filter, with the means to undo it.
  ///
  /// Built fresh on each build so the row cannot fall out of step with the
  /// sheet's state.
  List<({String label, VoidCallback remove})> get _activeFilters {
    final out = <({String label, VoidCallback remove})>[];

    if (_selectedChip != 0) {
      out.add((
        label: _chips[_selectedChip],
        remove: () => setState(() => _selectedChip = 0),
      ));
    }
    for (final age in _ageGroupSelected.toList()) {
      out.add((
        label: age,
        remove: () => setState(() => _ageGroupSelected.remove(age)),
      ));
    }
    if (_selectedMode != null) {
      out.add((
        label: _selectedMode!,
        remove: () => setState(() => _selectedMode = null),
      ));
    }
    for (final d in _dateSelected.toList()) {
      out.add((
        label: d,
        remove: () => setState(() => _dateSelected.remove(d)),
      ));
    }
    return out;
  }

  void _clearAllFilters() {
    setState(() {
      _selectedChip = 0;
      _ageGroupSelected.clear();
      _dateSelected.clear();
      _selectedMode = null;
    });
  }

  /// The selected filters, shown under the search bar so what is narrowing the
  /// results is visible without reopening the sheet. Each carries its own
  /// remove control.
  Widget _buildActiveFilterRow() {
    final active = _activeFilters;
    if (active.isEmpty) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.only(top: 8),
      child: SizedBox(
        height: 34,
        child: ListView.separated(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          itemCount: active.length + 1,
          separatorBuilder: (_, __) => const SizedBox(width: 8),
          itemBuilder: (context, i) {
            // "Clear all" trails the list so it can't be hit by accident when
            // reaching for the first chip's cross.
            if (i == active.length) {
              return GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: _clearAllFilters,
                child: Container(
                  alignment: Alignment.center,
                  padding: const EdgeInsets.symmetric(horizontal: 14),
                  child: Text(
                    'Clear all',
                    style: GoogleFonts.poppins(
                      fontSize: Responsive.sp(context, 12.5),
                      fontWeight: FontWeight.w600,
                      color: AppColors.seeAllBlue,
                    ),
                  ),
                ),
              );
            }

            final f = active[i];
            return Container(
              padding: const EdgeInsets.only(left: 14, right: 6),
              decoration: BoxDecoration(
                color: const Color(0xFFF1F1F5),
                borderRadius: BorderRadius.circular(17),
                border: Border.all(color: const Color(0xFFE0E0E6)),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    f.label,
                    style: GoogleFonts.poppins(
                      fontSize: Responsive.sp(context, 12.5),
                      fontWeight: FontWeight.w500,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(width: 4),
                  GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    onTap: f.remove,
                    child: Padding(
                      // Widens a small cross into a reachable target.
                      padding: const EdgeInsets.all(6),
                      child: Icon(Icons.close,
                          size: 13, color: Colors.grey.shade700),
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  /// Listing-type picker shown at the head of the filter sheet, mirroring the
  /// chip row on the screen behind it. Both drive [_selectedChip], so the two
  /// always agree.
  Widget _buildTypeSection(StateSetter setModalState) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Show',
            style: GoogleFonts.poppins(
              fontSize: Responsive.sp(context, 14),
              fontWeight: FontWeight.w500,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: List.generate(_chips.length, (i) {
              final selected = _selectedChip == i;
              return GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: () => setModalState(() => _selectedChip = i),
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 18, vertical: 9),
                  decoration: BoxDecoration(
                    color: selected ? AppColors.textPrimary : Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: selected
                          ? AppColors.textPrimary
                          : const Color(0xFFE0E0E6),
                    ),
                  ),
                  child: Text(
                    _chips[i],
                    style: GoogleFonts.poppins(
                      fontSize: Responsive.sp(context, 13),
                      fontWeight: FontWeight.w500,
                      color: selected ? Colors.white : AppColors.textPrimary,
                    ),
                  ),
                ),
              );
            }),
          ),
        ],
      ),
    );
  }

  Widget _buildBody() {
    // Searching an unserviced city returns nothing, and "No results for X"
    // blames the query for it. Say what is actually wrong, and offer the fix.
    if (!LocationState().isLocationSupported(
        LocationState().selectedCity.value)) {
      return const EmptyLocationWidget(title: 'Nothing to search here yet');
    }
    if (_query.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.search_rounded, size: 64, color: Colors.grey.shade300),
              const SizedBox(height: 16),
              Text(
                'Search anything',
                style: GoogleFonts.poppins(
                  fontSize: Responsive.sp(context, 18),
                  fontWeight: FontWeight.w500,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                'Find events, classes, programs & venues by name',
                style: GoogleFonts.poppins(fontSize: Responsive.sp(context, 13), color: Colors.grey),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      );
    }

    if (_loading) {
      return const Center(
        child: CircularProgressIndicator(
          color: AppColors.primaryLight,
          strokeWidth: 2.5,
        ),
      );
    }

    if (_hasError) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.wifi_off_rounded, size: 56, color: Colors.grey.shade300),
              const SizedBox(height: 16),
              Text(
                'Search failed',
                style: GoogleFonts.poppins(
                  fontSize: Responsive.sp(context, 15),
                  fontWeight: FontWeight.w500,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                'Could not reach the server. Check your connection and try again.',
                style: GoogleFonts.poppins(fontSize: Responsive.sp(context, 13), color: Colors.grey),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 20),
              GestureDetector(
                onTap: () => _doSearch(_query),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 12),
                  decoration: BoxDecoration(
                    color: AppColors.primaryLight,
                    borderRadius: BorderRadius.circular(24),
                  ),
                  child: Text(
                    'Retry',
                    style: GoogleFonts.poppins(
                      fontSize: Responsive.sp(context, 14),
                      fontWeight: FontWeight.w500,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    }

    final results = _filteredResults;
    if (results.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.search_off_rounded, size: 56, color: Colors.grey.shade300),
            const SizedBox(height: 16),
            Text(
              'No results for "$_query"',
              style: GoogleFonts.poppins(
                fontSize: Responsive.sp(context, 15),
                fontWeight: FontWeight.w500,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              'Try a different search term',
              style: GoogleFonts.poppins(fontSize: Responsive.sp(context, 13), color: Colors.grey),
            ),
          ],
        ),
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      itemCount: results.length,
      separatorBuilder: (_, __) => const Divider(height: 1, color: Color(0xFFF0F0F0)),
      itemBuilder: (context, index) {
        final item = results[index];
        return ListTile(
          contentPadding: const EdgeInsets.symmetric(vertical: 6),
          leading: ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: item.coverUrl != null && item.coverUrl!.isNotEmpty
                ? Image.network(
                    item.coverUrl!,
                    width: 56,
                    height: 56,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => _placeholder(item.typeColor),
                  )
                : _placeholder(item.typeColor),
          ),
          title: Text(
            item.title,
            style: GoogleFonts.poppins(
              fontSize: Responsive.sp(context, 16),
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          subtitle: Padding(
            padding: const EdgeInsets.only(top: 4),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: item.typeColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    item.typeLabel,
                    style: GoogleFonts.poppins(
                      fontSize: Responsive.sp(context, 10),
                      fontWeight: FontWeight.w500,
                      color: item.typeColor,
                    ),
                  ),
                ),
                if (item.subtitle.isNotEmpty) ...[
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      item.subtitle,
                      style: GoogleFonts.poppins(fontSize: Responsive.sp(context, 12), color: Colors.grey),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ],
            ),
          ),
          trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 14, color: Colors.grey),
          onTap: () => _onTap(item),
        );
      },
    );
  }

  Widget _placeholder(Color color) => Container(
        width: 56,
        height: 56,
        decoration: BoxDecoration(
          color: color.withOpacity(0.08),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(Icons.image_outlined, color: color.withOpacity(0.4), size: 24),
      );

  void _showFiltersBottomSheet(BuildContext context) {
    // The sheet mutates this screen's state directly through setModalState,
    // which rebuilds only the sheet. Without this the results and the active
    // filter row kept the pre-Apply state until something else rebuilt them.
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setModalState) {
          return Container(
            constraints: BoxConstraints(
              maxHeight: MediaQuery.of(context).size.height * 0.88,
            ),
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const SizedBox(height: 10),
                Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(height: 16),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Filters',
                        style: GoogleFonts.poppins(
                          fontSize: Responsive.sp(context, 18),
                          fontWeight: FontWeight.w500,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      GestureDetector(
                        onTap: () => Navigator.pop(ctx),
                        child: Container(
                          width: 32,
                          height: 32,
                          decoration: BoxDecoration(
                            color: Colors.grey.shade100,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Icons.close, size: 18, color: AppColors.textPrimary),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                Flexible(
                  child: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Divider(height: 1, color: Color(0xFFEEEEEE)),
                        // ── Listing type ─────────────────────────────────────
                        _buildTypeSection(setModalState),
                        const Divider(height: 1, color: Color(0xFFEEEEEE)),
                        // ── Age Group ────────────────────────────────────────
                        Padding(
                          padding: const EdgeInsets.fromLTRB(20, 16, 20, 16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Age Group', style: GoogleFonts.poppins(fontSize: Responsive.sp(context, 14), fontWeight: FontWeight.w500, color: AppColors.textPrimary)),
                              const SizedBox(height: 12),
                              Wrap(
                                spacing: 8,
                                runSpacing: 8,
                                children: _ageGroups.map((label) => _buildFilterChip(
                                  label: label,
                                  isSelected: _ageGroupSelected.contains(label),
                                  onTap: () => setModalState(() {
                                    _ageGroupSelected.contains(label) ? _ageGroupSelected.remove(label) : _ageGroupSelected.add(label);
                                  }),
                                )).toList(),
                              ),
                            ],
                          ),
                        ),
                        const Divider(height: 1, color: Color(0xFFEEEEEE)),
                        // ── Mode ─────────────────────────────────────────────
                        Padding(
                          padding: const EdgeInsets.fromLTRB(20, 16, 20, 4),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Mode', style: GoogleFonts.poppins(fontSize: Responsive.sp(context, 14), fontWeight: FontWeight.w500, color: AppColors.textPrimary)),
                              const SizedBox(height: 12),
                              ..._modes.map((mode) => _buildRadioOption(
                                label: mode,
                                isSelected: _selectedMode == mode,
                                onTap: () => setModalState(() {
                                  _selectedMode = _selectedMode == mode ? null : mode;
                                }),
                              )),
                            ],
                          ),
                        ),
                        const Divider(height: 1, color: Color(0xFFEEEEEE)),
                        // ── Date ─────────────────────────────────────────────
                        Padding(
                          padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Date', style: GoogleFonts.poppins(fontSize: Responsive.sp(context, 14), fontWeight: FontWeight.w500, color: AppColors.textPrimary)),
                              const SizedBox(height: 12),
                              Wrap(
                                spacing: 8,
                                runSpacing: 8,
                                children: _dateOptions.map((label) => _buildFilterChip(
                                  label: label,
                                  isSelected: _dateSelected.contains(label),
                                  onTap: () => setModalState(() {
                                    _dateSelected.contains(label) ? _dateSelected.remove(label) : _dateSelected.add(label);
                                  }),
                                )).toList(),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.fromLTRB(20, 12, 20, 28),
                  decoration: BoxDecoration(
                    border: Border(top: BorderSide(color: Colors.grey.shade200)),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () => setModalState(() {
                            _selectedChip = 0;
                            _ageGroupSelected.clear();
                            _dateSelected.clear();
                            _selectedMode = null;
                          }),
                          style: OutlinedButton.styleFrom(
                            side: const BorderSide(color: Color(0xFFE0E0E0)),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            padding: const EdgeInsets.symmetric(vertical: 14),
                          ),
                          child: Text('Clear All', style: GoogleFonts.poppins(fontSize: Responsive.sp(context, 15), fontWeight: FontWeight.w500, color: AppColors.textPrimary)),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () => Navigator.pop(ctx),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primaryLight,
                            foregroundColor: AppColors.textPrimary,
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            elevation: 0,
                          ),
                          child: Text('Apply Filters', style: GoogleFonts.poppins(fontSize: Responsive.sp(context, 15), fontWeight: FontWeight.w500)),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    ).whenComplete(() {
      if (mounted) setState(() {});
    });
  }

  Widget _buildRadioOption({required String label, required bool isSelected, required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.only(bottom: 14),
        child: Row(
          children: [
            Container(
              width: 22,
              height: 22,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: isSelected ? AppColors.textPrimary : Colors.grey.shade400,
                  width: 2,
                ),
              ),
              child: isSelected
                  ? Center(
                      child: Container(
                        width: 10,
                        height: 10,
                        decoration: const BoxDecoration(shape: BoxShape.circle, color: AppColors.textPrimary),
                      ),
                    )
                  : null,
            ),
            const SizedBox(width: 12),
            Text(label, style: GoogleFonts.poppins(fontSize: Responsive.sp(context, 14), fontWeight: FontWeight.w500, color: AppColors.textPrimary)),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterChip({required String label, required bool isSelected, required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primaryLight : Colors.grey.shade200,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (isSelected) ...[
              const Icon(Icons.close, size: 16, color: AppColors.textPrimary),
              const SizedBox(width: 6),
            ],
            Text(label, style: GoogleFonts.poppins(fontSize: Responsive.sp(context, 13), fontWeight: FontWeight.w500, color: AppColors.textPrimary)),
          ],
        ),
      ),
    );
  }
}
