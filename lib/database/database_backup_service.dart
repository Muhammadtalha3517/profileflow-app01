import 'dart:convert';
import '../models/user_profile.dart';
import '../security/encryption_service.dart';

class DatabaseBackupService {
  /// Exports user profile to a formatted JSON string (optionally encrypted with user password)
  static String exportProfileJson(UserProfile profile, {String? password}) {
    final rawJson = jsonEncode(profile.toJson());
    if (password != null && password.isNotEmpty) {
      final encrypted = EncryptionService.encrypt(rawJson, password);
      return jsonEncode({
        'format': 'profileflow_encrypted_backup',
        'version': 1,
        'exportedAt': DateTime.now().toIso8601String(),
        'cipher': encrypted,
      });
    }

    return jsonEncode({
      'format': 'profileflow_backup',
      'version': 1,
      'exportedAt': DateTime.now().toIso8601String(),
      'profile': profile.toJson(),
    });
  }

  /// Imports and validates a user profile from exported JSON string
  static UserProfile importProfileJson(String jsonString, {String? password}) {
    try {
      final map = jsonDecode(jsonString) as Map<String, dynamic>;
      final format = map['format'] as String?;

      if (format == 'profileflow_encrypted_backup') {
        if (password == null || password.isEmpty) {
          throw Exception('This backup is password protected. Please provide the password.');
        }
        final cipher = map['cipher'] as String;
        final decrypted = EncryptionService.decrypt(cipher, password);
        final profileMap = jsonDecode(decrypted) as Map<String, dynamic>;
        return UserProfile.fromJson(profileMap);
      } else if (format == 'profileflow_backup') {
        final profileMap = map['profile'] as Map<String, dynamic>;
        return UserProfile.fromJson(profileMap);
      } else {
        // Try direct parse as raw UserProfile JSON
        return UserProfile.fromJson(map);
      }
    } catch (e) {
      throw Exception('Failed to import profile: Invalid format or incorrect password. ($e)');
    }
  }
}
