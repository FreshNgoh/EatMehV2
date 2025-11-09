import 'dart:async';
import 'package:eatmehv2/presentation/screens/user/edit_profile.dart';
import 'package:eatmehv2/presentation/screens/user/setting_screen.dart';
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
            backgroundColor: Colors.white,
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

          // Section 2: User Activities (with expandable height on scroll)
          SliverToBoxAdapter(
            child: Container(
              margin: const EdgeInsets.only(top: 20),
              decoration: BoxDecoration(
                color: Colors.grey[50],
                border: Border.all(color: Colors.grey[100]!, width: 2),
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(40),
                  topRight: Radius.circular(40),
                ),
              ),
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 30),
                child: Column(
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
                    Container(
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.grey.withOpacity(0.1),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Column(
                        children: [
                          // Animated Image instead of Icon
                          AnimatedBuilder(
                            animation: _animationController,
                            builder: (context, child) {
                              return FadeTransition(
                                opacity: _fadeAnimation,
                                child: Container(
                                  width: 120,
                                  height: 120,
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    shape: BoxShape.circle,
                                    boxShadow: [
                                      BoxShadow(
                                        color: netCaloriesColor.withOpacity(
                                          0.2,
                                        ),
                                        blurRadius: 15,
                                        spreadRadius: 8,
                                      ),
                                    ],
                                  ),
                                  child: ClipOval(
                                    child: Image.asset(
                                      _currentImagePath,
                                      fit: BoxFit.cover,
                                      errorBuilder: (
                                        context,
                                        error,
                                        stackTrace,
                                      ) {
                                        return Icon(
                                          CalorieUtils.getStatusIcon(
                                            calorieStatus,
                                          ),
                                          size: 60,
                                          color: netCaloriesColor,
                                        );
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
                              fontSize: 52,
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
                                fontSize: 16,
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
                              Container(
                                height: 40,
                                width: 1,
                                color: Colors.grey[300],
                              ),
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
                        Icon(
                          Icons.people_alt_rounded,
                          size: 23,
                          color: Color(0xFF2D3748),
                        ),
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
                        Icon(
                          Icons.fitness_center,
                          size: 23,
                          color: Color(0xFF2D3748),
                        ),
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
                ),
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
