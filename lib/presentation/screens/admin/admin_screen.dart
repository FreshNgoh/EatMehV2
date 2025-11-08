import 'package:flutter/material.dart';
import 'package:eatmehv2/presentation/screens/admin/admin_user_screen.dart';
import 'package:eatmehv2/presentation/screens/admin/admin_request.dart';
import 'package:eatmehv2/presentation/screens/admin/admin_report.dart';
import 'package:eatmehv2/presentation/widgets/custom_app_bar.dart';

class AdminScreen extends StatefulWidget {
  const AdminScreen({super.key});

  @override
  State<AdminScreen> createState() => _AdminHomeScreenState();
}

class _AdminHomeScreenState extends State<AdminScreen> {
  int _selectedIndex = 0;

  final List<String> _titles = [
    'Users',
    'Requests',
    'Data',
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        title: _titles[_selectedIndex],
        showNotification: true,
        showFriendRequest: false,
      ),
      body: _buildPage(_selectedIndex),
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
                _buildNavItem(0, Icons.person, 'Users'),
                _buildNavItem(1, Icons.assignment, 'Requests'),
                _buildNavItem(2, Icons.data_array, 'Data'),
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
                color: isSelected ? const Color(0xFF191919) : Colors.grey.shade600,
                size: 24,
              ),
              const SizedBox(height: 4),
              Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                  color: isSelected ? const Color(0xFF191919) : Colors.grey.shade600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Move _buildPage inside the state class
  Widget _buildPage(int index) {
  switch (index) {
    case 0:
      return const UserScreen();
    case 1:
      return const RequestScreen();
    case 2:
      return const DataScreen();
    default:
      return const UserScreen();
    }
  }
}
