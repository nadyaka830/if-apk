import 'package:flutter/material.dart';
import '../models/group.dart';
import '../services/group_service.dart';

class GroupProvider extends ChangeNotifier {
  final GroupService _service = GroupService();

  List<ActiveGroup> _allGroups = [];
  List<ActiveGroup> _myGroups = [];
  bool _isLoading = false;
  String? _errorMessage;
  bool _showMyGroupsOnly = false;
  String _searchQuery = '';

  List<ActiveGroup> get allGroups => _allGroups;
  List<ActiveGroup> get myGroups => _myGroups;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  bool get showMyGroupsOnly => _showMyGroupsOnly;
  String get searchQuery => _searchQuery;

  List<ActiveGroup> get filteredGroups {
    final list = _showMyGroupsOnly ? _myGroups : _allGroups;
    if (_searchQuery.isEmpty) return list;

    final q = _searchQuery.toLowerCase();
    return list.where((g) {
      final matchName = g.groupName.toLowerCase().contains(q);
      final matchSubject = (g.subject ?? '').toLowerCase().contains(q);
      final matchOwner = g.ownerUsername.toLowerCase().contains(q);
      final matchMember = g.members.any((m) => m.discordUsername.toLowerCase().contains(q));
      return matchName || matchSubject || matchOwner || matchMember;
    }).toList();
  }

  void setFilterMyGroups(bool value) {
    _showMyGroupsOnly = value;
    notifyListeners();
  }

  void setSearchQuery(String query) {
    _searchQuery = query.trim();
    notifyListeners();
  }

  Future<void> fetchGroups({bool refresh = false}) async {
    if (_allGroups.isNotEmpty && !refresh) return;

    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _allGroups = await _service.getGroups(myOnly: false);
      _myGroups = await _service.getGroups(myOnly: true);
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _errorMessage = e.toString();
      _isLoading = false;
      notifyListeners();
    }
  }
}
