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
    },
  ];

  static const List<Map<String, dynamic>> exploreCategories = [
    {
      'label': 'Arts & Crafts',
      'image': 'assets/images/event_subcategories/artcraft.png',
      'gradient': [Color(0xFFE8E0FF), Color(0xFFD4BFFF)],
    },
    {
      'label': 'Performing Arts',
      'image': 'assets/images/event_subcategories/performarts.png',
      'gradient': [Color(0xFFFFE0E0), Color(0xFFFFB3B3)],
    },
    {
      'label': 'STEM &\nInnovation',
      'image': 'assets/images/event_subcategories/stem.png',
      'gradient': [Color(0xFFFFF0D4), Color(0xFFFFDB99)],
    },
    {
      'label': 'Sports &\nFitness',
      'image': 'assets/images/event_subcategories/sports.png',
      'gradient': [Color(0xFFFFF8D4), Color(0xFFFFEDA1)],
    },
    {
      'label': 'Languages &\nCommunication',
      'image': 'assets/images/event_subcategories/lang.png',
      'gradient': [Color(0xFFFFE8E0), Color(0xFFFFC2AD)],
    },
    {
      'label': 'Life Skills',
      'image': 'assets/images/event_subcategories/lifeskills.png',
      'gradient': [Color(0xFFE0F0FF), Color(0xFFADD4FF)],
    },
  ];

  static const List<Map<String, dynamic>> exploreFormats = [
    {
      'label': 'WORKSHOP',
      'image': 'assets/images/explore_formats/Workshops.png',
      'color': Color(0xFF3D2817), // Warm dark brown — matches yellow workshop badge
    },
    {
      'label': 'CAMP',
      'image': 'assets/images/explore_formats/camp.png',
      'color': Color(0xFF38BDF8), // Bright sky blue — matches CAMP's cyan lettering
    },
    {
      'label': 'COMPETITION',
      'image': 'assets/images/explore_formats/competition.png',
      'color': Color(0xFFFFCA28), // Golden yellow — matches warmer gold badge tone
    },
    {
      'label': 'MASTERCLASS',
      'image': 'assets/images/explore_formats/masterclass.png',
      'color': Color(0xFF111111), // Near-black
    },
    {
      'label': 'PERFORMANCE',
      'image': 'assets/images/explore_formats/performance.png',
      'color': Color(0xFFEC407A), // Softer rose — matches pink badge
    },
    {
      'label': 'SHOWCASE',
      'image': 'assets/images/explore_formats/shocase.png',
      'color': Color(0xFF66BB6A), // Softer green
    },
    {
      'label': 'DEMO',
      'image': 'assets/images/explore_formats/demo.png',
      'color': Color(0xFFFF8A3D), // Softer orange
    },
  ];

  static const List<Map<String, dynamic>> classesCategories = [
    {
      'label': 'Academic',
      'image': 'assets/images/class_page/academic.png',
      'gradient': [Color(0xFFF3F4F6), Color(0xFFE5E7EB)],
    },
    {
      'label': 'Creative Arts',
      'image': 'assets/images/class_page/creative.png',
      'gradient': [Color(0xFFFFF0F0), Color(0xFFFFDBDB)],
    },
    {
      'label': 'Tech & Innovation',
      'image': 'assets/images/class_page/tech.png',
      'gradient': [Color(0xFFFFF7ED), Color(0xFFFFEDD5)],
    },
    {
      'label': 'Performing Arts',
      'image': 'assets/images/class_page/performing.png',
      'gradient': [Color(0xFFFCE7F3), Color(0xFFFBCFE8)],
    },
    {
      'label': 'Sports & Fitness',
      'image': 'assets/images/class_page/sports.png',
      'gradient': [Color(0xFFFEF9C3), Color(0xFFFEF08A)],
    },
    {
      'label': 'Speech &\nCommunication',
      'image': 'assets/images/class_page/speech.png',
      'gradient': [Color(0xFFFFE4E6), Color(0xFFFECDD3)],
    },
  ];

  static const List<Map<String, dynamic>> pickYourPace = [
    {
      'label': 'Weekly\nClasses',
      'image': 'assets/images/pick_pace/weeklyclasses.png',
    },
    {
      'label': 'Monthly\nPrograms',
      'image': 'assets/images/pick_pace/monthly.png',
    },
    {
      'label': 'Term Courses',
      'image': 'assets/images/pick_pace/term.png',
    },
    {
      'label': 'Bootcamps',
      'image': 'assets/images/pick_pace/bootcamp.png',
    },
    {
      'label': 'Trial Class',
      'image': 'assets/images/pick_pace/trial.png',
    },
    {
      'label': 'Certification',
      'image': 'assets/images/pick_pace/certification.png',
    },
    {
      'label': 'Holiday\nCamps',
      'image': 'assets/images/pick_pace/holiday.png',
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

  static const List<Map<String, dynamic>> classesSeeAllCategories = [
    {
      'label': 'Academic',
      'image': 'assets/images/class_page/academic.png',
      'gradient': [Color(0xFFF3F4F6), Color(0xFFE5E7EB)],
    },
    {
      'label': 'Creative Arts',
      'image': 'assets/images/class_page/creative.png',
      'gradient': [Color(0xFFFFF0F0), Color(0xFFFFDBDB)],
    },
    {
      'label': 'Tech & Innovation',
      'image': 'assets/images/class_page/tech.png',
      'gradient': [Color(0xFFFFF7ED), Color(0xFFFFEDD5)],
    },
    {
      'label': 'Performing Arts',
      'image': 'assets/images/class_page/performing.png',
      'gradient': [Color(0xFFFCE7F3), Color(0xFFFBCFE8)],
    },
    {
      'label': 'Sports & Fitness',
      'image': 'assets/images/class_page/sports.png',
      'gradient': [Color(0xFFFEF9C3), Color(0xFFFEF08A)],
    },
    {
      'label': 'Speech & Communication',
      'image': 'assets/images/class_page/speech.png',
      'gradient': [Color(0xFFFFE4E6), Color(0xFFFECDD3)],
    },
    {
      'label': 'Life Skills & Personality Development',
      'image': 'assets/images/class_page/lifeskills.png',
      'gradient': [Color(0xFFE0F2FE), Color(0xFFBAE6FD)],
    },
    {
      'label': 'Creative Media',
      'image': 'assets/images/class_page/media.png',
      'gradient': [Color(0xFFFEF3C7), Color(0xFFFDE68A)],
    },
    {
      'label': 'Outdoor and Nature Learning',
      'image': 'assets/images/class_page/outdoor.png',
      'gradient': [Color(0xFFF0FDF4), Color(0xFFDCFCE7)],
    },
    {
      'label': 'Culinary',
      'image': 'assets/images/class_page/culinary.png',
      'gradient': [Color(0xFFFFF7ED), Color(0xFFFFEDD5)],
    },
    {
      'label': 'Brain Boosters',
      'image': 'assets/images/class_page/brainboosters.png',
      'gradient': [Color(0xFFF5F3FF), Color(0xFFEDE9FE)],
    },
  ];

  static const List<Map<String, dynamic>> venuesSeeAllCategories = [
    {
      'label': 'Play & Adventure',
      'image': 'assets/images/new_home/eventcategory1.png',
      'gradient': [Color(0xFFF0FDF4), Color(0xFFDCFCE7)],
    },
    {
      'label': 'Sports & Active',
      'image': 'assets/images/new_home/eventcategory2.png',
      'gradient': [Color(0xFFFEF9C3), Color(0xFFFEF08A)],
    },
    {
      'label': 'Creative & DIY',
      'image': 'assets/images/new_home/eventcategory3.png',
      'gradient': [Color(0xFFE0F2FE), Color(0xFFBAE6FD)],
    },
    {
      'label': 'Party & Celebration',
      'image': 'assets/images/new_home/eventcategory4.png',
      'gradient': [Color(0xFFFCE7F3), Color(0xFFFBCFE8)],
    },
    {
      'label': 'Science & Discovery',
      'image': 'assets/images/new_home/eventcategory5.png',
      'gradient': [Color(0xFFFFF7ED), Color(0xFFFFEDD5)],
    },
    {
      'label': 'Nature & Animals',
      'image': 'assets/images/new_home/eventcategory1.png',
      'gradient': [Color(0xFFECFDF5), Color(0xFFD1FAE5)],
    },
    {
      'label': 'Reading & Study',
      'image': 'assets/images/new_home/eventcategory2.png',
      'gradient': [Color(0xFFF3F4F6), Color(0xFFE5E7EB)],
    },
    {
      'label': 'Dining & Cafes',
      'image': 'assets/images/new_home/eventcategory3.png',
      'gradient': [Color(0xFFF5F3FF), Color(0xFFEDE9FE)],
    },
  ];

  static const List<Map<String, dynamic>> programsSeeAllCategories = [
    {
      'label': 'Future Tech & AI',
      'image': 'assets/images/new_home/eventcategory1.png',
      'gradient': [Color(0xFFDCFCE7), Color(0xFFBBF7D0)],
    },
    {
      'label': 'Design & Innovation',
      'image': 'assets/images/new_home/eventcategory2.png',
      'gradient': [Color(0xFFFEF9C3), Color(0xFFFEF08A)],
    },
    {
      'label': 'Leadership & Entrepreneurship',
      'image': 'assets/images/new_home/eventcategory3.png',
      'gradient': [Color(0xFFDBEAFE), Color(0xFFBFDBFE)],
    },
    {
      'label': 'Media & Content Creation',
      'image': 'assets/images/new_home/eventcategory4.png',
      'gradient': [Color(0xFFF3F4F6), Color(0xFFE5E7EB)],
    },
    {
      'label': 'Stage Arts & Performance',
      'image': 'assets/images/new_home/eventcategory5.png',
      'gradient': [Color(0xFFECFDF5), Color(0xFFD1FAE5)],
    },
    {
      'label': 'Active Sports & Training',
      'image': 'assets/images/new_home/eventcategory1.png',
      'gradient': [Color(0xFFFEE2E2), Color(0xFFFECACA)],
    },
    {
      'label': 'Academics & Competitive Prep',
      'image': 'assets/images/new_home/eventcategory2.png',
      'gradient': [Color(0xFFFFF7ED), Color(0xFFFFEDD5)],
    },
    {
      'label': 'Analytical Thinking',
      'image': 'assets/images/new_home/eventcategory3.png',
      'gradient': [Color(0xFFF0FDF4), Color(0xFFDCFCE7)],
    },
    {
      'label': 'Language & Communication',
      'image': 'assets/images/new_home/eventcategory4.png',
      'gradient': [Color(0xFFE0F2FE), Color(0xFFBAE6FD)],
    },
    {
      'label': 'Culinary & Hospitality',
      'image': 'assets/images/new_home/eventcategory5.png',
      'gradient': [Color(0xFFFFFBEB), Color(0xFFFEF3C7)],
    },
    {
      'label': 'Grooming & Personality Development',
      'image': 'assets/images/new_home/eventcategory1.png',
      'gradient': [Color(0xFFFAF5FF), Color(0xFFF3E8FF)],
    },
  ];

  static const List<Map<String, dynamic>> allCategories = [
    {
      'label': 'Arts & Crafts',
      'image': 'assets/images/event_subcategories/artcraft.png',
      'gradient': [Color(0xFFF3F4F6), Color(0xFFE5E7EB)],
    },
    {
      'label': 'Performing Arts',
      'image': 'assets/images/event_subcategories/performarts.png',
      'gradient': [Color(0xFFFFF0F0), Color(0xFFFFDBDB)],
    },
    {
      'label': 'STEM & Innovation',
      'image': 'assets/images/event_subcategories/stem.png',
      'gradient': [Color(0xFFFFF7ED), Color(0xFFFFEDD5)],
    },
    {
      'label': 'Sports & Fitness',
      'image': 'assets/images/event_subcategories/sports.png',
      'gradient': [Color(0xFFFCE7F3), Color(0xFFFBCFE8)],
    },
    {
      'label': 'Languages & Communication',
      'image': 'assets/images/event_subcategories/lang.png',
      'gradient': [Color(0xFFFEF9C3), Color(0xFFFEF08A)],
    },
    {
      'label': 'Life Skills',
      'image': 'assets/images/event_subcategories/lifeskills.png',
      'gradient': [Color(0xFFFFE4E6), Color(0xFFFECDD3)],
    },
    {
      'label': 'Mind & Strategy Games',
      'image': 'assets/images/event_subcategories/mindstrat.png',
      'gradient': [Color(0xFFF3F4F6), Color(0xFFE5E7EB)],
    },
    {
      'label': 'Edutainment & Experiences',
      'image': 'assets/images/event_subcategories/Educainment.png',
      'gradient': [Color(0xFFFFF7ED), Color(0xFFFFEDD5)],
    },
    {
      'label': 'Nature & Outdoors',
      'image': 'assets/images/event_subcategories/nature.png',
      'gradient': [Color(0xFFFCE7F3), Color(0xFFFBCFE8)],
    },
    {
      'label': 'Festivals & Celebrations',
      'image': 'assets/images/event_subcategories/festivals.png',
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

  static const List<EventModel> classesScreenBanners = [
    EventModel(
      title: 'Find The Perfect Class for your Child',
      venue: '',
      imagePath: 'assets/images/classes.png',
      tag: 'EDUCATION',
      description: 'Explore robotics, dance, music, coding & more – All in one place',
    ),
  ];

  static const List<EventModel> eventsScreenBanners = [
    EventModel(
      title: 'Summer Robotics Camp',
      venue: '',
      imagePath: 'assets/images/eventbanner.png',
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

  static const List<EventModel> holidaySpecials = [
    EventModel(
      title: 'Summer Camps',
      venue: 'Central Park',
      imagePath: 'assets/images/new_home/stealers1.png',
      tag: 'Summer Special',
      eventDate: 'Saturday, 27 Apr',
    ),
    EventModel(
      title: 'Holi Splash',
      venue: 'City Plaza',
      imagePath: 'assets/images/new_home/stealers2.png',
      tag: 'Festival Special',
      eventDate: 'Monday, 25 Mar',
    ),
    EventModel(
      title: 'Diwali Diya Workshop',
      venue: 'Art Center',
      imagePath: 'assets/images/new_home/weekendspl3.png',
      tag: 'Diwali Special',
      eventDate: 'Sunday, 03 Nov',
    ),
  ];

  static const List<EventModel> featuredPartners = [
    EventModel(
      title: 'Robotics Academies',
      venue: 'Specialized robotics training',
      imagePath: 'assets/images/featured_partners/1.png',
    ),
    EventModel(
      title: 'Kids Theater',
      venue: 'Creative drama workshops',
      imagePath: 'assets/images/featured_partners/2.png',
    ),
  ];

  static const List<EventModel> newOnTlb = [
    EventModel(
      title: 'Slime Making Class',
      venue: 'Calm Space Studio',
      imagePath: 'assets/images/new_home/newontlb1.jpg',
      rating: 5.0,
      reviewCount: '3.5k reviews',
      price: 200.0,
    ),
    EventModel(
      title: 'Pottery Basics',
      venue: 'Clay Play Studio',
      imagePath: 'assets/images/new_home/weekendspl2.png',
      rating: 4.8,
      reviewCount: '1.2k reviews',
      price: 350.0,
    ),
    EventModel(
      title: 'Robotics 101',
      venue: 'Techno Park',
      imagePath: 'assets/images/new_home/weekendspl4.png',
      rating: 4.9,
      reviewCount: '2.1k reviews',
      price: 500.0,
    ),
  ];

  static const List<EventModel> onlineEvents = [
    EventModel(
      title: 'Online Coding Workshop',
      venue: 'Learn basics of programming',
      imagePath: 'assets/images/new_home/onlineevent1.jpg',
      tag: 'Workshop',
      description: '8-12 Yrs',
      eventDate: 'Saturday, 27 Apr',
    ),
    EventModel(
      title: 'Virtual Art Tour',
      venue: 'Explore global art museums online',
      imagePath: 'assets/images/new_home/onlineevent2.jpg',
      tag: 'Tour',
      description: '6-14 Yrs',
      eventDate: 'Sunday, 28 Apr',
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

  // Sub-filters per explore category (index matches exploreCategories)
  static const List<List<String>> categorySubFilters = [
    ['All', 'Painting', 'Drawing', 'DIY', 'Pottery', 'Origami'],          // Arts & Crafts
    ['All', 'Dance', 'Music', 'Theater', 'Drama', 'Singing'],              // Performing Arts
    ['All', 'Robotics', 'Coding', 'Science', 'Math', 'Engineering'],       // STEM & Innovation
    ['All', 'Football', 'Cricket', 'Swimming', 'Yoga', 'Gymnastics'],      // Sports & Fitness
    ['All', 'English', 'Hindi', 'French', 'Storytelling', 'Public Speaking'], // Languages
    ['All', 'Cooking', 'Leadership', 'Finance', 'Social Skills', 'Mindfulness'], // Life Skills
  ];

  // Events per explore category (index matches exploreCategories)
  static final List<List<EventModel>> categoryEvents = [
    // 0: Arts & Crafts
    [
      const EventModel(
        title: 'Watercolour Painting Class',
        venue: 'The Art Studio',
        imagePath: 'assets/images/new_home/weekendspl2.png',
        rating: 4.8,
        reviewCount: '1.2k reviews',
        tag: 'Painting',
        description: 'Explore blending, shading and layering techniques.',
        eventDate: 'Sat, 26 Apr 2026',
        price: 600,
      ),
      const EventModel(
        title: 'DIY Craft Workshop',
        venue: 'Little Makers Hub',
        imagePath: 'assets/images/new_home/hotpic2.png',
        rating: 4.9,
        reviewCount: '980 reviews',
        tag: 'DIY',
        description: 'Build, paint and take home your own creation.',
        eventDate: 'Sun, 27 Apr 2026',
        price: 500,
      ),
      const EventModel(
        title: 'Clay Pottery for Kids',
        venue: 'Clay Play Studio',
        imagePath: 'assets/images/new_home/weekendspl1.png',
        rating: 5.0,
        reviewCount: '2.3k reviews',
        tag: 'Pottery',
        description: 'Shape, mould and glaze your own clay bowl.',
        eventDate: 'Sat, 03 May 2026',
        price: 750,
      ),
      const EventModel(
        title: 'Origami Fun Day',
        venue: 'Paper World Studio',
        imagePath: 'assets/images/new_home/hotpic3.png',
        rating: 4.7,
        reviewCount: '640 reviews',
        tag: 'Origami',
        description: 'Fold animals, boats and flowers step by step.',
        eventDate: 'Sun, 04 May 2026',
        price: 400,
      ),
      const EventModel(
        title: 'Charcoal Drawing Masterclass',
        venue: 'The Sketch Room',
        imagePath: 'assets/images/new_home/hotpic4.png',
        rating: 4.6,
        reviewCount: '510 reviews',
        tag: 'Drawing',
        description: 'Learn shading and form with charcoal pencils.',
        eventDate: 'Sat, 10 May 2026',
        price: 550,
      ),
      const EventModel(
        title: 'Mixed Media Art Camp',
        venue: 'Creative Corner',
        imagePath: 'assets/images/new_home/newontlb1.jpg',
        rating: 4.9,
        reviewCount: '1.8k reviews',
        tag: 'DIY',
        description: 'Combine paint, paper and fabric into one artwork.',
        eventDate: 'Sun, 11 May 2026',
        price: 900,
      ),
    ],
    // 1: Performing Arts
    [
      const EventModel(
        title: 'Bollywood Dance Workshop',
        venue: 'Rhythm Academy',
        imagePath: 'assets/images/new_home/weekendspl3.png',
        rating: 5.0,
        reviewCount: '3.1k reviews',
        tag: 'Dance',
        description: 'High energy moves with trending Bollywood hits.',
        eventDate: 'Sat, 26 Apr 2026',
        price: 700,
      ),
      const EventModel(
        title: 'Kids Theater Workshop',
        venue: 'Stage & Story Studio',
        imagePath: 'assets/images/featured_partners/2.png',
        rating: 4.8,
        reviewCount: '1.5k reviews',
        tag: 'Theater',
        description: 'Act, script and perform a mini-play on stage.',
        eventDate: 'Sun, 27 Apr 2026',
        price: 800,
      ),
      const EventModel(
        title: 'Vocal Training for Beginners',
        venue: 'Melodia Music School',
        imagePath: 'assets/images/new_home/hotpics1.jpg',
        rating: 4.7,
        reviewCount: '870 reviews',
        tag: 'Singing',
        description: 'Breathing, pitch and ear-training fundamentals.',
        eventDate: 'Sat, 03 May 2026',
        price: 600,
      ),
      const EventModel(
        title: 'Drama & Expression Class',
        venue: 'The Performance Box',
        imagePath: 'assets/images/new_home/weekendspl4.png',
        rating: 4.9,
        reviewCount: '1.1k reviews',
        tag: 'Drama',
        description: 'Confidence building through storytelling and drama.',
        eventDate: 'Sun, 04 May 2026',
        price: 650,
      ),
    ],
    // 2: STEM & Innovation
    [
      const EventModel(
        title: 'Junior Robotics Camp',
        venue: 'Little Innovation Lab',
        imagePath: 'assets/images/new_home/hotpics1.jpg',
        rating: 5.0,
        reviewCount: '3.5k reviews',
        tag: 'Robotics',
        description: 'Build and program a robot from scratch.',
        eventDate: 'Sat, 26 Apr 2026',
        price: 1200,
      ),
      const EventModel(
        title: 'Scratch Coding Workshop',
        venue: 'CodeKids Hub',
        imagePath: 'assets/images/new_home/onlineevent1.jpg',
        rating: 4.8,
        reviewCount: '2.2k reviews',
        tag: 'Coding',
        description: 'Create interactive animations and games using Scratch.',
        eventDate: 'Sun, 27 Apr 2026',
        price: 800,
      ),
      const EventModel(
        title: 'Science Experiment Day',
        venue: 'Curiosity Lab',
        imagePath: 'assets/images/new_home/hotpic2.png',
        rating: 4.9,
        reviewCount: '1.6k reviews',
        tag: 'Science',
        description: 'Volcanoes, slime and chemical reactions — safe and fun!',
        eventDate: 'Sat, 03 May 2026',
        price: 700,
      ),
      const EventModel(
        title: 'Math Magic Workshop',
        venue: 'Think Tank Studio',
        imagePath: 'assets/images/new_home/hotpic4.png',
        rating: 4.6,
        reviewCount: '740 reviews',
        tag: 'Math',
        description: 'Puzzles, patterns and mental math tricks.',
        eventDate: 'Sun, 04 May 2026',
        price: 500,
      ),
    ],
    // 3: Sports & Fitness
    [
      const EventModel(
        title: 'Junior Football League',
        venue: 'Sports Arena',
        imagePath: 'assets/images/new_home/weekendspl1.png',
        rating: 4.9,
        reviewCount: '2.8k reviews',
        tag: 'Football',
        description: 'Weekend 5-a-side matches for 8-14 year olds.',
        eventDate: 'Sat, 26 Apr 2026',
        price: 600,
      ),
      const EventModel(
        title: 'Kids Yoga & Mindfulness',
        venue: 'Calm Space Studio',
        imagePath: 'assets/images/new_home/weekendspl3.png',
        rating: 5.0,
        reviewCount: '1.9k reviews',
        tag: 'Yoga',
        description: 'Stretches, breathing and relaxation for little ones.',
        eventDate: 'Sun, 27 Apr 2026',
        price: 400,
      ),
      const EventModel(
        title: 'Swimming Crash Course',
        venue: 'Aqua Kids Pool',
        imagePath: 'assets/images/new_home/hotpic3.png',
        rating: 4.8,
        reviewCount: '1.3k reviews',
        tag: 'Swimming',
        description: 'Water safety, floating and basic strokes covered.',
        eventDate: 'Sat, 03 May 2026',
        price: 900,
      ),
      const EventModel(
        title: 'Gymnastics for Beginners',
        venue: 'FlipStar Gym',
        imagePath: 'assets/images/new_home/weekendspl4.png',
        rating: 4.7,
        reviewCount: '860 reviews',
        tag: 'Gymnastics',
        description: 'Rolls, cartwheels and balance beam fundamentals.',
        eventDate: 'Sun, 04 May 2026',
        price: 750,
      ),
    ],
    // 4: Languages & Communication
    [
      const EventModel(
        title: 'Storytelling Workshop',
        venue: 'The Word House',
        imagePath: 'assets/images/story_telling.png',
        rating: 4.9,
        reviewCount: '1.4k reviews',
        tag: 'Storytelling',
        description: 'Craft and narrate your own original story.',
        eventDate: 'Sat, 26 Apr 2026',
        price: 500,
      ),
      const EventModel(
        title: 'English Speaking Club',
        venue: 'Fluency Academy',
        imagePath: 'assets/images/new_home/onlineevent2.jpg',
        rating: 4.8,
        reviewCount: '1.1k reviews',
        tag: 'English',
        description: 'Debates, elocution and group discussion sessions.',
        eventDate: 'Sun, 27 Apr 2026',
        price: 600,
      ),
      const EventModel(
        title: 'Public Speaking Bootcamp',
        venue: 'The Confidence Stage',
        imagePath: 'assets/images/new_home/hotpic2.png',
        rating: 5.0,
        reviewCount: '2.0k reviews',
        tag: 'Public Speaking',
        description: 'Overcome stage fright and speak with confidence.',
        eventDate: 'Sat, 03 May 2026',
        price: 700,
      ),
      const EventModel(
        title: 'French for Kids',
        venue: 'Bonjour Language Studio',
        imagePath: 'assets/images/new_home/hotpic4.png',
        rating: 4.6,
        reviewCount: '530 reviews',
        tag: 'French',
        description: 'Songs, games and basic conversations in French.',
        eventDate: 'Sun, 04 May 2026',
        price: 550,
      ),
    ],
    // 5: Life Skills
    [
      const EventModel(
        title: 'Little Chefs Cooking Class',
        venue: 'Little Chef Studio',
        imagePath: 'assets/images/new_home/weekendspl1.png',
        rating: 5.0,
        reviewCount: '3.2k reviews',
        tag: 'Cooking',
        description: 'Easy, fun recipes kids can make at home too.',
        eventDate: 'Sat, 26 Apr 2026',
        price: 700,
      ),
      const EventModel(
        title: 'Junior Leadership Camp',
        venue: 'Leader\'s Den',
        imagePath: 'assets/images/new_home/hotpics1.jpg',
        rating: 4.9,
        reviewCount: '1.7k reviews',
        tag: 'Leadership',
        description: 'Teamwork, problem-solving and decision-making.',
        eventDate: 'Sun, 27 Apr 2026',
        price: 900,
      ),
      const EventModel(
        title: 'Kids Finance Workshop',
        venue: 'Money Minds Studio',
        imagePath: 'assets/images/new_home/hotpic3.png',
        rating: 4.7,
        reviewCount: '680 reviews',
        tag: 'Finance',
        description: 'Savings, budgeting and the value of money — simplified.',
        eventDate: 'Sat, 03 May 2026',
        price: 500,
      ),
      const EventModel(
        title: 'Mindfulness for Kids',
        venue: 'Calm Space Studio',
        imagePath: 'assets/images/new_home/weekendspl3.png',
        rating: 4.8,
        reviewCount: '920 reviews',
        tag: 'Mindfulness',
        description: 'Breathing exercises, journaling and focus games.',
        eventDate: 'Sun, 04 May 2026',
        price: 400,
      ),
    ],
  ];

  // ── Classes Screen Section Data ───────────────────────────────────────────

  static const List<EventModel> classesWhatEveryoneJoining = [
    EventModel(
      title: 'Future Tech Lab',
      venue: 'Learning Center',
      imagePath: 'assets/images/new_home/hotpics1.jpg',
      rating: 3.5,
      reviewCount: '8-12 Yrs',
      tag: 'Trending #1',
      eventDate: 'Sat, 12 Aug',
    ),
    EventModel(
      title: 'Kids Pottery Class',
      venue: 'Kidsworld Studio',
      imagePath: 'assets/images/new_home/hotpic2.png',
      rating: 4.8,
      reviewCount: '5-10 Yrs',
      tag: 'Filling Fast',
      eventDate: 'Sat, 15 Aug',
    ),
    EventModel(
      title: 'Creative Writing Workshop',
      venue: 'The Book Nook',
      imagePath: 'assets/images/new_home/hotpic3.png',
      rating: 4.6,
      reviewCount: '7-14 Yrs',
      tag: 'New',
      eventDate: 'Sun, 16 Aug',
    ),
  ];

  static const List<EventModel> classesRightAroundYou = [
    EventModel(
      title: 'Kids Hip-Hop Dance',
      venue: 'Groove Dance Academy',
      imagePath: 'assets/images/new_home/weekendspl1.png',
      rating: 4.5,
      reviewCount: '5-12 Yrs',
      tag: '0.8 km away',
      description: 'Fun and energetic dance classes to improve rhythm, confidence and fitness.',
    ),
    EventModel(
      title: 'Beginner Guitar Class',
      venue: 'Melody Music Studio',
      imagePath: 'assets/images/new_home/weekendspl2.png',
      rating: 4.7,
      reviewCount: '8-16 Yrs',
      tag: '1.2 km away',
      description: 'Learn guitar basics from scratch with fun songs and easy lessons.',
    ),
    EventModel(
      title: 'Swimming for Kids',
      venue: 'Aqua Sports Center',
      imagePath: 'assets/images/new_home/weekendspl3.png',
      rating: 4.9,
      reviewCount: '4-12 Yrs',
      tag: '2.1 km away',
      description: 'Professional coaching in a safe, fun, and encouraging environment.',
    ),
  ];

  static const List<EventModel> classesTopPicks = [
    EventModel(
      title: 'Piano & Keyboard Classes',
      venue: 'Harmony Studio',
      imagePath: 'assets/images/new_home/specialneeds1.png',
      eventDate: 'Saturday, 27 Apr',
      eventTime: '10:00 AM',
    ),
    EventModel(
      title: 'Watercolor Painting',
      venue: 'Creative Canvas Studio',
      imagePath: 'assets/images/new_home/specialneeds2.png',
      eventDate: 'Sunday, 28 Apr',
      eventTime: '11:00 AM',
    ),
    EventModel(
      title: 'Robotics for Beginners',
      venue: 'TechMinds Lab',
      imagePath: 'assets/images/new_home/hotpic4.png',
      eventDate: 'Monday, 29 Apr',
      eventTime: '03:00 PM',
    ),
  ];

  static const List<EventModel> classesHolidaySpecial = [
    EventModel(
      title: 'Summer Robotics Camps',
      venue: 'Future Tech Lab',
      imagePath: 'assets/images/new_home/hotpics1.jpg',
      tag: 'Summer Special',
      eventDate: '5 Days Camp',
    ),
    EventModel(
      title: 'Creative Arts Summer Camp',
      venue: 'Art Horizon Studio',
      imagePath: 'assets/images/new_home/hotpic2.png',
      tag: 'Summer Camp',
      eventDate: '7 Days Program',
    ),
    EventModel(
      title: 'Sports & Fitness Camp',
      venue: 'Champions Arena',
      imagePath: 'assets/images/new_home/weekendspl4.png',
      tag: 'Holiday Special',
      eventDate: '3 Days Camp',
    ),
  ];

  static const List<EventModel> classesBuildNewSkills = [
    EventModel(
      title: 'Coding & Game Creation',
      venue: 'Learn Tech Hub',
      imagePath: 'assets/images/new_home/hotpic3.png',
      rating: 3.5,
      reviewCount: '3.5k reviews',
      tag: 'Digital Skill',
    ),
    EventModel(
      title: 'Storytelling & Drama',
      venue: 'Stage Craft Studio',
      imagePath: 'assets/images/new_home/weekendspl2.png',
      rating: 4.6,
      reviewCount: '2.1k reviews',
      tag: 'Creative Skill',
    ),
    EventModel(
      title: 'Chess & Strategy',
      venue: 'Mind Masters Club',
      imagePath: 'assets/images/new_home/hotpic4.png',
      rating: 4.8,
      reviewCount: '1.8k reviews',
      tag: 'Mind Skill',
    ),
  ];

  static const List<EventModel> classesSpecialFocus = [
    EventModel(
      title: 'Sensory Play for Toddlers',
      venue: 'Little Minds Studio',
      imagePath: 'assets/images/new_home/specialneeds1.png',
      rating: 5.0,
      reviewCount: '2-5 Yrs',
      tag: 'Therapist Led',
      description: 'Safe, guided sensory activities for early childhood development.',
    ),
    EventModel(
      title: 'Inclusive Art Workshop',
      venue: 'Open Canvas Center',
      imagePath: 'assets/images/new_home/specialneeds2.png',
      rating: 4.9,
      reviewCount: '4-14 Yrs',
      tag: 'Special Needs',
      description: 'Art therapy sessions designed for children with special learning needs.',
    ),
    EventModel(
      title: 'Focus & Mindfulness Class',
      venue: 'Calm Minds Academy',
      imagePath: 'assets/images/new_home/weekendspl3.png',
      rating: 4.7,
      reviewCount: '5-12 Yrs',
      tag: 'Neuro Inclusive',
      description: 'Breathing, movement and mindfulness techniques for better focus.',
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
