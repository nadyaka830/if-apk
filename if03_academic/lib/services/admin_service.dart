import 'package:dio/dio.dart';
import '../core/config/api_config.dart';
import '../core/network/api_client.dart';
import '../core/network/api_exceptions.dart';
import '../models/account_request.dart';
import '../models/user.dart';

class AdminService {
  final ApiClient _apiClient = ApiClient();

  // Singleton pattern
  static final AdminService _instance = AdminService._internal();
  factory AdminService() => _instance;
  AdminService._internal();

  /// Mengambil semua permohonan akun (Pending, Approved, Rejected)
  Future<List<AccountRequest>> getAccountRequests({String? status}) async {
    try {
      final response = await _apiClient.botClient.get(
        ApiConfig.adminAccountRequestsEndpoint,
        queryParameters: status != null ? {'status': status} : null,
      );

      if (response.statusCode == 200 && response.data != null) {
        final List<dynamic> list = response.data['data'] as List<dynamic>? ?? [];
        return list.map((item) => AccountRequest.fromJson(item as Map<String, dynamic>)).toList();
      }
      return [];
    } on DioException catch (e) {
      throw ApiClient.handleError(e);
    } catch (e) {
      throw ApiException(message: 'Gagal memuat permohonan akun: ${e.toString()}');
    }
  }

  /// Menyetujui permohonan akun
  Future<String> approveRequest(int id) async {
    try {
      final response = await _apiClient.botClient.post(ApiConfig.adminApproveRequest(id));
      return response.data?['message'] ?? 'Permohonan akun berhasil disetujui.';
    } on DioException catch (e) {
      throw ApiClient.handleError(e);
    } catch (e) {
      throw ApiException(message: 'Gagal menyetujui akun: ${e.toString()}');
    }
  }

  /// Menolak permohonan akun
  Future<String> rejectRequest(int id, {String? reason}) async {
    try {
      final response = await _apiClient.botClient.post(
        ApiConfig.adminRejectRequest(id),
        data: {'reason': reason},
      );
      return response.data?['message'] ?? 'Permohonan akun telah ditolak.';
    } on DioException catch (e) {
      throw ApiClient.handleError(e);
    } catch (e) {
      throw ApiException(message: 'Gagal menolak akun: ${e.toString()}');
    }
  }

  /// Mengambil daftar semua user
  Future<List<User>> getUsers() async {
    try {
      final response = await _apiClient.botClient.get(ApiConfig.adminUsersEndpoint);
      if (response.statusCode == 200 && response.data != null) {
        final List<dynamic> list = response.data['data'] as List<dynamic>? ?? [];
        return list.map((item) => User.fromJson(item as Map<String, dynamic>)).toList();
      }
      return [];
    } on DioException catch (e) {
      throw ApiClient.handleError(e);
    } catch (e) {
      throw ApiException(message: 'Gagal memuat daftar pengguna: ${e.toString()}');
    }
  }

  /// Mengubah role user
  Future<String> updateUserRole(int userId, String newRole) async {
    try {
      final response = await _apiClient.botClient.put(
        '${ApiConfig.adminUsersEndpoint}/$userId/role',
        data: {'role': newRole},
      );
      return response.data?['message'] ?? 'Role berhasil diperbarui.';
    } on DioException catch (e) {
      throw ApiClient.handleError(e);
    } catch (e) {
      throw ApiException(message: 'Gagal mengubah role: ${e.toString()}');
    }
  }

  /// Menghapus user
  Future<String> deleteUser(int userId) async {
    try {
      final response = await _apiClient.botClient.delete('${ApiConfig.adminUsersEndpoint}/$userId');
      return response.data?['message'] ?? 'Pengguna berhasil dihapus.';
    } on DioException catch (e) {
      throw ApiClient.handleError(e);
    } catch (e) {
      throw ApiException(message: 'Gagal menghapus pengguna: ${e.toString()}');
    }
  }
}
