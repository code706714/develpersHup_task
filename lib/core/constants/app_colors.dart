import 'package:flutter/material.dart';

class AppColors {
  AppColors._();
  static const Color background = Color(0xFF0B0B0F);
  static const Color surface = Color(0xFF1C1C24);
  static const Color chipBackground = Color(0xFF1C1C24);
  static const Color divider = Color(0xFF2A2A33);
  static const Color textPrimary = Color(0xFFFFFFFF);
  static const Color textSecondary = Color(0xFF9A9AA8);
  static const Color primary = Color(0xFF6C63FF);
  static const Color priorityHigh = Color(0xFFFF5252);
  static const Color priorityMedium = Color(0xFFFF9800);
  static const Color priorityLow = Color(0xFF4CAF50);

  static Color priorityColor(String priority) {
    switch (priority) {
      case 'High':
        return priorityHigh;
      case 'Low':
        return priorityLow;
      default:
        return priorityMedium;
    }
  }
}