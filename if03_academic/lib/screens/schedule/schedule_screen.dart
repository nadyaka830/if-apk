import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_colors.dart';
import '../../models/schedule.dart';
import '../../providers/schedule_provider.dart';
import '../../widgets/app_card.dart';

class ScheduleScreen extends StatefulWidget {
  const ScheduleScreen({super.key});

  @override
  State<ScheduleScreen> createState() => _ScheduleScreenState();
}

class _ScheduleScreenState extends State<ScheduleScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<ScheduleProvider>(context, listen: false).fetchSchedules();
    });
  }

  @override
  Widget build(BuildContext context) {
    final scheduleProvider = Provider.of<ScheduleProvider>(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text('📅 Jadwal Kuliah IF03'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => scheduleProvider.fetchSchedules(refresh: true),
            tooltip: 'Segarkan Jadwal',
          ),
        ],
      ),
      body: Column(
        children: [
          // Banner Sumber Jadwalkampusku
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            color: AppColors.primary.withValues(alpha: 0.08),
            child: const Row(
              children: [
                Icon(Icons.link, size: 16, color: AppColors.primary),
                SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Disinkronkan dari jadwalkampusku.my.id (Kelas IF-03)',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: AppColors.primary,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Sub-Tab Switcher: Hari Ini vs Mingguan
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
            child: Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: isDark ? AppColors.darkCard : AppColors.lightBorder.withValues(alpha: 0.5),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: _buildSubTabButton(
                      title: 'Hari Ini',
                      isSelected: scheduleProvider.viewMode == ScheduleViewMode.today,
                      onTap: () => scheduleProvider.setViewMode(ScheduleViewMode.today),
                    ),
                  ),
                  Expanded(
                    child: _buildSubTabButton(
                      title: 'Mingguan',
                      isSelected: scheduleProvider.viewMode == ScheduleViewMode.weekly,
                      onTap: () => scheduleProvider.setViewMode(ScheduleViewMode.weekly),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Day Filter (Khusus jika mode Mingguan)
          if (scheduleProvider.viewMode == ScheduleViewMode.weekly)
            Container(
              height: 40,
              margin: const EdgeInsets.only(bottom: 8),
              child: ListView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                children: ['Semua', 'Senin', 'Selasa', 'Rabu', 'Kamis', 'Jumat'].map((day) {
                  final isSelected = scheduleProvider.selectedDay == day;
                  return Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: FilterChip(
                      selected: isSelected,
                      label: Text(day),
                      labelStyle: TextStyle(
                        fontSize: 12,
                        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                        color: isSelected ? Colors.white : (isDark ? Colors.white70 : Colors.black87),
                      ),
                      backgroundColor: isDark ? AppColors.darkCard : Colors.grey[200],
                      selectedColor: AppColors.primary,
                      showCheckmark: false,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                      onSelected: (_) => scheduleProvider.setSelectedDay(day),
                    ),
                  );
                }).toList(),
              ),
            ),

          // Content List
          Expanded(
            child: scheduleProvider.isLoading
                ? const Center(child: CircularProgressIndicator())
                : RefreshIndicator(
                    onRefresh: () => scheduleProvider.fetchSchedules(refresh: true),
                    child: _buildScheduleList(scheduleProvider),
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildSubTabButton({
    required String title,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 9),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: AppColors.primary.withValues(alpha: 0.25),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ]
              : null,
        ),
        alignment: Alignment.center,
        child: Text(
          title,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.bold,
            color: isSelected ? Colors.white : Colors.grey,
          ),
        ),
      ),
    );
  }

  Widget _buildScheduleList(ScheduleProvider provider) {
    final list = provider.viewMode == ScheduleViewMode.today
        ? provider.todaySchedules
        : provider.filteredWeeklySchedules;

    if (list.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.event_available, size: 56, color: Colors.grey.withValues(alpha: 0.5)),
            const SizedBox(height: 12),
            Text(
              provider.viewMode == ScheduleViewMode.today
                  ? 'Tidak ada jadwal kuliah hari ini! 🎉'
                  : 'Tidak ada jadwal kuliah yang ditemukan.',
              style: const TextStyle(fontSize: 14, color: Colors.grey, fontWeight: FontWeight.w600),
            ),
          ],
        ),
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: list.length,
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final item = list[index];
        return _buildScheduleCard(item);
      },
    );
  }

  Widget _buildScheduleCard(Schedule schedule) {
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              if (schedule.courseCode != null)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    schedule.courseCode!,
                    style: const TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: AppColors.primary,
                    ),
                  ),
                ),
              Row(
                children: [
                  if (schedule.day != null)
                    Text(
                      '${schedule.day!} • ',
                      style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Colors.grey),
                    ),
                  const Icon(Icons.access_time, size: 14, color: Colors.grey),
                  const SizedBox(width: 4),
                  Text(
                    schedule.timeRange,
                    style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.grey),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            schedule.courseName,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 10),
          const Divider(height: 1),
          const SizedBox(height: 10),
          Row(
            children: [
              if (schedule.room != null) ...[
                const Icon(Icons.room_outlined, size: 16, color: AppColors.secondary),
                const SizedBox(width: 4),
                Text(
                  schedule.room!,
                  style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
                ),
                const SizedBox(width: 16),
              ],
              if (schedule.lecturer != null) ...[
                const Icon(Icons.person_outline, size: 16, color: Colors.grey),
                const SizedBox(width: 4),
                Expanded(
                  child: Text(
                    schedule.lecturer!,
                    style: const TextStyle(fontSize: 12, color: Colors.grey),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }
}
