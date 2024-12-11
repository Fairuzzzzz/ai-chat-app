import 'package:aichatapp/pages/register_page.dart';
import 'package:aichatapp/services/auth/auth_service.dart';
import 'package:flutter/material.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final authService = AuthService();

  final _emailControllers = TextEditingController();
  final _passwordControllers = TextEditingController();

  void login() async {
    final email = _emailControllers.text;
    final password = _passwordControllers.text;

    if (email.isEmpty) {
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('Email is required!')));
    }

    if (password.isEmpty) {
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('Password is required!')));
    }

    // attempt
    try {
      await authService.signInWithEmailPassword(email, password);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('Error: $e')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 50),
        children: [
          const SizedBox(
            height: 24,
          ),
          Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
            ),
            child: TextField(
              controller: _emailControllers,
              decoration: const InputDecoration(
                labelText: 'Email',
              ),
              style: const TextStyle(color: Colors.white),
            ),
          ),
          const SizedBox(
            height: 12,
          ),
          TextField(
            controller: _passwordControllers,
            decoration: const InputDecoration(labelText: 'Password'),
            style: const TextStyle(color: Colors.white),
          ),
          const SizedBox(
            height: 24,
          ),
          ElevatedButton(
              onPressed: login,
              child: const Text(
                "Login",
                style: TextStyle(color: Colors.black),
              )),
          const SizedBox(
            height: 12,
          ),
          GestureDetector(
            onTap: () => Navigator.push(context,
                MaterialPageRoute(builder: (context) => const RegisterPage())),
            child: const Center(
              child: Text(
                "Don't have an account? Sign Up",
                style: TextStyle(color: Colors.white),
              ),
            ),
          )
        ],
      ),
      backgroundColor: Colors.black,
    );
  }
}
