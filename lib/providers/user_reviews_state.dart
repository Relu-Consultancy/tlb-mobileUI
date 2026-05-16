import 'package:flutter/foundation.dart';

class UserReviewsState {
  static final ValueNotifier<List<Map<String, dynamic>>> reviewsNotifier = ValueNotifier([]);

  static void addReview(Map<String, dynamic> review) {
    reviewsNotifier.value = [review, ...reviewsNotifier.value];
  }

  static void updateReview(int reviewId, Map<String, dynamic> changes) {
    reviewsNotifier.value = reviewsNotifier.value.map((r) {
      if (r['reviewId'] == reviewId) return {...r, ...changes};
      return r;
    }).toList();
  }

  static void removeReview(int reviewId) {
    reviewsNotifier.value = reviewsNotifier.value.where((r) => r['reviewId'] != reviewId).toList();
  }

  static void clear() {
    reviewsNotifier.value = [];
  }
}
