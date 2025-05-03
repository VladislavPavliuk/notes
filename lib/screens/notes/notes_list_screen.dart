import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/note.dart';
import '../../services/auth_service.dart';
import '../../services/note_service.dart';
import '../../widgets/custom_drawer.dart';
import '../../widgets/note_card.dart';
import 'create_note_screen.dart';
import 'note_detail_screen.dart';

enum SortOption { date, title }

class NotesListScreen extends StatefulWidget {
  const NotesListScreen({super.key});

  @override
  _NotesListScreenState createState() => _NotesListScreenState();
}

class _NotesListScreenState extends State<NotesListScreen> {
  final NoteService _noteService = NoteService();
  List<Note> _notes = [];
  bool _isLoading = true;
  bool _showFavoritesOnly = false;
  SortOption _sortOption = SortOption.date;

  @override
  void initState() {
    super.initState();
    _loadNotes();
  }

  Future<void> _loadNotes() async {
    final authService = Provider.of<AuthService>(context, listen: false);
    final user = await authService.getCurrentUser();

    if (user != null) {
      List<Note> notes = await _noteService.getNotes(user.id!);
      setState(() {
        _notes = notes;
        _isLoading = false;
      });
    } else {
      Navigator.pushReplacementNamed(context, '/sign_in');
    }
  }

  List<Note> get _filteredAndSortedNotes {
    List<Note> filtered = _showFavoritesOnly
        ? _notes.where((note) => note.isFavorite).toList()
        : List.from(_notes);

    switch (_sortOption) {
      case SortOption.title:
        filtered.sort((a, b) => a.title.toLowerCase().compareTo(b.title.toLowerCase()));
        break;
      case SortOption.date:
        filtered.sort((a, b) => (b.lastEditedAt ?? b.createdAt).compareTo(a.lastEditedAt ?? a.createdAt));
        break;
    }
    return filtered;
  }

  Future<void> _navigateToCreateNote() async {
    bool? noteCreated = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const CreateNoteScreen()),
    );

    if (noteCreated == true) {
      _loadNotes();
    }
  }

  Future<void> _navigateToNoteDetail(int noteId) async {
    bool? noteChanged = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => NoteDetailScreen(noteId: noteId),
      ),
    );

    if (noteChanged == true) {
      _loadNotes();
    }
  }

  Future<void> _deleteNote(Note note) async {
    await _noteService.deleteNote(note.id!);
    _loadNotes();
  }

  Future<void> _toggleFavorite(Note note) async {
    final updatedNote = Note(
      id: note.id,
      userId: note.userId,
      title: note.title,
      content: note.content,
      createdAt: note.createdAt,
      lastEditedAt: DateTime.now(),
    )..isFavorite = !note.isFavorite;

    await _noteService.updateNote(updatedNote);
    _loadNotes();
  }

  void _showSortOptions() {
    showModalBottomSheet(
      context: context,
      builder: (context) => Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          RadioListTile<SortOption>(
            title: const Text('Sort by date'),
            value: SortOption.date,
            groupValue: _sortOption,
            onChanged: (value) {
              setState(() {
                _sortOption = value!;
              });
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Sorted by date')),
              );
            },
          ),
          RadioListTile<SortOption>(
            title: const Text('Sort by title'),
            value: SortOption.title,
            groupValue: _sortOption,
            onChanged: (value) {
              setState(() {
                _sortOption = value!;
              });
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Sorted by title')),
              );
            },
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: const CustomDrawer(),
      appBar: AppBar(
        title: const Text('My Notes'),
        actions: [
          Row(
            children: [
              const Text('Favorites'),
              Switch(
                value: _showFavoritesOnly,
                onChanged: (value) {
                  setState(() {
                    _showFavoritesOnly = value;
                  });
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(value ? 'Showing favorites only' : 'Showing all notes'),
                    ),
                  );
                },
              ),
              IconButton(
                icon: const Icon(Icons.sort),
                onPressed: _showSortOptions,
                tooltip: 'Sort Notes',
              ),
            ],
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _filteredAndSortedNotes.isEmpty
          ? const Center(child: Text('No notes found.'))
          : RefreshIndicator(
        onRefresh: _loadNotes,
        child: ListView.builder(
          itemCount: _filteredAndSortedNotes.length,
          itemBuilder: (context, index) {
            final note = _filteredAndSortedNotes[index];
            return NoteCard(
              note: note,
              onTap: () {
                _navigateToNoteDetail(note.id!);
              },
              onDelete: () {
                _deleteNote(note);
              },
              onEdit: () {
                _navigateToNoteDetail(note.id!);
              },
              onToggleFavorite: () async {
                await _toggleFavorite(note);
              },
            );
          },
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _navigateToCreateNote,
        child: const Icon(Icons.add),
      ),
    );
  }
}
