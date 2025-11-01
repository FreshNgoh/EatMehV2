import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../../data/dummy_data.dart';
import '../../../../core/utils/calorie_calculator.dart';
import '../../../widgets/status/user_status_widget.dart';
import 'settings_screen.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final user = DummyData.currentUser;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          // Profile Picture
          Stack(
            children: [
              CircleAvatar(
                radius: 60,
                backgroundImage: NetworkImage(user.imageUrl ?? ''),
              ),
              Positioned(
                bottom: 0,
                right: 0,
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: const Color(0xFF191919),
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 2),
                  ),
                  child: const Icon(
                    Icons.camera_alt,
                    color: Colors.white,
                    size: 20,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),

          // Username
          Text(
            user.username,
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),

          const SizedBox(height: 8),

          // User ID (Copyable)
          GestureDetector(
            onTap: () {
              Clipboard.setData(ClipboardData(text: user.uid));
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('User ID copied to clipboard'),
                  duration: Duration(seconds: 2),
                ),
              );
            },
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.grey.shade200,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'ID: ${user.uid}',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey.shade700,
                    ),
                  ),
                  const SizedBox(width: 4),
                  Icon(
                    Icons.copy,
                    size: 14,
                    color: Colors.grey.shade700,
                  ),
                ],
              ),
            ),
          ),

          if (user.bio != null) ...[
            const SizedBox(height: 12),
            Text(
              user.bio!,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey.shade600,
              ),
            ),
          ],

          const SizedBox(height: 24),

          // Stats Row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildStatItem('Friends', user.friends.length.toString()),
              _buildStatItem('Posts', DummyData.mealRecords.length.toString()),
              _buildStatItem(
                'Streak',
                '${DummyData.mealRecords.length + DummyData.exerciseRecords.length}',
              ),
            ],
          ),

          const SizedBox(height: 24),

          // User Status Widget
          if (user.status != null)
            UserStatusWidget(
              status: user.status!,
              weeklyCalorieIntake: DummyData.mealRecords
                  .fold(0, (sum, meal) => sum + meal.calories),
              weeklyCalorieBurn: DummyData.exerciseRecords
                  .fold(0, (sum, ex) => sum + ex.caloriesBurnt),
            ),

          const SizedBox(height: 24),

          // Menu Items
          _buildMenuItem(
            context,
            icon: Icons.settings,
            title: 'Settings',
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const SettingsScreen()),
              );
            },
          ),

          _buildMenuItem(
            context,
            icon: Icons.person_add,
            title: 'Become a Trainer',
            onTap: () {
              // Navigate to trainer application
            },
          ),

          _buildMenuItem(
            context,
            icon: Icons.help_outline,
            title: 'Help & Support',
            onTap: () {
              // Show help
            },
          ),

          _buildMenuItem(
            context,
            icon: Icons.logout,
            title: 'Logout',
            isDestructive: true,
            onTap: () {
              _showLogoutDialog(context);
            },
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(String label, String value) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 14,
            color: Colors.grey.shade600,
          ),
        ),
      ],
    );
  }

  Widget _buildMenuItem(
    BuildContext context, {
    required IconData icon,
    required String title,
    required VoidCallback onTap,
    bool isDestructive = false,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.grey.shade100,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: isDestructive
                        ? Colors.red.shade100
                        : const Color(0xFF191919).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    icon,
                    color: isDestructive ? Colors.red : const Color(0xFF191919),
                    size: 20,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Text(
                    title,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: isDestructive ? Colors.red : Colors.black,
                    ),
                  ),
                ),
                Icon(
                  Icons.arrow_forward_ios,
                  size: 16,
                  color: Colors.grey.shade600,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Logout'),
        content: const Text('Are you sure you want to logout?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              // Perform logout
              Navigator.pushReplacementNamed(context, '/login');
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Logout'),
          ),
        ],
      ),
    );
  }
}
