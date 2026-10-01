import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../models/task_item.dart';
import '../../core/utils/date_formatter.dart';

class TaskStatusCard extends StatelessWidget {
  final TaskItem task;
  final VoidCallback onTap;
  final VoidCallback onStart;
  final VoidCallback onPause;
  final VoidCallback onDelete;

  const TaskStatusCard({
    Key? key,
    required this.task,
    required this.onTap,
    required this.onStart,
    required this.onPause,
    required this.onDelete,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    Color statusColor;
    String statusText;
    switch (task.status) {
      case TaskStatus.active:
        statusColor = AppColors.success;
        statusText = 'Active / Ready';
        break;
      case TaskStatus.paused:
        statusColor = AppColors.warning;
        statusText = 'Paused';
        break;
      case TaskStatus.completed:
        statusColor = AppColors.info;
        statusText = 'Completed';
        break;
      case TaskStatus.idle:
      default:
        statusColor = AppColors.textSecondaryLight;
        statusText = 'Idle';
        break;
    }

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 6),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(
          color: isDark ? AppColors.dividerDark : AppColors.dividerLight,
        ),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      task.title,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: statusColor.withOpacity(0.12),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: statusColor.withOpacity(0.3)),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: 6,
                          height: 6,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: statusColor,
                          ),
                        ),
                        const SizedBox(width: 6),
                        Text(
                          statusText,
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: statusColor,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              if (task.targetUrl.isNotEmpty) ...[
                const SizedBox(height: 6),
                Row(
                  children: [
                    const Icon(Icons.link, size: 14, color: AppColors.primary),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        task.targetUrl,
                        style: const TextStyle(
                          fontSize: 12,
                          color: AppColors.primary,
                          decoration: TextDecoration.underline,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ],
              const SizedBox(height: 12),
              Row(
                children: [
                  _buildStatBadge(
                    icon: Icons.radar,
                    label: '${task.detectedFieldsCount} detected',
                    context: context,
                  ),
                  const SizedBox(width: 8),
                  _buildStatBadge(
                    icon: Icons.check_circle_outline,
                    label: '${task.filledFieldsCount} filled',
                    context: context,
                  ),
                  const Spacer(),
                  Text(
                    DateFormatter.formatDateTime(task.updatedAt),
                    style: TextStyle(
                      fontSize: 11,
                      color: isDark ? AppColors.textTertiaryDark : AppColors.textTertiaryLight,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              const Divider(height: 1),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton.icon(
                    icon: const Icon(Icons.delete_outline, size: 16, color: AppColors.error),
                    label: const Text('Delete', style: TextStyle(color: AppColors.error, fontSize: 13)),
                    onPressed: onDelete,
                  ),
                  const SizedBox(width: 8),
                  if (task.status == TaskStatus.active)
                    OutlinedButton.icon(
                      icon: const Icon(Icons.pause, size: 16),
                      label: const Text('Pause', style: TextStyle(fontSize: 13)),
                      style: OutlinedButton.styleFrom(
                        minimumSize: const Size(90, 36),
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                      ),
                      onPressed: onPause,
                    )
                  else
                    ElevatedButton.icon(
                      icon: const Icon(Icons.play_arrow, size: 16),
                      label: const Text('Start / Resume', style: TextStyle(fontSize: 13)),
                      style: ElevatedButton.styleFrom(
                        minimumSize: const Size(130, 36),
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                      ),
                      onPressed: onStart,
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatBadge({
    required IconData icon,
    required String label,
    required BuildContext context,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF162032) : const Color(0xFFF1F5F9),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: AppColors.textSecondaryLight),
          const SizedBox(width: 4),
          Text(
            label,
            style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w500),
          ),
        ],
      ),
    );
  }
}
