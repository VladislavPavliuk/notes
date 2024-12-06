import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/note.dart';
import '../../services/auth_service.dart';
import '../../services/note_service.dart';
import '../../widgets/custom_drawer.dart';
import '../../widgets/note_card.dart';
import 'create_note_screen.dart';
import 'note_detail_screen.dart';

class NotesListScreen extends StatefulWidget {
  const NotesListScreen({super.key});

  @override
  _NotesListScreenState createState() => _NotesListScreenState();
}

class _NotesListScreenState extends State<NotesListScreen> {
  final NoteService _noteService = NoteService();
  List<Note> _notes = [];
  bool _isLoading = true;

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: const CustomDrawer(),
      appBar: AppBar(
        title: const Text('My Notes'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _notes.isEmpty
          ? const Center(child: Text('No notes found.'))
          : RefreshIndicator(
        onRefresh: _loadNotes,
        child: ListView.builder(
          itemCount: _notes.length,
          itemBuilder: (context, index) {
            return NoteCard(
              note: _notes[index],
              onTap: () {
                _navigateToNoteDetail(_notes[index].id!);
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
