import 'package:eatmehv2/bloc/auth/auth_bloc.dart';
import 'package:eatmehv2/core/theme/app_colors.dart';
import 'package:eatmehv2/data/models/meal/meal_record_model.dart';
import 'package:eatmehv2/data/repos/meal_records_repo.dart';
import 'package:eatmehv2/presentation/widgets/custom_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

class DietScreen extends StatefulWidget {
  const DietScreen({super.key});

  @override
  State<DietScreen> createState() => _DietScreenState();
}

class _DietScreenState extends State<DietScreen> {
  DateTime selectedDate = DateTime.now();
  late MealRecordsRepository _mealRepo;

  @override
  void initState() {
    super.initState();
    _mealRepo = MealRecordsRepository();
  }

  void _previousDay() {
    setState(
      () => selectedDate = selectedDate.subtract(const Duration(days: 1)),
    );
  }

  void _nextDay() {
    setState(() => selectedDate = selectedDate.add(const Duration(days: 1)));
  }

  Future<void> _selectDate() async {
    final date = await showDatePicker(
      context: context,
      initialDate: selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
    );
    if (date != null) setState(() => selectedDate = date);
  }

  @override
  Widget build(BuildContext context) {
    final authState = context.read<AuthBloc>().state as Authenticated;

    final userUid = authState.user.uid;

    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // === HEADER ===
            Container(
              padding: const EdgeInsets.fromLTRB(15, 10, 15, 10),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  IconButton(
                    icon: const Icon(Icons.chevron_left, size: 28),
                    onPressed: _previousDay,
                  ),
                  GestureDetector(
                    onTap: _selectDate,
                    child: Row(
                      children: [
                        Text(
                          DateFormat('EEE, MMM d').format(selectedDate),
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF2D3748),
                          ),
                        ),
                        const SizedBox(width: 8),
                        const Icon(Icons.calendar_today_outlined, size: 20),
                      ],
                    ),
                  ),
                  // unable to click if selected date is today (can not go to future)
                  IconButton(
                    icon: const Icon(Icons.chevron_right, size: 28),
                    onPressed:
                        selectedDate.isBefore(
                              DateTime(
                                DateTime.now().year,
                                DateTime.now().month,
                                DateTime.now().day,
                              ),
                            )
                            ? _nextDay
                            : null,
                    color:
                        selectedDate.isBefore(
                              DateTime(
                                DateTime.now().year,
                                DateTime.now().month,
                                DateTime.now().day,
                              ),
                            )
                            ? Colors.black
                            : Colors.grey.shade400,
                  ),
                ],
              ),
            ),

            // === FUTURE BUILDER TO LOAD FIREBASE DATA ===
            FutureBuilder<List<MealRecordModel>>(
              future: _mealRepo.fetchMealRecordsByUserAndDate(
                userUid: userUid,
                date: selectedDate,
              ),
              builder: (context, snapshot) {
                // loading
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(
                    child: Padding(
                      padding: EdgeInsets.all(50),
                      child: CircularProgressIndicator(),
                    ),
                  );
                }

                // error
                if (snapshot.hasError) {
                  return Padding(
                    padding: const EdgeInsets.fromLTRB(20, 12, 20, 12),
                    child: CustomCard(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Image.asset(
                            'assets/error.png',
                            height: 200,
                            width: 200,
                          ),
                          const SizedBox(height: 12),
                          Text(
                            'Error loading records:\n${snapshot.error}',
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              color: Colors.red,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }
                // no data
                final meals = snapshot.data ?? [];
                if (meals.isEmpty) {
                  return Padding(
                    padding: EdgeInsets.fromLTRB(20, 12, 20, 12),
                    child: CustomCard(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Image.asset(
                            'assets/noData.png',
                            height: 200,
                            width: 200,
                          ),
                          SizedBox(height: 12),
                          Text(
                            "No meal records found for this date.",
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: Color(0xFF403D39),
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }

                // === AGGREGATE NUTRITION DATA ===
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
                    // === NUTRITION SECTION ===
                    const Padding(
                      padding: EdgeInsets.fromLTRB(20, 12, 20, 12),
                      child: Row(
                        children: [
                          Icon(
                            Icons.apple_rounded,
                            size: 23,
                            color: Color(0xFF2D3748),
                          ),
                          SizedBox(width: 6),
                          Text(
                            'Nutrition',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF2D3748),
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(
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

                    // === MEALS SECTION ===
                    Container(
                      width: double.infinity,
                      margin: const EdgeInsets.only(top: 2),
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Row(
                            children: [
                              Icon(
                                Icons.restaurant_menu,
                                size: 20,
                                color: Color(0xFF2D3748),
                              ),
                              SizedBox(width: 6),
                              Text(
                                'Meals',
                                style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.w600,
                                  color: Color(0xFF2D3748),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          ...meals.map((meal) => _buildMealCard(meal)).toList(),
                        ],
                      ),
                    ),
                  ],
                );
              },
            ),
          ],
        ),
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
          BoxShadow(
            color: Colors.white.withOpacity(0.7),
            blurRadius: 6,
            offset: const Offset(-2, -2),
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

  Widget _buildMealCard(MealRecordModel meal) {
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
                    SizedBox(width: 8),
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
                      '${meal.calories} cal',
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
