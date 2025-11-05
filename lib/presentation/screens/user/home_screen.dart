import 'package:eatmehv2/presentation/screens/user/camera_screen.dart';
import 'package:eatmehv2/presentation/screens/user/consult_screen.dart';
import 'package:eatmehv2/presentation/screens/user/dashboard_screen.dart';
import 'package:eatmehv2/presentation/screens/user/friends_screen.dart';
import 'package:eatmehv2/presentation/screens/user/record_screen.dart';
import 'package:eatmehv2/presentation/widgets/custom_app_bar.dart';
import 'package:flutter/material.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;
  int _selectedRecordTab = 0;

  final List<String> _titles = [
    'Dashboard',
    'Friends',
    'Camera',
    'Consult',
    'Records',
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        title: _titles[_selectedIndex],
        showNotification: true,
        showFriendRequest: _selectedIndex == 1,
        selectedRecordTab: _selectedRecordTab,
        onRecordTabChange: (index) {
          setState(() {
            _selectedRecordTab = index;
          });
        },
      ),
      body: _buildPage(_selectedIndex, _selectedRecordTab),
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
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildNavItem(0, Icons.dashboard, 'Dashboard'),
                _buildNavItem(1, Icons.people_alt_rounded, 'Friends'),
                _buildNavItem(2, Icons.camera_alt, 'Camera'),
                _buildNavItem(3, Icons.chat_bubble_rounded, 'Consult'),
                _buildNavItem(4, Icons.note_alt_rounded, 'Records'),
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
            color:
                isSelected
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
                size: 24,
              ),
              const SizedBox(height: 4),
              Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                  color:
                      isSelected
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

Widget _buildPage(int index, int selectedRecordTab) {
  switch (index) {
    case 0:
      return const DashboardScreen();
    case 1:
      return const FriendsScreen();
    case 2:
      return const CameraScreen();
    case 3:
      return const ConsultScreen();
    case 4:
      return RecordScreen(selectedTab: selectedRecordTab);
    default:
      return const DashboardScreen();
  }
}
