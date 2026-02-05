import '../models/user_model.dart';


// Static data tetap ada untuk referensi
final dummyUsers = [
  UserModel(
    id: 1,
    name: 'Guest User',
    username: 'guest',
    email: 'guest@example.com',
    phone: '081234567890',
    password: '123456',
    role: 'guest',
    token: 'guest-token',
  ),
  UserModel(
    id: 2,
    name: 'Operator User',
    username: 'operator',
    email: 'operator@example.com',
    password: '123456',
    phone: '081234567891',
    role: 'operator',
    token: 'operator-token',
  ),
  UserModel(
    id: 3,
    name: 'Employee User',
    username: 'employee',
    email: 'employee@example.com',
    password: '123456',
    phone: '081234567892',
    role: 'employee',
    token: 'employee-token',
  ),
];

