import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../core/config/api_config.dart';
import '../core/network/api_client.dart';
import '../models/deadline.dart';

class DeadlineService {
  final ApiClient _apiClient = ApiClient();
  static const String _cachedDeadlinesKey = 'if03_cached_deadlines';

  // Singleton pattern
  static final DeadlineService _instance = DeadlineService._internal();
  factory DeadlineService() => _instance;
  DeadlineService._internal();

  /// Mengambil daftar deadline aktif dari bot VPS
  Future<List<Deadline>> getDeadlines() async {
    try {
      final response = await _apiClient.botClient.get(ApiConfig.deadlinesEndpoint);
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
          final deadlines = list.map((item) => Deadline.fromJson(item as Map<String, dynamic>)).toList();
          await _saveToCache(deadlines);
          return deadlines;
        }
      }
    } catch (_) {
      // Jika jaringan gagal, gunakan cache lokal atau default data
    }

    final cached = await getCachedDeadlines();
    if (cached.isNotEmpty) {
      return cached;
    }

    // Default deadlines mock
    final defaultList = _getDefaultDeadlines();
    await _saveToCache(defaultList);
    return defaultList;
  }

  Future<List<Deadline>> getCachedDeadlines() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final str = prefs.getString(_cachedDeadlinesKey);
      if (str != null && str.isNotEmpty) {
        final List<dynamic> jsonList = jsonDecode(str);
        return jsonList.map((item) => Deadline.fromJson(item as Map<String, dynamic>)).toList();
      }
    } catch (_) {}
    return [];
  }

  Future<void> _saveToCache(List<Deadline> deadlines) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final str = jsonEncode(deadlines.map((d) => d.toJson()).toList());
      await prefs.setString(_cachedDeadlinesKey, str);
    } catch (_) {}
  }

  List<Deadline> _getDefaultDeadlines() {
    return [
      Deadline(
        id: 1,
        course: 'Statistika & Probabilitas',
        title: 'PPT Statistika & Analisis Data',
        description: 'Buat presentasi slide mengenai distribusi normal dan uji hipotesis per kelompok.',
        dueAt: '2026-09-25 10:00:00',
        priority: 'HIGH',
      ),
      Deadline(
        id: 2,
        course: 'Pemrograman Web Lanjut',
        title: 'Praktikum REST API Express.js',
        description: 'Implementasi middleware otentikasi JWT dan CRUD database SQLite.',
        dueAt: '2026-09-28 23:59:00',
        priority: 'NORMAL',
      ),
      Deadline(
        id: 3,
        course: 'Rekayasa Perangkat Lunak',
        title: 'Dokumen SRS & Diagram UML',
        description: 'Use Case Diagram, Activity Diagram, dan Sequence Diagram sistem e-academic.',
        dueAt: '2026-10-02 12:00:00',
        priority: 'NORMAL',
      ),
      Deadline(
        id: 4,
        course: 'Jaringan Komputer',
        title: 'Laporan Subnetting VLSM Cisco Packet Tracer',
        description: 'Simulasi topologi jaringan 3 router dengan routing dinamis OSPF.',
        dueAt: '2026-10-05 17:00:00',
        priority: 'LOW',
      ),
    ];
  }
}
