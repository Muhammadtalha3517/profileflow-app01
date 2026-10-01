import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';

class AboutScreen extends StatelessWidget {
  const AboutScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text('About ProfileFlow'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          Center(
            child: Column(
              children: [
                Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [AppColors.primary, AppColors.secondary],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(24),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.primary.withOpacity(0.3),
                        blurRadius: 16,
                        offset: const Offset(0, 6),
                      ),
                    ],
                  ),
                  child: const Icon(Icons.badge_rounded, size: 44, color: Colors.white),
                ),
                const SizedBox(height: 16),
                Text(
                  'ProfileFlow Assistant',
                  style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 4),
                const Text(
                  'Version 1.0.0 (Build 1)',
                  style: TextStyle(color: AppColors.textSecondaryLight, fontSize: 13),
                ),
              ],
            ),
          ),

          const SizedBox(height: 32),

          Text(
            'Core Principles',
            style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),

          _buildPrincipleCard(
            context,
            icon: Icons.verified_user_rounded,
            color: AppColors.success,
            title: 'Authentic Data Only',
            description: 'No fabricated or placeholder data. All information originates directly from what you enter.',
          ),
          const SizedBox(height: 12),
          _buildPrincipleCard(
            context,
            icon: Icons.touch_app_rounded,
            color: AppColors.primary,
            title: 'Full User Control',
            description: 'The app assists by populating fields only after explicit user review and confirmation. Forms are never auto-submitted.',
          ),
          const SizedBox(height: 12),
          _buildPrincipleCard(
            context,
            icon: Icons.lock_rounded,
            color: AppColors.secondary,
            title: '100% Local Encrypted Vault',
            description: 'Your data stays on this device using local encryption. No external database or cloud synchronisation required.',
          ),

          const SizedBox(height: 32),

          Center(
            child: Text(
              'Designed & Engineered with Material 3 & Flutter',
              style: TextStyle(
                fontSize: 12,
                color: isDark ? AppColors.textTertiaryDark : AppColors.textTertiaryLight,
              ),
            ),
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  Widget _buildPrincipleCard(
    BuildContext context, {
    required IconData icon,
    required Color color,
    required String title,
    required String description,
  }) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? AppColors.surfaceDark : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark ? AppColors.dividerDark : AppColors.dividerLight,
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withOpacity(0.12),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold)),
                const SizedBox(height: 4),
                Text(
                  description,
                  style: TextStyle(
                    fontSize: 12,
                    height: 1.4,
                    color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
