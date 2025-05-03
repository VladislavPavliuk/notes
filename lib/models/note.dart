class Note {
  final int? id;
  final int userId;
  final String title;
  final String content;
  final DateTime createdAt;
  final DateTime? lastEditedAt;
  bool isFavorite; // ➕ додано

  Note({
    this.id,
    required this.userId,
    required this.title,
    required this.content,
    required this.createdAt,
    this.lastEditedAt,
    this.isFavorite = false, // ➕ дефолтне значення
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'userId': userId,
      'title': title,
      'content': content,
      'createdAt': createdAt.toIso8601String(),
      'lastEditedAt': lastEditedAt?.toIso8601String(),
      'isFavorite': isFavorite ? 1 : 0, // ➕ збереження як int
    };
  }

  factory Note.fromMap(Map<String, dynamic> map) {
    return Note(
      id: map['id'],
      userId: map['userId'],
      title: map['title'],
      content: map['content'],
      createdAt: DateTime.parse(map['createdAt']),
      lastEditedAt: map['lastEditedAt'] != null ? DateTime.parse(map['lastEditedAt']) : null,
      isFavorite: map['isFavorite'] == 1, // ➕ читання як bool
    );
  }
}
