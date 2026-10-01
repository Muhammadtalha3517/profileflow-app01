import '../../models/user_profile.dart';

class ProfileCompletionCalculator {
  /// Calculates the completion percentage of a user profile (0 to 100)
  static int calculate(UserProfile profile) {
    if (profile.isCompletelyEmpty) return 0;

    int totalPoints = 0;
    const int maxPoints = 100;

    final p = profile.personalInfo;
    final prof = profile.professionalInfo;

    // Personal Info (35 points total)
    if (p.firstName.trim().isNotEmpty) totalPoints += 5;
    if (p.lastName.trim().isNotEmpty) totalPoints += 5;
    if (p.email.trim().isNotEmpty) totalPoints += 10;
    if (p.phone.trim().isNotEmpty) totalPoints += 5;
    if (p.country.trim().isNotEmpty) totalPoints += 3;
    if (p.city.trim().isNotEmpty) totalPoints += 3;
    if (p.address.trim().isNotEmpty || p.postalCode.trim().isNotEmpty) totalPoints += 4;

    // Professional Info (30 points total)
    if (prof.professionalTitle.trim().isNotEmpty) totalPoints += 10;
    if (prof.overviewBio.trim().isNotEmpty) totalPoints += 8;
    if (prof.skills.isNotEmpty) totalPoints += 6;
    if (prof.languages.isNotEmpty) totalPoints += 3;
    if (prof.yearsOfExperience.trim().isNotEmpty || prof.hourlyRate.trim().isNotEmpty) totalPoints += 3;

    // Work Experience (15 points)
    if (profile.experiences.isNotEmpty) {
      totalPoints += 15;
    }

    // Education (10 points)
    if (profile.educations.isNotEmpty) {
      totalPoints += 10;
    }

    // Portfolio & Documents (10 points)
    if (profile.portfolioItems.isNotEmpty) totalPoints += 5;
    if (profile.profilePhotoPath.isNotEmpty || profile.documentPaths.isNotEmpty) totalPoints += 5;

    return totalPoints.clamp(0, maxPoints);
  }

  static String getCompletionStatusLabel(int percentage) {
    if (percentage == 0) return 'Profile Empty';
    if (percentage < 30) return 'Getting Started';
    if (percentage < 70) return 'In Progress';
    if (percentage < 90) return 'Almost Complete';
    return 'Fully Completed';
  }
}
