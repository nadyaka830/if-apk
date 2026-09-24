/// Model Jadwal Kuliah dari jadwalkampusku.my.id
class Schedule {
  final dynamic id;
  final String courseName;
  final String? courseCode;
  final String? lecturer;
  final String? className;
  final String? room;
  final String? day;
  final String? startTime;
  final String? endTime;
  final String? date;

  Schedule({
    this.id,
    required this.courseName,
    this.courseCode,
    this.lecturer,
    this.className,
    this.room,
    this.day,
    this.startTime,
    this.endTime,
    this.date,
  });

  String get timeRange {
    if (startTime != null && endTime != null) {
      return '$startTime - $endTime';
    }
    return startTime ?? endTime ?? '-';
  }

  factory Schedule.fromJson(Map<String, dynamic> json) {
    return Schedule(
      id: json['id'],
      courseName: json['course_name']?.toString() ??
          json['course']?.toString() ??
          json['mata_kuliah']?.toString() ??
          'Mata Kuliah',
      courseCode: json['course_code']?.toString() ?? json['kode']?.toString(),
      lecturer: json['lecturer']?.toString() ?? json['dosen']?.toString(),
      className: json['class_name']?.toString() ?? json['kelas']?.toString(),
      room: json['room']?.toString() ?? json['ruang']?.toString(),
      day: json['day']?.toString() ?? json['hari']?.toString(),
      startTime: json['start_time']?.toString() ?? json['jam_mulai']?.toString(),
      endTime: json['end_time']?.toString() ?? json['jam_selesai']?.toString(),
      date: json['date']?.toString() ?? json['tanggal']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'course_name': courseName,
      'course_code': courseCode,
      'lecturer': lecturer,
      'class_name': className,
      'room': room,
      'day': day,
      'start_time': startTime,
      'end_time': endTime,
      'date': date,
    };
  }
}
