import 'package:flutter/material.dart';

class Home extends StatefulWidget {
  final String userId;
  const Home({required this.userId, super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  @override
  Widget build(BuildContext context) {
    return const Scaffold();
  }
}
