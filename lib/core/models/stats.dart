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
        totalReports:       json['total_reports'] ?? 0,
        verifiedReports:    json['verified_reports'] ?? 0,
        criticalReports:    json['critical_reports'] ?? 0,
        totalTreesLost:     json['total_trees_lost'] ?? 0,
        totalAreaAffected:  (json['total_area_affected'] as num?)?.toDouble() ?? 0,
      );
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
