/// Base exception class for all ProfileFlow errors.
abstract class AppException implements Exception {
  final String message;
  final String? code;

  const AppException(this.message, [this.code]);

  @override
  String toString() => 'AppException: $message (code: $code)';
}

class SecurityException extends AppException {
  const SecurityException(String message, [String? code]) : super(message, code);
}

class StorageException extends AppException {
  const StorageException(String message, [String? code]) : super(message, code);
}

class FieldMappingException extends AppException {
  const FieldMappingException(String message, [String? code]) : super(message, code);
}

class ValidationException extends AppException {
  const ValidationException(String message, [String? code]) : super(message, code);
}
