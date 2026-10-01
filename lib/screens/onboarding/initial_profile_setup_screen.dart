import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import '../../core/constants/app_colors.dart';
import '../../models/user_profile.dart';
import '../../models/personal_info.dart';
import '../../models/professional_info.dart';
import '../../models/work_experience.dart';
import '../../models/education.dart';
import '../../models/portfolio_item.dart';
import '../../providers/profile_provider.dart';
import '../../widgets/forms/custom_text_field.dart';
import '../navigation/main_navigation_screen.dart';

class InitialProfileSetupScreen extends StatefulWidget {
  const InitialProfileSetupScreen({Key? key}) : super(key: key);

  @override
  State<InitialProfileSetupScreen> createState() => _InitialProfileSetupScreenState();
}

class _InitialProfileSetupScreenState extends State<InitialProfileSetupScreen> {
  int _currentStep = 0;
  final int _totalSteps = 5;

  // Step 1: Personal
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _fullNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _countryController = TextEditingController();
  final _cityController = TextEditingController();
  final _addressController = TextEditingController();
  final _postalCodeController = TextEditingController();

  // Step 2: Professional
  final _titleController = TextEditingController();
  final _bioController = TextEditingController();
  final _rateController = TextEditingController();
  final _currencyController = TextEditingController(text: 'USD (\$)');
  final _skillsController = TextEditingController();
  final List<String> _skills = [];
  final _languagesController = TextEditingController();
  final List<String> _languages = [];
  final _experienceYearsController = TextEditingController();

  // Step 3: Work Experience
  final List<WorkExperience> _experiences = [];

  // Step 4: Education
  final List<Education> _educations = [];

  // Step 5: Portfolio & Documents
  final List<PortfolioItem> _portfolioItems = [];
  String _profilePhotoPath = '';
  final List<String> _documentPaths = [];

  final ImagePicker _imagePicker = ImagePicker();

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _fullNameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _countryController.dispose();
    _cityController.dispose();
    _addressController.dispose();
    _postalCodeController.dispose();

    _titleController.dispose();
    _bioController.dispose();
    _rateController.dispose();
    _currencyController.dispose();
    _skillsController.dispose();
    _languagesController.dispose();
    _experienceYearsController.dispose();
    super.dispose();
  }

  void _addSkill() {
    final text = _skillsController.text.trim();
    if (text.isNotEmpty && !_skills.contains(text)) {
      setState(() {
        _skills.add(text);
        _skillsController.clear();
      });
    }
  }

  void _addLanguage() {
    final text = _languagesController.text.trim();
    if (text.isNotEmpty && !_languages.contains(text)) {
      setState(() {
        _languages.add(text);
        _languagesController.clear();
      });
    }
  }

  Future<void> _pickProfilePhoto() async {
    try {
      final XFile? image = await _imagePicker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 800,
        maxHeight: 800,
        imageQuality: 85,
      );
      if (image != null) {
        setState(() {
          _profilePhotoPath = image.path;
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Could not select image: $e')),
      );
    }
  }

  Future<void> _saveAndFinish() async {
    final profileProvider = context.read<ProfileProvider>();

    final personalInfo = PersonalInfo(
      firstName: _firstNameController.text.trim(),
      lastName: _lastNameController.text.trim(),
      fullName: _fullNameController.text.trim().isNotEmpty
          ? _fullNameController.text.trim()
          : '${_firstNameController.text.trim()} ${_lastNameController.text.trim()}'.trim(),
      email: _emailController.text.trim(),
      phone: _phoneController.text.trim(),
      country: _countryController.text.trim(),
      city: _cityController.text.trim(),
      address: _addressController.text.trim(),
      postalCode: _postalCodeController.text.trim(),
    );

    final professionalInfo = ProfessionalInfo(
      professionalTitle: _titleController.text.trim(),
      overviewBio: _bioController.text.trim(),
      hourlyRate: _rateController.text.trim(),
      currency: _currencyController.text.trim(),
      skills: _skills,
      languages: _languages,
      yearsOfExperience: _experienceYearsController.text.trim(),
    );

    final newProfile = UserProfile(
      personalInfo: personalInfo,
      professionalInfo: professionalInfo,
      experiences: _experiences,
      educations: _educations,
      portfolioItems: _portfolioItems,
      profilePhotoPath: _profilePhotoPath,
      documentPaths: _documentPaths,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );

    await profileProvider.saveProfile(newProfile);

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Row(
            children: [
              Icon(Icons.check_circle_rounded, color: Colors.white),
              SizedBox(width: 8),
              Text('Profile created successfully!'),
            ],
          ),
          backgroundColor: AppColors.success,
        ),
      );

      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const MainNavigationScreen()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Setup Your Profile'),
        elevation: 0,
        actions: [
          TextButton(
            onPressed: _saveAndFinish,
            child: const Text('Skip for Now', style: TextStyle(color: AppColors.primary)),
          ),
        ],
      ),
      body: Column(
        children: [
          // Step Progress Bar
          LinearProgressIndicator(
            value: (_currentStep + 1) / _totalSteps,
            backgroundColor: isDark ? AppColors.dividerDark : AppColors.dividerLight,
            valueColor: const AlwaysStoppedAnimation<Color>(AppColors.primary),
            minHeight: 4,
          ),

          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  _getStepTitle(_currentStep),
                  style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                ),
                Text(
                  'Step ${_currentStep + 1} of $_totalSteps',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),

          const Divider(height: 1),

          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: _buildStepContent(_currentStep),
            ),
          ),

          // Bottom Navigation Buttons
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: isDark ? AppColors.surfaceDark : Colors.white,
              border: Border(
                top: BorderSide(
                  color: isDark ? AppColors.dividerDark : AppColors.dividerLight,
                ),
              ),
            ),
            child: Row(
              children: [
                if (_currentStep > 0) ...[
                  OutlinedButton(
                    onPressed: () {
                      setState(() {
                        _currentStep--;
                      });
                    },
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    child: const Text('Back'),
                  ),
                  const SizedBox(width: 12),
                ],
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      if (_currentStep < _totalSteps - 1) {
                        setState(() {
                          _currentStep++;
                        });
                      } else {
                        _saveAndFinish();
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    child: Text(
                      _currentStep < _totalSteps - 1 ? 'Continue' : 'Complete Setup',
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _getStepTitle(int step) {
    switch (step) {
      case 0:
        return 'Personal Information';
      case 1:
        return 'Professional Overview';
      case 2:
        return 'Work Experience';
      case 3:
        return 'Education';
      case 4:
        return 'Portfolio & Documents';
      default:
        return '';
    }
  }

  Widget _buildStepContent(int step) {
    switch (step) {
      case 0:
        return _buildPersonalStep();
      case 1:
        return _buildProfessionalStep();
      case 2:
        return _buildExperienceStep();
      case 3:
        return _buildEducationStep();
      case 4:
        return _buildPortfolioStep();
      default:
        return const SizedBox();
    }
  }

  Widget _buildPersonalStep() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Enter your real contact details for form filling assistance.',
          style: TextStyle(fontSize: 13, color: AppColors.textSecondaryLight),
        ),
        const SizedBox(height: 20),
        Row(
          children: [
            Expanded(
              child: CustomTextField(
                controller: _firstNameController,
                labelText: 'First Name',
                hintText: 'e.g., Jane',
                prefixIcon: Icons.person_outline,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: CustomTextField(
                controller: _lastNameController,
                labelText: 'Last Name',
                hintText: 'e.g., Doe',
                prefixIcon: Icons.person_outline,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        CustomTextField(
          controller: _fullNameController,
          labelText: 'Full Name (Optional)',
          hintText: 'Auto-combined if left empty',
          prefixIcon: Icons.badge_outlined,
        ),
        const SizedBox(height: 16),
        CustomTextField(
          controller: _emailController,
          labelText: 'Email Address',
          hintText: 'e.g., jane.doe@example.com',
          prefixIcon: Icons.email_outlined,
          keyboardType: TextInputType.emailAddress,
        ),
        const SizedBox(height: 16),
        CustomTextField(
          controller: _phoneController,
          labelText: 'Phone Number',
          hintText: 'e.g., +1 (555) 019-2834',
          prefixIcon: Icons.phone_outlined,
          keyboardType: TextInputType.phone,
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: CustomTextField(
                controller: _countryController,
                labelText: 'Country',
                hintText: 'e.g., United States',
                prefixIcon: Icons.public_outlined,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: CustomTextField(
                controller: _cityController,
                labelText: 'City',
                hintText: 'e.g., San Francisco',
                prefixIcon: Icons.location_city_outlined,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        CustomTextField(
          controller: _addressController,
          labelText: 'Street Address',
          hintText: 'e.g., 742 Evergreen Terrace',
          prefixIcon: Icons.home_outlined,
        ),
        const SizedBox(height: 16),
        CustomTextField(
          controller: _postalCodeController,
          labelText: 'Postal / ZIP Code',
          hintText: 'e.g., 94102',
          prefixIcon: Icons.markunread_mailbox_outlined,
        ),
      ],
    );
  }

  Widget _buildProfessionalStep() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CustomTextField(
          controller: _titleController,
          labelText: 'Professional Title',
          hintText: 'e.g., Senior Mobile Application Engineer',
          prefixIcon: Icons.work_outline,
        ),
        const SizedBox(height: 16),
        CustomTextField(
          controller: _bioController,
          labelText: 'Professional Overview / Bio',
          hintText: 'Brief summary of your expertise and background...',
          prefixIcon: Icons.article_outlined,
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
                hintText: 'e.g., 65',
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
          controller: _experienceYearsController,
          labelText: 'Years of Experience',
          hintText: 'e.g., 7+ Years',
          prefixIcon: Icons.timeline_outlined,
        ),
        const SizedBox(height: 24),

        // Skills section
        const Text(
          'Skills',
          style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: CustomTextField(
                controller: _skillsController,
                labelText: 'Add a Skill',
                hintText: 'e.g., Flutter, Dart, Android',
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
          children: _skills.map((s) {
            return Chip(
              label: Text(s),
              deleteIcon: const Icon(Icons.close, size: 16),
              onDeleted: () {
                setState(() {
                  _skills.remove(s);
                });
              },
              backgroundColor: AppColors.primaryLight.withOpacity(0.3),
            );
          }).toList(),
        ),

        const SizedBox(height: 24),

        // Languages
        const Text(
          'Languages',
          style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: CustomTextField(
                controller: _languagesController,
                labelText: 'Add Language',
                hintText: 'e.g., English (Fluent)',
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
          children: _languages.map((l) {
            return Chip(
              label: Text(l),
              deleteIcon: const Icon(Icons.close, size: 16),
              onDeleted: () {
                setState(() {
                  _languages.remove(l);
                });
              },
              backgroundColor: AppColors.secondaryLight.withOpacity(0.3),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildExperienceStep() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Work Experience Entries',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            TextButton.icon(
              onPressed: () => _showAddExperienceDialog(),
              icon: const Icon(Icons.add_circle_outline, size: 18),
              label: const Text('Add Entry'),
            ),
          ],
        ),
        const SizedBox(height: 12),
        if (_experiences.isEmpty)
          Container(
            padding: const EdgeInsets.all(24),
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: Colors.grey.withOpacity(0.08),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.grey.withOpacity(0.2)),
            ),
            child: const Column(
              children: [
                Icon(Icons.business_center_outlined, size: 40, color: AppColors.primary),
                SizedBox(height: 8),
                Text(
                  'No experience entries added yet.',
                  style: TextStyle(fontWeight: FontWeight.w600),
                ),
                SizedBox(height: 4),
                Text(
                  'Tap "Add Entry" to record your job history.',
                  style: TextStyle(fontSize: 12, color: AppColors.textSecondaryLight),
                ),
              ],
            ),
          )
        else
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: _experiences.length,
            separatorBuilder: (_, __) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              final exp = _experiences[index];
              return Card(
                elevation: 1,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                child: ListTile(
                  leading: const CircleAvatar(
                    backgroundColor: AppColors.primaryLight,
                    child: Icon(Icons.work, color: AppColors.primary, size: 20),
                  ),
                  title: Text(exp.jobTitle, style: const TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: Text('${exp.company} • ${exp.startDate} - ${exp.endDate}'),
                  trailing: IconButton(
                    icon: const Icon(Icons.delete_outline, color: AppColors.error),
                    onPressed: () {
                      setState(() {
                        _experiences.removeAt(index);
                      });
                    },
                  ),
                ),
              );
            },
          ),
      ],
    );
  }

  void _showAddExperienceDialog() {
    final compController = TextEditingController();
    final roleController = TextEditingController();
    final startController = TextEditingController();
    final endController = TextEditingController();
    final descController = TextEditingController();

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Add Work Experience'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CustomTextField(controller: compController, labelText: 'Company Name', hintText: 'e.g. Acme Corp'),
              const SizedBox(height: 12),
              CustomTextField(controller: roleController, labelText: 'Job Title', hintText: 'e.g. Lead Architect'),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(child: CustomTextField(controller: startController, labelText: 'Start Date', hintText: '2020-01')),
                  const SizedBox(width: 8),
                  Expanded(child: CustomTextField(controller: endController, labelText: 'End Date', hintText: 'Present')),
                ],
              ),
              const SizedBox(height: 12),
              CustomTextField(controller: descController, labelText: 'Description', maxLines: 3),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () {
              if (compController.text.trim().isNotEmpty && roleController.text.trim().isNotEmpty) {
                setState(() {
                  _experiences.add(
                    WorkExperience(
                      id: DateTime.now().millisecondsSinceEpoch.toString(),
                      company: compController.text.trim(),
                      jobTitle: roleController.text.trim(),
                      startDate: startController.text.trim(),
                      endDate: endController.text.trim(),
                      description: descController.text.trim(),
                    ),
                  );
                });
                Navigator.pop(ctx);
              }
            },
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }

  Widget _buildEducationStep() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Education Entries',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            TextButton.icon(
              onPressed: () => _showAddEducationDialog(),
              icon: const Icon(Icons.add_circle_outline, size: 18),
              label: const Text('Add Education'),
            ),
          ],
        ),
        const SizedBox(height: 12),
        if (_educations.isEmpty)
          Container(
            padding: const EdgeInsets.all(24),
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: Colors.grey.withOpacity(0.08),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.grey.withOpacity(0.2)),
            ),
            child: const Column(
              children: [
                Icon(Icons.school_outlined, size: 40, color: AppColors.secondary),
                SizedBox(height: 8),
                Text(
                  'No education entries added yet.',
                  style: TextStyle(fontWeight: FontWeight.w600),
                ),
                SizedBox(height: 4),
                Text(
                  'Tap "Add Education" to list degrees and institutions.',
                  style: TextStyle(fontSize: 12, color: AppColors.textSecondaryLight),
                ),
              ],
            ),
          )
        else
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: _educations.length,
            separatorBuilder: (_, __) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              final edu = _educations[index];
              return Card(
                elevation: 1,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                child: ListTile(
                  leading: const CircleAvatar(
                    backgroundColor: AppColors.secondaryLight,
                    child: Icon(Icons.school, color: AppColors.secondary, size: 20),
                  ),
                  title: Text(edu.institution, style: const TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: Text('${edu.degree} in ${edu.fieldOfStudy} (${edu.startDate} - ${edu.endDate})'),
                  trailing: IconButton(
                    icon: const Icon(Icons.delete_outline, color: AppColors.error),
                    onPressed: () {
                      setState(() {
                        _educations.removeAt(index);
                      });
                    },
                  ),
                ),
              );
            },
          ),
      ],
    );
  }

  void _showAddEducationDialog() {
    final instController = TextEditingController();
    final degController = TextEditingController();
    final fieldController = TextEditingController();
    final startController = TextEditingController();
    final endController = TextEditingController();
    final descController = TextEditingController();

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Add Education'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CustomTextField(controller: instController, labelText: 'Institution / University', hintText: 'e.g. Stanford University'),
              const SizedBox(height: 12),
              CustomTextField(controller: degController, labelText: 'Degree', hintText: 'e.g. Bachelor of Science'),
              const SizedBox(height: 12),
              CustomTextField(controller: fieldController, labelText: 'Field of Study', hintText: 'e.g. Computer Science'),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(child: CustomTextField(controller: startController, labelText: 'Start Year', hintText: '2016')),
                  const SizedBox(width: 8),
                  Expanded(child: CustomTextField(controller: endController, labelText: 'End Year', hintText: '2020')),
                ],
              ),
              const SizedBox(height: 12),
              CustomTextField(controller: descController, labelText: 'Description (Optional)', maxLines: 2),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () {
              if (instController.text.trim().isNotEmpty) {
                setState(() {
                  _educations.add(
                    Education(
                      id: DateTime.now().millisecondsSinceEpoch.toString(),
                      institution: instController.text.trim(),
                      degree: degController.text.trim(),
                      fieldOfStudy: fieldController.text.trim(),
                      startDate: startController.text.trim(),
                      endDate: endController.text.trim(),
                      description: descController.text.trim(),
                    ),
                  );
                });
                Navigator.pop(ctx);
              }
            },
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }

  Widget _buildPortfolioStep() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Profile photo picker
        const Text(
          'Profile Photo',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            CircleAvatar(
              radius: 36,
              backgroundColor: AppColors.primary.withOpacity(0.1),
              backgroundImage: _profilePhotoPath.isNotEmpty ? AssetImage(_profilePhotoPath) : null,
              child: _profilePhotoPath.isEmpty
                  ? const Icon(Icons.person, size: 40, color: AppColors.primary)
                  : null,
            ),
            const SizedBox(width: 16),
            ElevatedButton.icon(
              onPressed: _pickProfilePhoto,
              icon: const Icon(Icons.photo_library_outlined, size: 18),
              label: const Text('Select Photo'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryLight.withOpacity(0.5),
                foregroundColor: AppColors.primaryDark,
              ),
            ),
          ],
        ),
        const SizedBox(height: 24),

        // Portfolio items
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Portfolio Items',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            TextButton.icon(
              onPressed: () => _showAddPortfolioDialog(),
              icon: const Icon(Icons.add_circle_outline, size: 18),
              label: const Text('Add Project'),
            ),
          ],
        ),
        const SizedBox(height: 12),
        if (_portfolioItems.isEmpty)
          Container(
            padding: const EdgeInsets.all(24),
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: Colors.grey.withOpacity(0.08),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.grey.withOpacity(0.2)),
            ),
            child: const Column(
              children: [
                Icon(Icons.folder_special_outlined, size: 40, color: AppColors.accent),
                SizedBox(height: 8),
                Text('No portfolio items added yet.', style: TextStyle(fontWeight: FontWeight.w600)),
                SizedBox(height: 4),
                Text('Add projects, URLs, and skill tags.', style: TextStyle(fontSize: 12, color: AppColors.textSecondaryLight)),
              ],
            ),
          )
        else
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: _portfolioItems.length,
            separatorBuilder: (_, __) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              final port = _portfolioItems[index];
              return Card(
                elevation: 1,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                child: ListTile(
                  leading: const CircleAvatar(
                    backgroundColor: AppColors.primaryLight,
                    child: Icon(Icons.code, color: AppColors.primary, size: 20),
                  ),
                  title: Text(port.projectName, style: const TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: Text(port.projectUrl.isNotEmpty ? port.projectUrl : port.projectDescription),
                  trailing: IconButton(
                    icon: const Icon(Icons.delete_outline, color: AppColors.error),
                    onPressed: () {
                      setState(() {
                        _portfolioItems.removeAt(index);
                      });
                    },
                  ),
                ),
              );
            },
          ),
      ],
    );
  }

  void _showAddPortfolioDialog() {
    final nameCtrl = TextEditingController();
    final descCtrl = TextEditingController();
    final urlCtrl = TextEditingController();
    final skillsCtrl = TextEditingController();

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Add Portfolio Project'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CustomTextField(controller: nameCtrl, labelText: 'Project Name', hintText: 'e.g. SuperApp Platform'),
              const SizedBox(height: 12),
              CustomTextField(controller: urlCtrl, labelText: 'Project URL', hintText: 'https://github.com/...'),
              const SizedBox(height: 12),
              CustomTextField(controller: skillsCtrl, labelText: 'Skills Used (comma-separated)', hintText: 'Flutter, REST API'),
              const SizedBox(height: 12),
              CustomTextField(controller: descCtrl, labelText: 'Description', maxLines: 3),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () {
              if (nameCtrl.text.trim().isNotEmpty) {
                final skillList = skillsCtrl.text.split(',').map((s) => s.trim()).where((s) => s.isNotEmpty).toList();
                setState(() {
                  _portfolioItems.add(
                    PortfolioItem(
                      id: DateTime.now().millisecondsSinceEpoch.toString(),
                      projectName: nameCtrl.text.trim(),
                      projectDescription: descCtrl.text.trim(),
                      projectUrl: urlCtrl.text.trim(),
                      skillsUsed: skillList,
                    ),
                  );
                });
                Navigator.pop(ctx);
              }
            },
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }
}
