import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:eatmehv2/core/constants/firebase_constants.dart';
import 'package:eatmehv2/core/utils/date_formatter.dart';
import 'package:eatmehv2/presentation/screens/trainer/trainer_chat_room.dart';
import 'package:eatmehv2/presentation/screens/trainer/trainer_goal_detail.dart';
import 'package:eatmehv2/presentation/screens/trainer/trainer_set_goal.dart';
import 'package:eatmehv2/presentation/screens/user/profile_screen.dart';
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
        String subtitle = 'Added by';
        Timestamp? lastUpdated;
        String? lastSenderUid;
        String timeAgo = '';
        bool hasUnreadMessages = false;

        if (snapshot.hasData && snapshot.data!.exists) {
          final data = snapshot.data!.data() as Map<String, dynamic>;
          subtitle = data['lastMessage'] ?? 'Added by';
          lastUpdated = data['lastUpdated'] as Timestamp?;
          lastSenderUid = data['lastSenderUid'] ?? '';

          // Check if there are unread messages from the trainee
          final unreadCount = data['unreadCount_$currentUserUid'] ?? 0;
          final isLastMessageFromOther = lastSenderUid != currentUserUid;
          hasUnreadMessages = isLastMessageFromOther && unreadCount > 0;
        }

        final formattedMessage =
            subtitle.length > 30 ? '${subtitle.substring(0, 10)}...' : subtitle;

        final displayMessage =
            (lastSenderUid == currentUserUid && subtitle != 'Added by')
                ? "You: $formattedMessage"
                : subtitle;

        if (lastUpdated != null) {
          timeAgo = DateFormatter.getTimeAgo(lastUpdated.toDate());
        } else {
          timeAgo = 'Just now';
        }

        return StreamBuilder<DocumentSnapshot>(
          stream:
              FirebaseFirestore.instance
                  .collection(FirebaseConstants.usersCollection)
                  .doc(traineeUid)
                  .snapshots(),
          builder: (context, goalSnapshot) {
            bool hasSetGoals = false;

            if (goalSnapshot.hasData && goalSnapshot.data!.exists) {
              final data = goalSnapshot.data!.data() as Map<String, dynamic>;
              if (data['goal'] != null) {
                hasSetGoals = true;
              } else {
                hasSetGoals = false;
              }
            }

            return CustomList(
              profile: CircleAvatar(
                radius: 25,
                backgroundColor: Colors.grey.shade200,
                backgroundImage:
                    traineeImage.isNotEmpty ? NetworkImage(traineeImage) : null,
                child:
                    traineeImage.isEmpty
                        ? Text(
                          traineeName[0].toUpperCase(),
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        )
                        : null,
              ),
              onProfileTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ProfileScreen(userUid: traineeUid),
                  ),
                );
              },
              value: traineeName,
              lastMessage:
                  "$displayMessage${timeAgo.isNotEmpty ? " • $timeAgo" : ""}",
              lastMessageStyle: TextStyle(
                fontWeight:
                    hasUnreadMessages ? FontWeight.bold : FontWeight.normal,
                color:
                    hasUnreadMessages
                        ? const Color(0xFF191919)
                        : Colors.grey.shade600,
              ),
              actionIcons:
                  hasSetGoals
                      ? [
                        ListActionIcon(
                          icon: Icons.note_alt_rounded,
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) {
                                  return TrainerGoalDetail(
                                    traineeUid: traineeUid,
                                  );
                                },
                              ),
                            );
                          },
                        ),
                      ]
                      : [
                        ListActionIcon(
                          icon: Icons.build_circle,
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) {
                                  return TrainerSetGoal(traineeUid: traineeUid);
                                },
                              ),
                            );
                          },
                        ),
                      ],
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
      },
    );
  }
}
