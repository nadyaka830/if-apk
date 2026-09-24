import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../core/config/api_config.dart';
import '../core/network/api_client.dart';
import '../models/schedule.dart';

class ScheduleService {
  final ApiClient _apiClient = ApiClient();
  static const String _cachedScheduleKey = 'if03_cached_schedules';

  // Singleton pattern
  static final ScheduleService _instance = ScheduleService._internal();
  factory ScheduleService() => _instance;
  ScheduleService._internal();

  /// Mengambil semua jadwal kuliah IF03 (Online dengan fallback cache)
  Future<List<Schedule>> getSchedules() async {
    try {
      final response = await _apiClient.scheduleClient.get(ApiConfig.scheduleEndpoint);
      if (response.statusCode == 200 && response.data != null) {
        final List<dynamic> list;
        if (response.data is List) {
          list = response.data as List;
        } else if (response.data is Map && response.data['data'] is List) {
          list = response.data['data'] as List;
        } else {
          list = [];
        }

        if (list.isNotEmpty) {
          final schedules = list.map((item) => Schedule.fromJson(item as Map<String, dynamic>)).toList();
          await _saveToCache(schedules);
          return schedules;
        }
      }
    } catch (_) {
      // Jika jaringan gagal / timeout / CORS di web, ambil dari cache atau dataset IF03 default
    }

    final cached = await getCachedSchedules();
    if (cached.isNotEmpty) {
      return cached;
    }

    // Dataset default IF03 (Semester Ganjil/Genap Teknik Informatika IF-03)
    final defaultList = _getDefaultIF03Schedules();
    await _saveToCache(defaultList);
    return defaultList;
  }

  /// Mengambil jadwal hari ini berdasarkan nama hari
  Future<List<Schedule>> getTodaySchedules() async {
    final all = await getSchedules();
    final todayName = _getIndonesianDayName(DateTime.now().weekday);
    return all.where((s) => s.day?.toLowerCase() == todayName.toLowerCase()).toList();
  }

  /// Ambil jadwal dari local cache
  Future<List<Schedule>> getCachedSchedules() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final str = prefs.getString(_cachedScheduleKey);
      if (str != null && str.isNotEmpty) {
        final List<dynamic> jsonList = jsonDecode(str);
        return jsonList.map((item) => Schedule.fromJson(item as Map<String, dynamic>)).toList();
      }
    } catch (_) {}
    return [];
  }

  Future<void> _saveToCache(List<Schedule> schedules) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final str = jsonEncode(schedules.map((s) => s.toJson()).toList());
      await prefs.setString(_cachedScheduleKey, str);
    } catch (_) {}
  }

  String _getIndonesianDayName(int weekday) {
    switch (weekday) {
      case DateTime.monday:
        return 'Senin';
      case DateTime.tuesday:
        return 'Selasa';
      case DateTime.wednesday:
        return 'Rabu';
      case DateTime.thursday:
        return 'Kamis';
      case DateTime.friday:
        return 'Jumat';
      case DateTime.saturday:
        return 'Sabtu';
      case DateTime.sunday:
      default:
        return 'Minggu';
    }
  }

  List<Schedule> _getDefaultIF03Schedules() {
    return [
      Schedule(
        id: 1,
        courseName: 'Statistika & Probabilitas',
        courseCode: 'IF-202',
        lecturer: 'Dr. Hendra M.T.',
        className: 'IF-03',
        room: 'KU3.05',
        day: 'Senin',
        startTime: '10:00',
        endTime: '12:00',
      ),
      Schedule(
        id: 2,
        courseName: 'Pemrograman Web Lanjut',
        courseCode: 'IF-301',
        lecturer: 'Rian Pratama, M.Kom.',
        className: 'IF-03',
        room: 'Lab Komputer 2',
        day: 'Senin',
        startTime: '13:00',
        endTime: '15:30',
      ),
      Schedule(
        id: 3,
        courseName: 'Rekayasa Perangkat Lunak',
        courseCode: 'IF-304',
        lecturer: 'Ir. Siti Rahma, M.Cs.',
        className: 'IF-03',
        room: 'KU2.10',
        day: 'Selasa',
        startTime: '08:00',
        endTime: '10:30',
      ),
      Schedule(
        id: 4,
        courseName: 'Jaringan Komputer & Komunikasi Data',
        courseCode: 'IF-205',
        lecturer: 'Agus Wijaya, S.T., M.Eng.',
        className: 'IF-03',
        room: 'Lab Jaringan',
        day: 'Rabu',
        startTime: '09:00',
        endTime: '11:30',
      ),
      Schedule(
        id: 5,
        courseName: 'Sistem Basis Data',
        courseCode: 'IF-206',
        lecturer: 'Dewi Lestari, S.Kom., M.T.',
        className: 'IF-03',
        room: 'KU3.02',
        day: 'Kamis',
        startTime: '10:00',
        endTime: '12:30',
      ),
      Schedule(
        id: 6,
        courseName: 'Kecerdasan Buatan (AI)',
        courseCode: 'IF-401',
        lecturer: 'Prof. Bambang Utomo',
        className: 'IF-03',
        room: 'KU1.08',
        day: 'Jumat',
        startTime: '08:00',
        endTime: '10:00',
      ),
    ];
  }
}
