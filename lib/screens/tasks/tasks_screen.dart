import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../providers/task_provider.dart';
import '../../widgets/cards/task_status_card.dart';
import 'create_task_screen.dart';
import 'task_detail_screen.dart';
import '../assistant_browser/form_assistant_webview_screen.dart';

class TasksScreen extends StatefulWidget {
  const TasksScreen({Key? key}) : super(key: key);

  @override
  State<TasksScreen> createState() => _TasksScreenState();
}

class _TasksScreenState extends State<TasksScreen> {
  String _selectedFilter = 'all';

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final taskProvider = context.watch<TaskProvider>();
    final allTasks = taskProvider.tasks;

    final filteredTasks = allTasks.where((t) {
      if (_selectedFilter == 'all') return true;
      return t.status.name.toLowerCase() == _selectedFilter;
    }).toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Assistant Tasks', style: TextStyle(fontWeight: FontWeight.bold)),
        actions: [
          IconButton(
            icon: const Icon(Icons.add_task_rounded),
            tooltip: 'Create Task',
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const CreateTaskScreen()),
              );
            },
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.of(context).push(
            MaterialPageRoute(builder: (_) => const CreateTaskScreen()),
          );
        },
        icon: const Icon(Icons.add),
        label: const Text('Create Task'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
      ),
      body: Column(
        children: [
          // Filter Chips
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            child: Row(
              children: [
                _buildFilterChip('all', 'All Tasks (${allTasks.length})'),
                const SizedBox(width: 8),
                _buildFilterChip('ready', 'Ready'),
                const SizedBox(width: 8),
                _buildFilterChip('inProgress', 'In Progress'),
                const SizedBox(width: 8),
                _buildFilterChip('completed', 'Completed'),
                const SizedBox(width: 8),
                _buildFilterChip('paused', 'Paused'),
              ],
            ),
          ),

          const Divider(height: 1),

          // Task List
          Expanded(
            child: filteredTasks.isEmpty
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
                            child: const Icon(Icons.assignment_outlined, size: 48, color: AppColors.primary),
                          ),
                          const SizedBox(height: 16),
                          Text(
                            _selectedFilter == 'all' ? 'No Tasks Created' : 'No Tasks Found',
                            style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Create a targeted form filling task with a specific website or form step.',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                            ),
                          ),
                          const SizedBox(height: 24),
                          ElevatedButton.icon(
                            onPressed: () {
                              Navigator.of(context).push(
                                MaterialPageRoute(builder: (_) => const CreateTaskScreen()),
                              );
                            },
                            icon: const Icon(Icons.add),
                            label: const Text('Create Task'),
                          ),
                        ],
                      ),
                    ),
                  )
                : ListView.separated(
                    padding: const EdgeInsets.fromLTRB(20, 16, 20, 80),
                    itemCount: filteredTasks.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 12),
                    itemBuilder: (context, index) {
                      final task = filteredTasks[index];
                      return TaskStatusCard(
                        task: task,
                        onTap: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (_) => TaskDetailScreen(taskId: task.id),
                            ),
                          );
                        },
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip(String filterKey, String label) {
    final isSelected = _selectedFilter == filterKey;
    return FilterChip(
      selected: isSelected,
      label: Text(label),
      onSelected: (_) {
        setState(() {
          _selectedFilter = filterKey;
        });
      },
      selectedColor: AppColors.primaryLight.withOpacity(0.4),
      checkmarkColor: AppColors.primary,
      labelStyle: TextStyle(
        color: isSelected ? AppColors.primaryDark : null,
        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
        fontSize: 12,
      ),
    );
  }
}
