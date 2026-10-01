class ProfileFieldDefinition {
  final String key;
  final String label;
  final String category;
  final List<String> autocompleteAttributes;
  final List<String> synonyms;
  final String? regexPattern;

  const ProfileFieldDefinition({
    required this.key,
    required this.label,
    required this.category,
    this.autocompleteAttributes = const [],
    this.synonyms = const [],
    this.regexPattern,
  });
}

class ProfileFieldDefinitions {
  static const List<ProfileFieldDefinition> all = [
    // Personal Info
    ProfileFieldDefinition(
      key: 'personal.firstName',
      label: 'First Name',
      category: 'Personal',
      autocompleteAttributes: ['given-name', 'fname', 'first-name'],
      synonyms: ['first name', 'given name', 'fname', 'forename', 'prenom', 'primer nombre'],
    ),
    ProfileFieldDefinition(
      key: 'personal.lastName',
      label: 'Last Name',
      category: 'Personal',
      autocompleteAttributes: ['family-name', 'lname', 'last-name', 'surname'],
      synonyms: ['last name', 'family name', 'lname', 'surname', 'apellido', 'nom de famille'],
    ),
    ProfileFieldDefinition(
      key: 'personal.fullName',
      label: 'Full Name',
      category: 'Personal',
      autocompleteAttributes: ['name', 'full-name'],
      synonyms: ['full name', 'your name', 'complete name', 'nombre completo', 'applicant name'],
    ),
    ProfileFieldDefinition(
      key: 'personal.email',
      label: 'Email Address',
      category: 'Personal',
      autocompleteAttributes: ['email', 'user-email'],
      synonyms: ['email', 'e-mail', 'email address', 'correo', 'courriel', 'mail'],
    ),
    ProfileFieldDefinition(
      key: 'personal.phone',
      label: 'Phone Number',
      category: 'Personal',
      autocompleteAttributes: ['tel', 'phone', 'mobile', 'tel-national'],
      synonyms: ['phone', 'mobile', 'telephone', 'cell', 'phone number', 'contact number', 'telefono'],
    ),
    ProfileFieldDefinition(
      key: 'personal.country',
      label: 'Country',
      category: 'Personal',
      autocompleteAttributes: ['country', 'country-name'],
      synonyms: ['country', 'nation', 'pais', 'pays'],
    ),
    ProfileFieldDefinition(
      key: 'personal.city',
      label: 'City',
      category: 'Personal',
      autocompleteAttributes: ['address-level2', 'city'],
      synonyms: ['city', 'town', 'municipality', 'ciudad', 'ville'],
    ),
    ProfileFieldDefinition(
      key: 'personal.address',
      label: 'Street Address',
      category: 'Personal',
      autocompleteAttributes: ['street-address', 'address-line1'],
      synonyms: ['street address', 'address', 'address line 1', 'residence', 'direccion'],
    ),
    ProfileFieldDefinition(
      key: 'personal.postalCode',
      label: 'Postal / ZIP Code',
      category: 'Personal',
      autocompleteAttributes: ['postal-code', 'zip', 'zipcode'],
      synonyms: ['postal code', 'zip code', 'zip', 'postcode', 'codigo postal'],
    ),

    // Professional Info
    ProfileFieldDefinition(
      key: 'professional.professionalTitle',
      label: 'Professional Title',
      category: 'Professional',
      autocompleteAttributes: ['organization-title', 'job-title'],
      synonyms: [
        'professional title',
        'job title',
        'title',
        'headline',
        'current title',
        'desired title',
        'role',
        'position',
        'designation',
      ],
    ),
    ProfileFieldDefinition(
      key: 'professional.overviewBio',
      label: 'Bio / Summary / Cover Letter',
      category: 'Professional',
      synonyms: [
        'bio',
        'overview',
        'summary',
        'about',
        'about me',
        'professional summary',
        'cover letter',
        'statement',
        'introduction',
        'description',
      ],
    ),
    ProfileFieldDefinition(
      key: 'professional.hourlyRate',
      label: 'Hourly Rate',
      category: 'Professional',
      synonyms: [
        'hourly rate',
        'rate',
        'rate / hr',
        'expected rate',
        'desired rate',
        'hourly wage',
        'compensation',
        'salary expectation',
      ],
    ),
    ProfileFieldDefinition(
      key: 'professional.skills',
      label: 'Skills',
      category: 'Professional',
      synonyms: [
        'skills',
        'key skills',
        'technologies',
        'tech stack',
        'expertise',
        'proficiencies',
        'competencies',
      ],
    ),
    ProfileFieldDefinition(
      key: 'professional.languages',
      label: 'Languages',
      category: 'Professional',
      synonyms: [
        'languages',
        'spoken languages',
        'language proficiencies',
        'idiomas',
      ],
    ),
    ProfileFieldDefinition(
      key: 'professional.yearsOfExperience',
      label: 'Years of Experience',
      category: 'Professional',
      synonyms: [
        'years of experience',
        'experience years',
        'total experience',
        'yoe',
        'how many years',
      ],
    ),

    // Experience & Education Fields
    ProfileFieldDefinition(
      key: 'experience.latestCompany',
      label: 'Recent Company',
      category: 'Experience',
      autocompleteAttributes: ['organization', 'current-company'],
      synonyms: ['company', 'organization', 'employer', 'recent company', 'current employer', 'workplace'],
    ),
    ProfileFieldDefinition(
      key: 'education.latestSchool',
      label: 'University / Institution',
      category: 'Education',
      autocompleteAttributes: ['school', 'university'],
      synonyms: ['university', 'college', 'school', 'institution', 'academy', 'alma mater'],
    ),
    ProfileFieldDefinition(
      key: 'education.latestDegree',
      label: 'Degree',
      category: 'Education',
      synonyms: ['degree', 'highest degree', 'qualification', 'diploma', 'major', 'field of study'],
    ),
    ProfileFieldDefinition(
      key: 'portfolio.websiteUrl',
      label: 'Portfolio / Website URL',
      category: 'Portfolio',
      autocompleteAttributes: ['url'],
      synonyms: ['portfolio', 'website', 'personal website', 'portfolio url', 'project link', 'github', 'linkedin'],
    ),
  ];
}
