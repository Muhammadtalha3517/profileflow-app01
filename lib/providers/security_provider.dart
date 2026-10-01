import 'package:flutter/material.dart';
import '../security/secure_vault_storage.dart';
import '../security/biometric_auth_service.dart';
import '../security/encryption_service.dart';

class SecurityProvider with ChangeNotifier {
  final SecureVaultStorage _vault = SecureVaultStorage();
  final BiometricAuthService _biometricAuth = BiometricAuthService();

  bool _isLocked = false;
  bool _isAppLockEnabled = false;
  bool _isBiometricEnabled = false;
  bool _hasPinSet = false;
  int _autoLockTimeoutMinutes = 5;
  DateTime? _lastPausedTime;

  bool get isLocked => _isLocked;
  bool get isAppLockEnabled => _isAppLockEnabled;
  bool get isBiometricEnabled => _isBiometricEnabled;
  bool get hasPinSet => _hasPinSet;
  int get autoLockTimeoutMinutes => _autoLockTimeoutMinutes;

  Future<void> initSecurity() async {
    _isAppLockEnabled = await _vault.isAppLockEnabled();
    _isBiometricEnabled = await _vault.isBiometricEnabled();
    final pinHash = await _vault.getAppPinHash();
    _hasPinSet = pinHash != null && pinHash.isNotEmpty;
    _autoLockTimeoutMinutes = await _vault.getAutoLockTimeoutMinutes();

    if (_isAppLockEnabled && _hasPinSet) {
      _isLocked = true;
    }
    notifyListeners();
  }

  Future<bool> setAppPin(String pin) async {
    if (pin.length < 4) return false;
    final hash = EncryptionService.hashSecret(pin);
    await _vault.setAppPinHash(hash);
    await _vault.setAppLockEnabled(true);
    _hasPinSet = true;
    _isAppLockEnabled = true;
    notifyListeners();
    return true;
  }

  Future<bool> verifyPin(String pin) async {
    final savedHash = await _vault.getAppPinHash();
    if (savedHash == null) return false;

    final inputHash = EncryptionService.hashSecret(pin);
    if (inputHash == savedHash) {
      _isLocked = false;
      notifyListeners();
      return true;
    }
    return false;
  }

  Future<bool> authenticateWithBiometrics() async {
    final success = await _biometricAuth.authenticate(
      reason: 'Scan fingerprint or face to unlock ProfileFlow',
    );
    if (success) {
      _isLocked = false;
      notifyListeners();
      return true;
    }
    return false;
  }

  Future<void> toggleBiometrics(bool enable) async {
    if (enable) {
      final available = await _biometricAuth.isBiometricsAvailable();
      if (!available) return;
    }
    await _vault.setBiometricEnabled(enable);
    _isBiometricEnabled = enable;
    notifyListeners();
  }

  Future<void> setAutoLockTimeout(int minutes) async {
    await _vault.setAutoLockTimeoutMinutes(minutes);
    _autoLockTimeoutMinutes = minutes;
    notifyListeners();
  }

  Future<void> removePinAndAppLock() async {
    await _vault.removeAppPin();
    await _vault.setAppLockEnabled(false);
    _hasPinSet = false;
    _isAppLockEnabled = false;
    _isLocked = false;
    notifyListeners();
  }

  void handleAppPaused() {
    _lastPausedTime = DateTime.now();
  }

  void handleAppResumed() {
    if (!_isAppLockEnabled || !_hasPinSet) return;
    if (_lastPausedTime == null) return;

    final diffMinutes = DateTime.now().difference(_lastPausedTime!).inMinutes;
    if (diffMinutes >= _autoLockTimeoutMinutes) {
      _isLocked = true;
      notifyListeners();
    }
  }

  void lockApp() {
    if (_isAppLockEnabled && _hasPinSet) {
      _isLocked = true;
      notifyListeners();
    }
  }
}
