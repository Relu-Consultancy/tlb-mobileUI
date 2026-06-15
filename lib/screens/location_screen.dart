import 'package:flutter/material.dart';
import '../core/app_snackbar.dart';
import '../core/responsive.dart';
import '../widgets/app_loader.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:async';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import '../providers/location_state.dart';
import '../core/app_colors.dart';

class LocationScreen extends StatefulWidget {
  const LocationScreen({super.key});

  @override
  State<LocationScreen> createState() => _LocationScreenState();
}

class _LocationScreenState extends State<LocationScreen> {
  final TextEditingController _searchController = TextEditingController();
  bool _isLoadingLocation = false;

  final List<Map<String, dynamic>> _popularCities = [
    {'name': 'Delhi NCR', 'icon': Icons.account_balance, 'image': 'assets/images/new_home/india-gate.png'},
    {'name': 'Mumbai', 'icon': Icons.apartment, 'image': 'assets/images/new_home/gateway.png'},
    {'name': 'Hyderabad', 'icon': Icons.location_city, 'image': 'assets/images/new_home/charminar.png'},
    {'name': 'Kolkata', 'icon': Icons.museum, 'image': 'location_screen_resources/kolkata.png'},
    {'name': 'Pune', 'icon': Icons.villa, 'image': 'location_screen_resources/pune.png'},
    {'name': 'Bengaluru', 'icon': Icons.account_balance, 'image': 'location_screen_resources/bangalore.png'},
  ];

  final List<String> _allCities = [
    'Agra',
    'Ahmedabad',
    'Ajmer',
    'Aligarh',
    'Amritsar',
    'Bengaluru',
    'Bhopal',
    'Chandigarh',
    'Chennai',
    'Coimbatore',
    'Delhi NCR',
    'Goa',
    'Guwahati',
    'Hyderabad',
    'Indore',
    'Jaipur',
    'Kanpur',
    'Kochi',
    'Kolkata',
    'Lucknow',
    'Mumbai',
    'Nagpur',
    'Patna',
    'Pune',
    'Surat',
    'Vadodara',
    'Visakhapatnam',
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

  /// Confirmation dialog used when location is blocked at the OS level. The
  /// "Open Settings" action runs [onOpen] (app settings or location settings).
  Future<void> _showSettingsDialog({
    required String title,
    required String message,
    required Future<bool> Function() onOpen,
  }) async {
    if (!mounted) return;
    await showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(
          title,
          style: GoogleFonts.poppins(
            fontSize: Responsive.sp(context, 17),
            fontWeight: FontWeight.w600,
            color: const Color(0xFF1A1A2E),
          ),
        ),
        content: Text(
          message,
          style: GoogleFonts.poppins(
            fontSize: Responsive.sp(context, 13.5),
            color: const Color(0xFF5A5A6A),
            height: 1.4,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(
              'Cancel',
              style: GoogleFonts.poppins(
                fontWeight: FontWeight.w500,
                color: const Color(0xFF9E9E9E),
              ),
            ),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(ctx);
              await onOpen();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFFFCC00),
              foregroundColor: const Color(0xFF1A1A2E),
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(24),
              ),
            ),
            child: Text(
              'Open Settings',
              style: GoogleFonts.poppins(fontWeight: FontWeight.w500),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _fetchCurrentLocation() async {
    setState(() => _isLoadingLocation = true);

    try {
      // Check if location services (GPS) are enabled device-wide. If not, send
      // the user to the OS location settings to turn it on.
      final serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        if (!mounted) return;
        setState(() => _isLoadingLocation = false);
        await _showSettingsDialog(
          title: 'Turn on location',
          message:
              'Location services (GPS) are turned off. Enable them in settings to use your current location.',
          onOpen: Geolocator.openLocationSettings,
        );
        return;
      }

      // Check / request permission — triggers the OS permission dialog.
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }

      // Permanently denied ("Don't ask again" / iOS denied) — the OS will no
      // longer show a prompt, so route the user to app settings instead.
      if (permission == LocationPermission.deniedForever) {
        if (!mounted) return;
        setState(() => _isLoadingLocation = false);
        await _showSettingsDialog(
          title: 'Location permission needed',
          message:
              'Location permission is blocked. Please enable it for TLB in app settings to use your current location.',
          onOpen: Geolocator.openAppSettings,
        );
        return;
      }

      // Denied this time but not permanently — nothing more we can do now.
      if (permission == LocationPermission.denied) {
        if (!mounted) return;
        AppSnackBar.show(context, 'Location permission denied.');
        return;
      }

      // Fetch position with a 15-second timeout to avoid infinite loading
      final position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(accuracy: LocationAccuracy.medium),
      ).timeout(
        const Duration(seconds: 15),
        onTimeout: () => throw TimeoutException('GPS timed out'),
      );

      final placemarks = await placemarkFromCoordinates(
        position.latitude,
        position.longitude,
      ).timeout(const Duration(seconds: 10));

      if (placemarks.isNotEmpty && mounted) {
        final p = placemarks.first;
        final rawCity = p.locality ?? p.subAdministrativeArea ?? p.administrativeArea ?? '';
        final matched = _matchToKnownCity(rawCity);
        _selectCity(matched ?? rawCity);
      }
    } on TimeoutException {
      if (mounted) {
        AppSnackBar.error(context, 'Location request timed out. Please try again.');
      }
    } catch (_) {
      if (mounted) {
        AppSnackBar.error(context, 'Could not determine your location. Please try again.');
      }
    } finally {
      if (mounted) setState(() => _isLoadingLocation = false);
    }
  }

  /// Tries to map a raw geocoded city name to a known city in the app's list.
  String? _matchToKnownCity(String raw) {
    final lower = raw.toLowerCase().trim();
    if (lower.isEmpty) return null;

    // Delhi region special case
    if (['delhi', 'new delhi', 'gurugram', 'gurgaon', 'noida', 'faridabad', 'ghaziabad']
        .any((k) => lower.contains(k))) {
      return 'Delhi NCR';
    }

    // Exact match (case-insensitive)
    for (final city in _allCities) {
      if (city.toLowerCase() == lower) return city;
    }

    // Substring match
    for (final city in _allCities) {
      if (lower.contains(city.toLowerCase()) || city.toLowerCase().contains(lower)) {
        return city;
      }
    }

    return null;
  }

  /// Bold, visually-distinct section title with a gold accent bar and a
  /// divider beneath it, so titles stand apart from the content below.
  Widget _sectionHeader(String title) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            // Gold accent bar — ties the header to the city-icon accent colour.
            Container(
              width: 4,
              height: 20,
              decoration: BoxDecoration(
                color: const Color(0xFFE0A000),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(width: 10),
            Text(
              title,
              style: GoogleFonts.poppins(
                fontSize: Responsive.sp(context, 18),
                fontWeight: FontWeight.w700,
                color: const Color(0xFF1A1A2E),
                letterSpacing: 0.2,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Divider(color: Colors.grey.shade300, thickness: 1, height: 1),
      ],
    );
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
            fontSize: Responsive.sp(context, 18),
            fontWeight: FontWeight.w500,
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
                    fontSize: Responsive.sp(context, 14),
                    color: Colors.grey.shade500,
                  ),
                  prefixIcon: Icon(Icons.search, color: Colors.grey.shade600),
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(vertical: 15),
                ),
                style: GoogleFonts.poppins(fontSize: Responsive.sp(context, 14)),
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
                onPressed: _isLoadingLocation ? null : _fetchCurrentLocation,
                icon: _isLoadingLocation
                    ? const AppLoaderInline(dotSize: 6, spacing: 3, color: Color(0xFF1A1A2E))
                    : const Icon(Icons.my_location, color: Color(0xFF1A1A2E), size: 20),
                label: Text(
                  _isLoadingLocation ? 'Fetching location...' : 'Use current location',
                  style: GoogleFonts.poppins(
                    fontSize: Responsive.sp(context, 14),
                    fontWeight: FontWeight.w500,
                    color: const Color(0xFF1A1A2E),
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryLight,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 32),

            // Popular Cities Header
            _sectionHeader('Popular Cities'),
            const SizedBox(height: 16),

            // Popular Cities Grid
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                mainAxisSpacing: 12,
                crossAxisSpacing: 12,
                childAspectRatio: 0.78,
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
                            color: const Color(0xFFE0A000),
                            height: 58,
                          )
                        else
                          Icon(
                            city['icon'] as IconData,
                            color: const Color(0xFFE0A000),
                            size: 58,
                          ),
                        const SizedBox(height: 14),
                        Text(
                          city['name'] as String,
                          style: GoogleFonts.poppins(
                            fontSize: Responsive.sp(context, 13),
                            fontWeight: FontWeight.w500,
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
            _sectionHeader('All Cities'),
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
                        fontSize: Responsive.sp(context, 14),
                        fontWeight: FontWeight.w500,
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
