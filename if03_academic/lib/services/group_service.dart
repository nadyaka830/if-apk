import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../core/config/api_config.dart';
import '../core/network/api_client.dart';
import '../models/group.dart';

class GroupService {
  final ApiClient _apiClient = ApiClient();
  static const String _cachedGroupsKey = 'if03_cached_groups';

  // Singleton pattern
  static final GroupService _instance = GroupService._internal();
  factory GroupService() => _instance;
  GroupService._internal();

  /// Mengambil daftar kelompok kelas
  Future<List<ActiveGroup>> getGroups({bool myOnly = false}) async {
    final endpoint = myOnly ? ApiConfig.myGroupsEndpoint : ApiConfig.groupsEndpoint;

    try {
      final response = await _apiClient.botClient.get(endpoint);
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
          final groups = list.map((item) => ActiveGroup.fromJson(item as Map<String, dynamic>)).toList();
          await _saveToCache(groups);
          return groups;
        }
      }
    } catch (_) {
      // Jika offline, ambil dari cache atau default
    }

    final cached = await getCachedGroups();
    if (cached.isNotEmpty) {
      return cached;
    }

    final defaultList = _getDefaultGroups();
    await _saveToCache(defaultList);
    return defaultList;
  }

  Future<List<ActiveGroup>> getCachedGroups() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final str = prefs.getString(_cachedGroupsKey);
      if (str != null && str.isNotEmpty) {
        final List<dynamic> jsonList = jsonDecode(str);
        return jsonList.map((item) => ActiveGroup.fromJson(item as Map<String, dynamic>)).toList();
      }
    } catch (_) {}
    return [];
  }

  Future<void> _saveToCache(List<ActiveGroup> groups) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final str = jsonEncode(groups.map((g) => g.toJson()).toList());
      await prefs.setString(_cachedGroupsKey, str);
    } catch (_) {}
  }

  List<ActiveGroup> _getDefaultGroups() {
    return [
      ActiveGroup(
        groupId: 1,
        groupName: 'Kelompok 3',
        subject: 'Statistika & Probabilitas',
        ownerDiscordUserId: '101234567890123456',
        ownerUsername: 'budi_santoso',
        status: 'ACTIVE',
        isUserOwner: false,
        members: [
          GroupMember(discordUserId: '101234567890123456', discordUsername: 'budi_santoso'),
          GroupMember(discordUserId: '123456789012345678', discordUsername: 'nadyaka'),
          GroupMember(discordUserId: '102345678901234567', discordUsername: 'ara_putri'),
          GroupMember(discordUserId: '103456789012345678', discordUsername: 'dimas_arya'),
        ],
      ),
      ActiveGroup(
        groupId: 2,
        groupName: 'Kelompok 1',
        subject: 'Pemrograman Web Lanjut',
        ownerDiscordUserId: '104567890123456789',
        ownerUsername: 'citra_ayu',
        status: 'ACTIVE',
        isUserOwner: false,
        members: [
          GroupMember(discordUserId: '104567890123456789', discordUsername: 'citra_ayu'),
          GroupMember(discordUserId: '105678901234567890', discordUsername: 'fajar_fadilah'),
          GroupMember(discordUserId: '106789012345678901', discordUsername: 'gilang_ramadhan'),
        ],
      ),
      ActiveGroup(
        groupId: 3,
        groupName: 'Kelompok 5',
        subject: 'Rekayasa Perangkat Lunak',
        ownerDiscordUserId: '123456789012345678',
        ownerUsername: 'nadyaka',
        status: 'ACTIVE',
        isUserOwner: true,
        members: [
          GroupMember(discordUserId: '123456789012345678', discordUsername: 'nadyaka'),
          GroupMember(discordUserId: '107890123456789012', discordUsername: 'hani_wijaya'),
          GroupMember(discordUserId: '108901234567890123', discordUsername: 'indra_kurnia'),
        ],
      ),
    ];
  }
}
