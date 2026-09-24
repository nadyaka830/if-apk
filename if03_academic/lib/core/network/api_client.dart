import 'package:dio/dio.dart';
import '../config/api_config.dart';
import '../storage/storage_service.dart';
import 'api_exceptions.dart';

/// Centralized HTTP client menggunakan Dio
/// Menangani token injection, exception formatting, dan timeout
class ApiClient {
  late final Dio _botDio;
  late final Dio _scheduleDio;
  final StorageService _storageService = StorageService();

  ApiClient() {
    // Client untuk VPS Backend (Auth, Deadlines, Groups)
    _botDio = Dio(
      BaseOptions(
        baseUrl: ApiConfig.botApiBaseUrl,
        connectTimeout: ApiConfig.connectTimeout,
        receiveTimeout: ApiConfig.receiveTimeout,
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      ),
    );

    // Client untuk Jadwal (jadwalkampusku.my.id)
    _scheduleDio = Dio(
      BaseOptions(
        baseUrl: ApiConfig.scheduleBaseUrl,
        connectTimeout: ApiConfig.connectTimeout,
        receiveTimeout: ApiConfig.receiveTimeout,
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      ),
    );

    // Interceptor untuk auto-attach JWT Bearer token ke botDio
    _botDio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          final token = await _storageService.getToken();
          if (token != null && token.isNotEmpty) {
            options.headers['Authorization'] = 'Bearer $token';
          }
          return handler.next(options);
        },
        onError: (DioException e, handler) {
          return handler.next(e);
        },
      ),
    );
  }

  Dio get botClient => _botDio;
  Dio get scheduleClient => _scheduleDio;

  /// Helper untuk menangani DioException ke ApiException
  static ApiException handleError(dynamic error) {
    if (error is DioException) {
      switch (error.type) {
        case DioExceptionType.connectionTimeout:
        case DioExceptionType.sendTimeout:
        case DioExceptionType.receiveTimeout:
        case DioExceptionType.connectionError:
          return NetworkException(
            message: 'Koneksi ke server terputus. Pastikan internet Anda aktif.',
          );
        case DioExceptionType.badResponse:
          final statusCode = error.response?.statusCode;
          final responseData = error.response?.data;
          String message = 'Terjadi kesalahan sistem.';

          if (responseData is Map && responseData.containsKey('message')) {
            message = responseData['message'].toString();
          }

          if (statusCode == 401) {
            return UnauthorizedException(message: message);
          } else if (statusCode == 403) {
            return ForbiddenException(message: message);
          } else if (statusCode == 404) {
            return NotFoundException(message: message);
          } else if (statusCode != null && statusCode >= 500) {
            return ServerException(message: message);
          }
          return ApiException(
            message: message,
            statusCode: statusCode,
            details: responseData,
          );
        case DioExceptionType.cancel:
          return ApiException(message: 'Permintaan dibatalkan.');
        default:
          return ApiException(message: error.message ?? 'Kesalahan tidak diketahui.');
      }
    }
    return ApiException(message: error.toString());
  }
}
