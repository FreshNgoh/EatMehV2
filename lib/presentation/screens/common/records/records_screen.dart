import 'package:flutter/material.dart';
import '../../../../data/dummy_data.dart';
import '../../../../core/utils/date_formatter.dart';
import '../../../../core/utils/color_helper.dart';

class RecordsScreen extends StatefulWidget {
  const RecordsScreen({super.key});

  @override
  State<RecordsScreen> createState() => _RecordsScreenState();
}

class _RecordsScreenState extends State<RecordsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Overview Card
        _buildOverviewCard(),

        // Tabs
        Container(
          color: Colors.white,
          child: TabBar(
            controller: _tabController,
            labelColor: const Color(0xFF191919),
            unselectedLabelColor: Colors.grey,
            indicatorColor: const Color(0xFF191919),
            tabs: const [
              Tab(text: 'Overview'),
              Tab(text: 'Diet'),
              Tab(text: 'Exercise'),
            ],
          ),
        ),

        // Tab Views
        Expanded(
          child: TabBarView(
            controller: _tabController,
            children: [
              _buildOverviewTab(),
              _buildDietTab(),
              _buildExerciseTab(),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildOverviewCard() {
    final mealRecords = DummyData.mealRecords;
    final exerciseRecords = DummyData.exerciseRecords;

    final totalCaloriesConsumed = mealRecords.fold<int>(
      0,
      (sum, meal) => sum + meal.calories,
    );
    final totalCaloriesBurnt = exerciseRecords.fold<int>(
      0,
      (sum, exercise) => sum + exercise.caloriesBurnt,
    );
    final netCalories = totalCaloriesConsumed - totalCaloriesBurnt;

    Color netCalorieColor;
    IconData netCalorieIcon;

    if (netCalories > 500) {
      netCalorieColor = Colors.red;
      netCalorieIcon = Icons.trending_up;
    } else if (netCalories < -500) {
      netCalorieColor = Colors.orange;
      netCalorieIcon = Icons.trending_down;
    } else {
      netCalorieColor = Colors.green;
      netCalorieIcon = Icons.check_circle;
    }

    return Container(
      margin: const EdgeInsets.all(20),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            netCalorieColor.withOpacity(0.8),
            netCalorieColor,
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: netCalorieColor.withOpacity(0.3),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        children: [
          Icon(
            netCalorieIcon,
            size: 60,
            color: Colors.white,
          ),
          const SizedBox(height: 12),
          Text(
            '$netCalories',
            style: const TextStyle(
              fontSize: 36,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const Text(
            'Net Calories',
            style: TextStyle(
              fontSize: 16,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildCalorieInfo(
                'Consumed',
                totalCaloriesConsumed,
                Icons.restaurant,
              ),
              Container(
                height: 40,
                width: 1,
                color: Colors.white.withOpacity(0.5),
              ),
              _buildCalorieInfo(
                'Burned',
                totalCaloriesBurnt,
                Icons.local_fire_department,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCalorieInfo(String label, int value, IconData icon) {
    return Column(
      children: [
        Icon(icon, color: Colors.white, size: 24),
        const SizedBox(height: 8),
        Text(
          '$value',
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            color: Colors.white,
          ),
        ),
      ],
    );
  }

  Widget _buildOverviewTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Recent Activity',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          _buildActivityTimeline(),
        ],
      ),
    );
  }

  Widget _buildActivityTimeline() {
    final meals = DummyData.mealRecords;
    final exercises = DummyData.exerciseRecords;

    // Combine and sort by date
    final activities = <Map<String, dynamic>>[];

    for (var meal in meals) {
      activities.add({
        'type': 'meal',
        'data': meal,
        'time': meal.createdAt.toDate(),
      });
    }

    for (var exercise in exercises) {
      activities.add({
        'type': 'exercise',
        'data': exercise,
        'time': exercise.createdAt.toDate(),
      });
    }

    activities.sort((a, b) => b['time'].compareTo(a['time']));

    return Column(
      children: activities.map((activity) {
        if (activity['type'] == 'meal') {
          return _buildMealActivityCard(activity['data']);
        } else {
          return _buildExerciseActivityCard(activity['data']);
        }
      }).toList(),
    );
  }

  Widget _buildMealActivityCard(dynamic meal) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Image.network(
              meal.imageUrl,
              width: 60,
              height: 60,
              fit: BoxFit.cover,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.restaurant,
                      size: 16,
                      color: ColorHelper.getMealTypeColor(meal.mealType),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      meal.mealType.toUpperCase(),
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: ColorHelper.getMealTypeColor(meal.mealType),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  '${meal.calories} kcal',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  DateFormatter.getTimeAgo(meal.createdAt.toDate()),
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey.shade600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildExerciseActivityCard(dynamic exercise) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Row(
        children: [
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: ColorHelper.getIntensityColor(exercise.intensity)
                  .withOpacity(0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              Icons.fitness_center,
              color: ColorHelper.getIntensityColor(exercise.intensity),
              size: 30,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  exercise.exerciseName,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '${exercise.duration} min • ${exercise.caloriesBurnt} kcal burned',
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.grey.shade600,
                  ),
                ),
                Text(
                  DateFormatter.getTimeAgo(exercise.createdAt.toDate()),
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey.shade600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDietTab() {
    final meals = DummyData.mealRecords;

    return ListView.builder(
      padding: const EdgeInsets.all(20),
      itemCount: meals.length,
      itemBuilder: (context, index) {
        return _buildMealActivityCard(meals[index]);
      },
    );
  }

  Widget _buildExerciseTab() {
    final exercises = DummyData.exerciseRecords;

    return ListView.builder(
      padding: const EdgeInsets.all(20),
      itemCount: exercises.length,
      itemBuilder: (context, index) {
        return _buildExerciseActivityCard(exercises[index]);
      },
    );
  }
}
