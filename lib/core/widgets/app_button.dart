import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../constants/app_colors.dart';

class AppButton extends StatelessWidget {
  final String label;
  final VoidCallback? onTap;
  final bool loading;
  final bool outline;
  final bool small;
  final IconData? icon;
  final Color? backgroundColor;
  final Color? textColor;
  final double? width;

  const AppButton({
    super.key,
    required this.label,
    this.onTap,
    this.loading = false,
    this.outline = false,
    this.small = false,
    this.icon,
    this.backgroundColor,
    this.textColor,
    this.width,
  });

  @override
  Widget build(BuildContext context) {
    final bg   = backgroundColor ?? (outline ? Colors.transparent : AppColors.lime);
    final fg   = textColor ?? (outline ? AppColors.textDk : AppColors.textDk);
    final h    = small ? 44.0 : 52.0;
    final fs   = small ? 13.5 : 14.5;
    final hPad = small ? 20.0 : 24.0;

    return SizedBox(
      width: width,
      height: h,
      child: Material(
        color: bg,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(99),
          side: outline
              ? BorderSide(color: AppColors.textDk.withOpacity(0.2), width: 1.5)
              : BorderSide.none,
        ),
        child: InkWell(
          borderRadius: BorderRadius.circular(99),
          onTap: loading ? null : onTap,
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: hPad),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: width != null ? MainAxisSize.max : MainAxisSize.min,
              children: [
                if (loading)
                  SizedBox(
                    width: 18, height: 18,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation(fg),
                    ),
                  )
                else ...[
                  if (icon != null) ...[
                    Icon(icon, size: 16, color: fg),
                    const SizedBox(width: 8),
                  ],
                  Text(label,
                    style: GoogleFonts.dmSans(
                      fontSize: fs, fontWeight: FontWeight.w600, color: fg,
                    )),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ── Dark button variant
class AppButtonDark extends StatelessWidget {
  final String label;
  final VoidCallback? onTap;
  final bool loading;
  final IconData? trailingIcon;

  const AppButtonDark({
    super.key,
    required this.label,
    this.onTap,
    this.loading = false,
    this.trailingIcon,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 52,
      child: Material(
        color: AppColors.textDk,
        borderRadius: BorderRadius.circular(99),
        child: InkWell(
          borderRadius: BorderRadius.circular(99),
          onTap: loading ? null : onTap,
          child: Padding(
            padding: const EdgeInsets.only(left: 24, right: 11),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (loading)
                  const SizedBox(width: 18, height: 18,
                    child: CircularProgressIndicator(strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation(Colors.white)))
                else
                  Text(label,
                    style: GoogleFonts.dmSans(
                      fontSize: 14.5, fontWeight: FontWeight.w600, color: Colors.white)),
                const SizedBox(width: 10),
                Container(
                  width: 34, height: 34,
                  decoration: const BoxDecoration(
                    color: AppColors.lime,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    trailingIcon ?? Icons.arrow_forward_rounded,
                    size: 16, color: AppColors.textDk,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
