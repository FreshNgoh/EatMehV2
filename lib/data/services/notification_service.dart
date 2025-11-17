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

  Future<bool> checkExistingTrainerRequest(
    String senderUid,
    String receiverUid,
  ) {
    try {
      final querySnapshot = _getNotificationCollection
          .where('senderUid', isEqualTo: senderUid)
          .where('receiverUid', isEqualTo: receiverUid)
          .where('type', isEqualTo: 'trainer_request')
          .where('status', isEqualTo: 'pending');

      return querySnapshot.get().then((snapshot) {
        return snapshot.docs.isNotEmpty;
      });
    } catch (e) {
      print('Error checking existing trainer request: $e');
    }
    return Future.value(false);
  }

  Future<void> markAsRead(String notificationId) async {
    try {
      await _getNotificationCollection.doc(notificationId).update({
        'isRead': true,
      });
    } catch (e) {
      print('Error marking notification as read: $e');
    }
  }

  Future<void> markAllAsRead(String userUid) async {
    try {
      final snapshot =
          await _getNotificationCollection
              .where('receiverUid', isEqualTo: userUid)
              .where('isRead', isEqualTo: false)
              .get();

      final batch = _firestore.batch();
      for (var doc in snapshot.docs) {
        batch.update(doc.reference, {'isRead': true});
      }
      await batch.commit();
    } catch (e) {
      print('Error marking all notifications as read: $e');
    }
  }

  // Delete notification
  Future<void> deleteNotification(String notificationId) async {
    try {
      await _getNotificationCollection.doc(notificationId).delete();
    } catch (e) {
      print('Error deleting notification: $e');
      rethrow;
    }
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
