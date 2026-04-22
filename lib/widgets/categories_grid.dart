import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../data/dummy_data.dart';
import '../screens/events_screen.dart';
import '../screens/classes_screen.dart';
import '../screens/programs_screen.dart';
import '../screens/venues_screen.dart';

class CategoriesGrid extends StatelessWidget {
  const CategoriesGrid({super.key});

  void _navigateTo(BuildContext context, String label) {
    Widget screen;
    switch (label) {
      case 'Events':
        screen = const EventsScreen();
        break;
      case 'Classes':
        screen = const ClassesScreen();
        break;
      case 'Program':
        screen = const ProgramsScreen();
        break;
      case 'Venues':
        screen = const VenuesScreen();
        break;
      default:
        screen = const EventsScreen(); // Shop placeholder
    }
    Navigator.push(context, MaterialPageRoute(builder: (_) => screen));
  }

  @override
  Widget build(BuildContext context) {
    final categories = DummyData.homeCategories;
    // Row 1: first 3 items, Row 2: remaining items
    final topRow = categories.sublist(0, 3);
    final bottomRow = categories.sublist(3);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        children: [
          // Top Row: 3 items
          Row(
            children: topRow.asMap().entries.map((entry) {
              final index = entry.key;
              final cat = entry.value;
              return Expanded(
                child: Padding(
                  padding: EdgeInsets.only(
                    right: index < topRow.length - 1 ? 12 : 0,
                  ),
                  child: GestureDetector(
                    onTap: () => _navigateTo(context, cat['label']),
                    child: _buildVerticalCategoryCard(context, cat),
                  ),
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 12),
          // Bottom Row: remaining items (horizontal layouts)
          Row(
            children: bottomRow.asMap().entries.map((entry) {
              final index = entry.key;
              final cat = entry.value;
              return Expanded(
                child: Padding(
                  padding: EdgeInsets.only(
                    right: index < bottomRow.length - 1 ? 12 : 0,
                  ),
                  child: GestureDetector(
                    onTap: () => _navigateTo(context, cat['label']),
                    child: _buildHorizontalCategoryCard(context, cat),
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  BoxDecoration _cardDecoration() {
    return BoxDecoration(
      gradient: LinearGradient(
        colors: [
          Colors.white,
          Colors.grey.shade200,
        ],
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
      ),
      borderRadius: BorderRadius.circular(16),
      border: Border.all(color: Colors.grey.shade300, width: 0.5),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withOpacity(0.04),
          blurRadius: 8,
          offset: const Offset(0, 3),
        ),
      ],
    );
  }

  Widget _buildVerticalCategoryCard(BuildContext context, Map<String, dynamic> cat) {
    return Container(
      height: 110,
      decoration: _cardDecoration(),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Expanded(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(12, 12, 12, 4),
              child: Image.asset(
                cat['image'],
                fit: BoxFit.contain,
                errorBuilder: (_, __, ___) => const Icon(
                  Icons.category_outlined,
                  size: 36,
                  color: Colors.grey,
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Text(
              cat['label'],
              style: GoogleFonts.poppins(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: const Color(0xFF1A1A2E),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHorizontalCategoryCard(BuildContext context, Map<String, dynamic> cat) {
    return Container(
      height: 70, // Slightly shorter than the square cards
      decoration: _cardDecoration(),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 8, top: 4, bottom: 4),
            child: Image.asset(
              cat['image'],
              width: 50, // Constrain image width so text fits nicely
              height: 50,
              fit: BoxFit.contain,
              errorBuilder: (_, __, ___) => const Icon(
                Icons.category_outlined,
                size: 28,
                color: Colors.grey,
              ),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              cat['label'],
              style: GoogleFonts.poppins(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: const Color(0xFF1A1A2E),
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}
