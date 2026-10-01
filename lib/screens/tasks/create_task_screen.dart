import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../models/task_item.dart';
import '../../providers/task_provider.dart';
import '../../widgets/forms/custom_text_field.dart';
import '../assistant_browser/form_assistant_webview_screen.dart';

class CreateTaskScreen extends StatefulWidget {
  const CreateTaskScreen({Key? key}) : super(key: key);

  @override
  State<CreateTaskScreen> createState() => _CreateTaskScreenState();
}

class _CreateTaskScreenState extends State<CreateTaskScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _urlController = TextEditingController();
  final _notesController = TextEditingController();

  final Map<String, bool> _allowedCategories = {
    'Personal Information': true,
    'Professional Details & Bio': true,
    'Work Experience History': true,
    'Education & Degrees': true,
    'Portfolio & Projects': true,
    'Documents & Photos': false,
  };

  @override
  void dispose() {
    _nameController.dispose();
    _urlController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  void _applyQuickTemplate(String name, String url) {
    setState(() {
      _nameController.text = name;
      _urlController.text = url;
    });
  }

  TaskItem _buildTaskItem() {
    final selectedCategories = _allowedCategories.entries
        .where((e) => e.value)
        .map((e) => e.key)
        .toList();

    return TaskItem(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      name: _nameController.text.trim(),
      targetUrl: _urlController.text.trim(),
      description: _notesController.text.trim(),
      status: TaskStatus.ready,
      createdAt: DateTime.now(),
      allowedCategories: selectedCategories,
    );
  }

  Future<void> _saveTaskOnly() async {
    if (_formKey.currentState?.validate() ?? false) {
      final task = _buildTaskItem();
      await context.read<TaskProvider>().addTask(task);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Task saved successfully!'),
            backgroundColor: AppColors.success,
          ),
        );
        Navigator.pop(context);
      }
    }
  }

  Future<void> _saveAndLaunchAssistant() async {
    if (_formKey.currentState?.validate() ?? false) {
      final task = _buildTaskItem();
      await context.read<TaskProvider>().addTask(task);

      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) => FormAssistantWebViewScreen(
              initialUrl: task.targetUrl,
              task: task,
            ),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Create New Task'),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            // Quick Templates
            Text(
              'Quick Templates',
              style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  ActionChip(
                    avatar: const Icon(Icons.work_outline, size: 16),
                    label: const Text('Job Application Form'),
                    onPressed: () => _applyQuickTemplate('Fill Job Application', 'https://'),
                  ),
                  const SizedBox(width: 8),
                  ActionChip(
                    avatar: const Icon(Icons.laptop, size: 16),
                    label: const Text('Freelance Platform Profile'),
                    onPressed: () => _applyQuickTemplate('Freelancer Profile Setup', 'https://'),
                  ),
                  const SizedBox(width: 8),
                  ActionChip(
                    avatar: const Icon(Icons.badge, size: 16),
                    label: const Text('Speaker / Conference Bio'),
                    onPressed: () => _applyQuickTemplate('Conference Speaker Submission', 'https://'),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // Task Name
            CustomTextField(
              controller: _nameController,
              labelText: 'Task Name',
              hintText: 'e.g., Apply for Lead Mobile Architect at Acme',
              prefixIcon: Icons.task_alt_outlined,
              validator: (v) => (v == null || v.trim().isEmpty) ? 'Please enter a task name' : null,
            ),

            const SizedBox(height: 16),

            // Target URL
            CustomTextField(
              controller: _urlController,
              labelText: 'Target Website / Form URL',
              hintText: 'https://careers.example.com/apply',
              prefixIcon: Icons.link_rounded,
              keyboardType: TextInputType.url,
              validator: (v) {
                if (v == null || v.trim().isEmpty) return 'Target URL is required';
                if (!v.startsWith('http://') && !v.startsWith('https://')) {
                  return 'Please include http:// or https:// in the URL';
                }
                return null;
              },
            ),

            const SizedBox(height: 16),

            // Notes
            CustomTextField(
              controller: _notesController,
              labelText: 'Task Notes / Instructions (Optional)',
              hintText: 'Add custom reminders or required fields...',
              prefixIcon: Icons.notes_outlined,
              maxLines: 2,
            ),

            const SizedBox(height: 24),

            // Allowed Profile Information
            Text(
              'Information Permitted for this Task',
              style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 4),
            Text(
              'Only selected data categories will be made available to the field matcher.',
              style: TextStyle(
                fontSize: 12,
                color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
              ),
            ),
            const SizedBox(height: 12),

            Container(
              decoration: BoxDecoration(
                color: isDark ? AppColors.surfaceDark : Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: isDark ? AppColors.dividerDark : AppColors.dividerLight,
                ),
              ),
              child: Column(
                children: _allowedCategories.keys.map((cat) {
                  return CheckboxListTile(
                    title: Text(cat, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
                    value: _allowedCategories[cat],
                    activeColor: AppColors.primary,
                    dense: true,
                    onChanged: (val) {
                      setState(() {
                        _allowedCategories[cat] = val ?? false;
                      });
                    },
                  );
                }).toList(),
              ),
            ),

            const SizedBox(height: 32),

            // Action Buttons
            ElevatedButton.icon(
              onPressed: _saveAndLaunchAssistant,
              icon: const Icon(Icons.rocket_launch_rounded),
              label: const Text('Save & Launch Form Assistant', style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
              ),
            ),
            const SizedBox(height: 12),
            OutlinedButton(
              onPressed: _saveTaskOnly,
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
              ),
              child: const Text('Save Task for Later'),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}
