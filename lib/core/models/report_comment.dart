import 'user.dart';

class ReportComment {
  final int id;
  final int reportId;
  final int userId;
  final String body;
  final DateTime createdAt;
  final User? user;

  ReportComment({
    required this.id,
    required this.reportId,
    required this.userId,
    required this.body,
    required this.createdAt,
    this.user,
  });

  factory ReportComment.fromJson(Map<String, dynamic> json) => ReportComment(
        id:        json['id'],
        reportId:  json['report_id'],
        userId:    json['user_id'],
        body:      json['body'] ?? '',
        createdAt: DateTime.tryParse(json['created_at'] ?? '') ?? DateTime.now(),
        user:      json['user'] != null ? User.fromJson(json['user']) : null,
      );
}
