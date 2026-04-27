import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../core/responsive.dart';

/// Result returned when the user taps "Apply".
class FilterResult {
  final String? selectedSort;
  final List<String> selectedFilters;
  final List<String> selectedCategories;

  const FilterResult({
    this.selectedSort,
    this.selectedFilters = const [],
    this.selectedCategories = const [],
  });
}

/// A reusable filter bottom-sheet with a left sidebar (Sort by / Filters / Categories)
/// and a right content panel. Based on the Component 711 design mockup.
class FilterBottomSheet extends StatefulWidget {
  final List<String> sortOptions;
  final List<String> filterOptions;
  final List<String> categoryOptions;

  /// Pre-selected values for restoring state.
  final String? initialSort;
  final List<String> initialFilters;
  final List<String> initialCategories;

  const FilterBottomSheet({
    super.key,
    required this.sortOptions,
    required this.filterOptions,
    required this.categoryOptions,
    this.initialSort,
    this.initialFilters = const [],
    this.initialCategories = const [],
  });

  /// Convenience method to show the sheet and return the result.
  static Future<FilterResult?> show(
    BuildContext context, {
    required List<String> sortOptions,
    required List<String> filterOptions,
    required List<String> categoryOptions,
    String? initialSort,
    List<String> initialFilters = const [],
    List<String> initialCategories = const [],
  }) {
    return showModalBottomSheet<FilterResult>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      barrierColor: Colors.black.withOpacity(0.45),
      builder: (_) => FilterBottomSheet(
        sortOptions: sortOptions,
        filterOptions: filterOptions,
        categoryOptions: categoryOptions,
        initialSort: initialSort,
        initialFilters: initialFilters,
        initialCategories: initialCategories,
      ),
    );
  }

  @override
  State<FilterBottomSheet> createState() => _FilterBottomSheetState();
}

class _FilterBottomSheetState extends State<FilterBottomSheet> {
  int _activeTab = 0; // 0 = Sort by, 1 = Filters, 2 = Categories
  String? _selectedSort;
  late List<String> _selectedFilters;
  late List<String> _selectedCategories;

  static const _tabLabels = ['Sort by', 'Filters', 'Categories'];

  @override
  void initState() {
    super.initState();
    _selectedSort = widget.initialSort;
    _selectedFilters = List.from(widget.initialFilters);
    _selectedCategories = List.from(widget.initialCategories);
  }

  void _clearAll() {
    setState(() {
      _selectedSort = null;
      _selectedFilters.clear();
      _selectedCategories.clear();
    });
  }

  void _apply() {
    Navigator.pop(
      context,
      FilterResult(
        selectedSort: _selectedSort,
        selectedFilters: List.from(_selectedFilters),
        selectedCategories: List.from(_selectedCategories),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;

    return Container(
      constraints: BoxConstraints(maxHeight: screenHeight * 0.55),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Drag handle
          const SizedBox(height: 10),
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.grey.shade300,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 4),

          // Body: sidebar + content
          Expanded(
            child: Row(
              children: [
                // ── Left sidebar ──
                Container(
                  width: Responsive.w(context, 110, min: 90),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF5F5F5),
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(24),
                    ),
                    border: Border(
                      right: BorderSide(color: Colors.grey.shade200),
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: List.generate(_tabLabels.length, (i) {
                      final isActive = _activeTab == i;
                      return GestureDetector(
                        onTap: () => setState(() => _activeTab = i),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 180),
                          padding: const EdgeInsets.symmetric(
                              vertical: 18, horizontal: 12),
                          decoration: BoxDecoration(
                            color: isActive ? Colors.white : Colors.transparent,
                            border: Border(
                              left: BorderSide(
                                color: isActive
                                    ? const Color(0xFFFFB902)
                                    : Colors.transparent,
                                width: 3,
                              ),
                            ),
                          ),
                          child: Text(
                            _tabLabels[i],
                            style: GoogleFonts.poppins(
                              fontSize: Responsive.sp(context, 14),
                              fontWeight:
                                  isActive ? FontWeight.w600 : FontWeight.w500,
                              color: isActive
                                  ? const Color(0xFF1A1A1A)
                                  : const Color(0xFF757575),
                            ),
                          ),
                        ),
                      );
                    }),
                  ),
                ),

                // ── Right content ──
                Expanded(
                  child: Column(
                    children: [
                      // Header with title + close button
                      Padding(
                        padding: const EdgeInsets.fromLTRB(16, 14, 8, 8),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              _tabLabels[_activeTab],
                              style: GoogleFonts.poppins(
                                fontSize: 16,
                                fontWeight: FontWeight.w700,
                                color: const Color(0xFF1A1A2E),
                              ),
                            ),
                            IconButton(
                              onPressed: () => Navigator.pop(context),
                              icon: Container(
                                width: 28,
                                height: 28,
                                decoration: BoxDecoration(
                                  color: const Color(0xFFF0F0F0),
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(Icons.close,
                                    size: 16, color: Color(0xFF1A1A2E)),
                              ),
                            ),
                          ],
                        ),
                      ),

                      // Scrollable options
                      Expanded(
                        child: AnimatedSwitcher(
                          duration: const Duration(milliseconds: 200),
                          child: _buildTabContent(),
                        ),
                      ),

                      // Footer: Clear All + Apply
                      Container(
                        padding: const EdgeInsets.fromLTRB(16, 10, 16, 16),
                        decoration: BoxDecoration(
                          border: Border(
                            top: BorderSide(color: Colors.grey.shade200),
                          ),
                        ),
                        child: Row(
                          children: [
                            Expanded(
                              child: OutlinedButton(
                                onPressed: _clearAll,
                                style: OutlinedButton.styleFrom(
                                  side: const BorderSide(
                                      color: Color(0xFFE0E0E0)),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(24),
                                  ),
                                  padding:
                                      const EdgeInsets.symmetric(vertical: 12),
                                ),
                                child: Text(
                                  'Clear All',
                                  style: GoogleFonts.poppins(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w600,
                                    color: const Color(0xFF1A1A2E),
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: ElevatedButton(
                                onPressed: _apply,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFFFFB902),
                                  foregroundColor: const Color(0xFF1A1A2E),
                                  elevation: 0,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(24),
                                  ),
                                  padding:
                                      const EdgeInsets.symmetric(vertical: 12),
                                ),
                                child: Text(
                                  'Apply',
                                  style: GoogleFonts.poppins(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTabContent() {
    switch (_activeTab) {
      case 0:
        return _SortByPanel(
          key: const ValueKey('sort'),
          options: widget.sortOptions,
          selected: _selectedSort,
          onChanged: (val) => setState(() => _selectedSort = val),
        );
      case 1:
        return _CheckboxPanel(
          key: const ValueKey('filters'),
          options: widget.filterOptions,
          selected: _selectedFilters,
          onChanged: (list) => setState(() => _selectedFilters = list),
        );
      case 2:
        return _CheckboxPanel(
          key: const ValueKey('categories'),
          options: widget.categoryOptions,
          selected: _selectedCategories,
          onChanged: (list) => setState(() => _selectedCategories = list),
        );
      default:
        return const SizedBox.shrink();
    }
  }
}

// ── Sort-by panel (radio buttons) ────────────────────────────────────────────
class _SortByPanel extends StatelessWidget {
  final List<String> options;
  final String? selected;
  final ValueChanged<String?> onChanged;

  const _SortByPanel({
    super.key,
    required this.options,
    required this.selected,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      itemCount: options.length,
      separatorBuilder: (_, __) => const SizedBox(height: 0),
      itemBuilder: (_, i) {
        final isSelected = options[i] == selected;
        return InkWell(
          onTap: () => onChanged(options[i]),
          borderRadius: BorderRadius.circular(8),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 10),
            child: Row(
              children: [
                Container(
                  width: 20,
                  height: 20,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: isSelected
                          ? const Color(0xFFFFB902)
                          : Colors.grey.shade400,
                      width: 2,
                    ),
                  ),
                  child: isSelected
                      ? Center(
                          child: Container(
                            width: 10,
                            height: 10,
                            decoration: const BoxDecoration(
                              shape: BoxShape.circle,
                              color: Color(0xFFFFB902),
                            ),
                          ),
                        )
                      : null,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    options[i],
                    style: GoogleFonts.poppins(
                      fontSize: 13,
                      fontWeight:
                          isSelected ? FontWeight.w600 : FontWeight.w400,
                      color: const Color(0xFF1A1A2E),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

// ── Checkbox panel (multi-select) ────────────────────────────────────────────
class _CheckboxPanel extends StatelessWidget {
  final List<String> options;
  final List<String> selected;
  final ValueChanged<List<String>> onChanged;

  const _CheckboxPanel({
    super.key,
    required this.options,
    required this.selected,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      itemCount: options.length,
      separatorBuilder: (_, __) => const SizedBox(height: 0),
      itemBuilder: (_, i) {
        final isChecked = selected.contains(options[i]);
        return InkWell(
          onTap: () {
            final updated = List<String>.from(selected);
            if (isChecked) {
              updated.remove(options[i]);
            } else {
              updated.add(options[i]);
            }
            onChanged(updated);
          },
          borderRadius: BorderRadius.circular(8),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 10),
            child: Row(
              children: [
                Container(
                  width: 20,
                  height: 20,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(4),
                    border: Border.all(
                      color: isChecked
                          ? const Color(0xFFFFB902)
                          : Colors.grey.shade400,
                      width: 1.5,
                    ),
                    color: isChecked
                        ? const Color(0xFFFFB902)
                        : Colors.transparent,
                  ),
                  child: isChecked
                      ? const Icon(Icons.check, size: 14, color: Colors.white)
                      : null,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    options[i],
                    style: GoogleFonts.poppins(
                      fontSize: 13,
                      fontWeight:
                          isChecked ? FontWeight.w600 : FontWeight.w400,
                      color: const Color(0xFF1A1A2E),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
