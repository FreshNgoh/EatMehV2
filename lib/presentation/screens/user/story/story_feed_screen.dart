import 'dart:ui';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:eatmehv2/bloc/auth/auth_bloc.dart';
import 'package:eatmehv2/data/models/story/story_model.dart';
import 'package:eatmehv2/data/models/user/user_model.dart';
import 'package:eatmehv2/data/repos/story_repo.dart';
import 'package:eatmehv2/data/repos/user_repo.dart';
import 'package:eatmehv2/presentation/screens/user/profile_screen.dart';
import 'package:eatmehv2/presentation/screens/user/story/story_viewer_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class StoriesFeedScreen extends StatefulWidget {
  const StoriesFeedScreen({super.key});

  @override
  State<StoriesFeedScreen> createState() => _StoriesFeedScreenState();
}

class _StoriesFeedScreenState extends State<StoriesFeedScreen> {
  final StoryRepository _storyRepo = StoryRepository();
  final UserRepository _userRepo = UserRepository();
  Map<String, List<StoryModel>> _groupedStories = {};
  List<UserModel> _allFriends = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadStoriesAndFriends();
  }

  Future<void> _loadStoriesAndFriends() async {
    setState(() => _isLoading = true);

    try {
      final authState = context.read<AuthBloc>().state as Authenticated;
      final currentUser = authState.user;

      // Get current user's friends (WITHOUT current user for the list)
      final friendIds = currentUser.friends;

      // Load grouped stories (including current user)
      final allUserIds = [...friendIds, currentUser.uid];
      final grouped = await _storyRepo.getGroupedFriendsStories(allUserIds);

      // Load all friends' user data (WITHOUT current user)
      final friends = await _userRepo.getUsersByUids(friendIds);

      setState(() {
        _groupedStories = grouped;
        _allFriends = friends;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error loading stories: $e')));
      }
    }
  }

  void _openStoryViewer(String userId, List<StoryModel> stories) {
    final authState = context.read<AuthBloc>().state as Authenticated;
    final currentUser = authState.user;

    Navigator.push(
      context,
      MaterialPageRoute(
        builder:
            (context) => StoryViewerScreen(
              stories: stories,
              currentUserId: currentUser.uid,
              currentUsername: currentUser.username,
              currentUserImageUrl: currentUser.imageUrl ?? '',
            ),
      ),
    ).then((_) => _loadStoriesAndFriends());
  }

  // story ring based on different situation
  Widget _buildStoryRing({
    required String userId,
    required List<StoryModel> userStories,
    required bool isCurrentUser,
    required String currentUserId,
    String? imageUrl,
    String? username,
  }) {
    final hasUnviewed = userStories.any(
      (story) => !story.views.contains(currentUserId),
    );

    final displayImageUrl =
        imageUrl ??
        (userStories.isNotEmpty ? userStories.first.userImageUrl : '');
    final displayUsername =
        username ??
        (userStories.isNotEmpty ? userStories.first.username : 'You');

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: GestureDetector(
        onTap:
            userStories.isNotEmpty
                ? () => _openStoryViewer(userId, userStories)
                : null,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Stack(
              children: [
                // Gradient ring or add button
                Container(
                  width: 70,
                  height: 70,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient:
                        userStories.isNotEmpty && hasUnviewed
                            ? const LinearGradient(
                              colors: [
                                Color(0xFFFD1D1D),
                                Color(0xFFE1306C),
                                Color(0xFFC13584),
                                Color(0xFF833AB4),
                                Color(0xFF5851DB),
                              ],
                              begin: Alignment.topRight,
                              end: Alignment.bottomLeft,
                            )
                            : null,
                    border:
                        userStories.isNotEmpty && !hasUnviewed
                            ? Border.all(color: Colors.grey.shade300, width: 2)
                            : Border.all(color: Colors.grey.shade300, width: 2),
                  ),
                  padding: const EdgeInsets.all(3),
                  child: Container(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.white,
                      border: Border.all(color: Colors.white, width: 3),
                    ),
                    child: ClipOval(
                      child:
                          displayImageUrl.isNotEmpty
                              ? Image.network(
                                displayImageUrl,
                                fit: BoxFit.cover,
                                errorBuilder:
                                    (_, __, ___) =>
                                        Image.asset('assets/teralero.png'),
                              )
                              : Image.asset('assets/teralero.png'),
                    ),
                  ),
                ),

                // Add button for current user with no stories
                if (isCurrentUser && userStories.isEmpty)
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        color: Colors.blue,
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 2),
                      ),
                      child: const Icon(
                        Icons.add,
                        color: Colors.white,
                        size: 16,
                      ),
                    ),
                  ),

                // Story count badge
                if (userStories.length > 1)
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: const BoxDecoration(
                        color: Colors.blue,
                        shape: BoxShape.circle,
                      ),
                      child: Text(
                        '${userStories.length}',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 4),
            SizedBox(
              width: 70,
              child: Text(
                isCurrentUser ? 'Your Story' : displayUsername,
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight:
                      isCurrentUser ? FontWeight.w600 : FontWeight.normal,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final authState = context.read<AuthBloc>().state as Authenticated;
    final currentUser = authState.user;

    // Get current user's stories
    final currentUserStories = _groupedStories[currentUser.uid] ?? [];

    return Scaffold(
      body:
          _isLoading
              ? const Center(child: CircularProgressIndicator())
              : Column(
                children: [
                  // Story Rings Row - Always show current user + friends with stories
                  Container(
                    height: 120,
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    child: ListView(
                      scrollDirection: Axis.horizontal,
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                      children: [
                        // Always show current user first
                        _buildStoryRing(
                          userId: currentUser.uid,
                          userStories: currentUserStories,
                          isCurrentUser: true,
                          currentUserId: currentUser.uid,
                          imageUrl: currentUser.imageUrl,
                          username: currentUser.username,
                        ),
                        // Show friends with stories
                        ..._groupedStories.entries
                            .where((entry) => entry.key != currentUser.uid)
                            .map((entry) {
                              final userId = entry.key;
                              final userStories = entry.value;

                              return _buildStoryRing(
                                userId: userId,
                                userStories: userStories,
                                isCurrentUser: false,
                                currentUserId: currentUser.uid,
                              );
                            }),
                      ],
                    ),
                  ),

                  // Friends List
                  Expanded(
                    child:
                        _allFriends.isEmpty
                            ? Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.people_outline,
                                    size: 64,
                                    color: Colors.grey.shade400,
                                  ),
                                  const SizedBox(height: 16),
                                  Text(
                                    'No friends yet',
                                    style: TextStyle(
                                      fontSize: 18,
                                      color: Colors.grey.shade600,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    'Add friends to see their stories',
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: Colors.grey.shade500,
                                    ),
                                  ),
                                ],
                              ),
                            )
                            : ListView.builder(
                              padding: const EdgeInsets.fromLTRB(16, 1, 16, 18),
                              itemCount: _allFriends.length,
                              itemBuilder: (context, index) {
                                final friend = _allFriends[index];
                                final hasStories = _groupedStories.containsKey(
                                  friend.uid,
                                );
                                final userStories =
                                    hasStories
                                        ? _groupedStories[friend.uid]!
                                        : <StoryModel>[];

                                // Check if user has unviewed stories
                                final hasUnviewed =
                                    hasStories &&
                                    userStories.any(
                                      (story) =>
                                          !story.views.contains(
                                            currentUser.uid,
                                          ),
                                    );

                                return Container(
                                  margin: const EdgeInsets.symmetric(
                                    vertical: 8,
                                  ),

                                  child: Row(
                                    children: [
                                      // Leading avatar with story ring
                                      GestureDetector(
                                        // onTap: view story
                                        onTap:
                                            hasStories
                                                ? () => _openStoryViewer(
                                                  friend.uid,
                                                  userStories,
                                                )
                                                : null,

                                        // onlongPress: view profile
                                        onLongPressStart: (details) {
                                          OverlayEntry? overlayEntry;

                                          overlayEntry = OverlayEntry(
                                            builder: (context) {
                                              return Stack(
                                                children: [
                                                  // Blur background, dismiss when tapping anywhere
                                                  GestureDetector(
                                                    onTap:
                                                        () =>
                                                            overlayEntry
                                                                ?.remove(),
                                                    child: BackdropFilter(
                                                      filter: ImageFilter.blur(
                                                        sigmaX: 8,
                                                        sigmaY: 8,
                                                      ),
                                                      child: Container(
                                                        color: Colors.black
                                                            .withOpacity(0.1),
                                                      ),
                                                    ),
                                                  ),

                                                  // Menu positioned at touch
                                                  Positioned(
                                                    left:
                                                        details
                                                            .globalPosition
                                                            .dx,
                                                    top:
                                                        details
                                                            .globalPosition
                                                            .dy,
                                                    child: Material(
                                                      color: Colors.transparent,
                                                      child: Column(
                                                        mainAxisSize:
                                                            MainAxisSize.min,
                                                        children: [
                                                          InkWell(
                                                            onTap: () {
                                                              // Close the overlay
                                                              overlayEntry
                                                                  ?.remove();

                                                              // Navigate to ProfileScreen
                                                              Navigator.push(
                                                                context,
                                                                MaterialPageRoute(
                                                                  builder:
                                                                      (
                                                                        context,
                                                                      ) => ProfileScreen(
                                                                        userUid:
                                                                            friend.uid,
                                                                      ),
                                                                ),
                                                              );
                                                            },

                                                            child: Container(
                                                              padding:
                                                                  const EdgeInsets.all(
                                                                    12,
                                                                  ),
                                                              decoration: BoxDecoration(
                                                                color:
                                                                    Colors
                                                                        .white,
                                                                borderRadius:
                                                                    BorderRadius.circular(
                                                                      8,
                                                                    ),
                                                              ),
                                                              child: Row(
                                                                mainAxisSize:
                                                                    MainAxisSize
                                                                        .min,
                                                                children: const [
                                                                  Icon(
                                                                    Icons
                                                                        .person,
                                                                    size: 15,
                                                                    color:
                                                                        Colors
                                                                            .black54,
                                                                  ),
                                                                  SizedBox(
                                                                    width: 8,
                                                                  ),
                                                                  Text(
                                                                    "View Profile",
                                                                    style: TextStyle(
                                                                      fontSize:
                                                                          15,
                                                                      color:
                                                                          Colors
                                                                              .black54,
                                                                    ),
                                                                  ),
                                                                ],
                                                              ),
                                                            ),
                                                          ),
                                                        ],
                                                      ),
                                                    ),
                                                  ),
                                                ],
                                              );
                                            },
                                          );

                                          Overlay.of(
                                            context,
                                          ).insert(overlayEntry);
                                        },

                                        child: Stack(
                                          children: [
                                            Container(
                                              width: 56,
                                              height: 56,
                                              decoration: BoxDecoration(
                                                shape: BoxShape.circle,
                                                gradient:
                                                    hasStories && hasUnviewed
                                                        ? const LinearGradient(
                                                          colors: [
                                                            Color(0xFFFD1D1D),
                                                            Color(0xFFE1306C),
                                                            Color(0xFFC13584),
                                                            Color(0xFF833AB4),
                                                            Color(0xFF5851DB),
                                                          ],
                                                          begin:
                                                              Alignment
                                                                  .topRight,
                                                          end:
                                                              Alignment
                                                                  .bottomLeft,
                                                        )
                                                        : null,
                                                border:
                                                    hasStories && !hasUnviewed
                                                        ? Border.all(
                                                          color:
                                                              Colors
                                                                  .grey
                                                                  .shade300,
                                                          width: 2,
                                                        )
                                                        : Border.all(
                                                          color:
                                                              Colors
                                                                  .grey
                                                                  .shade200,
                                                          width: 1,
                                                        ),
                                              ),
                                              padding: const EdgeInsets.all(3),
                                              child: Container(
                                                decoration: BoxDecoration(
                                                  shape: BoxShape.circle,
                                                  color: Colors.white,
                                                  border: Border.all(
                                                    color: Colors.white,
                                                    width: 2,
                                                  ),
                                                ),
                                                child: ClipOval(
                                                  child:
                                                      friend.imageUrl != null &&
                                                              friend
                                                                  .imageUrl!
                                                                  .isNotEmpty
                                                          ? Image.network(
                                                            friend.imageUrl!,
                                                            fit: BoxFit.cover,
                                                            errorBuilder:
                                                                (
                                                                  _,
                                                                  __,
                                                                  ___,
                                                                ) => Image.asset(
                                                                  'assets/teralero.png',
                                                                ),
                                                          )
                                                          : Image.asset(
                                                            'assets/teralero.png',
                                                          ),
                                                ),
                                              ),
                                            ),

                                            // Story count badge
                                            if (hasStories &&
                                                userStories.length > 1)
                                              Positioned(
                                                bottom: 0,
                                                right: 0,
                                                child: Container(
                                                  padding: const EdgeInsets.all(
                                                    4,
                                                  ),
                                                  decoration:
                                                      const BoxDecoration(
                                                        color: Colors.blue,
                                                        shape: BoxShape.circle,
                                                      ),
                                                  child: Text(
                                                    '${userStories.length}',
                                                    style: const TextStyle(
                                                      color: Colors.white,
                                                      fontSize: 10,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                    ),
                                                  ),
                                                ),
                                              ),
                                          ],
                                        ),
                                      ),

                                      const SizedBox(width: 16),

                                      // Title and subtitle
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              friend.username,
                                              style: const TextStyle(
                                                fontWeight: FontWeight.w600,
                                                fontSize: 16,
                                              ),
                                            ),
                                            Text(
                                              hasStories
                                                  ? '${userStories.length} ${userStories.length == 1 ? "story" : "stories"} • ${_formatTimestamp(userStories.first.createdAt)}'
                                                  : 'No story',
                                              style: TextStyle(
                                                color: Colors.grey.shade600,
                                                fontSize: 13,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),

                                      // Trailing icon
                                      if (hasStories)
                                        Icon(
                                          Icons.circle,
                                          size: 12,
                                          color:
                                              hasUnviewed
                                                  ? Colors.blue
                                                  : Colors.grey.shade300,
                                        ),
                                    ],
                                  ),
                                );
                              },
                            ),
                  ),
                ],
              ),
    );
  }

  String _formatTimestamp(Timestamp timestamp) {
    final now = DateTime.now();
    final date = timestamp.toDate();
    final difference = now.difference(date);

    if (difference.inMinutes < 1) {
      return 'Just now';
    } else if (difference.inHours < 1) {
      return '${difference.inMinutes}m ago';
    } else if (difference.inHours < 24) {
      return '${difference.inHours}h ago';
    } else {
      return '${difference.inDays}d ago';
    }
  }
}
