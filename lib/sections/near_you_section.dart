import 'package:flutter/material.dart';
import '../core/responsive.dart';
import '../widgets/section_header.dart';
import '../widgets/banner_carousel.dart';
import '../data/dummy_data.dart';

class NearYouSection extends StatelessWidget {
  const NearYouSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SectionHeader(
          title: 'Near You',
          subtitle: 'Events near you',
          onSeeAll: () {},
        ),
        const SizedBox(height: 14),
        BannerCarousel(
          events: DummyData.nearYouEvents,
          height: Responsive.h(context, 200, min: 160),
        ),
      ],
    );
  }
}
