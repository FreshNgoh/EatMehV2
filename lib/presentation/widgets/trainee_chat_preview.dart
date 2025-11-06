import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:eatmehv2/core/constants/firebase_constants.dart';
import 'package:eatmehv2/presentation/screens/trainer/trainer_chat_room.dart';
import 'package:eatmehv2/presentation/widgets/custom_list.dart';
import 'package:flutter/material.dart';

class TraineeChatPreview extends StatelessWidget {
  final String currentUserUid;
  final String traineeUid;
  final String traineeName;
  final String traineeImage;

  const TraineeChatPreview({
    super.key,
    required this.currentUserUid,
    required this.traineeUid,
    required this.traineeName,
    required this.traineeImage,
  });

  String _generateRoomId(String uid1, String uid2) {
    return uid1.hashCode <= uid2.hashCode ? '${uid1}_$uid2' : '${uid2}_$uid1';
  }

  @override
  Widget build(BuildContext context) {
    final roomId = _generateRoomId(currentUserUid, traineeUid);

    return StreamBuilder<DocumentSnapshot>(
      stream:
          FirebaseFirestore.instance
              .collection(FirebaseConstants.chatRoomsCollection)
              .doc(roomId)
              .snapshots(),
      builder: (context, snapshot) {
        String subtitle = 'No messages yet';
        Timestamp? lastUpdated;

        if (snapshot.hasData && snapshot.data!.exists) {
          final data = snapshot.data!.data() as Map<String, dynamic>;
          subtitle = data['lastMessage'] ?? 'No messages yet';
          lastUpdated = data['lastUpdated'] as Timestamp;
        }

        return CustomList(
          profile: const CircleAvatar(
            backgroundImage: AssetImage('assets/images/default_face.jpeg'),
          ),
          value: traineeName,
          lastMessage: subtitle,
          lastUpdated: lastUpdated,
          onFieldTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder:
                    (context) => TrainerChatRoom(
                      receiverUid: traineeUid,
                      receiverName: traineeName,
                      receiverImage: traineeImage,
                    ),
              ),
            );
          },
        );
      },
    );
  }
}
