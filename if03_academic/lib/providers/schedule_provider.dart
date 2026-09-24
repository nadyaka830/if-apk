import 'package:flutter/material.dart';
import '../models/schedule.dart';
import '../services/schedule_service.dart';

enum ScheduleViewMode { today, weekly }

class ScheduleProvider extends ChangeNotifier {
  final ScheduleService _service = ScheduleService();

  List<Schedule> _allSchedules = [];
  List<Schedule> _todaySchedules = [];
  bool _isLoading = false;
  String? _errorMessage;
  ScheduleViewMode _viewMode = ScheduleViewMode.today;
  String _selectedDay = 'Semua';

  List<Schedule> get allSchedules => _allSchedules;
  List<Schedule> get todaySchedules => _todaySchedules;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  ScheduleViewMode get viewMode => _viewMode;
  String get selectedDay => _selectedDay;

  List<Schedule> get filteredWeeklySchedules {
    if (_selectedDay == 'Semua') {
      return _allSchedules;
    }
    return _allSchedules.where((s) => s.day?.toLowerCase() == _selectedDay.toLowerCase()).toList();
  }

  void setViewMode(ScheduleViewMode mode) {
    _viewMode = mode;
    notifyListeners();
  }

  void setSelectedDay(String day) {
    _selectedDay = day;
    notifyListeners();
  }

  Future<void> fetchSchedules({bool refresh = false}) async {
    if (_allSchedules.isNotEmpty && !refresh) return;

    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _allSchedules = await _service.getSchedules();
      _todaySchedules = await _service.getTodaySchedules();
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _errorMessage = e.toString();
      _isLoading = false;
      notifyListeners();
    }
  }
}
