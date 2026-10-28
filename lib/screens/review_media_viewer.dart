import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import '../core/safe_launch.dart';
import 'package:video_player/video_player.dart';

import '../core/app_colors.dart';
import '../core/responsive.dart';
import '../models/api_review_model.dart';
import '../widgets/app_loader.dart';

/// Full-screen viewer for a review's photos and videos: swipe between them,
/// pinch to zoom a photo, tap a video to play or pause.
///
/// Review thumbnails used to be dead ends — a video showed a play icon that
/// did nothing — so an uploaded video could never be watched.
class ReviewMediaViewer extends StatefulWidget {
  final List<ApiReviewMedia> media;
  final int initialIndex;

  const ReviewMediaViewer({
    super.key,
    required this.media,
    this.initialIndex = 0,
  });

  /// Opens the viewer on [index] of [media].
  static Future<void> open(
    BuildContext context,
    List<ApiReviewMedia> media,
    int index,
  ) {
    return Navigator.of(context).push(
      MaterialPageRoute(
        fullscreenDialog: true,
        builder: (_) => ReviewMediaViewer(media: media, initialIndex: index),
      ),
    );
  }

  @override
  State<ReviewMediaViewer> createState() => _ReviewMediaViewerState();
}

class _ReviewMediaViewerState extends State<ReviewMediaViewer> {
  late final PageController _pages;
  late int _index;

  @override
  void initState() {
    super.initState();
    _index = widget.initialIndex.clamp(0, widget.media.length - 1);
    _pages = PageController(initialPage: _index);
  }

  @override
  void dispose() {
    _pages.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final count = widget.media.length;
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light,
      child: Scaffold(
        backgroundColor: Colors.black,
        appBar: AppBar(
          backgroundColor: Colors.black,
          elevation: 0,
          scrolledUnderElevation: 0,
          leading: IconButton(
            tooltip: 'Close',
            icon: const Icon(Icons.close_rounded, color: Colors.white),
            onPressed: () => Navigator.of(context).pop(),
          ),
          centerTitle: true,
          title: count > 1
              ? Text(
                  '${_index + 1} / $count',
                  style: GoogleFonts.poppins(
                    fontSize: Responsive.sp(context, 14),
                    color: Colors.white,
                  ),
                )
              : null,
        ),
        body: PageView.builder(
          controller: _pages,
          itemCount: count,
          onPageChanged: (i) => setState(() => _index = i),
          itemBuilder: (_, i) {
            final m = widget.media[i];
            return m.isVideo
                // Keyed so swiping away disposes (and stops) the player.
                ? _ReviewVideo(key: ValueKey(m.id), url: m.file)
                : _ReviewPhoto(url: m.file);
          },
        ),
      ),
    );
  }
}

class _ReviewPhoto extends StatelessWidget {
  final String url;

  const _ReviewPhoto({required this.url});

  @override
  Widget build(BuildContext context) {
    return InteractiveViewer(
      maxScale: 4,
      child: Center(
        child: Image.network(
          url,
          fit: BoxFit.contain,
          loadingBuilder: (_, child, progress) =>
              progress == null ? child : const Center(child: AppLoader()),
          errorBuilder: (_, __, ___) => const _MediaError(
            message: "This photo couldn't be loaded.",
          ),
        ),
      ),
    );
  }
}

class _ReviewVideo extends StatefulWidget {
  final String url;

  const _ReviewVideo({super.key, required this.url});

  @override
  State<_ReviewVideo> createState() => _ReviewVideoState();
}

class _ReviewVideoState extends State<_ReviewVideo> {
  VideoPlayerController? _controller;
  bool _failed = false;

  @override
  void initState() {
    super.initState();
    _start();
  }

  Future<void> _start() async {
    final uri = Uri.tryParse(widget.url);
    if (uri == null || widget.url.isEmpty) {
      setState(() => _failed = true);
      return;
    }
    final controller = VideoPlayerController.networkUrl(uri);
    _controller = controller;
    try {
      await controller.initialize();
      if (!mounted) return;
      controller.addListener(_onTick);
      await controller.play();
      setState(() {});
    } catch (_) {
      if (mounted) setState(() => _failed = true);
    }
  }

  void _onTick() {
    final c = _controller;
    if (c == null || !mounted) return;
    if (c.value.hasError && !_failed) {
      setState(() => _failed = true);
    } else {
      // Repaints the play/pause overlay as playback starts and ends.
      setState(() {});
    }
  }

  @override
  void dispose() {
    _controller?.removeListener(_onTick);
    _controller?.dispose();
    super.dispose();
  }

  void _togglePlay() {
    final c = _controller;
    if (c == null || !c.value.isInitialized) return;
    if (c.value.isPlaying) {
      c.pause();
    } else {
      // Finished: start again from the top.
      if (c.value.position >= c.value.duration) c.seekTo(Duration.zero);
      c.play();
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_failed) {
      return _MediaError(
        message: "This video couldn't be played here.",
        // A codec the device can't decode in-app may still open elsewhere.
        actionLabel: 'Open in another app',
        onAction: () => launchWebUrl(widget.url),
      );
    }
    final c = _controller;
    if (c == null || !c.value.isInitialized) {
      return const Center(child: AppLoader());
    }
    final playing = c.value.isPlaying;
    return Semantics(
      button: true,
      label: playing ? 'Pause video' : 'Play video',
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: _togglePlay,
        child: Stack(
          alignment: Alignment.center,
          children: [
            Center(
              child: AspectRatio(
                aspectRatio: c.value.aspectRatio,
                child: VideoPlayer(c),
              ),
            ),
            AnimatedOpacity(
              opacity: playing ? 0 : 1,
              duration: const Duration(milliseconds: 180),
              child: Container(
                padding: const EdgeInsets.all(14),
                decoration: const BoxDecoration(
                  color: Colors.black45,
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.play_arrow_rounded,
                    color: Colors.white, size: 44),
              ),
            ),
            Positioned(
              left: 16,
              right: 16,
              bottom: 24,
              child: VideoProgressIndicator(
                c,
                allowScrubbing: true,
                colors: const VideoProgressColors(
                  playedColor: AppColors.primaryLight,
                  bufferedColor: Colors.white38,
                  backgroundColor: Colors.white12,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _MediaError extends StatelessWidget {
  final String message;
  final String? actionLabel;
  final VoidCallback? onAction;

  const _MediaError({required this.message, this.actionLabel, this.onAction});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.error_outline_rounded,
                color: Colors.white54, size: 40),
            const SizedBox(height: 12),
            Text(
              message,
              textAlign: TextAlign.center,
              style: GoogleFonts.poppins(
                fontSize: Responsive.sp(context, 13),
                color: Colors.white70,
              ),
            ),
            if (actionLabel != null && onAction != null) ...[
              const SizedBox(height: 16),
              OutlinedButton(
                onPressed: onAction,
                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.white,
                  side: const BorderSide(color: Colors.white38),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(24),
                  ),
                ),
                child: Text(
                  actionLabel!,
                  style: GoogleFonts.poppins(
                    fontSize: Responsive.sp(context, 13),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
