import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:eatmehv2/bloc/auth/auth_bloc.dart';
import 'package:eatmehv2/data/models/story/story_model.dart';
import 'package:eatmehv2/data/models/user/user_model.dart';
import 'package:eatmehv2/data/repos/story_repo.dart';
import 'package:eatmehv2/data/repos/user_repo.dart';
import 'package:eatmehv2/presentation/screens/user/story/story_viewer_screen.dart';

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

      // Get current user's friends + self
      final friendIds = [...currentUser.friends, currentUser.uid];

      // Load grouped stories
      final grouped = await _storyRepo.getGroupedFriendsStories(friendIds);

      // Load all friends' user data
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
    ).then((_) => _loadStoriesAndFriends()); // Refresh after viewing
  }

  @override
  Widget build(BuildContext context) {
    final authState = context.read<AuthBloc>().state as Authenticated;
    final currentUser = authState.user;

    return Scaffold(
      body:
          _isLoading
              ? const Center(child: CircularProgressIndicator())
              : Column(
                children: [
                  // Story Rings Row - Only users WITH stories
                  if (_groupedStories.isNotEmpty)
                    Container(
                      height: 110,
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.grey.shade200,
                            blurRadius: 4,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        padding: const EdgeInsets.symmetric(horizontal: 8),
                        itemCount: _groupedStories.length,
                        itemBuilder: (context, index) {
                          final userId = _groupedStories.keys.elementAt(index);
                          final userStories = _groupedStories[userId]!;
                          final firstStory = userStories.first;

                          // Check if current user has viewed all stories
                          final hasUnviewed = userStories.any(
                            (story) => !story.views.contains(currentUser.uid),
                          );

                          final isCurrentUser = userId == currentUser.uid;

                          return Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 8),
                            child: GestureDetector(
                              onTap:
                                  () => _openStoryViewer(userId, userStories),
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Stack(
                                    children: [
                                      // Gradient ring
                                      Container(
                                        width: 70,
                                        height: 70,
                                        decoration: BoxDecoration(
                                          shape: BoxShape.circle,
                                          gradient:
                                              hasUnviewed
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
                                              !hasUnviewed
                                                  ? Border.all(
                                                    color: Colors.grey.shade300,
                                                    width: 2,
                                                  )
                                                  : null,
                                        ),
                                        padding: const EdgeInsets.all(3),
                                        child: Container(
                                          decoration: BoxDecoration(
                                            shape: BoxShape.circle,
                                            border: Border.all(
                                              color: Colors.white,
                                              width: 3,
                                            ),
                                          ),
                                          child: ClipOval(
                                            child:
                                                firstStory
                                                        .userImageUrl
                                                        .isNotEmpty
                                                    ? Image.network(
                                                      firstStory.userImageUrl,
                                                      fit: BoxFit.cover,
                                                      errorBuilder:
                                                          (
                                                            _,
                                                            __,
                                                            ___,
                                                          ) => Container(
                                                            color:
                                                                Colors
                                                                    .grey
                                                                    .shade300,
                                                            child: const Icon(
                                                              Icons.person,
                                                            ),
                                                          ),
                                                    )
                                                    : Container(
                                                      color:
                                                          Colors.grey.shade300,
                                                      child: const Icon(
                                                        Icons.person,
                                                      ),
                                                    ),
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
                                      isCurrentUser
                                          ? 'Your Story'
                                          : firstStory.username,
                                      textAlign: TextAlign.center,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: TextStyle(
                                        fontSize: 12,
                                        fontWeight:
                                            isCurrentUser
                                                ? FontWeight.bold
                                                : FontWeight.normal,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    ),

                  const Divider(height: 1),

                  // All Friends List (with and without stories)
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
                              padding: const EdgeInsets.all(16),
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
                                final isCurrentUser =
                                    friend.uid == currentUser.uid;

                                // Check if user has unviewed stories
                                final hasUnviewed =
                                    hasStories &&
                                    userStories.any(
                                      (story) =>
                                          !story.views.contains(
                                            currentUser.uid,
                                          ),
                                    );

                                return Card(
                                  margin: const EdgeInsets.only(bottom: 12),
                                  elevation: hasStories ? 2 : 0,
                                  color:
                                      hasStories
                                          ? Colors.white
                                          : Colors.grey.shade50,
                                  child: ListTile(
                                    leading: Stack(
                                      children: [
                                        // Profile picture with story ring
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
                                                      begin: Alignment.topRight,
                                                      end: Alignment.bottomLeft,
                                                    )
                                                    : null,
                                            border:
                                                hasStories && !hasUnviewed
                                                    ? Border.all(
                                                      color:
                                                          Colors.grey.shade300,
                                                      width: 2,
                                                    )
                                                    : Border.all(
                                                      color:
                                                          Colors.grey.shade200,
                                                      width: 1,
                                                    ),
                                          ),
                                          padding: const EdgeInsets.all(3),
                                          child: Container(
                                            decoration: BoxDecoration(
                                              shape: BoxShape.circle,
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
                                                            ) => Container(
                                                              color:
                                                                  Colors
                                                                      .grey
                                                                      .shade300,
                                                              child: const Icon(
                                                                Icons.person,
                                                                size: 24,
                                                              ),
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
                                    title: Text(
                                      isCurrentUser
                                          ? 'Your Story'
                                          : friend.username,
                                      style: TextStyle(
                                        fontWeight:
                                            hasStories
                                                ? FontWeight.bold
                                                : FontWeight.normal,
                                      ),
                                    ),
                                    subtitle:
                                        hasStories
                                            ? Text(
                                              '${userStories.length} ${userStories.length == 1 ? "story" : "stories"} • ${_formatTimestamp(userStories.first.createdAt)}',
                                              style: const TextStyle(
                                                color: Colors.blue,
                                              ),
                                            )
                                            : Text(
                                              'No stories yet',
                                              style: TextStyle(
                                                color: Colors.grey.shade500,
                                              ),
                                            ),
                                    trailing:
                                        hasStories
                                            ? Icon(
                                              Icons.circle,
                                              size: 12,
                                              color:
                                                  hasUnviewed
                                                      ? Colors.blue
                                                      : Colors.grey.shade300,
                                            )
                                            : Icon(
                                              Icons.add_circle_outline,
                                              color: Colors.grey.shade400,
                                            ),
                                    onTap:
                                        hasStories
                                            ? () => _openStoryViewer(
                                              friend.uid,
                                              userStories,
                                            )
                                            : null, // No action if no stories
                                    enabled:
                                        hasStories, // Disable tap if no stories
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
