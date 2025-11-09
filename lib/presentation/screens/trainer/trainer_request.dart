import 'package:eatmehv2/data/models/notification/notification_model.dart';
import 'package:eatmehv2/data/repos/notification_repo.dart';
import 'package:eatmehv2/data/services/notification_service.dart';
import 'package:eatmehv2/presentation/widgets/custom_list.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class TrainerRequestsScreen extends StatelessWidget {
  final notificationRepo = NotificationRepo(NotificationService());
  final String trainerUid = FirebaseAuth.instance.currentUser!.uid;

  TrainerRequestsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Trainer Requests')),
      body: StreamBuilder<List<NotificationModel>>(
        stream: notificationRepo.getNotifications(trainerUid),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text("Error: ${snapshot.error}"));
          }

          final requests = snapshot.data ?? [];
          if (requests.isEmpty) {
            return const Center(child: Text("No requests yet"));
          }

          return ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 30),
            itemCount: requests.length,
            itemBuilder: (context, index) {
              final req = requests[index];
              return CustomList(
                profile: CircleAvatar(
                  backgroundImage: AssetImage(
                    'assets/images/default_face.jpeg',
                  ),
                ),
                value: req.senderName ?? 'Unknown User',
                actionIcons: [
                  ListActionIcon(
                    icon: Icons.check,
                    onPressed: () async {
                      await notificationRepo.updateNotificationStatus(
                        req.uid!,
                        'accepted',
                      );
                    },
                    tooltip: 'Accept',
                  ),
                  ListActionIcon(
                    icon: Icons.close,
                    onPressed: () async {
                      await notificationRepo.updateNotificationStatus(
                        req.uid!,
                        'rejected',
                      );
                    },
                    tooltip: 'Reject',
                  ),
                ],
                onFieldTap: () {
                  // Handle tap on the request item
                },
              );
            },
          );
        },
      ),
    );
  }
}
