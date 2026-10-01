enum MatchConfidence {
  high,
  medium,
  uncertain,
}

class FormFieldMatch {
  final String elementId;
  final String name;
  final String type;
  final String tagName;
  final String placeholder;
  final String label;
  final String ariaLabel;
  final String autocomplete;
  final String selector;

  // Mapping result
  final String? mappedProfileKey;
  final String? mappedProfileCategory;
  final String mappedLabel;
  final String suggestedValue;
  final String userSelectedValue;
  final MatchConfidence confidence;
  final double confidenceScore;
  final bool isSelected;
  final bool isAmbiguous;
  final bool isManualOverride;
  final String reasoning;

  const FormFieldMatch({
    required this.elementId,
    this.name = '',
    this.type = 'text',
    this.tagName = 'INPUT',
    this.placeholder = '',
    this.label = '',
    this.ariaLabel = '',
    this.autocomplete = '',
    this.selector = '',
    this.mappedProfileKey,
    this.mappedProfileCategory,
    this.mappedLabel = '',
    this.suggestedValue = '',
    this.userSelectedValue = '',
    this.confidence = MatchConfidence.uncertain,
    this.confidenceScore = 0.0,
    this.isSelected = true,
    this.isAmbiguous = false,
    this.isManualOverride = false,
    this.reasoning = '',
  });

  String get effectiveFillValue {
    if (isManualOverride) return userSelectedValue;
    return suggestedValue.isNotEmpty ? suggestedValue : userSelectedValue;
  }

  String get displayIdentifier {
    if (label.isNotEmpty) return label;
    if (placeholder.isNotEmpty) return 'Placeholder: "$placeholder"';
    if (ariaLabel.isNotEmpty) return 'Aria: "$ariaLabel"';
    if (name.isNotEmpty) return 'Field: "$name"';
    return 'Element #$elementId';
  }

  FormFieldMatch copyWith({
    String? elementId,
    String? name,
    String? type,
    String? tagName,
    String? placeholder,
    String? label,
    String? ariaLabel,
    String? autocomplete,
    String? selector,
    String? mappedProfileKey,
    String? mappedProfileCategory,
    String? mappedLabel,
    String? suggestedValue,
    String? userSelectedValue,
    MatchConfidence? confidence,
    double? confidenceScore,
    bool? isSelected,
    bool? isAmbiguous,
    bool? isManualOverride,
    String? reasoning,
  }) {
    return FormFieldMatch(
      elementId: elementId ?? this.elementId,
      name: name ?? this.name,
      type: type ?? this.type,
      tagName: tagName ?? this.tagName,
      placeholder: placeholder ?? this.placeholder,
      label: label ?? this.label,
      ariaLabel: ariaLabel ?? this.ariaLabel,
      autocomplete: autocomplete ?? this.autocomplete,
      selector: selector ?? this.selector,
      mappedProfileKey: mappedProfileKey ?? this.mappedProfileKey,
      mappedProfileCategory: mappedProfileCategory ?? this.mappedProfileCategory,
      mappedLabel: mappedLabel ?? this.mappedLabel,
      suggestedValue: suggestedValue ?? this.suggestedValue,
      userSelectedValue: userSelectedValue ?? this.userSelectedValue,
      confidence: confidence ?? this.confidence,
      confidenceScore: confidenceScore ?? this.confidenceScore,
      isSelected: isSelected ?? this.isSelected,
      isAmbiguous: isAmbiguous ?? this.isAmbiguous,
      isManualOverride: isManualOverride ?? this.isManualOverride,
      reasoning: reasoning ?? this.reasoning,
    );
  }

  Map<String, dynamic> toJson() => {
        'elementId': elementId,
        'name': name,
        'type': type,
        'tagName': tagName,
        'placeholder': placeholder,
        'label': label,
        'ariaLabel': ariaLabel,
        'autocomplete': autocomplete,
        'selector': selector,
        'mappedProfileKey': mappedProfileKey,
        'mappedProfileCategory': mappedProfileCategory,
        'mappedLabel': mappedLabel,
        'suggestedValue': suggestedValue,
        'userSelectedValue': userSelectedValue,
        'confidence': confidence.name,
        'confidenceScore': confidenceScore,
        'isSelected': isSelected,
        'isAmbiguous': isAmbiguous,
        'isManualOverride': isManualOverride,
        'reasoning': reasoning,
      };

  factory FormFieldMatch.fromJson(Map<String, dynamic> json) {
    return FormFieldMatch(
      elementId: json['elementId'] as String? ?? '',
      name: json['name'] as String? ?? '',
      type: json['type'] as String? ?? 'text',
      tagName: json['tagName'] as String? ?? 'INPUT',
      placeholder: json['placeholder'] as String? ?? '',
      label: json['label'] as String? ?? '',
      ariaLabel: json['ariaLabel'] as String? ?? '',
      autocomplete: json['autocomplete'] as String? ?? '',
      selector: json['selector'] as String? ?? '',
      mappedProfileKey: json['mappedProfileKey'] as String?,
      mappedProfileCategory: json['mappedProfileCategory'] as String?,
      mappedLabel: json['mappedLabel'] as String? ?? '',
      suggestedValue: json['suggestedValue'] as String? ?? '',
      userSelectedValue: json['userSelectedValue'] as String? ?? '',
      confidence: MatchConfidence.values.firstWhere(
        (e) => e.name == json['confidence'],
        orElse: () => MatchConfidence.uncertain,
      ),
      confidenceScore: (json['confidenceScore'] as num?)?.toDouble() ?? 0.0,
      isSelected: json['isSelected'] as bool? ?? true,
      isAmbiguous: json['isAmbiguous'] as bool? ?? false,
      isManualOverride: json['isManualOverride'] as bool? ?? false,
      reasoning: json['reasoning'] as String? ?? '',
    );
  }
}
