class ProfessionalInfo {
  final String professionalTitle;
  final String overviewBio;
  final String hourlyRate;
  final String currency;
  final List<String> skills;
  final List<String> languages;
  final String yearsOfExperience;

  const ProfessionalInfo({
    this.professionalTitle = '',
    this.overviewBio = '',
    this.hourlyRate = '',
    this.currency = 'USD',
    this.skills = const [],
    this.languages = const [],
    this.yearsOfExperience = '',
  });

  factory ProfessionalInfo.empty() => const ProfessionalInfo();

  bool get isEmpty =>
      professionalTitle.isEmpty &&
      overviewBio.isEmpty &&
      hourlyRate.isEmpty &&
      skills.isEmpty &&
      languages.isEmpty &&
      yearsOfExperience.isEmpty;

  bool get isNotEmpty => !isEmpty;

  String get formattedRate {
    if (hourlyRate.trim().isEmpty) return '';
    return '$currency $hourlyRate/hr';
  }

  ProfessionalInfo copyWith({
    String? professionalTitle,
    String? overviewBio,
    String? hourlyRate,
    String? currency,
    List<String>? skills,
    List<String>? languages,
    String? yearsOfExperience,
  }) {
    return ProfessionalInfo(
      professionalTitle: professionalTitle ?? this.professionalTitle,
      overviewBio: overviewBio ?? this.overviewBio,
      hourlyRate: hourlyRate ?? this.hourlyRate,
      currency: currency ?? this.currency,
      skills: skills ?? this.skills,
      languages: languages ?? this.languages,
      yearsOfExperience: yearsOfExperience ?? this.yearsOfExperience,
    );
  }

  Map<String, dynamic> toJson() => {
        'professionalTitle': professionalTitle,
        'overviewBio': overviewBio,
        'hourlyRate': hourlyRate,
        'currency': currency,
        'skills': skills,
        'languages': languages,
        'yearsOfExperience': yearsOfExperience,
      };

  factory ProfessionalInfo.fromJson(Map<String, dynamic>? json) {
    if (json == null) return const ProfessionalInfo();
    return ProfessionalInfo(
      professionalTitle: json['professionalTitle'] as String? ?? '',
      overviewBio: json['overviewBio'] as String? ?? '',
      hourlyRate: json['hourlyRate'] as String? ?? '',
      currency: json['currency'] as String? ?? 'USD',
      skills: (json['skills'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          const [],
      languages: (json['languages'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          const [],
      yearsOfExperience: json['yearsOfExperience'] as String? ?? '',
    );
  }
}
