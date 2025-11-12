import 'package:flutter/material.dart';

class TrainerChatAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String receiverName;
  final String receiverImage;
  final VoidCallback? onBack;
  final VoidCallback? onProfileTap;
  final VoidCallback? onFeedbackTap;
  final VoidCallback? onAgendaTap;
  final bool isTrainer;

  const TrainerChatAppBar({
    super.key,
    required this.receiverName,
    required this.receiverImage,
    this.onBack,
    this.onProfileTap,
    this.onFeedbackTap,
    this.onAgendaTap,
    this.isTrainer = false,
  });

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: Colors.white,
      elevation: 0,
      automaticallyImplyLeading: false,
      titleSpacing: 0,
      title: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.arrow_back_ios, color: Colors.black),
            onPressed: onBack,
          ),

          GestureDetector(
            onTap: onProfileTap,
            child: CircleAvatar(
              backgroundImage:
              // receiverImage.isNotEmpty
              //     ? NetworkImage(receiverImage)
              //     : const AssetImage('assets/teralero.png')
              //         as ImageProvider,
              const AssetImage('assets/teralero.png'),
              radius: 20,
            ),
          ),

          const SizedBox(width: 12),

          Expanded(
            child: Text(
              receiverName,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.black,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ),

          if (!isTrainer) ...[
            IconButton(
              icon: const Icon(Icons.feedback, color: Colors.black87),
              onPressed: onFeedbackTap,
            ),
            IconButton(
              icon: const Icon(Icons.note_alt_rounded, color: Colors.black87),
              onPressed: onAgendaTap,
            ),
          ],
        ],
      ),
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
