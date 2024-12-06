import '../models/user.dart';
import 'database_helper.dart';
import 'package:bcrypt/bcrypt.dart';

class UserService {
  final DatabaseHelper _dbHelper = DatabaseHelper();

  Future<User?> getUserById(int userId) async {
    final db = await _dbHelper.database;

    final List<Map<String, dynamic>> users = await db.query(
      'users',
      where: 'id = ?',
      whereArgs: [userId],
    );

    if (users.isEmpty) return null;

    return User.fromMap(users.first);
  }

  Future<bool> updateUser(int userId, String name, String email) async {
    final db = await _dbHelper.database;

    final List<Map<String, dynamic>> existingUsers = await db.query(
      'users',
      where: 'email = ? AND id != ?',
      whereArgs: [email, userId],
    );

    if (existingUsers.isNotEmpty) {
      return false;
    }

    await db.update(
      'users',
      {
        'name': name,
        'email': email,
      },
      where: 'id = ?',
      whereArgs: [userId],
    );

    return true;
  }

  Future<void> changePassword(int userId, String newPassword) async {
    final db = await _dbHelper.database;

    String hashedPassword = BCrypt.hashpw(newPassword, BCrypt.gensalt());

    await db.update(
      'users',
      {'passwordHash': hashedPassword},
      where: 'id = ?',
      whereArgs: [userId],
    );
  }
}
