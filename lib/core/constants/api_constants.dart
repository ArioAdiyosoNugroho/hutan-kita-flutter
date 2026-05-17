class ApiConstants {
  ApiConstants._();

  // Ganti dengan base URL backend Laravel Anda
  static const String baseUrl = 'http://127.0.0.1:8000/api';

  // Auth
  static const String register      = '/auth/register';
  static const String login         = '/auth/login';
  static const String logout        = '/auth/logout';
  static const String me            = '/auth/me';

  // Reports
  static const String reports       = '/reports';
  static const String reportsMap    = '/reports/map';
  static const String reportsStats  = '/reports/stats';

  // Donations
  static const String donationsOrder       = '/donations/order';
  static const String donationsLeaderboard = '/donations/leaderboard';
  static const String donationsSummary     = '/donations/summary';
  static const String donationsMy          = '/donations/my';

  // Admin
  static const String adminDashboard = '/admin/dashboard';
  static const String adminReports   = '/admin/reports';
  static const String adminDonations = '/admin/donations';
}
