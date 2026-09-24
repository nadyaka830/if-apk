import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_colors.dart';
import '../../models/deadline.dart';
import '../../providers/deadline_provider.dart';
import '../../widgets/app_card.dart';

class DeadlinesScreen extends StatefulWidget {
  const DeadlinesScreen({super.key});

  @override
  State<DeadlinesScreen> createState() => _DeadlinesScreenState();
}

class _DeadlinesScreenState extends State<DeadlinesScreen> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<DeadlineProvider>(context, listen: false).fetchDeadlines();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final deadlineProvider = Provider.of<DeadlineProvider>(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text('📝 Tugas & Deadline IF03'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => deadlineProvider.fetchDeadlines(refresh: true),
            tooltip: 'Segarkan',
          ),
        ],
      ),
      body: Column(
        children: [
          // Search Bar
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
            child: TextField(
              controller: _searchController,
              onChanged: (val) => deadlineProvider.setSearchQuery(val),
              decoration: InputDecoration(
                hintText: 'Cari tugas atau mata kuliah...',
                prefixIcon: const Icon(Icons.search, size: 20),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear, size: 18),
                        onPressed: () {
                          _searchController.clear();
                          deadlineProvider.setSearchQuery('');
                        },
                      )
                    : null,
                contentPadding: const EdgeInsets.symmetric(vertical: 0, horizontal: 16),
              ),
            ),
          ),

          // Filter Chips (Semua, Tinggi, Normal, Selesai)
          Container(
            height: 42,
            margin: const EdgeInsets.only(bottom: 8),
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              children: ['Semua', 'Tinggi', 'Normal', 'Selesai'].map((filter) {
                final isSelected = deadlineProvider.selectedFilter == filter;
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: FilterChip(
                    selected: isSelected,
                    label: Text(filter),
                    labelStyle: TextStyle(
                      fontSize: 12,
                      fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                      color: isSelected ? Colors.white : (isDark ? Colors.white70 : Colors.black87),
                    ),
                    backgroundColor: isDark ? AppColors.darkCard : Colors.grey[200],
                    selectedColor: filter == 'Tinggi' ? AppColors.priorityHigh : AppColors.primary,
                    showCheckmark: false,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                    onSelected: (_) => deadlineProvider.setFilter(filter),
                  ),
                );
              }).toList(),
            ),
          ),

          // Deadlines List
          Expanded(
            child: deadlineProvider.isLoading
                ? const Center(child: CircularProgressIndicator())
                : RefreshIndicator(
                    onRefresh: () => deadlineProvider.fetchDeadlines(refresh: true),
                    child: _buildDeadlineList(deadlineProvider),
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildDeadlineList(DeadlineProvider provider) {
    final list = provider.filteredDeadlines;

    if (list.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.assignment_turned_in_outlined, size: 56, color: Colors.grey.withValues(alpha: 0.5)),
            const SizedBox(height: 12),
            const Text(
              'Tidak ada tugas pada kategori ini! 🎉',
              style: TextStyle(fontSize: 14, color: Colors.grey, fontWeight: FontWeight.w600),
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
        final isCompleted = provider.completedIds.contains(item.id);
        return _buildDeadlineCard(item, isCompleted, () {
          provider.toggleCompleted(item.id);
        });
      },
    );
  }

  Widget _buildDeadlineCard(Deadline deadline, bool isCompleted, VoidCallback onToggle) {
    final isHigh = deadline.isHighPriority;

    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Checkbox Selesai
              IconButton(
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
                icon: Icon(
                  isCompleted ? Icons.check_circle : Icons.radio_button_unchecked,
                  color: isCompleted ? AppColors.success : Colors.grey,
                  size: 22,
                ),
                onPressed: onToggle,
                tooltip: isCompleted ? 'Tandai belum selesai' : 'Tandai selesai',
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: AppColors.primary.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            deadline.course,
                            style: const TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                              color: AppColors.primary,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                          decoration: BoxDecoration(
                            color: isHigh
                                ? AppColors.priorityHigh.withValues(alpha: 0.15)
                                : AppColors.priorityMedium.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            isHigh ? 'PRIORITAS TINGGI' : 'NORMAL',
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w700,
                              color: isHigh ? AppColors.priorityHigh : AppColors.priorityMedium,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Text(
                      deadline.title,
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        decoration: isCompleted ? TextDecoration.lineThrough : null,
                        color: isCompleted ? Colors.grey : null,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          if (deadline.description != null && deadline.description!.isNotEmpty) ...[
            const SizedBox(height: 10),
            Text(
              deadline.description!,
              style: const TextStyle(fontSize: 12, color: Colors.grey, height: 1.4),
            ),
          ],

          const SizedBox(height: 12),
          const Divider(height: 1),
          const SizedBox(height: 10),

          // Tanggal batas pengumpulan
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Icon(
                    Icons.alarm,
                    size: 15,
                    color: isHigh ? AppColors.priorityHigh : Colors.grey,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    'Batas: ${deadline.dueAt}',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: isHigh ? AppColors.priorityHigh : Colors.grey,
                    ),
                  ),
                ],
              ),
              if (isCompleted)
                const Text(
                  'Terselesaikan ✓',
                  style: TextStyle(fontSize: 11, color: AppColors.success, fontWeight: FontWeight.bold),
                ),
            ],
          ),
        ],
      ),
    );
  }
}
