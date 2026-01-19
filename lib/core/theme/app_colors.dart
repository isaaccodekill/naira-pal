import 'package:flutter/material.dart';

class AppColors {
  // Light mode
  static const backgroundLight = Color(0xFFFFFFFF);  // Pure white
  static const surfaceLight = Color(0xFFFFFFFF);
  static const textPrimaryLight = Color(0xFF2D2A26);
  static const textSecondaryLight = Color(0xFF6B6560);

  // Dark mode
  static const backgroundDark = Color(0xFF1C1B1A);
  static const surfaceDark = Color(0xFF2A2927);
  static const textPrimaryDark = Color(0xFFFAF8F5);
  static const textSecondaryDark = Color(0xFFB0ACA7);

  // Accent colors (same for both modes)
  static const primary = Color(0xFFD4847C);      // Coral
  static const secondary = Color(0xFF9B7ED9);    // Muted purple
  static const warning = Color(0xFFE6A959);      // Amber
  static const error = Color(0xFFD4645C);

  // Category colors
  static const categoryFood = Color(0xFFD4847C);
  static const categoryTransport = Color(0xFF6B9BD2);
  static const categoryShopping = Color(0xFF9B7ED9);
  static const categoryBills = Color(0xFF8B8B8B);
  static const categoryEntertainment = Color(0xFFE091B8);
  static const categoryHealth = Color(0xFF7BA3D9);    // Soft blue instead of green
  static const categoryEducation = Color(0xFF6BB5B5);
  static const categoryGifts = Color(0xFFE6A959);
  static const categoryGroceries = Color(0xFFD4A574);  // Warm amber instead of green
  static const categoryOther = Color(0xFFA39E99);
}
