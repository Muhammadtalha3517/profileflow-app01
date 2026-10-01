import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../models/professional_info.dart';
import '../../providers/profile_provider.dart';
import '../../widgets/forms/custom_text_field.dart';

class EditProfessionalScreen extends StatefulWidget {
  const EditProfessionalScreen({Key? key}) : super(key: key);

  @override
  State<EditProfessionalScreen> createState() => _EditProfessionalScreenState();
}

class _EditProfessionalScreenState extends State<EditProfessionalScreen> {
  final _formKey = GlobalKey<FormState>();

  late TextEditingController _titleController;
  late TextEditingController _bioController;
  late TextEditingController _rateController;
  late TextEditingController _currencyController;
  late TextEditingController _skillsInputController;
  late TextEditingController _languagesInputController;
  late TextEditingController _yearsExpController;

  late List<String> _skills;
  late List<String> _languages;
  bool _isDirty = false;

  @override
  void initState() {
    super.initState();
    final prof = context.read<ProfileProvider>().profile.professionalInfo;
    _titleController = TextEditingController(text: prof.professionalTitle);
    _bioController = TextEditingController(text: prof.overviewBio);
    _rateController = TextEditingController(text: prof.hourlyRate);
    _currencyController = TextEditingController(text: prof.currency.isNotEmpty ? prof.currency : 'USD (\$)');
    _yearsExpController = TextEditingController(text: prof.yearsOfExperience);
    _skillsInputController = TextEditingController();
    _languagesInputController = TextEditingController();

    _skills = List<String>.from(prof.skills);
    _languages = List<String>.from(prof.languages);

    for (final c in [_titleController, _bioController, _rateController, _currencyController, _yearsExpController]) {
      c.addListener(_markDirty);
    }
  }

  void _markDirty() {
    if (!_isDirty) {
      setState(() {
        _isDirty = true;
      });
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _bioController.dispose();
    _rateController.dispose();
    _currencyController.dispose();
    _yearsExpController.dispose();
    _skillsInputController.dispose();
    _languagesInputController.dispose();
    super.dispose();
  }

  void _addSkill() {
    final text = _skillsInputController.text.trim();
    if (text.isNotEmpty && !_skills.contains(text)) {
      setState(() {
        _skills.add(text);
        _skillsInputController.clear();
        _isDirty = true;
      });
    }
  }

  void _addLanguage() {
    final text = _languagesInputController.text.trim();
    if (text.isNotEmpty && !_languages.contains(text)) {
      setState(() {
        _languages.add(text);
        _languagesInputController.clear();
        _isDirty = true;
      });
    }
  }

  Future<void> _saveChanges() async {
    if (_formKey.currentState?.validate() ?? false) {
      final updatedProf = ProfessionalInfo(
        professionalTitle: _titleController.text.trim(),
        overviewBio: _bioController.text.trim(),
        hourlyRate: _rateController.text.trim(),
        currency: _currencyController.text.trim(),
        skills: _skills,
        languages: _languages,
        yearsOfExperience: _yearsExpController.text.trim(),
      );

      await context.read<ProfileProvider>().updateProfessionalInfo(updatedProf);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Row(
              children: [
                Icon(Icons.check_circle, color: Colors.white),
                SizedBox(width: 8),
                Text('Professional information saved successfully!'),
              ],
            ),
            backgroundColor: AppColors.success,
          ),
        );
        Navigator.pop(context);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Professional Details'),
        actions: [
          IconButton(
            icon: const Icon(Icons.check_rounded),
            tooltip: 'Save',
            onPressed: _saveChanges,
          ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            CustomTextField(
              controller: _titleController,
              labelText: 'Professional Title / Headline',
              hintText: 'e.g., Senior Full Stack Engineer',
              prefixIcon: Icons.work_outline,
            ),
            const SizedBox(height: 16),
            CustomTextField(
              controller: _bioController,
              labelText: 'Professional Overview / Bio',
              hintText: 'Describe your expertise, focus areas, and achievements...',
              prefixIcon: Icons.description_outlined,
              maxLines: 4,
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  flex: 2,
                  child: CustomTextField(
                    controller: _rateController,
                    labelText: 'Hourly Rate',
                    hintText: 'e.g., 75',
                    prefixIcon: Icons.attach_money_outlined,
                    keyboardType: TextInputType.number,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  flex: 1,
                  child: CustomTextField(
                    controller: _currencyController,
                    labelText: 'Currency',
                    hintText: 'USD',
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            CustomTextField(
              controller: _yearsExpController,
              labelText: 'Years of Experience',
              hintText: 'e.g., 8 Years',
              prefixIcon: Icons.timeline_outlined,
            ),
            const SizedBox(height: 24),

            // Skills Section
            const Text(
              'Skills & Technologies',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: CustomTextField(
                    controller: _skillsInputController,
                    labelText: 'Add Skill',
                    hintText: 'e.g., Flutter, Kotlin, TypeScript',
                    prefixIcon: Icons.stars_outlined,
                    onSubmitted: (_) => _addSkill(),
                  ),
                ),
                const SizedBox(width: 8),
                IconButton.filled(
                  onPressed: _addSkill,
                  icon: const Icon(Icons.add),
                  style: IconButton.styleFrom(backgroundColor: AppColors.primary),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: _skills.map((skill) {
                return Chip(
                  label: Text(skill),
                  deleteIcon: const Icon(Icons.close, size: 16),
                  onDeleted: () {
                    setState(() {
                      _skills.remove(skill);
                      _isDirty = true;
                    });
                  },
                  backgroundColor: AppColors.primaryLight.withOpacity(0.35),
                );
              }).toList(),
            ),

            const SizedBox(height: 24),

            // Languages Section
            const Text(
              'Languages',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: CustomTextField(
                    controller: _languagesInputController,
                    labelText: 'Add Language',
                    hintText: 'e.g., English, Spanish, German',
                    prefixIcon: Icons.language_outlined,
                    onSubmitted: (_) => _addLanguage(),
                  ),
                ),
                const SizedBox(width: 8),
                IconButton.filled(
                  onPressed: _addLanguage,
                  icon: const Icon(Icons.add),
                  style: IconButton.styleFrom(backgroundColor: AppColors.secondary),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: _languages.map((lang) {
                return Chip(
                  label: Text(lang),
                  deleteIcon: const Icon(Icons.close, size: 16),
                  onDeleted: () {
                    setState(() {
                      _languages.remove(lang);
                      _isDirty = true;
                    });
                  },
                  backgroundColor: AppColors.secondaryLight.withOpacity(0.35),
                );
              }).toList(),
            ),

            const SizedBox(height: 32),
            ElevatedButton.icon(
              onPressed: _saveChanges,
              icon: const Icon(Icons.save_rounded),
              label: const Text('Save Changes', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}
