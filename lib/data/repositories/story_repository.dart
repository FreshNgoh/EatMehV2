import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/story/story_model.dart';
import '../../core/constants/firebase_constants.dart';

class StoryRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  CollectionReference get _storiesCollection {
    return _firestore.collection(FirebaseConstants.storiesCollection);
  }

  Future<String> createStory(StoryModel story) async {
    final doc = await _storiesCollection.add(story.toMap());
    return doc.id;
  }

  Stream<List<StoryModel>> getActiveStories(List<String> friendIds) {
    final now = Timestamp.now();

    return _storiesCollection
        .where('userId', whereIn: friendIds.isNotEmpty ? friendIds : [''])
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

  Future<void> markStoryAsViewed(String storyId, String userId) async {
    await _storiesCollection.doc(storyId).update({
      'views': FieldValue.arrayUnion([userId]),
      'viewCount': FieldValue.increment(1),
    });
  }

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
}
