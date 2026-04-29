import 'package:flutter/material.dart';
import '../models/event_model.dart';
import '../models/category_model.dart';

class DummyData {
  DummyData._();

  // New Categories Array mapped to 3D icons
  static const List<Map<String, dynamic>> homeCategories = [
    {
      'label': 'Events',
      'image': 'resources- tlb-ui/homescreen-categoryicons/events.png',
    },
    {
      'label': 'Classes',
      'image': 'resources- tlb-ui/homescreen-categoryicons/classes.png',
    },
    {
      'label': 'Program',
      'image': 'resources- tlb-ui/homescreen-categoryicons/programs.png',
    },
    {
      'label': 'Venues',
      'image': 'resources- tlb-ui/homescreen-categoryicons/venues.png',
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
    {
      'label': 'Life Skills &\nPersonality Dev',
      'image': 'assets/images/class_page/lifeskills.png',
      'gradient': [Color(0xFFE0F2FE), Color(0xFFBAE6FD)],
    },
    {
      'label': 'Creative Media',
      'image': 'assets/images/class_page/media.png',
      'gradient': [Color(0xFFFEF3C7), Color(0xFFFDE68A)],
    },
    {
      'label': 'Outdoor &\nNature Learning',
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
      'image': "resources- tlb-ui/events_page/futuretech'.png",
      'gradient': [Color(0xFFDCFCE7), Color(0xFFBBF7D0)],
    },
    {
      'label': 'Design &\nInnovation',
      'image': 'resources- tlb-ui/events_page/design.png',
      'gradient': [Color(0xFFFEF9C3), Color(0xFFFEF08A)],
    },
    {
      'label': 'Leadership &\nEntrepreneurship',
      'image': 'resources- tlb-ui/events_page/leadership.png',
      'gradient': [Color(0xFFDBEAFE), Color(0xFFBFDBFE)],
    },
    {
      'label': 'Media & Content\nCreation',
      'image': 'resources- tlb-ui/events_page/media.png',
      'gradient': [Color(0xFFF3F4F6), Color(0xFFE5E7EB)],
    },
    {
      'label': 'Stage Arts &\nPerformance',
      'image': 'resources- tlb-ui/events_page/stage.png',
      'gradient': [Color(0xFFECFDF5), Color(0xFFD1FAE5)],
    },
    {
      'label': 'Active Sports\n& Training',
      'image': 'resources- tlb-ui/events_page/activesports.png',
      'gradient': [Color(0xFFFEE2E2), Color(0xFFFECACA)],
    },
    {
      'label': 'Academics &\nCompetitive Prep',
      'image': 'assets/images/class_page/academic.png',
      'gradient': [Color(0xFFFCE7F3), Color(0xFFFBCFE8)],
    },
    {
      'label': 'Analytical\nThinking',
      'image': 'assets/images/class_page/brainboosters.png',
      'gradient': [Color(0xFFFEF9C3), Color(0xFFFDE68A)],
    },
    {
      'label': 'Language &\nCommunication',
      'image': 'assets/images/class_page/speech.png',
      'gradient': [Color(0xFFE0F2FE), Color(0xFFBAE6FD)],
    },
    {
      'label': 'Culinary &\nHospitality',
      'image': 'assets/images/class_page/culinary.png',
      'gradient': [Color(0xFFFFFBEB), Color(0xFFFEF3C7)],
    },
    {
      'label': 'Grooming &\nPersonality Dev',
      'image': 'assets/images/class_page/lifeskills.png',
      'gradient': [Color(0xFFFAF5FF), Color(0xFFF3E8FF)],
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
      'image': 'resources- tlb-ui/venues_page/play.png',
      'gradient': <Color>[Color(0xFFF0FDF4), Color(0xFFDCFCE7)],
    },
    {
      'label': 'Sports & Active',
      'image': 'resources- tlb-ui/venues_page/sports.png',
      'gradient': <Color>[Color(0xFFFEF9C3), Color(0xFFFEF08A)],
    },
    {
      'label': 'Creative & DIY',
      'image': 'resources- tlb-ui/venues_page/creativediy.png',
      'gradient': <Color>[Color(0xFFE0F2FE), Color(0xFFBAE6FD)],
    },
    {
      'label': 'Party & Celebration',
      'image': 'resources- tlb-ui/venues_page/party.png',
      'gradient': <Color>[Color(0xFFFCE7F3), Color(0xFFFBCFE8)],
    },
    {
      'label': 'Science & Discovery',
      'image': 'resources- tlb-ui/venues_page/science.png',
      'gradient': <Color>[Color(0xFFFFF7ED), Color(0xFFFFEDD5)],
    },
    {
      'label': 'Nature & Animals',
      'image': 'resources- tlb-ui/venues_page/nature.png',
      'gradient': <Color>[Color(0xFFECFDF5), Color(0xFFD1FAE5)],
    },
    {
      'label': 'Reading & Study',
      'image': 'assets/images/new_home/eventcategory2.png',
      'gradient': <Color>[Color(0xFFF3F4F6), Color(0xFFE5E7EB)],
    },
    {
      'label': 'Dining & Cafes',
      'image': 'assets/images/new_home/eventcategory3.png',
      'gradient': <Color>[Color(0xFFF5F3FF), Color(0xFFEDE9FE)],
    },
  ];

  static const List<Map<String, dynamic>> programsSeeAllCategories = [
    {
      'label': 'Future Tech & AI',
      'image': "resources- tlb-ui/events_page/futuretech'.png",
      'gradient': [Color(0xFFDCFCE7), Color(0xFFBBF7D0)],
    },
    {
      'label': 'Design & Innovation',
      'image': 'resources- tlb-ui/events_page/design.png',
      'gradient': [Color(0xFFFEF9C3), Color(0xFFFEF08A)],
    },
    {
      'label': 'Leadership & Entrepreneurship',
      'image': 'resources- tlb-ui/events_page/leadership.png',
      'gradient': [Color(0xFFDBEAFE), Color(0xFFBFDBFE)],
    },
    {
      'label': 'Media & Content Creation',
      'image': 'resources- tlb-ui/events_page/media.png',
      'gradient': [Color(0xFFF3F4F6), Color(0xFFE5E7EB)],
    },
    {
      'label': 'Stage Arts & Performance',
      'image': 'resources- tlb-ui/events_page/stage.png',
      'gradient': [Color(0xFFECFDF5), Color(0xFFD1FAE5)],
    },
    {
      'label': 'Active Sports & Training',
      'image': 'resources- tlb-ui/events_page/activesports.png',
      'gradient': [Color(0xFFFEE2E2), Color(0xFFFECACA)],
    },
    {
      'label': 'Academics & Competitive Prep',
      'image': 'assets/images/class_page/academic.png',
      'gradient': [Color(0xFFFCE7F3), Color(0xFFFBCFE8)],
    },
    {
      'label': 'Analytical Thinking',
      'image': 'assets/images/class_page/brainboosters.png',
      'gradient': [Color(0xFFFEF9C3), Color(0xFFFDE68A)],
    },
    {
      'label': 'Language & Communication',
      'image': 'assets/images/class_page/speech.png',
      'gradient': [Color(0xFFE0F2FE), Color(0xFFBAE6FD)],
    },
    {
      'label': 'Culinary & Hospitality',
      'image': 'assets/images/class_page/culinary.png',
      'gradient': [Color(0xFFFFFBEB), Color(0xFFFEF3C7)],
    },
    {
      'label': 'Grooming & Personality Development',
      'image': 'assets/images/class_page/lifeskills.png',
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

  static const List<EventModel> programsScreenBanners = [
    EventModel(
      title: 'AI Bootcamp for Kids',
      venue: '',
      imagePath: 'resources- tlb-ui/program_banner.png',
      tag: 'PROGRAMS',
      description: 'Build smart AI projects in 8 weeks(Online+ Offline, Age: 10 – 15 yrs)',
    ),
  ];

  // ── Venues screen data ──
  static const List<EventModel> venuesScreenBanners = [
    EventModel(
      title: 'Plan Your Perfect Weekend',
      venue: '',
      imagePath: 'resources- tlb-ui/spaces.png',
      description: 'Discover top rated venues near you with expert instructors',
    ),
  ];

  static const List<EventModel> venuesBigDays = [
    EventModel(title: 'Royal Banquet Hall', venue: 'Powai • 5 km', imagePath: 'assets/images/new_home/hotpics1.jpg', rating: 4.8, reviewCount: '3.5k reviews', tag: 'Birthday'),
    EventModel(title: 'Fun Zone Play Park', venue: 'Powai • 6 km', imagePath: 'assets/images/new_home/hotpic2.png', rating: 4.7, reviewCount: '2.1k reviews', tag: 'Kids Party'),
    EventModel(title: 'Grand Events Arena', venue: 'Bandra • 8 km', imagePath: 'assets/images/new_home/hotpic3.png', rating: 4.9, reviewCount: '4.2k reviews', tag: 'Premium'),
  ];

  static const List<EventModel> venuesWeekendPlan = [
    EventModel(title: 'Pottery Workshop', venue: 'Sat & Sun • 2 hrs', imagePath: 'assets/images/new_home/weekendspl2.png', rating: 4.8, reviewCount: '3.5k reviews', tag: 'Weekend Only'),
    EventModel(title: 'Canvas Painting', venue: 'Sat & Sun • 3 hrs', imagePath: 'assets/images/new_home/weekendspl3.png', rating: 4.7, reviewCount: '2.0k reviews', tag: 'Weekend Only'),
    EventModel(title: 'Pottery Workshop', venue: 'Sat & Sun • 2 hrs', imagePath: 'assets/images/new_home/weekendspl4.png', rating: 4.6, reviewCount: '1.8k reviews', tag: 'Weekend Only'),
  ];

  static const List<EventModel> venuesCloseToYou = [
    EventModel(title: 'Play Arena', venue: 'Indoor Play Zone • 3 kms', imagePath: 'assets/images/new_home/hotpic4.png', tag: 'Indoor'),
    EventModel(title: 'Kids Sports Hub', venue: 'Outdoor Sports • 4 kms', imagePath: 'assets/images/new_home/hotpick5.png', tag: 'Outdoor'),
    EventModel(title: 'Creative Studio', venue: 'Art Space • 2 kms', imagePath: 'assets/images/new_home/weekendspl1.png', tag: 'Indoor'),
  ];

  static const List<EventModel> venuesOutAndAbout = [
    EventModel(title: 'City Zoo', venue: 'Byculla', imagePath: 'assets/images/new_home/hotpics1.jpg'),
    EventModel(title: 'Water Park', venue: 'Thane', imagePath: 'assets/images/new_home/hotpic2.png'),
    EventModel(title: 'Lakeside Park', venue: 'Powai', imagePath: 'assets/images/new_home/hotpic3.png'),
  ];

  static const List<Map<String, dynamic>> venuesGetMoving = [
    {
      'sport': 'Football',
      'image': 'assets/images/new_home/hotpics1.jpg',
      'gradient': <Color>[Color(0xFF56CFB2), Color(0xFF2BC0B4)],
      'slotsText': 'Slots Available today',
      'venues': <Map<String, dynamic>>[
        {'name': 'Football Turf Arena', 'location': 'Mira road • 10 Kms', 'image': 'assets/images/new_home/hotpic4.png', 'slots': <String>['6:00 PM', '7:00 PM', '8:00 PM']},
        {'name': 'Football Turf Arena', 'location': 'Vitthalwadi • 10 Kms', 'image': 'assets/images/new_home/hotpick5.png', 'slots': <String>['7:00 PM', '8:00 PM', '9:00 PM']},
      ],
    },
    {
      'sport': 'Climbing',
      'image': 'assets/images/new_home/hotpic2.png',
      'gradient': <Color>[Color(0xFF60A5FA), Color(0xFF3B82F6)],
      'slotsText': 'Slots Available today',
      'venues': <Map<String, dynamic>>[
        {'name': 'Rock Climb Zone', 'location': 'Andheri • 5 Kms', 'image': 'assets/images/new_home/hotpic3.png', 'slots': <String>['10:00 AM', '11:00 AM', '12:00 PM']},
        {'name': 'Boulder House', 'location': 'Bandra • 7 Kms', 'image': 'assets/images/new_home/weekendspl2.png', 'slots': <String>['2:00 PM', '4:00 PM', '6:00 PM']},
      ],
    },
  ];

  static const List<EventModel> venuesHandsOn = [
    EventModel(title: 'Art & Craft Studio', venue: 'Bandra • 3 kms', imagePath: 'assets/images/new_home/weekendspl1.png'),
    EventModel(title: 'DIY Workshop Hub', venue: 'Andheri • 5 kms', imagePath: 'assets/images/new_home/weekendspl2.png'),
    EventModel(title: 'Pottery Corner', venue: 'Juhu • 4 kms', imagePath: 'assets/images/new_home/weekendspl3.png'),
  ];

  static const List<EventModel> venuesEasyPocket = [
    EventModel(title: 'Community Art Cafe', venue: 'Andheri • Budget Friendly', imagePath: 'assets/images/new_home/hotpic4.png', tag: '3 Kms away'),
    EventModel(title: 'Local Play Zone', venue: 'Borivali • Low Cost', imagePath: 'assets/images/new_home/hotpick5.png', tag: '5 Kms away'),
    EventModel(title: 'Open Ground Park', venue: 'Malad • Free Entry', imagePath: 'assets/images/new_home/weekendspl4.png', tag: '2 Kms away'),
  ];

  static const List<EventModel> venuesHeadedMall = [
    EventModel(title: 'Arcade Gaming Zone', venue: 'Phoenix mall • 5 km', imagePath: 'assets/images/new_home/hotpics1.jpg', rating: 4.8, reviewCount: '3.5k reviews', tag: 'Fun Game', description: '4-12 Yrs'),
    EventModel(title: 'Soft Play Kingdom', venue: 'R-City mall • 6 km', imagePath: 'assets/images/new_home/hotpic2.png', rating: 4.6, reviewCount: '1.8k reviews', tag: 'Soft Play', description: '2-8 Yrs'),
    EventModel(title: 'Trampoline World', venue: 'Viviana mall • 9 km', imagePath: 'assets/images/new_home/hotpic3.png', rating: 4.7, reviewCount: '2.3k reviews', tag: 'Active', description: '5-15 Yrs'),
  ];

  static const List<EventModel> venuesThoughtful = [
    EventModel(title: 'Sensory Friendly Studio', venue: 'Bandra • 5 km', imagePath: 'assets/images/new_home/specialneeds1.png', rating: 4.8, reviewCount: '3.5k reviews', tag: 'Low noise', description: 'Safe Space'),
    EventModel(title: 'Inclusive Art Center', venue: 'Bandra • 3 km', imagePath: 'assets/images/new_home/specialneeds2.png', rating: 4.8, reviewCount: '3.5k reviews', tag: 'Certified Instr.'),
  ];

  // ── Venues subcategory screen data ──
  static const List<List<String>> venuesSubFilters = [
    ['All', 'Indoor', 'Outdoor', 'Water Play', 'Adventure'],       // Play & Adventure
    ['All', 'Football', 'Cricket', 'Swimming', 'Cycling'],         // Sports & Active
    ['All', 'Pottery', 'Painting', 'Craft', 'Workshops'],          // Creative & DIY
    ['All', 'Birthday', 'Private', 'Group', 'Premium'],            // Party & Celebration
    ['All', 'Labs', 'Robotics', 'Museum', 'Planetarium'],          // Science & Discovery
    ['All', 'Zoo', 'Farms', 'Parks', 'Aquarium'],                  // Nature & Animals
    ['All', 'Library', 'Tutoring', 'Olympiad', 'Study Cafe'],      // Reading & Study
    ['All', 'Cafes', 'Kids Menu', 'Play Cafes', 'Events'],         // Dining & Cafes
  ];

  static const List<List<EventModel>> venuesByCategory = [
    // Play & Adventure
    [
      EventModel(title: 'Play Arena', venue: 'Indoor Play Zone • 3 kms', imagePath: 'assets/images/new_home/hotpic4.png', rating: 4.6, reviewCount: '1.2k reviews', tag: 'Indoor'),
      EventModel(title: 'Adventure Park', venue: 'Outdoor Fun • 5 kms', imagePath: 'assets/images/new_home/hotpick5.png', rating: 4.5, reviewCount: '980 reviews', tag: 'Outdoor'),
      EventModel(title: 'Splash Zone', venue: 'Water Play • 8 kms', imagePath: 'assets/images/new_home/hotpic2.png', rating: 4.7, reviewCount: '1.5k reviews', tag: 'Water Play'),
      EventModel(title: 'Jump Mania', venue: 'Trampoline Fun • 4 kms', imagePath: 'assets/images/new_home/hotpic3.png', rating: 4.8, reviewCount: '2.1k reviews', tag: 'Adventure'),
    ],
    // Sports & Active
    [
      EventModel(title: 'Football Turf Arena', venue: 'Mira Road • 10 kms', imagePath: 'assets/images/new_home/hotpics1.jpg', rating: 4.7, reviewCount: '1.8k reviews', tag: 'Football'),
      EventModel(title: 'Swim Club', venue: 'Andheri • 5 kms', imagePath: 'assets/images/new_home/weekendspl1.png', rating: 4.6, reviewCount: '1.1k reviews', tag: 'Swimming'),
      EventModel(title: 'Cricket Ground', venue: 'Borivali • 7 kms', imagePath: 'assets/images/new_home/weekendspl2.png', rating: 4.5, reviewCount: '900 reviews', tag: 'Cricket'),
      EventModel(title: 'Cycle Track Park', venue: 'Powai • 6 kms', imagePath: 'assets/images/new_home/weekendspl3.png', rating: 4.4, reviewCount: '750 reviews', tag: 'Cycling'),
    ],
    // Creative & DIY
    [
      EventModel(title: 'Art & Craft Studio', venue: 'Bandra • 3 kms', imagePath: 'assets/images/new_home/weekendspl1.png', rating: 4.8, reviewCount: '2.0k reviews', tag: 'Craft'),
      EventModel(title: 'Pottery Corner', venue: 'Juhu • 4 kms', imagePath: 'assets/images/new_home/weekendspl3.png', rating: 4.7, reviewCount: '1.4k reviews', tag: 'Pottery'),
      EventModel(title: 'Canvas Studio', venue: 'Andheri • 5 kms', imagePath: 'assets/images/new_home/weekendspl2.png', rating: 4.6, reviewCount: '1.1k reviews', tag: 'Painting'),
      EventModel(title: 'DIY Workshop Hub', venue: 'Malad • 6 kms', imagePath: 'assets/images/new_home/weekendspl4.png', rating: 4.5, reviewCount: '870 reviews', tag: 'Workshops'),
    ],
    // Party & Celebration
    [
      EventModel(title: 'Royal Banquet Hall', venue: 'Powai • 5 kms', imagePath: 'assets/images/new_home/hotpics1.jpg', rating: 4.9, reviewCount: '3.5k reviews', tag: 'Birthday'),
      EventModel(title: 'Fun Zone Play Park', venue: 'Borivali • 6 kms', imagePath: 'assets/images/new_home/hotpic2.png', rating: 4.7, reviewCount: '2.1k reviews', tag: 'Kids Party'),
      EventModel(title: 'Grand Events Arena', venue: 'Bandra • 8 kms', imagePath: 'assets/images/new_home/hotpic3.png', rating: 4.9, reviewCount: '4.2k reviews', tag: 'Premium'),
      EventModel(title: 'Celebration Hub', venue: 'Juhu • 4 kms', imagePath: 'assets/images/new_home/hotpic4.png', rating: 4.6, reviewCount: '1.3k reviews', tag: 'Group'),
    ],
    // Science & Discovery
    [
      EventModel(title: 'Science Museum', venue: 'Worli • 10 kms', imagePath: 'assets/images/new_home/hotpic2.png', rating: 4.7, reviewCount: '2.8k reviews', tag: 'Museum'),
      EventModel(title: 'Innovation Lab', venue: 'Andheri • 5 kms', imagePath: 'assets/images/new_home/hotpic3.png', rating: 4.6, reviewCount: '1.5k reviews', tag: 'Labs'),
      EventModel(title: 'Robotics Hub', venue: 'Bandra • 7 kms', imagePath: 'assets/images/new_home/hotpics1.jpg', rating: 4.8, reviewCount: '1.9k reviews', tag: 'Robotics'),
      EventModel(title: 'Nehru Planetarium', venue: 'Worli • 12 kms', imagePath: 'assets/images/new_home/hotpick5.png', rating: 4.9, reviewCount: '3.2k reviews', tag: 'Planetarium'),
    ],
    // Nature & Animals
    [
      EventModel(title: 'City Zoo', venue: 'Byculla • 8 kms', imagePath: 'assets/images/new_home/hotpics1.jpg', rating: 4.5, reviewCount: '4.1k reviews', tag: 'Zoo'),
      EventModel(title: 'Open Ground Park', venue: 'Malad • 2 kms', imagePath: 'assets/images/new_home/weekendspl4.png', rating: 4.3, reviewCount: '620 reviews', tag: 'Parks'),
      EventModel(title: 'Lakeside Farm', venue: 'Navi Mumbai • 15 kms', imagePath: 'assets/images/new_home/hotpic4.png', rating: 4.6, reviewCount: '980 reviews', tag: 'Farms'),
      EventModel(title: 'Aqua World', venue: 'Thane • 12 kms', imagePath: 'assets/images/new_home/hotpic3.png', rating: 4.7, reviewCount: '1.6k reviews', tag: 'Aquarium'),
    ],
    // Reading & Study
    [
      EventModel(title: 'Community Library', venue: 'Andheri • 4 kms', imagePath: 'assets/images/new_home/weekendspl2.png', rating: 4.4, reviewCount: '560 reviews', tag: 'Library'),
      EventModel(title: 'Study Brew Cafe', venue: 'Bandra • 5 kms', imagePath: 'assets/images/new_home/weekendspl3.png', rating: 4.6, reviewCount: '1.0k reviews', tag: 'Study Cafe'),
      EventModel(title: 'Tutoring Hub', venue: 'Powai • 6 kms', imagePath: 'assets/images/new_home/weekendspl1.png', rating: 4.5, reviewCount: '800 reviews', tag: 'Tutoring'),
      EventModel(title: 'Olympiad Centre', venue: 'Dadar • 8 kms', imagePath: 'assets/images/new_home/hotpic4.png', rating: 4.7, reviewCount: '1.3k reviews', tag: 'Olympiad'),
    ],
    // Dining & Cafes
    [
      EventModel(title: 'Kid-Friendly Café', venue: 'Juhu • 3 kms', imagePath: 'assets/images/new_home/weekendspl1.png', rating: 4.7, reviewCount: '1.9k reviews', tag: 'Cafes'),
      EventModel(title: 'Play Café & More', venue: 'Andheri • 5 kms', imagePath: 'assets/images/new_home/weekendspl4.png', rating: 4.6, reviewCount: '1.4k reviews', tag: 'Play Cafes'),
      EventModel(title: 'Family Dine Inn', venue: 'Bandra • 4 kms', imagePath: 'assets/images/new_home/hotpic2.png', rating: 4.5, reviewCount: '1.0k reviews', tag: 'Kids Menu'),
      EventModel(title: 'Event Kitchen', venue: 'Powai • 7 kms', imagePath: 'assets/images/new_home/hotpic3.png', rating: 4.4, reviewCount: '730 reviews', tag: 'Events'),
    ],
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

  // Sub-filters per Classes category (index matches classesCategories)
  static const List<List<String>> classesSubFilters = [
    ['All', 'Math', 'Science', 'English', 'Olympiad', 'Reading'],                  // Academic
    ['All', 'Painting', 'Drawing', 'Pottery', 'DIY Craft', 'Sculpting'],            // Creative Arts
    ['All', 'Coding', 'Robotics', 'AI', '3D Printing', 'Electronics'],              // Tech & Innovation
    ['All', 'Dance', 'Music', 'Theater', 'Singing', 'Drama'],                       // Performing Arts
    ['All', 'Swimming', 'Yoga', 'Football', 'Cricket', 'Martial Arts'],             // Sports & Fitness
    ['All', 'Public Speaking', 'Debate', 'Storytelling', 'Phonics', 'Elocution'],   // Speech & Communication
    ['All', 'Life Skills', 'Leadership', 'Finance', 'Mindfulness', 'Social Skills'], // Life Skills & Personality Dev
    ['All', 'Photography', 'Video Editing', 'Animation', 'Podcasting', 'Design'],   // Creative Media
    ['All', 'Gardening', 'Nature Art', 'Bird Watching', 'Hiking', 'Eco Science'],   // Outdoor & Nature Learning
    ['All', 'Baking', 'Cooking', 'Pastry', 'Nutrition', 'Food Science'],             // Culinary
    ['All', 'Chess', 'Puzzles', 'Memory Games', 'Logic', 'Math Games'],              // Brain Boosters
  ];

  // Classes per Classes category (index matches classesCategories)
  static final List<List<EventModel>> classesByCategory = [
    // 0: Academic
    [
      const EventModel(
        title: 'Junior Math Olympiad Prep',
        venue: 'Bright Minds Academy',
        imagePath: 'assets/images/new_home/hotpic4.png',
        rating: 4.9,
        reviewCount: '2.1k reviews',
        tag: 'Olympiad',
        description: 'Weekly practice with past Olympiad papers and tricks.',
        eventDate: 'Sat, 26 Apr 2026',
        price: 800,
      ),
      const EventModel(
        title: 'Vedic Math Mastery',
        venue: 'Number Sense Hub',
        imagePath: 'assets/images/new_home/hotpic3.png',
        rating: 4.7,
        reviewCount: '1.4k reviews',
        tag: 'Math',
        description: 'Mental math shortcuts to solve faster with confidence.',
        eventDate: 'Sun, 27 Apr 2026',
        price: 650,
      ),
      const EventModel(
        title: 'Young Scientists Lab',
        venue: 'Curious Minds Studio',
        imagePath: 'assets/images/new_home/hotpics1.jpg',
        rating: 4.8,
        reviewCount: '1.9k reviews',
        tag: 'Science',
        description: 'Hands-on experiments in physics, chemistry and biology.',
        eventDate: 'Sat, 03 May 2026',
        price: 900,
      ),
      const EventModel(
        title: 'English Grammar Bootcamp',
        venue: 'Word Wizards Academy',
        imagePath: 'assets/images/new_home/hotpic2.png',
        rating: 4.6,
        reviewCount: '820 reviews',
        tag: 'English',
        description: 'Build strong grammar foundations with fun activities.',
        eventDate: 'Sun, 04 May 2026',
        price: 550,
      ),
      const EventModel(
        title: 'Reading Club for Kids',
        venue: 'The Book Nook',
        imagePath: 'assets/images/new_home/hotpic3.png',
        rating: 4.9,
        reviewCount: '1.3k reviews',
        tag: 'Reading',
        description: 'Weekly sessions with guided reading and story discussions.',
        eventDate: 'Sat, 10 May 2026',
        price: 500,
      ),
      const EventModel(
        title: 'Science Olympiad Coaching',
        venue: 'STEM Scholars Hub',
        imagePath: 'assets/images/new_home/hotpic4.png',
        rating: 5.0,
        reviewCount: '2.5k reviews',
        tag: 'Olympiad',
        description: 'Structured preparation for national science olympiads.',
        eventDate: 'Sun, 11 May 2026',
        price: 1200,
      ),
    ],
    // 1: Creative Arts
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
        title: 'Kids Pottery Class',
        venue: 'Clay Play Studio',
        imagePath: 'assets/images/new_home/hotpic2.png',
        rating: 4.9,
        reviewCount: '980 reviews',
        tag: 'Pottery',
        description: 'Shape, mould and glaze your own clay bowl.',
        eventDate: 'Sun, 27 Apr 2026',
        price: 750,
      ),
      const EventModel(
        title: 'DIY Craft Workshop',
        venue: 'Little Makers Hub',
        imagePath: 'assets/images/new_home/hotpic3.png',
        rating: 4.7,
        reviewCount: '640 reviews',
        tag: 'DIY Craft',
        description: 'Build, paint and take home your own creation.',
        eventDate: 'Sun, 04 May 2026',
        price: 400,
      ),
      const EventModel(
        title: 'Mixed Media Art Camp',
        venue: 'Creative Corner',
        imagePath: 'assets/images/new_home/newontlb1.jpg',
        rating: 4.9,
        reviewCount: '1.8k reviews',
        tag: 'DIY Craft',
        description: 'Combine paint, paper and fabric into one artwork.',
        eventDate: 'Sun, 11 May 2026',
        price: 900,
      ),
      const EventModel(
        title: 'Clay Sculpting for Kids',
        venue: 'Art Horizon Studio',
        imagePath: 'assets/images/new_home/weekendspl1.png',
        rating: 4.8,
        reviewCount: '720 reviews',
        tag: 'Sculpting',
        description: 'Mould animals, figures and abstract art from clay.',
        eventDate: 'Sat, 17 May 2026',
        price: 700,
      ),
    ],
    // 2: Tech & Innovation
    [
      const EventModel(
        title: 'Scratch Coding Workshop',
        venue: 'CodeKids Hub',
        imagePath: 'assets/images/new_home/onlineevent1.jpg',
        rating: 4.8,
        reviewCount: '2.2k reviews',
        tag: 'Coding',
        description: 'Create interactive animations and games using Scratch.',
        eventDate: 'Sun, 27 Apr 2026',
        price: 1000,
      ),
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
        title: 'AI for Young Minds',
        venue: 'Future Tech Lab',
        imagePath: 'assets/images/new_home/hotpic4.png',
        rating: 4.9,
        reviewCount: '1.6k reviews',
        tag: 'AI',
        description: 'Intro to machine learning with fun real-world projects.',
        eventDate: 'Sat, 03 May 2026',
        price: 1500,
      ),
      const EventModel(
        title: '3D Printing Workshop',
        venue: 'Maker Space Studio',
        imagePath: 'assets/images/new_home/hotpic3.png',
        rating: 4.7,
        reviewCount: '890 reviews',
        tag: '3D Printing',
        description: 'Design and print your own 3D models from scratch.',
        eventDate: 'Sun, 04 May 2026',
        price: 1100,
      ),
      const EventModel(
        title: 'Electronics & Circuits',
        venue: 'SparkTech Hub',
        imagePath: 'assets/images/new_home/hotpics1.jpg',
        rating: 4.8,
        reviewCount: '1.1k reviews',
        tag: 'Electronics',
        description: 'Build simple circuits and learn how electronics work.',
        eventDate: 'Sat, 10 May 2026',
        price: 950,
      ),
      const EventModel(
        title: 'Python for Teens',
        venue: 'Learn Tech Hub',
        imagePath: 'assets/images/new_home/hotpic2.png',
        rating: 4.9,
        reviewCount: '2.8k reviews',
        tag: 'Coding',
        description: 'Learn Python fundamentals with real project builds.',
        eventDate: 'Sun, 11 May 2026',
        price: 1300,
      ),
    ],
    // 3: Performing Arts
    [
      const EventModel(
        title: 'Kids Hip-Hop Dance',
        venue: 'Groove Dance Academy',
        imagePath: 'assets/images/new_home/weekendspl1.png',
        rating: 4.5,
        reviewCount: '1.4k reviews',
        tag: 'Dance',
        description: 'Fun and energetic dance classes to improve rhythm.',
        eventDate: 'Sat, 26 Apr 2026',
        price: 700,
      ),
      const EventModel(
        title: 'Bollywood Dance Workshop',
        venue: 'Rhythm Academy',
        imagePath: 'assets/images/new_home/weekendspl3.png',
        rating: 5.0,
        reviewCount: '3.1k reviews',
        tag: 'Dance',
        description: 'High energy moves with trending Bollywood hits.',
        eventDate: 'Sun, 27 Apr 2026',
        price: 750,
      ),
      const EventModel(
        title: 'Beginner Guitar Class',
        venue: 'Melody Music Studio',
        imagePath: 'assets/images/new_home/weekendspl2.png',
        rating: 4.7,
        reviewCount: '920 reviews',
        tag: 'Music',
        description: 'Learn guitar basics from scratch with fun songs.',
        eventDate: 'Sat, 03 May 2026',
        price: 800,
      ),
      const EventModel(
        title: 'Kids Theater Workshop',
        venue: 'Stage & Story Studio',
        imagePath: 'assets/images/featured_partners/2.png',
        rating: 4.8,
        reviewCount: '1.5k reviews',
        tag: 'Theater',
        description: 'Act, script and perform a mini-play on stage.',
        eventDate: 'Sun, 04 May 2026',
        price: 850,
      ),
      const EventModel(
        title: 'Vocal Training for Beginners',
        venue: 'Melodia Music School',
        imagePath: 'assets/images/new_home/hotpics1.jpg',
        rating: 4.7,
        reviewCount: '870 reviews',
        tag: 'Singing',
        description: 'Breathing, pitch and ear-training fundamentals.',
        eventDate: 'Sat, 10 May 2026',
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
        eventDate: 'Sun, 11 May 2026',
        price: 650,
      ),
    ],
    // 4: Sports & Fitness
    [
      const EventModel(
        title: 'Swimming for Kids',
        venue: 'Aqua Sports Center',
        imagePath: 'assets/images/new_home/weekendspl3.png',
        rating: 4.9,
        reviewCount: '2.3k reviews',
        tag: 'Swimming',
        description: 'Professional coaching in a safe, fun environment.',
        eventDate: 'Sat, 26 Apr 2026',
        price: 900,
      ),
      const EventModel(
        title: 'Kids Yoga & Mindfulness',
        venue: 'Calm Minds Academy',
        imagePath: 'assets/images/new_home/specialneeds1.png',
        rating: 4.7,
        reviewCount: '1.1k reviews',
        tag: 'Yoga',
        description: 'Gentle yoga poses, breathing and relaxation for kids.',
        eventDate: 'Sun, 27 Apr 2026',
        price: 500,
      ),
      const EventModel(
        title: 'Football Training Camp',
        venue: 'Champions Arena',
        imagePath: 'assets/images/new_home/weekendspl4.png',
        rating: 4.8,
        reviewCount: '1.8k reviews',
        tag: 'Football',
        description: 'Build dribbling, passing and teamwork skills.',
        eventDate: 'Sat, 03 May 2026',
        price: 800,
      ),
      const EventModel(
        title: 'Cricket Coaching Academy',
        venue: 'Sports Horizon Club',
        imagePath: 'assets/images/new_home/weekendspl1.png',
        rating: 4.7,
        reviewCount: '1.3k reviews',
        tag: 'Cricket',
        description: 'Batting, bowling and fielding drills with certified coaches.',
        eventDate: 'Sun, 04 May 2026',
        price: 850,
      ),
      const EventModel(
        title: 'Karate for Young Warriors',
        venue: 'Dojo Martial Arts',
        imagePath: 'assets/images/new_home/hotpic4.png',
        rating: 5.0,
        reviewCount: '1.9k reviews',
        tag: 'Martial Arts',
        description: 'Discipline, focus and self-defence through karate.',
        eventDate: 'Sat, 10 May 2026',
        price: 950,
      ),
      const EventModel(
        title: 'Taekwondo Beginners',
        venue: 'Black Belt Academy',
        imagePath: 'assets/images/new_home/hotpic3.png',
        rating: 4.8,
        reviewCount: '980 reviews',
        tag: 'Martial Arts',
        description: 'Kicks, stances and forms for all fitness levels.',
        eventDate: 'Sun, 11 May 2026',
        price: 900,
      ),
    ],
    // 5: Speech & Communication
    [
      const EventModel(
        title: 'Public Speaking Bootcamp',
        venue: 'Speak Up Academy',
        imagePath: 'assets/images/new_home/hotpic3.png',
        rating: 4.9,
        reviewCount: '1.7k reviews',
        tag: 'Public Speaking',
        description: 'Build confidence on stage with structured practice.',
        eventDate: 'Sat, 26 Apr 2026',
        price: 700,
      ),
      const EventModel(
        title: 'Junior Debate Club',
        venue: 'Eloquence Hub',
        imagePath: 'assets/images/new_home/hotpic4.png',
        rating: 4.8,
        reviewCount: '1.2k reviews',
        tag: 'Debate',
        description: 'Learn rebuttal, argument structure and quick thinking.',
        eventDate: 'Sun, 27 Apr 2026',
        price: 650,
      ),
      const EventModel(
        title: 'Storytelling for Young Kids',
        venue: 'The Book Nook',
        imagePath: 'assets/images/new_home/hotpic2.png',
        rating: 4.7,
        reviewCount: '890 reviews',
        tag: 'Storytelling',
        description: 'Bring stories to life with voice and expression.',
        eventDate: 'Sat, 03 May 2026',
        price: 500,
      ),
      const EventModel(
        title: 'Phonics & Reading Aloud',
        venue: 'Word Wizards Academy',
        imagePath: 'assets/images/new_home/hotpics1.jpg',
        rating: 4.8,
        reviewCount: '1.1k reviews',
        tag: 'Phonics',
        description: 'Master letter sounds and fluent reading.',
        eventDate: 'Sun, 04 May 2026',
        price: 550,
      ),
      const EventModel(
        title: 'Elocution & Diction Class',
        venue: 'Speak Up Academy',
        imagePath: 'assets/images/new_home/weekendspl2.png',
        rating: 4.9,
        reviewCount: '940 reviews',
        tag: 'Elocution',
        description: 'Clear pronunciation, pace and expressive delivery.',
        eventDate: 'Sat, 10 May 2026',
        price: 600,
      ),
      const EventModel(
        title: 'MUN Prep for Teens',
        venue: 'Eloquence Hub',
        imagePath: 'assets/images/new_home/weekendspl3.png',
        rating: 5.0,
        reviewCount: '2.2k reviews',
        tag: 'Debate',
        description: 'Model UN prep — research, caucus and resolution writing.',
        eventDate: 'Sun, 11 May 2026',
        price: 900,
      ),
    ],
    // 6: Life Skills & Personality Dev
    [
      const EventModel(
        title: 'Junior Leadership Camp',
        venue: "Leader's Den",
        imagePath: 'assets/images/new_home/hotpics1.jpg',
        rating: 4.9,
        reviewCount: '1.7k reviews',
        tag: 'Leadership',
        description: 'Teamwork, problem-solving and decision-making skills.',
        eventDate: 'Sat, 26 Apr 2026',
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
        eventDate: 'Sun, 27 Apr 2026',
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
        eventDate: 'Sat, 03 May 2026',
        price: 400,
      ),
      const EventModel(
        title: 'Social Skills Bootcamp',
        venue: 'Confidence Corner',
        imagePath: 'assets/images/new_home/hotpic2.png',
        rating: 4.8,
        reviewCount: '1.1k reviews',
        tag: 'Social Skills',
        description: 'Empathy, communication and friendship-building activities.',
        eventDate: 'Sun, 04 May 2026',
        price: 600,
      ),
      const EventModel(
        title: 'Personality Development Class',
        venue: 'Groom & Shine Studio',
        imagePath: 'assets/images/new_home/hotpic4.png',
        rating: 5.0,
        reviewCount: '1.5k reviews',
        tag: 'Life Skills',
        description: 'Confidence, etiquette and positive self-image for kids.',
        eventDate: 'Sat, 10 May 2026',
        price: 700,
      ),
    ],
    // 7: Creative Media
    [
      const EventModel(
        title: 'Kids Photography Class',
        venue: 'SnapKids Studio',
        imagePath: 'assets/images/new_home/onlineevent1.jpg',
        rating: 4.8,
        reviewCount: '1.2k reviews',
        tag: 'Photography',
        description: 'Composition, lighting and storytelling through photos.',
        eventDate: 'Sat, 26 Apr 2026',
        price: 700,
      ),
      const EventModel(
        title: 'Junior Vloggers Workshop',
        venue: 'Content Creators Lab',
        imagePath: 'assets/images/new_home/onlineevent2.jpg',
        rating: 4.7,
        reviewCount: '860 reviews',
        tag: 'Video Editing',
        description: 'Script, shoot and edit your own YouTube-ready vlog.',
        eventDate: 'Sun, 27 Apr 2026',
        price: 900,
      ),
      const EventModel(
        title: 'Animation Basics for Kids',
        venue: 'Toon Workshop',
        imagePath: 'assets/images/new_home/hotpic2.png',
        rating: 4.9,
        reviewCount: '1.4k reviews',
        tag: 'Animation',
        description: 'Create simple 2D animations using beginner-friendly tools.',
        eventDate: 'Sat, 03 May 2026',
        price: 1100,
      ),
      const EventModel(
        title: 'Podcast for Teens',
        venue: 'SoundWave Studio',
        imagePath: 'assets/images/new_home/hotpic3.png',
        rating: 4.6,
        reviewCount: '540 reviews',
        tag: 'Podcasting',
        description: 'Record, edit and publish your own podcast episode.',
        eventDate: 'Sun, 04 May 2026',
        price: 800,
      ),
      const EventModel(
        title: 'Graphic Design for Kids',
        venue: 'Creative Pixels Hub',
        imagePath: 'assets/images/new_home/hotpic4.png',
        rating: 4.8,
        reviewCount: '1.0k reviews',
        tag: 'Design',
        description: 'Canva, colours and layouts to create stunning posters.',
        eventDate: 'Sat, 10 May 2026',
        price: 750,
      ),
    ],
    // 8: Outdoor & Nature Learning
    [
      const EventModel(
        title: 'Kids Gardening Workshop',
        venue: 'Green Thumb Garden',
        imagePath: 'assets/images/new_home/weekendspl4.png',
        rating: 4.8,
        reviewCount: '1.1k reviews',
        tag: 'Gardening',
        description: 'Sow seeds, care for plants and learn about ecosystems.',
        eventDate: 'Sat, 26 Apr 2026',
        price: 500,
      ),
      const EventModel(
        title: 'Nature Photography Walk',
        venue: 'City Nature Reserve',
        imagePath: 'assets/images/new_home/weekendspl2.png',
        rating: 4.7,
        reviewCount: '720 reviews',
        tag: 'Nature Art',
        description: 'Capture birds, flowers and insects in their natural habitat.',
        eventDate: 'Sun, 27 Apr 2026',
        price: 600,
      ),
      const EventModel(
        title: 'Eco Science Camp',
        venue: 'EarthKids Academy',
        imagePath: 'assets/images/new_home/hotpic2.png',
        rating: 4.9,
        reviewCount: '1.3k reviews',
        tag: 'Eco Science',
        description: 'Composting, water cycles and sustainability experiments.',
        eventDate: 'Sat, 03 May 2026',
        price: 700,
      ),
      const EventModel(
        title: 'Bird Watching Day Trip',
        venue: 'Local Wetland Park',
        imagePath: 'assets/images/new_home/hotpic3.png',
        rating: 4.6,
        reviewCount: '480 reviews',
        tag: 'Bird Watching',
        description: 'Spot, identify and record bird species with expert guides.',
        eventDate: 'Sun, 04 May 2026',
        price: 450,
      ),
    ],
    // 9: Culinary
    [
      const EventModel(
        title: 'Little Chefs Baking Class',
        venue: 'Little Chef Studio',
        imagePath: 'assets/images/new_home/weekendspl1.png',
        rating: 5.0,
        reviewCount: '3.2k reviews',
        tag: 'Baking',
        description: 'Cupcakes, cookies and bread — easy recipes kids love.',
        eventDate: 'Sat, 26 Apr 2026',
        price: 700,
      ),
      const EventModel(
        title: 'Pizza Making Masterclass',
        venue: 'Dough & Cheese Kitchen',
        imagePath: 'assets/images/new_home/hotpics1.jpg',
        rating: 4.9,
        reviewCount: '2.1k reviews',
        tag: 'Cooking',
        description: 'Roll dough, add toppings and bake your own pizza.',
        eventDate: 'Sun, 27 Apr 2026',
        price: 600,
      ),
      const EventModel(
        title: 'Junior Pastry Chef',
        venue: 'Sweet Studio',
        imagePath: 'assets/images/new_home/hotpic2.png',
        rating: 4.8,
        reviewCount: '1.4k reviews',
        tag: 'Pastry',
        description: 'Tarts, eclairs and macarons with a pastry chef.',
        eventDate: 'Sat, 03 May 2026',
        price: 850,
      ),
      const EventModel(
        title: 'Kids Nutrition Workshop',
        venue: 'Healthy Bites Lab',
        imagePath: 'assets/images/new_home/hotpic4.png',
        rating: 4.7,
        reviewCount: '640 reviews',
        tag: 'Nutrition',
        description: 'Learn about food groups, balanced meals and healthy eating.',
        eventDate: 'Sun, 04 May 2026',
        price: 450,
      ),
    ],
    // 10: Brain Boosters
    [
      const EventModel(
        title: 'Chess for Beginners',
        venue: 'Mind Masters Club',
        imagePath: 'assets/images/new_home/hotpic4.png',
        rating: 4.8,
        reviewCount: '1.8k reviews',
        tag: 'Chess',
        description: 'Pieces, rules and opening strategies for young players.',
        eventDate: 'Sat, 26 Apr 2026',
        price: 500,
      ),
      const EventModel(
        title: 'Puzzle & Logic Bootcamp',
        venue: 'Think Tank Studio',
        imagePath: 'assets/images/new_home/hotpic3.png',
        rating: 4.9,
        reviewCount: '1.2k reviews',
        tag: 'Puzzles',
        description: 'Sudoku, tangrams and lateral thinking challenges.',
        eventDate: 'Sun, 27 Apr 2026',
        price: 450,
      ),
      const EventModel(
        title: 'Memory Training Workshop',
        venue: 'Neuron Boost Academy',
        imagePath: 'assets/images/new_home/hotpic2.png',
        rating: 4.7,
        reviewCount: '830 reviews',
        tag: 'Memory Games',
        description: 'Mnemonics, association techniques and memory palace methods.',
        eventDate: 'Sat, 03 May 2026',
        price: 600,
      ),
      const EventModel(
        title: 'Math Puzzles & Games',
        venue: 'Number Ninjas Hub',
        imagePath: 'assets/images/new_home/hotpics1.jpg',
        rating: 4.8,
        reviewCount: '1.5k reviews',
        tag: 'Math Games',
        description: 'Fun, game-based approach to sharpen number skills.',
        eventDate: 'Sun, 04 May 2026',
        price: 400,
      ),
      const EventModel(
        title: 'Logic & Reasoning Class',
        venue: 'Brain Gym Studio',
        imagePath: 'assets/images/new_home/weekendspl4.png',
        rating: 5.0,
        reviewCount: '2.0k reviews',
        tag: 'Logic',
        description: 'Pattern recognition, deductive reasoning and IQ prep.',
        eventDate: 'Sat, 10 May 2026',
        price: 550,
      ),
    ],
  ];

  // ── Programs sub-filters (index matches programsCategories) ──────────────
  static const List<List<String>> programsSubFilters = [
    ['All', 'Coding', 'AI', 'Robotics', 'Cybersecurity', 'Data Science'],            // 0: Future Tech & AI
    ['All', 'UI/UX', 'Graphic Design', '3D Design', 'Architecture', 'Product'],      // 1: Design & Innovation
    ['All', 'Startups', 'Public Speaking', 'Finance', 'Marketing', 'Team Building'], // 2: Leadership
    ['All', 'Photography', 'Video', 'Podcasting', 'Writing', 'Social Media'],        // 3: Media & Content
    ['All', 'Theater', 'Dance', 'Music', 'Stand-up', 'Musical'],                     // 4: Stage Arts
    ['All', 'Football', 'Cricket', 'Swimming', 'Athletics', 'Martial Arts'],         // 5: Active Sports
    ['All', 'Olympiad', 'JEE Prep', 'NEET Prep', 'SAT', 'Scholarship'],              // 6: Academics
    ['All', 'Chess', 'Logic', 'Puzzles', 'Data', 'Problem Solving'],                 // 7: Analytical Thinking
    ['All', 'English', 'Hindi', 'French', 'Debate', 'Creative Writing'],             // 8: Language & Comm
    ['All', 'Baking', 'Cooking', 'Pastry', 'Barista', 'Food Science'],               // 9: Culinary
    ['All', 'Etiquette', 'Confidence', 'Interview', 'Style', 'Mindfulness'],         // 10: Grooming
  ];

  // ── Programs per category (index matches programsCategories) ─────────────
  static final List<List<EventModel>> programsByCategory = [
    // 0: Future Tech & AI
    [
      const EventModel(
        title: 'Future Coders Bootcamp',
        venue: 'Code Academy',
        imagePath: 'assets/images/new_home/hotpics1.jpg',
        rating: 4.9,
        reviewCount: '2.3k reviews',
        tag: 'Coding',
        description: 'Hands-on Python and web dev for young coders.',
        eventDate: 'Sat, 26 Apr 2026',
        price: 1200,
      ),
      const EventModel(
        title: 'AI for Young Minds',
        venue: 'TechSpark Studio',
        imagePath: 'assets/images/new_home/hotpic2.png',
        rating: 4.8,
        reviewCount: '1.8k reviews',
        tag: 'AI',
        description: 'Build simple AI models with Scratch and Python.',
        eventDate: 'Sun, 27 Apr 2026',
        price: 1500,
      ),
      const EventModel(
        title: 'Robotics Championship Prep',
        venue: 'RoboKids Lab',
        imagePath: 'assets/images/new_home/hotpic3.png',
        rating: 4.7,
        reviewCount: '1.2k reviews',
        tag: 'Robotics',
        description: 'Build and program robots to solve real challenges.',
        eventDate: 'Sat, 03 May 2026',
        price: 2000,
      ),
      const EventModel(
        title: 'Cybersecurity for Teens',
        venue: 'SecureNet Academy',
        imagePath: 'assets/images/new_home/hotpic4.png',
        rating: 4.6,
        reviewCount: '890 reviews',
        tag: 'Cybersecurity',
        description: 'Ethical hacking basics and digital safety skills.',
        eventDate: 'Sun, 04 May 2026',
        price: 1800,
      ),
    ],
    // 1: Design & Innovation
    [
      const EventModel(
        title: 'Junior UX Design Workshop',
        venue: 'Design Hub',
        imagePath: 'assets/images/new_home/weekendspl1.png',
        rating: 4.8,
        reviewCount: '1.5k reviews',
        tag: 'UI/UX',
        description: 'Design apps and websites using Figma from scratch.',
        eventDate: 'Sat, 26 Apr 2026',
        price: 1200,
      ),
      const EventModel(
        title: 'Graphic Design Basics',
        venue: 'Creative Canvas',
        imagePath: 'assets/images/new_home/weekendspl2.png',
        rating: 4.7,
        reviewCount: '1.1k reviews',
        tag: 'Graphic Design',
        description: 'Logo design and typography for beginners.',
        eventDate: 'Sun, 27 Apr 2026',
        price: 900,
      ),
      const EventModel(
        title: '3D Modelling for Kids',
        venue: 'Make3D Studio',
        imagePath: 'assets/images/new_home/hotpics1.jpg',
        rating: 4.9,
        reviewCount: '2.0k reviews',
        tag: '3D Design',
        description: 'Create 3D models using Blender and Tinkercad.',
        eventDate: 'Sat, 03 May 2026',
        price: 1500,
      ),
      const EventModel(
        title: 'Innovation Challenge Camp',
        venue: 'ThinkLab',
        imagePath: 'assets/images/new_home/hotpic2.png',
        rating: 4.8,
        reviewCount: '1.4k reviews',
        tag: 'Product',
        description: 'Prototype real-world solutions using design thinking.',
        eventDate: 'Sun, 04 May 2026',
        price: 1800,
      ),
    ],
    // 2: Leadership & Entrepreneurship
    [
      const EventModel(
        title: 'Young Entrepreneurs Camp',
        venue: 'BizKids Academy',
        imagePath: 'assets/images/new_home/hotpic3.png',
        rating: 4.9,
        reviewCount: '3.1k reviews',
        tag: 'Startups',
        description: 'Pitch, plan and prototype your own startup idea.',
        eventDate: 'Sat, 26 Apr 2026',
        price: 2200,
      ),
      const EventModel(
        title: 'Public Speaking Mastery',
        venue: 'Voice Forward Academy',
        imagePath: 'assets/images/new_home/hotpic4.png',
        rating: 4.8,
        reviewCount: '2.4k reviews',
        tag: 'Public Speaking',
        description: 'Build confidence and speak with clarity on stage.',
        eventDate: 'Sun, 27 Apr 2026',
        price: 1200,
      ),
      const EventModel(
        title: 'Teen Finance Workshop',
        venue: 'Money Minds',
        imagePath: 'assets/images/new_home/weekendspl3.png',
        rating: 4.7,
        reviewCount: '1.6k reviews',
        tag: 'Finance',
        description: 'Savings, budgeting and investing basics for teens.',
        eventDate: 'Sat, 03 May 2026',
        price: 900,
      ),
      const EventModel(
        title: 'Leadership Summit for Teens',
        venue: 'Lead Forward',
        imagePath: 'assets/images/new_home/weekendspl4.png',
        rating: 4.9,
        reviewCount: '2.8k reviews',
        tag: 'Team Building',
        description: 'Intensive 3-day leadership program with real projects.',
        eventDate: 'Sun, 04 May 2026',
        price: 3500,
      ),
    ],
    // 3: Media & Content Creation
    [
      const EventModel(
        title: 'Photography Masterclass',
        venue: 'Lens Craft Studio',
        imagePath: 'assets/images/new_home/hotpics1.jpg',
        rating: 4.8,
        reviewCount: '1.9k reviews',
        tag: 'Photography',
        description: 'Master composition, lighting and photo editing.',
        eventDate: 'Sat, 26 Apr 2026',
        price: 1200,
      ),
      const EventModel(
        title: 'YouTube Creator Camp',
        venue: 'Creator Academy',
        imagePath: 'assets/images/new_home/hotpic2.png',
        rating: 4.9,
        reviewCount: '3.4k reviews',
        tag: 'Video',
        description: 'Script, shoot and edit your own YouTube channel.',
        eventDate: 'Sun, 27 Apr 2026',
        price: 2000,
      ),
      const EventModel(
        title: 'Kids Podcast Workshop',
        venue: 'Audio Stories Lab',
        imagePath: 'assets/images/new_home/hotpic3.png',
        rating: 4.7,
        reviewCount: '1.1k reviews',
        tag: 'Podcasting',
        description: 'Record and publish your own podcast episode.',
        eventDate: 'Sat, 03 May 2026',
        price: 900,
      ),
      const EventModel(
        title: 'Creative Writing for Teens',
        venue: 'Ink & Idea Studio',
        imagePath: 'assets/images/new_home/hotpic4.png',
        rating: 4.8,
        reviewCount: '1.7k reviews',
        tag: 'Writing',
        description: 'Story arcs, dialogue and character building.',
        eventDate: 'Sun, 04 May 2026',
        price: 800,
      ),
    ],
    // 4: Stage Arts & Performance
    [
      const EventModel(
        title: 'Theater for Kids',
        venue: 'Stage Bright Academy',
        imagePath: 'assets/images/new_home/weekendspl1.png',
        rating: 4.9,
        reviewCount: '2.6k reviews',
        tag: 'Theater',
        description: 'Script reading, stage presence and performance.',
        eventDate: 'Sat, 26 Apr 2026',
        price: 1200,
      ),
      const EventModel(
        title: 'Contemporary Dance Workshop',
        venue: 'Move & Groove',
        imagePath: 'assets/images/new_home/weekendspl2.png',
        rating: 4.8,
        reviewCount: '2.1k reviews',
        tag: 'Dance',
        description: 'Learn contemporary and hip-hop dance forms.',
        eventDate: 'Sun, 27 Apr 2026',
        price: 1000,
      ),
      const EventModel(
        title: 'Kids Music Band Program',
        venue: 'Harmony Hall',
        imagePath: 'assets/images/new_home/hotpics1.jpg',
        rating: 4.7,
        reviewCount: '1.4k reviews',
        tag: 'Music',
        description: 'Learn to play, compose and perform as a band.',
        eventDate: 'Sat, 03 May 2026',
        price: 1800,
      ),
      const EventModel(
        title: 'Junior Stand-Up Comedy',
        venue: 'Laugh Lab',
        imagePath: 'assets/images/new_home/hotpic2.png',
        rating: 4.9,
        reviewCount: '1.8k reviews',
        tag: 'Stand-up',
        description: 'Write and perform your own 5-minute comedy set.',
        eventDate: 'Sun, 04 May 2026',
        price: 800,
      ),
    ],
    // 5: Active Sports & Training
    [
      const EventModel(
        title: 'Football Academy',
        venue: 'Goal Getters FC',
        imagePath: 'assets/images/new_home/hotpic3.png',
        rating: 4.8,
        reviewCount: '2.3k reviews',
        tag: 'Football',
        description: 'Dribbling, passing and match-play training.',
        eventDate: 'Sat, 26 Apr 2026',
        price: 1500,
      ),
      const EventModel(
        title: 'Cricket Coaching Camp',
        venue: 'Pitch Perfect Academy',
        imagePath: 'assets/images/new_home/hotpic4.png',
        rating: 4.9,
        reviewCount: '3.2k reviews',
        tag: 'Cricket',
        description: 'Batting, bowling and fielding with certified coaches.',
        eventDate: 'Sun, 27 Apr 2026',
        price: 2000,
      ),
      const EventModel(
        title: 'Junior Swimming Program',
        venue: 'Splash Zone',
        imagePath: 'assets/images/new_home/weekendspl3.png',
        rating: 4.7,
        reviewCount: '1.8k reviews',
        tag: 'Swimming',
        description: 'Learn strokes and water safety in a fun environment.',
        eventDate: 'Sat, 03 May 2026',
        price: 1200,
      ),
      const EventModel(
        title: 'Martial Arts Beginner Course',
        venue: 'DragonFly Dojo',
        imagePath: 'assets/images/new_home/weekendspl4.png',
        rating: 4.8,
        reviewCount: '2.0k reviews',
        tag: 'Martial Arts',
        description: 'Build discipline, strength and self-defence skills.',
        eventDate: 'Sun, 04 May 2026',
        price: 1500,
      ),
    ],
    // 6: Academics & Competitive Prep
    [
      const EventModel(
        title: 'JEE Foundation Course',
        venue: 'Apex Academy',
        imagePath: 'assets/images/new_home/hotpics1.jpg',
        rating: 4.9,
        reviewCount: '4.1k reviews',
        tag: 'JEE Prep',
        description: 'Strong foundation in Physics, Chemistry and Math.',
        eventDate: 'Sat, 26 Apr 2026',
        price: 3500,
      ),
      const EventModel(
        title: 'Science Olympiad Coaching',
        venue: 'STEM Scholars',
        imagePath: 'assets/images/new_home/hotpic2.png',
        rating: 4.8,
        reviewCount: '2.7k reviews',
        tag: 'Olympiad',
        description: 'Structured coaching for NSO, IAIS and similar exams.',
        eventDate: 'Sun, 27 Apr 2026',
        price: 2200,
      ),
      const EventModel(
        title: 'Scholarship Exam Workshop',
        venue: 'Bright Futures Institute',
        imagePath: 'assets/images/new_home/hotpic3.png',
        rating: 4.7,
        reviewCount: '1.5k reviews',
        tag: 'Scholarship',
        description: 'Master common scholarship exam formats and tricks.',
        eventDate: 'Sat, 03 May 2026',
        price: 1200,
      ),
      const EventModel(
        title: 'SAT Prep for Teens',
        venue: 'Global Edge Academy',
        imagePath: 'assets/images/new_home/hotpic4.png',
        rating: 4.8,
        reviewCount: '1.9k reviews',
        tag: 'SAT',
        description: 'Comprehensive SAT Math and English preparation.',
        eventDate: 'Sun, 04 May 2026',
        price: 4000,
      ),
    ],
    // 7: Analytical Thinking
    [
      const EventModel(
        title: 'Chess Training Program',
        venue: 'King & Queen Chess Club',
        imagePath: 'assets/images/new_home/weekendspl1.png',
        rating: 4.9,
        reviewCount: '2.2k reviews',
        tag: 'Chess',
        description: 'Opening theory, tactics and endgame strategies.',
        eventDate: 'Sat, 26 Apr 2026',
        price: 900,
      ),
      const EventModel(
        title: 'Logic & Reasoning Camp',
        venue: 'Think Sharp Academy',
        imagePath: 'assets/images/new_home/weekendspl2.png',
        rating: 4.7,
        reviewCount: '1.4k reviews',
        tag: 'Logic',
        description: 'Verbal and non-verbal reasoning with practice sets.',
        eventDate: 'Sun, 27 Apr 2026',
        price: 1200,
      ),
      const EventModel(
        title: 'Problem Solving Workshop',
        venue: 'BrainWave Studio',
        imagePath: 'assets/images/new_home/hotpics1.jpg',
        rating: 4.8,
        reviewCount: '1.6k reviews',
        tag: 'Problem Solving',
        description: 'STEM challenges that build lateral thinking skills.',
        eventDate: 'Sat, 03 May 2026',
        price: 1500,
      ),
      const EventModel(
        title: 'Data Thinking for Kids',
        venue: 'DataLab Jr.',
        imagePath: 'assets/images/new_home/hotpic2.png',
        rating: 4.6,
        reviewCount: '980 reviews',
        tag: 'Data',
        description: 'Read charts, spot patterns and make data decisions.',
        eventDate: 'Sun, 04 May 2026',
        price: 1200,
      ),
    ],
    // 8: Language & Communication
    [
      const EventModel(
        title: 'Spoken English Confidence',
        venue: 'Fluent Minds Academy',
        imagePath: 'assets/images/new_home/hotpic3.png',
        rating: 4.9,
        reviewCount: '3.5k reviews',
        tag: 'English',
        description: 'Accent, fluency and conversation skills for teens.',
        eventDate: 'Sat, 26 Apr 2026',
        price: 900,
      ),
      const EventModel(
        title: 'Debate & MUN Workshop',
        venue: 'Voice of Youth',
        imagePath: 'assets/images/new_home/hotpic4.png',
        rating: 4.8,
        reviewCount: '2.1k reviews',
        tag: 'Debate',
        description: 'Persuasion, rebuttal and structured argumentation.',
        eventDate: 'Sun, 27 Apr 2026',
        price: 1400,
      ),
      const EventModel(
        title: 'French Beginner Course',
        venue: 'Bonjour Kids',
        imagePath: 'assets/images/new_home/weekendspl3.png',
        rating: 4.7,
        reviewCount: '1.2k reviews',
        tag: 'French',
        description: 'Basic French speaking, reading and vocabulary.',
        eventDate: 'Sat, 03 May 2026',
        price: 1200,
      ),
      const EventModel(
        title: 'Creative Writing Workshop',
        venue: 'Story Seedlings',
        imagePath: 'assets/images/new_home/weekendspl4.png',
        rating: 4.9,
        reviewCount: '2.4k reviews',
        tag: 'Creative Writing',
        description: 'Plot, character and world-building from scratch.',
        eventDate: 'Sun, 04 May 2026',
        price: 900,
      ),
    ],
    // 9: Culinary & Hospitality
    [
      const EventModel(
        title: 'Junior Baking Workshop',
        venue: 'Sugar & Spice Studio',
        imagePath: 'assets/images/new_home/hotpics1.jpg',
        rating: 4.9,
        reviewCount: '2.8k reviews',
        tag: 'Baking',
        description: 'Cakes, cookies and breads baked from scratch.',
        eventDate: 'Sat, 26 Apr 2026',
        price: 1500,
      ),
      const EventModel(
        title: 'World Cuisine Cooking Class',
        venue: 'Global Kitchen',
        imagePath: 'assets/images/new_home/hotpic2.png',
        rating: 4.8,
        reviewCount: '2.2k reviews',
        tag: 'Cooking',
        description: 'Cook dishes from 4 different cuisines in one session.',
        eventDate: 'Sun, 27 Apr 2026',
        price: 1800,
      ),
      const EventModel(
        title: 'Pastry Arts Masterclass',
        venue: 'La Patisserie',
        imagePath: 'assets/images/new_home/hotpic3.png',
        rating: 4.9,
        reviewCount: '1.9k reviews',
        tag: 'Pastry',
        description: 'Tarts, éclairs and French pastry fundamentals.',
        eventDate: 'Sat, 03 May 2026',
        price: 2200,
      ),
      const EventModel(
        title: 'Food Science for Kids',
        venue: 'Kitchen Lab',
        imagePath: 'assets/images/new_home/hotpic4.png',
        rating: 4.7,
        reviewCount: '1.1k reviews',
        tag: 'Food Science',
        description: 'The chemistry and science behind cooking and baking.',
        eventDate: 'Sun, 04 May 2026',
        price: 1200,
      ),
    ],
    // 10: Grooming & Personality Dev
    [
      const EventModel(
        title: 'Social Etiquette for Teens',
        venue: 'The Poise Academy',
        imagePath: 'assets/images/new_home/weekendspl1.png',
        rating: 4.8,
        reviewCount: '1.8k reviews',
        tag: 'Etiquette',
        description: 'Table manners, networking and social confidence.',
        eventDate: 'Sat, 26 Apr 2026',
        price: 1500,
      ),
      const EventModel(
        title: 'Confidence Building Workshop',
        venue: 'Inner Edge',
        imagePath: 'assets/images/new_home/weekendspl2.png',
        rating: 4.9,
        reviewCount: '2.5k reviews',
        tag: 'Confidence',
        description: 'Overcome fear, build self-belief and lead with presence.',
        eventDate: 'Sun, 27 Apr 2026',
        price: 1200,
      ),
      const EventModel(
        title: 'Interview & Resume Workshop',
        venue: 'Career Launchpad',
        imagePath: 'assets/images/new_home/hotpics1.jpg',
        rating: 4.7,
        reviewCount: '1.4k reviews',
        tag: 'Interview',
        description: 'How to pitch yourself and ace any interview.',
        eventDate: 'Sat, 03 May 2026',
        price: 1500,
      ),
      const EventModel(
        title: 'Mindfulness & Stress Management',
        venue: 'Calm Minds Studio',
        imagePath: 'assets/images/new_home/hotpic2.png',
        rating: 4.8,
        reviewCount: '2.1k reviews',
        tag: 'Mindfulness',
        description: 'Breathing, journaling and focus techniques for teens.',
        eventDate: 'Sun, 04 May 2026',
        price: 900,
      ),
    ],
  ];

  // Fallbacks to keep app building if other files ref these
  static const List<EventModel> spotlightEvents = bannerEvents;
  static const List<EventModel> bestForWeek = hotPicks;
  static const List<EventModel> nearYouEvents = discoverNearYou;
  static const List<EventModel> trendingNow = weekendSpecial;
  static const List<EventModel> kidsFavorites = weekendSpecial;
  static const List<EventModel> featuredEvents = hotPicks;
}
