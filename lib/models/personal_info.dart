class PersonalInfo {
  final String firstName;
  final String lastName;
  final String fullName;
  final String email;
  final String phone;
  final String country;
  final String city;
  final String address;
  final String postalCode;

  const PersonalInfo({
    this.firstName = '',
    this.lastName = '',
    this.fullName = '',
    this.email = '',
    this.phone = '',
    this.country = '',
    this.city = '',
    this.address = '',
    this.postalCode = '',
  });

  factory PersonalInfo.empty() => const PersonalInfo();

  String get effectiveFullName {
    if (fullName.trim().isNotEmpty) return fullName.trim();
    final combined = '$firstName $lastName'.trim();
    return combined;
  }

  bool get isEmpty =>
      firstName.isEmpty &&
      lastName.isEmpty &&
      fullName.isEmpty &&
      email.isEmpty &&
      phone.isEmpty &&
      country.isEmpty &&
      city.isEmpty &&
      address.isEmpty &&
      postalCode.isEmpty;

  bool get isNotEmpty => !isEmpty;

  PersonalInfo copyWith({
    String? firstName,
    String? lastName,
    String? fullName,
    String? email,
    String? phone,
    String? country,
    String? city,
    String? address,
    String? postalCode,
  }) {
    return PersonalInfo(
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      fullName: fullName ?? this.fullName,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      country: country ?? this.country,
      city: city ?? this.city,
      address: address ?? this.address,
      postalCode: postalCode ?? this.postalCode,
    );
  }

  Map<String, dynamic> toJson() => {
        'firstName': firstName,
        'lastName': lastName,
        'fullName': fullName,
        'email': email,
        'phone': phone,
        'country': country,
        'city': city,
        'address': address,
        'postalCode': postalCode,
      };

  factory PersonalInfo.fromJson(Map<String, dynamic>? json) {
    if (json == null) return const PersonalInfo();
    return PersonalInfo(
      firstName: json['firstName'] as String? ?? '',
      lastName: json['lastName'] as String? ?? '',
      fullName: json['fullName'] as String? ?? '',
      email: json['email'] as String? ?? '',
      phone: json['phone'] as String? ?? '',
      country: json['country'] as String? ?? '',
      city: json['city'] as String? ?? '',
      address: json['address'] as String? ?? '',
      postalCode: json['postalCode'] as String? ?? '',
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PersonalInfo &&
          runtimeType == other.runtimeType &&
          firstName == other.firstName &&
          lastName == other.lastName &&
          fullName == other.fullName &&
          email == other.email &&
          phone == other.phone &&
          country == other.country &&
          city == other.city &&
          address == other.address &&
          postalCode == other.postalCode;

  @override
  int get hashCode =>
      firstName.hashCode ^
      lastName.hashCode ^
      fullName.hashCode ^
      email.hashCode ^
      phone.hashCode ^
      country.hashCode ^
      city.hashCode ^
      address.hashCode ^
      postalCode.hashCode;
}
