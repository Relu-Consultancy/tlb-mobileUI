import '../core/responsive.dart';
import 'package:flutter/material.dart';
import '../widgets/section_divider_widget.dart';
import '../widgets/horizontal_card_widget.dart';
import '../data/dummy_data.dart';
import '../screens/event_detail_screen.dart';

class FamilyFeelsSection extends StatelessWidget {
  const FamilyFeelsSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SectionDividerWidget(title: 'Family Feels'),
        SizedBox(
          height: Responsive.h(context, 380, min: 320),
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.only(left: 16),
            itemCount: DummyData.familyFeels.length,
            addAutomaticKeepAlives: false,
            itemBuilder: (context, index) {
              final event = DummyData.familyFeels[index];
              return RepaintBoundary(
                child: HorizontalCardWidget(
                  imagePath: event.imagePath,
                  distance: event.tag ?? 'Starting from ₹${event.price?.toInt() ?? 200}', // Specific to Figma design
                  title: event.title,
                  location: event.venue,
                  reviewCount: event.reviewCount ?? '0 reviews',
                  description: event.description ?? 'A wonderful bonding session',
                  buttonText: 'Book Now',
                  event: event,
                  onTapBtn: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => EventDetailScreen(event: event),
                      ),
                    );
                  },
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
