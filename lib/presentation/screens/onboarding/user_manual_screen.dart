import 'package:eatmehv2/data/models/user/user_model.dart';
import 'package:eatmehv2/presentation/screens/onboarding/personal_info_screen.dart';
import 'package:flutter/material.dart';
import '../../widgets/video_player.dart';

class ManualStep {
  final String videoAsset;
  final String text;

  ManualStep({required this.videoAsset, required this.text});
}

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

  // ⭐ NEW 5 steps (4 video steps + last PersonalInfo)
  final List<ManualStep> _steps = [
    ManualStep(
      videoAsset: 'assets/videos/scan_manual.mov',
      text: 'Scan your meal, get healthy',
    ),
    ManualStep(
      videoAsset: 'assets/videos/story_manual.mov',
      text: 'Post a story, share your meal',
    ),
    ManualStep(
      videoAsset: 'assets/videos/record_manual.mov',
      text: 'Track your record, stay healthy',
    ),
    ManualStep(
      videoAsset: 'assets/videos/trainee_manual.mov',
      text: 'Find a consult, customize your goal',
    ),
    ManualStep(
      videoAsset: 'assets/videos/trainer_manual.mov',
      text: 'Apply a consult, get your trainees',
    ),
  ];

  void _nextStep() {
    if (_currentStep == 5) {
      _personalInfoController.completeOnboarding?.call();
    } else {
      setState(() => _currentStep++);
    }
  }

  void _previousStep() {
    if (_currentStep > 0) setState(() => _currentStep--);
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
            // Progress bar
            LinearProgressIndicator(
              value: (_currentStep + 1) / 6,
              backgroundColor: Colors.grey.shade300,
              color: Colors.green,
            ),
            const SizedBox(height: 10),

            // Step indicator
            Text(
              "${_currentStep + 1} of 6",
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
                  _currentStep < 5
                      ? _buildVideoStep(_steps[_currentStep])
                      : PersonalInfoScreen(
                        key: ValueKey("personal-info-step"),
                        user: widget.user,
                        showButton: false,
                        controller: _personalInfoController,
                      ),
            ),

            const SizedBox(height: 20),

            // Bottom navigation buttons
            Row(
              children: [
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
                  child: ElevatedButton(
                    onPressed: _nextStep,
                    style: ElevatedButton.styleFrom(
                      minimumSize: const Size(double.infinity, 50),
                      backgroundColor: Colors.green,
                    ),
                    child: Text(
                      _currentStep == 5 ? "Start EatMeh" : "Next",
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

  //  Replaces _buildManualStep()
  Widget _buildVideoStep(ManualStep step) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: SingleChildScrollView(
          child: Column(
            children: [
              DemoVideoPlayer(videoAsset: step.videoAsset),
              const SizedBox(height: 20),
              Text(
                step.text,
                style: const TextStyle(fontSize: 18, height: 1.6),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
