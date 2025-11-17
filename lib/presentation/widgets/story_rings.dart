import 'package:flutter/material.dart';
import 'package:eatmehv2/data/models/story/story_model.dart';

class StoryRingsWidget extends StatelessWidget {
  final Map<String, List<StoryModel>> groupedStories;
  final String currentUserId;
  final Function(String userId, List<StoryModel> stories) onStoryTap;

  const StoryRingsWidget({
    super.key,
    required this.groupedStories,
    required this.currentUserId,
    required this.onStoryTap,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 100,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 8),
        itemCount: groupedStories.length,
        itemBuilder: (context, index) {
          final userId = groupedStories.keys.elementAt(index);
          final userStories = groupedStories[userId]!;
          final firstStory = userStories.first;

          // Check if current user has viewed all stories
          final hasUnviewed = userStories.any(
            (story) => !story.views.contains(currentUserId),
          );

          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: GestureDetector(
              onTap: () => onStoryTap(userId, userStories),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Stack(
                    children: [
                      // Gradient ring (if unviewed)
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
                            border: Border.all(color: Colors.white, width: 3),
                          ),
                          child: ClipOval(
                            child:
                                firstStory.userImageUrl.isNotEmpty
                                    ? Image.network(
                                      firstStory.userImageUrl,
                                      fit: BoxFit.cover,
                                      errorBuilder:
                                          (_, __, ___) => Container(
                                            color: Colors.grey.shade300,
                                            child: const Icon(Icons.person),
                                          ),
                                    )
                                    : Container(
                                      color: Colors.grey.shade300,
                                      child: const Icon(Icons.person),
                                    ),
                          ),
                        ),
                      ),
                      // Story count indicator
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
                      firstStory.username,
                      textAlign: TextAlign.center,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(fontSize: 12),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
