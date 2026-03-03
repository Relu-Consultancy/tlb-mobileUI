import 'package:flutter/material.dart';
import '../widgets/section_divider_widget.dart';
import '../widgets/horizontal_card_widget.dart';
import '../data/dummy_data.dart';
import '../screens/event_detail_screen.dart';

class DiscoverNearYouSection extends StatelessWidget {
  const DiscoverNearYouSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SectionDividerWidget(title: 'Discover Near You'),
        SizedBox(
          height: 380,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.only(left: 16),
            itemCount: DummyData.discoverNearYou.length,
            addAutomaticKeepAlives: false,
            itemBuilder: (context, index) {
              final event = DummyData.discoverNearYou[index];
              return RepaintBoundary(
                child: HorizontalCardWidget(
                  imagePath: event.imagePath,
                  distance: event.tag ?? '0.5 km away',
                  title: event.title,
                  location: event.venue,
                  reviewCount: event.reviewCount ?? '0 reviews',
                  description: event.description ?? '',
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
