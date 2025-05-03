import 'package:flutter/material.dart';
import '../../models/note.dart';
import '../../services/note_service.dart';
import 'edit_note_screen.dart';

class NoteDetailScreen extends StatefulWidget {
  final int noteId;

  const NoteDetailScreen({Key? key, required this.noteId}) : super(key: key);

  @override
  _NoteDetailScreenState createState() => _NoteDetailScreenState();
}

class _NoteDetailScreenState extends State<NoteDetailScreen> {
  final NoteService _noteService = NoteService();
  bool _isLoading = true;
  Note? _note;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadNote();
  }

  Future<void> _loadNote() async {
    try {
      Note? note = await _noteService.getNoteById(widget.noteId);
      if (note != null) {
        setState(() {
          _note = note;
          _isLoading = false;
        });
      } else {
        setState(() {
          _errorMessage = 'Note not found';
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Failed to load note';
        _isLoading = false;
      });
    }
  }

  Future<void> _deleteNote() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Note'),
        content: const Text('Are you sure you want to delete this note?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text(
              'Delete',
              style: TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );

    if (confirm == true && _note != null) {
      await _noteService.deleteNote(_note!.id!);
      Navigator.pop(context, true);
    }
  }

  Future<void> _navigateToEditNote() async {
    if (_note == null) return;

    bool? noteUpdated = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => EditNoteScreen(note: _note!),
      ),
    );

    if (noteUpdated == true) {
      await _loadNote();
      Navigator.pop(context, true);
    }
  }

  String _formatDate(DateTime date) {
    return "${date.day.toString().padLeft(2, '0')}/"
        "${date.month.toString().padLeft(2, '0')}/"
        "${date.year} ${date.hour}:${date.minute.toString().padLeft(2, '0')}";
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(), // for future keyboard dismiss
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Note Details'),
          actions: [
            IconButton(
              icon: const Icon(Icons.edit),
              onPressed: _navigateToEditNote,
              tooltip: 'Edit Note',
            ),
            IconButton(
              icon: const Icon(Icons.delete),
              onPressed: _deleteNote,
              tooltip: 'Delete Note',
            ),
          ],
        ),
        body: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : _errorMessage != null
            ? Center(
          child: Text(
            _errorMessage!,
            style: const TextStyle(color: Colors.red, fontSize: 18),
            textAlign: TextAlign.center,
          ),
        )
            : Padding(
          padding: const EdgeInsets.all(16.0),
          child: ListView(
            children: [
              Text(
                _note!.title.trim().isEmpty ? 'Untitled' : _note!.title,
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8.0),
              Text(
                _formatDate(_note!.lastEditedAt ?? _note!.createdAt),
                style: const TextStyle(color: Colors.grey, fontSize: 14),
              ),
              const SizedBox(height: 16.0),
              SelectableText(
                _note!.content.trim().isEmpty
                    ? '[No content]'
                    : _note!.content,
                style: const TextStyle(fontSize: 18),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
