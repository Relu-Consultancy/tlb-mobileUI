import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/api_review_model.dart';
import '../providers/auth_state.dart';
import '../providers/user_reviews_state.dart';
import '../services/review_service.dart';
import '../widgets/review_sheet.dart';

class YourReviewsScreen extends StatelessWidget {
  const YourReviewsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF2F2F7),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF2F2F7),
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF1A1A2E)),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Your Reviews',
          style: GoogleFonts.poppins(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: const Color(0xFF1A1A2E),
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      ValueListenableBuilder<String?>(
                        valueListenable: AuthState.userName,
                        builder: (context, _, __) => Text(
                          'Hi ${AuthState.firstName},',
                          style: GoogleFonts.poppins(fontSize: 22, fontWeight: FontWeight.w800, color: const Color(0xFF1A1A2E)),
                        ),
                      ),
                      Text(
                        'Here are your activities reviews.',
                        style: GoogleFonts.poppins(fontSize: 13, color: Colors.grey.shade500),
                      ),
                    ],
                  ),
                ),
                Image.asset(
                  'resources- tlb-ui/accounts_page/reviews.png',
                  width: 80,
                  errorBuilder: (_, __, ___) => const Icon(Icons.star, size: 64, color: Color(0xFFFFB902)),
                ),
              ],
            ),

            const SizedBox(height: 20),
            Text('Activities Review', style: GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.w700, color: const Color(0xFF1A1A2E))),
            const SizedBox(height: 10),

            ValueListenableBuilder<List<Map<String, dynamic>>>(
              valueListenable: UserReviewsState.reviewsNotifier,
              builder: (context, reviews, _) {
                if (reviews.isEmpty) {
                  return Center(
                    child: Padding(
                      padding: const EdgeInsets.only(top: 48),
                      child: Text('No reviews yet', style: GoogleFonts.poppins(fontSize: 15, color: Colors.grey.shade400)),
                    ),
                  );
                }
                return Column(children: reviews.map((r) => _ReviewCard(review: r)).toList());
              },
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}

class _ReviewCard extends StatelessWidget {
  final Map<String, dynamic> review;
  const _ReviewCard({required this.review});

  @override
  Widget build(BuildContext context) {
    final int rating = (review['rating'] as int?) ?? 0;
    final String image = (review['image'] as String?) ?? '';
    final bool isNetwork = image.startsWith('http');

    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 8, offset: const Offset(0, 2))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: isNetwork
                    ? Image.network(image, width: 70, height: 60, fit: BoxFit.cover, errorBuilder: (_, __, ___) => _fallback())
                    : image.isNotEmpty
                        ? Image.asset(image, width: 70, height: 60, fit: BoxFit.cover, errorBuilder: (_, __, ___) => _fallback())
                        : _fallback(),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            (review['eventName'] as String?) ?? '',
                            style: GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.w700, color: const Color(0xFF1A1A2E)),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const Icon(Icons.chevron_right, size: 18, color: Colors.grey),
                      ],
                    ),
                    const SizedBox(height: 3),
                    Row(
                      children: [
                        const Icon(Icons.calendar_month_outlined, size: 12, color: Colors.grey),
                        const SizedBox(width: 4),
                        Text((review['date'] as String?) ?? '', style: GoogleFonts.poppins(fontSize: 11, color: Colors.grey.shade500)),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: List.generate(5, (i) => Icon(
              i < rating ? Icons.star_rounded : Icons.star_outline_rounded,
              size: 20,
              color: i < rating ? const Color(0xFFFFB902) : Colors.grey.shade300,
            )),
          ),
          const SizedBox(height: 10),
          Text(
            '"${(review['text'] as String?) ?? ''}"',
            style: GoogleFonts.poppins(fontSize: 13, fontWeight: FontWeight.w600, color: const Color(0xFF1A1A2E), height: 1.1),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 2),
          Text(
            (review['text'] as String?) ?? '',
            style: GoogleFonts.poppins(fontSize: 12, color: Colors.grey.shade500, height: 1.5),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () => _edit(context),
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: Color(0xFFFFB902)),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22)),
                    padding: const EdgeInsets.symmetric(vertical: 10),
                  ),
                  child: Text('Edit Review', style: GoogleFonts.poppins(fontSize: 13, fontWeight: FontWeight.w600, color: const Color(0xFF1A1A2E))),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: OutlinedButton(
                  onPressed: () => _delete(context),
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: Color(0xFFFF6B6B)),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22)),
                    padding: const EdgeInsets.symmetric(vertical: 10),
                  ),
                  child: Text('Delete', style: GoogleFonts.poppins(fontSize: 13, fontWeight: FontWeight.w600, color: const Color(0xFFFF6B6B))),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _fallback() => Container(width: 70, height: 60, color: Colors.grey.shade200, child: const Icon(Icons.event, color: Colors.grey));

  Future<void> _edit(BuildContext context) async {
    final reviewId = review['reviewId'] as int?;
    final listingId = (review['listingId'] as String?) ?? '';
    if (reviewId == null || listingId.isEmpty || AuthState.accessToken == null) return;

    final existing = ApiReview(
      id: reviewId,
      customerId: AuthState.userData?['id'] as String? ?? '',
      customerName: AuthState.firstName,
      rating: (review['rating'] as int?) ?? 5,
      comment: (review['text'] as String?) ?? '',
      media: [],
      createdAt: DateTime.now(),
    );

    await showWriteReviewSheet(
      context,
      listingId: listingId,
      listingTitle: (review['eventName'] as String?) ?? '',
      listingImage: review['image'] as String?,
      existing: existing,
    );
  }

  Future<void> _delete(BuildContext context) async {
    final reviewId = review['reviewId'] as int?;
    if (reviewId == null || AuthState.accessToken == null) return;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: Text('Delete Review', style: GoogleFonts.poppins(fontWeight: FontWeight.w700)),
        content: Text('Are you sure you want to delete this review?', style: GoogleFonts.poppins(fontSize: 14)),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')),
          TextButton(onPressed: () => Navigator.pop(context, true), child: const Text('Delete', style: TextStyle(color: Color(0xFFFF6B6B)))),
        ],
      ),
    );
    if (confirmed != true) return;

    try {
      await ReviewService.deleteReview(AuthState.accessToken!, reviewId);
      UserReviewsState.removeReview(reviewId);
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString().replaceFirst('Exception: ', ''))));
      }
    }
  }
}
