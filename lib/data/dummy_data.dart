import 'package:flutter/material.dart';
import '../models/event_model.dart';
import '../models/category_model.dart';

class DummyData {
  DummyData._();

  // New Categories Array mapped to 3D icons
  static const List<Map<String, dynamic>> homeCategories = [
    {
      'label': 'Events',
      'image': 'assets/images/new_home/eventcategory1.png',
    },
    {
      'label': 'Classes',
      'image': 'assets/images/new_home/eventcategory2.png',
    },
    {
      'label': 'Program',
      'image': 'assets/images/new_home/eventcategory3.png',
    },
    {
      'label': 'Venues',
      'image': 'assets/images/new_home/eventcategory4.png',
      'isWide': true, // Indicator for the 2-item bottom row
    },
    {
      'label': 'Shop',
      'image': 'assets/images/new_home/eventcategory5.png',
      'isWide': true,
    },
  ];

  // Original categories kept for compatibility elsewhere
  static const List<CategoryModel> popularCategories = [
    CategoryModel(
      name: 'Creative\nArts',
      icon: Icons.brush,
      gradientColors: [Color(0xFFFFA726), Color(0xFFFF7043)],
    ),
    CategoryModel(
      name: 'Play\n& Adventure',
      icon: Icons.park,
      gradientColors: [Color(0xFFF48FB1), Color(0xFFE91E63)],
    ),
  ];

  static const List<EventModel> bannerEvents = [
    EventModel(
      title: 'Little Chefs',
      venue: 'Easy & fun recipes for tiny hands!',
      imagePath: 'assets/images/new_home/spotlight_banner.jpeg',
    ),
  ];

  static const List<EventModel> hotPicks = [
    EventModel(
      title: 'Weekend science Fun Workshop',
      venue: 'Little Innovation Lab',
      imagePath: 'assets/images/new_home/hotpics1.jpg',
      rating: 5.0,
      reviewCount: '3.5k reviews',
      price: 5000.0,
      tag: 'Filling Fast',
    ),
    EventModel(
      title: 'Family Creativity Day',
      venue: 'Art Center',
      imagePath: 'assets/images/new_home/hotpic2.png',
      rating: 4.8,
      reviewCount: '2.1k reviews',
      price: 3000.0,
      tag: 'Best Seller',
    ),
  ];

  static const List<EventModel> weekendSpecial = [
    EventModel(
      title: 'Kids Baking Workshop',
      venue: 'Little Chef Studio',
      imagePath: 'assets/images/new_home/weekendspl1.png',
      rating: 5.0,
      reviewCount: '3.5k reviews',
      tag: 'Sat\nmar 16',
    ),
    EventModel(
      title: 'Outdoor Art Camp',
      venue: 'City Park',
      imagePath: 'assets/images/new_home/weekendspl2.png',
      rating: 4.5,
      reviewCount: '1.2k reviews',
      tag: 'Sun\nmar 17',
    ),
  ];

  static const List<EventModel> discoverNearYou = [
    EventModel(
      title: 'Family Fun Park',
      venue: 'Riverside Avenue',
      imagePath: 'assets/images/new_home/hotpic3.png',
      rating: 5.0,
      reviewCount: '3.5k reviews',
      description: 'Slides, Splash Zone, Mini zipline & shaded picnic areas.',
      tag: '0.8 km away',
    ),
    EventModel(
      title: 'Creative Corner',
      venue: 'Downtown Mall',
      imagePath: 'assets/images/new_home/hotpic4.png',
      rating: 4.8,
      reviewCount: '2.5k reviews',
      description: 'Arts and crafts activities for all ages.',
      tag: '1.2 km away',
    ),
  ];

  static const List<EventModel> familyFeels = [
    EventModel(
      title: 'Parent & Kids Yoga Session',
      venue: 'Calm Space Studio',
      imagePath: 'assets/images/new_home/weekendspl3.png',
      rating: 5.0,
      reviewCount: '3.5k reviews',
      price: 200.0,
    ),
  ];

  // Fallbacks to keep app building if other files ref these
  static const List<EventModel> spotlightEvents = bannerEvents;
  static const List<EventModel> bestForWeek = hotPicks;
  static const List<EventModel> nearYouEvents = discoverNearYou;
  static const List<EventModel> trendingNow = weekendSpecial;
  static const List<EventModel> kidsFavorites = weekendSpecial;
  static const List<EventModel> featuredEvents = hotPicks;
}
