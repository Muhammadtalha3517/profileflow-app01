import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../models/education.dart';
import '../../providers/profile_provider.dart';
import '../../widgets/forms/custom_text_field.dart';

class ManageEducationScreen extends StatelessWidget {
  const ManageEducationScreen({Key? key}) : super(key: key);

  void _showEducationDialog(BuildContext context, {Education? existing, int? index}) {
    final instController = TextEditingController(text: existing?.institution ?? '');
    final degController = TextEditingController(text: existing?.degree ?? '');
    final fieldController = TextEditingController(text: existing?.fieldOfStudy ?? '');
    final startController = TextEditingController(text: existing?.startDate ?? '');
    final endController = TextEditingController(text: existing?.endDate ?? '');
    final descController = TextEditingController(text: existing?.description ?? '');

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(existing == null ? 'Add Education' : 'Edit Education'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CustomTextField(
                controller: instController,
                labelText: 'Institution / University',
                hintText: 'e.g. MIT / Harvard University',
                prefixIcon: Icons.account_balance_outlined,
              ),
              const SizedBox(height: 12),
              CustomTextField(
                controller: degController,
                labelText: 'Degree',
                hintText: 'e.g. Bachelor of Science',
                prefixIcon: Icons.school_outlined,
              ),
              const SizedBox(height: 12),
              CustomTextField(
                controller: fieldController,
                labelText: 'Field of Study / Major',
                hintText: 'e.g. Software Engineering',
                prefixIcon: Icons.menu_book_outlined,
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: CustomTextField(
                      controller: startController,
                      labelText: 'Start Year',
                      hintText: '2018',
                      prefixIcon: Icons.calendar_today_outlined,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: CustomTextField(
                      controller: endController,
                      labelText: 'Graduation Year',
                      hintText: '2022',
                      prefixIcon: Icons.event_outlined,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              CustomTextField(
                controller: descController,
                labelText: 'Description / Honors',
                hintText: 'Relevant coursework, honors, GPA...',
                maxLines: 3,
                prefixIcon: Icons.notes_outlined,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              if (instController.text.trim().isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Institution name is required.')),
                );
                return;
              }

              final provider = context.read<ProfileProvider>();
              final item = Education(
                id: existing?.id ?? DateTime.now().millisecondsSinceEpoch.toString(),
                institution: instController.text.trim(),
                degree: degController.text.trim(),
                fieldOfStudy: fieldController.text.trim(),
                startDate: startController.text.trim(),
                endDate: endController.text.trim(),
                description: descController.text.trim(),
              );

              if (existing != null && index != null) {
                await provider.updateEducation(index, item);
              } else {
                await provider.addEducation(item);
              }

              if (ctx.mounted) {
                Navigator.pop(ctx);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(existing == null ? 'Education entry added!' : 'Education updated!'),
                    backgroundColor: AppColors.success,
                  ),
                );
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
            ),
            child: Text(existing == null ? 'Add' : 'Save Changes'),
          ),
        ],
      ),
    );
  }

  void _confirmDelete(BuildContext context, int index, String institution) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Education?'),
        content: Text('Are you sure you want to remove "$institution"?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () async {
              await context.read<ProfileProvider>().removeEducation(index);
              if (ctx.mounted) {
                Navigator.pop(ctx);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Education entry removed.')),
                );
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.error),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final educations = context.watch<ProfileProvider>().profile.educations;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Education'),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showEducationDialog(context),
        icon: const Icon(Icons.add),
        label: const Text('Add Education'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
      ),
      body: educations.isEmpty
          ? Center(
              child: Padding(
                padding: const EdgeInsets.all(32.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: AppColors.secondary.withOpacity(0.1),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.school_outlined, size: 48, color: AppColors.secondary),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'No Education Added',
                      style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Add your degrees, universities, and certificates to complete your educational background.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                      ),
                    ),
                    const SizedBox(height: 24),
                    ElevatedButton.icon(
                      onPressed: () => _showEducationDialog(context),
                      icon: const Icon(Icons.add),
                      label: const Text('Add Education Entry'),
                    ),
                  ],
                ),
              ),
            )
          : ListView.separated(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 80),
              itemCount: educations.length,
              separatorBuilder: (_, __) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                final edu = educations[index];
                return Card(
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                    side: BorderSide(
                      color: isDark ? AppColors.dividerDark : AppColors.dividerLight,
                    ),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                color: AppColors.secondary.withOpacity(0.12),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: const Icon(Icons.school, color: AppColors.secondary, size: 22),
                            ),
                            const SizedBox(width: 14),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    edu.institution,
                                    style: theme.textTheme.titleMedium?.copyWith(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    edu.degreeAndField,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.w600,
                                      color: AppColors.primary,
                                      fontSize: 14,
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    '${edu.startDate} - ${edu.endDate}',
                                    style: theme.textTheme.bodySmall?.copyWith(
                                      color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            PopupMenuButton<String>(
                              icon: const Icon(Icons.more_vert),
                              onSelected: (val) {
                                if (val == 'edit') {
                                  _showEducationDialog(context, existing: edu, index: index);
                                } else if (val == 'delete') {
                                  _confirmDelete(context, index, edu.institution);
                                }
                              },
                              itemBuilder: (_) => [
                                const PopupMenuItem(
                                  value: 'edit',
                                  child: Row(
                                    children: [
                                      Icon(Icons.edit_outlined, size: 18),
                                      SizedBox(width: 8),
                                      Text('Edit'),
                                    ],
                                  ),
                                ),
                                const PopupMenuItem(
                                  value: 'delete',
                                  child: Row(
                                    children: [
                                      Icon(Icons.delete_outline, color: AppColors.error, size: 18),
                                      SizedBox(width: 8),
                                      Text('Delete', style: TextStyle(color: AppColors.error)),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                        if (edu.description.isNotEmpty) ...[
                          const SizedBox(height: 12),
                          const Divider(height: 1),
                          const SizedBox(height: 10),
                          Text(
                            edu.description,
                            style: theme.textTheme.bodyMedium?.copyWith(height: 1.4),
                          ),
                        ],
                      ],
                    ),
                  ),
                );
              },
            ),
    );
  }
}
