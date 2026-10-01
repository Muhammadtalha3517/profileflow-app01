import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../providers/profile_provider.dart';
import '../../providers/task_provider.dart';
import '../../providers/assistant_provider.dart';
import '../../widgets/cards/profile_completion_card.dart';
import '../../widgets/cards/task_status_card.dart';
import '../../widgets/cards/activity_log_tile.dart';
import '../profile/profile_dashboard_screen.dart';
import '../profile/edit_personal_screen.dart';
import '../tasks/create_task_screen.dart';
import '../tasks/tasks_screen.dart';
import '../search/global_search_screen.dart';
import '../assistant_browser/form_assistant_webview_screen.dart';
import '../activity/activity_history_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({Key? key}) : super(key: key);

  String _getGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) {
      return 'Good morning';
    } else if (hour < 17) {
      return 'Good afternoon';
    } else {
      return 'Good evening';
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final profileProvider = context.watch<ProfileProvider>();
    final taskProvider = context.watch<TaskProvider>();
    final assistantProvider = context.watch<AssistantProvider>();

    final profile = profileProvider.profile;
    final userName = profile.personalInfo.firstName.isNotEmpty
        ? profile.personalInfo.firstName
        : (profile.personalInfo.fullName.isNotEmpty ? profile.personalInfo.fullName : 'there');

    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(Icons.badge_rounded, color: AppColors.primary, size: 22),
            ),
            const SizedBox(width: 10),
            const Text(
              'ProfileFlow',
              style: TextStyle(fontWeight: FontWeight.bold, letterSpacing: -0.3),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.search_rounded),
            tooltip: 'Search Profile Data',
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const GlobalSearchScreen()),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.history_rounded),
            tooltip: 'Activity Audit Log',
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const ActivityHistoryScreen()),
              );
            },
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          await profileProvider.loadProfile();
          await taskProvider.loadTasks();
        },
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Greeting Section
              Text(
                '${_getGreeting()}, $userName 👋',
                style: theme.textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w800,
                  letterSpacing: -0.5,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Your verified real data is securely saved on-device.',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                ),
              ),

              const SizedBox(height: 20),

              // Profile Strength Card
              ProfileCompletionCard(
                percentage: profileProvider.completionPercentage,
                statusLabel: profileProvider.completionStatus,
                onEditTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => const ProfileDashboardScreen()),
                  );
                },
              ),

              const SizedBox(height: 24),

              // Quick Actions Grid
              Text(
                'Quick Actions',
                style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: _buildQuickActionCard(
                      context,
                      icon: Icons.edit_note_rounded,
                      title: 'Edit Profile',
                      color: AppColors.primary,
                      onTap: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(builder: (_) => const EditPersonalScreen()),
                        );
                      },
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildQuickActionCard(
                      context,
                      icon: Icons.add_task_rounded,
                      title: 'Create Task',
                      color: AppColors.secondary,
                      onTap: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(builder: (_) => const CreateTaskScreen()),
                        );
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: _buildQuickActionCard(
                      context,
                      icon: Icons.search_rounded,
                      title: 'Search Data',
                      color: const Color(0xFF6366F1),
                      onTap: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(builder: (_) => const GlobalSearchScreen()),
                        );
                      },
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildQuickActionCard(
                      context,
                      icon: Icons.auto_fix_high_rounded,
                      title: 'Fill Step',
                      color: const Color(0xFF0D9488),
                      onTap: () {
                        _showQuickFillUrlDialog(context);
                      },
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 24),

              // Security & Privacy Guarantee Card
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: isDark ? const Color(0xFF13232C) : AppColors.securityBadgeBg,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppColors.securityBadge.withOpacity(0.3)),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: AppColors.securityBadge.withOpacity(0.15),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.shield_rounded, color: AppColors.securityBadge, size: 24),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Local Vault Active',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                              color: AppColors.securityBadge,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            'Encrypted with AES-256 on this device. Manual review enforced before every fill.',
                            style: TextStyle(
                              fontSize: 12,
                              color: isDark ? Colors.white70 : const Color(0xFF065F46),
                              height: 1.3,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // Recent Tasks Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Recent Tasks',
                    style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                  ),
                  TextButton(
                    onPressed: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(builder: (_) => const TasksScreen()),
                      );
                    },
                    child: const Text('View All'),
                  ),
                ],
              ),
              const SizedBox(height: 8),

              if (taskProvider.tasks.isEmpty)
                Container(
                  padding: const EdgeInsets.all(20),
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: isDark ? AppColors.surfaceDark : Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: isDark ? AppColors.dividerDark : AppColors.dividerLight,
                    ),
                  ),
                  child: Column(
                    children: [
                      const Icon(Icons.assignment_outlined, size: 36, color: AppColors.textTertiaryLight),
                      const SizedBox(height: 8),
                      const Text(
                        'No tasks created yet',
                        style: TextStyle(fontWeight: FontWeight.w600),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Create a task to assist filling forms on websites.',
                        style: TextStyle(fontSize: 12, color: isDark ? AppColors.textTertiaryDark : AppColors.textSecondaryLight),
                      ),
                    ],
                  ),
                )
              else
                ...taskProvider.tasks.take(3).map(
                  (task) => Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: TaskStatusCard(
                      task: task,
                      onTap: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) => FormAssistantWebViewScreen(
                              initialUrl: task.targetUrl,
                              task: task,
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ),

              const SizedBox(height: 20),

              // Recent Activity Preview
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Recent Activity',
                    style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                  ),
                  TextButton(
                    onPressed: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(builder: (_) => const ActivityHistoryScreen()),
                      );
                    },
                    child: const Text('View Log'),
                  ),
                ],
              ),
              const SizedBox(height: 8),

              if (assistantProvider.activityLogs.isEmpty)
                Container(
                  padding: const EdgeInsets.all(16),
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: isDark ? AppColors.surfaceDark : Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: isDark ? AppColors.dividerDark : AppColors.dividerLight,
                    ),
                  ),
                  child: const Text(
                    'No form filling activity recorded yet.',
                    style: TextStyle(fontSize: 12, color: AppColors.textSecondaryLight),
                  ),
                )
              else
                ...assistantProvider.activityLogs.take(2).map(
                  (log) => Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: ActivityLogTile(entry: log),
                  ),
                ),

              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildQuickActionCard(
    BuildContext context, {
    required IconData icon,
    required String title,
    required Color color,
    required VoidCallback onTap,
  }) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Material(
      color: isDark ? AppColors.surfaceDark : Colors.white,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: isDark ? AppColors.dividerDark : AppColors.dividerLight,
            ),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: color, size: 20),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  title,
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showQuickFillUrlDialog(BuildContext context) {
    final urlController = TextEditingController(text: 'https://');

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Open Form Assistant'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Enter the web address of the form you want to fill:',
              style: TextStyle(fontSize: 13),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: urlController,
              decoration: const InputDecoration(
                labelText: 'Target URL',
                hintText: 'https://example.com/apply',
                prefixIcon: Icon(Icons.language),
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.url,
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () {
              final url = urlController.text.trim();
              if (url.isNotEmpty && (url.startsWith('http://') || url.startsWith('https://'))) {
                Navigator.pop(ctx);
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => FormAssistantWebViewScreen(initialUrl: url),
                  ),
                );
              }
            },
            child: const Text('Open Browser'),
          ),
        ],
      ),
    );
  }
}
