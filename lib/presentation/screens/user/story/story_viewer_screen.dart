import 'dart:async';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:eatmehv2/data/models/story/story_model.dart';
import 'package:eatmehv2/data/models/story/comment_model.dart';
import 'package:eatmehv2/data/repos/story_repo.dart';

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

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
    _pageController = PageController(initialPage: _currentIndex);
    _progressController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 5),
    );

    _markAsViewed(widget.stories[_currentIndex]);
    _startProgress();
  }

  void _startProgress() {
    _progressController.forward(from: 0).then((_) {
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
      setState(() => _currentIndex++);
      _pageController.animateToPage(
        _currentIndex,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
      _markAsViewed(widget.stories[_currentIndex]);
      _startProgress();
    } else {
      Navigator.pop(context);
    }
  }

  void _previousStory() {
    if (_currentIndex > 0) {
      _progressController.reset();
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

    final comment = CommentModel(
      uid: DateTime.now().millisecondsSinceEpoch.toString(),
      userId: widget.currentUserId,
      username: widget.currentUsername,
      userImageUrl: widget.currentUserImageUrl,
      text: text.trim(),
      createdAt: Timestamp.now(),
    );

    await _storyRepo.addComment(widget.stories[_currentIndex].uid, comment);
    _commentController.clear();

    if (mounted) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Comment added!')));
    }
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
    final currentStory = widget.stories[_currentIndex];

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
                        CircleAvatar(
                          radius: 20,
                          backgroundImage:
                              currentStory.userImageUrl.isNotEmpty
                                  ? NetworkImage(currentStory.userImageUrl)
                                  : null,
                          child:
                              currentStory.userImageUrl.isEmpty
                                  ? Image.asset(
                                    "assets/teralero.png",
                                    width: 40,
                                    height: 40,
                                    fit: BoxFit.cover,
                                  )
                                  : null,
                        ),

                        const SizedBox(width: 12),
                        Expanded(
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
                                _formatTimestamp(currentStory.createdAt),
                                style: TextStyle(
                                  color: Colors.white.withOpacity(0.7),
                                  fontSize: 12,
                                ),
                              ),
                            ],
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

            // Comment button at bottom
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
                      border: Border.all(color: Colors.white.withOpacity(0.5)),
                    ),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.mode_comment,
                          color: Colors.white,
                          size: 20,
                        ),
                        const SizedBox(width: 12),
                        Text(
                          'Send message',
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.8),
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
                            Text(
                              'Comments',
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            IconButton(
                              icon: const Icon(Icons.close),
                              onPressed: _toggleComments,
                            ),
                          ],
                        ),
                      ),

                      const Divider(height: 1),

                      // Comments list
                      Expanded(
                        child:
                            currentStory.comments.isEmpty
                                ? Center(
                                  child: Text(
                                    'No comments yet',
                                    style: TextStyle(
                                      color: Colors.grey.shade500,
                                    ),
                                  ),
                                )
                                : ListView.builder(
                                  padding: const EdgeInsets.all(16),
                                  itemCount: currentStory.comments.length,
                                  itemBuilder: (context, index) {
                                    final comment =
                                        currentStory.comments[index];
                                    return Padding(
                                      padding: const EdgeInsets.only(
                                        bottom: 16,
                                      ),
                                      child: Row(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          CircleAvatar(
                                            radius: 20,
                                            backgroundImage:
                                                currentStory
                                                        .userImageUrl
                                                        .isNotEmpty
                                                    ? NetworkImage(
                                                      currentStory.userImageUrl,
                                                    )
                                                    : null,
                                            child:
                                                currentStory
                                                        .userImageUrl
                                                        .isEmpty
                                                    ? Image.asset(
                                                      "assets/teralero.png",
                                                      width: 40,
                                                      height: 40,
                                                      fit: BoxFit.cover,
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
                        padding: const EdgeInsets.all(16),
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
                              backgroundImage:
                                  widget.currentUserImageUrl.isNotEmpty
                                      ? NetworkImage(widget.currentUserImageUrl)
                                      : null,
                              child:
                                  widget.currentUserImageUrl.isEmpty
                                      ? Image.asset(
                                        "assets/teralero.png",
                                        width: 36,
                                        height: 36,
                                        fit: BoxFit.cover,
                                      )
                                      : null,
                            ),

                            const SizedBox(width: 12),
                            Expanded(
                              child: TextField(
                                controller: _commentController,
                                decoration: InputDecoration(
                                  hintText: 'Add a comment...',
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
