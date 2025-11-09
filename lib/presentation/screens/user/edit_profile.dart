import 'package:flutter/material.dart';

class EditProfile extends StatelessWidget {
  const EditProfile({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        centerTitle: true,
        leadingWidth: 60,
        title: const Text('Settings'),
      ),
      body: const Center(
        child: Text('Edit Profile page!', style: TextStyle(fontSize: 20)),
      ),
    );
  }
}
