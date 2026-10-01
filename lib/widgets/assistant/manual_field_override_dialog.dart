import 'package:flutter/material.dart';
import '../../models/form_field_match.dart';
import '../../models/user_profile.dart';
import '../../core/constants/app_colors.dart';

class ManualFieldOverrideDialog extends StatefulWidget {
  final FormFieldMatch match;
  final UserProfile profile;

  const ManualFieldOverrideDialog({
    Key? key,
    required this.match,
    required this.profile,
  }) : super(key: key);

  @override
  State<ManualFieldOverrideDialog> createState() => _ManualFieldOverrideDialogState();
}

class _ManualFieldOverrideDialogState extends State<ManualFieldOverrideDialog> {
  late TextEditingController _customController;
  String? _selectedProfileValue;

  @override
  void initState() {
    super.initState();
    _customController = TextEditingController(text: widget.match.effectiveFillValue);
  }

  @override
  void dispose() {
    _customController.dispose();
    super.dispose();
  }

  List<Map<String, String>> _getAvailableProfileOptions() {
    final options = <Map<String, String>>[];
    final p = widget.profile.personalInfo;
    final prof = widget.profile.professionalInfo;

    if (p.firstName.isNotEmpty) options.add({'label': 'First Name', 'value': p.firstName});
    if (p.lastName.isNotEmpty) options.add({'label': 'Last Name', 'value': p.lastName});
    if (p.fullName.isNotEmpty) options.add({'label': 'Full Name', 'value': p.fullName});
    if (p.email.isNotEmpty) options.add({'label': 'Email', 'value': p.email});
    if (p.phone.isNotEmpty) options.add({'label': 'Phone', 'value': p.phone});
    if (p.country.isNotEmpty) options.add({'label': 'Country', 'value': p.country});
    if (p.city.isNotEmpty) options.add({'label': 'City', 'value': p.city});
    if (p.address.isNotEmpty) options.add({'label': 'Address', 'value': p.address});
    if (p.postalCode.isNotEmpty) options.add({'label': 'Postal Code', 'value': p.postalCode});
    if (prof.professionalTitle.isNotEmpty) options.add({'label': 'Job Title', 'value': prof.professionalTitle});
    if (prof.overviewBio.isNotEmpty) options.add({'label': 'Overview / Bio', 'value': prof.overviewBio});
    if (prof.hourlyRate.isNotEmpty) options.add({'label': 'Hourly Rate', 'value': prof.hourlyRate});
    if (prof.skills.isNotEmpty) options.add({'label': 'Skills', 'value': prof.skills.join(', ')});

    return options;
  }

  @override
  Widget build(BuildContext context) {
    final profileOptions = _getAvailableProfileOptions();

    return AlertDialog(
      title: Text('Select Value for "${widget.match.displayIdentifier}"'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Choose from your saved profile or type a custom real value:',
              style: TextStyle(fontSize: 13, color: AppColors.textSecondaryLight),
            ),
            const SizedBox(height: 12),
            if (profileOptions.isNotEmpty) ...[
              const Text(
                'Saved Profile Values:',
                style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 6),
              Container(
                decoration: BoxDecoration(
                  border: Border.all(color: AppColors.dividerLight),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: DropdownButtonFormField<String>(
                  value: _selectedProfileValue,
                  decoration: const InputDecoration(
                    contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    border: InputBorder.none,
                  ),
                  hint: const Text('Pick a profile attribute'),
                  items: profileOptions.map((opt) {
                    return DropdownMenuItem<String>(
                      value: opt['value'],
                      child: Text('${opt['label']}: ${opt['value']}', overflow: TextOverflow.ellipsis),
                    );
                  }).toList(),
                  onChanged: (val) {
                    if (val != null) {
                      setState(() {
                        _selectedProfileValue = val;
                        _customController.text = val;
                      });
                    }
                  },
                ),
              ),
              const SizedBox(height: 16),
            ],
            const Text(
              'Or Enter Custom Real Value:',
              style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 6),
            TextField(
              controller: _customController,
              decoration: const InputDecoration(
                hintText: 'Enter real value to fill...',
              ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(null),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: () {
            Navigator.of(context).pop(_customController.text.trim());
          },
          child: const Text('Apply Value'),
        ),
      ],
    );
  }
}
