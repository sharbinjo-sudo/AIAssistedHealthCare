import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import '../models/health_models.dart';

class ApiException implements Exception {
  const ApiException(this.message);

  final String message;

  @override
  String toString() => message;
}

class ApiService {
  ApiService({http.Client? client, String? baseUrl})
      : _client = client ?? http.Client(),
        baseUrl = baseUrl ?? _defaultBaseUrl;

  static String get _defaultBaseUrl {
    if (kIsWeb) return 'http://127.0.0.1:8000/api';
    if (defaultTargetPlatform == TargetPlatform.android) return 'http://10.0.2.2:8000/api';
    return 'http://127.0.0.1:8000/api';
  }

  final http.Client _client;
  final String baseUrl;

  Future<Map<String, dynamic>> login({required String email, required String password}) async {
    final data = await _request('POST', '/login/', body: {'email': email, 'password': password}, auth: false);
    await _saveTokens(data);
    return data;
  }

  Future<Map<String, dynamic>> signUp({
    required String name,
    required String email,
    required String phone,
    required String password,
  }) async {
    final data = await _request(
      'POST',
      '/register/',
      body: {'name': name, 'email': email, 'phone': phone, 'password': password},
      auth: false,
    );
    await _saveTokens(data);
    return data;
  }

  Future<Map<String, dynamic>> saveProfile(Map<String, dynamic> profile) => _request('PATCH', '/profile/', body: profile);

  Future<Map<String, dynamic>> profile() => _request('GET', '/profile/');

  Future<DashboardData> dashboard() async => DashboardData.fromJson(await _request('GET', '/dashboard/'));

  Future<Map<String, dynamic>> reportAnalysis() => _request('GET', '/reports/analysis/');

  Future<Map<String, dynamic>> createReport({required String title, required String reportType}) {
    return _request('POST', '/reports/', body: {'title': title, 'report_type': reportType});
  }

  Future<List<Map<String, dynamic>>> reports() async {
    final data = await _request('GET', '/reports/');
    return _asList(data);
  }

  Future<void> deleteReport(int id) async {
    await _request('DELETE', '/reports/$id/');
  }

  Future<Map<String, dynamic>> analysis() => _request('GET', '/analysis/');

  Future<Map<String, dynamic>> aiReport() => _request('GET', '/ai-report/');

  Future<Map<String, dynamic>> futureHealth(Map<String, dynamic> values) => _request('POST', '/future-health/', body: values);

  Future<Map<String, dynamic>> diet() => _request('GET', '/diet/');

  Future<List<Map<String, dynamic>>> progress({String period = 'W'}) async {
    final data = await _request('GET', '/progress/?period=$period');
    return _asList(data);
  }

  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    final refresh = prefs.getString('refresh_token');
    if (refresh != null) {
      try {
        await _request('POST', '/logout/', body: {'refresh': refresh});
      } on ApiException {
        // Local token cleanup should still happen if the server token is already invalid.
      }
    }
    await prefs.remove('access_token');
    await prefs.remove('refresh_token');
  }

  Future<Map<String, dynamic>> _request(String method, String path, {Map<String, dynamic>? body, bool auth = true}) async {
    final uri = Uri.parse('$baseUrl$path');
    final headers = {'Accept': 'application/json', 'Content-Type': 'application/json'};
    if (auth) {
      final token = await _accessToken();
      if (token != null) headers['Authorization'] = 'Bearer $token';
    }

    final http.Response response = switch (method) {
      'GET' => await _client.get(uri, headers: headers),
      'POST' => await _client.post(uri, headers: headers, body: jsonEncode(body ?? {})),
      'PATCH' => await _client.patch(uri, headers: headers, body: jsonEncode(body ?? {})),
      'DELETE' => await _client.delete(uri, headers: headers),
      _ => throw const ApiException('Unsupported request method.'),
    };

    if (response.statusCode == 401 && auth && await _refreshToken()) {
      return _request(method, path, body: body, auth: auth);
    }

    final decoded = response.body.isEmpty ? <String, dynamic>{} : jsonDecode(response.body) as Map<String, dynamic>;
    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw ApiException(decoded['message'] as String? ?? 'Request failed.');
    }

    final data = decoded['data'];
    if (data is Map<String, dynamic>) return data;
    return {'items': data};
  }

  Future<String?> _accessToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('access_token');
  }

  Future<void> _saveTokens(Map<String, dynamic> data) async {
    final prefs = await SharedPreferences.getInstance();
    final access = data['access'];
    final refresh = data['refresh'];
    if (access is String) await prefs.setString('access_token', access);
    if (refresh is String) await prefs.setString('refresh_token', refresh);
  }

  Future<bool> _refreshToken() async {
    final prefs = await SharedPreferences.getInstance();
    final refresh = prefs.getString('refresh_token');
    if (refresh == null) return false;

    final response = await _client.post(
      Uri.parse('$baseUrl/token/refresh/'),
      headers: {'Accept': 'application/json', 'Content-Type': 'application/json'},
      body: jsonEncode({'refresh': refresh}),
    );
    if (response.statusCode != 200) return false;

    final decoded = jsonDecode(response.body) as Map<String, dynamic>;
    final access = decoded['access'];
    if (access is! String) return false;
    await prefs.setString('access_token', access);
    return true;
  }

  List<Map<String, dynamic>> _asList(Map<String, dynamic> data) {
    final items = data['items'];
    if (items is List) return items.whereType<Map<String, dynamic>>().toList();
    return const [];
  }
}
