import 'package:flutter/material.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Friend Page'), centerTitle: true),
      body: const Center(
        child: Text(
          'This is a simple friend page!',
          style: TextStyle(fontSize: 20),
        ),
      ),
    );
  }
}
