import 'package:eatmehv2/data/models/user/user_model.dart';
import 'package:eatmehv2/data/repos/user_repo.dart';
import 'package:eatmehv2/presentation/screens/user/profile_screen.dart';
import 'package:flutter/material.dart';

class ProfileMeTab extends StatefulWidget {
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
  State<ProfileMeTab> createState() => _ProfileMeTabState();
}

class _ProfileMeTabState extends State<ProfileMeTab> {
  final UserRepository _userRepo = UserRepository();
  List<UserModel> _friends = [];
  UserModel? _trainer;
  bool _isLoadingFriends = true;
  bool _isLoadingTrainer = true;

  @override
  void initState() {
    super.initState();
    _loadFriends();
    _loadTrainer();
  }

  Future<void> _loadFriends() async {
    try {
      if (widget.user.friends.isNotEmpty) {
        final friends = await _userRepo.getUsersByUids(widget.user.friends);
        if (mounted) {
          setState(() {
            _friends = friends;
            _isLoadingFriends = false;
          });
        }
      } else {
        if (mounted) {
          setState(() => _isLoadingFriends = false);
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoadingFriends = false);
      }
    }
  }

  Future<void> _loadTrainer() async {
    try {
      if (widget.user.currentTrainerUid != null) {
        final trainer = await _userRepo.getUser(widget.user.currentTrainerUid!);
        if (mounted) {
          setState(() {
            _trainer = trainer;
            _isLoadingTrainer = false;
          });
        }
      } else {
        if (mounted) {
          setState(() => _isLoadingTrainer = false);
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoadingTrainer = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final bool hasFriends = _friends.isNotEmpty;
    final bool hasTrainer = _trainer != null;

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
                animation: widget.fadeAnimation,
                builder: (context, child) {
                  return FadeTransition(
                    opacity: widget.fadeAnimation,
                    child: Container(
                      width: 180,
                      height: 180,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: widget.netCaloriesColor.withOpacity(0.2),
                            blurRadius: 15,
                            spreadRadius: 8,
                          ),
                        ],
                      ),
                      child: ClipOval(
                        child: Image.asset(
                          widget.currentImagePath,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return widget.calorieStatusIcon;
                          },
                        ),
                      ),
                    ),
                  );
                },
              ),
              const SizedBox(height: 16),
              Text(
                '${widget.netCalories.toInt()}',
                style: TextStyle(
                  fontSize: 40,
                  fontWeight: FontWeight.bold,
                  color: widget.netCaloriesColor,
                  height: 1,
                ),
              ),
              Text(
                'kcal',
                style: TextStyle(
                  fontSize: 16,
                  color: widget.netCaloriesColor.withOpacity(0.7),
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
                  color: widget.netCaloriesColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  widget.statusText,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: widget.netCaloriesColor,
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildCalorieInfo(
                    'Taken',
                    widget.caloriesTaken,
                    Colors.orange,
                    Icons.local_fire_department,
                  ),
                  Container(height: 40, width: 1, color: Colors.grey[300]),
                  _buildCalorieInfo(
                    'Burnt',
                    widget.caloriesBurnt,
                    Colors.blue,
                    Icons.directions_run,
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),

        // Friends Section - Only show if has friends
        if (hasFriends || _isLoadingFriends) ...[
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
              const SizedBox(width: 8),
              if (_friends.isNotEmpty)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade200,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    '${_friends.length}',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Colors.grey.shade700,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 12),
          SizedBox(
            height: 60,
            child:
                _isLoadingFriends
                    ? const Center(
                      child: SizedBox(
                        width: 30,
                        height: 30,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      ),
                    )
                    : ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: _friends.length,
                      itemBuilder: (context, index) {
                        final friend = _friends[index];
                        return Padding(
                          padding: const EdgeInsets.only(right: 12.0),
                          child: GestureDetector(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder:
                                      (_) => ProfileScreen(userUid: friend.uid),
                                ),
                              );
                            },
                            child: Column(
                              children: [
                                CircleAvatar(
                                  radius: 25,
                                  backgroundColor: Colors.grey.shade300,
                                  backgroundImage:
                                      friend.imageUrl != null &&
                                              friend.imageUrl!.isNotEmpty
                                          ? NetworkImage(friend.imageUrl!)
                                          : null,
                                  child:
                                      friend.imageUrl == null ||
                                              friend.imageUrl!.isEmpty
                                          ? Text(
                                            friend.username[0].toUpperCase(),
                                            style: const TextStyle(
                                              fontSize: 18,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          )
                                          : null,
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
          ),
          const SizedBox(height: 24),
        ],

        // Trainer Section - Only show if has trainer
        if (hasTrainer || _isLoadingTrainer) ...[
          Row(
            children: [
              Icon(Icons.fitness_center, size: 23, color: Color(0xFF2D3748)),
              SizedBox(width: 6),
              Text(
                "Trainer",
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
            child:
                _isLoadingTrainer
                    ? const Center(
                      child: SizedBox(
                        width: 30,
                        height: 30,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      ),
                    )
                    : _trainer != null
                    ? GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder:
                                (_) => ProfileScreen(userUid: _trainer!.uid),
                          ),
                        );
                      },
                      child: Row(
                        children: [
                          CircleAvatar(
                            radius: 25,
                            backgroundColor: Colors.grey.shade200,
                            backgroundImage:
                                _trainer!.imageUrl != null &&
                                        _trainer!.imageUrl!.isNotEmpty
                                    ? NetworkImage(_trainer!.imageUrl!)
                                    : null,
                            child:
                                _trainer!.imageUrl == null ||
                                        _trainer!.imageUrl!.isEmpty
                                    ? Text(
                                      _trainer!.username[0].toUpperCase(),
                                      style: const TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    )
                                    : null,
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  _trainer!.username,
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                if (_trainer!.trainerProfile != null)
                                  Row(
                                    children: [
                                      Icon(
                                        Icons.star,
                                        size: 14,
                                        color: Colors.amber,
                                      ),
                                      const SizedBox(width: 4),
                                      Text(
                                        _trainer!.trainerProfile!.rating
                                            .toStringAsFixed(1),
                                        style: TextStyle(
                                          fontSize: 13,
                                          color: Colors.grey.shade600,
                                        ),
                                      ),
                                    ],
                                  ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    )
                    : const SizedBox.shrink(),
          ),
        ],
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
