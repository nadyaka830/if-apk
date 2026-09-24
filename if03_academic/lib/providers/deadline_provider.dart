import 'package:flutter/material.dart';
import '../models/deadline.dart';
import '../services/deadline_service.dart';

class DeadlineProvider extends ChangeNotifier {
  final DeadlineService _service = DeadlineService();

  List<Deadline> _deadlines = [];
  final Set<int> _completedIds = {};
  bool _isLoading = false;
  String? _errorMessage;
  String _selectedFilter = 'Semua';
  String _searchQuery = '';

  List<Deadline> get deadlines => _deadlines;
  Set<int> get completedIds => _completedIds;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  String get selectedFilter => _selectedFilter;

  List<Deadline> get filteredDeadlines {
    return _deadlines.where((d) {
      final isCompleted = _completedIds.contains(d.id);

      // Filter by category
      if (_selectedFilter == 'Selesai' && !isCompleted) return false;
      if (_selectedFilter != 'Selesai' && _selectedFilter != 'Semua' && isCompleted) return false;

      if (_selectedFilter == 'Tinggi' && !d.isHighPriority) return false;
      if (_selectedFilter == 'Normal' && d.isHighPriority) return false;

      // Filter by search query
      if (_searchQuery.isNotEmpty) {
        final q = _searchQuery.toLowerCase();
        final matchTitle = d.title.toLowerCase().contains(q);
        final matchCourse = d.course.toLowerCase().contains(q);
        return matchTitle || matchCourse;
      }

      return true;
    }).toList();
  }

  void setFilter(String filter) {
    _selectedFilter = filter;
    notifyListeners();
  }

  void setSearchQuery(String query) {
    _searchQuery = query.trim();
    notifyListeners();
  }

  void toggleCompleted(int id) {
    if (_completedIds.contains(id)) {
      _completedIds.remove(id);
    } else {
      _completedIds.add(id);
    }
    notifyListeners();
  }

  Future<void> fetchDeadlines({bool refresh = false}) async {
    if (_deadlines.isNotEmpty && !refresh) return;

    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _deadlines = await _service.getDeadlines();
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _errorMessage = e.toString();
      _isLoading = false;
      notifyListeners();
    }
  }
}
