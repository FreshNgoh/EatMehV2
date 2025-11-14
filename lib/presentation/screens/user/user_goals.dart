import 'package:eatmehv2/bloc/auth/auth_bloc.dart';
import 'package:eatmehv2/data/repos/user_repo.dart';
import 'package:eatmehv2/presentation/screens/trainer/trainer_list.dart';
import 'package:eatmehv2/presentation/widgets/custom_button.dart';
import 'package:eatmehv2/presentation/widgets/custom_goal.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class UserGoals extends StatefulWidget {
  const UserGoals({super.key});

  @override
  State<UserGoals> createState() => _UserGoalsState();
}

class _UserGoalsState extends State<UserGoals> {
  String? selectedGoal;

  void selectGoal(String goal) {
    setState(() {
      selectedGoal = goal;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: const Text('Set Your Goals'),
        titleTextStyle: const TextStyle(
          color: Colors.black87,
          fontSize: 20,
          fontWeight: FontWeight.w700,
        ),
      ),
      body: ListView(
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20.0),
            child: Column(
              children: [
                const SizedBox(height: 20),
                Text(
                  "Select one goal that best describes what you want to achieve.",
                  textAlign: TextAlign.center,
                  style: Theme.of(
                    context,
                  ).textTheme.bodyMedium?.copyWith(color: Colors.black54),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          CustomGoal(
            title: 'Lose Weight',
            description: 'Focus on fat loss and lean muscle retention.',
            icon: Icons.fitness_center,
            isSelected: selectedGoal == 'Lose Weight',
            onFieldTap: () => selectGoal('Lose Weight'),
          ),
          const SizedBox(height: 10),
          CustomGoal(
            title: 'Maintain Weight',
            description: 'Sustain current fitness level and body composition.',
            icon: Icons.balance,
            isSelected: selectedGoal == 'Maintain Weight',
            onFieldTap: () => selectGoal('Maintain Weight'),
          ),
          const SizedBox(height: 10),
          CustomGoal(
            title: 'Gain Weight',
            description: 'Build muscle mass and overall strength safely.',
            icon: Icons.trending_up,
            isSelected: selectedGoal == 'Gain Weight',
            onFieldTap: () => selectGoal('Gain Weight'),
          ),
          const SizedBox(height: 100),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 60),
            child: CustomButton(
              text: 'Finish',
              onPressed:
                  selectedGoal == null
                      ? null
                      : () {
                        updateUserGoal();
                      },
            ),
          ),
        ],
      ),
    );
  }

  void updateUserGoal() async {
    final userRepo = UserRepository();
    final authState = context.read<AuthBloc>().state as Authenticated;
    final currentUserUid = authState.user.uid;

    await userRepo.updateGoal(currentUserUid, selectedGoal);

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const TrainerList()),
    );
  }
}
