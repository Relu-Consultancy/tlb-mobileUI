import 'dart:io';
import 'package:flutter/material.dart';
import '../core/app_snackbar.dart';
import '../core/responsive.dart';
import 'app_dialog.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import '../core/app_colors.dart';
import '../models/api_review_model.dart';
import '../providers/auth_state.dart';
import '../providers/user_reviews_state.dart';
import '../services/review_service.dart';
import 'app_loader.dart';
import 'login_sheet.dart';

// ── Public entry points ───────────────────────────────────────────────────────

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

/// Opens the write/edit sheet. Requires auth — callers that don't know auth state
/// should use [_openWriteReviewWithGuard] via [buildReviewInlineSection].
Future<void> showWriteReviewSheet(
  BuildContext context, {
  required String listingId,
  required String listingTitle,
  required String? listingImage,
  ApiReview? existing,
}) async {
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

/// Guard-wrapped tap handler for the inline "Write a Review" button.
/// Non-logged-in users are sent to the login screen.
Future<void> _openWriteReviewWithGuard(
  BuildContext context, {
  required String listingId,
  required String listingTitle,
  String? listingImage,
  VoidCallback? onRefresh,
}) async {
  if (AuthState.accessToken == null) {
    showLoginSheet(context);
    return;
  }
  await showWriteReviewSheet(
    context,
    listingId: listingId,
    listingTitle: listingTitle,
    listingImage: listingImage,
  );
  onRefresh?.call();
}

// ── Inline section displayed inside detail screens ────────────────────────────

Widget buildReviewInlineSection(
  BuildContext context, {
  required String listingId,
  required String listingTitle,
  String? listingImage,
  ApiReviewPage? reviewPage,
  bool isLoading = false,
  VoidCallback? onRefresh,
}) {
  final reviews = reviewPage?.reviews ?? [];
  final avg = reviewPage?.averageRating ?? 0.0;
  final total = reviewPage?.totalReviews ?? 0;

  // Shared "Write a Review" button shown regardless of auth state.
  Widget writeButton() => GestureDetector(
    onTap: () => _openWriteReviewWithGuard(
      context,
      listingId: listingId,
      listingTitle: listingTitle,
      listingImage: listingImage,
      onRefresh: onRefresh,
    ),
    child: Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 12),
      decoration: BoxDecoration(
        color: Colors.amber.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.amber.shade200),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.edit_outlined, color: Color(0xFFDE7104), size: 18),
          const SizedBox(width: 8),
          Text(
            'Write a Review',
            style: GoogleFonts.poppins(fontSize: Responsive.sp(context, 14), fontWeight: FontWeight.w500, color: const Color(0xFFDE7104)),
          ),
        ],
      ),
    ),
  );

  // White card with a slim black border wrapping the whole reviews block,
  // matching the reference: bold "Reviews", an "Overall Rating" line, then the
  // reviewer tiles.
  return Padding(
    padding: const EdgeInsets.symmetric(horizontal: 16),
    child: Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0x14000000), width: 0.7),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Reviews', style: GoogleFonts.poppins(fontSize: Responsive.sp(context, 17), fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
              GestureDetector(
                onTap: () async {
                  await showReviewSheet(context, listingId: listingId, listingTitle: listingTitle, listingImage: listingImage);
                  onRefresh?.call();
                },
                child: Row(
                  children: [
                    Text('See All', style: GoogleFonts.poppins(fontSize: Responsive.sp(context, 13), fontWeight: FontWeight.w500, color: AppColors.seeAllBlue)),
                    const Icon(Icons.chevron_right, size: 18, color: AppColors.seeAllBlue),
                  ],
                ),
              ),
            ],
          ),

          if (isLoading) ...[
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 20),
              child: Center(child: AppLoaderInline()),
            ),
          ] else if (total > 0) ...[
            const SizedBox(height: 6),
            // Overall rating line
            Row(
              children: [
                Text(
                  'Overall Rating: ${avg.toStringAsFixed(1)}',
                  style: GoogleFonts.poppins(fontSize: Responsive.sp(context, 13.5), fontWeight: FontWeight.w500, color: AppColors.textPrimary),
                ),
                const SizedBox(width: 4),
                const Icon(Icons.star, color: Colors.amber, size: 16),
              ],
            ),
            const SizedBox(height: 14),

            // Preview reviews (up to 3)
            ...reviews.take(3).toList().asMap().entries.map((entry) {
              final i = entry.key;
              final r = entry.value;
              final isOwner = AuthState.userId != null && AuthState.userId == r.customerId;
              return Column(
                children: [
                  if (i > 0)
                    Divider(height: 24, color: Colors.grey.shade200),
                  _ReviewTile(
                    review: r,
                    onEdit: isOwner
                        ? () async {
                            await showWriteReviewSheet(
                              context,
                              listingId: listingId,
                              listingTitle: listingTitle,
                              listingImage: listingImage,
                              existing: r,
                            );
                            onRefresh?.call();
                          }
                        : null,
                    onDelete: isOwner
                        ? () => _confirmDeleteReview(context, r, onRefresh)
                        : null,
                  ),
                ],
              );
            }),

            const SizedBox(height: 14),
            writeButton(),
          ] else ...[
            const SizedBox(height: 10),
            Text(
              'No reviews yet — be the first!',
              style: GoogleFonts.poppins(fontSize: Responsive.sp(context, 13), color: Colors.grey.shade500),
            ),
            const SizedBox(height: 12),
            writeButton(),
          ],
        ],
      ),
    ),
  );
}

// ── Delete helper (shared by inline section and list sheet) ──────────────────

Future<void> _confirmDeleteReview(
  BuildContext context,
  ApiReview review,
  VoidCallback? onSuccess,
) async {
  final confirmed = await showAppConfirmDialog(
    context,
    title: 'Delete Review',
    message: 'Are you sure you want to delete this review?',
    confirmLabel: 'Delete',
    icon: Icons.delete_outline_rounded,
    destructive: true,
  );
  if (!confirmed) return;
  final token = AuthState.accessToken;
  if (token == null) return;
  try {
    await ReviewService.deleteReview(token, review.id);
    await UserReviewsState.remove(review.id);
    if (context.mounted) {
      AppSnackBar.success(context, 'Review deleted.');
      onSuccess?.call();
    }
  } catch (e) {
    if (context.mounted) {
      AppSnackBar.error(context, e.toString().replaceFirst('Exception: ', ''));
    }
  }
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
  final List<ApiReview> _allReviews = [];
  double _avgRating = 0;
  int _totalReviews = 0;
  Map<String, int> _breakdown = {};

  int _currentPage = 1;
  bool _hasNext = false;
  bool _loading = true;
  bool _loadingMore = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _load(page: 1, reset: true);
  }

  Future<void> _load({required int page, bool reset = false}) async {
    if (reset) setState(() { _loading = true; _error = null; });
    try {
      final result = await ReviewService.fetchReviews(widget.listingId, page: page);
      if (!mounted) return;
      setState(() {
        if (reset) {
          _allReviews.clear();
          _avgRating = result.averageRating;
          _totalReviews = result.totalReviews;
          _breakdown = result.ratingBreakdown;
        }
        _allReviews.addAll(result.reviews);
        _currentPage = page;
        _hasNext = result.hasNext;
        _loading = false;
        _loadingMore = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = e.toString().replaceFirst('Exception: ', '');
        _loading = false;
        _loadingMore = false;
      });
    }
  }

  Future<void> _loadMore() async {
    if (_loadingMore || !_hasNext) return;
    setState(() => _loadingMore = true);
    await _load(page: _currentPage + 1);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: BoxConstraints(maxHeight: MediaQuery.of(context).size.height * 0.88),
      decoration: const BoxDecoration(color: Colors.white, borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(height: 8),
          Center(child: Container(width: 40, height: 4, decoration: BoxDecoration(color: Colors.grey.shade300, borderRadius: BorderRadius.circular(2)))),

          // ── Header ──
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Reviews', style: GoogleFonts.poppins(fontSize: Responsive.sp(context, 17), fontWeight: FontWeight.w500, color: AppColors.textPrimary)),
                Row(
                  children: [
                    // Write / Edit button — visible to all; login guard inside
                    GestureDetector(
                      onTap: () async {
                        Navigator.pop(context);
                        await _openWriteReviewWithGuard(
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
                        child: const Icon(Icons.close, size: 20, color: AppColors.textPrimary),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const Divider(height: 1),

          if (_loading)
            const Padding(padding: EdgeInsets.all(40), child: AppLoader())
          else if (_error != null)
            Padding(
              padding: const EdgeInsets.all(32),
              child: Text(_error!, style: GoogleFonts.poppins(fontSize: Responsive.sp(context, 13), color: Colors.red.shade400), textAlign: TextAlign.center),
            )
          else
            Flexible(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // ── Rating summary ──
                    if (_totalReviews > 0) ...[
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Column(
                            children: [
                              Text(_avgRating.toStringAsFixed(1), style: GoogleFonts.poppins(fontSize: Responsive.sp(context, 36), fontWeight: FontWeight.w500, color: AppColors.textPrimary)),
                              Row(
                                children: List.generate(5, (i) {
                                  if (i < _avgRating.floor()) return const Icon(Icons.star, color: Colors.amber, size: 18);
                                  if (_avgRating - i >= 0.5) return const Icon(Icons.star_half, color: Colors.amber, size: 18);
                                  return const Icon(Icons.star_border, color: Colors.amber, size: 18);
                                }),
                              ),
                              const SizedBox(height: 4),
                              Text('$_totalReviews review${_totalReviews == 1 ? '' : 's'}', style: GoogleFonts.poppins(fontSize: Responsive.sp(context, 12), color: Colors.grey.shade500)),
                            ],
                          ),
                          const SizedBox(width: 20),
                          Expanded(
                            child: Column(
                              children: [5, 4, 3, 2, 1].map((star) {
                                final count = _breakdown['$star'] ?? 0;
                                final frac = _totalReviews > 0 ? (count / _totalReviews).clamp(0.0, 1.0) : 0.0;
                                return Padding(
                                  padding: const EdgeInsets.symmetric(vertical: 3),
                                  child: Row(
                                    children: [
                                      Text('$star', style: GoogleFonts.poppins(fontSize: Responsive.sp(context, 12), color: Colors.grey.shade600)),
                                      const SizedBox(width: 2),
                                      const Icon(Icons.star, size: 12, color: Colors.amber),
                                      const SizedBox(width: 6),
                                      Expanded(
                                        child: ClipRRect(
                                          borderRadius: BorderRadius.circular(4),
                                          child: LinearProgressIndicator(
                                            value: frac,
                                            backgroundColor: Colors.grey.shade200,
                                            valueColor: const AlwaysStoppedAnimation(Colors.amber),
                                            minHeight: 7,
                                          ),
                                        ),
                                      ),
                                      const SizedBox(width: 6),
                                      SizedBox(width: 22, child: Text('$count', style: GoogleFonts.poppins(fontSize: Responsive.sp(context, 12), color: Colors.grey.shade500), textAlign: TextAlign.end)),
                                    ],
                                  ),
                                );
                              }).toList(),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Divider(color: Colors.grey.shade200),
                      const SizedBox(height: 8),
                    ],

                    if (_allReviews.isEmpty)
                      Center(
                        child: Padding(
                          padding: const EdgeInsets.all(32),
                          child: Text('No reviews yet. Be the first!', style: GoogleFonts.poppins(fontSize: Responsive.sp(context, 14), color: Colors.grey.shade500), textAlign: TextAlign.center),
                        ),
                      )
                    else ...[
                      ...List.generate(_allReviews.length, (i) {
                        final r = _allReviews[i];
                        final isOwner = AuthState.userId != null && AuthState.userId == r.customerId;
                        return Column(
                          children: [
                            _ReviewTile(
                              review: r,
                              onEdit: isOwner
                                  ? () async {
                                      Navigator.pop(context);
                                      await showWriteReviewSheet(
                                        context,
                                        listingId: widget.listingId,
                                        listingTitle: widget.listingTitle,
                                        listingImage: widget.listingImage,
                                        existing: r,
                                      );
                                    }
                                  : null,
                              onDelete: isOwner
                                  ? () => _confirmDeleteReview(context, r, () {
                                        if (mounted) {
                                          setState(() {
                                            _allReviews.removeAt(i);
                                            _totalReviews = (_totalReviews - 1).clamp(0, _totalReviews);
                                          });
                                        }
                                      })
                                  : null,
                            ),
                            if (i < _allReviews.length - 1) ...[
                              const SizedBox(height: 4),
                              Divider(height: 20, color: Colors.grey.shade200),
                            ],
                          ],
                        );
                      }),
                      if (_hasNext) ...[
                        const SizedBox(height: 16),
                        Center(
                          child: _loadingMore
                              ? const AppLoaderInline()
                              : GestureDetector(
                                  onTap: _loadMore,
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
                                    decoration: BoxDecoration(border: Border.all(color: Colors.grey.shade300), borderRadius: BorderRadius.circular(20)),
                                    child: Text('Load more', style: GoogleFonts.poppins(fontSize: Responsive.sp(context, 13), fontWeight: FontWeight.w500, color: AppColors.textPrimary)),
                                  ),
                                ),
                        ),
                      ],
                    ],
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}

// ── Review Tile ───────────────────────────────────────────────────────────────

class _ReviewTile extends StatelessWidget {
  final ApiReview review;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;
  const _ReviewTile({required this.review, this.onEdit, this.onDelete});

  @override
  Widget build(BuildContext context) {
    const months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    final d = review.createdAt;
    final dateStr = '${months[d.month - 1]} ${d.day}, ${d.year}';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            CircleAvatar(
              radius: 16,
              backgroundColor: AppColors.primaryLight,
              child: Text(
                review.customerName.isNotEmpty ? review.customerName[0].toUpperCase() : '?',
                style: GoogleFonts.poppins(fontSize: Responsive.sp(context, 13), fontWeight: FontWeight.w500, color: AppColors.textPrimary),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(review.customerName, style: GoogleFonts.poppins(fontSize: Responsive.sp(context, 14), fontWeight: FontWeight.w500, color: AppColors.textPrimary)),
                  Text(dateStr, style: GoogleFonts.poppins(fontSize: Responsive.sp(context, 11), color: Colors.grey.shade500)),
                ],
              ),
            ),
            if (onEdit != null)
              GestureDetector(
                onTap: onEdit,
                child: Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(color: Colors.amber.shade50, shape: BoxShape.circle),
                  child: const Icon(Icons.edit_outlined, size: 16, color: Color(0xFFDE7104)),
                ),
              ),
            if (onEdit != null && onDelete != null) const SizedBox(width: 6),
            if (onDelete != null)
              GestureDetector(
                onTap: onDelete,
                child: Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(color: Colors.red.shade50, shape: BoxShape.circle),
                  child: const Icon(Icons.delete_outline, size: 16, color: Color(0xFFFF6B6B)),
                ),
              ),
          ],
        ),
        const SizedBox(height: 6),
        Row(children: List.generate(5, (i) => Icon(i < review.rating ? Icons.star : Icons.star_border, color: Colors.amber, size: 16))),
        if (review.comment.isNotEmpty) ...[
          const SizedBox(height: 6),
          Text('"${review.comment}"', style: GoogleFonts.poppins(fontSize: Responsive.sp(context, 13), color: Colors.grey.shade700, height: 1.4)),
        ],
        if (review.media.isNotEmpty) ...[
          const SizedBox(height: 8),
          SizedBox(
            height: 72,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: review.media.length,
              itemBuilder: (_, i) {
                final m = review.media[i];
                final isVideo = m.mediaType == 'video';
                return Container(
                  width: 72, height: 72,
                  margin: const EdgeInsets.only(right: 8),
                  decoration: BoxDecoration(borderRadius: BorderRadius.circular(8), color: Colors.grey.shade200),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: isVideo
                        ? _videoPlaceholder()
                        : Image.network(m.file, fit: BoxFit.cover, errorBuilder: (_, __, ___) => const Icon(Icons.broken_image, color: Colors.grey)),
                  ),
                );
              },
            ),
          ),
        ],
      ],
    );
  }

  static Widget _videoPlaceholder() => Container(
    color: Colors.grey.shade800,
    child: const Center(child: Icon(Icons.play_circle_fill, color: Colors.white, size: 28)),
  );
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

  // Existing media (edit mode) — track which to remove
  late List<ApiReviewMedia> _existingMedia;
  final List<int> _removeMediaIds = [];

  // New media picked
  final List<XFile> _newImages = [];
  final List<XFile> _newVideos = [];

  // Auto-detect if user already reviewed this listing
  bool _checkingExisting = false;
  bool _isEditMode = false;   // set true when fetchMyReview finds an existing review
  int? _existingReviewId;

  bool _submitting = false;

  bool get _isEdit => widget.existing != null || _isEditMode;

  // Media already on server that are still kept (not marked for removal)
  List<ApiReviewMedia> get _activeExistingMedia =>
      _existingMedia.where((m) => !_removeMediaIds.contains(m.id)).toList();

  int get _existingImageCount => _activeExistingMedia.where((m) => m.mediaType != 'video').length;
  int get _existingVideoCount => _activeExistingMedia.where((m) => m.mediaType == 'video').length;
  int get _totalImageCount => _existingImageCount + _newImages.length;
  int get _totalVideoCount => _existingVideoCount + _newVideos.length;

  @override
  void initState() {
    super.initState();
    _rating = widget.existing?.rating ?? 5;
    _controller = TextEditingController(text: widget.existing?.comment ?? '');
    _existingMedia = List.from(widget.existing?.media ?? []);
    // If not already in edit mode, check whether this user has already reviewed
    if (widget.existing == null) _checkExistingReview();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  /// Silently fetches the user's own review for this listing.
  /// If found, pre-fills the form and switches to edit mode.
  Future<void> _checkExistingReview() async {
    if (AuthState.accessToken == null) return;
    setState(() => _checkingExisting = true);
    try {
      final mine = await ReviewService.fetchMyReview(AuthState.accessToken!, widget.listingId);
      if (mine != null && mounted) {
        setState(() {
          _isEditMode = true;
          _existingReviewId = mine.id;
          _rating = mine.rating;
          _controller.text = mine.comment;
          _existingMedia = List.from(mine.media);
        });
      }
    } catch (_) {
      // Silently ignore — assume no existing review
    } finally {
      if (mounted) setState(() => _checkingExisting = false);
    }
  }

  Future<void> _pickImages() async {
    final remaining = 5 - _totalImageCount;
    if (remaining <= 0) return;
    final images = await ImagePicker().pickMultiImage(limit: remaining);
    if (images.isNotEmpty && mounted) setState(() => _newImages.addAll(images));
  }

  Future<void> _pickVideo() async {
    if (_totalVideoCount >= 2) return;
    final video = await ImagePicker().pickVideo(source: ImageSource.gallery);
    if (video != null && mounted) setState(() => _newVideos.add(video));
  }

  Future<void> _submit() async {
    final token = AuthState.accessToken;
    if (token == null) {
      AppSnackBar.error(
          context, 'Your session has expired. Please log in again.');
      return;
    }
    setState(() => _submitting = true);
    try {
      final comment = _controller.text.trim();
      final imageFiles = _newImages.map((x) => File(x.path)).toList();
      final videoFiles = _newVideos.map((x) => File(x.path)).toList();
      ApiReview review;

      if (_isEdit) {
        final reviewId = widget.existing?.id ?? _existingReviewId!;
        review = await ReviewService.updateReview(
          token,
          reviewId,
          rating: _rating,
          comment: comment,
          newImages: imageFiles,
          newVideos: videoFiles,
          removeMediaIds: _removeMediaIds,
        );
      } else {
        review = await ReviewService.createReview(
          token,
          widget.listingId,
          rating: _rating,
          comment: comment,
          images: imageFiles,
          videos: videoFiles,
        );
      }
      // Preserve listing context so YourReviewsScreen can display title/image
      final existing = UserReviewsState.reviewsNotifier.value
          .where((r) => r.id == review.id)
          .firstOrNull;
      await UserReviewsState.upsert(review.copyWith(
        listingId: widget.listingId.isNotEmpty ? widget.listingId : existing?.listingId,
        listingTitle: widget.listingTitle.isNotEmpty ? widget.listingTitle : existing?.listingTitle,
        listingImage: widget.listingImage ?? existing?.listingImage,
      ));

      if (!mounted) return;
      Navigator.pop(context);
      AppSnackBar.success(context, _isEdit ? 'Review updated!' : 'Review submitted!');
    } catch (e) {
      if (!mounted) return;
      setState(() => _submitting = false);
      AppSnackBar.error(context, e.toString().replaceFirst('Exception: ', ''));
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
            const SizedBox(height: 8),
            Center(child: Container(width: 40, height: 4, decoration: BoxDecoration(color: Colors.grey.shade300, borderRadius: BorderRadius.circular(2)))),

            // ── Header ──
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    _checkingExisting
                        ? 'Loading...'
                        : (_isEdit ? 'Edit Your Review' : 'Write a Review'),
                    style: GoogleFonts.poppins(fontSize: Responsive.sp(context, 17), fontWeight: FontWeight.w500, color: AppColors.textPrimary),
                  ),
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(color: Colors.grey.shade200, shape: BoxShape.circle),
                      child: const Icon(Icons.close, size: 20, color: AppColors.textPrimary),
                    ),
                  ),
                ],
              ),
            ),
            const Divider(height: 1),

            // Show loader while checking existing review
            if (_checkingExisting)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 48),
                child: Center(child: AppLoaderInline()),
              )
            else
              SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // ── Edit mode banner ──
                    if (_isEditMode) ...[
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        margin: const EdgeInsets.only(bottom: 16),
                        decoration: BoxDecoration(color: Colors.blue.shade50, borderRadius: BorderRadius.circular(8), border: Border.all(color: Colors.blue.shade100)),
                        child: Row(
                          children: [
                            Icon(Icons.info_outline, size: 16, color: Colors.blue.shade600),
                            const SizedBox(width: 8),
                            Expanded(child: Text('You already reviewed this — editing your existing review.', style: GoogleFonts.poppins(fontSize: Responsive.sp(context, 12), color: Colors.blue.shade700))),
                          ],
                        ),
                      ),
                    ],

                    // ── Star picker ──
                    Text('Your Rating', style: GoogleFonts.poppins(fontSize: Responsive.sp(context, 14), fontWeight: FontWeight.w500, color: AppColors.textPrimary)),
                    const SizedBox(height: 8),
                    Row(
                      children: List.generate(5, (i) => GestureDetector(
                        onTap: () => setState(() => _rating = i + 1),
                        child: Padding(
                          padding: const EdgeInsets.only(right: 8),
                          child: Icon(i < _rating ? Icons.star : Icons.star_border, color: Colors.amber, size: 36),
                        ),
                      )),
                    ),

                    const SizedBox(height: 20),

                    // ── Comment ──
                    Text('Your Review (optional)', style: GoogleFonts.poppins(fontSize: Responsive.sp(context, 14), fontWeight: FontWeight.w500, color: AppColors.textPrimary)),
                    const SizedBox(height: 8),
                    TextField(
                      controller: _controller,
                      maxLines: 4,
                      decoration: InputDecoration(
                        hintText: 'Share your experience...',
                        hintStyle: GoogleFonts.poppins(fontSize: Responsive.sp(context, 13), color: Colors.grey.shade400),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.grey.shade300)),
                        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.grey.shade300)),
                        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AppColors.primaryLight)),
                        filled: true,
                        fillColor: AppColors.inputFill,
                      ),
                    ),

                    const SizedBox(height: 20),

                    // ── Photos ──
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Photos (optional)', style: GoogleFonts.poppins(fontSize: Responsive.sp(context, 14), fontWeight: FontWeight.w500, color: AppColors.textPrimary)),
                        Text('$_totalImageCount / 5', style: GoogleFonts.poppins(fontSize: Responsive.sp(context, 12), color: Colors.grey.shade500)),
                      ],
                    ),
                    const SizedBox(height: 8),
                    SizedBox(
                      height: 84,
                      child: ListView(
                        scrollDirection: Axis.horizontal,
                        children: [
                          ..._activeExistingMedia
                              .where((m) => m.mediaType != 'video')
                              .map((m) => _existingImageThumb(m)),
                          ..._newImages.asMap().entries.map((e) => _newImageThumb(e.key, e.value)),
                          if (_totalImageCount < 5)
                            _addButton(Icons.add_photo_alternate_outlined, _pickImages),
                        ],
                      ),
                    ),

                    const SizedBox(height: 16),

                    // ── Videos ──
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Videos (optional)', style: GoogleFonts.poppins(fontSize: Responsive.sp(context, 14), fontWeight: FontWeight.w500, color: AppColors.textPrimary)),
                        Text('$_totalVideoCount / 2', style: GoogleFonts.poppins(fontSize: Responsive.sp(context, 12), color: Colors.grey.shade500)),
                      ],
                    ),
                    const SizedBox(height: 8),
                    SizedBox(
                      height: 84,
                      child: ListView(
                        scrollDirection: Axis.horizontal,
                        children: [
                          ..._activeExistingMedia
                              .where((m) => m.mediaType == 'video')
                              .map((m) => _existingVideoThumb(m)),
                          ..._newVideos.asMap().entries.map((e) => _newVideoThumb(e.key, e.value)),
                          if (_totalVideoCount < 2)
                            _addButton(Icons.video_library_outlined, _pickVideo),
                        ],
                      ),
                    ),

                    const SizedBox(height: 24),

                    // ── Submit ──
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton(
                        onPressed: _submitting ? null : _submit,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primaryLight,
                          foregroundColor: AppColors.textPrimary,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
                          elevation: 0,
                        ),
                        child: _submitting
                            ? const AppLoaderInline()
                            : Text(
                                _isEdit ? 'Update Review' : 'Submit Review',
                                style: GoogleFonts.poppins(fontSize: Responsive.sp(context, 16), fontWeight: FontWeight.w500),
                              ),
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

  // ── Media thumb helpers ──

  Widget _addButton(IconData icon, VoidCallback onTap) => GestureDetector(
    onTap: onTap,
    child: Container(
      width: 80, height: 80,
      margin: const EdgeInsets.only(right: 8),
      decoration: BoxDecoration(color: Colors.grey.shade100, borderRadius: BorderRadius.circular(10), border: Border.all(color: Colors.grey.shade300)),
      child: Icon(icon, color: Colors.grey, size: 28),
    ),
  );

  Widget _existingImageThumb(ApiReviewMedia media) => _thumbWrap(
    onRemove: () => setState(() => _removeMediaIds.add(media.id)),
    child: Image.network(media.file, fit: BoxFit.cover, errorBuilder: (_, __, ___) => Container(color: Colors.grey.shade200)),
  );

  Widget _existingVideoThumb(ApiReviewMedia media) => _thumbWrap(
    onRemove: () => setState(() => _removeMediaIds.add(media.id)),
    child: Container(color: Colors.grey.shade800, child: const Center(child: Icon(Icons.play_circle_fill, color: Colors.white, size: 28))),
  );

  Widget _newImageThumb(int index, XFile xfile) => _thumbWrap(
    onRemove: () => setState(() => _newImages.removeAt(index)),
    child: Image.file(File(xfile.path), fit: BoxFit.cover),
  );

  Widget _newVideoThumb(int index, XFile xfile) => _thumbWrap(
    onRemove: () => setState(() => _newVideos.removeAt(index)),
    child: Container(
      color: Colors.grey.shade800,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.videocam, color: Colors.white, size: 24),
          const SizedBox(height: 4),
          Text('Video', style: GoogleFonts.poppins(fontSize: Responsive.sp(context, 10), color: Colors.white70)),
        ],
      ),
    ),
  );

  Widget _thumbWrap({required Widget child, required VoidCallback onRemove}) => Stack(
    children: [
      Container(
        width: 80, height: 80,
        margin: const EdgeInsets.only(right: 8),
        decoration: BoxDecoration(borderRadius: BorderRadius.circular(10)),
        child: ClipRRect(borderRadius: BorderRadius.circular(10), child: child),
      ),
      Positioned(
        top: 2, right: 10,
        child: GestureDetector(
          onTap: onRemove,
          child: Container(
            padding: const EdgeInsets.all(3),
            decoration: const BoxDecoration(color: Colors.black54, shape: BoxShape.circle),
            child: const Icon(Icons.close, size: 13, color: Colors.white),
          ),
        ),
      ),
    ],
  );
}
