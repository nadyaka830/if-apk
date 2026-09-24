import '../core/utils/date_formatter.dart';

/// Model Deadline/Tugas dari IF03 Academic Bot (if03.db)
class Deadline {
  final int id;
  final String course;
  final String title;
  final String dueAt;
  final String? description;
  final String? channelId;
  final String priority; // 'NORMAL', 'HIGH', 'LOW'
  final String status; // 'ACTIVE', 'COMPLETED'
  final String? createdAt;

  Deadline({
    required this.id,
    required this.course,
    required this.title,
    required this.dueAt,
    this.description,
    this.channelId,
    this.priority = 'NORMAL',
    this.status = 'ACTIVE',
    this.createdAt,
  });

  bool get isHighPriority => priority.toUpperCase() == 'HIGH' || priority.toUpperCase() == 'TINGGI';
  bool get isActive => status.toUpperCase() == 'ACTIVE';

  DateTime? get dueDate => DateFormatter.parse(dueAt);

  factory Deadline.fromJson(Map<String, dynamic> json) {
    return Deadline(
      id: json['id'] is int ? json['id'] : int.tryParse(json['id']?.toString() ?? '0') ?? 0,
      course: json['course']?.toString() ?? json['subject']?.toString() ?? 'Mata Kuliah',
      title: json['title']?.toString() ?? 'Tugas',
      dueAt: json['due_at']?.toString() ?? json['deadline_date']?.toString() ?? '',
      description: json['description']?.toString(),
      channelId: json['channel_id']?.toString(),
      priority: json['priority']?.toString().toUpperCase() ?? 'NORMAL',
      status: json['status']?.toString().toUpperCase() ?? 'ACTIVE',
      createdAt: json['created_at']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'course': course,
      'title': title,
      'due_at': dueAt,
      'description': description,
      'channel_id': channelId,
      'priority': priority,
      'status': status,
      'created_at': createdAt,
    };
  }
}
