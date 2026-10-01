import 'personal_info.dart';
import 'professional_info.dart';
import 'work_experience.dart';
import 'education.dart';
import 'portfolio_item.dart';

class UserProfile {
  final PersonalInfo personalInfo;
  final ProfessionalInfo professionalInfo;
  final List<WorkExperience> experiences;
  final List<Education> educations;
  final List<PortfolioItem> portfolioItems;
  final String profilePhotoPath;
  final List<String> documentPaths;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const UserProfile({
    this.personalInfo = const PersonalInfo(),
    this.professionalInfo = const ProfessionalInfo(),
    this.experiences = const [],
    this.educations = const [],
    this.portfolioItems = const [],
    this.profilePhotoPath = '',
    this.documentPaths = const [],
    this.createdAt,
    this.updatedAt,
  });

  /// Authentic empty profile initialized for real user data
  factory UserProfile.empty() => UserProfile(
        personalInfo: PersonalInfo.empty(),
        professionalInfo: ProfessionalInfo.empty(),
        experiences: const [],
        educations: const [],
        portfolioItems: const [],
        profilePhotoPath: '',
        documentPaths: const [],
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

  bool get isCompletelyEmpty =>
      personalInfo.isEmpty &&
      professionalInfo.isEmpty &&
      experiences.isEmpty &&
      educations.isEmpty &&
      portfolioItems.isEmpty &&
      profilePhotoPath.isEmpty &&
      documentPaths.isEmpty;

  UserProfile copyWith({
    PersonalInfo? personalInfo,
    ProfessionalInfo? professionalInfo,
    List<WorkExperience>? experiences,
    List<Education>? educations,
    List<PortfolioItem>? portfolioItems,
    String? profilePhotoPath,
    List<String>? documentPaths,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return UserProfile(
      personalInfo: personalInfo ?? this.personalInfo,
      professionalInfo: professionalInfo ?? this.professionalInfo,
      experiences: experiences ?? this.experiences,
      educations: educations ?? this.educations,
      portfolioItems: portfolioItems ?? this.portfolioItems,
      profilePhotoPath: profilePhotoPath ?? this.profilePhotoPath,
      documentPaths: documentPaths ?? this.documentPaths,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() => {
        'personalInfo': personalInfo.toJson(),
        'professionalInfo': professionalInfo.toJson(),
        'experiences': experiences.map((e) => e.toJson()).toList(),
        'educations': educations.map((e) => e.toJson()).toList(),
        'portfolioItems': portfolioItems.map((e) => e.toJson()).toList(),
        'profilePhotoPath': profilePhotoPath,
        'documentPaths': documentPaths,
        'createdAt': createdAt?.toIso8601String(),
        'updatedAt': updatedAt?.toIso8601String(),
      };

  factory UserProfile.fromJson(Map<String, dynamic>? json) {
    if (json == null) return UserProfile.empty();
    return UserProfile(
      personalInfo: PersonalInfo.fromJson(
        json['personalInfo'] as Map<String, dynamic>?,
      ),
      professionalInfo: ProfessionalInfo.fromJson(
        json['professionalInfo'] as Map<String, dynamic>?,
      ),
      experiences: (json['experiences'] as List<dynamic>?)
              ?.map((e) => WorkExperience.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
      educations: (json['educations'] as List<dynamic>?)
              ?.map((e) => Education.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
      portfolioItems: (json['portfolioItems'] as List<dynamic>?)
              ?.map((e) => PortfolioItem.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
      profilePhotoPath: json['profilePhotoPath'] as String? ?? '',
      documentPaths: (json['documentPaths'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          const [],
      createdAt: json['createdAt'] != null
          ? DateTime.tryParse(json['createdAt'] as String)
          : null,
      updatedAt: json['updatedAt'] != null
          ? DateTime.tryParse(json['updatedAt'] as String)
          : null,
    );
  }
}
