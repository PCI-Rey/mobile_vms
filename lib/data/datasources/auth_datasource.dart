import 'dart:convert';
import '../models/user_model.dart';
import 'api_service.dart';
import 'hive_service.dart';
import 'package:flutter/foundation.dart';

class AuthDatasource {
  final ApiService _apiService = ApiService();
  final HiveService _hiveService = HiveService();

  Future<(UserModel?, String?, String?)> login(String username, String password) async {
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
          return (userModel, data['title'] as String?, data['msg'] as String? ?? 'Berhasil masuk');
        } else {
          return (null, data['title'] as String?, (data['msg'] as String?) ?? 'Login gagal');
        }
      } else {
        // Even for non-200 status codes (like 400), the API might return a JSON with a 'msg'
        if (response.data != null && response.data is Map) {
          final title = response.data['title'] as String?;
          final msg = response.data['msg'] as String?;
          if (msg != null && msg.isNotEmpty) {
            return (null, title, msg);
          }
        }
        return (null, 'Error', 'Server Error: ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('Login Error: $e');
      return (null, 'Error', 'Terjadi kesalahan koneksi');
    }
  }

  Future<(UserModel?, bool, Map<String, dynamic>?, String?, String?)> checkVisitorCode(String invitationCode) async {
    try {
      final response = await _apiService.checkVisitorCode(invitationCode);

      if (response.statusCode == 200) {
        final data = response.data as Map<String, dynamic>;
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
            faceUrl: collection['visitor_face']?.toString() ?? collection['face_url']?.toString(),
            // Store complete raw collection as extraData
            extraData: json.encode(collection),
          );

          // Save to Hive only if already fully registered (has token)
          if (isPraregisterDone) {
            await _hiveService.saveUser(userModel);
          }

          return (userModel, isPraregisterDone, collection, data['msg'] as String?, data['title'] as String?);
        } else if (data['status'] == 'process') {
          return (null, false, data as Map<String, dynamic>?, data['msg'] as String?, data['title'] as String?);
        } else {
          return (null, false, null, (data['msg'] as String?), data['title'] as String?);
        }
      } else {
        // Handle error responses like 400 Bad Request
        String? title;
        String? msg;
        if (response.data is Map) {
          title = response.data['title']?.toString();
          msg = response.data['msg']?.toString();
        }
        return (null, false, null, msg ?? 'Kode undangan belum terdaftar atau tidak valid', title ?? 'Error');
      }
    } catch (e) {
      debugPrint('Check Visitor Code Error: $e');
      return (null, false, null, 'Terjadi kesalahan koneksi', 'Error');
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
    final user = await getAuthData();
    return user != null && user.token != null && user.token!.isNotEmpty;
  }

  Future<(bool, String?, String?)> logout() async {
    try {
      // Get the current token before clearing
      final user = _hiveService.getUser();
      final token = user?.token;

      bool isSuccess = true;
      String? revokeMsg;
      String? revokeTitle;
      
      // Call revoke token API if token exists (works for both Employee and Visitor)
      if (token != null && token.isNotEmpty) {
        final response = await _apiService.logoutResponse(token); // Use a new method that returns full Response
        if (response.data is Map) {
          revokeMsg = response.data['msg']?.toString();
          revokeTitle = response.data['title']?.toString();
          isSuccess = response.statusCode == 200 && response.data['status'] == 'success';
        }
      }

      // Always clear local session regardless of API result
      await _hiveService.removeUser();
      return (isSuccess, revokeMsg ?? 'Berhasil Logout', revokeTitle ?? (isSuccess ? 'Success' : 'Pemberitahuan'));
    } catch (e) {
      debugPrint('Logout Error: $e');
      // Still remove local data even if API call fails
      try {
        await _hiveService.removeUser();
      } catch (_) {}
      return (false, 'Terjadi kesalahan saat logout', 'Error');
    }
  }

  Future<(Map<String, dynamic>?, String?)> getProfile() async {
    try {
      final user = _hiveService.getUser();
      final token = user?.token;
      if (token == null) return (null, 'Token tidak ditemukan');

      final response = await _apiService.getProfile(token);
      if (response.statusCode == 200) {
        final data = response.data;
        if (data['status'] == 'success') {
          final collection = data['collection'] as Map<String, dynamic>;
          // Update Hive with new collection data if needed
          if (user != null) {
            final updatedUser = UserModel.fromJson({
              ...user.toJson(), // Start with old data
              ...collection, // Overwrite with fresh API data
              'extra_data': json.encode(collection),
            });
            await _hiveService.saveUser(updatedUser);
          }
          return (collection, data['msg'] as String?);
        }
        return (null, data['msg'] as String? ?? 'Gagal mengambil profil');
      }
      return (null, 'Server Error: ${response.statusCode}');
    } catch (e) {
      debugPrint('getProfile Error: $e');
      return (null, 'Terjadi kesalahan koneksi');
    }
  }

  Future<(bool, String?, String?)> updateProfile(
      Map<String, dynamic> payload) async {
    try {
      final user = _hiveService.getUser();
      final token = user?.token;
      if (token == null) return (false, 'Error', 'Token tidak ditemukan');

      final response = await _apiService.updateProfile(token, payload);
      if (response.statusCode == 200) {
        final data = response.data;
        if (data['status'] == 'success') {
          // Refresh Hive data after update
          await getProfile();
          return (
            true,
            data['title'] as String?,
            data['msg'] as String? ?? 'Berhasil update profil'
          );
        }
        return (
          false,
          data['title'] as String?,
          data['msg'] as String? ?? 'Gagal update profil'
        );
      }
      return (false, 'Error', 'Server Error: ${response.statusCode}');
    } catch (e) {
      debugPrint('updateProfile Error: $e');
      return (false, 'Error', 'Terjadi kesalahan koneksi');
    }
  }

  Future<void> clearDashboardData() async {
    await _hiveService.clearDashboardData();
  }
}
