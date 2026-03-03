import 'package:flutter/material.dart';
import '../core/app_colors.dart';
import '../core/responsive.dart';
import '../data/dummy_data.dart';
import '../sections/home_header.dart';
import '../widgets/banner_carousel.dart';
import '../widgets/categories_grid.dart';
import '../widgets/section_divider_widget.dart';
import '../sections/hot_picks_section.dart';
import '../sections/weekend_special_section.dart';
import '../sections/tlb_signature_section.dart';
import '../sections/special_needs_section.dart';
import '../sections/stealers_section.dart';
import '../sections/discover_near_you_section.dart';
import '../sections/family_feels_section.dart';
import '../sections/app_footer.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _precacheImages();
  }

  void _precacheImages() {
    for (final event in DummyData.bannerEvents) {
      precacheImage(AssetImage(event.imagePath), context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Column(
        children: [
          // Fixed header at top
          const HomeHeader(),

          // Scrollable feed
          Expanded(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Spotlight section divider
                  const SectionDividerWidget(title: 'Spotlight'),
                  RepaintBoundary(
                    child: BannerCarousel(
                      events: DummyData.bannerEvents, 
                      height: Responsive.h(context, 380, min: 280),
                    ),
                  ),
                  const SizedBox(height: 24),
                  
                  // Categories Grid (3x2 layout)
                  const RepaintBoundary(child: CategoriesGrid()),
                  
                  const SizedBox(height: 8),
                  
                  // Sections
                  const RepaintBoundary(child: HotPicksSection()),
                  const RepaintBoundary(child: WeekendSpecialSection()),
                  const RepaintBoundary(child: DiscoverNearYouSection()),
                  const RepaintBoundary(child: FamilyFeelsSection()),
                  
                  const RepaintBoundary(child: TlbSignatureSection()),
                  const RepaintBoundary(child: SpecialNeedsSection()),
                  const RepaintBoundary(child: StealersSection()),

                  // AppFooter with upward gradient
                  const AppFooter(),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
