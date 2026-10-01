import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';

class SecureVaultStorage {
  static const String _keyMasterSecret = 'profileflow_master_secret';
  static const String _keyAppPinHash = 'profileflow_app_pin_hash';
  static const String _keyBiometricEnabled = 'profileflow_biometric_enabled';
  static const String _keyAppLockEnabled = 'profileflow_app_lock_enabled';
  static const String _keyAutoLockTimeout = 'profileflow_auto_lock_timeout';

  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage(
    aOptions: AndroidOptions(
      encryptedSharedPreferences: true,
      resetOnError: true,
    ),
  );

  /// Retrieves or generates a unique local encryption secret for this device
  Future<String> getOrCreateMasterSecret() async {
    try {
      String? secret = await _secureStorage.read(key: _keyMasterSecret);
      if (secret == null || secret.isEmpty) {
        secret = const Uuid().v4() + const Uuid().v4();
        await _secureStorage.write(key: _keyMasterSecret, value: secret);
      }
      return secret;
    } catch (_) {
      // Fallback to shared_preferences if keystore has edge-case issues
      final prefs = await SharedPreferences.getInstance();
      String? secret = prefs.getString(_keyMasterSecret);
      if (secret == null || secret.isEmpty) {
        secret = const Uuid().v4() + const Uuid().v4();
        await prefs.setString(_keyMasterSecret, secret);
      }
      return secret;
    }
  }

  Future<void> setAppPinHash(String hash) async {
    await _secureStorage.write(key: _keyAppPinHash, value: hash);
  }

  Future<String?> getAppPinHash() async {
    try {
      return await _secureStorage.read(key: _keyAppPinHash);
    } catch (_) {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getString(_keyAppPinHash);
    }
  }

  Future<void> removeAppPin() async {
    await _secureStorage.delete(key: _keyAppPinHash);
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_keyAppPinHash);
  }

  Future<bool> isBiometricEnabled() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_keyBiometricEnabled) ?? false;
  }

  Future<void> setBiometricEnabled(bool enabled) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keyBiometricEnabled, enabled);
  }

  Future<bool> isAppLockEnabled() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_keyAppLockEnabled) ?? false;
  }

  Future<void> setAppLockEnabled(bool enabled) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keyAppLockEnabled, enabled);
  }

  Future<int> getAutoLockTimeoutMinutes() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(_keyAutoLockTimeout) ?? 5; // Default 5 minutes
  }

  Future<void> setAutoLockTimeoutMinutes(int minutes) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_keyAutoLockTimeout, minutes);
  }

  Future<void> clearAllSecurityKeys() async {
    try {
      await _secureStorage.deleteAll();
    } catch (_) {}
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_keyMasterSecret);
    await prefs.remove(_keyAppPinHash);
    await prefs.remove(_keyBiometricEnabled);
    await prefs.remove(_keyAppLockEnabled);
    await prefs.remove(_keyAutoLockTimeout);
  }
}
