import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user/user_model.dart';
import '../../core/constants/firebase_constants.dart';

class UserRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  CollectionReference<UserModel> get _usersCollection {
    return _firestore
        .collection(FirebaseConstants.usersCollection)
        .withConverter<UserModel>(
          fromFirestore: (snapshot, _) => UserModel.fromMap(snapshot.data()!),
          toFirestore: (user, _) => user.toMap(),
        );
  }

  Future<void> createUser(UserModel user) async {
    await _usersCollection.doc(user.uid).set(user);
  }

  Future<void> updateUser(String uid, Map<String, dynamic> data) async {
    data['updatedAt'] = FieldValue.serverTimestamp();
    await _usersCollection.doc(uid).update(data);
  }

  // Add friend - User adds another user as friend directly
  Future<void> addFriend(String userId, String friendId) async {
    await _usersCollection.doc(userId).update({
      'friends': FieldValue.arrayUnion([friendId]),
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  // Remove friend
  Future<void> removeFriend(String userId, String friendId) async {
    await _usersCollection.doc(userId).update({
      'friends': FieldValue.arrayRemove([friendId]),
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  // Send friend request - User A requests User B
  Future<void> sendFriendRequest(String fromUserId, String toUserId) async {
    await _usersCollection.doc(toUserId).update({
      'friendRequests': FieldValue.arrayUnion([fromUserId]),
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  // Accept friend request - Remove from friendRequests and add to friends
  Future<void> acceptFriendRequest(String userId, String requesterId) async {
    final batch = _firestore.batch();

    // Remove from friend requests
    batch.update(_usersCollection.doc(userId), {
      'friendRequests': FieldValue.arrayRemove([requesterId]),
      'friends': FieldValue.arrayUnion([requesterId]),
      'updatedAt': FieldValue.serverTimestamp(),
    });

    // Add to requester's friends list as well (mutual friendship)
    batch.update(_usersCollection.doc(requesterId), {
      'friends': FieldValue.arrayUnion([userId]),
      'updatedAt': FieldValue.serverTimestamp(),
    });

    await batch.commit();
  }

  // Reject friend request - Just remove from friendRequests
  Future<void> rejectFriendRequest(String userId, String requesterId) async {
    await _usersCollection.doc(userId).update({
      'friendRequests': FieldValue.arrayRemove([requesterId]),
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  // Update goal - can use updateUser, but here's a specific method
  Future<void> updateGoal(String uid, goalData) async {
    await updateUser(uid, {'goalType': goalData});
  }

  // Admin freeze account
  Future<void> freezeAccount(String uid, bool freeze) async {
    await updateUser(uid, {'isFrozen': freeze});
  }

  //  Get all users
  Future<List<UserModel>> getAllUsers() async {
    final snapshot = await _usersCollection.get();
    return snapshot.docs.map((doc) => doc.data()).toList();
  }

  // Get single user
  Future<UserModel?> getUser(String uid) async {
    final doc = await _usersCollection.doc(uid).get();
    return doc.data();
  }

  Stream<UserModel?> getUserStream(String uid) {
    return _usersCollection.doc(uid).snapshots().map((doc) => doc.data());
  }

  // Get users by UIDs (for friends list)
  Future<List<UserModel>> getUsersByUids(List<String> uids) async {
    if (uids.isEmpty) return [];

    final query = await _usersCollection.where('uid', whereIn: uids).get();
    return query.docs.map((doc) => doc.data()).toList();
  }

  // Search users by username
  Future<List<UserModel>> searchUsers(String query) async {
    final snapshot =
        await _usersCollection
            .where('username', isGreaterThanOrEqualTo: query)
            .where('username', isLessThanOrEqualTo: '$query\uf8ff')
            .limit(20)
            .get();

    return snapshot.docs.map((doc) => doc.data()).toList();
  }

  // Get pending friend requests for a user
  Future<List<UserModel>> getFriendRequests(String userId) async {
    final user = await getUser(userId);
    if (user == null || user.friendRequests.isEmpty) return [];

    return getUsersByUids(user.friendRequests);
  }

  // Get current trainer from user
  Future<UserModel?> getCurrentTrainer(String userId) async {
    final user = await getUser(userId);
    if (user == null || user.currentTrainerUid == null) return null;

    return getUser(user.currentTrainerUid!);
  }

  // Submit rating for trainer
  Future<void> submitTrainerRating(String trainerUid, double rating) async {
    final trainer = await getUser(trainerUid);
    if (trainer == null) return;

    final currentProfile = trainer.trainerProfile;
    if (currentProfile == null) return;

    final totalRating = currentProfile.rating;
    final ratingCount = currentProfile.trainees.length;

    final newTotalRating = totalRating + rating;
    final averageRatings = newTotalRating / (ratingCount + 1);

    await updateUser(trainerUid, {'rating': averageRatings});
  }

  // Delete user from trainer's trainee list
  Future<void> changeTrainer(String trainerUid, String traineeUid) async {
    try {
      final trainerDocRef = _usersCollection.doc(trainerUid);
      final traineeDocRef = _usersCollection.doc(traineeUid);

      await trainerDocRef.update({
        'trainerProfile.trainees': FieldValue.arrayRemove([traineeUid]),
      });

      await traineeDocRef.update({'currentTrainerUid': null});
    } catch (e) {
      print('Error removing trainee: $e');
    }
  }
}
