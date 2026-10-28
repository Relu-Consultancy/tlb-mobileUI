import 'package:flutter_test/flutter_test.dart';
import 'package:tlb_mobile_ui/models/api_venue_model.dart';
import 'package:tlb_mobile_ui/models/event_model.dart';
import 'package:tlb_mobile_ui/models/homepage_section_model.dart';

/// Bug report: listings with no reviews still showed a rating. A listing is
/// "rated" only when the API's average_rating is above 0.
void main() {
  EventModel e({double? rating}) =>
      EventModel(title: 't', venue: 'v', imagePath: '', rating: rating);

  test('TC_M_RD_001 — only a positive average counts as a rating', () {
    expect(e(rating: 4.3).hasRating, isTrue);
    expect(e(rating: 0).hasRating, isFalse);
    expect(e().hasRating, isFalse);
  });

  test('TC_M_RD_002 — feed cards drop "0 reviews"', () {
    HomepageListing listing(String total, String rating) =>
        HomepageListing.fromJson({
          'id': 'x',
          'title': 't',
          'listing_type': 'event',
          'rating': rating,
          'total_reviews': total,
        });

    final none = listing('0', '0.0').toEventModel();
    expect(none.reviewCount, isNull);
    expect(none.hasRating, isFalse);

    final some = listing('3', '4.3').toEventModel();
    expect(some.reviewCount, '3 reviews');
    expect(some.rating, 4.3);
  });

  test('TC_M_RD_003 — venues read the rating the API sends', () {
    final json = {
      'id': 'v',
      'title': 't',
      'city': 'Mumbai',
      'average_rating': 4.3,
      'total_reviews': 7,
    };
    final list = ApiVenue.fromJson(json);
    expect(list.averageRating, 4.3);
    expect(list.totalReviews, 7);

    final detail = ApiVenueDetail.fromJson(json);
    expect(detail.averageRating, 4.3);
    expect(detail.totalReviews, 7);

    // Absent fields mean unrated, not an error.
    expect(ApiVenue.fromJson({'id': 'v2'}).averageRating, 0);
  });
}
