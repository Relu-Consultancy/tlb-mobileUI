import 'package:flutter/material.dart';
import '../widgets/section_divider_widget.dart';
import '../widgets/vertical_card_widget.dart';
import '../data/dummy_data.dart';

class WeekendSpecialSection extends StatelessWidget {
  const WeekendSpecialSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SectionDividerWidget(title: 'Weekend Special'),
        SizedBox(
          height: 380,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.only(left: 16),
            itemCount: DummyData.weekendSpecial.length,
            addAutomaticKeepAlives: false,
            itemBuilder: (context, index) {
              final event = DummyData.weekendSpecial[index];
              return RepaintBoundary(
                child: VerticalCardWidget(
                  imagePath: event.imagePath,
                  title: event.title,
                  subtitle: '5-12 Yrs', // Dummy age range
                  reviewCount: event.reviewCount ?? '0 reviews',
                  location: event.venue,
                  buttonText: 'View Details',
                  badgeText: event.tag, // Returns "Sat\nmar 16"
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
