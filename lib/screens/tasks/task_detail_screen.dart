import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../models/task_item.dart';
import '../../providers/task_provider.dart';
import '../assistant_browser/form_assistant_webview_screen.dart';

class TaskDetailScreen extends StatelessWidget {
  final String taskId;

  const TaskDetailScreen({Key? key, required this.taskId}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final taskProvider = context.watch<TaskProvider>();

    final taskIndex = taskProvider.tasks.indexWhere((t) => t.id == taskId);
    if (taskIndex == -1) {
      return Scaffold(
        appBar: AppBar(title: const Text('Task Detail')),
        body: const Center(child: Text('Task not found.')),
      );
    }

    final task = taskProvider.tasks[taskIndex];

    Color statusColor;
    switch (task.status) {
      case TaskStatus.ready:
        statusColor = AppColors.info;
        break;
      case TaskStatus.inProgress:
        statusColor = AppColors.warning;
        break;
      case TaskStatus.paused:
        statusColor = Colors.grey;
        break;
      case TaskStatus.completed:
        statusColor = AppColors.success;
        break;
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Task Overview'),
        actions: [
          IconButton(
            icon: const Icon(Icons.delete_outline, color: AppColors.error),
            tooltip: 'Delete Task',
            onPressed: () {
              showDialog(
                context: context,
                builder: (ctx) => AlertDialog(
                  title: const Text('Delete Task?'),
                  content: Text('Are you sure you want to delete "${task.name}"?'),
                  actions: [
                    TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
                    ElevatedButton(
                      onPressed: () async {
                        await taskProvider.deleteTask(task.id);
                        if (ctx.mounted) {
                          Navigator.pop(ctx);
                          Navigator.pop(context);
                        }
                      },
                      style: ElevatedButton.styleFrom(backgroundColor: AppColors.error),
                      child: const Text('Delete'),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          // Header Card
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: isDark ? AppColors.surfaceDark : Colors.white,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: isDark ? AppColors.dividerDark : AppColors.dividerLight,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: statusColor.withOpacity(0.12),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            width: 8,
                            height: 8,
                            decoration: BoxDecoration(color: statusColor, shape: BoxShape.circle),
                          ),
                          const SizedBox(width: 6),
                          Text(
                            task.status.name.toUpperCase(),
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                              color: statusColor,
                            ),
                          ),
                        ],
                      ),
                    ),
                    PopupMenuButton<TaskStatus>(
                      icon: const Icon(Icons.tune_rounded, size: 20),
                      tooltip: 'Change Status',
                      onSelected: (newStatus) {
                        taskProvider.updateTaskStatus(task.id, newStatus);
                      },
                      itemBuilder: (_) => TaskStatus.values.map((s) {
                        return PopupMenuItem(
                          value: s,
                          child: Text('Mark as ${s.name}'),
                        );
                      }).toList(),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  task.name,
                  style: theme.textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    const Icon(Icons.language, size: 16, color: AppColors.primary),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        task.targetUrl,
                        style: const TextStyle(
                          color: AppColors.primary,
                          fontWeight: FontWeight.w600,
                          fontSize: 13,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          const SizedBox(height: 20),

          // Description Card
          if (task.description.isNotEmpty) ...[
            Text('Notes', style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: isDark ? AppColors.surfaceDark : Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: isDark ? AppColors.dividerDark : AppColors.dividerLight,
                ),
              ),
              child: Text(task.description, style: const TextStyle(height: 1.4)),
            ),
            const SizedBox(height: 20),
          ],

          // Permitted Categories
          Text('Permitted Information Categories', style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: isDark ? AppColors.surfaceDark : Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: isDark ? AppColors.dividerDark : AppColors.dividerLight,
              ),
            ),
            child: task.allowedCategories.isEmpty
                ? const Text('All profile information allowed')
                : Column(
                    children: task.allowedCategories.map((c) {
                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 4),
                        child: Row(
                          children: [
                            const Icon(Icons.check_circle_rounded, color: AppColors.success, size: 18),
                            const SizedBox(width: 8),
                            Text(c, style: const TextStyle(fontWeight: FontWeight.w500)),
                          ],
                        ),
                      );
                    }).toList(),
                  ),
          ),

          const SizedBox(height: 20),

          // Detected Fields Stats
          Text('Fields Detected History', style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: isDark ? AppColors.surfaceDark : Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: isDark ? AppColors.dividerDark : AppColors.dividerLight,
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildStatItem('Detected', '${task.detectedFieldsCount}', AppColors.info),
                _buildStatItem('Filled', '${task.filledFieldsCount}', AppColors.success),
                _buildStatItem('Pending', '${task.detectedFieldsCount - task.filledFieldsCount < 0 ? 0 : task.detectedFieldsCount - task.filledFieldsCount}', AppColors.warning),
              ],
            ),
          ),

          const SizedBox(height: 32),

          // Launch Assistant Button
          ElevatedButton.icon(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => FormAssistantWebViewScreen(
                    initialUrl: task.targetUrl,
                    task: task,
                  ),
                ),
              );
            },
            icon: const Icon(Icons.open_in_browser_rounded),
            label: const Text('Open in Form Assistant', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16),
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
            ),
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildStatItem(String label, String value, Color color) {
    return Column(
      children: [
        Text(
          value,
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: const TextStyle(fontSize: 12, color: AppColors.textSecondaryLight),
        ),
      ],
    );
  }
}
