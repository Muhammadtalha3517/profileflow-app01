import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';

class SectionSummaryCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String summary;
  final bool isComplete;
  final VoidCallback onEdit;

  const SectionSummaryCard({
    Key? key,
    required this.icon,
    required this.title,
    required this.summary,
    required this.isComplete,
    required this.onEdit,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Card(
      elevation: 0,
      margin: const EdgeInsets.symmetric(vertical: 6),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(
          color: isComplete
              ? (isDark ? AppColors.dividerDark : AppColors.dividerLight)
              : AppColors.warning.withOpacity(0.4),
          width: 1,
        ),
      ),
      child: InkWell(
        onTap: onEdit,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: isComplete
                      ? AppColors.primary.withOpacity(0.1)
                      : AppColors.warning.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  icon,
                  color: isComplete ? AppColors.primary : AppColors.warning,
                  size: 22,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          title,
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(width: 8),
                        if (!isComplete)
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: AppColors.warningBg,
                              borderRadius: BorderRadius.circular(6),
                              border: Border.all(color: AppColors.warning.withOpacity(0.3), width: 1),
                            ),
                            child: const Text(
                              'Incomplete',
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.w600,
                                color: AppColors.warning,
                              ),
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      summary.isNotEmpty ? summary : 'Not provided yet',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: summary.isNotEmpty
                            ? (isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight)
                            : AppColors.textTertiaryLight,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              IconButton(
                icon: const Icon(Icons.edit_outlined, size: 20),
                color: AppColors.primary,
                tooltip: 'Edit $title',
                onPressed: onEdit,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
