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
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 50),
        children: [
          const SizedBox(
            height: 24,
          ),
          const Center(
            child: Text(
              'Welcome Back!',
              style: TextStyle(fontSize: 24),
            ),
          ),
          const SizedBox(
            height: 24,
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
            decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.black)),
            child: TextField(
              controller: _emailControllers,
              decoration: const InputDecoration(
                contentPadding: EdgeInsets.symmetric(horizontal: 2),
                labelText: 'Email',
                labelStyle: TextStyle(fontSize: 14),
                isDense: true,
                border: InputBorder.none,
              ),
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
                border: Border.all(color: Colors.black)),
            child: TextField(
              controller: _passwordControllers,
              decoration: const InputDecoration(
                  labelText: 'Password',
                  labelStyle: TextStyle(fontSize: 14),
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
              style: ButtonStyle(
                  backgroundColor: WidgetStateProperty.all(Colors.black)),
              onPressed: login,
              child: const Text(
                "Login",
                style: TextStyle(color: Colors.white),
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
                style: TextStyle(color: Colors.black),
              ),
            ),
          )
        ],
      ),
      backgroundColor: Colors.white,
    );
  }
}
