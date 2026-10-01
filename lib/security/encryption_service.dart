import 'dart:convert';
import 'dart:typed_data';
import 'package:crypto/crypto.dart';
import 'package:encrypt/encrypt.dart' as enc;

class EncryptionService {
  static const int _keyLength = 32; // 256 bits

  /// Derives a 32-byte AES key from a passphrase or master secret using SHA-256
  static enc.Key deriveKey(String secret, [String salt = 'ProfileFlowSalt2026']) {
    final bytes = utf8.encode('$secret:$salt');
    final digest = sha256.convert(bytes);
    return enc.Key(Uint8List.fromList(digest.bytes.sublist(0, _keyLength)));
  }

  /// Encrypts plain text with AES-CBC and a random 16-byte IV
  static String encrypt(String plainText, String secretKey) {
    if (plainText.isEmpty) return '';
    try {
      final key = deriveKey(secretKey);
      final iv = enc.IV.fromSecureRandom(16);
      final encrypter = enc.Encrypter(enc.AES(key, mode: enc.AESMode.cbc));
      final encrypted = encrypter.encrypt(plainText, iv: iv);

      // Store IV + Ciphertext as combined base64
      final combined = '${iv.base64}:${encrypted.base64}';
      return combined;
    } catch (e) {
      throw Exception('Encryption failed: $e');
    }
  }

  /// Decrypts combined IV:Ciphertext back to plain text
  static String decrypt(String cipherPayload, String secretKey) {
    if (cipherPayload.isEmpty) return '';
    try {
      final parts = cipherPayload.split(':');
      if (parts.length != 2) {
        throw Exception('Invalid cipher payload format');
      }

      final key = deriveKey(secretKey);
      final iv = enc.IV.fromBase64(parts[0]);
      final encrypted = enc.Encrypted.fromBase64(parts[1]);

      final encrypter = enc.Encrypter(enc.AES(key, mode: enc.AESMode.cbc));
      return encrypter.decrypt(encrypted, iv: iv);
    } catch (e) {
      throw Exception('Decryption failed: $e');
    }
  }

  /// Calculates a SHA-256 hash of a string (e.g. for PIN verification)
  static String hashSecret(String secret) {
    final bytes = utf8.encode(secret);
    return sha256.convert(bytes).toString();
  }
}
