import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../providers/security_provider.dart';
import '../../widgets/forms/custom_text_field.dart';

class SecuritySettingsScreen extends StatefulWidget {
  const SecuritySettingsScreen({Key? key}) : super(key: key);

  @override
  State<SecuritySettingsScreen> createState() => _SecuritySettingsScreenState();
}

class _SecuritySettingsScreenState extends State<SecuritySettingsScreen> {
  final _pinController = TextEditingController();
  final _confirmPinController = TextEditingController();

  @override
  void dispose() {
    _pinController.dispose();
    _confirmPinController.dispose();
    super.dispose();
  }

  void _showSetPinDialog(BuildContext context) {
    _pinController.clear();
    _confirmPinController.clear();

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Set 4-Digit Security PIN'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CustomTextField(
              controller: _pinController,
              labelText: 'New PIN',
              hintText: '4 digits',
              keyboardType: TextInputType.number,
              obscureText: true,
              maxLength: 4,
            ),
            const SizedBox(height: 12),
            CustomTextField(
              controller: _confirmPinController,
              labelText: 'Confirm PIN',
              hintText: 'Re-enter 4 digits',
              keyboardType: TextInputType.number,
              obscureText: true,
              maxLength: 4,
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () async {
              final pin = _pinController.text.trim();
              final confirm = _confirmPinController.text.trim();

              if (pin.length != 4) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('PIN must be exactly 4 digits.')),
                );
                return;
              }

              if (pin != confirm) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('PINs do not match.')),
                );
                return;
              }

              await context.read<SecurityProvider>().setPin(pin);

              if (ctx.mounted) {
                Navigator.pop(ctx);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('PIN enabled successfully!'),
                    backgroundColor: AppColors.success,
                  ),
                );
              }
            },
            child: const Text('Save PIN'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final secProvider = context.watch<SecurityProvider>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Security & Vault Lock'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          // Security Overview Card
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: isDark ? AppColors.surfaceDark : Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: isDark ? AppColors.dividerDark : AppColors.dividerLight,
              ),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withOpacity(0.12),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.lock_person_rounded, color: AppColors.primary, size: 28),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        secProvider.isPinEnabled ? 'Vault Protection Active' : 'Vault Unlocked',
                        style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        secProvider.isPinEnabled
                            ? 'PIN required on app launch to access profile.'
                            : 'Set a PIN to encrypt and secure your profile.',
                        style: TextStyle(
                          fontSize: 12,
                          color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),

          // Actions
          Container(
            decoration: BoxDecoration(
              color: isDark ? AppColors.surfaceDark : Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: isDark ? AppColors.dividerDark : AppColors.dividerLight,
              ),
            ),
            child: Column(
              children: [
                ListTile(
                  leading: const Icon(Icons.pin_rounded, color: AppColors.primary),
                  title: Text(secProvider.isPinEnabled ? 'Change PIN' : 'Set Security PIN'),
                  subtitle: Text(secProvider.isPinEnabled ? 'Update your 4-digit code' : 'Protect with 4-digit PIN'),
                  trailing: const Icon(Icons.arrow_forward_ios, size: 14),
                  onTap: () => _showSetPinDialog(context),
                ),
                if (secProvider.isPinEnabled) ...[
                  const Divider(height: 1),
                  ListTile(
                    leading: const Icon(Icons.lock_open_rounded, color: AppColors.error),
                    title: const Text('Disable PIN Lock', style: TextStyle(color: AppColors.error)),
                    subtitle: const Text('Remove passcode protection'),
                    onTap: () async {
                      await secProvider.removePin();
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('PIN lock disabled.')),
                        );
                      }
                    },
                  ),
                ],
                const Divider(height: 1),
                SwitchListTile(
                  secondary: const Icon(Icons.fingerprint_rounded, color: AppColors.secondary),
                  title: const Text('Biometric Authentication'),
                  subtitle: const Text('Unlock using fingerprint or face recognition'),
                  value: secProvider.isBiometricEnabled,
                  activeColor: AppColors.primary,
                  onChanged: (val) async {
                    await secProvider.setBiometricEnabled(val);
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
