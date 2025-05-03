import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../models/note.dart';
import '../../services/auth_service.dart';
import '../../services/note_service.dart';
import '../../widgets/stateful_button.dart';

class CreateNoteScreen extends StatefulWidget {
  const CreateNoteScreen({super.key});

  @override
  _CreateNoteScreenState createState() => _CreateNoteScreenState();
}

class _CreateNoteScreenState extends State<CreateNoteScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _contentController = TextEditingController();

  final _titleFocusNode = FocusNode();
  final _contentFocusNode = FocusNode();

  String? _errorMessage;
  ButtonState _buttonState = ButtonState.idle;

  Future<void> _saveNote() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _buttonState = ButtonState.loading;
      _errorMessage = null;
    });

    final authService = Provider.of<AuthService>(context, listen: false);
    final noteService = NoteService();
    final user = await authService.getCurrentUser();

    if (user == null) {
      setState(() {
        _buttonState = ButtonState.error;
        _errorMessage = 'User not authenticated';
      });
      await Future.delayed(const Duration(seconds: 2));
      setState(() {
        _buttonState = ButtonState.idle;
      });
      return;
    }

    Note newNote = Note(
      userId: user.id!,
      title: _titleController.text.trim(),
      content: _contentController.text.trim(),
      createdAt: DateTime.now(),
      lastEditedAt: DateTime.now(),
    );

    try {
      await noteService.createNote(newNote);
      setState(() {
        _buttonState = ButtonState.success;
      });
      await Future.delayed(const Duration(milliseconds: 500));
      if (!mounted) return;
      Navigator.pop(context, true);
    } catch (e) {
      setState(() {
        _buttonState = ButtonState.error;
        _errorMessage = 'Failed to save note';
      });
      await Future.delayed(const Duration(seconds: 2));
      setState(() {
        _buttonState = ButtonState.idle;
      });
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    _titleFocusNode.dispose();
    _contentFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(), // hide keyboard on tap outside
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Create Note'),
        ),
        body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: ListView(
              children: [
                TextFormField(
                  controller: _titleController,
                  focusNode: _titleFocusNode,
                  textInputAction: TextInputAction.next,
                  textCapitalization: TextCapitalization.sentences,
                  inputFormatters: [
                    LengthLimitingTextInputFormatter(100),
                    FilteringTextInputFormatter.allow(RegExp(r'[a-zA-Zа-яА-Я0-9\s.,!?()\-]')),
                  ],
                  onFieldSubmitted: (_) {
                    FocusScope.of(context).requestFocus(_contentFocusNode);
                  },
                  decoration: const InputDecoration(
                    labelText: 'Title',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 16.0),
                TextFormField(
                  controller: _contentController,
                  focusNode: _contentFocusNode,
                  keyboardType: TextInputType.multiline,
                  textInputAction: TextInputAction.newline,
                  maxLines: 10,
                  textCapitalization: TextCapitalization.sentences,
                  decoration: const InputDecoration(
                    labelText: 'Content',
                    border: OutlineInputBorder(),
                  ),
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
                  text: 'Save',
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
}
