import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:eatmehv2/data/models/notification/notification_model.dart';
import 'package:eatmehv2/data/repos/notification_repo.dart';
import 'package:eatmehv2/data/repos/trainer_profile_repo.dart';
import 'package:eatmehv2/data/services/notification_service.dart';
import 'package:eatmehv2/data/services/trainer_profile_service.dart';
import 'package:eatmehv2/presentation/widgets/custom_list.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class TrainerRequestsScreen extends StatefulWidget {
  final String? filterByUid;

  const TrainerRequestsScreen({super.key, this.filterByUid});

  @override
  State<TrainerRequestsScreen> createState() => _TrainerRequestsScreenState();
}

class _TrainerRequestsScreenState extends State<TrainerRequestsScreen> {
  final notificationRepo = NotificationRepo(NotificationService());
  final trainerProfileRepo = TrainerProfileRepo(TrainerProfileService());
  final String trainerUid = FirebaseAuth.instance.currentUser!.uid;

  bool _isProcessing = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.filterByUid != null ? 'Trainer Request' : 'Trainer Requests',
        ),
      ),
      body: StreamBuilder<List<NotificationModel>>(
        stream: notificationRepo.getNotifications(trainerUid),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.error_outline,
                    size: 64,
                    color: Colors.red.shade300,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    "Error loading requests",
                    style: TextStyle(fontSize: 16, color: Colors.grey.shade600),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    "${snapshot.error}",
                    style: TextStyle(fontSize: 12, color: Colors.grey.shade400),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            );
          }

          // Filter only trainer request notifications
          var requests =
              (snapshot.data ?? [])
                  .where((notif) => notif.type == 'trainer_request')
                  .toList();

          // Apply filterByUid if provided
          if (widget.filterByUid != null) {
            requests =
                requests
                    .where((req) => req.senderUid == widget.filterByUid)
                    .toList();

            if (requests.isEmpty) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.info_outline,
                      size: 64,
                      color: Colors.grey.shade300,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      "This request is no longer available",
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.grey.shade600,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      "It may have been already processed",
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey.shade400,
                      ),
                    ),
                    const SizedBox(height: 24),
                    ElevatedButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('Go Back'),
                    ),
                  ],
                ),
              );
            }
          }

          if (requests.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.fitness_center,
                    size: 80,
                    color: Colors.grey.shade300,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    "No trainer requests yet",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w500,
                      color: Colors.grey.shade600,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    "New requests will appear here",
                    style: TextStyle(fontSize: 14, color: Colors.grey.shade400),
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 30),
            itemCount: requests.length,
            itemBuilder: (context, index) {
              final req = requests[index];

              // Skip if already processed (accepted or rejected)
              if (req.status != null &&
                  (req.status == 'accepted' || req.status == 'rejected')) {
                return const SizedBox.shrink();
              }

              final traineeName = req.senderName ?? 'Unknown User';
              final traineeImage = req.senderImage ?? '';

              return Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: CustomList(
                  profile: CircleAvatar(
                    radius: 25,
                    backgroundColor: Colors.grey.shade200,
                    backgroundImage:
                        traineeImage.isNotEmpty
                            ? NetworkImage(traineeImage)
                            : null,
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
                  value: req.senderName ?? 'Unknown User',
                  actionIcons:
                      _isProcessing
                          ? []
                          : [
                            ListActionIcon(
                              icon: Icons.check,
                              onPressed: () => _handleAccept(req),
                              tooltip: 'Accept',
                            ),
                            ListActionIcon(
                              icon: Icons.close,
                              onPressed: () => _handleReject(req),
                              tooltip: 'Reject',
                            ),
                          ],
                  onFieldTap: () {
                    _showRequestDetails(req);
                  },
                ),
              );
            },
          );
        },
      ),
    );
  }

  Future<void> _handleAccept(NotificationModel req) async {
    if (_isProcessing) return;

    final confirm = await _showConfirmDialog(
      title: 'Accept Request',
      message: 'Accept ${req.senderName ?? 'this user'} as your trainee?',
      confirmText: 'Accept',
      confirmColor: Colors.green,
    );

    final acceptNotification = NotificationModel(
      senderUid: trainerUid,
      receiverUid: req.senderUid,
      title: "Trainer Request Accepted",
      message: 'Your request to be a trainee has been accepted by the trainer.',
      type: 'trainer_request',
      status: 'unread',
      createdAt: Timestamp.now(),
    );

    if (confirm != true) return;
    setState(() => _isProcessing = true);

    try {
      // Update notification status
      await notificationRepo.updateNotificationStatus(req.uid!, 'accepted');

      // Accept trainee request
      await trainerProfileRepo.acceptTraineeRequest(trainerUid, req.senderUid);

      // Send accept notification to user
      await notificationRepo.sendNotification(acceptNotification);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('✓ Accepted ${req.senderName ?? 'trainee'}'),
            backgroundColor: Colors.green,
            behavior: SnackBarBehavior.floating,
          ),
        );

        // If filtered by specific user, go back after processing
        if (widget.filterByUid != null) {
          Navigator.pop(context);
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error accepting request: $e'),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isProcessing = false);
      }
    }
  }

  Future<void> _handleReject(NotificationModel req) async {
    if (_isProcessing) return;

    final confirm = await _showConfirmDialog(
      title: 'Reject Request',
      message: 'Reject ${req.senderName ?? 'this user'}\'s trainer request?',
      confirmText: 'Reject',
      confirmColor: Colors.red,
    );

    final declineNotification = NotificationModel(
      senderUid: trainerUid,
      receiverUid: req.senderUid,
      title: "Trainer Request Declined",
      message: 'Your request to be a trainee has been rejected by the trainer.',
      type: 'trainer_request',
      status: 'unread',
      createdAt: Timestamp.now(),
    );

    if (confirm != true) return;

    setState(() => _isProcessing = true);

    try {
      // Update notification status
      await notificationRepo.updateNotificationStatus(req.uid!, 'rejected');

      // Decline trainee request
      await trainerProfileRepo.declineTraineeRequest(trainerUid, req.senderUid);

      // Send decline notification to user
      await notificationRepo.sendNotification(declineNotification);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Rejected ${req.senderName ?? 'trainee'}'),
            backgroundColor: Colors.orange,
            behavior: SnackBarBehavior.floating,
          ),
        );

        // If filtered by specific user, go back after processing
        if (widget.filterByUid != null) {
          Navigator.pop(context);
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error rejecting request: $e'),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isProcessing = false);
      }
    }
  }

  Future<bool?> _showConfirmDialog({
    required String title,
    required String message,
    required String confirmText,
    required Color confirmColor,
  }) {
    return showDialog<bool>(
      context: context,
      builder:
          (context) => AlertDialog.adaptive(
            title: Text(title),
            content: Text(message),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text('Cancel'),
              ),
              ElevatedButton(
                onPressed: () => Navigator.pop(context, true),
                style: ElevatedButton.styleFrom(
                  backgroundColor: confirmColor,
                  foregroundColor: Colors.white,
                ),
                child: Text(confirmText),
              ),
            ],
          ),
    );
  }

  void _showRequestDetails(NotificationModel req) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder:
          (context) => Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    CircleAvatar(
                      radius: 30,
                      backgroundImage: AssetImage(
                        'assets/images/default_face.jpeg',
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            req.senderName ?? 'Unknown User',
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Trainer Request',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey.shade600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                Text(
                  'Message',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey.shade700,
                  ),
                ),
                const SizedBox(height: 8),
                Text(req.message, style: const TextStyle(fontSize: 15)),
                const SizedBox(height: 24),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () {
                          Navigator.pop(context);
                          _handleReject(req);
                        },
                        style: OutlinedButton.styleFrom(
                          foregroundColor: Colors.red,
                          side: const BorderSide(color: Colors.red),
                        ),
                        child: const Text('Reject'),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.pop(context);
                          _handleAccept(req);
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green,
                          foregroundColor: Colors.white,
                        ),
                        child: const Text('Accept'),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
    );
  }
}
