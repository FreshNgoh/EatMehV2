import 'package:eatmehv2/core/localization/app_localizations.dart';
import 'package:eatmehv2/presentation/widgets/video_player.dart';
import 'package:flutter/material.dart';

class ManualStep {
  final String videoAsset;
  final String text;

  ManualStep({required this.videoAsset, required this.text});
}

class SimpleUserManualScreen extends StatefulWidget {
  const SimpleUserManualScreen({super.key});

  @override
  State<SimpleUserManualScreen> createState() => _SimpleUserManualScreenState();
}

class _SimpleUserManualScreenState extends State<SimpleUserManualScreen> {
  int _currentStep = 0;
  List<ManualStep> _steps = [];

  // ✅ Helper to load localized steps
  void _loadSteps(AppLocalizations loc) {
    _steps = [
      ManualStep(
        videoAsset: 'assets/videos/scan_manual.mov',
        text: loc.manualStepScan,
      ),
      ManualStep(
        videoAsset: 'assets/videos/story_manual.mov',
        text: loc.manualStepStory,
      ),
      ManualStep(
        videoAsset: 'assets/videos/record_manual.mov',
        text: loc.manualStepRecord,
      ),
      ManualStep(
        videoAsset: 'assets/videos/trainee_manual.mov',
        text: loc.manualStepTrainee,
      ),
      ManualStep(
        videoAsset: 'assets/videos/trainer_manual.mov',
        text: loc.manualStepTrainer,
      ),
    ];
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Load steps here to ensure `loc` is available
    _loadSteps(context.loc);
  }

  void _nextStep() {
    if (_currentStep == _steps.length - 1) {
      Navigator.pop(context); // Finish and close screen
    } else {
      setState(() => _currentStep++);
    }
  }

  void _previousStep() {
    if (_currentStep > 0) {
      setState(() => _currentStep--);
    }
  }

  @override
  Widget build(BuildContext context) {
    final loc = context.loc;
    // Ensure steps are loaded if build is called before didChangeDependencies
    if (_steps.isEmpty) {
      _loadSteps(loc);
    }

    return Scaffold(
      appBar:
          AppBar(title: Text(loc.settingsOtherUserManual), leadingWidth: 60),
      body: Padding(
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 40),
        child: Column(
          children: [
            // Progress Bar
            LinearProgressIndicator(
              value: (_currentStep + 1) / _steps.length,
              backgroundColor: Colors.grey.shade300,
              color: Colors.green,
            ),
            const SizedBox(height: 5),

            // Step counter
            Text(
              loc.manualStepCounter(
                _currentStep + 1,
                _steps.length,
              ),
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey.shade600,
                fontWeight: FontWeight.w500,
              ),
            ),
            // const SizedBox(height: 5),

            // Step content
            Expanded(child: _buildManualStep(_steps[_currentStep])),

            const SizedBox(height: 5),

            // Bottom navigation
            Row(
              children: [
                // Previous Button
                if (_currentStep > 0)
                  Expanded(
                    child: OutlinedButton(
                      onPressed: _previousStep,
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: Colors.green),
                        minimumSize: const Size(double.infinity, 50),
                      ),
                      child: Text(
                        loc.manualButtonPrevious,
                        style: const TextStyle(
                          color: Colors.green,
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),

                if (_currentStep > 0) const SizedBox(width: 16),

                // Next / Finish Button
                Expanded(
                  child: ElevatedButton(
                    onPressed: _nextStep,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      minimumSize: const Size(double.infinity, 50),
                    ),
                    child: Text(
                      _currentStep == _steps.length - 1
                          ? loc.trainerInstructionButtonFinish
                          : loc.manualButtonNext,
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

  // ✅ Build dynamic step widget
  Widget _buildManualStep(ManualStep step) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              DemoVideoPlayer(videoAsset: step.videoAsset), // dynamic video
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