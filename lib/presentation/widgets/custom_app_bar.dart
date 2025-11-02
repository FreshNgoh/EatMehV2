import 'package:eatmehv2/presentation/screens/user/profile_screen.dart';
import 'package:flutter/material.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final bool showNotification;
  final bool showFriendRequest;

  const CustomAppBar({
    super.key,
    required this.title,
    this.showNotification = false,
    this.showFriendRequest = false,
  });

  @override
  Size get preferredSize => const Size.fromHeight(60);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: Colors.white,
      elevation: 0,
      title: Row(
        children: [
          GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const ProfileScreen()),
              );
            },
            child: const CircleAvatar(
              radius: 18,
              backgroundImage: NetworkImage(
                'https://wallpapers.com/images/hd/chef-minion-in-red-hlpmj9v0kah222pp.jpg',
              ),
            ),
          ),
          const SizedBox(width: 12),
          const Text(
            'Hi, User',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Color(0xFF191919),
            ),
          ),
        ],
      ),
      actions: [
        if (showFriendRequest)
          Stack(
            children: [
              IconButton(
                icon: const Icon(Icons.person_add, color: Color(0xFF191919)),
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Friend Requests Page')),
                  );
                },
              ),
              Positioned(
                right: 8,
                top: 8,
                child: Container(
                  padding: const EdgeInsets.all(4),
                  decoration: const BoxDecoration(
                    color: Colors.red,
                    shape: BoxShape.circle,
                  ),
                  constraints: const BoxConstraints(
                    minWidth: 16,
                    minHeight: 16,
                  ),
                  child: const Text(
                    '2',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
            ],
          ),
        if (showNotification)
          Stack(
            children: [
              IconButton(
                icon: const Icon(Icons.notifications, color: Color(0xFF191919)),
                onPressed: () {
                  _showNotifications(context);
                },
              ),
              Positioned(
                right: 8,
                top: 8,
                child: Container(
                  width: 8,
                  height: 8,
                  decoration: const BoxDecoration(
                    color: Colors.red,
                    shape: BoxShape.circle,
                  ),
                ),
              ),
            ],
          ),
        const SizedBox(width: 8),
      ],
      bottom: PreferredSize(
        preferredSize: const Size.fromHeight(1),
        child: Container(height: 1, color: Colors.grey.shade200),
      ),
    );
  }

  void _showNotifications(BuildContext context) {
    // 🔹 Static dummy notifications list
    final List<Map<String, dynamic>> notifications = [
      {
        'type': 'friend_request',
        'title': 'New friend request',
        'body': 'John Doe sent you a friend request.',
        'read': false,
        'createdAt': DateTime.now().subtract(const Duration(minutes: 10)),
      },
      {
        'type': 'meal_reminder',
        'title': 'Lunch time!',
        'body': 'Don’t forget your healthy meal today 🍱',
        'read': true,
        'createdAt': DateTime.now().subtract(const Duration(hours: 3)),
      },
      {
        'type': 'story_view',
        'title': 'Your story was viewed',
        'body': 'Emily viewed your latest story.',
        'read': false,
        'createdAt': DateTime.now().subtract(const Duration(days: 1)),
      },
    ];

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Notifications',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              ...notifications.map((notif) {
                return ListTile(
                  leading: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color:
                          notif['read']
                              ? Colors.grey.shade200
                              : const Color(0xFF191919).withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      _getNotificationIcon(notif['type']),
                      color:
                          notif['read'] ? Colors.grey : const Color(0xFF191919),
                    ),
                  ),
                  title: Text(
                    notif['title'],
                    style: TextStyle(
                      fontWeight:
                          notif['read'] ? FontWeight.normal : FontWeight.bold,
                    ),
                  ),
                  subtitle: Text(notif['body']),
                  trailing: Text(
                    _getTimeAgo(notif['createdAt']),
                    style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                  ),
                );
              }).toList(),
            ],
          ),
        );
      },
    );
  }

  IconData _getNotificationIcon(String type) {
    switch (type) {
      case 'friend_request':
        return Icons.person_add;
      case 'story_view':
        return Icons.visibility;
      case 'meal_reminder':
        return Icons.restaurant;
      default:
        return Icons.notifications;
    }
  }

  String _getTimeAgo(DateTime dateTime) {
    final diff = DateTime.now().difference(dateTime);
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    return '${diff.inDays}d ago';
  }
}
