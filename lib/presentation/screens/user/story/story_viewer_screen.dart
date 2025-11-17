import 'dart:async';
import 'dart:math';
import 'package:eatmehv2/presentation/screens/user/profile_screen.dart';
import 'package:eatmehv2/presentation/widgets/toast.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:eatmehv2/data/models/story/story_model.dart';
import 'package:eatmehv2/data/models/story/comment_model.dart';
import 'package:eatmehv2/data/repos/story_repo.dart';
import 'package:eatmehv2/core/localization/app_localizations.dart';

class StoryViewerScreen extends StatefulWidget {
  final List<StoryModel> stories;
  final int initialIndex;
  final String currentUserId;
  final String currentUsername;
  final String currentUserImageUrl;

  const StoryViewerScreen({
    super.key,
    required this.stories,
    this.initialIndex = 0,
    required this.currentUserId,
    required this.currentUsername,
    required this.currentUserImageUrl,
  });

  @override
  State<StoryViewerScreen> createState() => _StoryViewerScreenState();
}

class _StoryViewerScreenState extends State<StoryViewerScreen>
    with SingleTickerProviderStateMixin {
  late PageController _pageController;
  late AnimationController _progressController;
  int _currentIndex = 0;
  Timer? _timer;
  final StoryRepository _storyRepo = StoryRepository();
  bool _showComments = false;
  final TextEditingController _commentController = TextEditingController();

  // Local state to show comments immediately
  final Map<int, List<CommentModel>> _localComments = {};

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
    _pageController = PageController(initialPage: _currentIndex);
    _progressController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 5),
    );

    // Initialize local comments with existing comments
    for (int i = 0; i < widget.stories.length; i++) {
      _localComments[i] = List.from(widget.stories[i].comments);
    }

    _markAsViewed(widget.stories[_currentIndex]);
    _startProgress();
  }

  void _startProgress() {
    _progressController.forward(from: 0).then((_) {
      if (!mounted) return;
      if (_currentIndex < widget.stories.length - 1) {
        _nextStory();
      } else {
        Navigator.pop(context);
      }
    });
  }

  void _nextStory() {
    if (_currentIndex < widget.stories.length - 1) {
      _progressController.reset();
      if (!mounted) return;
      setState(() => _currentIndex++);
      _pageController.animateToPage(
        _currentIndex,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
      _markAsViewed(widget.stories[_currentIndex]);
      _startProgress();
    } else {
      if (mounted) Navigator.pop(context);
    }
  }

  void _previousStory() {
    if (_currentIndex > 0) {
      _progressController.reset();
      if (!mounted) return;
      setState(() => _currentIndex--);
      _pageController.animateToPage(
        _currentIndex,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
      _startProgress();
    }
  }

  void _pauseProgress() {
    _progressController.stop();
  }

  void _resumeProgress() {
    _progressController.forward();
  }

  Future<void> _markAsViewed(StoryModel story) async {
    if (!story.views.contains(widget.currentUserId)) {
      await _storyRepo.addView(story.uid, widget.currentUserId);
    }
  }

  void _toggleComments() {
    setState(() {
      _showComments = !_showComments;
      if (_showComments) {
        _pauseProgress();
      } else {
        _resumeProgress();
      }
    });
  }

  Future<void> _addComment(String text) async {
    if (text.trim().isEmpty) return;
    final loc = context.loc;

    // Fix: Handle empty string as null for userImageUrl
    final userImageUrl =
        _hasValidImageUrl(widget.currentUserImageUrl)
            ? widget.currentUserImageUrl
            : '';

    final comment = CommentModel(
      uid: DateTime.now().millisecondsSinceEpoch.toString(),
      userId: widget.currentUserId,
      username: widget.currentUsername,
      userImageUrl: userImageUrl,
      text: text.trim(),
      createdAt: Timestamp.now(),
    );

    // Add comment to local state immediately for instant UI update
    setState(() {
      _localComments[_currentIndex]?.add(comment);
    });

    _commentController.clear();

    // Save to Firebase in background
    try {
      await _storyRepo.addComment(widget.stories[_currentIndex].uid, comment);
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _localComments[_currentIndex]?.removeLast();
      });
      final errorMsg = loc.storyViewerErrorComment(e.toString());
      showCustomToast(context, errorMsg, type: ToastType.error);
    }
  }

  // Helper function to safely check if image URL is valid
  bool _hasValidImageUrl(String? url) {
    return url != null && url.isNotEmpty && url != '';
  }

  @override
  void dispose() {
    _progressController.dispose();
    _pageController.dispose();
    _timer?.cancel();
    _commentController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final loc = context.loc;
    final currentStory = widget.stories[_currentIndex];
    final displayComments = _localComments[_currentIndex] ?? [];
    final commentCount = displayComments.length;

    return Scaffold(
      backgroundColor: Colors.black,
      body: GestureDetector(
        onTapUp: (details) {
          final screenWidth = MediaQuery.of(context).size.width;
          if (details.globalPosition.dx < screenWidth / 2) {
            _previousStory();
          } else {
            _nextStory();
          }
        },
        onLongPressStart: (_) => _pauseProgress(),
        onLongPressEnd: (_) => _resumeProgress(),
        child: Stack(
          children: [
            // Story Image
            PageView.builder(
              controller: _pageController,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: widget.stories.length,
              itemBuilder: (context, index) {
                return Center(
                  child: Image.network(
                    widget.stories[index].mediaUrl,
                    fit: BoxFit.contain,
                    loadingBuilder: (context, child, loadingProgress) {
                      if (loadingProgress == null) return child;
                      return const Center(child: CircularProgressIndicator());
                    },
                  ),
                );
              },
            ),

            // Progress bars at top
            SafeArea(
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Row(
                      children: List.generate(
                        widget.stories.length,
                        (index) => Expanded(
                          child: Container(
                            height: 3,
                            margin: const EdgeInsets.symmetric(horizontal: 2),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.3),
                              borderRadius: BorderRadius.circular(2),
                            ),
                            child:
                                index == _currentIndex
                                    ? AnimatedBuilder(
                                        animation: _progressController,
                                        builder: (context, child) {
                                          return FractionallySizedBox(
                                            alignment: Alignment.centerLeft,
                                            widthFactor:
                                                _progressController.value,
                                            child: Container(
                                              decoration: BoxDecoration(
                                                color: Colors.white,
                                                borderRadius:
                                                    BorderRadius.circular(2),
                                              ),
                                            ),
                                          );
                                        },
                                      )
                                    : index < _currentIndex
                                    ? Container(
                                        decoration: BoxDecoration(
                                          color: Colors.white,
                                          borderRadius: BorderRadius.circular(2),
                                        ),
                                      )
                                    : const SizedBox(),
                          ),
                        ),
                      ),
                    ),
                  ),

                  // User info header
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    child: Row(
                      children: [
                        // Wrap avatar in GestureDetector

                        // navigate to profile
                        GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder:
                                    (context) => ProfileScreen(
                                  userUid: currentStory.userId,
                                ),
                              ),
                            );
                          },
                          child: CircleAvatar(
                            radius: 20,
                            backgroundColor: Colors.transparent,
                            backgroundImage:
                                _hasValidImageUrl(currentStory.userImageUrl)
                                    ? NetworkImage(currentStory.userImageUrl)
                                    : null,
                            child:
                                !_hasValidImageUrl(currentStory.userImageUrl)
                                    ? ClipOval(
                                        child: Image.asset(
                                          "assets/teralero.png",
                                          width: 40,
                                          height: 40,
                                          fit: BoxFit.cover,
                                        ),
                                      )
                                    : null,
                          ),
                        ),

                        const SizedBox(width: 12),

                        // Wrap the username + timestamp in GestureDetector too
                        Expanded(
                          child: GestureDetector(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder:
                                      (context) => ProfileScreen(
                                    userUid: currentStory.userId,
                                  ),
                                ),
                              );
                            },
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  currentStory.username,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                Text(
                                  _formatTimestamp(currentStory.createdAt, loc),
                                  style: TextStyle(
                                    color: Colors.white.withOpacity(0.7),
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),

                        IconButton(
                          icon: const Icon(Icons.close, color: Colors.white),
                          onPressed: () => Navigator.pop(context),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // Comment button at bottom with count badge
            if (!_showComments)
              Positioned(
                bottom: 40,
                left: 20,
                right: 20,
                child: GestureDetector(
                  onTap: _toggleComments,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.5),
                      borderRadius: BorderRadius.circular(25),
                      border: Border.all(
                        color:
                            commentCount > 0
                                ? Colors.blue.withOpacity(0.8)
                                : Colors.white.withOpacity(0.5),
                        width: commentCount > 0 ? 2 : 1,
                      ),
                    ),
                    child: Row(
                      children: [
                        Stack(
                          children: [
                            Icon(
                              commentCount > 0
                                  ? Icons.mode_comment
                                  : Icons.mode_comment_outlined,
                              color:
                                  commentCount > 0
                                      ? Colors.blue.shade300
                                      : Colors.white,
                              size: 22,
                            ),
                            // Comment count badge
                            if (commentCount > 0)
                              Positioned(
                                right: -2,
                                top: -2,
                                child: Container(
                                  padding: const EdgeInsets.all(4),
                                  decoration: const BoxDecoration(
                                    color: Colors.blue,
                                    shape: BoxShape.circle,
                                  ),
                                  constraints: const BoxConstraints(
                                    minWidth: 18,
                                    minHeight: 18,
                                  ),
                                  child: Text(
                                    commentCount > 99 ? '99+' : '$commentCount',
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 10,
                                      fontWeight: FontWeight.bold,
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                ),
                              ),
                          ],
                        ),
                        const SizedBox(width: 12),
                        Text(
                          commentCount == 0
                              ? loc.storyViewerButtonSendMessage
                              : commentCount == 1
                                ? loc.storyViewerButtonViewComment
                                : loc.storyViewerButtonViewComments(commentCount),
                          style: TextStyle(
                            color:
                                commentCount > 0
                                    ? Colors.blue.shade300
                                    : Colors.white.withOpacity(0.8),
                            fontWeight:
                                commentCount > 0
                                    ? FontWeight.w600
                                    : FontWeight.normal,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

            // Comments bottom sheet
            if (_showComments)
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child: Container(
                  height: MediaQuery.of(context).size.height * 0.6,
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.vertical(
                      top: Radius.circular(20),
                    ),
                  ),
                  child: Column(
                    children: [
                      // Handle bar
                      Container(
                        margin: const EdgeInsets.symmetric(vertical: 12),
                        width: 40,
                        height: 4,
                        decoration: BoxDecoration(
                          color: Colors.grey.shade300,
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),

                      // Comments header
                      Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 8,
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                Text(
                                  loc.storyViewerSheetTitle,
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                if (commentCount > 0) ...[
                                  const SizedBox(width: 8),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 8,
                                      vertical: 4,
                                    ),
                                    decoration: BoxDecoration(
                                      color: Colors.blue.shade100,
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Text(
                                      '$commentCount',
                                      style: TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.blue.shade700,
                                      ),
                                    ),
                                  ),
                                ],
                              ],
                            ),
                            IconButton(
                              icon: const Icon(Icons.close),
                              onPressed: _toggleComments,
                            ),
                          ],
                        ),
                      ),

                      const Divider(
                        height: 1,
                        thickness: sqrt1_2,
                        color: Colors.black45,
                      ),

                      // Comments list
                      Expanded(
                        child:
                            displayComments.isEmpty
                                ? Center(
                                    child: Column(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        Icon(
                                          Icons.chat_bubble_outline,
                                          size: 48,
                                          color: Colors.grey.shade300,
                                        ),
                                        const SizedBox(height: 12),
                                        Text(
                                          loc.storyViewerEmptyTitle,
                                          style: TextStyle(
                                            color: Colors.grey.shade500,
                                            fontSize: 16,
                                          ),
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          loc.storyViewerEmptySubtitle,
                                          style: TextStyle(
                                            color: Colors.grey.shade400,
                                            fontSize: 14,
                                          ),
                                        ),
                                      ],
                                    ),
                                  )
                                : ListView.builder(
                                    padding: const EdgeInsets.all(16),
                                    itemCount: displayComments.length,
                                    itemBuilder: (context, index) {
                                      final comment = displayComments[index];
                                      return Padding(
                                        padding: const EdgeInsets.only(
                                          bottom: 16,
                                        ),
                                        child: Row(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            CircleAvatar(
                                              radius: 18,
                                              backgroundColor: Colors.transparent,
                                              backgroundImage:
                                                  _hasValidImageUrl(
                                                        comment.userImageUrl,
                                                      )
                                                      ? NetworkImage(
                                                          comment.userImageUrl,
                                                        )
                                                      : null,
                                              child:
                                                  !_hasValidImageUrl(
                                                        comment.userImageUrl,
                                                      )
                                                      ? CircleAvatar(
                                                          radius: 20,
                                                          backgroundColor:
                                                              Colors.grey.shade300,
                                                          child: Text(
                                                            currentStory.username[0]
                                                                .toUpperCase(),
                                                            style: const TextStyle(
                                                              fontWeight:
                                                                  FontWeight.bold,
                                                            ),
                                                          ),
                                                        )
                                                      : null,
                                            ),
                                            const SizedBox(width: 12),
                                            Expanded(
                                              child: Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  Row(
                                                    children: [
                                                      Text(
                                                        comment.username,
                                                        style: const TextStyle(
                                                          fontWeight:
                                                              FontWeight.bold,
                                                        ),
                                                      ),
                                                      const SizedBox(width: 8),
                                                      Text(
                                                        _formatTimestamp(
                                                          comment.createdAt,
                                                          loc
                                                        ),
                                                        style: TextStyle(
                                                          color:
                                                              Colors
                                                                  .grey
                                                                  .shade500,
                                                          fontSize: 12,
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                  const SizedBox(height: 4),
                                                  Text(comment.text),
                                                ],
                                              ),
                                            ),
                                          ],
                                        ),
                                      );
                                    },
                                  ),
                      ),

                      // Comment input
                      Container(
                        padding: const EdgeInsets.fromLTRB(16, 16, 16, 30),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          border: Border(
                            top: BorderSide(color: Colors.grey.shade300),
                          ),
                        ),
                        child: Row(
                          children: [
                            CircleAvatar(
                              radius: 18,
                              backgroundColor: Colors.transparent,
                              backgroundImage:
                                  _hasValidImageUrl(widget.currentUserImageUrl)
                                      ? NetworkImage(widget.currentUserImageUrl)
                                      : null,
                              child:
                                  !_hasValidImageUrl(widget.currentUserImageUrl)
                                      ? CircleAvatar(
                                          radius: 20,
                                          backgroundColor: Colors.grey.shade300,
                                          child: Text(
                                            currentStory.username[0]
                                                .toUpperCase(),
                                            style: const TextStyle(
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        )
                                      : null,
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: TextField(
                                controller: _commentController,
                                decoration: InputDecoration(
                                  hintText: loc.storyViewerInputHint,
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(25),
                                    borderSide: BorderSide.none,
                                  ),
                                  filled: true,
                                  fillColor: Colors.grey.shade100,
                                  contentPadding: const EdgeInsets.symmetric(
                                    horizontal: 16,
                                    vertical: 8,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            IconButton(
                              icon: const Icon(Icons.send, color: Colors.blue),
                              onPressed:
                                  () => _addComment(_commentController.text),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  String _formatTimestamp(Timestamp timestamp, AppLocalizations loc) {
    final now = DateTime.now();
    final date = timestamp.toDate();
    final difference = now.difference(date);

    if (difference.inMinutes < 1) {
      return loc.storiesTimestampJustNow;
    } else if (difference.inHours < 1) {
      return loc.storiesTimestampMinutesAgo(difference.inMinutes);
    } else if (difference.inHours < 24) {
      return loc.storiesTimestampHoursAgo(difference.inHours);
    } else {
      return loc.storiesTimestampDaysAgo(difference.inDays);
    }
  }
}