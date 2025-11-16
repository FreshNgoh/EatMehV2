import 'package:eatmehv2/bloc/auth/auth_bloc.dart';
import 'package:eatmehv2/core/theme/app_colors.dart';
import 'package:eatmehv2/data/models/exercise/exercise_model.dart';
import 'package:eatmehv2/data/models/meal/meal_record_model.dart';
import 'package:eatmehv2/data/models/user/user_model.dart';
import 'package:eatmehv2/data/repos/exercise_repo.dart';
import 'package:eatmehv2/data/repos/meal_records_repo.dart';
import 'package:eatmehv2/data/repos/user_repo.dart';
import 'package:eatmehv2/presentation/widgets/custom_card.dart';
import 'package:eatmehv2/utils/calorie_utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  late MealRecordsRepository _mealRepo;
  late ExerciseRepository _exerciseRepo;

  final UserRepository _userRepo = UserRepository();
  UserModel? _user; // local user state
  bool _isLoadingUser = true;

  @override
  void initState() {
    super.initState();
    _mealRepo = MealRecordsRepository();
    _exerciseRepo = ExerciseRepository();

    final authState = context.read<AuthBloc>().state as Authenticated;
    final userUid = authState.user.uid;
    _loadUserData(userUid);
  }

  Future<void> _loadUserData(String uid) async {
    try {
      final user = await _userRepo.getUser(uid); // fetch user from repo
      setState(() {
        _user = user;
        _isLoadingUser = false;
      });
    } catch (e) {
      setState(() {
        _isLoadingUser = false;
      });
      print('Error loading user: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final today = DateTime.now();

    if (_isLoadingUser) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    if (_user == null) {
      return const Scaffold(
        body: Center(child: Text('Failed to load user data')),
      );
    }

    final user = _user!;
    final userUid = user.uid;

    // ✅ Check if user has completed their profile
    final hasCompleteProfile =
        user.height != null &&
        user.weight != null &&
        user.age != null &&
        user.gender != null;

    // Calculate user metrics only if profile is complete
    final bmi = CalorieUtils.calculateBMI(
      heightCm: user.height,
      weightKg: user.weight,
    );

    final double? maintenanceCalories =
        hasCompleteProfile
            ? CalorieUtils.calculateMaintenanceCalories(
              weightKg: user.weight!,
              heightCm: user.height!,
              age: user.age!,
              gender: user.gender!,
            )
            : null;

    final double? lowThreshold =
        maintenanceCalories != null
            ? CalorieUtils.getLowCalorieThreshold(
              maintenanceCalories: maintenanceCalories,
            )
            : null;

    final double? highThreshold =
        maintenanceCalories != null
            ? CalorieUtils.getHighCalorieThreshold(
              maintenanceCalories: maintenanceCalories,
            )
            : null;

    return Scaffold(
      backgroundColor: const Color(0xFFF9F9F9),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // === USER INFO SECTION ===
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Hello, ${user.username}!',
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF2D3748),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    DateFormat('EEEE, MMMM d, yyyy').format(today),
                    style: const TextStyle(
                      fontSize: 14,
                      color: Color(0xFF718096),
                    ),
                  ),
                  const SizedBox(height: 24),

                  // User Stats Cards
                  Row(
                    children: [
                      Expanded(
                        child: _buildStatCard(
                          icon: Icons.height,
                          label: 'Height',
                          value: '${user.height?.toStringAsFixed(0) ?? '-'} cm',
                          color: AppColors.info,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _buildStatCard(
                          icon: Icons.monitor_weight,
                          label: 'Weight',
                          value: '${user.weight?.toStringAsFixed(1) ?? '-'} kg',
                          color: AppColors.secondary,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),

                  // BMI Card
                  if (bmi != null)
                    CustomCard(
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: CalorieUtils.getBMIColor(
                                bmi,
                              ).withOpacity(0.1),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Icon(
                              Icons.favorite,
                              color: CalorieUtils.getBMIColor(bmi),
                              size: 24,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'Body Mass Index (BMI)',
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: Color(0xFF718096),
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Row(
                                  children: [
                                    Text(
                                      bmi.toStringAsFixed(1),
                                      style: const TextStyle(
                                        fontSize: 24,
                                        fontWeight: FontWeight.bold,
                                        color: Color(0xFF2D3748),
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 8,
                                        vertical: 4,
                                      ),
                                      decoration: BoxDecoration(
                                        color: CalorieUtils.getBMIColor(
                                          bmi,
                                        ).withOpacity(0.1),
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: Text(
                                        CalorieUtils.getBMICategory(bmi),
                                        style: TextStyle(
                                          fontSize: 12,
                                          fontWeight: FontWeight.bold,
                                          color: CalorieUtils.getBMIColor(bmi),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),

                  const SizedBox(height: 16),

                  // Calorie Thresholds Section (only show if profile is complete)
                  if (hasCompleteProfile &&
                      lowThreshold != null &&
                      highThreshold != null) ...[
                    const Text(
                      'Daily Calorie Guide',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF2D3748),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: _buildCalorieThresholdCard(
                            icon: Icons.trending_down,
                            label: 'Too Low',
                            value: '< ${lowThreshold.toInt()}',
                            color: AppColors.caloriesLow,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: _buildCalorieThresholdCard(
                            icon: Icons.check_circle,
                            label: 'Healthy',
                            value:
                                '${lowThreshold.toInt()}-${highThreshold.toInt()}',
                            color: AppColors.caloriesMedium,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: _buildCalorieThresholdCard(
                            icon: Icons.trending_up,
                            label: 'Too High',
                            value: '> ${highThreshold.toInt()}',
                            color: AppColors.caloriesHigh,
                          ),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),

            // const SizedBox(height: 12),

            // === TODAY'S NUTRITION SECTION ===
            FutureBuilder<List<MealRecordModel>>(
              future: _mealRepo.fetchMealRecordsByUserAndDate(
                userUid: userUid,
                date: today,
              ),
              builder: (context, mealSnapshot) {
                if (mealSnapshot.connectionState == ConnectionState.waiting) {
                  return const Center(
                    child: Padding(
                      padding: EdgeInsets.all(20),
                      child: CircularProgressIndicator(),
                    ),
                  );
                }

                final meals = mealSnapshot.data ?? [];

                // Calculate nutrition totals
                final totalProtein = meals.fold<double>(
                  0,
                  (sum, meal) => sum + meal.nutritionInfo.protein,
                );
                final totalCarbs = meals.fold<double>(
                  0,
                  (sum, meal) => sum + meal.nutritionInfo.carbs,
                );
                final totalFat = meals.fold<double>(
                  0,
                  (sum, meal) => sum + meal.nutritionInfo.fat,
                );
                final totalFiber = meals.fold<double>(
                  0,
                  (sum, meal) => sum + meal.nutritionInfo.fiber,
                );

                final nutritionData = [
                  _NutritionData(
                    'Protein',
                    totalProtein,
                    50,
                    AppColors.proteinIcon,
                    AppColors.proteinColor,
                  ),
                  _NutritionData(
                    'Carbs',
                    totalCarbs,
                    250,
                    AppColors.carbsIcon,
                    AppColors.carbsColor,
                  ),
                  _NutritionData(
                    'Fat',
                    totalFat,
                    70,
                    AppColors.fatIcon,
                    AppColors.fatColor,
                  ),
                  _NutritionData(
                    'Fiber',
                    totalFiber,
                    30,
                    AppColors.fiberIcon,
                    AppColors.fiberColor,
                  ),
                ];

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.fromLTRB(20, 12, 20, 12),
                      child: Row(
                        children: [
                          const Icon(
                            Icons.apple_rounded,
                            size: 23,
                            color: Color(0xFF2D3748),
                          ),
                          const SizedBox(width: 8),
                          const Text(
                            "Today's Nutrition",
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF2D3748),
                            ),
                          ),
                        ],
                      ),
                    ),

                    meals.isEmpty
                        ? Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          child: CustomCard(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Image.asset(
                                  'assets/noData.png',
                                  height: 200,
                                  width: 200,
                                ),
                                const SizedBox(height: 12),
                                const Text(
                                  "No meals recorded today",
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    color: Color(0xFF403D39),
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        )
                        : SizedBox(
                          height: 160,
                          child: ListView.builder(
                            scrollDirection: Axis.horizontal,
                            padding: const EdgeInsets.symmetric(horizontal: 12),
                            itemCount: nutritionData.length,
                            itemBuilder:
                                (context, index) =>
                                    _buildNutritionCard(nutritionData[index]),
                          ),
                        ),
                  ],
                );
              },
            ),

            const SizedBox(height: 12),

            // === TODAY'S EXERCISE SECTION (CAROUSEL) ===
            FutureBuilder<List<ExerciseRecordModel>>(
              future: _exerciseRepo.fetchExercises(
                userUid: userUid,
                date: today,
              ),
              builder: (context, exerciseSnapshot) {
                if (exerciseSnapshot.connectionState ==
                    ConnectionState.waiting) {
                  return const Center(
                    child: Padding(
                      padding: EdgeInsets.all(20),
                      child: CircularProgressIndicator(),
                    ),
                  );
                }

                final exercises = exerciseSnapshot.data ?? [];

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.fromLTRB(20, 12, 20, 12),
                      child: Row(
                        children: [
                          const Icon(
                            Icons.fitness_center,
                            size: 23,
                            color: Color(0xFF2D3748),
                          ),
                          const SizedBox(width: 8),
                          const Text(
                            "Today's Exercise",
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF2D3748),
                            ),
                          ),
                        ],
                      ),
                    ),
                    exercises.isEmpty
                        ? Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          child: CustomCard(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Image.asset(
                                  'assets/noData.png',
                                  height: 200,
                                  width: 200,
                                ),
                                const SizedBox(height: 12),
                                const Text(
                                  "No exercises recorded today",
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    color: Color(0xFF403D39),
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        )
                        : SizedBox(
                          height: 160,
                          child: ListView.builder(
                            scrollDirection: Axis.horizontal,
                            padding: const EdgeInsets.symmetric(horizontal: 12),
                            itemCount: exercises.length,
                            itemBuilder:
                                (context, index) =>
                                    _buildExerciseCard(exercises[index]),
                          ),
                        ),
                  ],
                );
              },
            ),

            // === TODAY'S MEALS SECTION ===
            FutureBuilder<List<MealRecordModel>>(
              future: _mealRepo.fetchMealRecordsByUserAndDate(
                userUid: userUid,
                date: today,
              ),
              builder: (context, mealSnapshot) {
                if (mealSnapshot.connectionState == ConnectionState.waiting) {
                  return const SizedBox.shrink();
                }

                final meals = mealSnapshot.data ?? [];

                if (meals.isEmpty) {
                  return const SizedBox.shrink();
                }

                return Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Icon(
                            Icons.restaurant_menu,
                            size: 20,
                            color: Color(0xFF2D3748),
                          ),
                          const SizedBox(width: 8),
                          const Text(
                            "Today's Meals",
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF2D3748),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      ...meals
                          .map(
                            (meal) => _buildMealCard(meal, maintenanceCalories),
                          )
                          .toList(),
                    ],
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatCard({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
    return CustomCard(
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: color, size: 24),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: const TextStyle(fontSize: 12, color: Color(0xFF718096)),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Color(0xFF2D3748),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCalorieThresholdCard({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3), width: 1),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 25),
          const SizedBox(height: 6),
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: color,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            value,
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          const SizedBox(height: 2),
          const Text(
            'kcal',
            style: TextStyle(fontSize: 10, color: Color(0xFF718096)),
          ),
        ],
      ),
    );
  }

  Widget _buildNutritionCard(_NutritionData data) {
    final progress = (data.goal == 0) ? 0.0 : (data.current / data.goal);
    final Color mainColor = data.color;

    return Container(
      width: 180,
      margin: const EdgeInsets.symmetric(horizontal: 8),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.white, Colors.grey.shade100],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: mainColor.withOpacity(0.15), width: 1.5),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 8,
            offset: const Offset(2, 4),
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: mainColor.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(data.icon, color: mainColor, size: 24),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: mainColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  '${(progress * 100).toInt()}%',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: mainColor,
                  ),
                ),
              ),
            ],
          ),
          Text(
            data.name,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: Color(0xFF718096),
            ),
          ),
          const SizedBox(height: 6),
          Row(
            children: [
              Text(
                '${data.current.toStringAsFixed(1)}g',
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF2D3748),
                ),
              ),
              Text(
                ' / ${data.goal}g',
                style: const TextStyle(fontSize: 13, color: Color(0xFF718096)),
              ),
            ],
          ),
          const SizedBox(height: 10),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: progress,
              backgroundColor: const Color(0xFFE2E8F0),
              valueColor: AlwaysStoppedAnimation<Color>(mainColor),
              minHeight: 6,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildExerciseCard(ExerciseRecordModel exercise) {
    final iconData = AppColors.exerciseIconData[exercise.exerciseName];
    final icon = iconData?['icon'] as IconData? ?? Icons.fitness_center;
    final color = iconData?['color'] as Color? ?? Colors.blue;

    return Container(
      width: 180,
      margin: const EdgeInsets.symmetric(horizontal: 8),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.white, Colors.grey.shade100],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withOpacity(0.15), width: 1.5),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 8,
            offset: const Offset(2, 4),
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: color.withOpacity(0.15),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: color, size: 24),
          ),
          Text(
            exercise.exerciseName,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Color(0xFF2D3748),
            ),
          ),
          const SizedBox(height: 4),
          Row(
            children: [
              const Icon(Icons.timer, size: 14, color: Color(0xFF718096)),
              const SizedBox(width: 4),
              Text(
                '${exercise.duration} mins',
                style: const TextStyle(fontSize: 12, color: Color(0xFF718096)),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: const Color(0xFFF59E0B).withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.local_fire_department,
                  size: 14,
                  color: Color(0xFFF59E0B),
                ),
                const SizedBox(width: 4),
                Text(
                  '${exercise.caloriesBurnt} kcal',
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFFF59E0B),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMealCard(MealRecordModel meal, double? maintenanceCalories) {
    // Use general meal calorie thresholds (not user-specific for individual meals)
    final calorieColor = AppColors.getCalorieColor(meal.calories);

    return CustomCard(
      child: Row(
        children: [
          SizedBox(
            width: 90,
            height: 90,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: Image.network(
                meal.imageUrl ?? '',
                fit: BoxFit.cover,
                errorBuilder:
                    (_, __, ___) => Image.asset(
                      'assets/images/error.png',
                      fit: BoxFit.cover,
                    ),
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Flexible(
                      child: Text(
                        meal.foodName,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF2D3748),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      DateFormat('HH:mm').format(meal.createdAt.toDate()),
                      style: const TextStyle(
                        fontSize: 13,
                        color: Color(0xFF718096),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 12,
                  runSpacing: 6,
                  children: [
                    _buildNutritionChip(
                      Icons.local_fire_department,
                      '${meal.calories} kcal',
                      calorieColor,
                    ),
                    _buildNutritionChip(
                      AppColors.proteinIcon,
                      '${meal.nutritionInfo.protein}g',
                      AppColors.proteinColor,
                    ),
                    _buildNutritionChip(
                      AppColors.carbsIcon,
                      '${meal.nutritionInfo.carbs}g',
                      AppColors.carbsColor,
                    ),
                    _buildNutritionChip(
                      AppColors.fatIcon,
                      '${meal.nutritionInfo.fat}g',
                      AppColors.fatColor,
                    ),
                    _buildNutritionChip(
                      AppColors.fiberIcon,
                      '${meal.nutritionInfo.fiber}g',
                      AppColors.fiberColor,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNutritionChip(IconData icon, String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: color),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}

class _NutritionData {
  final String name;
  final double current;
  final double goal;
  final IconData icon;
  final Color color;

  _NutritionData(this.name, this.current, this.goal, this.icon, this.color);
}
