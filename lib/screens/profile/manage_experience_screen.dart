import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../models/work_experience.dart';
import '../../providers/profile_provider.dart';
import '../../widgets/forms/custom_text_field.dart';

class ManageExperienceScreen extends StatelessWidget {
  const ManageExperienceScreen({Key? key}) : super(key: key);

  void _showExperienceDialog(BuildContext context, {WorkExperience? existing, int? index}) {
    final compController = TextEditingController(text: existing?.company ?? '');
    final roleController = TextEditingController(text: existing?.jobTitle ?? '');
    final startController = TextEditingController(text: existing?.startDate ?? '');
    final endController = TextEditingController(text: existing?.endDate ?? '');
    final descController = TextEditingController(text: existing?.description ?? '');

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(existing == null ? 'Add Work Experience' : 'Edit Work Experience'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CustomTextField(
                controller: compController,
                labelText: 'Company Name',
                hintText: 'e.g. Google',
                prefixIcon: Icons.business_outlined,
              ),
              const SizedBox(height: 12),
              CustomTextField(
                controller: roleController,
                labelText: 'Job Title',
                hintText: 'e.g. Senior Software Engineer',
                prefixIcon: Icons.badge_outlined,
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: CustomTextField(
                      controller: startController,
                      labelText: 'Start Date',
                      hintText: '2021-03',
                      prefixIcon: Icons.calendar_today_outlined,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: CustomTextField(
                      controller: endController,
                      labelText: 'End Date',
                      hintText: 'Present',
                      prefixIcon: Icons.event_outlined,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              CustomTextField(
                controller: descController,
                labelText: 'Description & Achievements',
                hintText: 'Responsibilities, technologies, team impact...',
                maxLines: 4,
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
              if (compController.text.trim().isEmpty || roleController.text.trim().isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Company and Job Title are required.')),
                );
                return;
              }

              final provider = context.read<ProfileProvider>();
              final item = WorkExperience(
                id: existing?.id ?? DateTime.now().millisecondsSinceEpoch.toString(),
                company: compController.text.trim(),
                jobTitle: roleController.text.trim(),
                startDate: startController.text.trim(),
                endDate: endController.text.trim(),
                description: descController.text.trim(),
              );

              if (existing != null && index != null) {
                await provider.updateExperience(index, item);
              } else {
                await provider.addExperience(item);
              }

              if (ctx.mounted) {
                Navigator.pop(ctx);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(existing == null ? 'Experience added!' : 'Experience updated!'),
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

  void _confirmDelete(BuildContext context, int index, String company) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Experience?'),
        content: Text('Are you sure you want to remove your experience at "$company"?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () async {
              await context.read<ProfileProvider>().removeExperience(index);
              if (ctx.mounted) {
                Navigator.pop(ctx);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Experience entry removed.')),
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
    final experiences = context.watch<ProfileProvider>().profile.experiences;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Work Experience'),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showExperienceDialog(context),
        icon: const Icon(Icons.add),
        label: const Text('Add Experience'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
      ),
      body: experiences.isEmpty
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
                      child: const Icon(Icons.business_center_outlined, size: 48, color: AppColors.primary),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'No Work History',
                      style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Add your previous positions to help fill job applications effortlessly.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                      ),
                    ),
                    const SizedBox(height: 24),
                    ElevatedButton.icon(
                      onPressed: () => _showExperienceDialog(context),
                      icon: const Icon(Icons.add),
                      label: const Text('Add First Position'),
                    ),
                  ],
                ),
              ),
            )
          : ListView.separated(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 80),
              itemCount: experiences.length,
              separatorBuilder: (_, __) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                final exp = experiences[index];
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
                                color: AppColors.primary.withOpacity(0.12),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: const Icon(Icons.business, color: AppColors.primary, size: 22),
                            ),
                            const SizedBox(width: 14),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    exp.jobTitle,
                                    style: theme.textTheme.titleMedium?.copyWith(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    exp.company,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.w600,
                                      color: AppColors.primary,
                                      fontSize: 14,
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    '${exp.startDate} - ${exp.endDate}',
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
                                  _showExperienceDialog(context, existing: exp, index: index);
                                } else if (val == 'delete') {
                                  _confirmDelete(context, index, exp.company);
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
                        if (exp.description.isNotEmpty) ...[
                          const SizedBox(height: 12),
                          const Divider(height: 1),
                          const SizedBox(height: 10),
                          Text(
                            exp.description,
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
