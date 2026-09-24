import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../core/config/api_config.dart';
import '../core/network/api_client.dart';
import '../core/network/api_exceptions.dart';
import '../core/storage/storage_service.dart';
import '../models/user.dart';

/// Service untuk menangani Autentikasi Mahasiswa dan Admin
/// Mengakses REST API VPS backend secara aman menggunakan JWT Bearer token
class AuthService {
  final ApiClient _apiClient = ApiClient();
  final StorageService _storageService = StorageService();

  static const String _cachedUserKey = 'if03_cached_user';

  // Singleton pattern
  static final AuthService _instance = AuthService._internal();
  factory AuthService() => _instance;
  AuthService._internal();

  /// Login user ke Backend VPS
  /// Mengembalikan objek User jika berhasil
  /// Melempar ApiException jika gagal (password salah, pending, dll)
  Future<User> login({
    required String username,
    required String password,
  }) async {
    try {
      final response = await _apiClient.botClient.post(
        ApiConfig.loginEndpoint,
        data: {
          'username': username.trim(),
          'password': password,
        },
      );

      final data = response.data;
      if (data == null || data['success'] != true) {
        throw ApiException(
          message: data?['message'] ?? 'Login gagal. Periksa username dan password.',
        );
      }

      // Ambil token dan data user dari response backend
      final token = data['token']?.toString() ?? data['data']?['token']?.toString();
      final userData = data['user'] ?? data['data']?['user'];

      if (token == null || token.isEmpty) {
        throw ServerException(message: 'Token autentikasi tidak valid dari server.');
      }

      if (userData == null) {
        throw ServerException(message: 'Data profil user tidak diterima.');
      }

      final user = User.fromJson(userData as Map<String, dynamic>);

      // Simpan token secara aman di Android EncryptedSharedPreferences (Keystore)
      await _storageService.saveToken(token);

      // Cache data profil user untuk offline/sesi cepat
      await _saveCachedUser(user);

      return user;
    } on DioException catch (dioErr) {
      // Tangani status khusus (misal 403 atau 400 saat akun masih PENDING)
      final res = dioErr.response?.data;
      if (res is Map && res.containsKey('status') && res['status'] == 'PENDING') {
        throw ApiException(
          message: 'Permohonan akun kamu masih menunggu persetujuan admin.',
          statusCode: 403,
        );
      }
      throw ApiClient.handleError(dioErr);
    } catch (e) {
      if (e is ApiException) rethrow;
      throw ApiException(message: 'Terjadi kesalahan: ${e.toString()}');
    }
  }

  /// Verifikasi sesi dan ambil profil terbaru dari server menggunakan token yang tersimpan
  Future<User?> getCurrentUser() async {
    final hasToken = await _storageService.hasToken();
    if (!hasToken) {
      return null;
    }

    try {
      final response = await _apiClient.botClient.get(ApiConfig.meEndpoint);
      if (response.statusCode == 200 && response.data != null) {
        final userData = response.data['user'] ?? response.data['data'];
        if (userData != null) {
          final user = User.fromJson(userData as Map<String, dynamic>);
          await _saveCachedUser(user);
          return user;
        }
      }
    } catch (e) {
      // Jika offline, gunakan cache user lokal
      return await getCachedUser();
    }

    return await getCachedUser();
  }

  /// Ambil user dari cache lokal
  Future<User?> getCachedUser() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final userString = prefs.getString(_cachedUserKey);
      if (userString != null && userString.isNotEmpty) {
        return User.fromJson(jsonDecode(userString) as Map<String, dynamic>);
      }
    } catch (_) {}
    return null;
  }

  /// Simpan user ke cache
  Future<void> _saveCachedUser(User user) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_cachedUserKey, jsonEncode(user.toJson()));
    } catch (_) {}
  }

  /// Logout: hapus token dari Secure Storage dan hapus cache sesi
  Future<void> logout() async {
    await _storageService.deleteToken();
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_cachedUserKey);
  }
}
