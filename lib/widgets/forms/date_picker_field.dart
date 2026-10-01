import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../core/utils/date_formatter.dart';

class DatePickerField extends StatelessWidget {
  final String label;
  final DateTime? selectedDate;
  final ValueChanged<DateTime?> onDateSelected;
  final bool isRequired;

  const DatePickerField({
    Key? key,
    required this.label,
    required this.selectedDate,
    required this.onDateSelected,
    this.isRequired = false,
  }) : super(key: key);

  Future<void> _pickDate(BuildContext context) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: selectedDate ?? DateTime.now(),
      firstDate: DateTime(1960),
      lastDate: DateTime(2035),
    );
    if (picked != null) {
      onDateSelected(picked);
    }
  }

  @override
  Widget build(BuildContext context) {
    final formatted = DateFormatter.formatMonthYear(selectedDate);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                label,
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimaryLight,
                ),
              ),
              if (isRequired) ...[
                const SizedBox(width: 4),
                const Text(
                  '*',
                  style: TextStyle(color: AppColors.error, fontWeight: FontWeight.bold),
                ),
              ],
            ],
          ),
          const SizedBox(height: 6),
          InkWell(
            onTap: () => _pickDate(context),
            borderRadius: BorderRadius.circular(12),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.dividerLight),
              ),
              child: Row(
                children: [
                  const Icon(Icons.calendar_today_outlined, size: 18, color: AppColors.textSecondaryLight),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      formatted.isNotEmpty ? formatted : 'Select Date',
                      style: TextStyle(
                        fontSize: 14,
                        color: formatted.isNotEmpty ? AppColors.textPrimaryLight : AppColors.textTertiaryLight,
                      ),
                    ),
                  ),
                  if (selectedDate != null)
                    IconButton(
                      icon: const Icon(Icons.clear, size: 16),
                      onPressed: () => onDateSelected(null),
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
