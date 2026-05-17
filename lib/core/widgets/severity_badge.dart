import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../constants/app_colors.dart';

class SeverityBadge extends StatelessWidget {
  final String severity;
  final bool small;

  const SeverityBadge({super.key, required this.severity, this.small = false});

  @override
  Widget build(BuildContext context) {
    final color = AppColors.severityColor(severity);
    final label = _label(severity);
    final fs    = small ? 10.0 : 11.0;
    final hPad  = small ? 8.0  : 11.0;
    final vPad  = small ? 3.0  : 4.0;
    final dot   = small ? 5.0  : 7.0;

    return Container(
      padding: EdgeInsets.symmetric(horizontal: hPad, vertical: vPad),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.92),
        borderRadius: BorderRadius.circular(99),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: dot, height: dot,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
          ),
          const SizedBox(width: 5),
          Text(label,
            style: GoogleFonts.dmSans(
              fontSize: fs, fontWeight: FontWeight.w600, color: const Color(0xFF222222))),
        ],
      ),
    );
  }

  String _label(String s) {
    switch (s) {
      case 'critical': return 'Kritis';
      case 'high':     return 'Tinggi';
      case 'medium':   return 'Sedang';
      default:         return 'Rendah';
    }
  }
}

class StatusBadge extends StatelessWidget {
  final String status;

  const StatusBadge({super.key, required this.status});

  @override
  Widget build(BuildContext context) {
    final (color, label) = switch (status) {
      'verified' => (const Color(0xFF22C55E), 'Terverifikasi'),
      'resolved' => (const Color(0xFF3B82F6), 'Selesai'),
      'rejected' => (AppColors.error,         'Ditolak'),
      _          => (AppColors.medium,        'Menunggu'),
    };

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(99),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Text(label,
        style: GoogleFonts.dmSans(
          fontSize: 11, fontWeight: FontWeight.w600, color: color)),
    );
  }
}
