import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:eatmehv2/bloc/auth/auth_bloc.dart';
import 'package:eatmehv2/core/constants/firebase_constants.dart';
import 'package:eatmehv2/data/models/notification/notification_model.dart';
import 'package:eatmehv2/data/repos/notification_repo.dart';
import 'package:eatmehv2/data/services/notification_service.dart';
import 'package:eatmehv2/presentation/screens/user/friends_screen.dart';
import 'package:eatmehv2/presentation/screens/user/notifications_screen.dart';
import 'package:eatmehv2/presentation/screens/user/profile_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/localization/app_localizations.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final bool showNotification;
  final bool showFriendRequest;

  // Only used when the title is "Records"
  final int selectedRecordTab;
  final ValueChanged<int>? onRecordTabChange;

  const CustomAppBar({
    super.key,
    required this.title,
    this.showNotification = false,
    this.showFriendRequest = false,
    this.selectedRecordTab = 0,
    this.onRecordTabChange,
  });

  @override
  Size get preferredSize => const Size.fromHeight(60);

  @override
  Widget build(BuildContext context) {
    final bool isRecordPage = title == 'Records';

    return AppBar(
      backgroundColor: Colors.white,
      elevation: 0,
      centerTitle: true,
      leadingWidth: 60,
      // center title
      title:
          isRecordPage
              ? _buildRecordTabs(context)
              : Text(
                title,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF191919),
                ),
              ),
      // avatar on the left
      leading: Padding(
        padding: const EdgeInsets.only(left: 15.0),
        child: BlocBuilder<AuthBloc, AuthState>(
          builder: (context, state) {
            if (state is! Authenticated) {
              // Fallback: show default avatar without navigation
              return Align(
                alignment: Alignment.centerLeft,
                child: CircleAvatar(
                  radius: 20,
                  backgroundColor: Colors.white,
                  backgroundImage: const AssetImage("assets/teralero.png"),
                ),
              );
            }

            final ImageProvider avatarImage =
                (state.user.imageUrl != null && state.user.imageUrl!.isNotEmpty)
                    ? NetworkImage(state.user.imageUrl!)
                    : const AssetImage("assets/teralero.png");

            final currentUserUid = state.user.uid;

            return Align(
              alignment: Alignment.centerLeft,
              child: GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => ProfileScreen(userUid: currentUserUid),
                    ),
                  );
                },
                child: Container(
                  padding: const EdgeInsets.all(3),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.black, width: 1),
                  ),
                  child: CircleAvatar(
                    radius: 20,
                    backgroundColor: Colors.white,
                    backgroundImage: avatarImage,
                  ),
                ),
              ),
            );
          },
        ),
      ),
      actions: [
        if (showFriendRequest) _showFriendRequestButton(context),
        if (showNotification) _showNotificationsButton(context),

        const SizedBox(width: 12),
      ],
      bottom: PreferredSize(
        preferredSize: const Size.fromHeight(1),
        child: Container(height: 1, color: Colors.grey.shade200),
      ),
    );
  }

  // Request Button
  Widget _showFriendRequestButton(BuildContext context) {
    final authState = context.read<AuthBloc>().state;
    if (authState is! Authenticated) {
      return const SizedBox.shrink();
    }

    final userUid = authState.user.uid;

    return StreamBuilder<DocumentSnapshot>(
      stream:
          FirebaseFirestore.instance
              .collection(FirebaseConstants.usersCollection)
              .doc(userUid)
              .snapshots(),
      builder: (context, snapshot) {
        int requestCount = 0;

        if (snapshot.hasData && snapshot.data?.data() != null) {
          final data = snapshot.data!.data() as Map<String, dynamic>;
          final friendRequests = List<String>.from(
            data['friendRequests'] ?? [],
          );
          requestCount = friendRequests.length;
        }

        return Padding(
          padding: const EdgeInsets.only(right: 8.0),
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              IconButton(
                icon: const Icon(Icons.person_add, color: Color(0xFF191919)),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const FriendsScreen()),
                  );
                },
              ),
              if (requestCount > 0)
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
                      minWidth: 18,
                      minHeight: 18,
                    ),
                    child: Center(
                      child: Text(
                        requestCount > 9 ? '9+' : '$requestCount',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }

  Widget _showNotificationsButton(BuildContext context) {
    final notificationRepo = NotificationRepo(NotificationService());
    final authState = context.read<AuthBloc>().state as Authenticated;
    final userUid = authState.user.uid;

    return StreamBuilder<List<NotificationModel>>(
      stream: notificationRepo.getNotifications(userUid),
      builder: (context, snapshot) {
        final hasUnread =
            snapshot.hasData &&
            snapshot.data!.any((notif) => notif.isRead == false);

        return Stack(
          children: [
            IconButton(
              icon: const Icon(Icons.notifications, color: Color(0xFF191919)),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => NotificationsScreen(userUid: userUid),
                  ),
                );
              },
            ),
            if (hasUnread)
              const Positioned(
                right: 8,
                top: 8,
                child: CircleAvatar(radius: 5, backgroundColor: Colors.red),
              ),
          ],
        );
      },
    );
  }

  /// --- RECORD PAGE TAB SWITCHER ---
  Widget _buildRecordTabs(BuildContext context) {
    final loc = context.loc;

    final tabs = [
      loc.recordTabDiet,
      loc.recordTabOverview,
      loc.recordTabExercise,
    ];

    return Padding(
      padding: const EdgeInsets.only(
        left: 30.0,
      ), // add margin manually to make it center
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: List.generate(tabs.length, (index) {
          final bool isSelected = index == selectedRecordTab;
          return GestureDetector(
            onTap: () => onRecordTabChange?.call(index),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10.0),
              child: Text(
                tabs[index],
                style: TextStyle(
                  fontSize: isSelected ? 18 : 19,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                  color:
                      isSelected ? const Color(0xFF191919) : Colors.grey[600],
                ),
              ),
            ),
          );
        }),
      ),
    );
  }

  void _showNotifications(
    BuildContext context,
    List<NotificationModel> notifications,
  ) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        if (notifications.isEmpty) {
          return const Padding(
            padding: EdgeInsets.all(20),
            child: Center(child: Text("No notifications yet")),
          );
        }

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
                          notif.isRead
                              ? Colors.grey.shade200
                              : const Color(0xFF191919).withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      _getNotificationIcon(notif.type),
                      color:
                          notif.isRead ? Colors.grey : const Color(0xFF191919),
                    ),
                  ),
                  title: Text(
                    notif.title,
                    style: TextStyle(
                      fontWeight:
                          notif.isRead ? FontWeight.normal : FontWeight.bold,
                    ),
                  ),
                  subtitle: Text(notif.message),
                  trailing: Text(
                    _getTimeAgo(notif.createdAt.toDate()),
                    style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                  ),
                );
              }),
            ],
          ),
        );
      },
    );
  }

  IconData _getNotificationIcon(String type) {
    switch (type) {
      case 'trainer_request':
        return Icons.fitness_center;
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
