import 'package:flutter/material.dart';

class AppColors {
  AppColors._();

  // Primary palette
  static const Color primary = Color(0xFFF5A623);
  static const Color primaryLight = Color(0xFFFFCC00);
  static const Color primaryDark = Color(0xFFE8961E);
  static const Color amber = Color(0xFFFFB800);

  // Background
  static const Color background = Color(0xFFFFF8EE);
  static const Color cardBackground = Colors.white;
  static const Color headerGradientTop = Color(0xFFFFCC02);
  static const Color headerGradientBottom = Color(0xFFF5A623);

  // Text
  static const Color textPrimary = Color(0xFF1A1A2E);
  // Darkened from 0xFF6B7280 → somewhat-dark grey for stronger, more legible
  // secondary text on cards (age range, rating, venue, etc.).
  static const Color textSecondary = Color(0xFF333333);   // card/secondary text — black @ ~0.80
  static const Color textDescription = Color(0xFF333333); // card description body — black @ ~0.80
  static const Color textWhite = Colors.white;

  // Accent
  static const Color blue = Color(0xFF3B82F6);
  static const Color seeAllBlue = Color(0xFF0068E7);       // "See All" links app-wide
  static const Color accentBlue = Color(0xFF2563EB);       // ticket / notification / help accent

  // Category colors
  static const Color categoryOrange = Color(0xFFFFA726);
  static const Color categoryPurple = Color(0xFF9C7CF4);
  static const Color categoryPink = Color(0xFFF48FB1);
  static const Color categoryGreen = Color(0xFF66BB6A);
  static const Color categoryBlue = Color(0xFF42A5F5);
  static const Color categoryRed = Color(0xFFEF5350);

  // Trending section
  static const Color trendingBg = Color(0xFFFFF3E0);

  // Stars
  static const Color starFilled = Color(0xFFF5A623);
  static const Color starEmpty = Color(0xFFD1D5DB);

  // Misc
  static const Color divider = Color(0xFFE5E7EB);
  static const Color searchBarBg = Color(0xFFFFF8EE);
  static const Color searchBarBorder = Color(0xFFE8C547);
  static const Color bookNowBg = Color(0xFFFFCC00);
  static const Color tagProgram = Color(0xFFF48FB1);
  static const Color tagFeatured = Color(0xFFEF5350);

  // Extended palette — fills gaps found across screens
  static const Color dividerGold = Color(0xFFE4CD89);      // section divider lines
  static const Color indigo = Color(0xFF5B5BD6);           // links / underlines
  static const Color lightGray = Color(0xFFF2F2F7);        // iOS surface color
  static const Color bookingBlue = Color(0xFF1A3A8F);      // booking confirmation header
  static const Color successGreen = Color(0xFF34C759);     // booking confirmed badge
  static const Color starAmber = Color(0xFFFFB902);        // star/rating amber
  static const Color inputFill = Color(0xFFF8F9FA);        // text-field fill (review sheet)
}
