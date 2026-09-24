import 'package:dio/dio.dart';
import '../core/config/api_config.dart';
import '../core/network/api_client.dart';
import '../core/network/api_exceptions.dart';

/// Service untuk menangani pengiriman dan pengecekan status Permohonan Akun Mahasiswa
class AccountRequestService {
  final ApiClient _apiClient = ApiClient();

  // Singleton pattern
  static final AccountRequestService _instance = AccountRequestService._internal();
  factory AccountRequestService() => _instance;
  AccountRequestService._internal();

  /// Mengajukan permohonan akun baru ke backend VPS
  Future<String> submitAccountRequest({
    required String username,
    required String name,
    required String password,
    required String discordUserId,
    required String discordUsername,
  }) async {
    try {
      final response = await _apiClient.botClient.post(
        ApiConfig.accountRequestsEndpoint,
        data: {
          'username': username.trim().toLowerCase(),
          'name': name.trim(),
          'password': password,
          'discord_user_id': discordUserId.trim(),
          'discord_username': discordUsername.trim(),
        },
      );

      final data = response.data;
      if (data == null || data['success'] != true) {
        throw ApiException(
          message: data?['message'] ?? 'Gagal mengajukan permohonan akun.',
        );
      }

      return data['message'] ?? 'Permohonan akun berhasil dikirim! Silakan tunggu persetujuan Admin.';
    } on DioException catch (e) {
      throw ApiClient.handleError(e);
    } catch (e) {
      if (e is ApiException) rethrow;
      throw ApiException(message: 'Terjadi kesalahan: ${e.toString()}');
    }
  }

  /// Cek status permohonan akun berdasarkan username
  Future<Map<String, dynamic>?> checkStatus(String username) async {
    try {
      final response = await _apiClient.botClient.get(
        '${ApiConfig.accountRequestsEndpoint}/status/${username.trim().toLowerCase()}',
      );
      if (response.statusCode == 200 && response.data != null) {
        return response.data['data'] as Map<String, dynamic>?;
      }
      return null;
    } on DioException catch (e) {
      if (e.response?.statusCode == 404) {
        return null;
      }
      throw ApiClient.handleError(e);
    } catch (e) {
      return null;
    }
  }
}
