import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class HorizontalFilterChips extends StatelessWidget {
  final List<String> filters;
  final String selectedFilter;
  final Function(String) onFilterSelect;
  final VoidCallback onOpenFiltersSheet;

  const HorizontalFilterChips({
    super.key,
    required this.filters,
    required this.selectedFilter,
    required this.onFilterSelect,
    required this.onOpenFiltersSheet,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 36,
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        children: [
          // Black Filters button
          GestureDetector(
            onTap: onOpenFiltersSheet,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                color: Colors.black,
                borderRadius: BorderRadius.circular(18),
              ),
              child: Row(
                children: [
                  Text(
                    'Filters',
                    style: GoogleFonts.poppins(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(width: 4),
                  const Icon(Icons.keyboard_arrow_down, color: Colors.white, size: 16),
                ],
              ),
            ),
          ),
          const SizedBox(width: 8),
          
          // dynamic horizontal list
          ...filters.map((filter) {
            final isSelected = filter == selectedFilter;
            return GestureDetector(
              onTap: () => onFilterSelect(filter),
              child: Container(
                margin: const EdgeInsets.only(right: 8),
                padding: const EdgeInsets.symmetric(horizontal: 16),
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: isSelected ? Colors.transparent : const Color(0xFFF5F5F5),
                  borderRadius: BorderRadius.circular(18),
                  border: isSelected ? Border.all(color: const Color(0xFFFFCC00), width: 1.5) : null,
                ),
                child: Text(
                  filter,
                  style: GoogleFonts.poppins(
                    fontSize: 13,
                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                    color: isSelected ? const Color(0xFF1A1A2E) : Colors.grey.shade700,
                  ),
                ),
              ),
            );
          }),
        ],
      ),
    );
  }
}
