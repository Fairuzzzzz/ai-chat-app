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
          color: Colors.blue,
          size: 20,
        ),
        title: const Text(
          "Sign Up",
          style: TextStyle(color: Colors.black, fontSize: 20),
        ),
        backgroundColor: Colors.white,
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 40),
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
            decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.blue)),
            child: TextField(
              controller: _usernameControllers,
              decoration: const InputDecoration(
                  labelText: 'Username',
                  labelStyle: TextStyle(fontSize: 14, color: Colors.grey),
                  contentPadding: EdgeInsets.symmetric(horizontal: 2),
                  isDense: true,
                  border: InputBorder.none),
              style: const TextStyle(color: Colors.black),
            ),
          ),
          const SizedBox(
            height: 18,
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
            decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.blue)),
            child: TextField(
              controller: _emailControllers,
              decoration: const InputDecoration(
                  labelText: 'Email',
                  labelStyle: TextStyle(fontSize: 14, color: Colors.grey),
                  contentPadding: EdgeInsets.symmetric(horizontal: 2),
                  isDense: true,
                  border: InputBorder.none),
              style: const TextStyle(color: Colors.black),
            ),
          ),
          const SizedBox(
            height: 18,
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
            decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.blue)),
            child: TextField(
              controller: _passwordControllers,
              obscureText: true,
              decoration: const InputDecoration(
                  labelText: 'Password',
                  labelStyle: TextStyle(fontSize: 14, color: Colors.grey),
                  contentPadding: EdgeInsets.symmetric(horizontal: 2),
                  isDense: true,
                  border: InputBorder.none),
              style: const TextStyle(color: Colors.black),
            ),
          ),
          const SizedBox(
            height: 18,
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
            decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.blue)),
            child: TextField(
              controller: _confirmPasswordControllers,
              obscureText: true,
              decoration: const InputDecoration(
                  labelText: 'Confirm Password',
                  labelStyle: TextStyle(fontSize: 14, color: Colors.grey),
                  contentPadding: EdgeInsets.symmetric(horizontal: 2),
                  isDense: true,
                  border: InputBorder.none),
              style: const TextStyle(color: Colors.black),
            ),
          ),
          const SizedBox(
            height: 24,
          ),
          ElevatedButton(
              style: const ButtonStyle(
                  backgroundColor: WidgetStatePropertyAll(Colors.blue)),
              onPressed: signUp,
              child: const Text(
                "Sign Up",
                style: TextStyle(color: Colors.white),
              ))
        ],
      ),
      backgroundColor: Colors.white,
    );
  }
}
