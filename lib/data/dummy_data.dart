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
      'label': 'Spaces',
      'image': 'assets/images/new_home/eventcategory4.png',
      'isWide': true, // Indicator for the 2-item bottom row
    },
    {
      'label': 'Shop',
      'image': 'assets/images/new_home/eventcategory5.png',
      'isWide': true,
    },
  ];

  static const List<Map<String, dynamic>> exploreCategories = [
    {
      'label': 'Arts & Crafts',
      'image': 'assets/images/new_home/eventcategory1.png',
      'gradient': [Color(0xFFE8E0FF), Color(0xFFD4BFFF)],
    },
    {
      'label': 'Performing Arts',
      'image': 'assets/images/new_home/eventcategory2.png',
      'gradient': [Color(0xFFFFE0E0), Color(0xFFFFB3B3)],
    },
    {
      'label': 'STEM &\nInnovation',
      'image': 'assets/images/new_home/eventcategory3.png',
      'gradient': [Color(0xFFFFF0D4), Color(0xFFFFDB99)],
    },
    {
      'label': 'Sports &\nFitness',
      'image': 'assets/images/new_home/eventcategory4.png',
      'gradient': [Color(0xFFFFF8D4), Color(0xFFFFEDA1)],
    },
    {
      'label': 'Languages &\nCommunication',
      'image': 'assets/images/new_home/eventcategory5.png',
      'gradient': [Color(0xFFFFE8E0), Color(0xFFFFC2AD)],
    },
    {
      'label': 'Life Skills',
      'image': 'assets/images/new_home/eventcategory1.png',
      'gradient': [Color(0xFFE0F0FF), Color(0xFFADD4FF)],
    },
  ];

  static const List<Map<String, dynamic>> exploreFormats = [
    {
      'label': 'WORKSHOP',
      'color': Color(0xFF1E1E1E), // Dark background
    },
    {
      'label': 'CAMP',
      'color': Color(0xFF00A2FF), // Blue background
    },
    {
      'label': 'COMPETITION',
      'color': Color(0xFFFFB900), // Yellow background
    },
    {
      'label': 'MASTERCLASS',
      'color': Color(0xFF1E1E1E), // Dark background
    },
  ];

  static const List<Map<String, dynamic>> classesCategories = [
    {
      'label': 'Academic',
      'image': 'assets/images/new_home/eventcategory1.png',
      'gradient': [Color(0xFFF3F4F6), Color(0xFFE5E7EB)],
    },
    {
      'label': 'Creative Arts',
      'image': 'assets/images/new_home/eventcategory2.png',
      'gradient': [Color(0xFFFFF0F0), Color(0xFFFFDBDB)],
    },
    {
      'label': 'Tech & Innovation',
      'image': 'assets/images/new_home/eventcategory3.png',
      'gradient': [Color(0xFFFFF7ED), Color(0xFFFFEDD5)],
    },
    {
      'label': 'Performing Arts',
      'image': 'assets/images/new_home/eventcategory4.png',
      'gradient': [Color(0xFFFCE7F3), Color(0xFFFBCFE8)],
    },
    {
      'label': 'Sports & Fitness',
      'image': 'assets/images/new_home/eventcategory5.png',
      'gradient': [Color(0xFFFEF9C3), Color(0xFFFEF08A)],
    },
    {
      'label': 'Speech &\nCommunication',
      'image': 'assets/images/new_home/eventcategory1.png',
      'gradient': [Color(0xFFFFE4E6), Color(0xFFFECDD3)],
    },
  ];

  static const List<Map<String, dynamic>> pickYourPace = [
    {
      'label': 'Weekly\nClasses',
      'image': 'assets/images/new_home/eventcategory5.png',
    },
    {
      'label': 'Monthly\nPrograms',
      'image': 'assets/images/new_home/eventcategory2.png',
    },
    {
      'label': 'Term Courses',
      'image': 'assets/images/new_home/eventcategory3.png',
    },
    {
      'label': 'Bootcamps',
      'image': 'assets/images/new_home/eventcategory4.png',
    },
  ];

  static const List<Map<String, dynamic>> programsCategories = [
    {
      'label': 'Future Tech & AI',
      'image': 'assets/images/new_home/eventcategory1.png',
      'gradient': [Color(0xFFDCFCE7), Color(0xFFBBF7D0)],
    },
    {
      'label': 'Design &\nInnovation',
      'image': 'assets/images/new_home/eventcategory2.png',
      'gradient': [Color(0xFFFEF9C3), Color(0xFFFEF08A)],
    },
    {
      'label': 'Leadership &\nEntrepreneurship',
      'image': 'assets/images/new_home/eventcategory3.png',
      'gradient': [Color(0xFFDBEAFE), Color(0xFFBFDBFE)],
    },
    {
      'label': 'Media & Content\nCreation',
      'image': 'assets/images/new_home/eventcategory4.png',
      'gradient': [Color(0xFFF3F4F6), Color(0xFFE5E7EB)],
    },
    {
      'label': 'Stage Arts &\nPerformance',
      'image': 'assets/images/new_home/eventcategory5.png',
      'gradient': [Color(0xFFECFDF5), Color(0xFFD1FAE5)],
    },
    {
      'label': 'Active Sports\n& Training',
      'image': 'assets/images/new_home/eventcategory1.png',
      'gradient': [Color(0xFFFEE2E2), Color(0xFFFECACA)],
    },
  ];

  static const List<Map<String, dynamic>> findYourFit = [
    {
      'label': 'Batch\nProgram',
      'image': 'assets/images/new_home/eventcategory2.png',
    },
    {
      'label': 'Camp\nProgram',
      'image': 'assets/images/new_home/eventcategory3.png',
    },
    {
      'label': 'Holiday-\nbased',
      'image': 'assets/images/new_home/eventcategory4.png',
    },
    {
      'label': 'Flexible\nPace',
      'image': 'assets/images/new_home/eventcategory5.png',
    },
  ];

  static const List<Map<String, dynamic>> allCategories = [
    {
      'label': 'Arts & Crafts',
      'image': 'assets/images/new_home/eventcategory1.png',
      'gradient': [Color(0xFFF3F4F6), Color(0xFFE5E7EB)],
    },
    {
      'label': 'Performing Arts',
      'image': 'assets/images/new_home/eventcategory2.png',
      'gradient': [Color(0xFFFFF0F0), Color(0xFFFFDBDB)],
    },
    {
      'label': 'STEM & Innovation',
      'image': 'assets/images/new_home/eventcategory3.png',
      'gradient': [Color(0xFFFFF7ED), Color(0xFFFFEDD5)],
    },
    {
      'label': 'Sports & Fitness',
      'image': 'assets/images/new_home/eventcategory4.png',
      'gradient': [Color(0xFFFCE7F3), Color(0xFFFBCFE8)],
    },
    {
      'label': 'Languages & Communication',
      'image': 'assets/images/new_home/eventcategory5.png',
      'gradient': [Color(0xFFFEF9C3), Color(0xFFFEF08A)],
    },
    {
      'label': 'Life Skills',
      'image': 'assets/images/new_home/eventcategory1.png',
      'gradient': [Color(0xFFFFE4E6), Color(0xFFFECDD3)],
    },
    {
      'label': 'Mind & Strategy Games',
      'image': 'assets/images/new_home/eventcategory2.png',
      'gradient': [Color(0xFFF3F4F6), Color(0xFFE5E7EB)],
    },
    {
      'label': 'Edutainment & Experiences',
      'image': 'assets/images/new_home/eventcategory3.png',
      'gradient': [Color(0xFFFFF7ED), Color(0xFFFFEDD5)],
    },
    {
      'label': 'Nature & Outdoors',
      'image': 'assets/images/new_home/eventcategory4.png',
      'gradient': [Color(0xFFFCE7F3), Color(0xFFFBCFE8)],
    },
    {
      'label': 'Festivals & Celebrations',
      'image': 'assets/images/new_home/eventcategory5.png',
      'gradient': [Color(0xFFFFE4E6), Color(0xFFFECDD3)],
    },
  ];

  // Original categories kept for compatibility elsewhere
  static const List<CategoryModel> popularCategories = [
    CategoryModel(
      name: 'Creative\nArts',
      icon: Icons.brush,
      gradientColors: [Color(0xFFFFA726), Color(0xFFFF7043)],
      imagePath: 'assets/images/new_home/eventcategory1.png',
    ),
    CategoryModel(
      name: 'Play\n& Adventure',
      icon: Icons.park,
      gradientColors: [Color(0xFFF48FB1), Color(0xFFE91E63)],
      imagePath: 'assets/images/new_home/eventcategory5.png', // Using fallback asset
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
      eventDate: 'Sat, 22 Mar 2026',
      eventTime: '10:00 AM',
    ),
    EventModel(
      title: 'Family Creativity Day',
      venue: 'Art Center',
      imagePath: 'assets/images/new_home/hotpic2.png',
      rating: 4.8,
      reviewCount: '2.1k reviews',
      price: 3000.0,
      tag: 'Best Seller',
      eventDate: 'Sun, 23 Mar 2026',
      eventTime: '02:00 PM',
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
      eventDate: 'Sat, 16 Mar 2026',
      eventTime: '11:00 AM',
    ),
    EventModel(
      title: 'Outdoor Art Camp',
      venue: 'City Park',
      imagePath: 'assets/images/new_home/weekendspl2.png',
      rating: 4.5,
      reviewCount: '1.2k reviews',
      tag: 'Sun\nmar 17',
      eventDate: 'Sun, 17 Mar 2026',
      eventTime: '09:00 AM',
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
      eventDate: 'Sat, 22 Mar 2026',
      eventTime: '10:00 AM',
    ),
    EventModel(
      title: 'Creative Corner',
      venue: 'Downtown Mall',
      imagePath: 'assets/images/new_home/hotpic4.png',
      rating: 4.8,
      reviewCount: '2.5k reviews',
      description: 'Arts and crafts activities for all ages.',
      tag: '1.2 km away',
      eventDate: 'Sun, 23 Mar 2026',
      eventTime: '11:00 AM',
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
      eventDate: 'Sat, 22 Mar 2026',
      eventTime: '07:00 AM',
    ),
  ];

  static const List<EventModel> tlbSignature = [
    EventModel(
      title: 'TLB Women\'s Day Celebration 2026',
      venue: 'An inter generational celebration honoring mothers, grandmothers, and inspiring women.',
      imagePath: 'assets/images/new_home/tlbsignature3.png',
    ),
    EventModel(
      title: 'Little Chefs Baking Competition',
      venue: 'A fun baking face-off for kids and parents!',
      imagePath: 'assets/images/new_home/tlbsignature2.png',
    ),
  ];

  static const List<EventModel> specialNeeds = [
    EventModel(
      title: 'Sensory Play Activity Kit',
      venue: '',
      imagePath: 'assets/images/new_home/specialneeds1.png',
      rating: 5.0,
      reviewCount: '3.5k reviews',
      price: 200.0,
      tag: 'Therapist Recommended', // We'll hijack 'tag' for the bottom banner
    ),
    EventModel(
      title: 'Therapeutic Art Class',
      venue: '',
      imagePath: 'assets/images/new_home/specialneeds2.png',
      rating: 4.8,
      reviewCount: '1.2k reviews',
      price: 350.0,
      tag: 'Therapist Recommended',
    ),
  ];

  static const List<EventModel> stealers = [
    EventModel(
      title: 'Kids Bluetooth Karaoke Mic',
      venue: '',
      imagePath: 'assets/images/new_home/stealers1.png',
      rating: 5.0,
      reviewCount: '3.5k reviews',
      price: 2000.0,
      tag: '60% OFF', // Hijack tag for pink banner
      description: 'End in 08:05:56', // Hijack description for top yellow pill
    ),
    EventModel(
      title: 'Indoor Play Tent',
      venue: '',
      imagePath: 'assets/images/new_home/stealers2.png',
      rating: 4.5,
      reviewCount: '1.8k reviews',
      price: 2500.0,
      tag: '50% OFF',
      description: 'End in 12:30:00',
    ),
  ];

  static const List<EventModel> featuredPartners = [
    EventModel(
      title: 'The Future Is Now!',
      venue: 'Robotics Academies\nSpecialized robotics training',
      imagePath: 'assets/images/new_home/partner1.jpg',
    ),
    EventModel(
      title: 'Kids Theater',
      venue: 'Creative drama workshops',
      imagePath: 'assets/images/new_home/partner2.jpg',
    ),
  ];

  static const List<EventModel> newOnTlb = [
    EventModel(
      title: 'Slime Making Class',
      venue: 'Calm Space Studio',
      imagePath: 'assets/images/new_home/newontlb1.jpg',
      rating: 5.0,
      reviewCount: '3.5k reviews',
      price: 300.0, // Used as 'Starting from ₹300'
    ),
  ];

  static const List<EventModel> onlineEvents = [
    EventModel(
      title: 'Online Coding Workshop',
      venue: 'Learn basics of programming',
      imagePath: 'assets/images/new_home/onlineevent1.jpg',
      tag: 'Workshop',
      eventDate: 'Sat, 27 Apr',
    ),
    EventModel(
      title: 'Virtual Art Tour',
      venue: 'Explore global art museums online',
      imagePath: 'assets/images/new_home/onlineevent2.jpg',
      tag: 'Tour',
      eventDate: 'Sun, 28 Apr',
    ),
  ];


  /// Extra events used in category events screen (centralized from inline)
  static const List<EventModel> categoryEventsExtra = [
    EventModel(
      title: 'Kids party',
      venue: 'FULL PROGRAM',
      imagePath: 'assets/images/new_home/eventposter1.jpg',
      price: 800,
      tag: '2 Weeks',
      description: 'Age 8-14',
      eventDate: 'Sat, 29 Mar 2026',
      eventTime: '10:00 AM',
    ),
    EventModel(
      title: 'Adventure Camp',
      venue: 'SUMMER SPECIAL',
      imagePath: 'assets/images/new_home/eventposter2.jpg',
      price: 1200,
      tag: '1 Week',
      description: 'Age 10-15',
      eventDate: 'Mon, 31 Mar 2026',
      eventTime: '09:00 AM',
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
