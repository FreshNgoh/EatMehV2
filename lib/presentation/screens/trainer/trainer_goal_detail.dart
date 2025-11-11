import 'package:eatmehv2/data/models/user/user_model.dart';
import 'package:eatmehv2/data/repos/user_repo.dart';
import 'package:eatmehv2/presentation/widgets/custom_goal_progress.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:table_calendar/table_calendar.dart';

class TrainerGoalDetail extends StatefulWidget {
  final String traineeUid;
  const TrainerGoalDetail({super.key, required this.traineeUid});

  @override
  State<TrainerGoalDetail> createState() => _TrainerGoalDetailState();
}

class _TrainerGoalDetailState extends State<TrainerGoalDetail> {
  final userRepo = UserRepository();

  UserModel? _user;
  bool isLoading = true;
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;
  Map<DateTime, Map<String, dynamic>> _dailyProgress = {};

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

    final goal = _user!.goal;

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text('Goal Progress'),
      ),
      body: CustomScrollView(
        slivers: [
          // Trainee Info
          SliverToBoxAdapter(
            child: Container(
              padding: const EdgeInsets.all(20),
              color: Colors.white,
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 30,
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
                      children: [
                        Text(
                          _user!.username,
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Goal: ${goal!.goalType}',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Goal Summary Cards
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Daily Targets',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: CustomGoalProgress(
                          icon: Icons.local_fire_department,
                          label: 'Calories',
                          value: '${goal.goalCal.toInt()}',
                          unit: 'kcal',
                          color: Colors.orange,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: CustomGoalProgress(
                          icon: Icons.egg,
                          label: 'Protein',
                          value: '${goal.protein.toInt()}',
                          unit: 'g',
                          color: Colors.red,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: CustomGoalProgress(
                          icon: Icons.rice_bowl,
                          label: 'Carbs',
                          value: '${goal.carbs.toInt()}',
                          unit: 'g',
                          color: Colors.amber,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: CustomGoalProgress(
                          icon: Icons.water_drop,
                          label: 'Fat',
                          value: '${goal.fat.toInt()}',
                          unit: 'g',
                          color: Colors.yellow,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  CustomGoalProgress(
                    icon: Icons.grass,
                    label: 'Fiber',
                    value: '${goal.fiber.toInt()}',
                    unit: 'g',
                    color: Colors.green,
                  ),
                  const SizedBox(height: 16),

                  // Duration
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.blue[50],
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.blue[200]!),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.calendar_today, color: Colors.blue[700]),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Goal Period',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey[600],
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                '${DateFormat('MMM dd, yyyy').format(goal.startDate!.toDate())} - ${DateFormat('MMM dd, yyyy').format(goal.endDate!.toDate())}',
                                style: const TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                ),
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

          // Calendar View
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Progress Calendar',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 12),
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withOpacity(0.1),
                          spreadRadius: 1,
                          blurRadius: 5,
                        ),
                      ],
                    ),
                    child: TableCalendar(
                      firstDay: goal.startDate!.toDate(),
                      lastDay: goal.endDate!.toDate(),
                      focusedDay: _focusedDay,
                      selectedDayPredicate:
                          (day) => isSameDay(_selectedDay, day),
                      calendarFormat: CalendarFormat.month,
                      onDaySelected: (selectedDay, focusedDay) {
                        setState(() {
                          _selectedDay = selectedDay;
                          _focusedDay = focusedDay;
                        });
                      },
                      onPageChanged: (focusedDay) {
                        _focusedDay = focusedDay;
                        // _loadDailyProgress();
                      },
                      calendarStyle: CalendarStyle(
                        todayDecoration: BoxDecoration(
                          color: Colors.blue[300],
                          shape: BoxShape.circle,
                        ),
                        selectedDecoration: const BoxDecoration(
                          color: Colors.blue,
                          shape: BoxShape.circle,
                        ),
                        markerDecoration: const BoxDecoration(
                          color: Colors.green,
                          shape: BoxShape.circle,
                        ),
                      ),
                      calendarBuilders: CalendarBuilders(
                        markerBuilder: (context, date, events) {
                          final dateKey = DateTime(
                            date.year,
                            date.month,
                            date.day,
                          );
                          final progress = _dailyProgress[dateKey];

                          if (progress != null) {
                            final caloriesProgress =
                                (progress['calories'] / goal.goalCal);
                            final meetsGoal =
                                caloriesProgress >= 0.8 &&
                                caloriesProgress <= 1.2;

                            return Positioned(
                              bottom: 1,
                              child: Container(
                                width: 7,
                                height: 7,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color:
                                      meetsGoal ? Colors.green : Colors.orange,
                                ),
                              ),
                            );
                          }
                          return null;
                        },
                      ),
                    ),
                  ),
                  const SizedBox(height: 50),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
