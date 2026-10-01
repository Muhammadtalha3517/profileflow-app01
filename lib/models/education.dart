class Education {
  final String id;
  final String institution;
  final String degree;
  final String fieldOfStudy;
  final DateTime? startDate;
  final DateTime? endDate;
  final bool isCurrent;
  final String description;

  const Education({
    required this.id,
    this.institution = '',
    this.degree = '',
    this.fieldOfStudy = '',
    this.startDate,
    this.endDate,
    this.isCurrent = false,
    this.description = '',
  });

  bool get isEmpty =>
      institution.isEmpty && degree.isEmpty && fieldOfStudy.isEmpty;

  bool get isNotEmpty => !isEmpty;

  String get degreeAndField {
    if (degree.isNotEmpty && fieldOfStudy.isNotEmpty) {
      return '$degree in $fieldOfStudy';
    }
    return degree.isNotEmpty ? degree : fieldOfStudy;
  }

  Education copyWith({
    String? id,
    String? institution,
    String? degree,
    String? fieldOfStudy,
    DateTime? startDate,
    DateTime? endDate,
    bool? isCurrent,
    String? description,
  }) {
    return Education(
      id: id ?? this.id,
      institution: institution ?? this.institution,
      degree: degree ?? this.degree,
      fieldOfStudy: fieldOfStudy ?? this.fieldOfStudy,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      isCurrent: isCurrent ?? this.isCurrent,
      description: description ?? this.description,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'institution': institution,
        'degree': degree,
        'fieldOfStudy': fieldOfStudy,
        'startDate': startDate?.toIso8601String(),
        'endDate': endDate?.toIso8601String(),
        'isCurrent': isCurrent,
        'description': description,
      };

  factory Education.fromJson(Map<String, dynamic> json) {
    return Education(
      id: json['id'] as String? ?? '',
      institution: json['institution'] as String? ?? '',
      degree: json['degree'] as String? ?? '',
      fieldOfStudy: json['fieldOfStudy'] as String? ?? '',
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
