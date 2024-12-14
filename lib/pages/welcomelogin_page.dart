import 'package:aichatapp/pages/register_page.dart';
import 'package:aichatapp/services/auth/auth_service.dart';
import 'package:flutter/material.dart';

class WelcomeloginPage extends StatefulWidget {
  const WelcomeloginPage({super.key});

  @override
  State<WelcomeloginPage> createState() => _WelcomeloginPageState();
}

class _WelcomeloginPageState extends State<WelcomeloginPage> {
  late bool _showWelcome = true;

  void _goToLogin() {
    setState(() {
      _showWelcome = false;
    });
  }

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
        body: Center(
            child:
                _showWelcome ? _buildWelcomeContent() : _buildLoginContent()));
  }

  Widget _buildWelcomeContent() {
    return Container(
      alignment: Alignment.center,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // TODO: Add Vector Animation
          const Text(
            "Hello, it's AI Ally!",
            style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold),
          ),
          const SizedBox(
            height: 12,
          ),
          const Text(
            "Welcome to our AI assistant app!\nWe're excited to have you on\nboard. Here are a few steps to\nhelp you get started.",
            textAlign: TextAlign.center,
            style: TextStyle(fontWeight: FontWeight.w400),
          ),
          const SizedBox(
            height: 24,
          ),
          ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.black,
                minimumSize: const Size(160, 50),
              ),
              onPressed: _goToLogin,
              child: const Text(
                "Next",
                style: TextStyle(color: Colors.white),
              )),
        ],
      ),
    );
  }

  Widget _buildLoginContent() {
    return Container(
      key: const ValueKey('login'),
      alignment: Alignment.center,
      child: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 50),
        children: [
          const SizedBox(
            height: 24,
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
              obscureText: true,
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
    );
  }
}
