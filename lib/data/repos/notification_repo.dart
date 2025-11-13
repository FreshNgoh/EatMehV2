import 'package:eatmehv2/data/models/notification/notification_model.dart';
import 'package:eatmehv2/data/services/notification_service.dart';

class NotificationRepo {
  final NotificationService _notificationService;
  NotificationRepo(this._notificationService);

  Future<void> sendNotification(notification) async {
    await _notificationService.sendNotification(notification);
  }

  Stream<List<NotificationModel>> getNotifications(String userUid) {
    return _notificationService.getNotifications(userUid);
  }

  Future<void> markAsRead(String notificationId) async {
    await _notificationService.markAsRead(notificationId);
  }

  Future<void> markAllAsRead(String userUid) async {
    await _notificationService.markAllAsRead(userUid);
  }

  Future<void> deleteNotification(String notificationId) async {
    await _notificationService.deleteNotification(notificationId);
  }

  Future<void> updateNotificationStatus(String requestId, String status) async {
    await _notificationService.updateTrainerRequestStatus(requestId, status);
  }
}
