import 'package:flutter/material.dart';
import '../widgets/section_divider_widget.dart';
import '../widgets/vertical_card_widget.dart';
import '../data/dummy_data.dart';
import '../screens/event_detail_screen.dart';

class HotPicksSection extends StatelessWidget {
  const HotPicksSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SectionDividerWidget(title: 'Hot Picks'),
        SizedBox(
          height: 380,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.only(left: 16),
            itemCount: DummyData.hotPicks.length,
            addAutomaticKeepAlives: false,
            itemBuilder: (context, index) {
              final event = DummyData.hotPicks[index];
              return RepaintBoundary(
                child: VerticalCardWidget(
                  imagePath: event.imagePath,
                  title: event.title,
                  subtitle: '3-5 Yrs', // Dummy age range
                  reviewCount: event.reviewCount ?? '0 reviews',
                  location: event.venue,
                  buttonText: 'Book Now',
                  price: event.price != null ? '₹${event.price!.toInt()}' : null,
                  badgeText: event.tag,
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
