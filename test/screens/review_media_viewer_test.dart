import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail_image_network/mocktail_image_network.dart';
import 'package:tlb_mobile_ui/models/api_review_model.dart';
import 'package:tlb_mobile_ui/screens/review_media_viewer.dart';

import '../helpers/test_setup.dart';

/// Bug report: a video attached to a review posted fine but could never be
/// opened or played — the thumbnail was a static play icon with no action,
/// and the API's http:// media URL is refused by Android anyway.
void main() {
  group('ApiReviewMedia', () {
    test('TC_M_RM_001 — media URLs are upgraded to https', () {
      final m = ApiReviewMedia.fromJson({
        'id': 1,
        'media_type': 'video',
        'file': 'http://tlb-api.reluconsultancy.in/media/reviews/clip.mp4',
      });
      expect(m.file,
          'https://tlb-api.reluconsultancy.in/media/reviews/clip.mp4');
      expect(m.isVideo, isTrue);
    });

    test('TC_M_RM_002 — a photo is not a video', () {
      final m = ApiReviewMedia.fromJson(
          {'id': 2, 'media_type': 'image', 'file': 'https://x/y.jpg'});
      expect(m.isVideo, isFalse);
    });
  });

  group('ReviewMediaViewer', () {
    const photo = ApiReviewMedia(
        id: 1, mediaType: 'image', file: 'https://x/photo.jpg');
    const video = ApiReviewMedia(
        id: 2, mediaType: 'video', file: 'https://x/clip.mp4');

    testWidgets('TC_W_RM_003 — opens on the tapped item, with a counter',
        (tester) async {
      await mockNetworkImages(() async {
        await pumpTLBApp(
          tester,
          const ReviewMediaViewer(media: [photo, video], initialIndex: 0),
        );
        await tester.pump();
      });
      expect(find.text('1 / 2'), findsOneWidget);
      expect(find.byType(InteractiveViewer), findsOneWidget,
          reason: 'photos can be pinch-zoomed');
    });

    testWidgets(
        'TC_W_RM_004 — a video that cannot play here says so and offers '
        'another app, instead of doing nothing', (tester) async {
      // No video backend in widget tests, so initialise fails — the same path
      // a codec the device can't decode would take.
      await pumpTLBApp(
        tester,
        const ReviewMediaViewer(media: [video], initialIndex: 0),
      );
      await tester.pumpAndSettle();

      expect(find.text("This video couldn't be played here."), findsOneWidget);
      expect(find.text('Open in another app'), findsOneWidget);
    });

    testWidgets('TC_W_RM_005 — close returns to the review', (tester) async {
      await mockNetworkImages(() async {
        await pumpTLBApp(
          tester,
          Builder(
            builder: (context) => Scaffold(
              body: TextButton(
                onPressed: () =>
                    ReviewMediaViewer.open(context, const [photo], 0),
                child: const Text('thumb'),
              ),
            ),
          ),
        );
        // Not pumpAndSettle: the photo's loading animation never settles
        // against the mocked network image.
        await tester.tap(find.text('thumb'));
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 500));
        expect(find.byType(ReviewMediaViewer), findsOneWidget);

        await tester.tap(find.byTooltip('Close'));
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 500));
        expect(find.byType(ReviewMediaViewer), findsNothing);
      });
    });
  });
}
