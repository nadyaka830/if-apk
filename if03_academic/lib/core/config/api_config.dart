/// Konfigurasi URL dan Endpoint API untuk IF03 Academic
/// Sumber data:
/// - Jadwal: https://jadwalkampusku.my.id
/// - Deadline & Kelompok: Backend API IF03 Academic Bot VPS (SQLite if03.db)
/// - Auth & Account Requests: Backend API VPS
class ApiConfig {
  ApiConfig._();

  // Base URL untuk Website Jadwal Kampusku
  static const String scheduleBaseUrl = 'https://jadwalkampusku.my.id';

  // Base URL untuk Backend REST API IF03 Academic Bot VPS
  // Default port 3001 untuk REST API server di VPS (208.76.40.197)
  static const String botApiBaseUrl = 'http://208.76.40.197:3001';

  // Timeout settings
  static const Duration connectTimeout = Duration(seconds: 15);
  static const Duration receiveTimeout = Duration(seconds: 15);

  // Endpoints: Authentication & Account Request
  static const String loginEndpoint = '/api/auth/login';
  static const String meEndpoint = '/api/auth/me';
  static const String accountRequestsEndpoint = '/api/account-requests';
  static const String adminAccountRequestsEndpoint = '/api/admin/account-requests';
  static String adminApproveRequest(int id) => '/api/admin/account-requests/$id/approve';
  static String adminRejectRequest(int id) => '/api/admin/account-requests/$id/reject';
  static const String adminUsersEndpoint = '/api/admin/users';

  // Endpoints: Jadwal Kuliah (jadwalkampusku.my.id)
  static const String scheduleEndpoint = '/api/schedules';
  static const String todayScheduleEndpoint = '/api/schedules/today';

  // Endpoints: Deadline & Tasks (IF03 Academic Bot SQLite)
  static const String deadlinesEndpoint = '/api/deadlines';
  static const String activeDeadlinesEndpoint = '/api/deadlines/active';

  // Endpoints: Kelompok Aktif (IF03 Academic Bot SQLite)
  static const String groupsEndpoint = '/api/groups';
  static const String myGroupsEndpoint = '/api/groups/my-active';
}
