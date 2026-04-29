import 'package:flutter/material.dart';

// Brand Colors from Prompt 26
class AppColors {
  static const Color sageGreen = Color(0xFFB1CFA0);
  static const Color deepPlum = Color(0xFF452741);
  static const Color lightAqua = Color(0xFFB9DACE);
  static const Color darkTeal = Color(0xFF154956);
  static const Color terracotta = Color(0xFF754743);

  // Semantic aliases
  static const Color primary = darkTeal;
  static const Color secondary = sageGreen;
  static const Color accent = terracotta;
  static const Color background = lightAqua;
  static const Color surface = Colors.white;
}

Color getEffortColor(String effort) {
  switch (effort.toLowerCase()) { 
    case 'high':
      return AppColors.terracotta;
    case 'medium':
      return AppColors.sageGreen;
    case 'low':
      return AppColors.lightAqua;
    default:
      return AppColors.darkTeal;
  }
}
