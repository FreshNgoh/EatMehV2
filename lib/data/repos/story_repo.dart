import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:eatmehv2/core/constants/firebase_constants.dart';
import '../models/story/story_model.dart';
import '../models/story/comment_model.dart';

class StoryRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  CollectionReference get _storiesCollection {
    return _firestore.collection(FirebaseConstants.storiesCollection);
  }

  // Create a new story
  Future<void> createStory(StoryModel story) async {
    await _storiesCollection.doc(story.uid).set(story.toMap());
  }

  // Get active stories from friends (including current user)
  Stream<List<StoryModel>> getFriendsStories(List<String> friendIds) {
    final now = Timestamp.now();

    return _storiesCollection
        .where('userId', whereIn: friendIds.isEmpty ? [''] : friendIds)
        .where('expiresAt', isGreaterThan: now)
        .orderBy('expiresAt')
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) {
          return snapshot.docs.map((doc) {
            return StoryModel.fromMap(
              doc.id,
              doc.data() as Map<String, dynamic>,
            );
          }).toList();
        });
  }

  // Get stories for a specific user
  Stream<List<StoryModel>> getUserStories(String userId) {
    final now = Timestamp.now();

    return _storiesCollection
        .where('userId', isEqualTo: userId)
        .where('expiresAt', isGreaterThan: now)
        .orderBy('expiresAt')
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) {
          return snapshot.docs.map((doc) {
            return StoryModel.fromMap(
              doc.id,
              doc.data() as Map<String, dynamic>,
            );
          }).toList();
        });
  }

  // Add view to story
  Future<void> addView(String storyId, String userId) async {
    await _storiesCollection.doc(storyId).update({
      'views': FieldValue.arrayUnion([userId]),
      'viewCount': FieldValue.increment(1),
    });
  }

  // Add comment to story
  Future<void> addComment(String storyId, CommentModel comment) async {
    await _storiesCollection.doc(storyId).update({
      'comments': FieldValue.arrayUnion([comment.toMap()]),
    });
  }

  // Get single story
  Future<StoryModel?> getStory(String storyId) async {
    final doc = await _storiesCollection.doc(storyId).get();
    if (!doc.exists) return null;
    return StoryModel.fromMap(doc.id, doc.data() as Map<String, dynamic>);
  }

  // Delete story (manual or after expiration)
  Future<void> deleteStory(String storyId) async {
    await _storiesCollection.doc(storyId).delete();
  }

  // Delete expired stories (can be called periodically)
  Future<void> deleteExpiredStories() async {
    final now = Timestamp.now();
    final expiredStories =
        await _storiesCollection.where('expiresAt', isLessThan: now).get();

    final batch = _firestore.batch();
    for (var doc in expiredStories.docs) {
      batch.delete(doc.reference);
    }
    await batch.commit();
  }

  // Group stories by user for the story ring UI
  Future<Map<String, List<StoryModel>>> getGroupedFriendsStories(
    List<String> friendIds,
  ) async {
    final now = Timestamp.now();

    final snapshot =
        await _storiesCollection
            .where('userId', whereIn: friendIds.isEmpty ? [''] : friendIds)
            .where('expiresAt', isGreaterThan: now)
            .orderBy('expiresAt')
            .orderBy('createdAt', descending: true)
            .get();

    final Map<String, List<StoryModel>> grouped = {};

    for (var doc in snapshot.docs) {
      final story = StoryModel.fromMap(
        doc.id,
        doc.data() as Map<String, dynamic>,
      );
      if (!grouped.containsKey(story.userId)) {
        grouped[story.userId] = [];
      }
      grouped[story.userId]!.add(story);
    }

    return grouped;
  }
}
