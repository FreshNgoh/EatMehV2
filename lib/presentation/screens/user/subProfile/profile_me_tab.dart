import 'package:eatmehv2/data/models/user/user_model.dart';
import 'package:flutter/material.dart';

class ProfileMeTab extends StatelessWidget {
  final int caloriesTaken;
  final int caloriesBurnt;
  final double netCalories;
  final Color netCaloriesColor;
  final String statusText;
  final String currentImagePath;
  final Animation<double> fadeAnimation;
  final VoidCallback onStatusIconError;
  final Widget calorieStatusIcon;
  final UserModel user;

  const ProfileMeTab({
    super.key,
    required this.caloriesTaken,
    required this.caloriesBurnt,
    required this.netCalories,
    required this.netCaloriesColor,
    required this.statusText,
    required this.currentImagePath,
    required this.fadeAnimation,
    required this.onStatusIconError,
    required this.calorieStatusIcon,
    required this.user,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(Icons.today, size: 23, color: Color(0xFF2D3748)),
            SizedBox(width: 6),
            Text(
              "Today's Status",
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w600,
                color: Color(0xFF2D3748),
              ),
            ),
          ],
        ),
        const SizedBox(height: 20),

        // Calorie Status Card with Animated Image
        Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              // Animated Image instead of Icon
              AnimatedBuilder(
                animation: fadeAnimation,
                builder: (context, child) {
                  return FadeTransition(
                    opacity: fadeAnimation,
                    child: Container(
                      width: 180,
                      height: 180,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: netCaloriesColor.withOpacity(0.2),
                            blurRadius: 15,
                            spreadRadius: 8,
                          ),
                        ],
                      ),
                      child: ClipOval(
                        child: Image.asset(
                          currentImagePath,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return calorieStatusIcon;
                          },
                        ),
                      ),
                    ),
                  );
                },
              ),
              const SizedBox(height: 16),
              Text(
                '${netCalories.toInt()}',
                style: TextStyle(
                  fontSize: 40,
                  fontWeight: FontWeight.bold,
                  color: netCaloriesColor,
                  height: 1,
                ),
              ),
              Text(
                'Cal',
                style: TextStyle(
                  fontSize: 16,
                  color: netCaloriesColor.withOpacity(0.7),
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: netCaloriesColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  statusText,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: netCaloriesColor,
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildCalorieInfo(
                    'Taken',
                    caloriesTaken,
                    Colors.orange,
                    Icons.local_fire_department,
                  ),
                  Container(height: 40, width: 1, color: Colors.grey[300]),
                  _buildCalorieInfo(
                    'Burnt',
                    caloriesBurnt,
                    Colors.blue,
                    Icons.directions_run,
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),

        // Friends Section
        Row(
          children: [
            Icon(Icons.people_alt_rounded, size: 23, color: Color(0xFF2D3748)),
            SizedBox(width: 6),
            Text(
              "Friends",
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w600,
                color: Color(0xFF2D3748),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: 60,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: 5,
            itemBuilder: (context, index) {
              return Padding(
                padding: const EdgeInsets.only(right: 12.0),
                child: const CircleAvatar(
                  radius: 30,
                  backgroundColor: Colors.white,
                  backgroundImage: AssetImage(
                    "assets/images/default_face.jpeg",
                  ),
                ),
              );
            },
          ),
        ),
        const SizedBox(height: 24),

        // Trainer Section
        Row(
          children: [
            Icon(Icons.fitness_center, size: 23, color: Color(0xFF2D3748)),
            SizedBox(width: 6),
            Text(
              "Trainers",
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w600,
                color: Color(0xFF2D3748),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: 60,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: 2,
            itemBuilder: (context, index) {
              return Padding(
                padding: const EdgeInsets.only(right: 12.0),
                child: const CircleAvatar(
                  radius: 30,
                  backgroundColor: Colors.white,
                  backgroundImage: AssetImage(
                    "assets/images/default_face.jpeg",
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildCalorieInfo(
    String label,
    int value,
    Color color,
    IconData icon,
  ) {
    return Column(
      children: [
        Row(
          children: [
            Icon(icon, size: 16, color: color),
            const SizedBox(width: 4),
            Text(
              label,
              style: TextStyle(fontSize: 14, color: Colors.grey[600]),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Text(
          '$value kcal',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
      ],
    );
  }
}
