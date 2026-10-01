import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import 'package:file_picker/file_picker.dart';
import '../../core/constants/app_colors.dart';
import '../../providers/profile_provider.dart';

class ManageDocumentsScreen extends StatefulWidget {
  const ManageDocumentsScreen({Key? key}) : super(key: key);

  @override
  State<ManageDocumentsScreen> createState() => _ManageDocumentsScreenState();
}

class _ManageDocumentsScreenState extends State<ManageDocumentsScreen> {
  final ImagePicker _picker = ImagePicker();

  Future<void> _pickProfilePhoto() async {
    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1024,
        maxHeight: 1024,
        imageQuality: 90,
      );

      if (image != null && mounted) {
        await context.read<ProfileProvider>().setProfilePhoto(image.path);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Profile photo updated successfully!'),
            backgroundColor: AppColors.success,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to pick photo: $e')),
        );
      }
    }
  }

  Future<void> _pickDocument() async {
    try {
      final FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf', 'doc', 'docx', 'jpg', 'jpeg', 'png'],
      );

      if (result != null && result.files.single.path != null && mounted) {
        final path = result.files.single.path!;
        await context.read<ProfileProvider>().addDocumentPath(path);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Document attached successfully!'),
            backgroundColor: AppColors.success,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to pick document: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final profileProvider = context.watch<ProfileProvider>();
    final profile = profileProvider.profile;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Documents & Photos'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          // Security / Manual User Control Notice
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF13232C) : AppColors.securityBadgeBg,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: AppColors.securityBadge.withOpacity(0.3)),
            ),
            child: const Row(
              children: [
                Icon(Icons.shield_outlined, color: AppColors.securityBadge, size: 24),
                SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Documents are stored locally on your device. ProfileFlow will never automatically upload identity files to external websites.',
                    style: TextStyle(fontSize: 12, height: 1.3),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),

          // Profile Photo Section
          Text(
            'Profile Photo',
            style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),

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
                  width: 72,
                  height: 72,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: AppColors.primary, width: 2),
                  ),
                  child: ClipOval(
                    child: profile.profilePhotoPath.isNotEmpty && File(profile.profilePhotoPath).existsSync()
                        ? Image.file(
                            File(profile.profilePhotoPath),
                            fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) => const Icon(
                              Icons.person,
                              size: 40,
                              color: AppColors.primary,
                            ),
                          )
                        : const Icon(Icons.person, size: 40, color: AppColors.primary),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        profile.profilePhotoPath.isNotEmpty ? 'Photo selected' : 'No photo uploaded',
                        style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'Used for quick manual reference and profile preview.',
                        style: TextStyle(
                          fontSize: 12,
                          color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          ElevatedButton.icon(
                            onPressed: _pickProfilePhoto,
                            icon: const Icon(Icons.photo_library_outlined, size: 16),
                            label: Text(profile.profilePhotoPath.isNotEmpty ? 'Change Photo' : 'Select Photo'),
                            style: ElevatedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                              backgroundColor: AppColors.primary,
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                            ),
                          ),
                          if (profile.profilePhotoPath.isNotEmpty) ...[
                            const SizedBox(width: 8),
                            IconButton(
                              icon: const Icon(Icons.delete_outline, color: AppColors.error),
                              tooltip: 'Remove photo',
                              onPressed: () => profileProvider.setProfilePhoto(''),
                            ),
                          ],
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 28),

          // Attached Documents Section
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Attached Documents',
                style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
              ),
              TextButton.icon(
                onPressed: _pickDocument,
                icon: const Icon(Icons.upload_file_outlined, size: 18),
                label: const Text('Attach File'),
              ),
            ],
          ),
          const SizedBox(height: 10),

          if (profile.documentPaths.isEmpty)
            Container(
              padding: const EdgeInsets.all(24),
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: isDark ? AppColors.surfaceDark : Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: isDark ? AppColors.dividerDark : AppColors.dividerLight,
                ),
              ),
              child: Column(
                children: [
                  const Icon(Icons.folder_open_outlined, size: 40, color: AppColors.textTertiaryLight),
                  const SizedBox(height: 8),
                  const Text('No documents attached', style: TextStyle(fontWeight: FontWeight.w600)),
                  const SizedBox(height: 4),
                  Text(
                    'Attach your resume, portfolio PDFs, or reference letters for manual viewing.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 12,
                      color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                    ),
                  ),
                ],
              ),
            )
          else
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: profile.documentPaths.length,
              separatorBuilder: (_, __) => const SizedBox(height: 10),
              itemBuilder: (context, index) {
                final docPath = profile.documentPaths[index];
                final fileName = docPath.split(Platform.pathSeparator).last;

                return Card(
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                    side: BorderSide(
                      color: isDark ? AppColors.dividerDark : AppColors.dividerLight,
                    ),
                  ),
                  child: ListTile(
                    leading: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(Icons.description, color: AppColors.primary, size: 22),
                    ),
                    title: Text(
                      fileName,
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    subtitle: Text(
                      docPath,
                      style: TextStyle(
                        fontSize: 11,
                        color: isDark ? AppColors.textTertiaryDark : AppColors.textTertiaryLight,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    trailing: IconButton(
                      icon: const Icon(Icons.delete_outline, color: AppColors.error),
                      onPressed: () => profileProvider.removeDocumentPath(index),
                    ),
                  ),
                );
              },
            ),
        ],
      ),
    );
  }
}
