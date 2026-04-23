import 'package:hive_flutter/hive_flutter.dart';
import '../models/user_model.dart';

class HiveService {
  static const String authBoxName = 'authBox';

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
}
