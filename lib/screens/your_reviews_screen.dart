import 'package:flutter/material.dart';
import '../core/app_snackbar.dart';
import '../core/responsive.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/api_review_model.dart';
import '../providers/auth_state.dart';
import '../providers/user_reviews_state.dart';
import '../services/review_service.dart';
import '../widgets/app_loader.dart';
import '../widgets/review_sheet.dart';

class YourReviewsScreen extends StatefulWidget {
  const YourReviewsScreen({super.key});

  @override
  State<YourReviewsScreen> createState() => _YourReviewsScreenState();
}

class _YourReviewsScreenState extends State<YourReviewsScreen> {
  bool _loading = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() { _loading = true; _error = null; });
    try {
      await UserReviewsState.loadFromApi();
    } catch (e) {
      if (mounted) setState(() => _error = 'Failed to load reviews.');
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

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
          style: GoogleFonts.poppins(fontSize: Responsive.sp(context, 18), fontWeight: FontWeight.w700, color: const Color(0xFF1A1A2E)),
        ),
      ),
      body: RefreshIndicator(
        onRefresh: _load,
        color: const Color(0xFFFFB902),
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── Header ──
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        ValueListenableBuilder<String?>(
                          valueListenable: AuthState.userName,
                          builder: (_, __, ___) => Text(
                            'Hi ${AuthState.firstName},',
                            style: GoogleFonts.poppins(
                              fontSize: Responsive.sp(context, 22), fontWeight: FontWeight.w800, color: const Color(0xFF1A1A2E),
                            ),
                          ),
                        ),
                        Text(
                          'Here are your activities reviews.',
                          style: GoogleFonts.poppins(fontSize: Responsive.sp(context, 13), color: Colors.grey.shade500),
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
              Text('Activities Review',
                  style: GoogleFonts.poppins(fontSize: Responsive.sp(context, 14), fontWeight: FontWeight.w700, color: const Color(0xFF1A1A2E))),
              const SizedBox(height: 10),

              // ── Content ──
              if (_loading)
                const Padding(
                  padding: EdgeInsets.only(top: 48),
                  child: Center(child: AppLoaderInline()),
                )
              else if (_error != null)
                Padding(
                  padding: const EdgeInsets.only(top: 48),
                  child: Center(
                    child: Column(
                      children: [
                        Text(_error!, style: GoogleFonts.poppins(fontSize: Responsive.sp(context, 14), color: Colors.grey.shade500)),
                        const SizedBox(height: 12),
                        TextButton(
                          onPressed: _load,
                          child: Text('Retry', style: GoogleFonts.poppins(color: const Color(0xFFFFB902), fontWeight: FontWeight.w600)),
                        ),
                      ],
                    ),
                  ),
                )
              else
                ValueListenableBuilder<List<ApiReview>>(
                  valueListenable: UserReviewsState.reviewsNotifier,
                  builder: (context, reviews, _) {
                    if (reviews.isEmpty) {
                      return Padding(
                        padding: const EdgeInsets.only(top: 48),
                        child: Center(
                          child: Text('No reviews yet',
                              style: GoogleFonts.poppins(fontSize: Responsive.sp(context, 15), color: Colors.grey.shade400)),
                        ),
                      );
                    }
                    return Column(
                      children: reviews.map((r) => _ReviewCard(review: r, onRefresh: _load)).toList(),
                    );
                  },
                ),

              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}

class _ReviewCard extends StatelessWidget {
  final ApiReview review;
  final VoidCallback onRefresh;

  const _ReviewCard({required this.review, required this.onRefresh});

  @override
  Widget build(BuildContext context) {
    final hasImage = (review.listingImage ?? '').isNotEmpty;
    final title = review.listingTitle ?? 'Review #${review.id}';
    final dateStr = _formatDate(review.createdAt);

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
          // ── Listing header ──
          Row(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: hasImage
                    ? Image.network(
                        review.listingImage!,
                        width: 70, height: 60, fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => _fallback(),
                      )
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
                            title,
                            style: GoogleFonts.poppins(
                              fontSize: Responsive.sp(context, 14), fontWeight: FontWeight.w700, color: const Color(0xFF1A1A2E),
                            ),
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
                        Text(dateStr, style: GoogleFonts.poppins(fontSize: Responsive.sp(context, 11), color: Colors.grey.shade500)),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 12),

          // ── Stars ──
          Row(
            children: List.generate(5, (i) => Icon(
              i < review.rating ? Icons.star_rounded : Icons.star_outline_rounded,
              size: 20,
              color: i < review.rating ? const Color(0xFFFFB902) : Colors.grey.shade300,
            )),
          ),

          // ── Comment ──
          if (review.comment.isNotEmpty) ...[
            const SizedBox(height: 10),
            Text(
              '"${review.comment}"',
              style: GoogleFonts.poppins(
                fontSize: Responsive.sp(context, 13), fontWeight: FontWeight.w600, color: const Color(0xFF1A1A2E), height: 1.4,
              ),
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
            ),
          ],

          // ── Media thumbnails ──
          if (review.media.isNotEmpty) ...[
            const SizedBox(height: 10),
            SizedBox(
              height: 64,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: review.media.length,
                separatorBuilder: (_, __) => const SizedBox(width: 6),
                itemBuilder: (_, i) {
                  final m = review.media[i];
                  return ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: m.mediaType == 'video'
                        ? Container(
                            width: 64, height: 64,
                            color: Colors.grey.shade800,
                            child: const Center(child: Icon(Icons.play_circle_fill, color: Colors.white, size: 24)),
                          )
                        : Image.network(m.file, width: 64, height: 64, fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) => Container(
                              width: 64, height: 64,
                              color: Colors.grey.shade200,
                              child: const Icon(Icons.image_not_supported, size: 20, color: Colors.grey),
                            )),
                  );
                },
              ),
            ),
          ],

          const SizedBox(height: 14),

          // ── Actions ──
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
                  child: Text('Edit Review',
                      style: GoogleFonts.poppins(fontSize: Responsive.sp(context, 13), fontWeight: FontWeight.w600, color: const Color(0xFF1A1A2E))),
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
                  child: Text('Delete',
                      style: GoogleFonts.poppins(fontSize: Responsive.sp(context, 13), fontWeight: FontWeight.w600, color: const Color(0xFFFF6B6B))),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _fallback() => Container(
        width: 70, height: 60,
        decoration: BoxDecoration(color: Colors.grey.shade200, borderRadius: BorderRadius.circular(10)),
        child: const Icon(Icons.event, color: Colors.grey),
      );

  String _formatDate(DateTime d) {
    const months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    return '${months[d.month - 1]} ${d.day}, ${d.year}';
  }

  Future<void> _edit(BuildContext context) async {
    final listingId = review.listingId ?? '';
    if (listingId.isEmpty || AuthState.accessToken == null) return;
    await showWriteReviewSheet(
      context,
      listingId: listingId,
      listingTitle: review.listingTitle ?? '',
      listingImage: review.listingImage,
      existing: review,
    );
  }

  Future<void> _delete(BuildContext context) async {
    if (AuthState.accessToken == null) return;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: Text('Delete Review', style: GoogleFonts.poppins(fontWeight: FontWeight.w700)),
        content: Text('Are you sure you want to delete this review?', style: GoogleFonts.poppins(fontSize: Responsive.sp(context, 14))),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Delete', style: TextStyle(color: Color(0xFFFF6B6B))),
          ),
        ],
      ),
    );
    if (confirmed != true) return;

    try {
      await ReviewService.deleteReview(AuthState.accessToken!, review.id);
      await UserReviewsState.remove(review.id);
    } catch (e) {
      if (context.mounted) {
        AppSnackBar.error(context, e.toString().replaceFirst('Exception: ', ''));
      }
    }
  }
}
