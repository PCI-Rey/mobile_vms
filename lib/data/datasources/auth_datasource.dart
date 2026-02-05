import 'dart:async';

import '../../data/datasources/dummy_data.dart';
import '../../data/models/user_model.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/foundation.dart';

class AuthDatasource {
  Future<UserModel> login(String username, String password) async {
    final user = dummyUsers.where((u) => u.username == username).toList();

    if (user.isEmpty) {
      throw Exception('Harap masukkan username yang valid');
    }

    if (user.first.password != password) {
      throw Exception('Harap masukkan username yang valid');
    }

    return user.first;
  }

  Future<void> saveAuthData(UserModel userModel) async {
    final prefs = await SharedPreferences.getInstance();

    await prefs.setString('auth_data_user', userModel.toRawJson());
  }

  Future<void> removeAuthData() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('auth_data_user');
  }

  Future<UserModel?> getAuthData() async {
    final prefs = await SharedPreferences.getInstance();
    final authData = prefs.getString('auth_data_user');
    if (authData != null) {
      return UserModel.fromRawJson(authData);
    }
    return null;
  }

  Future<bool> isAuthDataExist() async {
    try {
      debugPrint('>>> SharedPreferences.getInstance() calling');
      final prefs = await SharedPreferences.getInstance().timeout(
        const Duration(seconds: 5),
        onTimeout: () =>
            throw TimeoutException('SharedPreferences.getInstance timeout'),
      );
      debugPrint('>>> SharedPreferences acquired: $prefs');
      return prefs.containsKey('auth_data_user');
    } catch (e, st) {
      debugPrint('!!! isAuthDataExist error: $e');
      debugPrint('$st');
      rethrow;
    }
  }

  Future<bool> logout() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      if (prefs.containsKey('auth_data_user')) {
        await prefs.remove('auth_data_user');
      }
      return true;
    } catch (e, st) {
      debugPrint('logout error: $e');
      debugPrint('$st');
      return false;
    }
  }
}
