/// Model Akun Pengguna IF03 Academic
class User {
  final int? id;
  final String username;
  final String name;
  final String role; // 'ADMIN' atau 'MAHASISWA'
  final String discordUserId;
  final String discordUsername;

  User({
    this.id,
    required this.username,
    required this.name,
    required this.role,
    required this.discordUserId,
    required this.discordUsername,
  });

  bool get isAdmin => role.toUpperCase() == 'ADMIN';
  bool get isMahasiswa => role.toUpperCase() == 'MAHASISWA';

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'] is int ? json['id'] : int.tryParse(json['id']?.toString() ?? ''),
      username: json['username']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      role: json['role']?.toString().toUpperCase() ?? 'MAHASISWA',
      discordUserId: json['discord_user_id']?.toString() ?? '',
      discordUsername: json['discord_username']?.toString() ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'username': username,
      'name': name,
      'role': role,
      'discord_user_id': discordUserId,
      'discord_username': discordUsername,
    };
  }
}
