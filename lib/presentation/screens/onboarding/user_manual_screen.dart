import 'package:eatmehv2/data/models/user/user_model.dart';
import 'package:eatmehv2/presentation/screens/onboarding/personal_info_screen.dart';
import 'package:flutter/material.dart';

class UserManualScreen extends StatefulWidget {
  final UserModel user;
  const UserManualScreen({super.key, required this.user});

  @override
  State<UserManualScreen> createState() => _UserManualScreenState();
}

class _UserManualScreenState extends State<UserManualScreen> {
  int _currentStep = 0;
  final PersonalInfoController _personalInfoController =
      PersonalInfoController();

  // Dummy content for first 4 steps
  final List<String> _manualSteps = [
    "Welcome to EatMeh! 🍽️\n\nTrack your meals and stay healthy.",
    "Connect with professional trainers to reach your goals.",
    "Monitor your BMI, diet, and daily progress easily.",
    "Set realistic goals and track achievements effortlessly.",
  ];
  void _nextStep() {
    if (_currentStep == 4) {
      _personalInfoController.completeOnboarding?.call();
    } else {
      setState(() {
        _currentStep++;
      });
    }
  }

  void _previousStep() {
    if (_currentStep > 0) {
      setState(() {
        _currentStep--;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("EatMeh Onboarding"),
        automaticallyImplyLeading: false,
      ),
      body: Padding(
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 40),
        child: Column(
          children: [
            // Progress indicator
            LinearProgressIndicator(
              value: (_currentStep + 1) / 5,
              backgroundColor: Colors.grey.shade300,
              color: Colors.green,
            ),
            const SizedBox(height: 10),

            // Step counter
            Text(
              "${_currentStep + 1} of 5",
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey.shade600,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 30),

            // Step content
            Expanded(
              child:
                  _currentStep < 4
                      ? _buildManualStep(_manualSteps[_currentStep])
                      : PersonalInfoScreen(
                        key: ValueKey('personal_info_$_currentStep'),
                        user: widget.user,
                        showButton: false,
                        controller: _personalInfoController,
                      ),
            ),

            const SizedBox(height: 20),

            // Bottom navigation buttons
            Row(
              children: [
                // Previous button
                if (_currentStep > 0)
                  Expanded(
                    child: OutlinedButton(
                      onPressed: _previousStep,
                      style: OutlinedButton.styleFrom(
                        minimumSize: const Size(double.infinity, 50),
                        side: const BorderSide(color: Colors.green),
                      ),
                      child: const Text(
                        "Previous",
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          color: Colors.green,
                        ),
                      ),
                    ),
                  ),

                if (_currentStep > 0) const SizedBox(width: 16),

                // Next/Start button
                Expanded(
                  flex: _currentStep == 0 ? 1 : 1,
                  child: ElevatedButton(
                    onPressed: _nextStep,
                    style: ElevatedButton.styleFrom(
                      minimumSize: const Size(double.infinity, 50),
                      backgroundColor: Colors.green,
                    ),
                    child: Text(
                      _currentStep == 4 ? "Start EatMeh" : "Next",
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ],
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
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(_getStepIcon(_currentStep), size: 80, color: Colors.green),
            const SizedBox(height: 30),
            Text(
              text,
              style: const TextStyle(fontSize: 18, height: 1.6),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  IconData _getStepIcon(int step) {
    switch (step) {
      case 0:
        return Icons.restaurant_menu;
      case 1:
        return Icons.people;
      case 2:
        return Icons.monitor_heart;
      case 3:
        return Icons.flag;
      default:
        return Icons.info;
    }
  }
}
