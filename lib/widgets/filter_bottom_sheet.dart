import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class FilterBottomSheet extends StatefulWidget {
  final Map<String, bool> initialFilters;
  final Function(Map<String, bool>) onApply;

  const FilterBottomSheet({
    super.key,
    required this.initialFilters,
    required this.onApply,
  });

  @override
  State<FilterBottomSheet> createState() => _FilterBottomSheetState();
}

class _FilterBottomSheetState extends State<FilterBottomSheet> {
  late Map<String, bool> _filters;

  @override
  void initState() {
    super.initState();
    _filters = Map.from(widget.initialFilters);
  }

  void _clearAll() {
    setState(() {
      _filters.updateAll((key, value) => false);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(24),
          topRight: Radius.circular(24),
        ),
      ),
      padding: EdgeInsets.only(
        top: 24,
        left: 20,
        right: 20,
        bottom: MediaQuery.of(context).padding.bottom + 20,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Filters',
                style: GoogleFonts.poppins(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: const Color(0xFF1A1A2E),
                ),
              ),
              GestureDetector(
                onTap: () => Navigator.pop(context),
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade100,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.close, size: 18, color: Color(0xFF1A1A2E)),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),

          // Checkboxes List
          Flexible(
            child: SingleChildScrollView(
              child: Column(
                children: _filters.keys.map((filterName) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 16.0),
                    child: Row(
                      children: [
                        GestureDetector(
                          onTap: () {
                            setState(() {
                              _filters[filterName] = !(_filters[filterName] ?? false);
                            });
                          },
                          child: Container(
                            width: 24,
                            height: 24,
                            decoration: BoxDecoration(
                              color: _filters[filterName] == true
                                  ? const Color(0xFF1A1A2E) // Dark selection color matching design
                                  : Colors.white,
                              border: Border.all(
                                color: _filters[filterName] == true
                                    ? const Color(0xFF1A1A2E)
                                    : Colors.grey.shade400,
                                width: 1.5,
                              ),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            // Checkmark not strictly in design image, but standard for checkboxes if needed. 
                            // The design just shows a solid box fill.
                          ),
                        ),
                        const SizedBox(width: 12),
                        Text(
                          filterName,
                          style: GoogleFonts.poppins(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                            color: const Color(0xFF333333),
                          ),
                        ),
                      ],
                    ),
                  );
                }).toList(),
              ),
            ),
          ),
          const SizedBox(height: 20),
          Divider(color: Colors.grey.shade200),
          const SizedBox(height: 20),

          // Bottom Buttons
          Row(
            children: [
              Expanded(
                child: ElevatedButton(
                  onPressed: () {
                    widget.onApply(_filters);
                    Navigator.pop(context);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFFFCC00),
                    foregroundColor: const Color(0xFF1A1A2E),
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(24),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                  child: Text(
                    'Apply',
                    style: GoogleFonts.poppins(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton(
                  onPressed: _clearAll,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFE0E0E0), // Light grey
                    foregroundColor: const Color(0xFF1A1A2E),
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(24),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                  child: Text(
                    'Clear All',
                    style: GoogleFonts.poppins(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
