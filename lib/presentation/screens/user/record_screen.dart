import 'package:eatmehv2/presentation/screens/user/subRecords/diet_screen.dart';
import 'package:eatmehv2/presentation/screens/user/subRecords/exercise_screen.dart';
import 'package:eatmehv2/presentation/screens/user/subRecords/calories_tracker_screen.dart';
import 'package:flutter/material.dart';

class RecordScreen extends StatelessWidget {
  final int selectedTab;

  const RecordScreen({super.key, required this.selectedTab});

  @override
  Widget build(BuildContext context) {
    switch (selectedTab) {
      case 0:
        return const DietScreen();
      case 1:
        return const CaloriesTrackerPage();
      case 2:
        return const ExerciseScreen();
      default:
        return const DietScreen();
    }
  }
}
