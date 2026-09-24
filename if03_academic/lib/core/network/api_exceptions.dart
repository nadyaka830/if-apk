/// Kelas exception kustom untuk menangani error HTTP dan koneksi
class ApiException implements Exception {
  final String message;
  final int? statusCode;
  final dynamic details;

  ApiException({
    required this.message,
    this.statusCode,
    this.details,
  });

  @override
  String toString() => message;
}

class NetworkException extends ApiException {
  NetworkException({String message = 'Tidak ada koneksi internet. Periksa koneksi Anda.'})
      : super(message: message, statusCode: 0);
}

class UnauthorizedException extends ApiException {
  UnauthorizedException({String message = 'Sesi Anda telah berakhir. Silakan login kembali.'})
      : super(message: message, statusCode: 401);
}

class ForbiddenException extends ApiException {
  ForbiddenException({String message = 'Anda tidak memiliki hak akses untuk tindakan ini.'})
      : super(message: message, statusCode: 403);
}

class NotFoundException extends ApiException {
  NotFoundException({String message = 'Data atau rute tidak ditemukan.'})
      : super(message: message, statusCode: 404);
}

class ServerException extends ApiException {
  ServerException({String message = 'Terjadi kesalahan pada server. Coba lagi nanti.'})
      : super(message: message, statusCode: 500);
}
