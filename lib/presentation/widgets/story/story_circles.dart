import 'package:flutter/material.dart';
import '../../../data/dummy_data.dart';
import '../../screens/common/story/story_viewer_screen.dart';

class StoryCircles extends StatelessWidget {
  final List<dynamic> stories;

  const StoryCircles({super.key, required this.stories});

  @override
  Widget build(BuildContext context) {
    final currentUser = DummyData.currentUser;

    return Container(
      height: 120,
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: stories.length + 1, // +1 for "Add Story"
        itemBuilder: (context, index) {
          if (index == 0) {
            return _buildAddStoryCircle(context);
          }

          final story = stories[index - 1];
          final hasViewed = story.views.contains(currentUser.uid);

          return _buildStoryCircle(
            context: context,
            story: story,
            hasViewed: hasViewed,
          );
        },
      ),
    );
  }

  Widget _buildAddStoryCircle(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: 12),
      child: GestureDetector(
        onTap: () {
          // Navigate to camera
          Navigator.pushNamed(context, '/camera');
        },
        child: Column(
          children: [
            Container(
              width: 70,
              height: 70,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [
                    Color(0xFF4285F4),
                    Color(0xFF9C27B0),
                  ],
                ),
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF4285F4).withOpacity(0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: const Icon(
                Icons.add,
                color: Colors.white,
                size: 32,
              ),
            ),
            const SizedBox(height: 6),
            const Text(
              'Your Story',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStoryCircle({
    required BuildContext context,
    required dynamic story,
    required bool hasViewed,
  }) {
    return Padding(
      padding: const EdgeInsets.only(right: 12),
      child: GestureDetector(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => StoryViewerScreen(story: story),
            ),
          );
        },
        child: Column(
          children: [
            Container(
              width: 74,
              height: 74,
              padding: const EdgeInsets.all(3),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: hasViewed
                    ? null
                    : const LinearGradient(
                        colors: [
                          Color(0xFF9C27B0),
                          Color(0xFFE91E63),
                          Color(0xFFFF5722),
                        ],
                      ),
                border: hasViewed
                    ? Border.all(color: Colors.grey.shade300, width: 2)
                    : null,
              ),
              child: Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white, width: 3),
                ),
                child: CircleAvatar(
                  backgroundImage: NetworkImage(story.userImageUrl),
                ),
              ),
            ),
            const SizedBox(height: 6),
            SizedBox(
              width: 70,
              child: Text(
                story.username,
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.center,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
