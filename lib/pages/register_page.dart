import 'package:aichatapp/services/auth/auth_service.dart';
import 'package:flutter/material.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final authService = AuthService();

  final _usernameControllers = TextEditingController();
  final _emailControllers = TextEditingController();
  final _passwordControllers = TextEditingController();
  final _confirmPasswordControllers = TextEditingController();

  void signUp() async {
    final username = _usernameControllers.text;
    final email = _emailControllers.text;
    final password = _passwordControllers.text;
    final confirmPassword = _confirmPasswordControllers.text;

    if (password != confirmPassword) {
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text("Password don't match")));
      return;
    }

    if (username.isEmpty) {
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text("Username is required!")));
      return;
    }

    try {
      await authService.signUpWithEmailPassword(email, password, username);

      Navigator.pop(context);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text("Error: $e")));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        iconTheme: const IconThemeData(
          color: Colors.white,
          size: 20,
        ),
        title: const Text(
          "Sign Up",
          style: TextStyle(color: Colors.white, fontSize: 20),
        ),
        backgroundColor: Colors.black,
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 50),
        children: [
          TextField(
            controller: _usernameControllers,
            decoration: const InputDecoration(labelText: 'Username'),
            style: const TextStyle(color: Colors.white),
          ),
          const SizedBox(
            height: 12,
          ),
          TextField(
            controller: _emailControllers,
            decoration: const InputDecoration(labelText: 'Email'),
            style: const TextStyle(color: Colors.white),
          ),
          const SizedBox(
            height: 12,
          ),
          TextField(
            controller: _passwordControllers,
            obscureText: true,
            decoration: const InputDecoration(labelText: 'Password'),
            style: const TextStyle(color: Colors.white),
          ),
          const SizedBox(
            height: 12,
          ),
          TextField(
            controller: _confirmPasswordControllers,
            obscureText: true,
            decoration: const InputDecoration(labelText: 'Confirm Password'),
            style: const TextStyle(color: Colors.white),
          ),
          const SizedBox(
            height: 24,
          ),
          ElevatedButton(
              onPressed: signUp,
              child: const Text(
                "Sign Up",
                style: TextStyle(color: Colors.black),
              ))
        ],
      ),
      backgroundColor: Colors.black,
    );
  }
}
