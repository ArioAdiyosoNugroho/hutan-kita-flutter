import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'app_colors.dart';

class AppTextStyles {
  AppTextStyles._();

  static TextStyle syne({
    double fontSize = 16,
    FontWeight fontWeight = FontWeight.w700,
    Color color = AppColors.textDk,
    double? height,
  }) =>
      GoogleFonts.syne(
        fontSize: fontSize,
        fontWeight: fontWeight,
        color: color,
        height: height,
      );

  static TextStyle dmSans({
    double fontSize = 14,
    FontWeight fontWeight = FontWeight.w400,
    Color color = AppColors.textMd,
    double? height,
    FontStyle fontStyle = FontStyle.normal,
  }) =>
      GoogleFonts.dmSans(
        fontSize: fontSize,
        fontWeight: fontWeight,
        color: color,
        height: height,
        fontStyle: fontStyle,
      );

  // Heading styles
  static TextStyle get h1 => syne(fontSize: 32);
  static TextStyle get h2 => syne(fontSize: 26);
  static TextStyle get h3 => syne(fontSize: 20);
  static TextStyle get h4 => syne(fontSize: 17);

  // Body styles
  static TextStyle body    = dmSans(fontSize: 14, height: 1.75);
  static TextStyle bodyMd  = dmSans(fontSize: 14, fontWeight: FontWeight.w500);
  static TextStyle bodySm  = dmSans(fontSize: 12, color: AppColors.textLt);
  static TextStyle caption = dmSans(fontSize: 11, color: AppColors.textLt);
  static TextStyle get label => dmSans(
    fontSize: 10,
    fontWeight: FontWeight.w700,
    color: AppColors.textLt,
  ).copyWith(letterSpacing: 1.0);
}

extension TextStyleExtensions on TextStyle {
  TextStyle get letterSpacing1 => copyWith(letterSpacing: 1.0);
  TextStyle white() => copyWith(color: AppColors.white);
  TextStyle lime()  => copyWith(color: AppColors.lime);
  TextStyle green() => copyWith(color: AppColors.green);
  TextStyle error() => copyWith(color: AppColors.error);
}
