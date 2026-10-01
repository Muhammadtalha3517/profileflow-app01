class ValidationUtils {
  static final RegExp _emailRegex = RegExp(
    r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+",
  );

  static final RegExp _phoneRegex = RegExp(
    r"^\+?[0-9\s\-()]{7,20}$",
  );

  static final RegExp _urlRegex = RegExp(
    r"^(https?:\/\/)?([a-zA-Z0-9-]+\.)+[a-zA-Z]{2,}(:\d+)?(\/.*)?$",
    caseSensitive: false,
  );

  static bool isValidEmail(String? email) {
    if (email == null || email.trim().isEmpty) return false;
    return _emailRegex.hasMatch(email.trim());
  }

  static bool isValidPhone(String? phone) {
    if (phone == null || phone.trim().isEmpty) return false;
    return _phoneRegex.hasMatch(phone.trim());
  }

  static bool isValidUrl(String? url) {
    if (url == null || url.trim().isEmpty) return false;
    return _urlRegex.hasMatch(url.trim());
  }

  static String? validateRequired(String? value, String fieldName) {
    if (value == null || value.trim().isEmpty) {
      return '$fieldName is required';
    }
    return null;
  }

  static String? validateEmail(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Email is required';
    }
    if (!isValidEmail(value)) {
      return 'Please enter a valid email address';
    }
    return null;
  }
}
