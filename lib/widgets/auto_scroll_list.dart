import 'dart:async';
import 'package:flutter/material.dart';

/// A horizontal list that auto-advances like a carousel.
///
/// Drop-in replacement for a horizontal `ListView.builder`: it periodically
/// scrolls forward by ~one viewport and loops back to the start. Auto-scroll
/// pauses while the user is interacting and resumes a few seconds after.
/// Lists that fit entirely on screen (no scroll extent) simply stay still.
class AutoScrollList extends StatefulWidget {
  final int itemCount;
  final IndexedWidgetBuilder itemBuilder;
  final EdgeInsetsGeometry? padding;
  final Clip clipBehavior;
  final bool addAutomaticKeepAlives;

  /// How often the list advances.
  final Duration interval;

  /// Fraction of the viewport width to advance on each tick.
  final double advanceFraction;

  const AutoScrollList({
    super.key,
    required this.itemCount,
    required this.itemBuilder,
    this.padding,
    this.clipBehavior = Clip.hardEdge,
    this.addAutomaticKeepAlives = true,
    this.interval = const Duration(seconds: 3),
    this.advanceFraction = 0.85,
  });

  @override
  State<AutoScrollList> createState() => _AutoScrollListState();
}

class _AutoScrollListState extends State<AutoScrollList> {
  final ScrollController _controller = ScrollController();
  Timer? _timer;
  bool _paused = false;

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(widget.interval, (_) => _tick());
  }

  @override
  void dispose() {
    _timer?.cancel();
    _controller.dispose();
    super.dispose();
  }

  void _tick() {
    if (!mounted || _paused || !_controller.hasClients) return;
    final pos = _controller.position;
    final max = pos.maxScrollExtent;
    if (max <= 0) return; // nothing to scroll — list fits on screen
    final step = pos.viewportDimension * widget.advanceFraction;
    double next = _controller.offset + step;
    if (next >= max - 4) next = 0; // reached the end → loop to start
    _controller.animateTo(
      next,
      duration: const Duration(milliseconds: 650),
      curve: Curves.easeInOut,
    );
  }

  bool _onNotification(ScrollNotification n) {
    // Pause when the user starts dragging; resume a few seconds after they stop.
    if (n is ScrollStartNotification && n.dragDetails != null) {
      _paused = true;
    } else if (n is ScrollEndNotification) {
      Future.delayed(const Duration(seconds: 4), () {
        if (mounted) _paused = false;
      });
    }
    return false;
  }

  @override
  Widget build(BuildContext context) {
    return NotificationListener<ScrollNotification>(
      onNotification: _onNotification,
      child: ListView.builder(
        controller: _controller,
        scrollDirection: Axis.horizontal,
        clipBehavior: widget.clipBehavior,
        padding: widget.padding,
        itemCount: widget.itemCount,
        addAutomaticKeepAlives: widget.addAutomaticKeepAlives,
        itemBuilder: widget.itemBuilder,
      ),
    );
  }
}
