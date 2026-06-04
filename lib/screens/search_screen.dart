import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../core/responsive.dart';
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
  String? _selectedCity;
  String? _selectedArea;
  final Set<String> _ageGroupSelected = {};
  final Set<String> _dateSelected = {};

  final List<String> _chips = ['All', 'Events', 'Classes', 'Programs', 'Venues'];

  static const _ageGroups  = ['0-3 years', '3-5 years', '6-8 years', '9-12 years', '13-16 years'];
  static const _modes      = ['Offline', 'Hybrid', 'Online'];
  static const _cities     = ['Mumbai', 'Delhi', 'Bangalore', 'Hyderabad', 'Chennai', 'Pune'];
  static const _areas      = ['Bandra', 'Juhu', 'Andheri', 'Powai', 'Thane', 'Worli', 'Lower Parel'];
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

    try {
      // Start all four in parallel, await each after
      final eventsFuture   = EventsListingService.fetchEvents(search: q, pageSize: 10);
      final classesFuture  = ClassesListingService.fetchClasses(search: q, pageSize: 10);
      final programsFuture = ProgramsListingService.fetchPrograms(search: q, pageSize: 10);
      final venuesFuture   = EventsListingService.fetchVenues(search: q, pageSize: 10);

      final eventsPage   = await eventsFuture;
      final classesPage  = await classesFuture;
      final programsPage = await programsFuture;
      final venuesPage   = await venuesFuture;

      if (!mounted) return;

      final items = <_SearchItem>[
        for (final e in eventsPage.results)
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
        for (final c in classesPage.results)
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
        for (final p in programsPage.results)
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
        for (final v in venuesPage.results)
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

      // Client-side filter: the backend may return unrelated results if the
      // search param isn't implemented — only keep items that genuinely
      // contain the query in their title or subtitle.
      final qLower = q.toLowerCase();
      final relevant = items.where((item) {
        return item.title.toLowerCase().contains(qLower) ||
            item.subtitle.toLowerCase().contains(qLower);
      }).toList();

      setState(() { _allResults = relevant; _loading = false; });
    } catch (_) {
      if (!mounted) return;
      setState(() { _loading = false; _hasError = true; });
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
          icon: const Icon(Icons.arrow_back, color: Color(0xFF1A1A2E)),
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
                borderSide: const BorderSide(color: Color(0xFF1A1A2E), width: 1.5),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(24),
                borderSide: const BorderSide(color: Color(0xFF1A1A2E), width: 1.5),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(24),
                borderSide: const BorderSide(color: Color(0xFF1A1A2E), width: 1.5),
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
                      color: isSelected ? const Color(0xFF1A1A2E) : Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: const Color(0xFF1A1A2E), width: 1.5),
                    ),
                    child: Text(
                      _chips[index],
                      style: GoogleFonts.poppins(
                        fontSize: Responsive.sp(context, 13),
                        fontWeight: FontWeight.w500,
                        color: isSelected ? Colors.white : const Color(0xFF1A1A2E),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 8),
          Expanded(child: _buildBody()),
        ],
      ),
    );
  }

  Widget _buildBody() {
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
                  color: const Color(0xFF1A1A2E),
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
          color: Color(0xFFFFCC00),
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
                  color: const Color(0xFF1A1A2E),
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
                    color: const Color(0xFFFFCC00),
                    borderRadius: BorderRadius.circular(24),
                  ),
                  child: Text(
                    'Retry',
                    style: GoogleFonts.poppins(
                      fontSize: Responsive.sp(context, 14),
                      fontWeight: FontWeight.w500,
                      color: const Color(0xFF1A1A2E),
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
                color: const Color(0xFF1A1A2E),
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
              fontSize: Responsive.sp(context, 14),
              fontWeight: FontWeight.w500,
              color: const Color(0xFF1A1A2E),
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
                          color: const Color(0xFF1A1A2E),
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
                          child: const Icon(Icons.close, size: 18, color: Color(0xFF1A1A2E)),
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
                        // ── Age Group ────────────────────────────────────────
                        Padding(
                          padding: const EdgeInsets.fromLTRB(20, 16, 20, 16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Age Group', style: GoogleFonts.poppins(fontSize: Responsive.sp(context, 14), fontWeight: FontWeight.w500, color: const Color(0xFF1A1A2E))),
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
                              Text('Mode', style: GoogleFonts.poppins(fontSize: Responsive.sp(context, 14), fontWeight: FontWeight.w500, color: const Color(0xFF1A1A2E))),
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
                        // ── Location ─────────────────────────────────────────
                        Padding(
                          padding: const EdgeInsets.fromLTRB(20, 16, 20, 16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Location', style: GoogleFonts.poppins(fontSize: Responsive.sp(context, 14), fontWeight: FontWeight.w500, color: const Color(0xFF1A1A2E))),
                              const SizedBox(height: 12),
                              _buildDropdown(
                                hint: 'City',
                                value: _selectedCity,
                                items: _cities,
                                onChanged: (v) => setModalState(() { _selectedCity = v; _selectedArea = null; }),
                              ),
                              const SizedBox(height: 10),
                              _buildDropdown(
                                hint: 'Area/Locality',
                                value: _selectedArea,
                                items: _areas,
                                onChanged: (v) => setModalState(() => _selectedArea = v),
                              ),
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
                              Text('Date', style: GoogleFonts.poppins(fontSize: Responsive.sp(context, 14), fontWeight: FontWeight.w500, color: const Color(0xFF1A1A2E))),
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
                            _ageGroupSelected.clear();
                            _dateSelected.clear();
                            _selectedMode = null;
                            _selectedCity = null;
                            _selectedArea = null;
                          }),
                          style: OutlinedButton.styleFrom(
                            side: const BorderSide(color: Color(0xFFE0E0E0)),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            padding: const EdgeInsets.symmetric(vertical: 14),
                          ),
                          child: Text('Clear All', style: GoogleFonts.poppins(fontSize: Responsive.sp(context, 15), fontWeight: FontWeight.w500, color: const Color(0xFF1A1A2E))),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () => Navigator.pop(ctx),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFFFFCC00),
                            foregroundColor: const Color(0xFF1A1A2E),
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
    );
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
                  color: isSelected ? const Color(0xFF1A1A2E) : Colors.grey.shade400,
                  width: 2,
                ),
              ),
              child: isSelected
                  ? Center(
                      child: Container(
                        width: 10,
                        height: 10,
                        decoration: const BoxDecoration(shape: BoxShape.circle, color: Color(0xFF1A1A2E)),
                      ),
                    )
                  : null,
            ),
            const SizedBox(width: 12),
            Text(label, style: GoogleFonts.poppins(fontSize: Responsive.sp(context, 14), fontWeight: FontWeight.w500, color: const Color(0xFF1A1A2E))),
          ],
        ),
      ),
    );
  }

  Widget _buildDropdown({required String hint, required String? value, required List<String> items, required ValueChanged<String?> onChanged}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(color: const Color(0xFFF5F5F5), borderRadius: BorderRadius.circular(12)),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: value,
          hint: Text(hint, style: GoogleFonts.poppins(fontSize: Responsive.sp(context, 14), color: Colors.grey.shade500)),
          items: items.map((item) => DropdownMenuItem(
            value: item,
            child: Text(item, style: GoogleFonts.poppins(fontSize: Responsive.sp(context, 14), color: const Color(0xFF1A1A2E))),
          )).toList(),
          onChanged: onChanged,
          isExpanded: true,
          icon: const Icon(Icons.keyboard_arrow_down_rounded, color: Color(0xFF1A1A2E)),
          dropdownColor: Colors.white,
          style: GoogleFonts.poppins(fontSize: Responsive.sp(context, 14), color: const Color(0xFF1A1A2E)),
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
          color: isSelected ? const Color(0xFFFFCC00) : Colors.grey.shade200,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (isSelected) ...[
              const Icon(Icons.close, size: 16, color: Color(0xFF1A1A2E)),
              const SizedBox(width: 6),
            ],
            Text(label, style: GoogleFonts.poppins(fontSize: Responsive.sp(context, 13), fontWeight: FontWeight.w500, color: const Color(0xFF1A1A2E))),
          ],
        ),
      ),
    );
  }
}
