import 'package:flutter/material.dart';
import '../core/responsive.dart';
import '../widgets/section_header.dart';
import '../widgets/event_card_with_price.dart';
import '../data/dummy_data.dart';

class KidsFavoritesSection extends StatelessWidget {
  const KidsFavoritesSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SectionHeader(
          title: "Kids' Favorites",
          subtitle: "Book what's favourite among kids",
          onSeeAll: () {},
        ),
        const SizedBox(height: 14),
        SizedBox(
          height: Responsive.h(context, 355, min: 300),
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            addAutomaticKeepAlives: false,
            itemCount: DummyData.kidsFavorites.length,
            separatorBuilder: (_, __) => const SizedBox(width: 14),
            itemBuilder: (context, index) {
              return EventCardWithPrice(
                event: DummyData.kidsFavorites[index],
                width: Responsive.cardWidth(context, fraction: 0.76, max: 300),
              );
            },
          ),
        ),
      ],
    );
  }
}
