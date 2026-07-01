import 'package:flutter/material.dart';

/// Renders a listing cover that may be a **network URL** (real API data) or a
/// bundled **asset path** (legacy/dummy), with a graceful grey fallback when
/// the path is empty or fails to load. Use this anywhere a card shows an
/// `EventModel.imagePath` so both data sources render correctly.
///
/// Images are decoded at (roughly) their display resolution via `cacheWidth`
/// so a large source — especially an arbitrarily-sized network image — doesn't
/// balloon into tens of MB of RAM. A 4000×3000 photo decoded full-size costs
/// ~48 MB; capped to the widget width it's a few hundred KB.
Widget listingImage(
  String path, {
  BoxFit fit = BoxFit.cover,
  double? width,
  double? height,
  int? cacheWidth,
}) {
  Widget fallback() => Container(
        width: width,
        height: height,
        color: const Color(0xFFEDEDED),
        child: Icon(Icons.image_outlined, color: Colors.grey.shade400, size: 28),
      );

  if (path.isEmpty) return fallback();

  // Decode target: caller override → ~3× the logical width (covers 3x DPI) →
  // a sensible full-width cap when the width is unbounded (double.infinity).
  final int decodeWidth = cacheWidth ??
      ((width != null && width.isFinite && width > 0)
          ? (width * 3).ceil()
          : 1080);

  if (path.startsWith('http')) {
    return Image.network(
      path,
      width: width,
      height: height,
      fit: fit,
      cacheWidth: decodeWidth,
      errorBuilder: (_, __, ___) => fallback(),
    );
  }
  return Image.asset(
    path,
    width: width,
    height: height,
    fit: fit,
    cacheWidth: decodeWidth,
    errorBuilder: (_, __, ___) => fallback(),
  );
}
