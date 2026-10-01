import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../providers/profile_provider.dart';
import '../../widgets/cards/section_summary_card.dart';
import 'edit_personal_screen.dart';
import 'edit_professional_screen.dart';
import 'manage_experience_screen.dart';
import 'manage_education_screen.dart';
import 'manage_portfolio_screen.dart';
import 'manage_documents_screen.dart';
import '../search/global_search_screen.dart';

class ProfileDashboardScreen extends StatelessWidget {
  const ProfileDashboardScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final profileProvider = context.watch<ProfileProvider>();
    final profile = profileProvider.profile;
    final percentage = profileProvider.completionPercentage;

    final personal = profile.personalInfo;
    final prof = profile.professionalInfo;

    final fullName = personal.effectiveFullName.isNotEmpty
        ? personal.effectiveFullName
        : (personal.email.isNotEmpty ? personal.email : 'Authentic Profile');

    final title = prof.professionalTitle.isNotEmpty
        ? prof.professionalTitle
        : 'Title Not Specified';

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Profile', style: TextStyle(fontWeight: FontWeight.bold)),
        actions: [
          IconButton(
            icon: const Icon(Icons.search_rounded),
            tooltip: 'Search Profile',
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const GlobalSearchScreen()),
              );
            },
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          await profileProvider.loadProfile();
        },
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Top Profile Hero Header
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: isDark
                        ? [const Color(0xFF1E293B), const Color(0xFF0F172A)]
                        : [Colors.white, const Color(0xFFF1F5F9)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(
                    color: isDark ? AppColors.dividerDark : AppColors.dividerLight,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.04),
                      blurRadius: 14,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    Row(
                      children: [
                        // Profile Avatar
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
                                fullName,
                                style: theme.textTheme.titleLarge?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  letterSpacing: -0.3,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 2),
                              Text(
                                title,
                                style: theme.textTheme.bodyMedium?.copyWith(
                                  color: AppColors.primary,
                                  fontWeight: FontWeight.w600,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 6),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                decoration: BoxDecoration(
                                  color: (percentage >= 80 ? AppColors.success : AppColors.primary).withOpacity(0.12),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(
                                      percentage >= 80 ? Icons.verified : Icons.pie_chart_outline,
                                      size: 13,
                                      color: percentage >= 80 ? AppColors.success : AppColors.primary,
                                    ),
                                    const SizedBox(width: 4),
                                    Text(
                                      'Profile $percentage% Complete',
                                      style: TextStyle(
                                        fontSize: 11,
                                        fontWeight: FontWeight.bold,
                                        color: percentage >= 80 ? AppColors.success : AppColors.primary,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(6),
                      child: LinearProgressIndicator(
                        value: percentage / 100,
                        backgroundColor: isDark ? AppColors.dividerDark : AppColors.dividerLight,
                        valueColor: AlwaysStoppedAnimation<Color>(
                          percentage >= 80 ? AppColors.success : AppColors.primary,
                        ),
                        minHeight: 6,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              Text(
                'Profile Sections',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  letterSpacing: -0.2,
                ),
              ),
              const SizedBox(height: 10),

              // 1. Personal Information Card
              SectionSummaryCard(
                icon: Icons.person_rounded,
                title: 'Personal Information',
                summary: [
                  if (personal.email.isNotEmpty) personal.email,
                  if (personal.phone.isNotEmpty) personal.phone,
                  if (personal.city.isNotEmpty || personal.country.isNotEmpty)
                    '${personal.city}, ${personal.country}'.trim().replaceAll(RegExp(r'^,\s*|,\s*$'), ''),
                ].join(' • '),
                isComplete: personal.firstName.isNotEmpty && personal.email.isNotEmpty,
                onEdit: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => const EditPersonalScreen()),
                  );
                },
              ),

              // 2. Professional Information Card
              SectionSummaryCard(
                icon: Icons.work_rounded,
                title: 'Professional Information',
                summary: [
                  if (prof.professionalTitle.isNotEmpty) prof.professionalTitle,
                  if (prof.hourlyRate.isNotEmpty) '${prof.hourlyRate} ${prof.currency}/hr',
                  if (prof.yearsOfExperience.isNotEmpty) prof.yearsOfExperience,
                ].join(' • '),
                isComplete: prof.professionalTitle.isNotEmpty,
                onEdit: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => const EditProfessionalScreen()),
                  );
                },
              ),

              // 3. Work Experience Card
              SectionSummaryCard(
                icon: Icons.business_center_rounded,
                title: 'Work Experience',
                summary: profile.experiences.isNotEmpty
                    ? '${profile.experiences.length} positions: ${profile.experiences.first.jobTitle} at ${profile.experiences.first.company}'
                    : 'No work history recorded',
                isComplete: profile.experiences.isNotEmpty,
                onEdit: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => const ManageExperienceScreen()),
                  );
                },
              ),

              // 4. Education Card
              SectionSummaryCard(
                icon: Icons.school_rounded,
                title: 'Education',
                summary: profile.educations.isNotEmpty
                    ? '${profile.educations.length} entries: ${profile.educations.first.degree} at ${profile.educations.first.institution}'
                    : 'No education history recorded',
                isComplete: profile.educations.isNotEmpty,
                onEdit: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => const ManageEducationScreen()),
                  );
                },
              ),

              // 5. Skills Card
              SectionSummaryCard(
                icon: Icons.stars_rounded,
                title: 'Skills & Languages',
                summary: [
                  if (prof.skills.isNotEmpty) '${prof.skills.length} skills (${prof.skills.take(3).join(', ')}...)',
                  if (prof.languages.isNotEmpty) '${prof.languages.length} languages',
                ].join(' • '),
                isComplete: prof.skills.isNotEmpty,
                onEdit: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => const EditProfessionalScreen()),
                  );
                },
              ),

              // 6. Portfolio Card
              SectionSummaryCard(
                icon: Icons.folder_special_rounded,
                title: 'Portfolio & Projects',
                summary: profile.portfolioItems.isNotEmpty
                    ? '${profile.portfolioItems.length} projects (${profile.portfolioItems.map((p) => p.projectName).join(', ')})'
                    : 'No portfolio items recorded',
                isComplete: profile.portfolioItems.isNotEmpty,
                onEdit: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => const ManagePortfolioScreen()),
                  );
                },
              ),

              // 7. Documents Card
              SectionSummaryCard(
                icon: Icons.attachment_rounded,
                title: 'Documents & Photos',
                summary: [
                  if (profile.profilePhotoPath.isNotEmpty) 'Profile photo set',
                  if (profile.documentPaths.isNotEmpty) '${profile.documentPaths.length} attached files',
                ].join(' • '),
                isComplete: profile.profilePhotoPath.isNotEmpty || profile.documentPaths.isNotEmpty,
                onEdit: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => const ManageDocumentsScreen()),
                  );
                },
              ),

              const SizedBox(height: 28),
            ],
          ),
        ),
      ),
    );
  }
}
