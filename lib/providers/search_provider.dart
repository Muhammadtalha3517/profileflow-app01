import 'package:flutter/material.dart';
import '../models/user_profile.dart';

class SearchResultItem {
  final String category;
  final String label;
  final String value;
  final String subtext;
  final IconData icon;

  const SearchResultItem({
    required this.category,
    required this.label,
    required this.value,
    this.subtext = '',
    required this.icon,
  });
}

class SearchProvider with ChangeNotifier {
  String _query = '';
  String _selectedFilter = 'All';
  List<SearchResultItem> _results = [];

  String get query => _query;
  String get selectedFilter => _selectedFilter;
  List<SearchResultItem> get results => _results;

  final List<String> availableFilters = [
    'All',
    'Personal',
    'Professional',
    'Experience',
    'Education',
    'Skills',
    'Portfolio',
  ];

  void setFilter(String filter, UserProfile profile) {
    _selectedFilter = filter;
    search(_query, profile);
  }

  void search(String query, UserProfile profile) {
    _query = query.trim().toLowerCase();
    final allItems = _buildAllProfileItems(profile);

    if (_query.isEmpty) {
      if (_selectedFilter == 'All') {
        _results = allItems;
      } else {
        _results = allItems.where((item) => item.category == _selectedFilter).toList();
      }
    } else {
      _results = allItems.where((item) {
        final matchesFilter = _selectedFilter == 'All' || item.category == _selectedFilter;
        final matchesQuery = item.label.toLowerCase().contains(_query) ||
            item.value.toLowerCase().contains(_query) ||
            item.subtext.toLowerCase().contains(_query) ||
            item.category.toLowerCase().contains(_query);
        return matchesFilter && matchesQuery;
      }).toList();
    }

    notifyListeners();
  }

  List<SearchResultItem> _buildAllProfileItems(UserProfile profile) {
    final list = <SearchResultItem>[];
    final p = profile.personalInfo;
    final prof = profile.professionalInfo;

    // Personal Info
    if (p.firstName.isNotEmpty) {
      list.add(SearchResultItem(category: 'Personal', label: 'First Name', value: p.firstName, icon: Icons.person_outline));
    }
    if (p.lastName.isNotEmpty) {
      list.add(SearchResultItem(category: 'Personal', label: 'Last Name', value: p.lastName, icon: Icons.person_outline));
    }
    if (p.fullName.isNotEmpty) {
      list.add(SearchResultItem(category: 'Personal', label: 'Full Name', value: p.fullName, icon: Icons.badge_outlined));
    }
    if (p.email.isNotEmpty) {
      list.add(SearchResultItem(category: 'Personal', label: 'Email', value: p.email, icon: Icons.email_outlined));
    }
    if (p.phone.isNotEmpty) {
      list.add(SearchResultItem(category: 'Personal', label: 'Phone', value: p.phone, icon: Icons.phone_outlined));
    }
    if (p.country.isNotEmpty) {
      list.add(SearchResultItem(category: 'Personal', label: 'Country', value: p.country, icon: Icons.public_outlined));
    }
    if (p.city.isNotEmpty) {
      list.add(SearchResultItem(category: 'Personal', label: 'City', value: p.city, icon: Icons.location_city_outlined));
    }
    if (p.address.isNotEmpty) {
      list.add(SearchResultItem(category: 'Personal', label: 'Address', value: p.address, icon: Icons.home_outlined));
    }
    if (p.postalCode.isNotEmpty) {
      list.add(SearchResultItem(category: 'Personal', label: 'Postal Code', value: p.postalCode, icon: Icons.markunread_mailbox_outlined));
    }

    // Professional Info
    if (prof.professionalTitle.isNotEmpty) {
      list.add(SearchResultItem(category: 'Professional', label: 'Professional Title', value: prof.professionalTitle, icon: Icons.work_outline));
    }
    if (prof.overviewBio.isNotEmpty) {
      list.add(SearchResultItem(category: 'Professional', label: 'Overview / Bio', value: prof.overviewBio, icon: Icons.description_outlined));
    }
    if (prof.hourlyRate.isNotEmpty) {
      list.add(SearchResultItem(category: 'Professional', label: 'Hourly Rate', value: prof.formattedRate, icon: Icons.payments_outlined));
    }
    if (prof.yearsOfExperience.isNotEmpty) {
      list.add(SearchResultItem(category: 'Professional', label: 'Years of Experience', value: '${prof.yearsOfExperience} Years', icon: Icons.timeline_outlined));
    }

    // Skills
    for (final skill in prof.skills) {
      if (skill.isNotEmpty) {
        list.add(SearchResultItem(category: 'Skills', label: 'Skill', value: skill, icon: Icons.psychology_outlined));
      }
    }

    // Languages
    for (final lang in prof.languages) {
      if (lang.isNotEmpty) {
        list.add(SearchResultItem(category: 'Professional', label: 'Language', value: lang, icon: Icons.translate_outlined));
      }
    }

    // Experience
    for (final exp in profile.experiences) {
      if (exp.isNotEmpty) {
        list.add(SearchResultItem(
          category: 'Experience',
          label: exp.jobTitle.isNotEmpty ? exp.jobTitle : 'Role',
          value: exp.company,
          subtext: exp.description,
          icon: Icons.business_center_outlined,
        ));
      }
    }

    // Education
    for (final edu in profile.educations) {
      if (edu.isNotEmpty) {
        list.add(SearchResultItem(
          category: 'Education',
          label: edu.degreeAndField.isNotEmpty ? edu.degreeAndField : 'Degree',
          value: edu.institution,
          subtext: edu.description,
          icon: Icons.school_outlined,
        ));
      }
    }

    // Portfolio
    for (final port in profile.portfolioItems) {
      if (port.isNotEmpty) {
        list.add(SearchResultItem(
          category: 'Portfolio',
          label: port.projectName.isNotEmpty ? port.projectName : 'Project',
          value: port.projectUrl.isNotEmpty ? port.projectUrl : port.projectDescription,
          subtext: port.skillsUsed.join(', '),
          icon: Icons.folder_special_outlined,
        ));
      }
    }

    return list;
  }
}
