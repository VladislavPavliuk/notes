import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../services/auth_service.dart';
import '../notes/notes_list_screen.dart';
import '../../widgets/stateful_button.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  _SignupScreenState createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _nameController = TextEditingController();

  String? _errorMessage;
  ButtonState _buttonState = ButtonState.idle;

  String? _validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return 'Email is required';
    }
    final emailRegExp = RegExp(r'^[^@]+@[^@]+\.[^@]+');
    if (!emailRegExp.hasMatch(value)) {
      return 'Enter a valid email';
    }
    return null;
  }

  String? _validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Password is required';
    }
    if (value.length < 7) {
      return 'Password must be at least 7 characters';
    }
    return null;
  }

  String? _validateName(String? value) {
    if (value == null || value.isEmpty) {
      return 'Name is required';
    }
    return null;
  }

  Future<void> _register() async {
    setState(() {
      _buttonState = ButtonState.loading;
      _errorMessage = null;
    });

    final authService = Provider.of<AuthService>(context, listen: false);
    bool success = await authService.registerUser(
      _nameController.text.trim(),
      _emailController.text.trim(),
      _passwordController.text,
    );

    if (success) {
      bool loginSuccess = await authService.loginUser(
        _emailController.text.trim(),
        _passwordController.text,
      );

      if (loginSuccess) {
        setState(() {
          _buttonState = ButtonState.success;
        });

        await Future.delayed(const Duration(milliseconds: 500));

        if (!mounted) return;
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => const NotesListScreen()),
              (route) => false,
        );
      }
    } else {
      setState(() {
        _buttonState = ButtonState.error;
        _errorMessage = 'Email already in use';
      });

      await Future.delayed(const Duration(seconds: 2));

      setState(() {
        _buttonState = ButtonState.idle;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Sign Up'),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: <Widget>[
              const SizedBox(height: 40.0),
              Center(
                child: Image.network(
                  "https://upload.wikimedia.org/wikipedia/commons/thumb/4/44/Google-flutter-logo.svg/1024px-Google-flutter-logo.svg.png",
                  width: 200,
                ),
              ),
              const SizedBox(height: 24.0),

              const Text(
                'Sign up',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24.0),

              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: 'Name:',
                  border: OutlineInputBorder(),
                ),
                validator: _validateName,
              ),
              const SizedBox(height: 16.0),

              TextFormField(
                controller: _emailController,
                decoration: const InputDecoration(
                  labelText: 'Email:',
                  border: OutlineInputBorder(),
                ),
                validator: _validateEmail,
              ),
              const SizedBox(height: 16.0),

              TextFormField(
                controller: _passwordController,
                obscureText: true,
                decoration: const InputDecoration(
                  labelText: 'Password:',
                  border: OutlineInputBorder(),
                ),
                validator: _validatePassword,
              ),
              const SizedBox(height: 24.0),

              if (_errorMessage != null) ...[
                Text(
                  _errorMessage!,
                  style: const TextStyle(color: Colors.red),
                ),
                const SizedBox(height: 16.0),
              ],

              StatefulButton(
                text: "Sign up",
                state: _buttonState,
                onPressed: () {
                  if (_formKey.currentState!.validate()) {
                    _register();
                  }
                },
              ),
              const SizedBox(height: 16.0),

              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                child: const Text('Back'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _nameController.dispose();
    super.dispose();
  }
}
