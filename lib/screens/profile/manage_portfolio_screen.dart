import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../models/portfolio_item.dart';
import '../../providers/profile_provider.dart';
import '../../widgets/forms/custom_text_field.dart';

class ManagePortfolioScreen extends StatelessWidget {
  const ManagePortfolioScreen({Key? key}) : super(key: key);

  void _showPortfolioDialog(BuildContext context, {PortfolioItem? existing, int? index}) {
    final nameController = TextEditingController(text: existing?.projectName ?? '');
    final descController = TextEditingController(text: existing?.projectDescription ?? '');
    final urlController = TextEditingController(text: existing?.projectUrl ?? '');
    final skillsController = TextEditingController(text: existing?.skillsUsed.join(', ') ?? '');

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(existing == null ? 'Add Portfolio Item' : 'Edit Portfolio Item'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CustomTextField(
                controller: nameController,
                labelText: 'Project / Product Name',
                hintText: 'e.g. Flutter E-Commerce Platform',
                prefixIcon: Icons.folder_outlined,
              ),
              const SizedBox(height: 12),
              CustomTextField(
                controller: urlController,
                labelText: 'Project URL / Repository',
                hintText: 'https://github.com/username/project',
                prefixIcon: Icons.link_outlined,
                keyboardType: TextInputType.url,
              ),
              const SizedBox(height: 12),
              CustomTextField(
                controller: skillsController,
                labelText: 'Skills Used (Comma-separated)',
                hintText: 'Flutter, Dart, GraphQL, Firebase',
                prefixIcon: Icons.code_outlined,
              ),
              const SizedBox(height: 12),
              CustomTextField(
                controller: descController,
                labelText: 'Description & Features',
                hintText: 'Describe key features, role, architecture...',
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
              if (nameController.text.trim().isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Project Name is required.')),
                );
                return;
              }

              final skillsList = skillsController.text
                  .split(',')
                  .map((s) => s.trim())
                  .where((s) => s.isNotEmpty)
                  .toList();

              final provider = context.read<ProfileProvider>();
              final item = PortfolioItem(
                id: existing?.id ?? DateTime.now().millisecondsSinceEpoch.toString(),
                projectName: nameController.text.trim(),
                projectDescription: descController.text.trim(),
                projectUrl: urlController.text.trim(),
                skillsUsed: skillsList,
                imageUrls: existing?.imageUrls ?? const [],
              );

              if (existing != null && index != null) {
                await provider.updatePortfolioItem(index, item);
              } else {
                await provider.addPortfolioItem(item);
              }

              if (ctx.mounted) {
                Navigator.pop(ctx);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(existing == null ? 'Portfolio project added!' : 'Portfolio project updated!'),
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

  void _confirmDelete(BuildContext context, int index, String projectName) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Portfolio Item?'),
        content: Text('Are you sure you want to remove "$projectName"?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () async {
              await context.read<ProfileProvider>().removePortfolioItem(index);
              if (ctx.mounted) {
                Navigator.pop(ctx);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Portfolio item removed.')),
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
    final portfolioItems = context.watch<ProfileProvider>().profile.portfolioItems;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Portfolio & Projects'),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showPortfolioDialog(context),
        icon: const Icon(Icons.add),
        label: const Text('Add Project'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
      ),
      body: portfolioItems.isEmpty
          ? Center(
              child: Padding(
                padding: const EdgeInsets.all(32.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: AppColors.accent.withOpacity(0.1),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.folder_special_outlined, size: 48, color: AppColors.accent),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'No Projects Recorded',
                      style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Showcase your best projects, portfolio URLs, and technical skill sets.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                      ),
                    ),
                    const SizedBox(height: 24),
                    ElevatedButton.icon(
                      onPressed: () => _showPortfolioDialog(context),
                      icon: const Icon(Icons.add),
                      label: const Text('Add First Project'),
                    ),
                  ],
                ),
              ),
            )
          : ListView.separated(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 80),
              itemCount: portfolioItems.length,
              separatorBuilder: (_, __) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                final item = portfolioItems[index];
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
                                color: AppColors.accent.withOpacity(0.12),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: const Icon(Icons.code_rounded, color: AppColors.accent, size: 22),
                            ),
                            const SizedBox(width: 14),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    item.projectName,
                                    style: theme.textTheme.titleMedium?.copyWith(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  if (item.projectUrl.isNotEmpty) ...[
                                    const SizedBox(height: 2),
                                    Text(
                                      item.projectUrl,
                                      style: const TextStyle(
                                        color: AppColors.primary,
                                        fontSize: 13,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ],
                                ],
                              ),
                            ),
                            PopupMenuButton<String>(
                              icon: const Icon(Icons.more_vert),
                              onSelected: (val) {
                                if (val == 'edit') {
                                  _showPortfolioDialog(context, existing: item, index: index);
                                } else if (val == 'delete') {
                                  _confirmDelete(context, index, item.projectName);
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
                        if (item.projectDescription.isNotEmpty) ...[
                          const SizedBox(height: 10),
                          Text(
                            item.projectDescription,
                            style: theme.textTheme.bodyMedium?.copyWith(height: 1.4),
                          ),
                        ],
                        if (item.skillsUsed.isNotEmpty) ...[
                          const SizedBox(height: 12),
                          Wrap(
                            spacing: 6,
                            runSpacing: 6,
                            children: item.skillsUsed.map((s) {
                              return Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                decoration: BoxDecoration(
                                  color: AppColors.primaryLight.withOpacity(0.3),
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: Text(
                                  s,
                                  style: const TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w600,
                                    color: AppColors.primaryDark,
                                  ),
                                ),
                              );
                            }).toList(),
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
