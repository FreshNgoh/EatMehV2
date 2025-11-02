import 'package:flutter/material.dart';

class AdminScreen extends StatelessWidget {
  const AdminScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Admin Page'), centerTitle: true),
      body: const Center(
        child: Text(
          'This is a simple admin page!',
          style: TextStyle(fontSize: 20),
        ),
      ),
    );
  }
}
