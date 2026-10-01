import 'dart:convert';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import '../models/user_profile.dart';
import '../models/task_item.dart';
import '../models/activity_log_entry.dart';
import '../security/encryption_service.dart';
import '../security/secure_vault_storage.dart';

class LocalDatabase {
  static final LocalDatabase _instance = LocalDatabase._internal();
  factory LocalDatabase() => _instance;
  LocalDatabase._internal();

  final SecureVaultStorage _vault = SecureVaultStorage();

  static const String _profileFileName = 'user_profile.vault';
  static const String _tasksFileName = 'user_tasks.vault';
  static const String _logsFileName = 'activity_logs.vault';

  Future<File> _getFile(String fileName) async {
    final dir = await getApplicationDocumentsDirectory();
    return File('${dir.path}/$fileName');
  }

  // --- Profile Operations ---

  /// Loads the encrypted profile. If none exists, returns an empty profile (NO fake demo data).
  Future<UserProfile> loadProfile() async {
    try {
      final file = await _getFile(_profileFileName);
      if (!await file.exists()) {
        return UserProfile.empty();
      }

      final cipherText = await file.readAsString();
      if (cipherText.trim().isEmpty) {
        return UserProfile.empty();
      }

      final secret = await _vault.getOrCreateMasterSecret();
      final decryptedJson = EncryptionService.decrypt(cipherText, secret);
      final map = jsonDecode(decryptedJson) as Map<String, dynamic>;
      return UserProfile.fromJson(map);
    } catch (e) {
      // If corrupted or empty, fallback safely to empty profile
      return UserProfile.empty();
    }
  }

  /// Saves the user profile encrypted with the local master secret.
  Future<void> saveProfile(UserProfile profile) async {
    try {
      final file = await _getFile(_profileFileName);
      final jsonString = jsonEncode(profile.toJson());
      final secret = await _vault.getOrCreateMasterSecret();
      final encrypted = EncryptionService.encrypt(jsonString, secret);
      await file.writeAsString(encrypted, flush: true);
    } catch (e) {
      throw Exception('Failed to save profile locally: $e');
    }
  }

  // --- Task Operations ---

  Future<List<TaskItem>> loadTasks() async {
    try {
      final file = await _getFile(_tasksFileName);
      if (!await file.exists()) return [];

      final cipherText = await file.readAsString();
      if (cipherText.trim().isEmpty) return [];

      final secret = await _vault.getOrCreateMasterSecret();
      final decryptedJson = EncryptionService.decrypt(cipherText, secret);
      final list = jsonDecode(decryptedJson) as List<dynamic>;
      return list.map((e) => TaskItem.fromJson(e as Map<String, dynamic>)).toList();
    } catch (_) {
      return [];
    }
  }

  Future<void> saveTasks(List<TaskItem> tasks) async {
    try {
      final file = await _getFile(_tasksFileName);
      final jsonString = jsonEncode(tasks.map((e) => e.toJson()).toList());
      final secret = await _vault.getOrCreateMasterSecret();
      final encrypted = EncryptionService.encrypt(jsonString, secret);
      await file.writeAsString(encrypted, flush: true);
    } catch (e) {
      throw Exception('Failed to save tasks: $e');
    }
  }

  // --- Activity Log Operations ---

  Future<List<ActivityLogEntry>> loadActivityLogs() async {
    try {
      final file = await _getFile(_logsFileName);
      if (!await file.exists()) return [];

      final cipherText = await file.readAsString();
      if (cipherText.trim().isEmpty) return [];

      final secret = await _vault.getOrCreateMasterSecret();
      final decryptedJson = EncryptionService.decrypt(cipherText, secret);
      final list = jsonDecode(decryptedJson) as List<dynamic>;
      return list.map((e) => ActivityLogEntry.fromJson(e as Map<String, dynamic>)).toList();
    } catch (_) {
      return [];
    }
  }

  Future<void> saveActivityLogs(List<ActivityLogEntry> logs) async {
    try {
      final file = await _getFile(_logsFileName);
      // Keep only most recent 100 entries to maintain high performance
      final trimmedLogs = logs.length > 100 ? logs.sublist(0, 100) : logs;
      final jsonString = jsonEncode(trimmedLogs.map((e) => e.toJson()).toList());
      final secret = await _vault.getOrCreateMasterSecret();
      final encrypted = EncryptionService.encrypt(jsonString, secret);
      await file.writeAsString(encrypted, flush: true);
    } catch (_) {}
  }

  Future<void> addActivityLog(ActivityLogEntry entry) async {
    final logs = await loadActivityLogs();
    logs.insert(0, entry);
    await saveActivityLogs(logs);
  }

  // --- Clear Database ---

  Future<void> clearAllData() async {
    try {
      final pFile = await _getFile(_profileFileName);
      if (await pFile.exists()) await pFile.delete();

      final tFile = await _getFile(_tasksFileName);
      if (await tFile.exists()) await tFile.delete();

      final lFile = await _getFile(_logsFileName);
      if (await lFile.exists()) await lFile.delete();
    } catch (_) {}
  }
}
