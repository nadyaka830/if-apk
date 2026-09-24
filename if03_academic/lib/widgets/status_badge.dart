import 'package:flutter/material.dart';
import '../core/theme/app_colors.dart';

class StatusBadge extends StatelessWidget {
  final String label;
  final Color backgroundColor;
  final Color textColor;
  final IconData? icon;

  const StatusBadge({
    super.key,
    required this.label,
    required this.backgroundColor,
    required this.textColor,
    this.icon,
  });

  factory StatusBadge.priority(String priority) {
    switch (priority.toUpperCase()) {
      case 'HIGH':
        return const StatusBadge(
          label: 'Tinggi',
          backgroundColor: Color(0xFFFEE2E2),
          textColor: AppColors.priorityHigh,
          icon: Icons.priority_high,
        );
      case 'LOW':
        return const StatusBadge(
          label: 'Rendah',
          backgroundColor: Color(0xFFDCFCE7),
          textColor: AppColors.priorityLow,
        );
      default:
        return const StatusBadge(
          label: 'Normal',
          backgroundColor: Color(0xFFFEF3C7),
          textColor: AppColors.priorityMedium,
        );
    }
  }

  factory StatusBadge.status(String status) {
    switch (status.toUpperCase()) {
      case 'APPROVED':
      case 'ACTIVE':
        return const StatusBadge(
          label: 'Aktif',
          backgroundColor: Color(0xFFDCFCE7),
          textColor: AppColors.success,
          icon: Icons.check_circle_outline,
        );
      case 'REJECTED':
        return const StatusBadge(
          label: 'Ditolak',
          backgroundColor: Color(0xFFFEE2E2),
          textColor: AppColors.error,
          icon: Icons.cancel_outlined,
        );
      default:
        return const StatusBadge(
          label: 'Menunggu',
          backgroundColor: Color(0xFFFEF3C7),
          textColor: AppColors.warning,
          icon: Icons.access_time,
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 14, color: textColor),
            const SizedBox(width: 4),
          ],
          Text(
            label,
            style: TextStyle(
              color: textColor,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
