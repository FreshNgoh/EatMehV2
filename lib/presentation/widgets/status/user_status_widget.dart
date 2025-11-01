import 'package:flutter/material.dart';
import '../../../data/models/user/user_status_model.dart';
import '../../../core/utils/calorie_calculator.dart';

class UserStatusWidget extends StatelessWidget {
  final UserStatus status;
  final int weeklyCalorieIntake;
  final int weeklyCalorieBurn;

  const UserStatusWidget({
    super.key,
    required this.status,
    required this.weeklyCalorieIntake,
    required this.weeklyCalorieBurn,
  });

  @override
  Widget build(BuildContext context) {
    final bmiCategory = CalorieCalculator.getBMICategory(status.bmi!);
    final bmiColor = _getBMIColor(status.bmi!);

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            bmiColor.withOpacity(0.2),
            bmiColor.withOpacity(0.1),
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: bmiColor.withOpacity(0.5), width: 2),
      ),
      child: Column(
        children: [
          // Status Emoji
          Text(
            status.statusEmoji,
            style: const TextStyle(fontSize: 60),
          ),

          const SizedBox(height: 12),

          Text(
            bmiCategory,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: bmiColor,
            ),
          ),

          const SizedBox(height: 16),

          // BMI
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                'BMI: ',
                style: TextStyle(fontSize: 16, color: Colors.grey),
              ),
              Text(
                status.bmi!.toStringAsFixed(1),
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: bmiColor,
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),

          // Weight Progress
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildWeightInfo(
                  'Current', status.currentWeight!, Colors.black87),
              const Icon(Icons.arrow_forward, color: Colors.grey),
              _buildWeightInfo('Goal', status.goalWeight!, bmiColor),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildWeightInfo(String label, double weight, Color color) {
    return Column(
      children: [
        Text(
          label,
          style: const TextStyle(fontSize: 12, color: Colors.grey),
        ),
        const SizedBox(height: 4),
        Text(
          '${weight.toStringAsFixed(1)} kg',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
      ],
    );
  }

  Color _getBMIColor(double bmi) {
    if (bmi < 18.5) return Colors.orange;
    if (bmi < 25) return Colors.green;
    if (bmi < 30) return Colors.orange;
    return Colors.red;
  }
}
