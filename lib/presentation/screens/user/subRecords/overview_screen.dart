import 'package:flutter/material.dart';

class OverviewScreen extends StatelessWidget {
  const OverviewScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Overview Page'), centerTitle: true),
      body: const Center(
        child: Text(
          'This is a simple friend page!',
          style: TextStyle(fontSize: 20),
        ),
      ),
    );
  }
}
