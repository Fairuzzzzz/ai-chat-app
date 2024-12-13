import 'package:aichatapp/pages/home.dart';
import 'package:aichatapp/pages/welcomelogin_page.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AuthGate extends StatefulWidget {
  const AuthGate({super.key});

  @override
  State<AuthGate> createState() => _AuthGateState();
}

class _AuthGateState extends State<AuthGate> {
  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
        stream: Supabase.instance.client.auth.onAuthStateChange,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Scaffold(
              body: Center(
                child: CircularProgressIndicator(),
              ),
            );
          }

          final session = snapshot.hasData ? snapshot.data!.session : null;
          if (session != null) {
            final userId = session.user.id;
            return Home(userId: userId);
          }

          return const WelcomeloginPage();
        });
  }
}
