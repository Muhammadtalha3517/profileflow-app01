import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../providers/assistant_provider.dart';
import '../../widgets/cards/activity_log_tile.dart';

class ActivityHistoryScreen extends StatelessWidget {
  const ActivityHistoryScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final assistantProvider = context.watch<AssistantProvider>();
    final logs = assistantProvider.activityLogs;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Activity Audit Log'),
        actions: [
          if (logs.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.delete_sweep_outlined),
              tooltip: 'Clear Log History',
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (ctx) => AlertDialog(
                    title: const Text('Clear Activity Log?'),
                    content: const Text('This will clear the audit history of form filling sessions. Your profile data will remain safe.'),
                    actions: [
                      TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
                      ElevatedButton(
                        onPressed: () {
                          assistantProvider.clearLogs();
                          Navigator.pop(ctx);
                        },
                        style: ElevatedButton.styleFrom(backgroundColor: AppColors.error),
                        child: const Text('Clear Log'),
                      ),
                    ],
                  ),
                );
              },
            ),
        ],
      ),
      body: logs.isEmpty
          ? Center(
              child: Padding(
                padding: const EdgeInsets.all(32.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withOpacity(0.1),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.history_toggle_off_rounded, size: 48, color: AppColors.primary),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'No Activity Recorded Yet',
                      style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'All scan events, field approvals, and population actions will appear in this audit log.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                      ),
                    ),
                  ],
                ),
              ),
            )
          : ListView.separated(
              padding: const EdgeInsets.all(20),
              itemCount: logs.length,
              separatorBuilder: (_, __) => const SizedBox(height: 8),
              itemBuilder: (context, index) {
                final entry = logs[index];
                return ActivityLogTile(entry: entry);
              },
            ),
    );
  }
}
