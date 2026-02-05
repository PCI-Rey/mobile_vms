import 'dart:convert';

class UserModel {
  final int id;
  final String name;
  final String username;
  final String? email;
  final String? phone;
  final String role;
  final String password;
  final String? token;

  UserModel({
    required this.id,
    required this.name,
    required this.username,
    required this.password,
    this.email,
    this.phone,
    required this.role,
    this.token,
  });

  factory UserModel.fromRawJson(String str) =>
      UserModel.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'],
      name: json['name'],
      username: json['username'],
      password: json['password'],
      email: json['email'],
      phone: json['phone'],
      role: json['role'],
      token: json['token'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'username': username,
      'password': password,
      'email': email,
      'phone': phone,
      'role': role,
      'token': token,
    };
  }
}
