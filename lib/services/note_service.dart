import '../models/note.dart';
import 'database_helper.dart';

class NoteService {
  final DatabaseHelper _dbHelper = DatabaseHelper();

  Future<int> createNote(Note note) async {
    final db = await _dbHelper.database;
    return await db.insert('notes', note.toMap());
  }

  Future<List<Note>> getNotes(int userId) async {
    final db = await _dbHelper.database;

    final List<Map<String, dynamic>> maps = await db.query(
      'notes',
      where: 'userId = ?',
      whereArgs: [userId],
      orderBy: 'lastEditedAt DESC, createdAt DESC',
    );

    return List.generate(maps.length, (i) {
      return Note.fromMap(maps[i]);
    });
  }

  Future<Note?> getNoteById(int id) async {
    final db = await _dbHelper.database;

    final List<Map<String, dynamic>> maps = await db.query(
      'notes',
      where: 'id = ?',
      whereArgs: [id],
    );

    if (maps.isEmpty) return null;

    return Note.fromMap(maps.first);
  }

  Future<int> updateNote(Note note) async {
    final db = await _dbHelper.database;

    return await db.update(
      'notes',
      note.toMap(),
      where: 'id = ?',
      whereArgs: [note.id],
    );
  }

  Future<int> deleteNote(int id) async {
    final db = await _dbHelper.database;

    return await db.delete(
      'notes',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // ➕ нова функція для зміни isFavorite
  Future<int> toggleFavorite(int noteId, bool isFavorite) async {
    final db = await _dbHelper.database;

    return await db.update(
      'notes',
      {
        'isFavorite': isFavorite ? 1 : 0,
        'lastEditedAt': DateTime.now().toIso8601String(),
      },
      where: 'id = ?',
      whereArgs: [noteId],
    );
  }
}
