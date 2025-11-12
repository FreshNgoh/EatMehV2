import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:eatmehv2/core/constants/firebase_constants.dart';
import 'package:eatmehv2/data/models/notification/notification_model.dart';

class NotificationService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  CollectionReference<NotificationModel> get _getNotificationCollection {
    return _firestore
        .collection(FirebaseConstants.notificationsCollection)
        .withConverter<NotificationModel>(
          fromFirestore:
              (snapshot, _) =>
                  NotificationModel.fromMap(snapshot.id, snapshot.data()!),
          toFirestore: (application, _) => application.toMap(),
        );
  }

  Future<void> sendNotification(NotificationModel notif) async {
    await _getNotificationCollection.add(notif);
  }

  Stream<List<NotificationModel>> getNotifications(String userUid) {
    return _getNotificationCollection
        .where('receiverUid', isEqualTo: userUid)
        .where('type', isEqualTo: 'trainer_request')
        .where('status', isEqualTo: 'pending')
        .orderBy('createdAt', descending: true)
        .snapshots()
        .asyncMap((snapshot) async {
          List<NotificationModel> notifications = [];
          for (var doc in snapshot.docs) {
            final data = doc.data().toMap();
            final senderUid = data['senderUid'];

            final userDoc =
                await _firestore.collection('users').doc(senderUid).get();
            final senderName = userDoc.data()?['username'] ?? 'Unknown User';

            data['senderName'] = senderName;

            notifications.add(NotificationModel.fromMap(doc.id, data));
          }
          return notifications;
        });
  }

  Future<void> updateTrainerRequestStatus(
    String requestId,
    String status,
  ) async {
    try {
      await _getNotificationCollection.doc(requestId).update({
        'status': status,
      });
    } catch (e) {
      throw Exception('Error updating trainer request status: $e');
    }
  }
}
