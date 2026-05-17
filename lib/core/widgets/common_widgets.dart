import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shimmer/shimmer.dart';
import '../constants/app_colors.dart';

// ── Loading skeleton
class ShimmerBox extends StatelessWidget {
  final double width;
  final double height;
  final double radius;

  const ShimmerBox({
    super.key,
    this.width = double.infinity,
    required this.height,
    this.radius = 8,
  });

  @override
  Widget build(BuildContext context) => Shimmer.fromColors(
        baseColor: const Color(0xFFE5E7EB),
        highlightColor: const Color(0xFFF9FAFB),
        child: Container(
          width: width, height: height,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(radius),
          ),
        ),
      );
}

// ── Empty state
class EmptyState extends StatelessWidget {
  final IconData icon;
  final String title;
  final String? subtitle;
  final Widget? action;

  const EmptyState({
    super.key,
    required this.icon,
    required this.title,
    this.subtitle,
    this.action,
  });

  @override
  Widget build(BuildContext context) => Center(
        child: Padding(
          padding: const EdgeInsets.all(40),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 72, height: 72,
                decoration: BoxDecoration(
                  color: AppColors.offWhite,
                  shape: BoxShape.circle,
                  border: Border.all(color: AppColors.border),
                ),
                child: Icon(icon, size: 30, color: AppColors.textLt),
              ),
              const SizedBox(height: 16),
              Text(title,
                style: GoogleFonts.syne(
                  fontSize: 16, fontWeight: FontWeight.w700, color: AppColors.textDk),
                textAlign: TextAlign.center),
              if (subtitle != null) ...[
                const SizedBox(height: 6),
                Text(subtitle!,
                  style: GoogleFonts.dmSans(
                    fontSize: 13, color: AppColors.textLt),
                  textAlign: TextAlign.center),
              ],
              if (action != null) ...[
                const SizedBox(height: 20),
                action!,
              ],
            ],
          ),
        ),
      );
}

// ── Error state
class ErrorState extends StatelessWidget {
  final String message;
  final VoidCallback? onRetry;

  const ErrorState({super.key, required this.message, this.onRetry});

  @override
  Widget build(BuildContext context) => Center(
        child: Padding(
          padding: const EdgeInsets.all(40),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 72, height: 72,
                decoration: BoxDecoration(
                  color: AppColors.error.withOpacity(0.08),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.error_outline_rounded,
                  size: 30, color: AppColors.error),
              ),
              const SizedBox(height: 16),
              Text('Terjadi Kesalahan',
                style: GoogleFonts.syne(
                  fontSize: 16, fontWeight: FontWeight.w700, color: AppColors.textDk)),
              const SizedBox(height: 6),
              Text(message,
                style: GoogleFonts.dmSans(fontSize: 13, color: AppColors.textLt),
                textAlign: TextAlign.center),
              if (onRetry != null) ...[
                const SizedBox(height: 20),
                TextButton(
                  onPressed: onRetry,
                  child: Text('Coba Lagi',
                    style: GoogleFonts.dmSans(
                      color: AppColors.greenMd, fontWeight: FontWeight.w600)),
                ),
              ],
            ],
          ),
        ),
      );
}

// ── Section header
class SectionHeader extends StatelessWidget {
  final String title;
  final String? subtitle;
  final Widget? trailing;

  const SectionHeader({super.key, required this.title, this.subtitle, this.trailing});

  @override
  Widget build(BuildContext context) => Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title,
                  style: GoogleFonts.syne(
                    fontSize: 24, fontWeight: FontWeight.w700,
                    color: AppColors.textDk, letterSpacing: -0.5)),
                if (subtitle != null) ...[
                  const SizedBox(height: 4),
                  Text(subtitle!,
                    style: GoogleFonts.dmSans(fontSize: 13, color: AppColors.textLt)),
                ],
              ],
            ),
          ),
          if (trailing != null) trailing!,
        ],
      );
}

// ── Stat chip (small info pill)
class StatChip extends StatelessWidget {
  final IconData icon;
  final String value;
  final String label;
  final Color color;

  const StatChip({
    super.key,
    required this.icon,
    required this.value,
    required this.label,
    required this.color,
  });

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 13),
        decoration: BoxDecoration(
          color: AppColors.offWhite,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppColors.border),
        ),
        child: Row(
          children: [
            Container(
              width: 38, height: 38,
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, size: 17, color: color),
            ),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(value,
                  style: GoogleFonts.syne(
                    fontSize: 22, fontWeight: FontWeight.w700,
                    color: AppColors.textDk, height: 1)),
                const SizedBox(height: 2),
                Text(label,
                  style: GoogleFonts.dmSans(
                    fontSize: 11, color: AppColors.textLt)),
              ],
            ),
          ],
        ),
      );
}
