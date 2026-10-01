class WorkExperience {
  final String id;
  final String company;
  final String jobTitle;
  final DateTime? startDate;
  final DateTime? endDate;
  final bool isCurrent;
  final String description;

  const WorkExperience({
    required this.id,
    this.company = '',
    this.jobTitle = '',
    this.startDate,
    this.endDate,
    this.isCurrent = false,
    this.description = '',
  });

  bool get isEmpty =>
      company.isEmpty && jobTitle.isEmpty && description.isEmpty;

  bool get isNotEmpty => !isEmpty;

  WorkExperience copyWith({
    String? id,
    String? company,
    String? jobTitle,
    DateTime? startDate,
    DateTime? endDate,
    bool? isCurrent,
    String? description,
  }) {
    return WorkExperience(
      id: id ?? this.id,
      company: company ?? this.company,
      jobTitle: jobTitle ?? this.jobTitle,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      isCurrent: isCurrent ?? this.isCurrent,
      description: description ?? this.description,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'company': company,
        'jobTitle': jobTitle,
        'startDate': startDate?.toIso8601String(),
        'endDate': endDate?.toIso8601String(),
        'isCurrent': isCurrent,
        'description': description,
      };

  factory WorkExperience.fromJson(Map<String, dynamic> json) {
    return WorkExperience(
      id: json['id'] as String? ?? '',
      company: json['company'] as String? ?? '',
      jobTitle: json['jobTitle'] as String? ?? '',
      startDate: json['startDate'] != null
          ? DateTime.tryParse(json['startDate'] as String)
          : null,
      endDate: json['endDate'] != null
          ? DateTime.tryParse(json['endDate'] as String)
          : null,
      isCurrent: json['isCurrent'] as bool? ?? false,
      description: json['description'] as String? ?? '',
    );
  }
}
