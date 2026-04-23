import 'dart:convert';
import '../models/user_model.dart';
import 'api_service.dart';
import 'hive_service.dart';
import 'package:flutter/foundation.dart';

class AuthDatasource {
  final ApiService _apiService = ApiService();
  final HiveService _hiveService = HiveService();

  Future<(UserModel?, String?)> login(String username, String password) async {
    try {
      final response = await _apiService.login(username, password);

      if (response.statusCode == 200) {
        final data = response.data;
        if (data['status'] == 'success') {
          final collection = data['collection'] as Map<String, dynamic>;
          // Build UserModel from collection + store full JSON as extraData
          final userModel = UserModel.fromJson({
            ...collection,
            'extra_data': json.encode(collection),
          });
          // Save complete data to Hive
          await _hiveService.saveUser(userModel);
          return (userModel, data['msg'] as String? ?? 'Berhasil masuk');
        } else {
          return (null, (data['msg'] as String?) ?? 'Login gagal');
        }
      } else {
        return (null, 'Server Error: ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('Login Error: $e');
      return (null, 'Terjadi kesalahan koneksi');
    }
  }

  Future<(UserModel?, bool, Map<String, dynamic>?, String?)> checkVisitorCode(String invitationCode) async {
    try {
      final response = await _apiService.checkVisitorCode(invitationCode);

      if (response.statusCode == 200) {
        final data = response.data;
        if (data['status'] == 'success' || data['status'] == 'fiil_form') {
          final collection = data['collection'] as Map<String, dynamic>;
          final isPraregisterDone = collection['is_praregister_done'] == true;

          // Build UserModel mapping all visitor fields
          final userModel = UserModel(
            id: collection['visitor_id']?.toString()
                ?? collection['id']?.toString()
                ?? DateTime.now().millisecondsSinceEpoch.toString(),
            fullname: collection['visitor_name']?.toString() ?? 'Guest',
            username: collection['visitor_email']?.toString() ?? 'guest',
            email: collection['visitor_email']?.toString() ?? '',
            roleAccess: collection['visitor_role']?.toString() ?? 'guest',
            token: collection['token']?.toString(),
            applicationId: collection['application_id']?.toString(),
            description: collection['agenda']?.toString(),
            // Visitor-specific fields
            phone: collection['visitor_phone']?.toString(),
            visitorCode: collection['visitor_code']?.toString(),
            invitationCode: collection['invitation_code']?.toString(),
            hostName: collection['host_name']?.toString(),
            sitePlaceName: collection['site_place_name']?.toString(),
            visitorStatus: collection['visitor_status']?.toString(),
            // Store complete raw collection as extraData
            extraData: json.encode(collection),
          );

          // Save to Hive immediately (even for fiil_form so session is cached)
          await _hiveService.saveUser(userModel);

          return (userModel, isPraregisterDone, collection, data['msg'] as String? ?? 'Berhasil masuk');
        } else {
          return (null, false, null, (data['msg'] as String?) ?? 'Kode undangan belum terdaftar');
        }
      } else {
        // Handle error responses like 400 Bad Request
        if (response.data is Map && response.data['msg'] != null) {
          final msg = response.data['msg'].toString();
          if (msg != 'bad_request') {
            return (null, false, null, msg);
          }
        }
        return (null, false, null, 'Kode undangan belum terdaftar atau tidak valid');
      }
    } catch (e) {
      debugPrint('Check Visitor Code Error: $e');
      return (null, false, null, 'Terjadi kesalahan koneksi');
    }
  }

  Future<void> saveAuthData(UserModel userModel) async {
    await _hiveService.saveUser(userModel);
  }

  Future<void> removeAuthData() async {
    await _hiveService.removeUser();
  }

  Future<UserModel?> getAuthData() async {
    return _hiveService.getUser();
  }

  Future<bool> isAuthDataExist() async {
    return _hiveService.hasUser();
  }

  Future<(bool, String?)> logout() async {
    try {
      // Get the current token before clearing
      final user = _hiveService.getUser();
      final token = user?.token;

      String? revokeMsg;
      // Call revoke token API if token exists (works for both Employee and Visitor)
      if (token != null && token.isNotEmpty) {
        final (success, msg) = await _apiService.revokeToken(token);
        revokeMsg = msg;
      }

      // Always clear local session regardless of API result
      await _hiveService.removeUser();
      return (true, revokeMsg ?? 'Berhasil Logout');
    } catch (e) {
      debugPrint('Logout Error: $e');
      // Still remove local data even if API call fails
      try { await _hiveService.removeUser(); } catch (_) {}
      return (false, 'Terjadi kesalahan saat logout');
    }
  }
}
