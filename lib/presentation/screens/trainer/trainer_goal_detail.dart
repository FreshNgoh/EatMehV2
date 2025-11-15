import 'package:eatmehv2/data/models/user/user_model.dart';
import 'package:eatmehv2/data/repos/user_repo.dart';
import 'package:eatmehv2/data/repos/meal_records_repo.dart';
import 'package:eatmehv2/data/repos/exercise_repo.dart';
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
  final mealRepo = MealRecordsRepository();
  final exerciseRepo = ExerciseRepository();

  UserModel? _user;
  bool isLoading = true;
  bool isLoadingProgress = false;
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;
  Map<DateTime, Map<String, dynamic>> _dailyProgress = {};
  Map<String, dynamic>? _selectedDayDetails;

  Future<void> loadTraineeProfile() async {
    final user = await userRepo.getUser(widget.traineeUid);

    setState(() {
      _user = user;
      isLoading = false;
    });

    if (user?.goal != null) {
      await _loadDailyProgress();
    }
  }

  /// Load daily progress for the visible month
  Future<void> _loadDailyProgress() async {
    if (_user?.goal == null) return;

    setState(() {
      isLoadingProgress = true;
    });

    try {
      // Get the start and end of the focused month
      final startOfMonth = DateTime(_focusedDay.year, _focusedDay.month, 1);
      final endOfMonth = DateTime(_focusedDay.year, _focusedDay.month + 1, 0);

      final goalStart = _user!.goal!.startDate!.toDate();
      final goalEnd = _user!.goal!.endDate!.toDate();

      final effectiveStart =
          startOfMonth.isBefore(goalStart) ? goalStart : startOfMonth;
      final effectiveEnd = endOfMonth.isAfter(goalEnd) ? goalEnd : endOfMonth;

      Map<DateTime, Map<String, dynamic>> progressMap = {};

      // Iterate through each day in the range
      for (
        var date = effectiveStart;
        date.isBefore(effectiveEnd.add(const Duration(days: 1)));
        date = date.add(const Duration(days: 1))
      ) {
        final dateKey = DateTime(date.year, date.month, date.day);

        // Fetch meals for this day
        final meals = await mealRepo.fetchMealRecordsByUserAndDate(
          userUid: widget.traineeUid,
          date: date,
        );

        // Fetch exercises for this day
        final exercises = await exerciseRepo.fetchExercises(
          userUid: widget.traineeUid,
          date: date,
        );

        // Calculate totals
        double totalCalories = 0;
        double totalProtein = 0;
        double totalCarbs = 0;
        double totalFat = 0;
        double totalFiber = 0;

        for (var meal in meals) {
          totalCalories += meal.calories;
          totalProtein += meal.nutritionInfo.protein;
          totalCarbs += meal.nutritionInfo.carbs;
          totalFat += meal.nutritionInfo.fat;
          totalFiber += meal.nutritionInfo.fiber;
        }

        double totalCaloriesBurnt = 0;
        for (var exercise in exercises) {
          totalCaloriesBurnt += exercise.caloriesBurnt;
        }

        // Store progress data
        progressMap[dateKey] = {
          'calories': totalCalories,
          'caloriesBurnt': totalCaloriesBurnt,
          'protein': totalProtein,
          'carbs': totalCarbs,
          'fat': totalFat,
          'fiber': totalFiber,
          'mealsCount': meals.length,
          'exercisesCount': exercises.length,
        };
      }

      setState(() {
        _dailyProgress = progressMap;
        isLoadingProgress = false;
      });
    } catch (e) {
      debugPrint('Error loading daily progress: $e');
      setState(() {
        isLoadingProgress = false;
      });
    }
  }

  // Load details for a specific selected day
  Future<void> _loadSelectedDayDetails(DateTime day) async {
    if (_user?.goal == null) return;

    try {
      final dateKey = DateTime(day.year, day.month, day.day);
      final progress = _dailyProgress[dateKey];

      setState(() {
        _selectedDayDetails = progress;
      });
    } catch (e) {
      debugPrint('Error loading selected day details: $e');
    }
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
    bool hasSetGoal = goal == null;

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text('Goal Progress'),
      ),
      body:
          hasSetGoal
              ? Center(
                child: Text(
                  'Trainee has not set any goals for you yet.',
                  style: TextStyle(fontSize: 16, color: Colors.grey[600]),
                ),
              )
              : CustomScrollView(
                slivers: [
                  // Trainee Info
                  SliverToBoxAdapter(
                    child: Container(
                      padding: const EdgeInsets.all(20),
                      color: Colors.white,
                      child: Row(
                        children: [
                          CircleAvatar(
                            radius: 25,
                            backgroundColor: Colors.grey.shade200,
                            backgroundImage:
                                (_user!.imageUrl != null &&
                                        _user!.imageUrl!.isNotEmpty)
                                    ? NetworkImage(_user!.imageUrl!)
                                    : null,
                            child:
                                (_user!.imageUrl == null ||
                                        _user!.imageUrl!.isEmpty)
                                    ? Text(
                                      _user!.username[0].toUpperCase(),
                                      style: const TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    )
                                    : null,
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
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
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
                                Icon(
                                  Icons.calendar_today,
                                  color: Colors.blue[700],
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
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
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
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
                            child: Stack(
                              children: [
                                TableCalendar(
                                  firstDay: goal.startDate!.toDate(),
                                  lastDay: goal.endDate!.toDate(),
                                  focusedDay: _focusedDay,
                                  selectedDayPredicate:
                                      (day) => isSameDay(_selectedDay, day),
                                  calendarFormat: CalendarFormat.month,
                                  availableCalendarFormats: const {
                                    CalendarFormat.month: 'Month',
                                  },
                                  onDaySelected: (selectedDay, focusedDay) {
                                    setState(() {
                                      _selectedDay = selectedDay;
                                      _focusedDay = focusedDay;
                                    });
                                    _loadSelectedDayDetails(selectedDay);
                                  },
                                  onPageChanged: (focusedDay) {
                                    setState(() {
                                      _focusedDay = focusedDay;
                                    });
                                    _loadDailyProgress();
                                  },
                                  headerStyle: const HeaderStyle(
                                    formatButtonVisible: false,
                                  ),
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

                                      if (progress != null &&
                                          progress['mealsCount'] > 0) {
                                        final caloriesProgress =
                                            (progress['calories'] /
                                                goal.goalCal);
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
                                                  meetsGoal
                                                      ? Colors.green
                                                      : Colors.orange,
                                            ),
                                          ),
                                        );
                                      }
                                      return null;
                                    },
                                  ),
                                ),
                                if (isLoadingProgress)
                                  Positioned.fill(
                                    child: Container(
                                      decoration: BoxDecoration(
                                        color: Colors.white.withOpacity(0.8),
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      child: const Center(
                                        child: CircularProgressIndicator(),
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                          ),

                          // Selected Day Details
                          if (_selectedDay != null &&
                              _selectedDayDetails != null)
                            Padding(
                              padding: const EdgeInsets.only(top: 16),
                              child: Container(
                                padding: const EdgeInsets.all(16),
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
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      DateFormat(
                                        'EEEE, MMMM d, yyyy',
                                      ).format(_selectedDay!),
                                      style: const TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    const SizedBox(height: 12),
                                    _buildProgressRow(
                                      'Calories',
                                      _selectedDayDetails!['calories'].toInt(),
                                      goal.goalCal.toInt(),
                                      Colors.orange,
                                    ),
                                    _buildProgressRow(
                                      'Protein',
                                      _selectedDayDetails!['protein'].toInt(),
                                      goal.protein.toInt(),
                                      Colors.red,
                                    ),
                                    _buildProgressRow(
                                      'Carbs',
                                      _selectedDayDetails!['carbs'].toInt(),
                                      goal.carbs.toInt(),
                                      Colors.amber,
                                    ),
                                    _buildProgressRow(
                                      'Fat',
                                      _selectedDayDetails!['fat'].toInt(),
                                      goal.fat.toInt(),
                                      Colors.yellow,
                                    ),
                                    _buildProgressRow(
                                      'Fiber',
                                      _selectedDayDetails!['fiber'].toInt(),
                                      goal.fiber.toInt(),
                                      Colors.green,
                                    ),
                                    const Divider(height: 24),
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceAround,
                                      children: [
                                        _buildStat(
                                          'Meals',
                                          _selectedDayDetails!['mealsCount']
                                              .toString(),
                                          Icons.restaurant,
                                        ),
                                        _buildStat(
                                          'Exercises',
                                          _selectedDayDetails!['exercisesCount']
                                              .toString(),
                                          Icons.fitness_center,
                                        ),
                                        _buildStat(
                                          'Burnt',
                                          '${_selectedDayDetails!['caloriesBurnt'].toInt()} kcal',
                                          Icons.local_fire_department,
                                        ),
                                      ],
                                    ),
                                  ],
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

  Widget _buildProgressRow(String label, int current, int goal, Color color) {
    final percentage = (current / goal * 100).clamp(0, 100);
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(label, style: const TextStyle(fontSize: 14)),
              Text(
                '$current / $goal',
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          LinearProgressIndicator(
            value: percentage / 100,
            backgroundColor: Colors.grey[200],
            valueColor: AlwaysStoppedAnimation<Color>(color),
            minHeight: 8,
            borderRadius: BorderRadius.circular(4),
          ),
        ],
      ),
    );
  }

  Widget _buildStat(String label, String value, IconData icon) {
    return Column(
      children: [
        Icon(icon, size: 24, color: Colors.blue),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        Text(label, style: TextStyle(fontSize: 12, color: Colors.grey[600])),
      ],
    );
  }
}
