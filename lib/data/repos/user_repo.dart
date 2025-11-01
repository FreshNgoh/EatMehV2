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

  Future<UserModel?> getUser(String uid) async {
    final doc = await _usersCollection.doc(uid).get();
    return doc.data();
  }

  Stream<UserModel?> getUserStream(String uid) {
    return _usersCollection.doc(uid).snapshots().map((doc) => doc.data());
  }

  Future<void> updateUser(String uid, Map<String, dynamic> data) async {
    data['updatedAt'] = FieldValue.serverTimestamp();
    await _usersCollection.doc(uid).update(data);
  }

  Future<List<UserModel>> getUsersByUids(List<String> uids) async {
    if (uids.isEmpty) return [];

    final query = await _usersCollection.where('uid', whereIn: uids).get();

    return query.docs.map((doc) => doc.data()).toList();
  }

  Future<List<UserModel>> searchUsers(String query) async {
    final snapshot =
        await _usersCollection
            .where('username', isGreaterThanOrEqualTo: query)
            .where('username', isLessThanOrEqualTo: '$query\uf8ff')
            .limit(20)
            .get();

    return snapshot.docs.map((doc) => doc.data()).toList();
  }

  Future<void> addFriend(String userId, String friendId) async {
    await _usersCollection.doc(userId).update({
      'friends': FieldValue.arrayUnion([friendId]),
    });
  }

  Future<void> removeFriend(String userId, String friendId) async {
    await _usersCollection.doc(userId).update({
      'friends': FieldValue.arrayRemove([friendId]),
    });
  }
}
