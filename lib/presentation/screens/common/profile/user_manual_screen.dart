import 'package:flutter/material.dart';

class UserManualScreen extends StatelessWidget {
  const UserManualScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('User Manual'),
        backgroundColor: Colors.white,
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          _buildManualSection(
            icon: Icons.camera_alt,
            title: 'Taking Photos',
            description: '1. Tap the Camera tab\n'
                '2. Point camera at your meal\n'
                '3. Tap the capture button\n'
                '4. Review and analyze or post as story',
          ),
          const SizedBox(height: 20),
          _buildManualSection(
            icon: Icons.auto_awesome,
            title: 'AI Analysis',
            description: 'Our AI automatically detects:\n'
                '• Food items in your meal\n'
                '• Estimated calories\n'
                '• Nutritional recommendations\n'
                '• Meal type (breakfast, lunch, dinner)',
          ),
          const SizedBox(height: 20),
          _buildManualSection(
            icon: Icons.add_circle,
            title: 'Posting Stories',
            description: '1. Take a photo of your meal\n'
                '2. Tap "Post Story"\n'
                '3. Your story will be visible to friends for 24 hours\n'
                '4. See who viewed your story',
          ),
          const SizedBox(height: 20),
          _buildManualSection(
            icon: Icons.people,
            title: 'Adding Friends',
            description: '1. Go to Friends tab\n'
                '2. Tap the + button\n'
                '3. Enter friend\'s User ID\n'
                '4. Wait for them to accept',
          ),
          const SizedBox(height: 20),
          _buildManualSection(
            icon: Icons.track_changes,
            title: 'Tracking Progress',
            description: 'View your progress in:\n'
                '• Daily calorie intake\n'
                '• Exercise calories burned\n'
                '• Weight changes\n'
                '• BMI calculations',
          ),
        ],
      ),
    );
  }

  Widget _buildManualSection({
    required IconData icon,
    required String title,
    required String description,
  }) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: const Color(0xFF191919),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: Colors.white, size: 24),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
                      fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            description,
            style: TextStyle(
                fontSize: 14, color: Colors.grey.shade700, height: 1.5),
          ),
        ],
      ),
    );
  }
}
