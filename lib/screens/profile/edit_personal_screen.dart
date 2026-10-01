import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../models/personal_info.dart';
import '../../providers/profile_provider.dart';
import '../../widgets/forms/custom_text_field.dart';

class EditPersonalScreen extends StatefulWidget {
  const EditPersonalScreen({Key? key}) : super(key: key);

  @override
  State<EditPersonalScreen> createState() => _EditPersonalScreenState();
}

class _EditPersonalScreenState extends State<EditPersonalScreen> {
  final _formKey = GlobalKey<FormState>();

  late TextEditingController _firstNameController;
  late TextEditingController _lastNameController;
  late TextEditingController _fullNameController;
  late TextEditingController _emailController;
  late TextEditingController _phoneController;
  late TextEditingController _countryController;
  late TextEditingController _cityController;
  late TextEditingController _addressController;
  late TextEditingController _postalCodeController;

  bool _isDirty = false;

  @override
  void initState() {
    super.initState();
    final p = context.read<ProfileProvider>().profile.personalInfo;
    _firstNameController = TextEditingController(text: p.firstName);
    _lastNameController = TextEditingController(text: p.lastName);
    _fullNameController = TextEditingController(text: p.fullName);
    _emailController = TextEditingController(text: p.email);
    _phoneController = TextEditingController(text: p.phone);
    _countryController = TextEditingController(text: p.country);
    _cityController = TextEditingController(text: p.city);
    _addressController = TextEditingController(text: p.address);
    _postalCodeController = TextEditingController(text: p.postalCode);

    for (final c in [
      _firstNameController,
      _lastNameController,
      _fullNameController,
      _emailController,
      _phoneController,
      _countryController,
      _cityController,
      _addressController,
      _postalCodeController,
    ]) {
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
    _firstNameController.dispose();
    _lastNameController.dispose();
    _fullNameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _countryController.dispose();
    _cityController.dispose();
    _addressController.dispose();
    _postalCodeController.dispose();
    super.dispose();
  }

  Future<void> _saveChanges() async {
    if (_formKey.currentState?.validate() ?? false) {
      final updatedPersonal = PersonalInfo(
        firstName: _firstNameController.text.trim(),
        lastName: _lastNameController.text.trim(),
        fullName: _fullNameController.text.trim(),
        email: _emailController.text.trim(),
        phone: _phoneController.text.trim(),
        country: _countryController.text.trim(),
        city: _cityController.text.trim(),
        address: _addressController.text.trim(),
        postalCode: _postalCodeController.text.trim(),
      );

      await context.read<ProfileProvider>().updatePersonalInfo(updatedPersonal);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Row(
              children: [
                Icon(Icons.check_circle, color: Colors.white),
                SizedBox(width: 8),
                Text('Personal information saved securely!'),
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
    return WillPopScope(
      onWillPop: () async {
        if (!_isDirty) return true;
        final shouldPop = await showDialog<bool>(
          context: context,
          builder: (ctx) => AlertDialog(
            title: const Text('Discard Unsaved Changes?'),
            content: const Text('You have unsaved changes in your personal details. Are you sure you want to discard them?'),
            actions: [
              TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Keep Editing')),
              ElevatedButton(
                onPressed: () => Navigator.pop(ctx, true),
                style: ElevatedButton.styleFrom(backgroundColor: AppColors.error),
                child: const Text('Discard'),
              ),
            ],
          ),
        );
        return shouldPop ?? false;
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Personal Information'),
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
              Row(
                children: [
                  Expanded(
                    child: CustomTextField(
                      controller: _firstNameController,
                      labelText: 'First Name',
                      hintText: 'e.g., Alex',
                      prefixIcon: Icons.person_outline,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: CustomTextField(
                      controller: _lastNameController,
                      labelText: 'Last Name',
                      hintText: 'e.g., Morgan',
                      prefixIcon: Icons.person_outline,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              CustomTextField(
                controller: _fullNameController,
                labelText: 'Full Name',
                hintText: 'Leave empty to auto-combine first and last name',
                prefixIcon: Icons.badge_outlined,
              ),
              const SizedBox(height: 16),
              CustomTextField(
                controller: _emailController,
                labelText: 'Email Address',
                hintText: 'e.g., alex.morgan@domain.com',
                prefixIcon: Icons.email_outlined,
                keyboardType: TextInputType.emailAddress,
              ),
              const SizedBox(height: 16),
              CustomTextField(
                controller: _phoneController,
                labelText: 'Phone Number',
                hintText: 'e.g., +1 (415) 555-0199',
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
                      hintText: 'e.g., Austin',
                      prefixIcon: Icons.location_city_outlined,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              CustomTextField(
                controller: _addressController,
                labelText: 'Street Address',
                hintText: 'e.g., 100 Congress Ave, Suite 200',
                prefixIcon: Icons.home_outlined,
              ),
              const SizedBox(height: 16),
              CustomTextField(
                controller: _postalCodeController,
                labelText: 'Postal / ZIP Code',
                hintText: 'e.g., 78701',
                prefixIcon: Icons.markunread_mailbox_outlined,
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
      ),
    );
  }
}
