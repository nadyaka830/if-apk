import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Service untuk menangani penyimpanan lokal
/// - Token & Kredensial sensitif: FlutterSecureStorage (Keystore Android / Keychain iOS)
/// - Preferensi UI (Tema, cache ringan): SharedPreferences
class StorageService {
  static const String _keyToken = 'auth_token';
  static const String _keyUser = 'cached_user';
  static const String _keyTheme = 'app_theme_mode';

  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage(
    aOptions: AndroidOptions(encryptedSharedPreferences: true),
  );

  // Singleton instance
  static final StorageService _instance = StorageService._internal();
  factory StorageService() => _instance;
  StorageService._internal();

  /// Simpan JWT Auth Token secara aman
  Future<void> saveToken(String token) async {
    await _secureStorage.write(key: _keyToken, value: token);
  }

  /// Ambil JWT Auth Token
  Future<String?> getToken() async {
    return await _secureStorage.read(key: _keyToken);
  }

  /// Hapus JWT Auth Token saat logout
  Future<void> deleteToken() async {
    await _secureStorage.delete(key: _keyToken);
  }

  /// Cek apakah user sudah login
  Future<bool> hasToken() async {
    final token = await getToken();
    return token != null && token.isNotEmpty;
  }

  /// Simpan mode tema ('light', 'dark', 'system')
  Future<void> setThemeMode(String mode) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyTheme, mode);
  }

  /// Ambil preferensi tema
  Future<String> getThemeMode() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_keyTheme) ?? 'system';
  }

  /// Hapus seluruh data session
  Future<void> clearAll() async {
    await _secureStorage.deleteAll();
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_keyUser);
  }
}
