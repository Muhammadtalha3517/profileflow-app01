import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../models/activity_log_entry.dart';
import '../../core/utils/date_formatter.dart';

class ActivityLogTile extends StatelessWidget {
  final ActivityLogEntry entry;

  const ActivityLogTile({
    Key? key,
    required this.entry,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    IconData icon;
    Color iconBg;
    Color iconColor;

    switch (entry.actionType) {
      case 'pageScanned':
        icon = Icons.radar;
        iconBg = AppColors.infoBg;
        iconColor = AppColors.info;
        break;
      case 'fieldsFilled':
        icon = Icons.check_circle_outline;
        iconBg = AppColors.successBg;
        iconColor = AppColors.success;
        break;
      case 'taskCreated':
        icon = Icons.add_task;
        iconBg = const Color(0xFFF3E8FF);
        iconColor = const Color(0xFF9333EA);
        break;
      case 'dataExported':
      case 'dataImported':
        icon = Icons.swap_horiz;
        iconBg = AppColors.warningBg;
        iconColor = AppColors.warning;
        break;
      default:
        icon = Icons.history;
        iconBg = isDark ? const Color(0xFF1E293B) : const Color(0xFFF1F5F9);
        iconColor = AppColors.textSecondaryLight;
        break;
    }

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: iconBg,
              shape: BoxShape.circle,
            ),
            child: Icon(icon, size: 18, color: iconColor),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      entry.title,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
                      ),
                    ),
                    Text(
                      DateFormatter.formatTime(entry.timestamp),
                      style: TextStyle(
                        fontSize: 11,
                        color: isDark ? AppColors.textTertiaryDark : AppColors.textTertiaryLight,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 2),
                Text(
                  entry.description,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontSize: 12,
                    color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                  ),
                ),
                if (entry.targetUrl != null && entry.targetUrl!.isNotEmpty) ...[
                  const SizedBox(height: 2),
                  Text(
                    entry.targetUrl!,
                    style: const TextStyle(
                      fontSize: 10,
                      color: AppColors.primary,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}
