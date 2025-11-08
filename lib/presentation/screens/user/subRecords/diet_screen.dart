import 'package:eatmehv2/core/theme/app_colors.dart';
import 'package:eatmehv2/presentation/widgets/custom_card.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class DietScreen extends StatefulWidget {
  const DietScreen({super.key});

  @override
  State<DietScreen> createState() => _DietScreenState();
}

class _DietScreenState extends State<DietScreen> {
  DateTime selectedDate = DateTime.now();

  void _previousDay() {
    setState(() {
      selectedDate = selectedDate.subtract(const Duration(days: 1));
    });
  }

  void _nextDay() {
    setState(() {
      selectedDate = selectedDate.add(const Duration(days: 1));
    });
  }

  Future<void> _selectDate() async {
    final date = await showDatePicker(
      context: context,
      initialDate: selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
    );
    if (date != null) {
      setState(() {
        selectedDate = date;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header with Date Navigation
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
                  IconButton(
                    icon: const Icon(Icons.chevron_right, size: 28),
                    onPressed: _nextDay,
                  ),
                ],
              ),
            ),

            // Nutrition Cards Carousel
            const Padding(
              padding: EdgeInsets.fromLTRB(20, 12, 20, 12),
              child: Row(
                children: [
                  Icon(Icons.apple_rounded, size: 23, color: Color(0xFF2D3748)),
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
                itemCount: 4, // Protein, Carbs, Fat, Fiber
                itemBuilder: (context, index) {
                  final nutritionData = [
                    _NutritionData(
                      'Protein',
                      22,
                      50,
                      AppColors.proteinIcon,
                      AppColors.proteinColor,
                    ),
                    _NutritionData(
                      'Carbs',
                      150,
                      250,
                      AppColors.carbsIcon,
                      AppColors.carbsColor,
                    ),
                    _NutritionData(
                      'Fat',
                      45,
                      70,
                      AppColors.fatIcon,
                      AppColors.fatColor,
                    ),
                    _NutritionData(
                      'Fiber',
                      18,
                      30,
                      AppColors.fiberIcon,
                      AppColors.fiberColor,
                    ),
                  ];

                  return _buildNutritionCard(nutritionData[index]);
                },
              ),
            ),

            // Meals Section
            Container(
              width: double.infinity,
              margin: const EdgeInsets.only(top: 2),
              padding: const EdgeInsets.all(20),
              // color: Colors.white,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.restaurant_menu,
                        size: 20,
                        color: Color(0xFF2D3748),
                      ),
                      SizedBox(width: 6),
                      const Text(
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
                  ...List.generate(
                    8, // Generate 8 meals to test scrolling
                    (index) => _buildMealCard(
                      'Grilled Chicken Salad ${index + 1}',
                      '13:59',
                      800,
                      22,
                      33,
                      22,
                      5,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNutritionCard(_NutritionData data) {
    final progress = data.current / data.goal;

    // Define border colors for each nutrition type
    final colorMap = {
      'Protein': AppColors.proteinColor,
      'Carbs': AppColors.carbsColor,
      'Fat': AppColors.fatColor,
      'Fiber': AppColors.fiberColor,
    };

    final Color mainColor = colorMap[data.name] ?? const Color(0xFF718096);

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
          // Soft drop shadow below
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 8,
            offset: const Offset(2, 4),
          ),
          // Gentle highlight on top-left
          BoxShadow(
            color: Colors.white.withOpacity(0.7),
            blurRadius: 6,
            offset: const Offset(-2, -2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  // color: data.color.withOpacity(0.1),
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
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
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
                    '${data.current}g',
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF2D3748),
                    ),
                  ),
                  Text(
                    ' / ${data.goal}g',
                    style: const TextStyle(
                      fontSize: 13,
                      color: Color(0xFF718096),
                    ),
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
        ],
      ),
    );
  }

  Widget _buildMealCard(
    String name,
    String time,
    int calories,
    int protein,
    int carbs,
    int fat,
    int fiber,
  ) {
    final calorieColor = AppColors.getCalorieColor(calories);
    return CustomCard(
      child: Row(
        children: [
          SizedBox(
            width: 90,
            height: 90,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: Image.asset(
                'assets/images/default_face.jpeg',
                fit: BoxFit.cover,
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
                    Text(
                      name,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF2D3748),
                      ),
                    ),
                    Text(
                      time,
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
                      '$calories cal',
                      calorieColor,
                    ),
                    _buildNutritionChip(
                      AppColors.proteinIcon,
                      '${protein}g',
                      AppColors.proteinColor,
                    ),
                    _buildNutritionChip(
                      AppColors.carbsIcon,
                      '${carbs}g',
                      AppColors.carbsColor,
                    ),
                    _buildNutritionChip(
                      AppColors.fatIcon,
                      '${fat}g',
                      AppColors.fatColor,
                    ),
                    _buildNutritionChip(
                      AppColors.fiberIcon,
                      '${fiber}g',
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
  final int current;
  final int goal;
  final IconData icon;
  final Color color;

  _NutritionData(this.name, this.current, this.goal, this.icon, this.color);
}
