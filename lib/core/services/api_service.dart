import 'package:dio/dio.dart';
import '../constants/api_constants.dart';
import 'storage_service.dart';

class ApiService {
  static final ApiService _instance = ApiService._internal();
  factory ApiService() => _instance;
  ApiService._internal() { _init(); }

  late final Dio _dio;

  void _init() {
    _dio = Dio(BaseOptions(
      baseUrl:        ApiConstants.baseUrl,
      connectTimeout: const Duration(seconds: 15),
      receiveTimeout: const Duration(seconds: 15),
      headers: {
        'Accept':       'application/json',
        'Content-Type': 'application/json',
      },
    ));

    _dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) async {
        final token = await StorageService.getToken();
        if (token != null) {
          options.headers['Authorization'] = 'Bearer $token';
        }
        return handler.next(options);
      },
      onError: (error, handler) {
        return handler.next(error);
      },
    ));
  }

  // ── Auth ──────────────────────────────────────
  Future<Response> register(Map<String, dynamic> data) =>
      _dio.post(ApiConstants.register, data: data);

  Future<Response> login(Map<String, dynamic> data) =>
      _dio.post(ApiConstants.login, data: data);

  Future<Response> logout() =>
      _dio.post(ApiConstants.logout);

  Future<Response> me() =>
      _dio.get(ApiConstants.me);

  // ── Reports ───────────────────────────────────
  Future<Response> getReports({Map<String, dynamic>? params}) =>
      _dio.get(ApiConstants.reports, queryParameters: params);

  Future<Response> getReportMapPins({Map<String, dynamic>? params}) =>
      _dio.get(ApiConstants.reportsMap, queryParameters: params);

  Future<Response> getReportStats() =>
      _dio.get(ApiConstants.reportsStats);

  Future<Response> getReport(int id) =>
      _dio.get('${ApiConstants.reports}/$id');

  Future<Response> createReport(FormData formData) =>
      _dio.post(ApiConstants.reports, data: formData,
          options: Options(contentType: 'multipart/form-data'));

  Future<Response> updateReport(int id, Map<String, dynamic> data) =>
      _dio.put('${ApiConstants.reports}/$id', data: data);

  Future<Response> deleteReport(int id) =>
      _dio.delete('${ApiConstants.reports}/$id');

  Future<Response> voteReport(int id) =>
      _dio.post('${ApiConstants.reports}/$id/vote');

  Future<Response> addComment(int id, String body) =>
      _dio.post('${ApiConstants.reports}/$id/comments', data: {'body': body});

  Future<Response> deleteComment(int reportId, int commentId) =>
      _dio.delete('${ApiConstants.reports}/$reportId/comments/$commentId');

  // ── Donations ─────────────────────────────────
  Future<Response> createDonationOrder(Map<String, dynamic> data) =>
      _dio.post(ApiConstants.donationsOrder, data: data);

  Future<Response> getDonation(int id, {bool allowPublic = false}) =>
      _dio.get('/donations/$id',
          queryParameters: allowPublic ? {'allow_public': '1'} : null);

  Future<Response> getMyDonations({int page = 1}) =>
      _dio.get(ApiConstants.donationsMy, queryParameters: {'page': page});

  Future<Response> getDonationLeaderboard() =>
      _dio.get(ApiConstants.donationsLeaderboard);

  Future<Response> getDonationSummary() =>
      _dio.get(ApiConstants.donationsSummary);

  // ── Admin ─────────────────────────────────────
  Future<Response> getAdminDashboard() =>
      _dio.get(ApiConstants.adminDashboard);

  Future<Response> getAdminReports({Map<String, dynamic>? params}) =>
      _dio.get(ApiConstants.adminReports, queryParameters: params);

  Future<Response> updateAdminReport(int id, Map<String, dynamic> data) =>
      _dio.put('${ApiConstants.adminReports}/$id', data: data);

  Future<Response> getAdminDonations({Map<String, dynamic>? params}) =>
      _dio.get(ApiConstants.adminDonations, queryParameters: params);
}
