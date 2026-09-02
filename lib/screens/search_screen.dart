import 'dart:async';
import '../core/app_colors.dart';
import '../core/listing_schedule.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../core/responsive.dart';
import '../providers/listing_taxonomy_state.dart';
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

class _SearchItem {
  final ListingKind type;
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
    ListingKind.event   => const Color(0xFF3949AB),
    ListingKind.klass   => const Color(0xFF7B2FBE),
    ListingKind.program => const Color(0xFF0F9D58),
    ListingKind.venue   => const Color(0xFFE53935),
  };

  String get typeLabel => switch (type) {
    ListingKind.event   => 'Event',
    ListingKind.klass   => 'Class',
    ListingKind.program => 'Program',
    ListingKind.venue   => 'Venue',
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

  // Category filter — unlike the three above, this one IS sent to the APIs.
  TaxonomyNode? _selectedCategory;
  TaxonomyNode? _selectedSubcategory;

  /// Incremented per dispatched search so a slower earlier request cannot
  /// overwrite a newer one. Applying a filter makes the *new* request the
  /// fast one — it queries only the sources that can express the filter — so
  /// without this the older unfiltered response routinely lands last and
  /// replaces the filtered results the user just asked for.
  int _searchGeneration = 0;

  /// True when a filter that narrows the request itself is set, as opposed to
  /// the decorative ones. Such a filter is meaningful on its own, so it makes
  /// a search worth running even with an empty query.
  bool get _hasServerFilter =>
      _selectedCategory != null || _selectedSubcategory != null;

  final List<String> _chips = ['All', 'Events', 'Classes', 'Programs', 'Venues'];

  static const _ageGroups  = ['0-3 years', '3-5 years', '6-8 years', '9-12 years', '13-16 years'];
  static const _modes      = ['Offline', 'Hybrid', 'Online'];
  static const _dateOptions = ['Today', 'This Weekend', 'This Week', 'Upcoming'];

  List<_SearchItem> get _filteredResults {
    if (_selectedChip == 0) return _allResults;
    final target = const [null, ListingKind.event, ListingKind.klass, ListingKind.program, ListingKind.venue][_selectedChip];
    return _allResults.where((r) => r.type == target).toList();
  }

  @override
  void initState() {
    super.initState();
    // Warm the category vocabulary so the filter sheet has something to show
    // the first time it is opened. Never throws, and the sheet copes with it
    // still being in flight, so this is deliberately not awaited.
    ListingTaxonomyState.load();
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
    // A category on its own is a perfectly good query ("show me everything in
    // Performing Arts"), so only an empty box AND no server-side filter means
    // there is nothing to ask for.
    final generation = ++_searchGeneration;
    if (q.isEmpty && !_hasServerFilter) {
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

    // A newer search was dispatched while this one was in flight — its
    // results are the ones the user is waiting for, so drop these.
    if (!mounted || generation != _searchGeneration) return;

    // The denominator is the sources the filter actually left in play, not
    // all four. A source excluded by the category filter returns an empty
    // list rather than null, so counting it as a success would mask the case
    // where every source that COULD have answered failed — showing a bare
    // "no results" for what was really a network failure.
    final inPlay = ListingKind.values.where(_sourceMatchesFilter).length;
    final failureCount = lists.where((l) => l == null).length;
    if (inPlay > 0 && failureCount == inPlay) {
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

  /// Whether the active category filter can be expressed to [kind] at all.
  ///
  /// A source that does not offer the selected category would otherwise be
  /// asked for it unfiltered and return everything, which reads as the filter
  /// having been ignored. Excluding it is the honest answer: that listing type
  /// genuinely has nothing under this category.
  bool _sourceMatchesFilter(ListingKind kind) {
    final sub = _selectedSubcategory;
    if (sub != null) return sub.has(kind);
    final cat = _selectedCategory;
    if (cat != null) return cat.has(kind);
    return true;
  }

  /// Returns the mapped items for a source, or `null` if that source's request
  /// failed — so the caller can distinguish "no matches" from "couldn't fetch".
  Future<List<_SearchItem>?> _fetchEventItems(String q) async {
    if (!_sourceMatchesFilter(ListingKind.event)) return const [];
    try {
      final page = await EventsListingService.fetchEvents(
        search: q.isEmpty ? null : q,
        // Events match on the exact category NAME — a slug or an id returns
        // zero rows rather than an error.
        category: _selectedCategory?.names[ListingKind.event],
        subcategory: _selectedSubcategory?.names[ListingKind.event],
        pageSize: 10,
      );
      return [
        // Same reasoning as every other events list: a finished event has
        // nothing left to book, tapping in from a search result is as much
        // of a dead end as tapping in from a browse list.
        for (final e in page.results)
          if (!ListingSchedule.hasEnded(e.endDatetime))
            _SearchItem(
              type: ListingKind.event,
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
    if (!_sourceMatchesFilter(ListingKind.klass)) return const [];
    try {
      final page = await ClassesListingService.fetchClasses(
        search: q.isEmpty ? null : q,
        // Classes match on the exact name too — and on the FULL name, not the
        // truncated display label the category screens show.
        category: _selectedCategory?.names[ListingKind.klass],
        subcategory: _selectedSubcategory?.names[ListingKind.klass],
        pageSize: 10,
      );
      return [
        // Classes have no end date to filter by (open-ended recurring
        // schedule) — is_paused is the partner-controlled "not currently
        // bookable" signal instead.
        for (final c in page.results)
          if (!c.isPaused)
            _SearchItem(
              type: ListingKind.klass,
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
    if (!_sourceMatchesFilter(ListingKind.program)) return const [];
    try {
      final page = await ProgramsListingService.fetchPrograms(
        search: q.isEmpty ? null : q,
        // Programs are the mirror image of events/classes: the backend
        // ignores the name and honours only the integer id.
        categoryId: _selectedCategory?.ids[ListingKind.program],
        subcategoryId: _selectedSubcategory?.ids[ListingKind.program],
        pageSize: 10,
      );
      return [
        // Same reasoning as events: a finished program (every batch over)
        // has nothing left to book.
        for (final p in page.results)
          if (!ListingSchedule.hasEnded(p.endDatetime))
            _SearchItem(
              type: ListingKind.program,
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
    if (!_sourceMatchesFilter(ListingKind.venue)) return const [];
    try {
      final page = await EventsListingService.fetchVenues(
        search: q.isEmpty ? null : q,
        // Venues filter by integer id at both levels, like programs.
        categoryId: _selectedCategory?.ids[ListingKind.venue],
        subcategoryId: _selectedSubcategory?.ids[ListingKind.venue],
        pageSize: 10,
      );
      return [
        for (final v in page.results)
          _SearchItem(
            type: ListingKind.venue,
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
      ListingKind.event   => EventDetailScreen(event: item.eventModel),
      ListingKind.klass   => ClassDetailScreen(event: item.eventModel),
      ListingKind.program => ProgramDetailScreen(event: item.eventModel),
      ListingKind.venue   => VenueDetailScreen(event: item.eventModel),
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
    // Category before subcategory, matching the order they were picked in.
    final cat = _selectedCategory;
    if (cat != null) {
      out.add((
        label: cat.label,
        // Clearing the category clears the subcategory with it — a subcategory
        // is only meaningful under its parent.
        remove: () {
          setState(() {
            _selectedCategory = null;
            _selectedSubcategory = null;
          });
          _rerunSearch();
        },
      ));
    }
    final sub = _selectedSubcategory;
    if (sub != null) {
      out.add((
        label: sub.label,
        remove: () {
          setState(() => _selectedSubcategory = null);
          _rerunSearch();
        },
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
    final hadServerFilter = _hasServerFilter;
    setState(_resetFilters);
    // Only the category filter reaches the API, so only it needs a refetch.
    if (hadServerFilter) _rerunSearch();
  }

  /// The single definition of "no filters", so the chip row's Clear all and
  /// the sheet's own Clear All button cannot drift apart.
  void _resetFilters() {
    _selectedChip = 0;
    _ageGroupSelected.clear();
    _dateSelected.clear();
    _selectedMode = null;
    _selectedCategory = null;
    _selectedSubcategory = null;
  }

  /// Re-queries with the current text and filters. Used whenever a
  /// server-side filter changes outside the debounced text field.
  void _rerunSearch() {
    _debounce?.cancel();
    _doSearch(_searchController.text.trim());
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

  /// Category + subcategory picker, built from the merged taxonomy of all four
  /// listing types.
  ///
  /// Renders nothing at all when the taxonomy is unavailable (every metadata
  /// endpoint failed, or we are offline) — an empty "Category" heading would
  /// read as a broken filter rather than an absent one.
  Widget _buildCategorySection(
    BuildContext sheetContext,
    StateSetter setModalState,
  ) {
    // The taxonomy is usually still in flight when the sheet is opened right
    // after launch, so the section has to repaint when it lands rather than
    // leaving a spinner up until the sheet is reopened.
    return ValueListenableBuilder<int>(
      valueListenable: ListingTaxonomyState.version,
      builder: (_, __, ___) => _buildCategoryBody(sheetContext, setModalState),
    );
  }

  Widget _buildCategoryBody(
    BuildContext sheetContext,
    StateSetter setModalState,
  ) {
    if (ListingTaxonomyState.isLoading && !ListingTaxonomyState.isLoaded) {
      return Padding(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 16),
        child: Row(
          children: [
            _sectionHeading('Category'),
            const SizedBox(width: 12),
            const SizedBox(
              width: 14,
              height: 14,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: AppColors.primaryLight,
              ),
            ),
          ],
        ),
      );
    }

    final categories = ListingTaxonomyState.categories;
    if (categories.isEmpty) {
      // Every metadata endpoint failed. The repo's habit elsewhere is to fall
      // back to DummyData, but those entries carry labels and no ids — they
      // could never be resolved for programs or venues, so the filter would
      // look like it works and quietly do nothing. Say so and offer a retry.
      return Padding(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 16),
        child: Row(
          children: [
            Expanded(
              child: Text(
                "Categories couldn't be loaded",
                style: GoogleFonts.poppins(
                  fontSize: Responsive.sp(context, 13),
                  color: Colors.grey.shade600,
                ),
              ),
            ),
            GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: () async {
                await ListingTaxonomyState.load(force: true);
                // The sheet can be dismissed mid-retry; setModalState on a
                // torn-down StatefulBuilder throws. The ValueListenableBuilder
                // above repaints it anyway if it survived, so this is only a
                // nudge for the case where `version` did not change.
                if (sheetContext.mounted) setModalState(() {});
              },
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                child: Text(
                  'Retry',
                  style: GoogleFonts.poppins(
                    fontSize: Responsive.sp(context, 13),
                    fontWeight: FontWeight.w600,
                    color: AppColors.seeAllBlue,
                  ),
                ),
              ),
            ),
          ],
        ),
      );
    }

    final selected = _selectedCategory;
    final subcategories = selected?.children ?? const <TaxonomyNode>[];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _sectionHeading('Category'),
              ..._buildGroupedChips(
                nodes: categories,
                isSelected: (cat) => selected == cat,
                onTap: (cat) => setModalState(() {
                  _selectedCategory = selected == cat ? null : cat;
                  // The old subcategory belongs to the old parent.
                  _selectedSubcategory = null;
                }),
              ),
            ],
          ),
        ),
        // Subcategories only exist under a chosen category, so the section
        // appears with the parent rather than sitting there empty.
        if (selected != null && subcategories.isNotEmpty) ...[
          const Divider(height: 1, color: Color(0xFFEEEEEE)),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _sectionHeading('Subcategory'),
                // Grouped too: the two cross-type categories carry
                // near-duplicate subcategories from each backend ("Singing"
                // from events beside "Singing / Vocal Music" from classes),
                // which read as synonyms but return disjoint results.
                ..._buildGroupedChips(
                  nodes: subcategories,
                  isSelected: (sub) => _selectedSubcategory == sub,
                  onTap: (sub) => setModalState(() {
                    _selectedSubcategory =
                        _selectedSubcategory == sub ? null : sub;
                  }),
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }

  /// Chips grouped by the listing types that actually offer them.
  ///
  /// The four taxonomies barely overlap — of 38 merged categories only two
  /// ("Performing Arts", "Sports & Fitness") exist in more than one listing
  /// type. A flat alphabetical list therefore files near-synonyms from
  /// different backends next to each other with nothing to separate them:
  /// "Arts & Crafts" (events), "Creative Arts" (classes), "Design &
  /// Innovation" (programs) and "Creative & DIY" (venues) are four different
  /// chips that a parent reads as one idea. Grouping states the listing type
  /// once per group instead of annotating 36 chips individually, and makes
  /// "which categories does each type offer" answerable at a glance.
  List<Widget> _buildGroupedChips({
    required List<TaxonomyNode> nodes,
    required bool Function(TaxonomyNode) isSelected,
    required void Function(TaxonomyNode) onTap,
  }) {
    // Grouped by the exact set of sources, so a shared node is listed once
    // under a heading naming every type it covers rather than duplicated.
    final groups = <String, List<TaxonomyNode>>{};
    for (final node in nodes) {
      final key = ListingKind.values
          .where(node.has)
          .map(_kindLabel)
          .join(' · ');
      if (key.isEmpty) continue;
      groups.putIfAbsent(key, () => []).add(node);
    }

    // Shared groups first (they cover the most ground), then by listing-type
    // order, so the sequence is stable between opens.
    final keys = groups.keys.toList()
      ..sort((a, b) {
        final spanA = a.split(' · ').length;
        final spanB = b.split(' · ').length;
        if (spanA != spanB) return spanB.compareTo(spanA);
        return a.compareTo(b);
      });

    return [
      for (final key in keys) ...[
        const SizedBox(height: 12),
        Text(
          key,
          style: GoogleFonts.poppins(
            fontSize: Responsive.sp(context, 11.5),
            fontWeight: FontWeight.w600,
            color: Colors.grey.shade600,
          ),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: groups[key]!
              .map((node) => _buildFilterChip(
                    label: node.label,
                    isSelected: isSelected(node),
                    onTap: () => onTap(node),
                  ))
              .toList(),
        ),
      ],
    ];
  }

  static String _kindLabel(ListingKind kind) => switch (kind) {
        ListingKind.event => 'Events',
        ListingKind.klass => 'Classes',
        ListingKind.program => 'Programs',
        ListingKind.venue => 'Venues',
      };

  /// The sheet's section heading style, shared by every section.
  Widget _sectionHeading(String text) => Text(
        text,
        style: GoogleFonts.poppins(
          fontSize: Responsive.sp(context, 14),
          fontWeight: FontWeight.w500,
          color: AppColors.textPrimary,
        ),
      );

  Widget _buildBody() {
    // Searching an unserviced city returns nothing, and "No results for X"
    // blames the query for it. Say what is actually wrong, and offer the fix.
    if (!LocationState().isLocationSupported(
        LocationState().selectedCity.value)) {
      return const EmptyLocationWidget(title: 'Nothing to search here yet');
    }
    // A category filter is a query in its own right, so the prompt only
    // belongs here when there is genuinely nothing to show results for.
    if (_query.isEmpty && !_hasServerFilter) {
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
                // Reads the live text and current filters, not the stale
                // _query, so a retry after a filter change re-issues both.
                onTap: _rerunSearch,
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
            // With a filter on, an empty list is at least as likely to be the
            // filter's doing as the query's — pointing at the search term
            // would send the user to fix the wrong thing.
            Text(
              _query.isEmpty
                  ? 'No results for these filters'
                  : 'No results for "$_query"',
              style: GoogleFonts.poppins(
                fontSize: Responsive.sp(context, 15),
                fontWeight: FontWeight.w500,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              _hasServerFilter
                  ? 'Try removing a filter'
                  : 'Try a different search term',
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
    // Apply, the X and a swipe-dismiss all land in the same completion
    // callback and cannot be told apart, so rather than hanging the refetch
    // off Apply alone, compare the category selection across the sheet's whole
    // lifetime and requery whenever it actually moved. Clearing the category
    // and swiping away then refreshes the results just like Apply does.
    final categoryBefore = _selectedCategory;
    final subcategoryBefore = _selectedSubcategory;

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
                        // ── Category / Subcategory ───────────────────────────
                        _buildCategorySection(context, setModalState),
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
                          onPressed: () => setModalState(_resetFilters),
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
      if (!mounted) return;
      setState(() {});
      if (_selectedCategory != categoryBefore ||
          _selectedSubcategory != subcategoryBefore) {
        _rerunSearch();
      }
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
