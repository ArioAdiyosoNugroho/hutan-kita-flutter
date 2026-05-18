// lib/core/constants/app_text_styles.dart

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'app_colors.dart';

class AppTextStyles {
  AppTextStyles._();

  // ── Base builders
  static TextStyle syne({
    double fontSize = 16,
    FontWeight fontWeight = FontWeight.w700,
    Color color = AppColors.textDk,
    double? height,
    double? letterSpacing,
  }) =>
      GoogleFonts.syne(
        fontSize: fontSize,
        fontWeight: fontWeight,
        color: color,
        height: height,
        letterSpacing: letterSpacing,
      );

  static TextStyle dmSans({
    double fontSize = 14,
    FontWeight fontWeight = FontWeight.w400,
    Color color = AppColors.textMd,
    double? height,
    double? letterSpacing,
    FontStyle fontStyle = FontStyle.normal,
    TextDecoration? decoration,
  }) =>
      GoogleFonts.dmSans(
        fontSize: fontSize,
        fontWeight: fontWeight,
        color: color,
        height: height,
        letterSpacing: letterSpacing,
        fontStyle: fontStyle,
        decoration: decoration,
      );

  // ── Heading (Syne)
  static TextStyle get h1        => syne(fontSize: 32);
  static TextStyle get h2        => syne(fontSize: 26);
  static TextStyle get h3        => syne(fontSize: 20);
  static TextStyle get h4        => syne(fontSize: 17);
  static TextStyle get heading1  => syne(fontSize: 28, letterSpacing: -0.5);
  static TextStyle get heading2  => syne(fontSize: 24, letterSpacing: -0.5);
  static TextStyle get heading3  => syne(fontSize: 16, height: 1.5);
  static TextStyle get heading4  => h4;

  static TextStyle get heroTitle => syne(
    fontSize: 42, fontWeight: FontWeight.w800,
    color: Colors.white, height: 0.98, letterSpacing: -1.5);

  static TextStyle get heroStat => syne(
    fontSize: 30, fontWeight: FontWeight.w700,
    color: Colors.white, height: 1);

  static TextStyle get statValue => syne(
    fontSize: 22, fontWeight: FontWeight.w700,
    color: AppColors.textDk, height: 1);

  static TextStyle get ctaTitle => syne(
    fontSize: 32, fontWeight: FontWeight.w800,
    color: Colors.white, height: 1.1, letterSpacing: -0.5);

  static TextStyle get cardTitle => dmSans(
    fontSize: 15, fontWeight: FontWeight.w600,
    color: AppColors.textDk, height: 1.48);

  // ── Body (DM Sans)
  static TextStyle body   = dmSans(fontSize: 14, height: 1.85);
  static TextStyle bodyMd = dmSans(fontSize: 14, fontWeight: FontWeight.w500);
  static TextStyle bodySm = dmSans(fontSize: 12, color: AppColors.textLt);

  static TextStyle get bodyHero => dmSans(
    fontSize: 14, color: const Color(0x8CFFFFFF), height: 1.75);

  static TextStyle get caption => dmSans(
    fontSize: 12, color: const Color(0xFFAAAAAA));

  static TextStyle get captionGreen => dmSans(
    fontSize: 12, color: AppColors.greenMd, fontWeight: FontWeight.w500);

  static TextStyle get tiny => dmSans(
    fontSize: 11, color: AppColors.textLt);

  static TextStyle get tinyLime => dmSans(
    fontSize: 11, color: AppColors.lime, fontWeight: FontWeight.w600);

  static TextStyle get label => dmSans(
    fontSize: 13, color: AppColors.textMd, fontWeight: FontWeight.w500);

  static TextStyle get labelDk => dmSans(
    fontSize: 13.5, fontWeight: FontWeight.w600, color: AppColors.textDk);

  static TextStyle get labelWhite => dmSans(
    fontSize: 13.5, fontWeight: FontWeight.w600, color: Colors.white);

  static TextStyle get tagBadge => dmSans(
    fontSize: 11, fontWeight: FontWeight.w600, color: AppColors.textDk);

  static TextStyle get ticker => dmSans(
    fontSize: 13, color: const Color(0xFF999999));

  static TextStyle get dateLabel => dmSans(
    fontSize: 11, color: const Color(0xFFCCCCCC));

  static TextStyle get ctaOverline => dmSans(
    fontSize: 10, color: AppColors.lime,
    fontWeight: FontWeight.w600, letterSpacing: 2);

  static TextStyle get heroStatLabel => dmSans(
    fontSize: 9, color: const Color(0x73FFFFFF),
    letterSpacing: 0.7, fontWeight: FontWeight.w400);

  static TextStyle get heroStatSub => dmSans(
    fontSize: 11, color: const Color(0x61FFFFFF));
}

extension TextStyleExtensions on TextStyle {
  TextStyle white() => copyWith(color: AppColors.white);
  TextStyle lime()  => copyWith(color: AppColors.lime);
  TextStyle green() => copyWith(color: AppColors.green);
  TextStyle error() => copyWith(color: AppColors.error);
}