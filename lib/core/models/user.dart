class User {
  final int id;
  final String name;
  final String email;
  final String? avatar;
  final String role;
  final int? totalReports;
  final int? totalTreesPlanted;
  final int? reportsCount;
  final int? donationsCount;

  User({
    required this.id,
    required this.name,
    required this.email,
    this.avatar,
    this.role = 'user',
    this.totalReports,
    this.totalTreesPlanted,
    this.reportsCount,
    this.donationsCount,
  });

  bool get isAdmin => role == 'admin';

  factory User.fromJson(Map<String, dynamic> json) => User(
        id:                 json['id'],
        name:               json['name'] ?? '',
        email:              json['email'] ?? '',
        avatar:             json['avatar'],
        role:               json['role'] ?? 'user',
        totalReports:       json['total_reports'],
        totalTreesPlanted:  json['total_trees_planted'],
        reportsCount:       json['reports_count'],
        donationsCount:     json['donations_count'],
      );

  Map<String, dynamic> toJson() => {
        'id':    id,
        'name':  name,
        'email': email,
      };
}
