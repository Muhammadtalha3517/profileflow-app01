import 'package:flutter/material.dart';
import '../models/user_profile.dart';
import '../models/personal_info.dart';
import '../models/professional_info.dart';
import '../models/work_experience.dart';
import '../models/education.dart';
import '../models/portfolio_item.dart';
import '../database/local_database.dart';
import '../core/utils/profile_completion_calculator.dart';

class ProfileProvider with ChangeNotifier {
  final LocalDatabase _db = LocalDatabase();

  UserProfile _profile = UserProfile.empty();
  bool _isLoading = true;
  bool _hasLoaded = false;
  String? _errorMessage;

  UserProfile get profile => _profile;
  bool get isLoading => _isLoading;
  bool get hasLoaded => _hasLoaded;
  String? get errorMessage => _errorMessage;

  int get completionPercentage => ProfileCompletionCalculator.calculate(_profile);
  String get completionStatus => ProfileCompletionCalculator.getCompletionStatusLabel(completionPercentage);

  Future<void> loadProfile() async {
    _isLoading = true;
    notifyListeners();

    try {
      _profile = await _db.loadProfile();
      _errorMessage = null;
    } catch (e) {
      _errorMessage = 'Failed to load profile: $e';
    } finally {
      _isLoading = false;
      _hasLoaded = true;
      notifyListeners();
    }
  }

  Future<void> saveProfile(UserProfile updatedProfile) async {
    _isLoading = true;
    notifyListeners();

    try {
      _profile = updatedProfile.copyWith(updatedAt: DateTime.now());
      await _db.saveProfile(_profile);
      _errorMessage = null;
    } catch (e) {
      _errorMessage = 'Failed to save profile: $e';
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> updatePersonalInfo(PersonalInfo personalInfo) async {
    final updated = _profile.copyWith(personalInfo: personalInfo);
    await saveProfile(updated);
  }

  Future<void> updateProfessionalInfo(ProfessionalInfo professionalInfo) async {
    final updated = _profile.copyWith(professionalInfo: professionalInfo);
    await saveProfile(updated);
  }

  Future<void> addExperience(WorkExperience experience) async {
    final updatedList = List<WorkExperience>.from(_profile.experiences)..add(experience);
    final updated = _profile.copyWith(experiences: updatedList);
    await saveProfile(updated);
  }

  Future<void> updateExperience(int index, WorkExperience experience) async {
    if (index >= 0 && index < _profile.experiences.length) {
      final updatedList = List<WorkExperience>.from(_profile.experiences);
      updatedList[index] = experience;
      final updated = _profile.copyWith(experiences: updatedList);
      await saveProfile(updated);
    }
  }

  Future<void> removeExperience(int index) async {
    if (index >= 0 && index < _profile.experiences.length) {
      final updatedList = List<WorkExperience>.from(_profile.experiences)..removeAt(index);
      final updated = _profile.copyWith(experiences: updatedList);
      await saveProfile(updated);
    }
  }

  Future<void> addEducation(Education education) async {
    final updatedList = List<Education>.from(_profile.educations)..add(education);
    final updated = _profile.copyWith(educations: updatedList);
    await saveProfile(updated);
  }

  Future<void> updateEducation(int index, Education education) async {
    if (index >= 0 && index < _profile.educations.length) {
      final updatedList = List<Education>.from(_profile.educations);
      updatedList[index] = education;
      final updated = _profile.copyWith(educations: updatedList);
      await saveProfile(updated);
    }
  }

  Future<void> removeEducation(int index) async {
    if (index >= 0 && index < _profile.educations.length) {
      final updatedList = List<Education>.from(_profile.educations)..removeAt(index);
      final updated = _profile.copyWith(educations: updatedList);
      await saveProfile(updated);
    }
  }

  Future<void> addPortfolioItem(PortfolioItem item) async {
    final updatedList = List<PortfolioItem>.from(_profile.portfolioItems)..add(item);
    final updated = _profile.copyWith(portfolioItems: updatedList);
    await saveProfile(updated);
  }

  Future<void> updatePortfolioItem(int index, PortfolioItem item) async {
    if (index >= 0 && index < _profile.portfolioItems.length) {
      final updatedList = List<PortfolioItem>.from(_profile.portfolioItems);
      updatedList[index] = item;
      final updated = _profile.copyWith(portfolioItems: updatedList);
      await saveProfile(updated);
    }
  }

  Future<void> removePortfolioItem(int index) async {
    if (index >= 0 && index < _profile.portfolioItems.length) {
      final updatedList = List<PortfolioItem>.from(_profile.portfolioItems)..removeAt(index);
      final updated = _profile.copyWith(portfolioItems: updatedList);
      await saveProfile(updated);
    }
  }

  Future<void> setProfilePhoto(String path) async {
    final updated = _profile.copyWith(profilePhotoPath: path);
    await saveProfile(updated);
  }

  Future<void> addDocumentPath(String path) async {
    final updatedList = List<String>.from(_profile.documentPaths)..add(path);
    final updated = _profile.copyWith(documentPaths: updatedList);
    await saveProfile(updated);
  }

  Future<void> removeDocumentPath(int index) async {
    if (index >= 0 && index < _profile.documentPaths.length) {
      final updatedList = List<String>.from(_profile.documentPaths)..removeAt(index);
      final updated = _profile.copyWith(documentPaths: updatedList);
      await saveProfile(updated);
    }
  }

  Future<void> clearAllProfileData() async {
    _profile = UserProfile.empty();
    await _db.clearAllData();
    notifyListeners();
  }
}
