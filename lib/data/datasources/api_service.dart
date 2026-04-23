import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

class ApiService {
  final Dio _dio = Dio(BaseOptions(
    baseUrl: 'https://be-vms.app.bio-experience.com',
    connectTimeout: const Duration(seconds: 10),
    receiveTimeout: const Duration(seconds: 10),
    headers: {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    },
  ));

  static const String pathApi = 'api';

  Future<Response> login(String username, String password) async {
    try {
      final response = await _dio.post(
        '/$pathApi/_Auth/RequestToken',
        data: {
          'username': username,
          'password': password,
        },
      );
      return response;
    } on DioException catch (e) {
      debugPrint('Dio Error: ${e.message}');
      if (e.response != null) {
        return e.response!;
      }
      rethrow;
    }
  }

  Future<Response> checkVisitorCode(String invitationCode) async {
    try {
      final response = await _dio.post(
        '/$pathApi/on-portal/VisitorRequest',
        data: {
          'code': invitationCode,
        },
      );
      return response;
    } on DioException catch (e) {
      debugPrint('Dio Error: ${e.message}');
      if (e.response != null) {
        return e.response!;
      }
      rethrow;
    }
  }

  Future<Response> submitPraForm(Map<String, dynamic> payload) async {
    try {
      debugPrint('submitPraForm payload trx_visitor_id: ${payload['trx_visitor_id']}');
      final response = await _dio.post(
        '/$pathApi/on-portal/submit/pra-form',
        data: payload,
      );
      return response;
    } on DioException catch (e) {
      debugPrint('Dio Error submitPraForm: ${e.message}');
      debugPrint('Response status: ${e.response?.statusCode}');
      debugPrint('Response data: ${e.response?.data}');
      if (e.response != null) {
        final msg = e.response?.data?['msg']?.toString() ??
            e.response?.data?['message']?.toString() ??
            'Gagal submit form (${e.response?.statusCode})';
        throw Exception(msg);
      }
      throw Exception('Terjadi kesalahan saat submit form');
    }
  }

  Future<(bool, String?)> revokeToken(String token) async {
    try {
      final response = await _dio.post(
        '/$pathApi/_Auth/RevokeToken',
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );
      final msg = response.data?['msg']?.toString();
      final isSuccess = response.statusCode == 200 &&
          response.data?['status'] == 'success';
      return (isSuccess, msg);
    } on DioException catch (e) {
      debugPrint('Dio Error revokeToken: ${e.message}');
      final msg = e.response?.data?['msg']?.toString() ?? e.message;
      // Even if revoke fails we still clear local session
      return (false, msg);
    }
  }

  // Future<Response> getCMSData(String endpoint) async { ... }
}
