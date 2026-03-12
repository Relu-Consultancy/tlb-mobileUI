import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../core/responsive.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final TextEditingController _searchController = TextEditingController();
  int _selectedChip = 0;

  // Filter state
  bool _paidSelected = true;
  bool _freeSelected = false;
  bool _trendingOn = false;
  bool _highlyRatedOn = false;
  final Set<String> _ageGroupSelected = {'3-5 years'};
  final Set<String> _dateSelected = {'Today'};

  final List<String> _chips = ['Stream', 'Events', 'Plays', 'Sports'];

  final List<String> _trendingSearches = [
    'Dhurandhar',
    'Mastiii 4',
    'Tere Ishk Mein',
    'Now You See Me: Now You Don\'t',
    'De De Pyaar De 2',
    'Ikk Kudi',
    'Haq',
    'AP Dhillon: One Of One Tour - Delhi',
  ];

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
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
            decoration: InputDecoration(
              hintText: 'Search for events ...',
              hintStyle: GoogleFonts.poppins(
                fontSize: 14,
                color: Colors.grey,
              ),
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              suffixIcon: IconButton(
                icon: const Icon(Icons.tune, color: Colors.black),
                onPressed: () => _showFiltersBottomSheet(context),
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
            style: GoogleFonts.poppins(fontSize: 14),
          ),
        ),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Category chips
          const SizedBox(height: 8),
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
                      border: Border.all(
                        color: const Color(0xFF1A1A2E),
                        width: 1.5,
                      ),
                    ),
                    child: Text(
                      _chips[index],
                      style: GoogleFonts.poppins(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: isSelected ? Colors.white : const Color(0xFF1A1A2E),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),

          const SizedBox(height: 20),

          // Trending header
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Text(
              'Popular / Trending Searches',
              style: GoogleFonts.poppins(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Colors.black,
              ),
            ),
          ),

          const SizedBox(height: 8),

          // Trending list
          Expanded(
            child: ListView.separated(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: _trendingSearches.length,
              separatorBuilder: (_, __) => const Divider(height: 1),
              itemBuilder: (context, index) {
                return ListTile(
                  contentPadding: EdgeInsets.zero,
                  title: Text(
                    _trendingSearches[index],
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: const Color(0xFF1A1A2E),
                    ),
                  ),
                  trailing: const Icon(
                    Icons.movie_creation_outlined,
                    color: Colors.grey,
                    size: 22,
                  ),
                  onTap: () {},
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  void _showFiltersBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setModalState) {
          final resultCount = 24; // Could be computed from filters
          return Container(
            constraints: BoxConstraints(
              maxHeight: MediaQuery.of(context).size.height * 0.85,
            ),
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Header
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 20, 20, 12),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Filters',
                        style: GoogleFonts.poppins(
                          fontSize: Responsive.sp(context, 18),
                          fontWeight: FontWeight.w700,
                          color: const Color(0xFF1A1A2E),
                        ),
                      ),
                      GestureDetector(
                        onTap: () {
                          setModalState(() {
                            _paidSelected = false;
                            _freeSelected = false;
                            _trendingOn = false;
                            _highlyRatedOn = false;
                            _ageGroupSelected.clear();
                            _dateSelected.clear();
                          });
                        },
                        child: Text(
                          'Clear All',
                          style: GoogleFonts.poppins(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: Colors.blue,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const Divider(height: 1),
                Flexible(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Availability
                        Text(
                          'Availability',
                          style: GoogleFonts.poppins(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: const Color(0xFF1A1A2E),
                          ),
                        ),
                        const SizedBox(height: 10),
                        Row(
                          children: [
                            _buildFilterChip(
                              label: 'Paid',
                              isSelected: _paidSelected,
                              onTap: () {
                                setModalState(() {
                                  _paidSelected = !_paidSelected;
                                  if (_paidSelected) _freeSelected = false;
                                });
                              },
                            ),
                            const SizedBox(width: 10),
                            _buildFilterChip(
                              label: 'Free',
                              isSelected: _freeSelected,
                              onTap: () {
                                setModalState(() {
                                  _freeSelected = !_freeSelected;
                                  if (_freeSelected) _paidSelected = false;
                                });
                              },
                            ),
                          ],
                        ),
                        const SizedBox(height: 20),
                        // Trending
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Trending',
                              style: GoogleFonts.poppins(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: const Color(0xFF1A1A2E),
                              ),
                            ),
                            Switch(
                              value: _trendingOn,
                              onChanged: (v) => setModalState(() => _trendingOn = v),
                              activeTrackColor: const Color(0xFFFFCC00).withOpacity(0.6),
                              activeThumbColor: const Color(0xFFFFCC00),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        // Highly Rated
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Highly Rated',
                              style: GoogleFonts.poppins(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: const Color(0xFF1A1A2E),
                              ),
                            ),
                            Switch(
                              value: _highlyRatedOn,
                              onChanged: (v) => setModalState(() => _highlyRatedOn = v),
                              activeTrackColor: const Color(0xFFFFCC00).withOpacity(0.6),
                              activeThumbColor: const Color(0xFFFFCC00),
                            ),
                          ],
                        ),
                        const SizedBox(height: 20),
                        // Age Group
                        Text(
                          'Age Group',
                          style: GoogleFonts.poppins(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: const Color(0xFF1A1A2E),
                          ),
                        ),
                        const SizedBox(height: 10),
                        Wrap(
                          spacing: 10,
                          runSpacing: 10,
                          children: ['3-5 years', '6-8 years', '9-12 years', 'Teens (13+)']
                              .map((label) => _buildFilterChip(
                                    label: label,
                                    isSelected: _ageGroupSelected.contains(label),
                                    onTap: () {
                                      setModalState(() {
                                        if (_ageGroupSelected.contains(label)) {
                                          _ageGroupSelected.remove(label);
                                        } else {
                                          _ageGroupSelected.add(label);
                                        }
                                      });
                                    },
                                  ))
                              .toList(),
                        ),
                        const SizedBox(height: 20),
                        // Date
                        Text(
                          'Date',
                          style: GoogleFonts.poppins(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: const Color(0xFF1A1A2E),
                          ),
                        ),
                        const SizedBox(height: 10),
                        Wrap(
                          spacing: 10,
                          runSpacing: 10,
                          children: ['Today', 'This Week', 'Weekend', 'Custom']
                              .map((label) => _buildFilterChip(
                                    label: label,
                                    isSelected: _dateSelected.contains(label),
                                    onTap: () {
                                      setModalState(() {
                                        if (_dateSelected.contains(label)) {
                                          _dateSelected.remove(label);
                                        } else {
                                          _dateSelected.add(label);
                                        }
                                      });
                                    },
                                  ))
                              .toList(),
                        ),
                      ],
                    ),
                  ),
                ),
                // Show results button
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
                  child: ElevatedButton(
                    onPressed: () => Navigator.pop(ctx),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFFFCC00),
                      foregroundColor: const Color(0xFF1A1A2E),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 0,
                    ),
                    child: Text(
                      'Show $resultCount results',
                      style: GoogleFonts.poppins(
                        fontSize: Responsive.sp(context, 16),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildFilterChip({
    required String label,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
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
            Text(
              label,
              style: GoogleFonts.poppins(
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color: const Color(0xFF1A1A2E),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
