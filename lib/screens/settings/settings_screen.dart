import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../providers/profile_provider.dart';
import '../../providers/theme_provider.dart';
import '../../providers/security_provider.dart';
import 'security_settings_screen.dart';
import 'export_import_screen.dart';
import 'about_screen.dart';
import '../onboarding/onboarding_screen.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({Key? key}) : super(key: key);

  void _confirmClearData(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.warning_amber_rounded, color: AppColors.error),
            SizedBox(width: 8),
            Text('Clear All Local Data?'),
          ],
        ),
        content: const Text(
          'This will permanently delete your stored profile, work experience, education, portfolio, and settings from this device.\n\nThis action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              await context.read<ProfileProvider>().clearAllProfileData();
              if (ctx.mounted) {
                Navigator.pop(ctx);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('All local profile data was securely erased.'),
                    backgroundColor: AppColors.error,
                  ),
                );
                Navigator.of(context).pushAndRemoveUntil(
                  MaterialPageRoute(builder: (_) => const OnboardingScreen()),
                  (route) => false,
                );
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.error),
            child: const Text('Erase Everything'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final themeProvider = context.watch<ThemeProvider>();
    final securityProvider = context.watch<SecurityProvider>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings', style: TextStyle(fontWeight: FontWeight.bold)),
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        children: [
          // Security Section
          _buildSectionHeader(context, 'Security & Access'),
          _buildSettingsCard(
            context,
            children: [
              ListTile(
                leading: const Icon(Icons.security_rounded, color: AppColors.primary),
                title: const Text('App Lock & PIN'),
                subtitle: Text(
                  securityProvider.isPinEnabled ? 'Protected with PIN' : 'Not configured',
                ),
                trailing: const Icon(Icons.arrow_forward_ios, size: 14),
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => const SecuritySettingsScreen()),
                  );
                },
              ),
              const Divider(height: 1),
              SwitchListTile(
                secondary: const Icon(Icons.fingerprint_rounded, color: AppColors.secondary),
                title: const Text('Biometric Unlock'),
                subtitle: const Text('Fingerprint or Face Authentication'),
                value: securityProvider.isBiometricEnabled,
                activeColor: AppColors.primary,
                onChanged: (val) async {
                  await securityProvider.setBiometricEnabled(val);
                },
              ),
            ],
          ),

          const SizedBox(height: 20),

          // Appearance Section
          _buildSectionHeader(context, 'Appearance'),
          _buildSettingsCard(
            context,
            children: [
              ListTile(
                leading: const Icon(Icons.palette_outlined, color: AppColors.primary),
                title: const Text('App Theme'),
                subtitle: Text(
                  themeProvider.themeMode == ThemeMode.system
                      ? 'System Default'
                      : (themeProvider.themeMode == ThemeMode.dark ? 'Dark Mode' : 'Light Mode'),
                ),
                trailing: PopupMenuButton<ThemeMode>(
                  icon: const Icon(Icons.arrow_drop_down),
                  onSelected: (mode) => themeProvider.setThemeMode(mode),
                  itemBuilder: (_) => const [
                    PopupMenuItem(value: ThemeMode.system, child: Text('System Default')),
                    PopupMenuItem(value: ThemeMode.light, child: Text('Light Mode')),
                    PopupMenuItem(value: ThemeMode.dark, child: Text('Dark Mode')),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 20),

          // Backup & Data Section
          _buildSectionHeader(context, 'Data & Backup'),
          _buildSettingsCard(
            context,
            children: [
              ListTile(
                leading: const Icon(Icons.import_export_rounded, color: AppColors.primary),
                title: const Text('Export & Import Profile'),
                subtitle: const Text('Backup or restore encrypted JSON files'),
                trailing: const Icon(Icons.arrow_forward_ios, size: 14),
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => const ExportImportScreen()),
                  );
                },
              ),
              const Divider(height: 1),
              ListTile(
                leading: const Icon(Icons.delete_forever_rounded, color: AppColors.error),
                title: const Text('Clear All Local Data', style: TextStyle(color: AppColors.error)),
                subtitle: const Text('Permanently erase saved profile and tasks'),
                onTap: () => _confirmClearData(context),
              ),
            ],
          ),

          const SizedBox(height: 20),

          // Privacy & About Section
          _buildSectionHeader(context, 'About & Privacy'),
          _buildSettingsCard(
            context,
            children: [
              ListTile(
                leading: const Icon(Icons.privacy_tip_outlined, color: AppColors.primary),
                title: const Text('Privacy Architecture'),
                subtitle: const Text('Zero-cloud, zero-tracking guarantee'),
                trailing: const Icon(Icons.arrow_forward_ios, size: 14),
                onTap: () {
                  _showPrivacyDialog(context);
                },
              ),
              const Divider(height: 1),
              ListTile(
                leading: const Icon(Icons.info_outline_rounded, color: AppColors.primary),
                title: const Text('About ProfileFlow'),
                subtitle: const Text('Version 1.0.0 • Architecture & Principles'),
                trailing: const Icon(Icons.arrow_forward_ios, size: 14),
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => const AboutScreen()),
                  );
                },
              ),
            ],
          ),

          const SizedBox(height: 32),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(BuildContext context, String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 4, bottom: 8),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.bold,
          letterSpacing: 0.8,
          color: AppColors.primary,
        ),
      ),
    );
  }

  Widget _buildSettingsCard(BuildContext context, {required List<Widget> children}) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      decoration: BoxDecoration(
        color: isDark ? AppColors.surfaceDark : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark ? AppColors.dividerDark : AppColors.dividerLight,
        ),
      ),
      child: Column(children: children),
    );
  }

  void _showPrivacyDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Privacy & Security Principles'),
        content: const SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                '1. Zero Fake Information',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 4),
              Text('ProfileFlow never fabricates identities, credentials, or placeholder values.'),
              SizedBox(height: 12),
              Text(
                '2. 100% On-Device Vault',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 4),
              Text('All personal data is encrypted and stored locally on your Android device. No external telemetry or cloud servers.'),
              SizedBox(height: 12),
              Text(
                '3. Explicit User Approval',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 4),
              Text('No forms are ever auto-submitted. You review and confirm every mapped field step-by-step.'),
            ],
          ),
        ),
        actions: [
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Understood'),
          ),
        ],
      ),
    );
  }
}
