import 'dart:async';
import 'package:eatmehv2/presentation/screens/user/edit_profile.dart';
import 'package:eatmehv2/presentation/screens/user/setting_screen.dart';
import 'package:eatmehv2/presentation/screens/user/subProfile/profile_consult_tab.dart';
import 'package:eatmehv2/presentation/screens/user/subProfile/profile_me_tab.dart';
import 'package:eatmehv2/utils/calorie_utils.dart';
import 'package:flutter/services.dart';
import 'package:flutter/material.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  Timer? _imageTimer;
  String _currentImagePath = '';
  int _selectedTabIndex = 0; // 0 = Me, 1 = Consult

  @override
  void initState() {
    super.initState();

    _animationController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeIn),
    );

    _updateImage();
    _animationController.forward();

    // Automatically change image every few seconds
    _imageTimer = Timer.periodic(const Duration(seconds: 5), (_) {
      _updateImage();
      _animationController
        ..reset()
        ..forward();
      setState(() {});
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    _imageTimer?.cancel();
    super.dispose();
  }

  void _updateImage() {
    // Get calorie status based on current net calories
    const int caloriesTaken = 1850;
    const int caloriesBurnt = 450;
    final netCalories = CalorieUtils.calculateNetCalories(
      caloriesTaken.toDouble(),
      caloriesBurnt.toDouble(),
    );
    final calorieStatus = CalorieUtils.getCalorieStatus(netCalories);
    _currentImagePath = CalorieUtils.getRandomStatusImage(calorieStatus);
  }

  void _showSettings(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const SettingScreen()),
    );
  }

  void _showEditProfile(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const EditProfile()),
    );
  }

  void _showBioEditor(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const BioEditorSheet(),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Dummy data
    const String userName = 'John Doe';
    const String userId = '@johndoe123';
    const String userBio = 'Tap here to fill in your bio';
    const bool hasBio = false;
    const int caloriesTaken = 1850;
    const int caloriesBurnt = 450;
    final double netCalories = CalorieUtils.calculateNetCalories(
      caloriesTaken.toDouble(),
      caloriesBurnt.toDouble(),
    );

    // Calculate status using utils
    final calorieStatus = CalorieUtils.getCalorieStatus(netCalories);
    final netCaloriesColor = CalorieUtils.getStatusColor(netCalories);
    final statusText = CalorieUtils.getStatusText(calorieStatus);

    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        centerTitle: true,
        leadingWidth: 60,
        title: const Text('Profile Page'),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit_outlined),
            onPressed: () => _showEditProfile(context),
          ),
          Padding(
            padding: const EdgeInsets.only(right: 15.0),
            child: IconButton(
              icon: const Icon(Icons.settings),
              onPressed: () => _showSettings(context),
            ),
          ),
        ],
      ),
      body: CustomScrollView(
        slivers: [
          // Section 1: User Info
          SliverAppBar(
            expandedHeight: 230,
            pinned: false,
            automaticallyImplyLeading: false,
            flexibleSpace: FlexibleSpaceBar(
              background: Stack(
                fit: StackFit.expand,
                children: [
                  // Section 1: User Info
                  Container(
                    width: double.infinity,
                    color: Colors.white,
                    child: Padding(
                      padding: const EdgeInsets.all(20.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              const CircleAvatar(
                                radius: 50,
                                backgroundColor: Colors.white,
                                backgroundImage: AssetImage(
                                  "assets/teralero.png",
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      userName,
                                      style: const TextStyle(
                                        fontSize: 25,
                                        fontWeight: FontWeight.bold,
                                        color: Color(0xFF2D3748),
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    GestureDetector(
                                      onLongPress: () {
                                        Clipboard.setData(
                                          ClipboardData(text: userId),
                                        );
                                        ScaffoldMessenger.of(
                                          context,
                                        ).showSnackBar(
                                          const SnackBar(
                                            content: Text(
                                              'User ID copied to clipboard!',
                                            ),
                                            duration: Duration(seconds: 1),
                                          ),
                                        );
                                      },
                                      child: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Text(
                                            userId,
                                            style: TextStyle(
                                              fontSize: 12,
                                              color: Colors.grey[600],
                                            ),
                                          ),
                                          const SizedBox(width: 4),
                                          const Icon(
                                            Icons.copy,
                                            size: 14,
                                            color: Colors.grey,
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),

                          const SizedBox(height: 20),

                          // User Bio
                          GestureDetector(
                            onTap: () => _showBioEditor(context),
                            child: Text(
                              userBio,
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey[500],
                              ),
                            ),
                          ),
                          const SizedBox(height: 20),

                          // Badges
                          Wrap(
                            spacing: 10,
                            runSpacing: 8,
                            children: [
                              _buildBadge(Icons.male, 'Male', Colors.blue),
                              _buildBadge(
                                Icons.monitor_weight,
                                'BMI 22.5',
                                Colors.green,
                              ),
                              _buildBadge(
                                Icons.fitness_center,
                                'Trainer',
                                Colors.orange,
                              ),
                              _buildBadge(Icons.eco, 'Vegan', Colors.teal),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Section 2: User Activities with Tabs
          SliverToBoxAdapter(
            child: Container(
              decoration: BoxDecoration(
                color: Colors.grey[50],
                border: Border(
                  top: BorderSide(color: Colors.grey[200]!, width: 2),
                ),
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(40),
                  topRight: Radius.circular(40),
                ),
              ),
              child: Column(
                children: [
                  // Tab Header
                  Padding(
                    padding: const EdgeInsets.fromLTRB(20, 20, 20, 10),
                    child: Row(
                      children: [
                        // "Me" Tab
                        Expanded(
                          child: GestureDetector(
                            onTap: () {
                              setState(() {
                                _selectedTabIndex = 0;
                              });
                            },
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  'Me',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight:
                                        _selectedTabIndex == 0
                                            ? FontWeight.w600
                                            : FontWeight.w200,

                                    color:
                                        _selectedTabIndex == 0
                                            ? Colors.black
                                            : Colors.grey[500],
                                  ),
                                ),
                                const SizedBox(height: 4),
                                // Underline indicator
                                Container(
                                  height: 3,
                                  width: 30,
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(1.5),
                                    gradient:
                                        _selectedTabIndex == 0
                                            ? const LinearGradient(
                                              colors: [
                                                Colors.lightGreen,
                                                Colors.green,
                                              ],
                                            )
                                            : const LinearGradient(
                                              colors: [
                                                Colors.transparent,
                                                Colors.transparent,
                                              ],
                                            ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),

                        // "Consult" Tab
                        Expanded(
                          child: GestureDetector(
                            onTap: () {
                              setState(() {
                                _selectedTabIndex = 1;
                              });
                            },
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  'Consult',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight:
                                        _selectedTabIndex == 1
                                            ? FontWeight.w600
                                            : FontWeight.w200,

                                    color:
                                        _selectedTabIndex == 1
                                            ? Colors.black
                                            : Colors.grey[500],
                                  ),
                                ),
                                const SizedBox(height: 4),
                                // Underline indicator
                                Container(
                                  height: 3,
                                  width: 30,
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(1.5),
                                    gradient:
                                        _selectedTabIndex == 1
                                            ? const LinearGradient(
                                              colors: [
                                                Colors.lightGreen,
                                                Colors.green,
                                              ],
                                            )
                                            : const LinearGradient(
                                              colors: [
                                                Colors.transparent,
                                                Colors.transparent,
                                              ],
                                            ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Tab Content
                  Padding(
                    padding: const EdgeInsets.fromLTRB(20, 10, 20, 30),
                    child:
                        _selectedTabIndex == 0
                            ? ProfileMeTab(
                              caloriesTaken: caloriesTaken,
                              caloriesBurnt: caloriesBurnt,
                              netCalories: netCalories,
                              netCaloriesColor: netCaloriesColor,
                              statusText: statusText,
                              currentImagePath: _currentImagePath,
                              fadeAnimation: _fadeAnimation,
                              calorieStatusIcon: Icon(
                                CalorieUtils.getStatusIcon(calorieStatus),
                                size: 60,
                                color: netCaloriesColor,
                              ),
                              onStatusIconError: () {
                                // Handle error if needed
                              },
                            )
                            : const ProfileConsultTab(),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBadge(IconData icon, String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: color, size: 14),
          const SizedBox(width: 6),
          Text(
            label,
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w600,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}

// Bio Editor Bottom Sheet
class BioEditorSheet extends StatefulWidget {
  const BioEditorSheet({super.key});

  @override
  State<BioEditorSheet> createState() => _BioEditorSheetState();
}

class _BioEditorSheetState extends State<BioEditorSheet> {
  final TextEditingController _bioController = TextEditingController();

  @override
  void dispose() {
    _bioController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.6,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
      ),
      child: Column(
        children: [
          // Handle bar
          Container(
            margin: const EdgeInsets.only(top: 12),
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          // Header
          Padding(
            padding: const EdgeInsets.all(20.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text(
                    'Cancel',
                    style: TextStyle(color: Colors.grey, fontSize: 16),
                  ),
                ),
                const Text(
                  'Edit Bio',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF2D3748),
                  ),
                ),
                TextButton(
                  onPressed: () {
                    // TODO: Save bio
                    Navigator.pop(context);
                    ScaffoldMessenger.of(
                      context,
                    ).showSnackBar(const SnackBar(content: Text('Bio saved!')));
                  },
                  child: const Text('Save', style: TextStyle(fontSize: 18)),
                ),
              ],
            ),
          ),
          // Text field
          SizedBox(
            height: 120,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              child: TextField(
                controller: _bioController,
                maxLines: 5,
                maxLength: 150,
                decoration: const InputDecoration(
                  hintText: 'Tell us about yourself...',
                  border: OutlineInputBorder(),
                  alignLabelWithHint: true,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
