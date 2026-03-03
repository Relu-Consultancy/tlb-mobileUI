import 'package:flutter/material.dart';
import '../core/responsive.dart';
import '../widgets/section_header.dart';
import '../widgets/event_card.dart';
import '../data/dummy_data.dart';

class SpotlightSection extends StatelessWidget {
  const SpotlightSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SectionHeader(
          title: 'Spotlight',
          onSeeAll: () {},
        ),
        const SizedBox(height: 14),
        SizedBox(
          height: Responsive.h(context, 290, min: 240),
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            addAutomaticKeepAlives: false,
            itemCount: DummyData.spotlightEvents.length,
            separatorBuilder: (_, __) => const SizedBox(width: 14),
            itemBuilder: (context, index) {
              return EventCard(
                event: DummyData.spotlightEvents[index],
                width: Responsive.cardWidth(context, fraction: 0.66, max: 260),
                imageHeight: 210,
              );
            },
          ),
        ),
      ],
    );
  }
}
