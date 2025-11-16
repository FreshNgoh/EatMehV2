import 'package:eatmehv2/data/models/notification/notification_model.dart';
import 'package:eatmehv2/data/repos/notification_repo.dart';
import 'package:eatmehv2/data/repos/user_repo.dart';
import 'package:eatmehv2/data/services/notification_service.dart';
import 'package:eatmehv2/presentation/screens/trainer/trainer_request.dart';
import 'package:flutter/material.dart';

class NotificationsScreen extends StatefulWidget {
  final String userUid;
  const NotificationsScreen({super.key, required this.userUid});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  final notificationRepo = NotificationRepo(NotificationService());
  String selectedFilter = 'all';
  final userRepo = UserRepository();
  bool isLoadingRole = true;
  String? userRole;

  final Map<String, String> filterTypes = {
    'all': 'All',
    'trainer_request': 'Trainer Requests',
    'story_view': 'Story Views',
    'meal_reminder': 'Meal Reminders',
  };

  @override
  void initState() {
    super.initState();
    _loadUserRole();
  }

  Future<void> _loadUserRole() async {
    try {
      final userDoc = await userRepo.getUser(widget.userUid);
      if (mounted) {
        setState(() {
          userRole = userDoc?.role ?? 'user';
          isLoadingRole = false;
        });
      }
    } catch (e) {
      Exception('Error loading user role: $e');
      if (mounted) {
        setState(() {
          userRole = 'user';
          isLoadingRole = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        title: const Text(
          'Notifications',
          style: TextStyle(
            color: Color(0xFF191919),
            fontWeight: FontWeight.bold,
          ),
        ),
        iconTheme: const IconThemeData(color: Color(0xFF191919)),
      ),
      body: Column(
        children: [
          // Filter chips
          Container(
            height: 60,
            color: Colors.white,
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              children:
                  filterTypes.entries.map((entry) {
                    final isSelected = selectedFilter == entry.key;
                    return Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: FilterChip(
                        label: Text(entry.value),
                        selected: isSelected,
                        onSelected: (selected) {
                          setState(() {
                            selectedFilter = entry.key;
                          });
                        },
                        backgroundColor: Colors.grey.shade100,
                        selectedColor: const Color(0xFF191919),
                        labelStyle: TextStyle(
                          color:
                              isSelected
                                  ? Colors.white
                                  : const Color(0xFF191919),
                          fontWeight:
                              isSelected ? FontWeight.bold : FontWeight.normal,
                        ),
                        checkmarkColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                          side: BorderSide(
                            color:
                                isSelected
                                    ? const Color(0xFF191919)
                                    : Colors.transparent,
                          ),
                        ),
                      ),
                    );
                  }).toList(),
            ),
          ),
          const Divider(height: 1),

          // Notifications list
          Expanded(
            child: StreamBuilder<List<NotificationModel>>(
              stream: notificationRepo.getNotifications(widget.userUid),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.notifications_none,
                          size: 80,
                          color: Colors.grey.shade300,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          "No notifications yet",
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w500,
                            color: Colors.grey.shade600,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          "We'll notify you when something arrives",
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey.shade400,
                          ),
                        ),
                      ],
                    ),
                  );
                }

                // Filter notifications
                final allNotifications = snapshot.data!;
                final filteredNotifications =
                    selectedFilter == 'all'
                        ? allNotifications
                        : allNotifications
                            .where((n) => n.type == selectedFilter)
                            .toList();

                if (filteredNotifications.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          _getNotificationIcon(selectedFilter),
                          size: 60,
                          color: Colors.grey.shade300,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          "No ${filterTypes[selectedFilter]?.toLowerCase()}",
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.grey.shade600,
                          ),
                        ),
                      ],
                    ),
                  );
                }

                return ListView.separated(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  itemCount: filteredNotifications.length,
                  separatorBuilder:
                      (context, index) => const Divider(height: 1, indent: 72),
                  itemBuilder: (context, index) {
                    final notif = filteredNotifications[index];
                    return Dismissible(
                      key: Key(notif.uid ?? 'notif_$index'),
                      direction: DismissDirection.endToStart,
                      confirmDismiss: (direction) async {
                        return await _showDeleteConfirmation(notif);
                      },
                      onDismissed: (direction) async {
                        await notificationRepo.deleteNotification(notif.uid!);
                        if (mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: const Text('Notification deleted'),
                              behavior: SnackBarBehavior.floating,
                              action: SnackBarAction(
                                label: 'Undo',
                                onPressed: () {
                                  // Note: Implementing undo would require
                                  // storing deleted notification data temporarily
                                },
                              ),
                            ),
                          );
                        }
                      },
                      background: Container(
                        color: Colors.red,
                        alignment: Alignment.centerRight,
                        padding: const EdgeInsets.only(right: 20),
                        child: const Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.delete, color: Colors.white, size: 28),
                            SizedBox(height: 4),
                            Text(
                              'Delete',
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ),
                      child: Container(
                        color:
                            notif.isRead
                                ? Colors.white
                                : const Color(0xFF191919).withOpacity(0.02),
                        child: ListTile(
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 8,
                          ),
                          leading: Container(
                            width: 48,
                            height: 48,
                            decoration: BoxDecoration(
                              color:
                                  notif.isRead
                                      ? Colors.grey.shade200
                                      : _getNotificationColor(
                                        notif.type,
                                      ).withOpacity(0.1),
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              _getNotificationIcon(notif.type),
                              color:
                                  notif.isRead
                                      ? Colors.grey
                                      : _getNotificationColor(notif.type),
                              size: 24,
                            ),
                          ),
                          title: Text(
                            notif.title,
                            style: TextStyle(
                              fontWeight:
                                  notif.isRead
                                      ? FontWeight.w500
                                      : FontWeight.bold,
                              fontSize: 15,
                              color: const Color(0xFF191919),
                            ),
                          ),
                          subtitle: Padding(
                            padding: const EdgeInsets.only(top: 4),
                            child: Text(
                              notif.message,
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey.shade700,
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          trailing: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Text(
                                _getTimeAgo(notif.createdAt.toDate()),
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey.shade500,
                                ),
                              ),
                              if (!notif.isRead) ...[
                                const SizedBox(height: 4),
                                Container(
                                  width: 8,
                                  height: 8,
                                  decoration: const BoxDecoration(
                                    color: Color(0xFF191919),
                                    shape: BoxShape.circle,
                                  ),
                                ),
                              ],
                            ],
                          ),
                          onTap: () async {
                            // Mark as read
                            if (!notif.isRead) {
                              await notificationRepo.markAsRead(notif.uid!);
                            }

                            _handleNotificationTap(notif);
                          },
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Future<bool?> _showDeleteConfirmation(NotificationModel notif) {
    return showDialog<bool>(
      context: context,
      builder:
          (context) => AlertDialog.adaptive(
            title: const Text('Delete Notification'),
            content: Text('Delete "${notif.title}"?'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text('Cancel'),
              ),
              TextButton(
                onPressed: () => Navigator.pop(context, true),
                style: TextButton.styleFrom(foregroundColor: Colors.red),
                child: const Text('Delete'),
              ),
            ],
          ),
    );
  }

  void _handleNotificationTap(NotificationModel notif) {
    switch (notif.type) {
      case 'trainer_request':
        if (userRole == 'trainer') {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder:
                  (context) =>
                      TrainerRequestsScreen(filterByUid: notif.senderUid),
            ),
          );
        }
        break;
      case 'story_view':
        // navigate
        break;
      case 'meal_reminder':
        // navigate
        break;
      default:
        break;
    }
  }

  IconData _getNotificationIcon(String type) {
    switch (type) {
      case 'trainer_request':
        return Icons.fitness_center;
      case 'story_view':
        return Icons.visibility;
      case 'meal_reminder':
        return Icons.restaurant;
      default:
        return Icons.notifications;
    }
  }

  Color _getNotificationColor(String type) {
    switch (type) {
      case 'trainer_request':
        return Colors.orange;
      case 'story_view':
        return Colors.purple;
      case 'meal_reminder':
        return Colors.green;
      default:
        return const Color(0xFF191919);
    }
  }

  String _getTimeAgo(DateTime dateTime) {
    final diff = DateTime.now().difference(dateTime);
    if (diff.inSeconds < 60) return 'Just now';
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    if (diff.inDays < 7) return '${diff.inDays}d ago';
    if (diff.inDays < 30) return '${(diff.inDays / 7).floor()}w ago';
    return '${(diff.inDays / 30).floor()}mo ago';
  }
}
