import 'package:flutter/material.dart';

class AppColors {
  AppColors._();

  static const Color green      = Color(0xFF1B3A2B);
  static const Color greenMd    = Color(0xFF2D6A4F);
  static const Color lime       = Color(0xFFB5E235);
  static const Color limeHov    = Color(0xFFC8F24D);
  static const Color offWhite   = Color(0xFFF5F5F0);
  static const Color textDk     = Color(0xFF0F1A10);
  static const Color textMd     = Color(0xFF4A5544);
  static const Color textLt     = Color(0xFF8A9984);
  static const Color border     = Color(0x14000000);
  static const Color white      = Color(0xFFFFFFFF);
  static const Color error      = Color(0xFFEF4444);
  static const Color warning    = Color(0xFFF97316);
  static const Color info       = Color(0xFF0EA5E9);
  static const Color critical   = Color(0xFFEF4444);
  static const Color high       = Color(0xFFF97316);
  static const Color medium     = Color(0xFFFBBF24);
  static const Color low        = Color(0xFF60A5FA);

  static Color severityColor(String? severity) {
    switch (severity) {
      case 'critical': return critical;
      case 'high':     return high;
      case 'medium':   return medium;
      case 'low':      return low;
      default:         return low;
    }
  }
}
