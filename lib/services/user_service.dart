import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:eatmehv2/models/friend_requests_model.dart';
import 'package:eatmehv2/models/user_model.dart';
import 'package:firebase_auth/firebase_auth.dart';

const String USER_COLLECTION_REF = "users";

class UserService {
  final _fireStore = FirebaseFirestore.instance;

  late final CollectionReference<UserModel>
  _usersRef; // Specify the generic type here

  UserService() {
    _usersRef = _fireStore
        .collection(USER_COLLECTION_REF)
        .withConverter<UserModel>(
          // Get snapshot from firebase, returning them as user instance
          fromFirestore: (snapshots, _) => UserModel.fromMap(snapshots.data()!),
          toFirestore: (user, _) => user.toMap(),
        );
  }

  Stream<QuerySnapshot> getUsers() {
    return _usersRef.snapshots();
  }

  Future<void> addUser(UserModel user) async {
    try {
      await _usersRef.doc(user.uid).set(user); // Use .doc(user.uid).set()
    } catch (e) {
      log("🔥 Error writing user to Firestore: $e");
    }
  }

  //Friend Requests
  final String? _currentUserId = FirebaseAuth.instance.currentUser?.uid;
  final CollectionReference<FriendRequestModel> _friendRequestsCollection =
      FirebaseFirestore.instance
          .collection('friend_requests')
          .withConverter<FriendRequestModel>(
            fromFirestore:
                (snapshot, _) => FriendRequestModel.fromMap(snapshot.data()!),
            toFirestore: (request, _) => request.toMap(),
          );

  Future<bool> sendFriendRequest(String receiverUid) async {
    if (_currentUserId == null || _currentUserId == receiverUid) {
      return false; // Indicate failure
    }

    // Check if the receiver user exists based on the 'uid' field
    final receiverUsersQuery =
        await _usersRef
            .where('uid', isEqualTo: receiverUid)
            .limit(1) // We only need to find one user
            .get();

    if (receiverUsersQuery.docs.isEmpty) {
      log('User with UID $receiverUid does not exist.');
      return false; // Indicate failure
    }

    // Check if a request already exists
    final existingRequest =
        await _friendRequestsCollection
            .where('senderUid', isEqualTo: _currentUserId)
            .where('receiverUid', isEqualTo: receiverUid)
            .where('status', isNotEqualTo: 'rejected')
            .get();

    final existingInverseRequest =
        await _friendRequestsCollection
            .where('senderUid', isEqualTo: receiverUid)
            .where('receiverUid', isEqualTo: _currentUserId)
            .where('status', isNotEqualTo: 'rejected')
            .get();

    if (existingRequest.docs.isNotEmpty ||
        existingInverseRequest.docs.isNotEmpty) {
      log('Friend request already pending or exists.');
      return false; // Indicate failure
    }

    try {
      final newRequest = FriendRequestModel(
        senderUid: _currentUserId!,
        receiverUid: receiverUid,
        status: 'pending',
        createdAt: Timestamp.now(),
      );
      await _friendRequestsCollection.add(newRequest);
      log('Friend request sent successfully!');
      return true; // Indicate success
    } catch (e) {
      log('Error sending friend request: $e');
      return false; // Indicate failure
    }
  }

  Stream<QuerySnapshot<FriendRequestModel>>
  getPendingFriendRequestsAsQuerySnapshot() {
    if (_currentUserId == null) {
      return Stream.empty(); // Return an empty stream when no user is logged in
    }
    return _friendRequestsCollection
        .where('receiverUid', isEqualTo: _currentUserId)
        .where('status', isEqualTo: 'pending')
        .orderBy('createdAt', descending: true)
        .snapshots();
  }

  Stream<List<FriendRequestModel>> getPendingFriendRequests() {
    if (_currentUserId == null) {
      return Stream.value([]);
    }
    return _friendRequestsCollection
        .where('receiverUid', isEqualTo: _currentUserId)
        .where('status', isEqualTo: 'pending')
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs.map((doc) => doc.data()).toList());
  }

  Future<void> acceptFriendRequest(
    String requestId,
    String senderUidToCheck,
  ) async {
    if (_currentUserId == null) {
      return;
    }

    final requestDocRef = _friendRequestsCollection.doc(requestId);

    try {
      await _fireStore.runTransaction((transaction) async {
        final requestSnapshot = await transaction.get(requestDocRef);

        if (!requestSnapshot.exists ||
            requestSnapshot.data()?.status != 'pending') {
          throw Exception("Friend request not found or already processed.");
        }

        // Fetch current user document by uid
        final currentUserDocRef = _usersRef.doc(_currentUserId);
        final currentUserSnapshot = await transaction.get(currentUserDocRef);

        // Fetch sender user document by uid
        final senderUserDocRef = _usersRef.doc(senderUidToCheck);
        final senderUserSnapshot = await transaction.get(senderUserDocRef);

        // Update friend request status
        transaction.update(requestDocRef, {'status': 'accepted'});

        // Update current user's friends list
        List<String> currentUserFriends =
            currentUserSnapshot.data()?.friends ?? [];
        if (!currentUserFriends.contains(senderUidToCheck)) {
          transaction.update(currentUserDocRef, {
            'friends': [...currentUserFriends, senderUidToCheck],
          });
        }

        // Update sender's friends list
        List<String> senderFriends = senderUserSnapshot.data()?.friends ?? [];
        if (!senderFriends.contains(_currentUserId)) {
          transaction.update(senderUserDocRef, {
            'friends': [...senderFriends, _currentUserId],
          });
        }
      });
      log('Friend request accepted!');
    } catch (e) {
      log('Error accepting friend request: $e');
    }
  }

  Future<void> rejectFriendRequest(String requestId) async {
    final requestDocRef = _friendRequestsCollection.doc(requestId);
    try {
      await requestDocRef.update({'status': 'rejected'});
      log('Friend request rejected!');
    } catch (e) {
      log('Error rejecting friend request: $e');
    }
  }

  // Helper function to get user data (you might already have this)
  // Helper function to get user data
  Future<DocumentSnapshot<UserModel>?> getUserData(String userUid) async {
    try {
      final userDocument = await _usersRef.doc(userUid).get();
      return userDocument;
    } catch (e) {
      log("🔥 Error getting user data: $e");
      return null;
    }
  }

  Future<List<DocumentSnapshot<UserModel>>> getUsersByUids(
    List<String> uids,
  ) async {
    if (uids.isEmpty) {
      return [];
    }
    final querySnapshot =
        await _fireStore
            .collection(USER_COLLECTION_REF)
            .withConverter<UserModel>(
              fromFirestore:
                  (snapshots, _) => UserModel.fromMap(snapshots.data()!),
              toFirestore: (user, _) => user.toMap(),
            )
            .where('uid', whereIn: uids)
            .get();
    return querySnapshot.docs;
  }

  // Helper function to get user data as a Stream
  Stream<DocumentSnapshot<UserModel>> getUserDataStream(String userUid) {
    return _usersRef.doc(userUid).snapshots();
  }

  // *** New method to get a single user by UID ***
  Future<UserModel?> getUser(String uid) async {
    try {
      final DocumentSnapshot<UserModel> userDoc =
          await _usersRef.doc(uid).get();
      return userDoc.data();
    } catch (e) {
      log("🔥 Error fetching user: $e");
      return null;
    }
  }

  // *** New method to update user data ***
  Future<void> updateUser(String uid, Map<String, dynamic> data) async {
    try {
      await _usersRef.doc(uid).update(data);
    } catch (e) {
      log("🔥 Error updating user: $e");
      rethrow; // Re-throw the error to be caught in the UI
    }
  }
}
