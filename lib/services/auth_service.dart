import 'package:bcrypt/bcrypt.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user.dart';
import 'database_helper.dart';
import 'package:flutter/material.dart';

class AuthService extends ChangeNotifier {
  final DatabaseHelper _dbHelper = DatabaseHelper();
  User? _currentUser;

  User? get currentUser => _currentUser;

  Future<bool> registerUser(String name, String email, String password) async {
    final db = await _dbHelper.database;

    final List<Map<String, dynamic>> existingUsers = await db.query(
      'users',
      where: 'email = ?',
      whereArgs: [email],
    );

    if (existingUsers.isNotEmpty) {
      return false;
    }

    String hashedPassword = BCrypt.hashpw(password, BCrypt.gensalt());

    User newUser = User(
      name: name,
      email: email,
      passwordHash: hashedPassword,
      createdAt: DateTime.now(),
    );

    await db.insert('users', newUser.toMap());

    return true;
  }

  Future<bool> loginUser(String email, String password) async {
    final db = await _dbHelper.database;

    final List<Map<String, dynamic>> users = await db.query(
      'users',
      where: 'email = ?',
      whereArgs: [email],
    );

    if (users.isEmpty) return false;

    User user = User.fromMap(users.first);
    bool passwordVerified = BCrypt.checkpw(password, user.passwordHash);

    if (!passwordVerified) return false;

    await db.update(
      'users',
      {'lastLoginAt': DateTime.now().toIso8601String()},
      where: 'id = ?',
      whereArgs: [user.id],
    );

    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setInt('userId', user.id!);

    _currentUser = user;
    notifyListeners();

    return true;
  }

  Future<void> logout() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.remove('userId');

    _currentUser = null;
    notifyListeners();
  }

  Future<User?> getCurrentUser() async {
    if (_currentUser != null) return _currentUser;

    SharedPreferences prefs = await SharedPreferences.getInstance();
    int? userId = prefs.getInt('userId');

    if (userId == null) return null;

    final db = await _dbHelper.database;

    final List<Map<String, dynamic>> users = await db.query(
      'users',
      where: 'id = ?',
      whereArgs: [userId],
    );

    if (users.isEmpty) return null;

    _currentUser = User.fromMap(users.first);
    return _currentUser;
  }

  Future<void> deleteAccount() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    int? userId = prefs.getInt('userId');

    if (userId == null) return;

    final db = await _dbHelper.database;

    await db.delete(
      'users',
      where: 'id = ?',
      whereArgs: [userId],
    );

    await prefs.remove('userId');
    _currentUser = null;
    notifyListeners();
  }

  Future<bool> verifyPassword(int userId, String password) async {
    final db = await _dbHelper.database;

    final List<Map<String, dynamic>> users = await db.query(
      'users',
      columns: ['passwordHash'],
      where: 'id = ?',
      whereArgs: [userId],
    );

    if (users.isEmpty) return false;

    String storedHash = users.first['passwordHash'];
    return BCrypt.checkpw(password, storedHash);
  }
}
