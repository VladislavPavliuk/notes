import 'package:flutter/material.dart';
import '../../models/note.dart';
import '../../services/note_service.dart';
import '../../widgets/stateful_button.dart';

class EditNoteScreen extends StatefulWidget {
  final Note note;

  const EditNoteScreen({super.key, required this.note});

  @override
  _EditNoteScreenState createState() => _EditNoteScreenState();
}

class _EditNoteScreenState extends State<EditNoteScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _titleController;
  late TextEditingController _contentController;
  final FocusNode _contentFocusNode = FocusNode();

  String? _errorMessage;
  ButtonState _buttonState = ButtonState.idle;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.note.title);
    _contentController = TextEditingController(text: widget.note.content);
  }

  Future<void> _saveNote() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _buttonState = ButtonState.loading;
      _errorMessage = null;
    });

    final noteService = NoteService();

    Note updatedNote = Note(
      id: widget.note.id,
      userId: widget.note.userId,
      title: _titleController.text.trim(),
      content: _contentController.text.trim(),
      createdAt: widget.note.createdAt,
      lastEditedAt: DateTime.now(),
    );

    try {
      await noteService.updateNote(updatedNote);
      setState(() {
        _buttonState = ButtonState.success;
      });
      await Future.delayed(const Duration(milliseconds: 500));
      if (!mounted) return;
      Navigator.pop(context, true);
    } catch (e) {
      setState(() {
        _buttonState = ButtonState.error;
        _errorMessage = 'Failed to update note';
      });
      await Future.delayed(const Duration(seconds: 2));
      setState(() {
        _buttonState = ButtonState.idle;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(), // hide keyboard on tap outside
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Edit Note'),
        ),
        body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: ListView(
              children: [
                TextFormField(
                  controller: _titleController,
                  decoration: const InputDecoration(
                    labelText: 'Title',
                    border: OutlineInputBorder(),
                  ),
                  textCapitalization: TextCapitalization.sentences,
                  textInputAction: TextInputAction.next,
                  keyboardType: TextInputType.text,
                  maxLength: 100,
                  onFieldSubmitted: (_) =>
                      FocusScope.of(context).requestFocus(_contentFocusNode),
                ),
                const SizedBox(height: 16.0),
                TextFormField(
                  controller: _contentController,
                  focusNode: _contentFocusNode,
                  decoration: const InputDecoration(
                    labelText: 'Content',
                    border: OutlineInputBorder(),
                  ),
                  keyboardType: TextInputType.multiline,
                  textInputAction: TextInputAction.newline,
                  textCapitalization: TextCapitalization.sentences,
                  maxLines: 10,
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Content cannot be empty';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16.0),
                if (_errorMessage != null) ...[
                  Text(
                    _errorMessage!,
                    style: const TextStyle(color: Colors.red),
                  ),
                  const SizedBox(height: 16.0),
                ],
                StatefulButton(
                  text: 'Save Changes',
                  state: _buttonState,
                  onPressed: _saveNote,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    _contentFocusNode.dispose();
    super.dispose();
  }
}
