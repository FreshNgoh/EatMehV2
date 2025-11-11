import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:eatmehv2/data/models/user/user_model.dart';
import 'package:eatmehv2/presentation/screens/admin/admin_screen.dart';
import 'package:eatmehv2/presentation/screens/user/home_screen.dart';
import 'package:eatmehv2/presentation/screens/onboarding/personal_info_screen.dart';

class UserManualScreen extends StatefulWidget {
  final UserModel user;
  const UserManualScreen({super.key, required this.user});

  @override
  State<UserManualScreen> createState() => _UserManualScreenState();
}

class _UserManualScreenState extends State<UserManualScreen> {
  int _currentStep = 0;

  // Dummy content for first 4 steps
  final List<String> _manualSteps = [
    "Welcome to EatMeh! 🍽️\n\nTrack your meals and stay healthy.",
    "Connect with professional trainers to reach your goals.",
    "Monitor your BMI, diet, and daily progress easily.",
    "Set realistic goals and track achievements effortlessly.",
  ];

  void _nextStep() {
    setState(() {
      if (_currentStep < 4) {
        _currentStep++;
      }
    });
  }

  Future<void> _completeOnboarding(BuildContext context) async {
    // ✅ Update Firestore (mark onboarding complete)
    // await FirebaseFirestore.instance
    //     .collection('users')
    //     .doc(widget.user.uid)
    //     .update({'settings.showOnboarding': false});

    // ✅ Navigate based on role
    Widget nextScreen;
    switch (widget.user.role) {
      case 'admin':
        nextScreen = const AdminScreen();
        break;
      case 'trainer':
        nextScreen = const HomeScreen();
        break;
      default:
        nextScreen = const HomeScreen();
    }

    // ✅ Replace current screen with destination
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => nextScreen),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("EatMeh Onboarding"),
        automaticallyImplyLeading: false,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            // Progress indicator
            LinearProgressIndicator(
              value: (_currentStep + 1) / 5,
              backgroundColor: Colors.grey.shade300,
              color: Colors.green,
            ),
            const SizedBox(height: 30),

            // Step content
            Expanded(
              child:
                  _currentStep < 4
                      ? _buildManualStep(_manualSteps[_currentStep])
                      : PersonalInfoScreen(
                        user: widget.user,
                      ), // 👈 Show Personal Info on Step 5
            ),

            const SizedBox(height: 20),

            // Bottom button area
            if (_currentStep < 4)
              ElevatedButton(
                onPressed: _nextStep,
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 50),
                  backgroundColor: Colors.green,
                ),
                child: const Text(
                  "Next",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              )
            else
              ElevatedButton(
                onPressed: () => _completeOnboarding(context),
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 50),
                  backgroundColor: Colors.green,
                ),
                child: const Text(
                  "Start EatMeh",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildManualStep(String text) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Text(
          text,
          style: const TextStyle(fontSize: 18, height: 1.6),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}
