import 'package:flutter/material.dart';

class PersonalInfo extends StatelessWidget {
  const PersonalInfo({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Personal Info'), centerTitle: true),
      body: const Center(child: Text('This is the Personal Info page!')),
    );
  }
}
