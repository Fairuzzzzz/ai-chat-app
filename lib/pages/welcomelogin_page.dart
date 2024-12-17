import 'package:aichatapp/pages/register_page.dart';
import 'package:aichatapp/services/auth/auth_service.dart';
import 'package:flutter/material.dart';

class WelcomeloginPage extends StatefulWidget {
  const WelcomeloginPage({super.key});

  @override
  State<WelcomeloginPage> createState() => _WelcomeloginPageState();
}

class _WelcomeloginPageState extends State<WelcomeloginPage> {
  bool _showWelcome = true;

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
      body: Stack(children: [
        Positioned(
          top: MediaQuery.of(context).size.height - 360 - 50,
          left: MediaQuery.of(context).size.width / 26,
          child: GestureDetector(
            onTap: () {
              setState(() {
                _showWelcome = true;
              });
            },
            child: Visibility(
              visible: !_showWelcome,
              child: Container(
                width: 40,
                height: 40,
                decoration: const BoxDecoration(
                    shape: BoxShape.circle, color: Colors.white),
                child: const Icon(
                  Icons.arrow_back_rounded,
                  color: Colors.blue,
                ),
              ),
            ),
          ),
        ),
        Align(
            alignment: Alignment.bottomCenter,
            child: Container(
                height: 360,
                width: double.infinity,
                decoration: const BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(36),
                        topRight: Radius.circular(36)),
                    boxShadow: [
                      BoxShadow(
                          color: Colors.black12,
                          blurRadius: 1,
                          offset: Offset(0, -1))
                    ]),
                child: _showWelcome
                    ? _buildWelcomeContent()
                    : _buildLoginContent())),
      ]),
      backgroundColor: const Color(0xFFD9E8FF),
    );
  }

  Widget _buildWelcomeContent() {
    return Stack(
      children: [
        Container(
          padding: const EdgeInsets.all(24),
          child: const Column(
            children: [
              SizedBox(
                height: 50,
              ),
              Center(
                child: Text(
                  "AI Assistant\nin your pocket",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                      fontSize: 30, fontWeight: FontWeight.w500, height: 1.2),
                ),
              ),
              SizedBox(
                height: 30,
              ),
              Center(
                child: Text(
                  "AI assistant can answer any\n of your questions. Just ask!",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w400,
                      height: 1.2,
                      color: Colors.grey),
                ),
              )
            ],
          ),
        ),
        Positioned(
          bottom: 20,
          right: 20,
          child: ElevatedButton(
              onPressed: () {
                setState(() {
                  _showWelcome = false;
                });
              },
              style: ElevatedButton.styleFrom(
                padding:
                    const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                backgroundColor: Colors.blue,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Icon(
                Icons.arrow_forward_rounded,
                color: Colors.white,
              )),
        ),
      ],
    );
  }

  Widget _buildLoginContent() {
    return Container(
      key: const ValueKey('login'),
      alignment: Alignment.center,
      child: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 20),
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
                border: Border.all(color: Colors.blue)),
            child: TextField(
              controller: _emailControllers,
              decoration: const InputDecoration(
                contentPadding: EdgeInsets.symmetric(horizontal: 2),
                labelText: 'Email',
                labelStyle: TextStyle(fontSize: 14, color: Colors.grey),
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
            height: 24,
          ),
          ElevatedButton(
              style: ButtonStyle(
                  backgroundColor: WidgetStateProperty.all(Colors.blue)),
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
