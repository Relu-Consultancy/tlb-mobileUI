import 'package:flutter/material.dart';
import '../core/app_colors.dart';
import 'package:google_fonts/google_fonts.dart';
import '../core/responsive.dart';
import '../core/listing_image.dart';
import '../models/event_model.dart';

class GalleryScreen extends StatefulWidget {
  final EventModel event;

  /// The listing's real media, as the detail screen's gallery row shows it.
  ///
  /// Required in practice: without it this screen used to invent its own list
  /// of bundled demo art, so "See All" opened a different set of pictures from
  /// the strip that was just tapped.
  final List<String> images;

  const GalleryScreen({
    super.key,
    required this.event,
    this.images = const [],
  });

  @override
  State<GalleryScreen> createState() => _GalleryScreenState();
}

class _GalleryScreenState extends State<GalleryScreen> {
  late final PageController _pageController;
  int _currentPage = 0;

  /// The listing's media. Empty entries are dropped — a listing with no
  /// cover would otherwise contribute a blank page.
  late final List<String> _images;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
    final supplied =
        widget.images.where((i) => i.trim().isNotEmpty).toList();
    _images = supplied.isNotEmpty
        ? supplied
        // Falls back to the cover alone, never to unrelated demo art.
        : [
            if (widget.event.imagePath.trim().isNotEmpty)
              widget.event.imagePath,
          ];
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _goToPage(int index) {
    _pageController.animateToPage(
      index,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.textPrimary),
          onPressed: () => Navigator.pop(context),
        ),
        centerTitle: true,
        title: Text(
          'Gallery',
          style: GoogleFonts.poppins(
            fontSize: Responsive.sp(context, 17),
            fontWeight: FontWeight.w500,
            color: AppColors.textPrimary,
          ),
        ),
      ),
      body: SafeArea(
        child: _images.isEmpty
            ? Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.image_outlined,
                        size: 48, color: Colors.grey.shade400),
                    const SizedBox(height: 12),
                    Text(
                      'No photos yet',
                      style: GoogleFonts.poppins(
                        fontSize: Responsive.sp(context, 14),
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),
              )
            : Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Subtitle
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 4, 16, 16),
            child: Text(
              '${widget.event.title} fun experience!',
              style: GoogleFonts.poppins(
                fontSize: Responsive.sp(context, 13),
                color: Colors.grey.shade600,
              ),
            ),
          ),

          // Main image viewer
          Expanded(
            child: PageView.builder(
              controller: _pageController,
              itemCount: _images.length,
              onPageChanged: (index) {
                setState(() => _currentPage = index);
              },
              itemBuilder: (context, index) {
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(16),
                    // listingImage, not Image.asset: gallery media are
                    // network URLs, which an asset loader can only fail on.
                    child: listingImage(
                      _images[index],
                      fit: BoxFit.cover,
                      width: double.infinity,
                    ),
                  ),
                );
              },
            ),
          ),

          const SizedBox(height: 16),

          // Page indicator
          Center(
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  '${_currentPage + 1}/${_images.length}',
                  style: GoogleFonts.poppins(
                    fontSize: Responsive.sp(context, 14),
                    fontWeight: FontWeight.w500,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(width: 4),
                const Icon(Icons.chevron_right, size: 18, color: AppColors.textPrimary),
              ],
            ),
          ),

          const SizedBox(height: 12),

          // Thumbnail strip
          SizedBox(
            height: Responsive.h(context, 65, min: 50),
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: _images.length,
              itemBuilder: (context, index) {
                final isActive = index == _currentPage;
                return GestureDetector(
                  onTap: () => _goToPage(index),
                  child: Container(
                    width: Responsive.w(context, 65, min: 50),
                    margin: const EdgeInsets.only(right: 8),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      border: isActive
                          ? Border.all(color: AppColors.primaryLight, width: 2.5)
                          : null,
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(isActive ? 8 : 10),
                      child: listingImage(
                        _images[index],
                        fit: BoxFit.cover,
                        cacheWidth: 180,
                      ),
                    ),
                  ),
                );
              },
            ),
          ),

          const SizedBox(height: 24),
        ],
        ),
      ),
    );
  }
}
