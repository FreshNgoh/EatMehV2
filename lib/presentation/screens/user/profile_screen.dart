import 'dart:async';

import 'package:eatmehv2/bloc/auth/auth_bloc.dart';
import 'package:eatmehv2/core/theme/app_colors.dart';
import 'package:eatmehv2/data/models/user/user_model.dart';
import 'package:eatmehv2/data/repos/calorie_tracker_repo.dart';
import 'package:eatmehv2/data/repos/user_repo.dart';
import 'package:eatmehv2/presentation/screens/user/edit_profile.dart';
import 'package:eatmehv2/presentation/screens/user/setting_screen.dart';
import 'package:eatmehv2/presentation/screens/user/subProfile/profile_consult_tab.dart';
import 'package:eatmehv2/presentation/screens/user/subProfile/profile_me_tab.dart';
import 'package:eatmehv2/presentation/widgets/custom_card.dart';
import 'package:eatmehv2/utils/calorie_utils.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:eatmehv2/presentation/widgets/friend_request_button.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class ProfileScreen extends StatefulWidget {
  final String userUid;

  const ProfileScreen({super.key, required this.userUid});

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

  final UserRepository _userRepo = UserRepository();
  final CalorieTrackerRepository _calorieRepo = CalorieTrackerRepository();

  UserModel? _user;
  Map<String, double>? _calorieData;
  bool _isLoading = true;
  String _errorMessage = '';
  bool get isOwnProfile =>
      FirebaseAuth.instance.currentUser?.uid == widget.userUid;

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

    _loadUserData();
  }

  Future<void> _loadUserData() async {
    try {
      setState(() {
        _isLoading = true;
        _errorMessage = '';
      });

      // Fetch user data
      final user = await _userRepo.getUser(widget.userUid);
      if (user == null) {
        setState(() {
          _errorMessage = 'User not found';
          _isLoading = false;
        });
        return;
      }

      // Fetch calorie data for today
      final calorieData = await _calorieRepo.fetchCaloriesByPeriod(
        userUid: widget.userUid,
        date: DateTime.now(),
        period: 'daily',
      );

      setState(() {
        _user = user;
        _calorieData = calorieData;
        _isLoading = false;
      });

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
    } catch (e) {
      setState(() {
        _errorMessage = 'Failed to load user data: $e';
        _isLoading = false;
      });
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    _imageTimer?.cancel();
    super.dispose();
  }

  void _updateImage() {
    if (_calorieData == null) return;

    final caloriesTaken = _calorieData!['taken'] ?? 0.0;
    final caloriesBurnt = _calorieData!['burnt'] ?? 0.0;
    final netCalories = CalorieUtils.calculateNetCalories(
      caloriesTaken,
      caloriesBurnt,
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
      MaterialPageRoute(builder: (_) => EditProfile(user: _user!)),
    );
  }

  void _showBioEditor(BuildContext context) {
    if (!isOwnProfile) return; // Only allow editing own bio

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder:
          (context) => BioEditorSheet(
            currentBio: _user?.bio ?? '',
            onSave: (newBio) async {
              try {
                await _userRepo.updateUser(widget.userUid, {'bio': newBio});
                await _loadUserData(); // Reload data
                if (mounted) {
                  ScaffoldMessenger.of(
                    context,
                  ).showSnackBar(const SnackBar(content: Text('Bio updated!')));
                }
              } catch (e) {
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Failed to update bio: $e')),
                  );
                }
              }
            },
          ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Profile'),
          centerTitle: true,
          leadingWidth: 60,
        ),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    if (_errorMessage.isNotEmpty || _user == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Profile'), centerTitle: true),
        body: Center(
          child: CustomCard(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Image.asset('assets/error.png', height: 200, width: 200),
                const SizedBox(height: 12),
                Text(
                  'Error loading records:\n $_errorMessage',
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: Colors.red,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: _loadUserData,
                  child: const Text('Retry'),
                ),
              ],
            ),
          ),
        ),
      );
    }

    // Extract data from user model
    final userName = _user!.username;
    final userId = '@${_user!.uid.substring(0, 10)}...'; // Shortened UID
    final userBio =
        _user!.bio != null && _user!.bio!.isNotEmpty
            ? _user!.bio! // user has a bio, show it
            : isOwnProfile
            ? 'Tap here to fill in your bio' // own profile, no bio yet
            : 'This user hasn\'t written a bio yet'; // someone else's profile, no bio

    final hasBio = _user!.bio != null && _user!.bio!.isNotEmpty;
    final caloriesTaken = _calorieData?['taken']?.toInt() ?? 0;
    final caloriesBurnt = _calorieData?['burnt']?.toInt() ?? 0;
    final netCalories = CalorieUtils.calculateNetCalories(
      caloriesTaken.toDouble(),
      caloriesBurnt.toDouble(),
    );

    final calorieStatus = CalorieUtils.getCalorieStatus(netCalories);
    final netCaloriesColor = CalorieUtils.getStatusColor(netCalories);
    final statusText = CalorieUtils.getStatusText(calorieStatus);

    // user image
    final ImageProvider avatarImage =
        (_user!.imageUrl != null && _user!.imageUrl!.isNotEmpty)
            ? NetworkImage(_user!.imageUrl!)
            : const AssetImage("assets/teralero.png");

    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        centerTitle: true,
        leadingWidth: 60,
        title: Text(isOwnProfile ? 'Profile' : userName),
        actions: [
          if (isOwnProfile) ...[
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
                              CircleAvatar(
                                radius: 50,
                                backgroundColor: Colors.white,
                                backgroundImage: avatarImage,
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
                                          ClipboardData(text: _user!.uid),
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
                                    // const SizedBox(height: 4),
                                    _buildProfileActions(
                                      context,
                                      _user!,
                                      isOwnProfile,
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 15),

                          // User Bio
                          GestureDetector(
                            onTap:
                                isOwnProfile && !hasBio
                                    ? () => _showBioEditor(context)
                                    : null,
                            child: Text(
                              userBio,
                              style: TextStyle(
                                fontSize: 14,
                                color:
                                    hasBio
                                        ? Colors.grey[700]
                                        : Colors.grey[500],
                                fontStyle:
                                    hasBio
                                        ? FontStyle.normal
                                        : FontStyle.italic,
                              ),
                            ),
                          ),
                          const SizedBox(height: 15),

                          // Badges
                          Wrap(
                            spacing: 10,
                            runSpacing: 8,
                            children: [
                              if (_user!.gender != null)
                                _buildBadge(
                                  _user!.gender == 'male'
                                      ? Icons.male
                                      : Icons.female,
                                  _user!.gender!,
                                  _user!.gender == 'male'
                                      ? Colors.blue
                                      : Colors.pink,
                                ),
                              if (_user!.bmi != null)
                                _buildBadge(
                                  Icons.monitor_weight,
                                  'BMI ${_user!.bmi!.toStringAsFixed(1)}',
                                  Colors.deepOrange,
                                ),
                              if (_user!.role == 'trainer')
                                _buildBadge(
                                  Icons.fitness_center,
                                  'Trainer',
                                  Colors.orange,
                                ),
                              if (_user!.dietType != null)
                                _buildBadge(
                                  Icons.restaurant_menu,
                                  _user!.dietType!,
                                  AppColors.getDietColor(_user!.dietType!),
                                ),
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
                              user: _user!,
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
                              onStatusIconError: () {},
                            )
                            : (_user!.trainerProfile != null
                                ? ProfileConsultTab(
                                  trainerProfile: _user!.trainerProfile!,
                                  trainerUid: _user!.uid,
                                )
                                : Center(
                                  child: Padding(
                                    padding: EdgeInsets.all(40.0),
                                    child: Text(
                                      isOwnProfile
                                          ? "Apply as trainer!"
                                          : 'He/She has no trainer profile yet.',
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                        fontSize: 16,
                                        color: Colors.grey,
                                      ),
                                    ),
                                  ),
                                )),
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

  Widget _buildProfileActions(
    BuildContext context,
    UserModel profileUser,
    bool isOwnProfile,
  ) {
    // Don't show if viewing own profile
    if (isOwnProfile) {
      return const SizedBox.shrink();
    }

    return BlocBuilder<AuthBloc, AuthState>(
      builder: (context, state) {
        if (state is! Authenticated) {
          return const SizedBox.shrink();
        }

        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 10),
          child: FriendRequestButton(
            targetUserId: profileUser.uid,
            currentUserFriends: state.user.friends,
            targetUserFriendRequests: profileUser.friendRequests,
            currentUserFriendRequests: state.user.friendRequests,
          ),
        );
      },
    );
  }
}

// Bio Editor Bottom Sheet
class BioEditorSheet extends StatefulWidget {
  final String currentBio;
  final Function(String) onSave;

  const BioEditorSheet({
    super.key,
    required this.currentBio,
    required this.onSave,
  });

  @override
  State<BioEditorSheet> createState() => _BioEditorSheetState();
}

class _BioEditorSheetState extends State<BioEditorSheet> {
  late TextEditingController _bioController;

  @override
  void initState() {
    super.initState();
    _bioController = TextEditingController(text: widget.currentBio);
  }

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
          Container(
            margin: const EdgeInsets.only(top: 12),
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(2),
            ),
          ),
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
                    widget.onSave(_bioController.text);
                    Navigator.pop(context);
                  },
                  child: const Text('Save', style: TextStyle(fontSize: 18)),
                ),
              ],
            ),
          ),
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
