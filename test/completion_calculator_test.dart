import 'package:flutter_test/flutter_test.dart';
import 'package:profileflow_assistant/models/user_profile.dart';
import 'package:profileflow_assistant/models/personal_info.dart';
import 'package:profileflow_assistant/models/professional_info.dart';
import 'package:profileflow_assistant/models/work_experience.dart';
import 'package:profileflow_assistant/models/education.dart';
import 'package:profileflow_assistant/core/utils/profile_completion_calculator.dart';

void main() {
  group('ProfileCompletionCalculator Tests', () {
    test('Empty profile returns 0 percent', () {
      final profile = UserProfile.empty();
      final percentage = ProfileCompletionCalculator.calculate(profile);
      expect(percentage, 0);
    });

    test('Partially filled profile calculates proportionate score', () {
      const profile = UserProfile(
        personalInfo: PersonalInfo(
          firstName: 'Jane',
          lastName: 'Doe',
          email: 'jane@example.com',
          phone: '+123456789',
        ),
        professionalInfo: ProfessionalInfo(
          professionalTitle: 'Lead Architect',
          skills: ['Flutter', 'Dart'],
        ),
        experiences: [
          WorkExperience(
            id: '1',
            company: 'TechCorp',
            jobTitle: 'Developer',
            startDate: '2020',
            endDate: '2024',
          )
        ],
        educations: [
          Education(
            id: '1',
            institution: 'University of Tech',
            degree: 'BSc',
            fieldOfStudy: 'Computer Science',
            startDate: '2016',
            endDate: '2020',
          )
        ],
      );

      final percentage = ProfileCompletionCalculator.calculate(profile);
      expect(percentage, greaterThan(60));
    });
  });
}
