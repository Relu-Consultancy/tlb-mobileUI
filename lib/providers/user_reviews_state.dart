import 'package:flutter/foundation.dart';

class UserReviewsState {
  static final UserReviewsState _instance = UserReviewsState._internal();
  factory UserReviewsState() => _instance;
  UserReviewsState._internal();

  final ValueNotifier<List<Map<String, dynamic>>> reviewsNotifier = ValueNotifier([
    {
      'eventName': 'Halloween Party 2025',
      'image': 'assets/images/halloween_party.png',
      'rating': 5,
      'date': 'Feb 28, 2025',
      'text':
          'Absolutely amazing event! The decorations were top-notch and my kids had a blast. The storytelling session was the highlight. Would definitely recommend!',
      'helpful': 12,
    },
    {
      'eventName': 'World Storytelling Day',
      'image': 'assets/images/story_telling.png',
      'rating': 4,
      'date': 'Feb 20, 2025',
      'text':
          'Great event with wonderful storytellers. The venue was a bit crowded but the overall experience was really enjoyable. Kids loved every minute of it.',
      'helpful': 8,
    },
    {
      'eventName': 'Art & Craft Workshop',
      'image': 'assets/images/kids_party.png',
      'rating': 5,
      'date': 'Feb 15, 2025',
      'text':
          'Such a creative and fun workshop! The instructors were patient and encouraging. My daughter made a beautiful painting that we framed at home.',
      'helpful': 15,
    },
    {
      'eventName': 'Summer Dance Camp',
      'image': 'assets/images/story_telling.png',
      'rating': 3,
      'date': 'Feb 10, 2025',
      'text':
          'The dance camp was okay. The choreography was interesting but the session felt a bit short. Would have liked more time for practice.',
      'helpful': 3,
    },
  ]);

  void addReview(Map<String, dynamic> review) {
    reviewsNotifier.value = [review, ...reviewsNotifier.value];
  }
}
