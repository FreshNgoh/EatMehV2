import 'package:flutter/material.dart';

class RecordScreen extends StatelessWidget {
  const RecordScreen({super.key});

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
