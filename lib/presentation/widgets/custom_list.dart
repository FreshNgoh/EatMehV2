import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:eatmehv2/presentation/widgets/custom_card.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class ListActionIcon {
  final IconData icon;
  final VoidCallback onPressed;
  final String? tooltip;

  ListActionIcon({required this.icon, required this.onPressed, this.tooltip});
}

class CustomList extends StatelessWidget {
  final String value;
  final VoidCallback onFieldTap;
  final VoidCallback? onProfileTap;
  final Widget? profile;
  final String? lastMessage;
  final Timestamp? lastUpdated;
  final List<ListActionIcon> actionIcons;

  const CustomList({
    super.key,
    required this.value,
    required this.onFieldTap,
    this.onProfileTap,
    this.profile,
    this.lastMessage,
    this.lastUpdated,
    this.actionIcons = const [],
  });

  String _formatTimestamp(Timestamp? timestamp) {
    if (timestamp == null) return '';
    final date = timestamp.toDate();
    final now = DateTime.now();

    if (date.year == now.year &&
        date.month == now.month &&
        date.day == now.day) {
      // same day → show only 24-hour time
      return DateFormat('HH:mm').format(date);
    }
    // different day → show short date
    return DateFormat('dd/MM/yyyy').format(date);
  }

  @override
  Widget build(BuildContext context) {
    final hasSubText =
        (lastMessage != null && lastMessage!.isNotEmpty) || lastUpdated != null;

    return GestureDetector(
      onTap: onFieldTap,
      child: CustomCard(
        child: Row(
          crossAxisAlignment:
              hasSubText ? CrossAxisAlignment.start : CrossAxisAlignment.center,
          children: [
            if (profile != null) ...[
              GestureDetector(onTap: onProfileTap, child: profile!),
              const SizedBox(width: 12),
            ],
            Expanded(
              child:
                  hasSubText
                      ? Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            value,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 4),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                                child: Text(
                                  lastMessage ?? '',
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: Colors.grey[600],
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              const SizedBox(width: 8),
                              Text(
                                _formatTimestamp(lastUpdated),
                                style: TextStyle(
                                  fontSize: 13,
                                  color: Colors.grey[500],
                                ),
                              ),
                            ],
                          ),
                        ],
                      )
                      : Text(
                        value,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
            ),
            if (actionIcons.isNotEmpty) ...[
              Row(
                mainAxisSize: MainAxisSize.min,
                children:
                    actionIcons
                        .map(
                          (action) => IconButton(
                            icon: Icon(action.icon),
                            onPressed: action.onPressed,
                            tooltip: action.tooltip,
                          ),
                        )
                        .toList(),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
