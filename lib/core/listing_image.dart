import 'package:flutter/material.dart';

/// Renders a listing cover that may be a **network URL** (real API data) or a
/// bundled **asset path** (legacy/dummy), with a graceful grey fallback when
/// the path is empty or fails to load. Use this anywhere a card shows an
/// `EventModel.imagePath` so both data sources render correctly.
Widget listingImage(
  String path, {
  BoxFit fit = BoxFit.cover,
  double? width,
  double? height,
}) {
  Widget fallback() => Container(
        width: width,
        height: height,
        color: const Color(0xFFEDEDED),
        child: Icon(Icons.image_outlined, color: Colors.grey.shade400, size: 28),
      );

  if (path.isEmpty) return fallback();
  if (path.startsWith('http')) {
    return Image.network(
      path,
      width: width,
      height: height,
      fit: fit,
      errorBuilder: (_, __, ___) => fallback(),
    );
  }
  return Image.asset(
    path,
    width: width,
    height: height,
    fit: fit,
    errorBuilder: (_, __, ___) => fallback(),
  );
}
