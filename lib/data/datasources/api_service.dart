import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'dart:io';

class ApiService {
  final Dio _dio = Dio(
    BaseOptions(
      baseUrl: 'https://be-vms.app.bio-experience.com',
      connectTimeout: const Duration(seconds: 10),
      receiveTimeout: const Duration(seconds: 10),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
    ),
  );

  static const String pathApi = 'api';

  Future<Response> login(String username, String password) async {
    try {
      final response = await _dio.post(
        '/$pathApi/_Auth/RequestToken',
        data: {'username': username, 'password': password},
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
        data: {'code': invitationCode},
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
      debugPrint(
        'submitPraForm payload trx_visitor_id: ${payload['trx_visitor_id']}',
      );
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
        final msg =
            e.response?.data?['msg']?.toString() ??
            e.response?.data?['message']?.toString() ??
            'Gagal submit form (${e.response?.statusCode})';
        throw Exception(msg);
      }
      throw Exception('Terjadi kesalahan saat submit form');
    }
  }

  Future<Response> logoutResponse(String token) async {
    try {
      final response = await _dio.get(
        '/$pathApi/_Auth/RevokeToken',
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );
      return response;
    } on DioException catch (e) {
      if (e.response != null) return e.response!;
      rethrow;
    }
  }

  Future<(bool, String?)> revokeToken(String token) async {
    try {
      final response = await _dio.get(
        '/$pathApi/_Auth/RevokeToken',
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );

      String? msg;
      bool isSuccess = false;

      if (response.data is Map) {
        msg = response.data['msg']?.toString();
        isSuccess =
            response.statusCode == 200 && response.data['status'] == 'success';
      }

      return (isSuccess, msg);
    } on DioException catch (e) {
      debugPrint('Dio Error revokeToken: ${e.message}');
      String? msg;
      if (e.response?.data is Map) {
        msg = e.response?.data['msg']?.toString();
      }
      msg ??= e.message;

      return (false, msg);
    } catch (e) {
      debugPrint('Unknown Error revokeToken: $e');
      return (false, e.toString());
    }
  }

  // Future<Response> getCMSData(String endpoint) async { ... }

  Future<Response> getProfile(String token) async {
    try {
      final response = await _dio.get(
        '/$pathApi/profile/me',
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );
      return response;
    } on DioException catch (e) {
      debugPrint('Dio Error getProfile: ${e.message}');
      if (e.response != null) {
        return e.response!;
      }
      rethrow;
    }
  }

  Future<Response> updateProfile(
    String token,
    Map<String, dynamic> payload,
  ) async {
    try {
      final response = await _dio.post(
        '/$pathApi/profile/update',
        data: payload,
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );
      return response;
    } on DioException catch (e) {
      debugPrint('Dio Error updateProfile: ${e.message}');
      if (e.response != null) {
        return e.response!;
      }
      rethrow;
    }
  }

  Future<Response> uploadFile(File file) async {
    try {
      String fileName = file.path.split('/').last;
      FormData formData = FormData.fromMap({
        "file_name": fileName,
        "file": await MultipartFile.fromFile(file.path, filename: fileName),
        "path": "face",
      });

      final response = await _dio.post('/cdn/upload', data: formData);
      return response;
    } on DioException catch (e) {
      debugPrint('Dio Error uploadFile: ${e.message}');
      if (e.response != null) {
        return e.response!;
      }
      rethrow;
    }
  }
}
