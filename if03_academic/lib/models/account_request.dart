/// Model Permohonan Akun Mahasiswa
class AccountRequest {
  final int id;
  final String username;
  final String name;
  final String discordUserId;
  final String discordUsername;
  final String status; // 'PENDING', 'APPROVED', 'REJECTED'
  final String? requestedAt;
  final String? reviewedAt;
  final String? reviewedBy;
  final String? rejectionReason;

  AccountRequest({
    required this.id,
    required this.username,
    required this.name,
    required this.discordUserId,
    required this.discordUsername,
    this.status = 'PENDING',
    this.requestedAt,
    this.reviewedAt,
    this.reviewedBy,
    this.rejectionReason,
  });

  bool get isPending => status.toUpperCase() == 'PENDING';
  bool get isApproved => status.toUpperCase() == 'APPROVED';
  bool get isRejected => status.toUpperCase() == 'REJECTED';

  factory AccountRequest.fromJson(Map<String, dynamic> json) {
    return AccountRequest(
      id: json['id'] is int ? json['id'] : int.tryParse(json['id']?.toString() ?? '0') ?? 0,
      username: json['username']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      discordUserId: json['discord_user_id']?.toString() ?? '',
      discordUsername: json['discord_username']?.toString() ?? '',
      status: json['status']?.toString().toUpperCase() ?? 'PENDING',
      requestedAt: json['requested_at']?.toString(),
      reviewedAt: json['reviewed_at']?.toString(),
      reviewedBy: json['reviewed_by']?.toString(),
      rejectionReason: json['rejection_reason']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'username': username,
      'name': name,
      'discord_user_id': discordUserId,
      'discord_username': discordUsername,
      'status': status,
      'requested_at': requestedAt,
      'reviewed_at': reviewedAt,
      'reviewed_by': reviewedBy,
      'rejection_reason': rejectionReason,
    };
  }
}
