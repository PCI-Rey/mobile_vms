import 'dart:convert';
import 'package:hive_flutter/hive_flutter.dart';
import '../models/user_model.dart';
import '../models/access_pass_model.dart';

class HiveService {
  static const String authBoxName = 'authBox';
  static const String dashboardBoxName = 'dashboardBox';

  Future<void> saveUser(UserModel user) async {
    final box = Hive.box(authBoxName);
    // Serialize object to JSON string because we are not using TypeAdapter
    await box.put('user', user.toRawJson());
  }

  UserModel? getUser() {
    final box = Hive.box(authBoxName);
    final userJson = box.get('user');

    // Deserialize JSON string back to object
    if (userJson != null && userJson is String) {
      try {
        return UserModel.fromRawJson(userJson);
      } catch (e) {
        return null;
      }
    }
    return null;
  }

  Future<void> removeUser() async {
    final box = Hive.box(authBoxName);
    await box.delete('user');
  }

  bool hasUser() {
    final box = Hive.box(authBoxName);
    return box.containsKey('user');
  }

  // --- Dashboard Persistence ---

  Future<void> saveAccessPasses(List<AccessPassModel> passes) async {
    final box = Hive.box(dashboardBoxName);
    final List<String> passesJson = passes.map((e) => e.toRawJson()).toList();
    await box.put('access_passes', passesJson);
  }

  List<AccessPassModel> getAccessPasses() {
    final box = Hive.box(dashboardBoxName);
    final List<dynamic>? passesJson = box.get('access_passes');

    if (passesJson == null) return [];

    return passesJson
        .map((e) {
          try {
            return AccessPassModel.fromRawJson(e as String);
          } catch (_) {
            return null;
          }
        })
        .whereType<AccessPassModel>()
        .toList();
  }

  Future<void> clearDashboardData() async {
    final box = Hive.box(dashboardBoxName);
    await box.clear();
  }

  // --- Sites Cache ---

  Future<void> saveSites(List<Map<String, String>> sites) async {
    final box = Hive.box(dashboardBoxName);
    await box.put('cached_sites', json.encode(sites));
  }

  List<Map<String, String>> getSites() {
    final box = Hive.box(dashboardBoxName);
    final raw = box.get('cached_sites');
    if (raw == null || raw is! String) return [];
    try {
      final List<dynamic> decoded = json.decode(raw);
      return decoded.map((e) {
        final map = e as Map<String, dynamic>;
        return {
          'id': map['id']?.toString() ?? '',
          'name': map['name']?.toString() ?? '',
        };
      }).toList();
    } catch (_) {
      return [];
    }
  }
}
