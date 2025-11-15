import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:eatmehv2/core/constants/firebase_constants.dart';
import 'package:eatmehv2/data/models/trainer/trainer_profile_model.dart';
import 'package:eatmehv2/data/models/user/goal_model.dart';

class TrainerProfileService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  CollectionReference<TrainerProfile> get _trainerProfilesCollection {
    return _firestore
        .collection(FirebaseConstants.usersCollection)
        .withConverter<TrainerProfile>(
          fromFirestore:
              (snapshot, _) => TrainerProfile.fromMap(snapshot.data()!),
          toFirestore: (application, _) => application.toMap(),
        );
  }

  // generate unique room id to get lastest message and timestamp
  String _generateRoomId(String uid1, String uid2) {
    return uid1.hashCode <= uid2.hashCode ? '${uid1}_$uid2' : '${uid2}_$uid1';
  }

  // Create a new trainer profile document
  Future<void> createTrainerProfile(
    String trainerUid,
    TrainerProfile profile,
  ) async {
    try {
      await _firestore
          .collection(FirebaseConstants.usersCollection)
          .doc(trainerUid)
          .update({'trainerProfile': profile.toMap(), 'role': 'trainer'});
    } catch (e) {
      print('Error creating embedded trainer profile: $e');
    }
  }

  // Get a trainer profile by user UID
  Future<TrainerProfile?> getTrainerProfile(String userUid) async {
    try {
      final doc =
          await _firestore
              .collection(FirebaseConstants.usersCollection)
              .doc(userUid)
              .get();
      if (doc.exists) {
        final data = doc.data();
        if (data != null && data['trainerProfile'] != null) {
          return TrainerProfile.fromMap(
            data['trainerProfile'] as Map<String, dynamic>,
          );
        }
      }
    } catch (e) {
      print('Error fetching trainer profile: $e');
    }
    return null;
  }

  // Stream trainees' details with latest chat updates
  Stream<List<Map<String, dynamic>>> getTraineesDetailsStream(
    List<String> traineeUids,
    String trainerUid,
  ) {
    final trainees = <Map<String, dynamic>>[];
    final controller = StreamController<List<Map<String, dynamic>>>();

    // For each trainee, listen to their chat room
    for (final uid in traineeUids) {
      final roomId = _generateRoomId(trainerUid, uid);
      final chatRoomRef = _firestore
          .collection(FirebaseConstants.chatRoomsCollection)
          .doc(roomId);

      // Listen to chat updates for this specific trainee
      chatRoomRef.snapshots().listen((chatDoc) async {
        final userDoc =
            await _firestore
                .collection(FirebaseConstants.usersCollection)
                .doc(uid)
                .get();

        if (!userDoc.exists) return;

        final userData = userDoc.data()!;
        final trainee = {
          'uid': uid,
          'name': userData['username'] ?? 'Unknown',
          'image': userData['imageUrl'] ?? '',
          'lastMessage': chatDoc.data()?['lastMessage'] ?? '',
          'lastUpdated': chatDoc.data()?['lastUpdated'] ?? Timestamp.now(),
        };

        // Update or insert trainee
        final index = trainees.indexWhere((t) => t['uid'] == uid);
        if (index >= 0) {
          trainees[index] = trainee;
        } else {
          trainees.add(trainee);
        }

        // Sort trainees by lastUpdated
        trainees.sort((a, b) {
          final aTime = a['lastUpdated'] as Timestamp;
          final bTime = b['lastUpdated'] as Timestamp;
          return bTime.compareTo(aTime);
        });

        controller.add(List<Map<String, dynamic>>.from(trainees));
      });
    }

    return controller.stream;
  }

  // Get all trainers
  Future<List<Map<String, dynamic>>> getAllTrainers() async {
    try {
      final snapshot =
          await _firestore
              .collection(FirebaseConstants.usersCollection)
              .where('role', isEqualTo: 'trainer')
              .get();

      return snapshot.docs.map((doc) {
        final data = doc.data();
        return {
          'uid': doc.id,
          'name': data['username'] ?? 'Unknown',
          'image': data['imageUrl'] ?? '',
          'trainerProfile': data['trainerProfile'],
        };
      }).toList();
    } catch (e) {
      print('Error fetching trainers: $e');
      return [];
    }
  }

  // Add or update trainer profile
  Future<void> updateTrainerProfile(
    String trainerUid,
    TrainerProfile profile,
  ) async {
    try {
      await _trainerProfilesCollection.doc(trainerUid).set(profile);
    } catch (e) {
      print('Error saving trainer profile: $e');
    }
  }

  // Accept trainee request and add to trainer's trainee list
  Future<void> acceptTraineeRequest(
    String trainerUid,
    String traineeUid,
  ) async {
    try {
      final trainerDocRef = _firestore
          .collection(FirebaseConstants.usersCollection)
          .doc(trainerUid);

      final traineeDocRef = _firestore
          .collection(FirebaseConstants.usersCollection)
          .doc(traineeUid);

      await trainerDocRef.update({
        'trainerProfile.trainees': FieldValue.arrayUnion([traineeUid]),
      });

      await traineeDocRef.update({'currentTrainerUid': trainerUid});
    } catch (e) {
      print('Error accepting trainee request: $e');
    }
  }

  // Reject trainee request
  Future<void> rejectTraineeRequest(
    String trainerUid,
    String traineeUid,
  ) async {
    // as it is handled by updating the notification status.
    print('Trainee request from $traineeUid rejected by trainer $trainerUid');
  }

  // Save goals for user
  Future<void> saveUserGoals(String userUid, Goal goals) async {
    try {
      final goalsData = goals.toMap();
      await _firestore
          .collection(FirebaseConstants.usersCollection)
          .doc(userUid)
          .update({'goal': goalsData});
    } catch (e) {
      print('Error saving goals for user: $e');
    }
  }
}
