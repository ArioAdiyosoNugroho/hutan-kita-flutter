import 'package:flutter/material.dart';
import 'package:hutankita/core/models/user.dart';
import 'package:hutankita/core/services/api_service.dart';
import 'package:hutankita/core/services/storage_service.dart';

enum AuthStatus { unknown, authenticated, unauthenticated }

class AuthProvider extends ChangeNotifier {
  final _api = ApiService();

  AuthStatus _status = AuthStatus.unknown;
  User? _user;
  String? _error;
  bool _loading = false;

  AuthStatus get status  => _status;
  User?       get user   => _user;
  String?     get error  => _error;
  bool        get loading => _loading;
  bool        get isAuth  => _status == AuthStatus.authenticated;
  bool        get isAdmin => _user?.isAdmin ?? false;

  Future<void> init() async {
    final hasToken = await StorageService.hasToken();
    if (hasToken) {
      await fetchMe();
    } else {
      _status = AuthStatus.unauthenticated;
      notifyListeners();
    }
  }

  Future<void> fetchMe() async {
    try {
      final res = await _api.me();
      _user   = User.fromJson(res.data);
      _status = AuthStatus.authenticated;
    } catch (_) {
      await StorageService.deleteToken();
      _user = null;
      _status = AuthStatus.unauthenticated;
      _error = 'Sesi telah berakhir, silakan login kembali';
    }
    notifyListeners();
  }

  Future<bool> login(String email, String password) async {
    _loading = true; _error = null; notifyListeners();
    try {
      final res = await _api.login({'email': email, 'password': password});
      await StorageService.saveToken(res.data['token']);
      _user   = User.fromJson(res.data['user']);
      _status = AuthStatus.authenticated;
      _loading = false; notifyListeners();
      return true;
    } catch (e) {
      _error = _parseError(e);
      _loading = false; notifyListeners();
      return false;
    }
  }

  Future<bool> register(String name, String email, String password, String passwordConfirmation) async {
    _loading = true; _error = null; notifyListeners();
    try {
      final res = await _api.register({
        'name':                  name,
        'email':                 email,
        'password':              password,
        'password_confirmation': passwordConfirmation,
      });
      await StorageService.saveToken(res.data['token']);
      _user   = User.fromJson(res.data['user']);
      _status = AuthStatus.authenticated;
      _loading = false; notifyListeners();
      return true;
    } catch (e) {
      _error = _parseError(e);
      _loading = false; notifyListeners();
      return false;
    }
  }

  Future<void> logout() async {
    try { await _api.logout(); } catch (_) {}
    await StorageService.deleteToken();
    _user   = null;
    _error  = null;
    _status = AuthStatus.unauthenticated;
    notifyListeners();
  }

  String _parseError(dynamic e) {
    try {
      final data = (e as dynamic).response?.data;
      if (data is Map) {
        if (data['errors'] != null) {
          final errors = data['errors'] as Map;
          return errors.values.first is List
              ? errors.values.first[0]
              : errors.values.first.toString();
        }
        return data['message'] ?? 'Terjadi kesalahan';
      }
    } catch (_) {}
    return 'Gagal terhubung ke server';
  }
}
