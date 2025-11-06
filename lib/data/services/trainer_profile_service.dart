import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:eatmehv2/core/constants/firebase_constants.dart';
import 'package:eatmehv2/data/models/trainer/trainer_profile_model.dart';

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

  // Get trainees' details
  Future<List<Map<String, dynamic>>> getTraineesDetails(
    List<String> traineeUids,
    String trainerUid,
  ) async {
    final List<Map<String, dynamic>> trainees = [];

    try {
      for (final uid in traineeUids) {
        final doc =
            await _firestore
                .collection(FirebaseConstants.usersCollection)
                .doc(uid)
                .get();
        if (doc.exists) {
          final data = doc.data()!;
          final trainee = {
            'uid': uid,
            'name': data['username'] ?? 'Unknown',
            'image': data['imageUrl'] ?? 'https://via.placeholder.com/150',
          };

          // Generate chat room ID between trainer and this trainee
          final roomId = _generateRoomId(trainerUid, uid);

          // Fetch chat room metadata (if exists)
          final chatDoc =
              await _firestore
                  .collection(FirebaseConstants.chatRoomsCollection)
                  .doc(roomId)
                  .get();

          if (chatDoc.exists) {
            final chatData = chatDoc.data() as Map<String, dynamic>;
            trainee['lastMessage'] = chatData['lastMessage'] ?? '';
            trainee['lastUpdated'] = chatData['lastUpdated'] ?? Timestamp.now();
          } else {
            trainee['lastMessage'] = '';
            trainee['lastUpdated'] = Timestamp.now();
          }
          trainees.add(trainee);
        }
      }
    } catch (e) {
      print('Error fetching trainees: $e');
    }

    return trainees;
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
          'image': data['imageUrl'] ?? 'https://via.placeholder.com/150',
          'trainerProfile': data['trainerProfile'], // optional
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
}
