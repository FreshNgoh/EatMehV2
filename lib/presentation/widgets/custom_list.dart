import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';

class ListActionIcon {
  final IconData icon;
  final VoidCallback onPressed;
  final String? tooltip;

  ListActionIcon({required this.icon, required this.onPressed, this.tooltip});
}

class CustomList extends StatelessWidget {
  final String value;
  final VoidCallback onFieldTap;
  final List<ListActionIcon> actionIcons;

  const CustomList({
    super.key,
    required this.value,
    required this.onFieldTap,
    this.actionIcons = const [],
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onFieldTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
        margin: const EdgeInsets.symmetric(vertical: 6),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.border),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Text(
                value,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
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
        ),
      ),
    );
  }
}
