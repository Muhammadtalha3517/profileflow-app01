import 'package:flutter_test/flutter_test.dart';
import 'package:profileflow_assistant/models/user_profile.dart';
import 'package:profileflow_assistant/models/personal_info.dart';
import 'package:profileflow_assistant/models/professional_info.dart';
import 'package:profileflow_assistant/models/form_field_match.dart';
import 'package:profileflow_assistant/field_mapping/field_matcher_engine.dart';

void main() {
  group('FieldMatcherEngine Unit Tests', () {
    const testProfile = UserProfile(
      personalInfo: PersonalInfo(
        firstName: 'Jane',
        lastName: 'Doe',
        email: 'jane.doe@example.com',
        phone: '+15551234567',
        city: 'San Francisco',
        country: 'United States',
      ),
      professionalInfo: ProfessionalInfo(
        professionalTitle: 'Lead Mobile Architect',
        overviewBio: '10+ years engineering scalable applications.',
        hourlyRate: '85',
        currency: 'USD',
        skills: ['Flutter', 'Dart', 'Android', 'Kotlin'],
      ),
    );

    test('should match First Name with high confidence via label', () {
      final rawFields = [
        {
          'elementId': 'f_fname',
          'name': 'firstName',
          'type': 'text',
          'label': 'First Name',
          'placeholder': 'Enter your first name',
          'selector': '#f_fname',
        }
      ];

      final results = FieldMatcherEngine.matchFields(
        rawFields: rawFields,
        profile: testProfile,
      );

      expect(results.length, 1);
      final match = results.first;
      expect(match.confidence, MatchConfidence.high);
      expect(match.effectiveFillValue, 'Jane');
      expect(match.isSelected, true);
    });

    test('should match Email via autocomplete and placeholder', () {
      final rawFields = [
        {
          'elementId': 'input_email',
          'name': 'user_email',
          'type': 'email',
          'autocomplete': 'email',
          'placeholder': 'name@domain.com',
          'selector': '#input_email',
        }
      ];

      final results = FieldMatcherEngine.matchFields(
        rawFields: rawFields,
        profile: testProfile,
      );

      expect(results.length, 1);
      final match = results.first;
      expect(match.confidence, MatchConfidence.high);
      expect(match.effectiveFillValue, 'jane.doe@example.com');
      expect(match.isSelected, true);
    });

    test('should match Professional Title with synonym Headline', () {
      final rawFields = [
        {
          'elementId': 'input_headline',
          'name': 'headline',
          'type': 'text',
          'label': 'Professional Headline',
          'placeholder': 'e.g. Senior Software Engineer',
          'selector': '#input_headline',
        }
      ];

      final results = FieldMatcherEngine.matchFields(
        rawFields: rawFields,
        profile: testProfile,
      );

      expect(results.length, 1);
      final match = results.first;
      expect(match.confidence, MatchConfidence.high);
      expect(match.effectiveFillValue, 'Lead Mobile Architect');
    });

    test('should mark unknown field as uncertain without guessing', () {
      final rawFields = [
        {
          'elementId': 'custom_random_code',
          'name': 'x_factor_token_99',
          'type': 'text',
          'label': 'Special Code #99',
          'placeholder': '',
          'selector': '#custom_random_code',
        }
      ];

      final results = FieldMatcherEngine.matchFields(
        rawFields: rawFields,
        profile: testProfile,
      );

      expect(results.length, 1);
      final match = results.first;
      expect(match.confidence, MatchConfidence.uncertain);
      expect(match.effectiveFillValue, '');
      expect(match.isSelected, false);
    });
  });
}
