import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../core/location_state.dart';
import '../core/app_colors.dart';

class LocationScreen extends StatefulWidget {
  const LocationScreen({super.key});

  @override
  State<LocationScreen> createState() => _LocationScreenState();
}

class _LocationScreenState extends State<LocationScreen> {
  final TextEditingController _searchController = TextEditingController();

  final List<Map<String, dynamic>> _popularCities = [
    {'name': 'Delhi NCR', 'icon': Icons.account_balance, 'image': 'assets/images/new_home/india-gate.png'},
    {'name': 'Mumbai', 'icon': Icons.apartment, 'image': 'assets/images/new_home/gateway.png'},
    {'name': 'Hyderabad', 'icon': Icons.location_city, 'image': 'assets/images/new_home/charminar.png'},
    {'name': 'Kolkata', 'icon': Icons.museum},
    {'name': 'Pune', 'icon': Icons.villa},
    {'name': 'Bengaluru', 'icon': Icons.account_balance},
  ];

  final List<String> _allCities = [
    'Agra',
    'Ahmedabad',
    'Ajmer',
    'Aligarh',
    'Amritsar',
    'Bengaluru',
    'Bhopal',
    'Chennai',
    'Delhi NCR',
    'Goa',
    'Hyderabad',
    'Jaipur',
    'Kochi',
    'Kolkata',
    'Lucknow',
    'Mumbai',
    'Pune',
  ];

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _selectCity(String city) {
    LocationState().setCity(city);
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9FAFB), // Very light grey backround
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        leadingWidth: 64,
        leading: Container(
          margin: const EdgeInsets.only(left: 16, top: 8, bottom: 8),
          decoration: const BoxDecoration(
            color: Colors.white,
            shape: BoxShape.circle,
          ),
          child: IconButton(
            icon: const Icon(Icons.arrow_back, color: Color(0xFF1A1A2E), size: 20),
            onPressed: () => Navigator.pop(context),
            splashRadius: 24,
          ),
        ),
        title: Text(
          'Select Location',
          style: GoogleFonts.poppins(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: const Color(0xFF1A1A2E),
          ),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Search Bar
            Container(
              height: 50,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: Colors.grey.shade300),
              ),
              child: TextField(
                controller: _searchController,
                decoration: InputDecoration(
                  hintText: 'Search city, area or landmark...',
                  hintStyle: GoogleFonts.poppins(
                    fontSize: 14,
                    color: Colors.grey.shade500,
                  ),
                  prefixIcon: Icon(Icons.search, color: Colors.grey.shade600),
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(vertical: 15),
                ),
                style: GoogleFonts.poppins(fontSize: 14),
                onSubmitted: (value) {
                  if (value.trim().isNotEmpty) {
                    _selectCity(value);
                  }
                },
              ),
            ),
            const SizedBox(height: 24),

            // Use Current Location Button
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton.icon(
                onPressed: () => _selectCity('Sonipat'), // Dummy current location
                icon: const Icon(Icons.my_location, color: Color(0xFF1A1A2E), size: 20),
                label: Text(
                  'Use current location',
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF1A1A2E),
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryLight, // #FFCC02 Bright Yellow
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 32),

            // Popular Cities Header
            Text(
              'Popular Cities',
              style: GoogleFonts.poppins(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: const Color(0xFF1A1A2E),
              ),
            ),
            const SizedBox(height: 16),

            // Popular Cities Grid
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                mainAxisSpacing: 12,
                crossAxisSpacing: 12,
                childAspectRatio: 0.9, // Slightly taller cards
              ),
              itemCount: _popularCities.length,
              itemBuilder: (context, index) {
                final city = _popularCities[index];
                return GestureDetector(
                  onTap: () => _selectCity(city['name'] as String),
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        if (city.containsKey('image'))
                          Image.asset(
                            city['image'] as String,
                            color: const Color(0xFFE0A000), // Dark yellow
                            height: 42,
                          )
                        else
                          Icon(
                            city['icon'] as IconData,
                            color: const Color(0xFFE0A000), // Match the dark yellow
                            size: 42,
                          ),
                        const SizedBox(height: 12),
                        Text(
                          city['name'] as String,
                          style: GoogleFonts.poppins(
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            color: const Color(0xFF1A1A2E),
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
            const SizedBox(height: 32),

            // All Cities Header
            Text(
              'All Cities',
              style: GoogleFonts.poppins(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: const Color(0xFF1A1A2E),
              ),
            ),
            const SizedBox(height: 8),

            // All Cities List
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: _allCities.length,
              separatorBuilder: (context, index) => Divider(
                color: Colors.grey.shade200,
                height: 1,
              ),
              itemBuilder: (context, index) {
                final city = _allCities[index];
                return InkWell(
                  onTap: () => _selectCity(city),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    child: Text(
                      city,
                      style: GoogleFonts.poppins(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: const Color(0xFF1A1A2E),
                      ),
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
