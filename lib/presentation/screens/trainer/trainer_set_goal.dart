import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:eatmehv2/core/utils/date_formatter.dart';
import 'package:eatmehv2/data/models/user/goal_model.dart';
import 'package:eatmehv2/data/models/user/user_model.dart';
import 'package:eatmehv2/data/repos/trainer_profile_repo.dart';
import 'package:eatmehv2/data/repos/user_repo.dart';
import 'package:eatmehv2/data/services/trainer_profile_service.dart';
import 'package:eatmehv2/presentation/widgets/custom_button.dart';
import 'package:eatmehv2/presentation/widgets/custom_text_field.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class TrainerSetGoal extends StatefulWidget {
  final String traineeUid;
  const TrainerSetGoal({super.key, required this.traineeUid});

  @override
  State<TrainerSetGoal> createState() => _TrainerSetGoalState();
}

class _TrainerSetGoalState extends State<TrainerSetGoal> {
  final userRepo = UserRepository();
  final trainerRepo = TrainerProfileRepo(TrainerProfileService());

  final _caloriesController = TextEditingController();
  final _proteinController = TextEditingController();
  final _carbsController = TextEditingController();
  final _fatController = TextEditingController();
  final _fiberController = TextEditingController();
  final _startDateController = TextEditingController();
  final _endDateController = TextEditingController();

  UserModel? _user;
  Goal? _goal;
  bool isLoading = true;
  bool isSaving = false;

  Future<void> loadTraineeProfile() async {
    final user = await userRepo.getUser(widget.traineeUid);

    setState(() {
      _user = user;
      isLoading = false;
    });
  }

  @override
  void initState() {
    super.initState();
    loadTraineeProfile();
  }

  @override
  void dispose() {
    _caloriesController.dispose();
    _proteinController.dispose();
    _carbsController.dispose();
    _fatController.dispose();
    _fiberController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    if (_user == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Error')),
        body: const Center(child: Text("Trainee not found")),
      );
    }

    final userName = _user!.username;
    final userId = '@${_user!.uid.substring(0, 10)}...';
    final isCreatingNewGoal = _goal == null;

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text('Customize Goal'),
      ),
      body: CustomScrollView(
        slivers: [
          // Section 1: User Info
          SliverAppBar(
            expandedHeight: 150,
            pinned: false,
            automaticallyImplyLeading: false,
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                color: Colors.white,
                padding: const EdgeInsets.all(20.0),
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 40,
                      backgroundColor: Colors.white,
                      backgroundImage:
                          _user!.imageUrl != null
                              ? NetworkImage(_user!.imageUrl!)
                              : const AssetImage("assets/teralero.png")
                                  as ImageProvider,
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            userName,
                            style: const TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF2D3748),
                            ),
                          ),
                          const SizedBox(height: 4),
                          GestureDetector(
                            onLongPress: () {
                              Clipboard.setData(
                                ClipboardData(text: _user!.uid),
                              );
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('User ID copied!'),
                                  duration: Duration(seconds: 1),
                                ),
                              );
                            },
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  userId,
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.grey[600],
                                  ),
                                ),
                                const SizedBox(width: 4),
                                const Icon(
                                  Icons.copy,
                                  size: 14,
                                  color: Colors.grey,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // Section 2: Goal Form
          SliverToBoxAdapter(
            child: Container(
              decoration: BoxDecoration(
                color: Colors.grey[50],
                border: Border(
                  top: BorderSide(color: Colors.grey[200]!, width: 2),
                ),
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(40),
                  topRight: Radius.circular(40),
                ),
              ),
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (isCreatingNewGoal)
                      Container(
                        padding: const EdgeInsets.all(16),
                        margin: const EdgeInsets.only(bottom: 24),
                        decoration: BoxDecoration(
                          color: Colors.blue[50],
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.blue[200]!),
                        ),
                        child: Row(
                          children: [
                            Icon(Icons.info_outline, color: Colors.blue[700]),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                '$userName hope to (user goals)',
                                style: TextStyle(
                                  color: Colors.blue[900],
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),

                    const Text(
                      'Daily Nutritional Goals',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 20),

                    CustomTextField(
                      controller: _caloriesController,
                      label: 'Calories (kcal)',
                      hint: 'Calories',
                      prefixIcon: Icons.local_fire_department,
                    ),
                    const SizedBox(height: 10),

                    CustomTextField(
                      controller: _proteinController,
                      label: 'Protein (g)',
                      hint: 'Protein',
                      prefixIcon: Icons.egg,
                    ),
                    const SizedBox(height: 10),

                    CustomTextField(
                      controller: _carbsController,
                      label: 'Carbs (g)',
                      hint: 'Carbs',
                      prefixIcon: Icons.rice_bowl,
                    ),
                    const SizedBox(height: 10),

                    CustomTextField(
                      controller: _fatController,
                      label: 'Fat (g)',
                      hint: 'Fat',
                      prefixIcon: Icons.water_drop,
                    ),
                    const SizedBox(height: 10),

                    CustomTextField(
                      controller: _fiberController,
                      label: 'Fiber (g)',
                      hint: 'Fiber',
                      prefixIcon: Icons.grass,
                    ),
                    const SizedBox(height: 10),

                    CustomTextField(
                      controller: _startDateController,
                      label: 'Start Date',
                      hint: 'Select start date',
                      prefixIcon: Icons.calendar_today,
                      readOnly: true,
                      onTap:
                          () => _selectDate(
                            context: context,
                            controller: _startDateController,
                          ),
                    ),
                    const SizedBox(height: 10),

                    CustomTextField(
                      controller: _endDateController,
                      label: 'End Date',
                      hint: 'Select end date',
                      prefixIcon: Icons.event,
                      readOnly: true,
                      onTap:
                          () => _selectDate(
                            context: context,
                            controller: _endDateController,
                          ),
                    ),
                    const SizedBox(height: 32),

                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 50),
                      child: CustomButton(
                        text: isSaving ? 'Saving...' : 'Save Goal',
                        onPressed: _saveGoal,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _selectDate({
    required BuildContext context,
    required TextEditingController controller,
  }) async {
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
    );

    if (pickedDate != null) {
      controller.text = DateFormatter.formatDate(pickedDate);
    }
  }

  Future<void> _saveGoal() async {
    setState(() {
      isSaving = true;
    });

    try {
      final traineeUid = widget.traineeUid;
      final startDate = DateFormatter.parseDate(_startDateController.text);
      final endDate = DateFormatter.parseDate(_endDateController.text);
      final goals = Goal(
        goalType: 'custom',
        goalCal: double.parse(_caloriesController.text),
        protein: double.parse(_proteinController.text),
        carbs: double.parse(_carbsController.text),
        fat: double.parse(_fatController.text),
        fiber: double.parse(_fiberController.text),
        startDate: Timestamp.fromDate(startDate),
        endDate: Timestamp.fromDate(endDate),
      );

      await trainerRepo.saveUserGoals(traineeUid, goals);

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Goal saved successfully!')));

      Navigator.pop(context);
    } catch (e) {
      if (mounted) {
        setState(() => isSaving = false);
      }
      throw ('Error saving goal: $e');
    }
  }
}
