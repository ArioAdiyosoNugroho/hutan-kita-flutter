// lib/core/widgets/common_widgets.dart

import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';
import '../constants/app_colors.dart';
import '../constants/app_text_styles.dart';

// ─────────────────────────────────────────────────────────────────
// SHIMMER
// ─────────────────────────────────────────────────────────────────
class ShimmerWrap extends StatelessWidget {
  final Widget child;
  const ShimmerWrap({super.key, required this.child});

  @override
  Widget build(BuildContext context) => Shimmer.fromColors(
    baseColor:      const Color(0xFFE5E7EB),
    highlightColor: const Color(0xFFF9FAFB),
    child: child,
  );
}

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
  Widget build(BuildContext context) => Container(
    width: width, height: height,
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(radius),
    ),
  );
}

// ─────────────────────────────────────────────────────────────────
// EMPTY STATE
// ─────────────────────────────────────────────────────────────────
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
          DecoratedBox(
            decoration: BoxDecoration(
              color: AppColors.offWhite,
              shape: BoxShape.circle,
              border: Border.all(color: AppColors.border),
            ),
            child: SizedBox(
              width: 72, height: 72,
              child: Icon(icon, size: 30, color: AppColors.textLt),
            ),
          ),
          const SizedBox(height: 16),
          Text(title,
            style: AppTextStyles.heading3,
            textAlign: TextAlign.center),
          if (subtitle != null) ...[
            const SizedBox(height: 6),
            Text(subtitle!,
              style: AppTextStyles.label,
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

// ─────────────────────────────────────────────────────────────────
// ERROR STATE
// ─────────────────────────────────────────────────────────────────
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
          const DecoratedBox(
            decoration: BoxDecoration(
              color: Color(0x14EF4444),
              shape: BoxShape.circle,
            ),
            child: SizedBox(
              width: 72, height: 72,
              child: Icon(Icons.error_outline_rounded,
                size: 30, color: AppColors.error),
            ),
          ),
          const SizedBox(height: 16),
          Text('Terjadi Kesalahan', style: AppTextStyles.heading3),
          const SizedBox(height: 6),
          Text(message,
            style: AppTextStyles.label,
            textAlign: TextAlign.center),
          if (onRetry != null) ...[
            const SizedBox(height: 20),
            TextButton(
              onPressed: onRetry,
              child: Text('Coba Lagi',
                style: AppTextStyles.captionGreen
                  .copyWith(fontWeight: FontWeight.w600)),
            ),
          ],
        ],
      ),
    ),
  );
}

// ─────────────────────────────────────────────────────────────────
// SECTION HEADER
// ─────────────────────────────────────────────────────────────────
class SectionHeader extends StatelessWidget {
  final String title;
  final String? subtitle;
  final Widget? trailing;

  const SectionHeader({
    super.key,
    required this.title,
    this.subtitle,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) => Row(
    crossAxisAlignment: CrossAxisAlignment.end,
    children: [
      Expanded(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: AppTextStyles.heading2),
            if (subtitle != null) ...[
              const SizedBox(height: 4),
              Text(subtitle!, style: AppTextStyles.tiny),
            ],
          ],
        ),
      ),
      if (trailing != null) trailing!,
    ],
  );
}

// ─────────────────────────────────────────────────────────────────
// STAT CHIP — fixed overflow
// ─────────────────────────────────────────────────────────────────
class StatChip extends StatelessWidget {
  final IconData icon;
  final String   value;
  final String   label;
  final Color    color;

  const StatChip({
    super.key,
    required this.icon,
    required this.value,
    required this.label,
    required this.color,
  });

  @override
  Widget build(BuildContext context) => DecoratedBox(
    decoration: BoxDecoration(
      color: AppColors.offWhite,
      borderRadius: BorderRadius.circular(14),
      border: Border.all(color: AppColors.border),
    ),
    child: Padding(
      // ✅ vertical 10 — lebih compact, tidak overflow
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          DecoratedBox(
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            // ✅ 32x32 bukan 38x38
            child: SizedBox(
              width: 32, height: 32,
              child: Icon(icon, size: 16, color: color),
            ),
          ),
          const SizedBox(width: 10),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,       // ✅ wajib ada
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(value, style: AppTextStyles.statValue),
              Text(label, style: AppTextStyles.tiny),
            ],
          ),
        ],
      ),
    ),
  );
}