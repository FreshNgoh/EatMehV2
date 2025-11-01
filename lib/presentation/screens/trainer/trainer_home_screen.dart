import 'package:flutter/material.dart';
import '../common/friends/friends_screen.dart';
import '../common/records/records_screen.dart';
import '../common/camera/camera_screen.dart';
import 'trainees_screen.dart';
import '../common/profile/profile_screen.dart';
import '../../widgets/common/custom_app_bar.dart';

class TrainerHomeScreen extends StatefulWidget {
  const TrainerHomeScreen({super.key});

  @override
  State<TrainerHomeScreen> createState() => _TrainerHomeScreenState();
}

class _TrainerHomeScreenState extends State<TrainerHomeScreen> {
  int _selectedIndex = 0;

  final List<Widget> _pages = [
    const FriendsScreen(),
    const RecordsScreen(),
    const CameraScreen(),
    const TraineesScreen(),
    const ProfileScreen(),
  ];

  final List<String> _titles = [
    'Friends',
    'Records',
    'Camera',
    'Trainees',
    'Profile',
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        title: _titles[_selectedIndex],
        showNotification: true,
        showFriendRequest: _selectedIndex == 0,
      ),
      body: IndexedStack(
        index: _selectedIndex,
        children: _pages,
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 10,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildNavItem(0, Icons.people, 'Friends'),
                _buildNavItem(1, Icons.assessment, 'Records'),
                _buildNavItem(2, Icons.camera_alt, 'Camera'),
                _buildNavItem(3, Icons.fitness_center, 'Trainees'),
                _buildNavItem(4, Icons.person, 'Profile'),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem(int index, IconData icon, String label) {
    final isSelected = _selectedIndex == index;

    return Expanded(
      child: GestureDetector(
        onTap: () {
          setState(() {
            _selectedIndex = index;
          });
        },
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 8),
          decoration: BoxDecoration(
            color: isSelected
                ? const Color(0xFF191919).withOpacity(0.1)
                : Colors.transparent,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                icon,
                color:
                    isSelected ? const Color(0xFF191919) : Colors.grey.shade600,
                size: 22,
              ),
              const SizedBox(height: 4),
              Text(
                label,
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                  color: isSelected
                      ? const Color(0xFF191919)
                      : Colors.grey.shade600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
