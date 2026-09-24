import 'package:flutter/material.dart';
import '../models/account_request.dart';
import '../models/user.dart';
import '../services/admin_service.dart';

class AdminProvider extends ChangeNotifier {
  final AdminService _service = AdminService();

  List<AccountRequest> _requests = [];
  List<User> _users = [];
  bool _isLoading = false;
  String? _errorMessage;

  List<AccountRequest> get requests => _requests;
  List<User> get users => _users;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  List<AccountRequest> get pendingRequests => _requests.where((r) => r.isPending).toList();

  Future<void> fetchRequests({String? status}) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _requests = await _service.getAccountRequests(status: status);
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _errorMessage = e.toString();
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> fetchUsers() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _users = await _service.getUsers();
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _errorMessage = e.toString();
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<String> approveRequest(int id) async {
    try {
      final msg = await _service.approveRequest(id);
      await fetchRequests();
      return msg;
    } catch (e) {
      rethrow;
    }
  }

  Future<String> rejectRequest(int id, {String? reason}) async {
    try {
      final msg = await _service.rejectRequest(id, reason: reason);
      await fetchRequests();
      return msg;
    } catch (e) {
      rethrow;
    }
  }

  Future<String> updateUserRole(int userId, String newRole) async {
    try {
      final msg = await _service.updateUserRole(userId, newRole);
      await fetchUsers();
      return msg;
    } catch (e) {
      rethrow;
    }
  }

  Future<String> deleteUser(int userId) async {
    try {
      final msg = await _service.deleteUser(userId);
      await fetchUsers();
      return msg;
    } catch (e) {
      rethrow;
    }
  }
}
