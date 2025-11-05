import 'package:flutter/material.dart';

class ExerciseScreen extends StatelessWidget {
  const ExerciseScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Exercise Page'), centerTitle: true),
      body: const Center(
        child: Text(
          'This is a simple friend page!',
          style: TextStyle(fontSize: 20),
        ),
      ),
    );
  }
}
