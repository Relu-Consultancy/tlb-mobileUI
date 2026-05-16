import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/api_review_model.dart';
import '../providers/auth_state.dart';
import '../providers/user_reviews_state.dart';
import '../services/review_service.dart';

// ── Public entry points ───────────────────────────────────────────────────────

/// Opens the read-all-reviews sheet, with a "Write a Review" button if logged in.
Future<void> showReviewSheet(
  BuildContext context, {
  required String listingId,
  required String listingTitle,
  required String? listingImage,
}) async {
  await showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (_) => _ReviewListSheet(
      listingId: listingId,
      listingTitle: listingTitle,
      listingImage: listingImage,
    ),
  );
}

/// Opens the write/edit review sheet directly.
Future<void> showWriteReviewSheet(
  BuildContext context, {
  required String listingId,
  required String listingTitle,
  required String? listingImage,
  ApiReview? existing, // non-null = edit mode
}) async {
  if (AuthState.accessToken == null) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Please log in to write a review.')),
    );
    return;
  }
  await showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (_) => _WriteReviewSheet(
      listingId: listingId,
      listingTitle: listingTitle,
      listingImage: listingImage,
      existing: existing,
    ),
  );
}

// ── Review List Sheet ─────────────────────────────────────────────────────────

class _ReviewListSheet extends StatefulWidget {
  final String listingId;
  final String listingTitle;
  final String? listingImage;
  const _ReviewListSheet({required this.listingId, required this.listingTitle, required this.listingImage});

  @override
  State<_ReviewListSheet> createState() => _ReviewListSheetState();
}

class _ReviewListSheetState extends State<_ReviewListSheet> {
  ApiReviewPage? _page;
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    try {
      final page = await ReviewService.fetchReviews(widget.listingId);
      if (!mounted) return;
      setState(() { _page = page; _loading = false; });
    } catch (e) {
      if (!mounted) return;
      setState(() { _error = e.toString().replaceFirst('Exception: ', ''); _loading = false; });
    }
  }

  @override
  Widget build(BuildContext context) {
    final reviews = _page?.reviews ?? [];
    final avg = _page?.averageRating ?? 0.0;
    final total = _page?.totalReviews ?? 0;

    return Container(
      constraints: BoxConstraints(maxHeight: MediaQuery.of(context).size.height * 0.85),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // ── Header ──
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Reviews', style: GoogleFonts.poppins(fontSize: 17, fontWeight: FontWeight.w700, color: const Color(0xFF1A1A2E))),
                Row(
                  children: [
                    if (AuthState.accessToken != null)
                      GestureDetector(
                        onTap: () async {
                          Navigator.pop(context);
                          await showWriteReviewSheet(
                            context,
                            listingId: widget.listingId,
                            listingTitle: widget.listingTitle,
                            listingImage: widget.listingImage,
                          );
                        },
                        child: Container(
                          padding: const EdgeInsets.all(6),
                          decoration: BoxDecoration(color: Colors.amber.shade100, shape: BoxShape.circle),
                          child: const Icon(Icons.edit, size: 20, color: Color(0xFFDE7104)),
                        ),
                      ),
                    const SizedBox(width: 8),
                    GestureDetector(
                      onTap: () => Navigator.pop(context),
                      child: Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(color: Colors.grey.shade200, shape: BoxShape.circle),
                        child: const Icon(Icons.close, size: 20, color: Color(0xFF1A1A2E)),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // ── Rating summary ──
          if (!_loading && _error == null)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Overall Rating: ${avg.toStringAsFixed(1)} ($total reviews)',
                    style: GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.w500, color: const Color(0xFF1A1A2E)),
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: List.generate(5, (i) {
                      if (i < avg.floor()) return const Icon(Icons.star, color: Colors.amber, size: 22);
                      if (i < avg && avg - i >= 0.5) return const Icon(Icons.star_half, color: Colors.amber, size: 22);
                      return const Icon(Icons.star_border, color: Colors.amber, size: 22);
                    }),
                  ),
                ],
              ),
            ),

          const SizedBox(height: 16),
          const Divider(height: 1),

          // ── Body ──
          if (_loading)
            const Padding(padding: EdgeInsets.all(40), child: CircularProgressIndicator(color: Color(0xFFFFCC00)))
          else if (_error != null)
            Padding(
              padding: const EdgeInsets.all(32),
              child: Text(_error!, style: GoogleFonts.poppins(fontSize: 13, color: Colors.red.shade400), textAlign: TextAlign.center),
            )
          else if (reviews.isEmpty)
            Padding(
              padding: const EdgeInsets.all(40),
              child: Text('No reviews yet. Be the first!', style: GoogleFonts.poppins(fontSize: 14, color: Colors.grey.shade500), textAlign: TextAlign.center),
            )
          else
            Flexible(
              child: ListView.separated(
                shrinkWrap: true,
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                itemCount: reviews.length,
                separatorBuilder: (_, __) => Divider(height: 24, color: Colors.grey.shade300),
                itemBuilder: (_, i) => _ReviewTile(review: reviews[i]),
              ),
            ),
        ],
      ),
    );
  }
}

class _ReviewTile extends StatelessWidget {
  final ApiReview review;
  const _ReviewTile({required this.review});

  @override
  Widget build(BuildContext context) {
    final months = ['Jan','Feb','Mar','Apr','May','Jun','Jul','Aug','Sep','Oct','Nov','Dec'];
    final d = review.createdAt;
    final dateStr = '${months[d.month - 1]} ${d.day}, ${d.year}';
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            CircleAvatar(
              radius: 16,
              backgroundColor: const Color(0xFFFFCC00),
              child: Text(
                review.customerName.isNotEmpty ? review.customerName[0].toUpperCase() : '?',
                style: GoogleFonts.poppins(fontSize: 13, fontWeight: FontWeight.w700, color: const Color(0xFF1A1A2E)),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(review.customerName, style: GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.w700, color: const Color(0xFF1A1A2E))),
                  Text(dateStr, style: GoogleFonts.poppins(fontSize: 11, color: Colors.grey.shade500)),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),
        Row(children: List.generate(5, (i) => Icon(i < review.rating ? Icons.star : Icons.star_border, color: Colors.amber, size: 18))),
        const SizedBox(height: 6),
        Text('"${review.comment}"', style: GoogleFonts.poppins(fontSize: 13, color: Colors.grey.shade700, height: 1.4)),
      ],
    );
  }
}

// ── Write / Edit Review Sheet ─────────────────────────────────────────────────

class _WriteReviewSheet extends StatefulWidget {
  final String listingId;
  final String listingTitle;
  final String? listingImage;
  final ApiReview? existing;

  const _WriteReviewSheet({
    required this.listingId,
    required this.listingTitle,
    required this.listingImage,
    this.existing,
  });

  @override
  State<_WriteReviewSheet> createState() => _WriteReviewSheetState();
}

class _WriteReviewSheetState extends State<_WriteReviewSheet> {
  late int _rating;
  late TextEditingController _controller;
  bool _submitting = false;

  bool get _isEdit => widget.existing != null;

  @override
  void initState() {
    super.initState();
    _rating = widget.existing?.rating ?? 5;
    _controller = TextEditingController(text: widget.existing?.comment ?? '');
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final text = _controller.text.trim();
    if (text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please write a review first.')));
      return;
    }
    setState(() => _submitting = true);
    try {
      final token = AuthState.accessToken!;
      ApiReview review;
      if (_isEdit) {
        review = await ReviewService.updateReview(token, widget.existing!.id, rating: _rating, comment: text);
        UserReviewsState.updateReview(review.id, {
          'rating': review.rating,
          'comment': review.comment,
        });
      } else {
        review = await ReviewService.createReview(token, widget.listingId, rating: _rating, comment: text);
        final now = DateTime.now();
        const months = ['Jan','Feb','Mar','Apr','May','Jun','Jul','Aug','Sep','Oct','Nov','Dec'];
        UserReviewsState.addReview({
          'reviewId': review.id,
          'listingId': widget.listingId,
          'eventName': widget.listingTitle,
          'image': widget.listingImage ?? '',
          'rating': review.rating,
          'date': '${months[now.month - 1]} ${now.day}, ${now.year}',
          'text': review.comment,
        });
      }
      if (!mounted) return;
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(_isEdit ? 'Review updated!' : 'Review submitted!')),
      );
    } catch (e) {
      if (!mounted) return;
      setState(() => _submitting = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString().replaceFirst('Exception: ', ''))),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      child: Container(
        decoration: const BoxDecoration(color: Colors.white, borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // ── Header ──
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    _isEdit ? 'Edit Review' : 'Write a Review',
                    style: GoogleFonts.poppins(fontSize: 17, fontWeight: FontWeight.w700, color: const Color(0xFF1A1A2E)),
                  ),
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(color: Colors.grey.shade200, shape: BoxShape.circle),
                      child: const Icon(Icons.close, size: 20, color: Color(0xFF1A1A2E)),
                    ),
                  ),
                ],
              ),
            ),
            const Divider(height: 1),
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Tap to Rate:', style: GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.w600, color: const Color(0xFF1A1A2E))),
                  const SizedBox(height: 8),
                  Row(
                    children: List.generate(5, (i) => GestureDetector(
                      onTap: () => setState(() => _rating = i + 1),
                      child: Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: Icon(i < _rating ? Icons.star : Icons.star_border, color: Colors.amber, size: 32),
                      ),
                    )),
                  ),
                  const SizedBox(height: 20),
                  Text('Your Review:', style: GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.w600, color: const Color(0xFF1A1A2E))),
                  const SizedBox(height: 8),
                  TextField(
                    controller: _controller,
                    maxLines: 4,
                    decoration: InputDecoration(
                      hintText: 'Share your experience...',
                      hintStyle: GoogleFonts.poppins(fontSize: 13, color: Colors.grey.shade400),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.grey.shade300)),
                      enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.grey.shade300)),
                      focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFFFFCC00))),
                      filled: true,
                      fillColor: const Color(0xFFF8F9FA),
                    ),
                  ),
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: ElevatedButton(
                      onPressed: _submitting ? null : _submit,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFFFCC00),
                        foregroundColor: const Color(0xFF1A1A2E),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
                        elevation: 0,
                      ),
                      child: _submitting
                          ? const SizedBox(width: 22, height: 22, child: CircularProgressIndicator(strokeWidth: 2, color: Color(0xFF1A1A2E)))
                          : Text(_isEdit ? 'Update Review' : 'Submit Review', style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.w600)),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
