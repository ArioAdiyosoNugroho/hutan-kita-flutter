import 'user.dart';
import 'report_comment.dart';

class Report {
  final int id;
  final String title;
  final String? description;
  final double? lat;
  final double? lng;
  final String? locationText;
  final String? reportType;
  final String severity;
  final String status;
  final String? photoPath;
  final String? photoUrl;
  final int upvotes;
  final double? areaAffected;
  final int? treesLost;
  final String? adminNotes;
  final DateTime createdAt;
  final User? user;
  final List<ReportComment> comments;

  Report({
    required this.id,
    required this.title,
    this.description,
    this.lat,
    this.lng,
    this.locationText,
    this.reportType,
    required this.severity,
    required this.status,
    this.photoPath,
    this.photoUrl,
    this.upvotes = 0,
    this.areaAffected,
    this.treesLost,
    this.adminNotes,
    required this.createdAt,
    this.user,
    this.comments = const [],
  });

  factory Report.fromJson(Map<String, dynamic> json) => Report(
        id:           json['id'],
        title:        json['title'] ?? '',
        description:  json['description'],
        lat:          (json['lat'] as num?)?.toDouble(),
        lng:          (json['lng'] as num?)?.toDouble(),
        locationText: json['location_text'],
        reportType:   json['report_type'] ?? json['type'],
        severity:     json['severity'] ?? 'low',
        status:       json['status'] ?? 'pending',
        photoPath:    json['photo_path'],
        photoUrl:     json['photo_url'],
        upvotes:      json['upvotes'] ?? 0,
        areaAffected: (json['area_affected'] as num?)?.toDouble(),
        treesLost:    json['trees_lost'],
        adminNotes:   json['admin_notes'],
        createdAt:    DateTime.tryParse(json['created_at'] ?? '') ?? DateTime.now(),
        user:         json['user'] != null ? User.fromJson(json['user']) : null,
        comments:     (json['comments'] as List<dynamic>?)
                          ?.map((c) => ReportComment.fromJson(c))
                          .toList() ??
                      [],
      );

  String get severityLabel {
    switch (severity) {
      case 'critical': return 'Kritis';
      case 'high':     return 'Tinggi';
      case 'medium':   return 'Sedang';
      default:         return 'Rendah';
    }
  }

  String get typeLabel {
    switch (reportType) {
      case 'sawit_expansion': return 'Ekspansi Sawit';
      case 'illegal_logging': return 'Penebangan Liar';
      case 'forest_fire':     return 'Kebakaran Hutan';
      case 'land_clearing':   return 'Pembukaan Lahan';
      case 'mining':          return 'Pertambangan';
      case 'other':           return 'Lainnya';
      default:                return 'Lainnya';
    }
  }

  String get typeEmoji {
    switch (reportType) {
      case 'sawit_expansion': return '🌴';
      case 'illegal_logging': return '🪓';
      case 'forest_fire':     return '🔥';
      case 'land_clearing':   return '🚜';
      case 'mining':          return '⛏️';
      case 'other':           return '📍';
      default:                return '📍';
    }
  }

  String get statusLabel {
    switch (status) {
      case 'verified': return 'Terverifikasi';
      case 'resolved': return 'Selesai';
      case 'rejected': return 'Ditolak';
      default:         return 'Menunggu';
    }
  }
}
