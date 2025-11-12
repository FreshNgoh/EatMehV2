import 'package:flutter/material.dart';

class CustomActionCard extends StatelessWidget {
  final BuildContext context;
  final String title;
  final String subtitle;
  final IconData icon;
  final Gradient gradient;
  final bool isPending;
  final bool isOutlined;
  final VoidCallback? onTap;

  const CustomActionCard({
    super.key,
    required this.context,
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.gradient,
    this.isPending = false,
    this.isOutlined = false,
    this.onTap,
  });
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: isPending ? null : onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          gradient: isOutlined ? null : gradient,
          color: isOutlined ? Colors.white : null,
          border:
              isOutlined
                  ? Border.all(color: Colors.grey.shade300, width: 2)
                  : null,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color:
                  isOutlined
                      ? Colors.grey.withOpacity(0.1)
                      : Colors.green.withOpacity(0.3),
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color:
                    isOutlined
                        ? Colors.blue.shade50
                        : Colors.white.withOpacity(0.2),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Icon(
                icon,
                size: 32,
                color: isOutlined ? Colors.blue.shade600 : Colors.white,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    isPending ? 'Application Pending' : title,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: isOutlined ? Colors.grey.shade900 : Colors.white,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    isPending ? 'We\'re reviewing your application' : subtitle,
                    style: TextStyle(
                      fontSize: 14,
                      color:
                          isOutlined
                              ? Colors.grey.shade600
                              : Colors.white.withOpacity(0.9),
                    ),
                  ),
                ],
              ),
            ),
            if (!isPending)
              Icon(
                Icons.arrow_forward_ios,
                color: isOutlined ? Colors.grey.shade600 : Colors.white,
                size: 20,
              ),
          ],
        ),
      ),
    );
  }
}
