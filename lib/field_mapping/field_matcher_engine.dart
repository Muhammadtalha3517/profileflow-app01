import '../models/user_profile.dart';
import '../models/form_field_match.dart';
import 'field_definition.dart';
import 'heuristic_rules.dart';

class FieldMatcherEngine {
  /// Matches a list of raw scanned DOM fields against the user's authentic profile.
  static List<FormFieldMatch> matchFields({
    required List<Map<String, dynamic>> rawFields,
    required UserProfile profile,
  }) {
    final matches = <FormFieldMatch>[];

    for (final raw in rawFields) {
      final match = _matchSingleField(raw, profile);
      matches.add(match);
    }

    return matches;
  }

  static FormFieldMatch _matchSingleField(
    Map<String, dynamic> raw,
    UserProfile profile,
  ) {
    final elementId = raw['elementId'] as String? ?? '';
    final name = raw['name'] as String? ?? '';
    final type = (raw['type'] as String? ?? 'text').toLowerCase();
    final tagName = (raw['tagName'] as String? ?? 'INPUT').toUpperCase();
    final placeholder = raw['placeholder'] as String? ?? '';
    final label = raw['label'] as String? ?? '';
    final ariaLabel = raw['ariaLabel'] as String? ?? '';
    final autocomplete = (raw['autocomplete'] as String? ?? '').toLowerCase();
    final selector = raw['selector'] as String? ?? '';
    final surroundingText = raw['surroundingText'] as String? ?? '';

    // Ignore submit / button / hidden / password fields for form filling
    if (type == 'hidden' || type == 'submit' || type == 'password') {
      return FormFieldMatch(
        elementId: elementId,
        name: name,
        type: type,
        tagName: tagName,
        placeholder: placeholder,
        label: label,
        ariaLabel: ariaLabel,
        autocomplete: autocomplete,
        selector: selector,
        isSelected: false,
        confidence: MatchConfidence.uncertain,
        reasoning: 'Field type ($type) is ignored for profile autofill.',
      );
    }

    // Evaluate against all definitions
    ProfileFieldDefinition? bestDef;
    double highestScore = 0.0;
    String matchReason = '';

    for (final def in ProfileFieldDefinitions.all) {
      double score = 0.0;

      // 1. Exact Autocomplete Match (Strongest signal)
      if (autocomplete.isNotEmpty) {
        for (final auto in def.autocompleteAttributes) {
          if (autocomplete == auto || autocomplete.contains(auto)) {
            score = 0.95;
            matchReason = 'Matched browser autocomplete="$autocomplete"';
            break;
          }
        }
      }

      // 2. Exact / Synonym Label Match
      if (score < 0.90 && label.isNotEmpty) {
        final normLabel = HeuristicRules.normalize(label);
        for (final syn in def.synonyms) {
          if (normLabel == syn) {
            score = 0.90;
            matchReason = 'Matched exact label: "$label"';
            break;
          } else if (normLabel.contains(syn) || syn.contains(normLabel)) {
            final sim = HeuristicRules.calculateSimilarity(normLabel, syn);
            final s = 0.70 + (sim * 0.18);
            if (s > score) {
              score = s;
              matchReason = 'Matched label keyword: "$label"';
            }
          }
        }
      }

      // 3. Aria-Label Match
      if (score < 0.85 && ariaLabel.isNotEmpty) {
        final normAria = HeuristicRules.normalize(ariaLabel);
        for (final syn in def.synonyms) {
          if (normAria == syn || normAria.contains(syn)) {
            score = 0.82;
            matchReason = 'Matched accessibility aria-label: "$ariaLabel"';
            break;
          }
        }
      }

      // 4. Placeholder Match
      if (score < 0.80 && placeholder.isNotEmpty) {
        final normPl = HeuristicRules.normalize(placeholder);
        for (final syn in def.synonyms) {
          if (normPl == syn || normPl.contains(syn)) {
            final s = 0.75;
            if (s > score) {
              score = s;
              matchReason = 'Matched placeholder: "$placeholder"';
            }
          }
        }
      }

      // 5. Name / ID Attribute Match
      if (score < 0.75 && (name.isNotEmpty || elementId.isNotEmpty)) {
        final normName = HeuristicRules.normalize(name.isNotEmpty ? name : elementId);
        for (final syn in def.synonyms) {
          if (normName.contains(syn.replaceAll(' ', '')) || normName.contains(syn)) {
            final s = 0.70;
            if (s > score) {
              score = s;
              matchReason = 'Matched attribute name/id: "$name"';
            }
          }
        }
      }

      // 6. Surrounding Text / Context Match
      if (score < 0.60 && surroundingText.isNotEmpty) {
        final normSurr = HeuristicRules.normalize(surroundingText);
        for (final syn in def.synonyms) {
          if (normSurr.contains(syn)) {
            final s = 0.55;
            if (s > score) {
              score = s;
              matchReason = 'Context keyword match: "$syn"';
            }
          }
        }
      }

      if (score > highestScore) {
        highestScore = score;
        bestDef = def;
      }
    }

    // Determine Confidence Level
    MatchConfidence confidence;
    bool isAmbiguous = false;

    if (highestScore >= 0.80) {
      confidence = MatchConfidence.high;
    } else if (highestScore >= 0.60) {
      confidence = MatchConfidence.medium;
    } else {
      confidence = MatchConfidence.uncertain;
      if (highestScore > 0.30) {
        isAmbiguous = true;
      }
    }

    // Extract real profile value
    String suggestedValue = '';
    if (bestDef != null && confidence != MatchConfidence.uncertain) {
      suggestedValue = _extractValueFromProfile(bestDef.key, profile);
    }

    return FormFieldMatch(
      elementId: elementId,
      name: name,
      type: type,
      tagName: tagName,
      placeholder: placeholder,
      label: label,
      ariaLabel: ariaLabel,
      autocomplete: autocomplete,
      selector: selector,
      mappedProfileKey: bestDef?.key,
      mappedProfileCategory: bestDef?.category,
      mappedLabel: bestDef?.label ?? 'Custom Field',
      suggestedValue: suggestedValue,
      userSelectedValue: suggestedValue,
      confidence: confidence,
      confidenceScore: highestScore,
      isSelected: confidence == MatchConfidence.high && suggestedValue.isNotEmpty,
      isAmbiguous: isAmbiguous,
      reasoning: matchReason.isNotEmpty
          ? matchReason
          : 'Could not confidently match this field to saved profile.',
    );
  }

  static String _extractValueFromProfile(String key, UserProfile profile) {
    final p = profile.personalInfo;
    final prof = profile.professionalInfo;

    switch (key) {
      case 'personal.firstName':
        return p.firstName;
      case 'personal.lastName':
        return p.lastName;
      case 'personal.fullName':
        return p.effectiveFullName;
      case 'personal.email':
        return p.email;
      case 'personal.phone':
        return p.phone;
      case 'personal.country':
        return p.country;
      case 'personal.city':
        return p.city;
      case 'personal.address':
        return p.address;
      case 'personal.postalCode':
        return p.postalCode;
      case 'professional.professionalTitle':
        return prof.professionalTitle;
      case 'professional.overviewBio':
        return prof.overviewBio;
      case 'professional.hourlyRate':
        return prof.hourlyRate;
      case 'professional.skills':
        return prof.skills.join(', ');
      case 'professional.languages':
        return prof.languages.join(', ');
      case 'professional.yearsOfExperience':
        return prof.yearsOfExperience;
      case 'experience.latestCompany':
        return profile.experiences.isNotEmpty ? profile.experiences.first.company : '';
      case 'education.latestSchool':
        return profile.educations.isNotEmpty ? profile.educations.first.institution : '';
      case 'education.latestDegree':
        return profile.educations.isNotEmpty ? profile.educations.first.degreeAndField : '';
      case 'portfolio.websiteUrl':
        return profile.portfolioItems.isNotEmpty ? profile.portfolioItems.first.projectUrl : '';
      default:
        return '';
    }
  }
}
