import 'dart:developer';

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'dart:io';

class ApiService {
  final Dio _dio = Dio(
    BaseOptions(
      baseUrl: 'https://be-vms.app.bio-experience.com',
      connectTimeout: const Duration(seconds: 15),
      receiveTimeout: const Duration(seconds: 30),
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

  Future<Response> submitPraForm(
    Map<String, dynamic> payload, {
    String? visitorTypeId,
  }) async {
    try {
      debugPrint(
        'submitPraForm payload trx_visitor_id: ${payload['trx_visitor_id']}',
      );
      log('/$pathApi/on-portal/submit/pra-form');

      final response = await _dio.post(
        '/$pathApi/on-portal/submit/pra-form',
        // visitor_type sudah ada di dalam body payload, tidak perlu query param ?id=
        data: payload,
      );
      debugPrint('response: $response');
      return response;
    } on DioException catch (e) {
      // if (e.response != null) {
      //   log('Error Response Data: ${e.response?.data}');
      // }
      // debugPrint('Dio Error submitPraForm: ${e.message}');
      // debugPrint('Response status: ${e.response?.statusCode}');
      // debugPrint('Response data: ${e.response?.data}');
      // // Kembalikan response asli (termasuk 500) supaya retry loop di controller bisa handle
      if (e.response != null) {
        return e.response!;
      }
      rethrow;
    }
  }

  /// GET /api/invitation-site/public
  /// Public endpoint — no Bearer token required.
  /// Uses invitation code as query param for visitor context.
  Future<Response> getSites(String invitationCode) async {
    try {
      final response = await _dio.get(
        '/$pathApi/invitation-site/public',
        queryParameters: {
          'token': invitationCode,
          'data-type': 'InvitationLink',
        },
      );
      return response;
    } on DioException catch (e) {
      debugPrint('Dio Error getSites: ${e.message}');
      debugPrint('Response status: ${e.response?.statusCode}');
      debugPrint('Response data: ${e.response?.data}');
      if (e.response != null) {
        return e.response!;
      }
      rethrow;
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

  // ─── Pra Registration ────────────────────────────────────────────────────

  Future<Response> getVisitorTypes(String token) async {
    try {
      final response = await _dio.get(
        '/$pathApi/invitation-visitor-type',
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );
      return response;
    } on DioException catch (e) {
      debugPrint('Dio Error getVisitorTypes: ${e.message}');
      if (e.response != null) return e.response!;
      rethrow;
    }
  }

  Future<Response> getVisitorTypeById(String token, String id) async {
    try {
      final response = await _dio.get(
        '/$pathApi/visitor-type/$id',
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );
      return response;
    } on DioException catch (e) {
      debugPrint('Dio Error getVisitorTypeById: ${e.message}');
      if (e.response != null) return e.response!;
      rethrow;
    }
  }

  Future<Response> submitPraFormOperator(
    String token,
    String visitorTypeId,
    Map<String, dynamic> body,
  ) async {
    try {
      final response = await _dio.post(
        '/$pathApi/on-portal/submit/pra-form',
        queryParameters: {'id': visitorTypeId},
        data: body,
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );
      return response;
    } on DioException catch (e) {
      debugPrint('Dio Error submitPraFormOperator: ${e.message}');
      if (e.response != null) return e.response!;
      rethrow;
    }
  }

  Future<Response> submitNewVisit(
    String token,
    Map<String, dynamic> body,
  ) async {
    try {
      final response = await _dio.post(
        '/$pathApi/operator-invitation/new-visit',
        data: body,
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );
      return response;
    } on DioException catch (e) {
      debugPrint('Dio Error submitNewVisit: ${e.message}');
      if (e.response != null) return e.response!;
      rethrow;
    }
  }

  Future<Response> getAccessPass(String token) async {
    try {
      final response = await _dio.get(
        '/$pathApi/dashboard/access-pass',
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );
      return response;
    } on DioException catch (e) {
      debugPrint('Dio Error getAccessPass: ${e.message}');
      if (e.response != null) return e.response!;
      rethrow;
    }
  }
}
