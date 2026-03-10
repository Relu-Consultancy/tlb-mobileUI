import 'package:flutter/material.dart';

class CategoryModel {
  final String name;
  final IconData icon;
  final List<Color> gradientColors;
  final String imagePath; // Added for CategoryDetailScreen routing

  const CategoryModel({
    required this.name,
    required this.icon,
    required this.gradientColors,
    required this.imagePath,
  });
}
