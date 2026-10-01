import 'package:flutter/material.dart';
import '../../models/form_field_match.dart';
import '../../models/user_profile.dart';
import '../../core/constants/app_colors.dart';
import 'manual_field_override_dialog.dart';

class FieldReviewSheet extends StatelessWidget {
  final List<FormFieldMatch> matches;
  final UserProfile profile;
  final Function(int index, bool selected) onToggleSelection;
  final Function(int index, String newValue) onUpdateOverride;
  final Function(bool selectAll) onSelectAll;
  final VoidCallback onFillApproved;
  final VoidCallback onCancel;

  const FieldReviewSheet({
    Key? key,
    required this.matches,
    required this.profile,
    required this.onToggleSelection,
    required this.onUpdateOverride,
    required this.onSelectAll,
    required this.onFillApproved,
    required this.onCancel,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final approvedCount = matches.where((m) => m.isSelected && m.effectiveFillValue.isNotEmpty).length;

    return Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.85,
      ),
      decoration: BoxDecoration(
        color: isDark ? AppColors.surfaceDark : Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Drag Handle
          const SizedBox(height: 12),
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: AppColors.dividerLight,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 12),

          // Header
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'CURRENT STEP',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1.2,
                        color: AppColors.primary,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '$approvedCount of ${matches.length} fields selected',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                TextButton(
                  onPressed: () {
                    final allSelected = matches.every((m) => m.isSelected);
                    onSelectAll(!allSelected);
                  },
                  child: Text(
                    matches.every((m) => m.isSelected) ? 'Deselect All' : 'Select All',
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                ),
              ],
            ),
          ),
          const Divider(),

          // Field list
          Flexible(
            child: ListView.separated(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              shrinkWrap: true,
              itemCount: matches.length,
              separatorBuilder: (_, __) => const SizedBox(height: 8),
              itemBuilder: (context, index) {
                final match = matches[index];
                return _buildFieldCard(context, match, index);
              },
            ),
          ),

          const Divider(),

          // Bottom Action Buttons
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
            child: Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: onCancel,
                    child: const Text('Cancel'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  flex: 2,
                  child: ElevatedButton.icon(
                    icon: const Icon(Icons.auto_fix_high, size: 18),
                    label: Text(approvedCount > 0 ? 'Fill $approvedCount Fields' : 'Fill Fields'),
                    onPressed: approvedCount > 0 ? onFillApproved : null,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFieldCard(BuildContext context, FormFieldMatch match, int index) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    Color badgeColor;
    IconData badgeIcon;
    String badgeText;

    switch (match.confidence) {
      case MatchConfidence.high:
        badgeColor = AppColors.confidenceHigh;
        badgeIcon = Icons.check_circle;
        badgeText = 'High Confidence';
        break;
      case MatchConfidence.medium:
        badgeColor = AppColors.confidenceMedium;
        badgeIcon = Icons.warning_amber;
        badgeText = 'Review Recommended';
        break;
      case MatchConfidence.uncertain:
      default:
        badgeColor = AppColors.confidenceUncertain;
        badgeIcon = Icons.help_outline;
        badgeText = 'Uncertain Match';
        break;
    }

    final hasValue = match.effectiveFillValue.isNotEmpty;

    return Container(
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF162032) : const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: match.isSelected
              ? AppColors.primary.withOpacity(0.5)
              : (isDark ? AppColors.dividerDark : AppColors.dividerLight),
          width: match.isSelected ? 1.5 : 1,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Checkbox(
                  value: match.isSelected,
                  activeColor: AppColors.primary,
                  onChanged: hasValue
                      ? (val) => onToggleSelection(index, val ?? false)
                      : null,
                ),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              match.displayIdentifier,
                              style: theme.textTheme.titleMedium?.copyWith(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: badgeColor.withOpacity(0.12),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(badgeIcon, size: 11, color: badgeColor),
                                const SizedBox(width: 4),
                                Text(
                                  badgeText,
                                  style: TextStyle(
                                    fontSize: 10,
                                    fontWeight: FontWeight.w600,
                                    color: badgeColor,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      if (hasValue)
                        Row(
                          children: [
                            const Text(
                              'Value: ',
                              style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: AppColors.primary),
                            ),
                            Expanded(
                              child: Text(
                                match.effectiveFillValue,
                                style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        )
                      else
                        const Text(
                          'Information not available in your profile.',
                          style: TextStyle(fontSize: 12, color: AppColors.error, fontStyle: FontStyle.italic),
                        ),
                    ],
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.edit_note, size: 22, color: AppColors.primary),
                  tooltip: 'Change value',
                  onPressed: () async {
                    final newVal = await showDialog<String>(
                      context: context,
                      builder: (_) => ManualFieldOverrideDialog(
                        match: match,
                        profile: profile,
                      ),
                    );
                    if (newVal != null) {
                      onUpdateOverride(index, newVal);
                    }
                  },
                ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.only(left: 48, top: 2),
              child: Text(
                match.reasoning,
                style: TextStyle(
                  fontSize: 11,
                  color: isDark ? AppColors.textTertiaryDark : AppColors.textTertiaryLight,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
