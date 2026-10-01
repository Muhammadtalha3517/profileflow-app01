class PortfolioItem {
  final String id;
  final String projectName;
  final String projectDescription;
  final String projectUrl;
  final List<String> skillsUsed;
  final List<String> imagePaths;

  const PortfolioItem({
    required this.id,
    this.projectName = '',
    this.projectDescription = '',
    this.projectUrl = '',
    this.skillsUsed = const [],
    this.imagePaths = const [],
  });

  bool get isEmpty =>
      projectName.isEmpty && projectDescription.isEmpty && projectUrl.isEmpty;

  bool get isNotEmpty => !isEmpty;

  PortfolioItem copyWith({
    String? id,
    String? projectName,
    String? projectDescription,
    String? projectUrl,
    List<String>? skillsUsed,
    List<String>? imagePaths,
  }) {
    return PortfolioItem(
      id: id ?? this.id,
      projectName: projectName ?? this.projectName,
      projectDescription: projectDescription ?? this.projectDescription,
      projectUrl: projectUrl ?? this.projectUrl,
      skillsUsed: skillsUsed ?? this.skillsUsed,
      imagePaths: imagePaths ?? this.imagePaths,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'projectName': projectName,
        'projectDescription': projectDescription,
        'projectUrl': projectUrl,
        'skillsUsed': skillsUsed,
        'imagePaths': imagePaths,
      };

  factory PortfolioItem.fromJson(Map<String, dynamic> json) {
    return PortfolioItem(
      id: json['id'] as String? ?? '',
      projectName: json['projectName'] as String? ?? '',
      projectDescription: json['projectDescription'] as String? ?? '',
      projectUrl: json['projectUrl'] as String? ?? '',
      skillsUsed: (json['skillsUsed'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          const [],
      imagePaths: (json['imagePaths'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          const [],
    );
  }
}
