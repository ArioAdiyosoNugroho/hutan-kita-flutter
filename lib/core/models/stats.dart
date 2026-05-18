class ReportStats {
  final int totalReports;
  final int verifiedReports;
  final int criticalReports;
  final int totalTreesLost;
  final double totalAreaAffected;

  ReportStats({
    required this.totalReports,
    required this.verifiedReports,
    required this.criticalReports,
    required this.totalTreesLost,
    required this.totalAreaAffected,
  });

  factory ReportStats.fromJson(Map<String, dynamic> json) => ReportStats(
        totalReports:      _toInt(json['total_reports']),
        verifiedReports:   _toInt(json['verified_reports']),
        criticalReports:   _toInt(json['critical_reports']),
        totalTreesLost:    _toInt(json['total_trees_lost']),
        totalAreaAffected: _toDouble(json['total_area_affected']), // ← fix
      );

  static int _toInt(dynamic v) {
    if (v == null) return 0;
    if (v is int) return v;
    if (v is double) return v.toInt();
    return int.tryParse(v.toString()) ?? 0;
  }

  static double _toDouble(dynamic v) {
    if (v == null) return 0;
    if (v is double) return v;
    if (v is int) return v.toDouble();
    return double.tryParse(v.toString()) ?? 0;
  }
}

class AdminDashboard {
  final Map<String, dynamic> users;
  final Map<String, dynamic> reports;
  final Map<String, dynamic> donations;
  final List<dynamic> recentReports;
  final List<dynamic> recentDonations;

  AdminDashboard({
    required this.users,
    required this.reports,
    required this.donations,
    required this.recentReports,
    required this.recentDonations,
  });

  factory AdminDashboard.fromJson(Map<String, dynamic> json) => AdminDashboard(
        users:           Map<String, dynamic>.from(json['users'] ?? {}),
        reports:         Map<String, dynamic>.from(json['reports'] ?? {}),
        donations:       Map<String, dynamic>.from(json['donations'] ?? {}),
        recentReports:   json['recent_reports'] ?? [],
        recentDonations: json['recent_donations'] ?? [],
      );
}