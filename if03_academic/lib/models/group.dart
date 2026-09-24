/// Anggota kelompok Discord
class GroupMember {
  final String discordUserId;
  final String discordUsername;

  GroupMember({
    required this.discordUserId,
    required this.discordUsername,
  });

  factory GroupMember.fromJson(dynamic json) {
    if (json is String) {
      return GroupMember(
        discordUserId: '',
        discordUsername: json,
      );
    }
    if (json is Map) {
      return GroupMember(
        discordUserId: json['discord_user_id']?.toString() ?? json['discord_id']?.toString() ?? '',
        discordUsername: json['discord_username']?.toString() ?? json['name']?.toString() ?? 'Member',
      );
    }
    return GroupMember(discordUserId: '', discordUsername: 'Member');
  }

  Map<String, dynamic> toJson() {
    return {
      'discord_user_id': discordUserId,
      'discord_username': discordUsername,
    };
  }
}

/// Model Kelompok Aktif dari IF03 Academic Bot (if03.db)
class ActiveGroup {
  final dynamic groupId;
  final String groupName;
  final String? subject;
  final String ownerDiscordUserId;
  final String ownerUsername;
  final String status; // 'ACTIVE'
  final String? createdAt;
  final List<GroupMember> members;
  final bool isUserOwner;

  ActiveGroup({
    required this.groupId,
    required this.groupName,
    this.subject,
    required this.ownerDiscordUserId,
    required this.ownerUsername,
    this.status = 'ACTIVE',
    this.createdAt,
    this.members = const [],
    this.isUserOwner = false,
  });

  bool get isActive => status.toUpperCase() == 'ACTIVE';

  factory ActiveGroup.fromJson(Map<String, dynamic> json) {
    var rawMembers = json['members'];
    List<GroupMember> memberList = [];
    if (rawMembers is List) {
      memberList = rawMembers.map((m) => GroupMember.fromJson(m)).toList();
    }

    final name = json['group_name']?.toString() ??
        (json['groupNumber'] != null ? 'Kelompok ${json['groupNumber']}' : 'Kelompok');

    return ActiveGroup(
      groupId: json['group_id'] ?? json['id'] ?? 0,
      groupName: name,
      subject: json['subject']?.toString(),
      ownerDiscordUserId: json['owner_discord_user_id']?.toString() ?? json['ownerId']?.toString() ?? '',
      ownerUsername: json['owner_username']?.toString() ?? json['ownerName']?.toString() ?? 'Owner',
      status: json['status']?.toString().toUpperCase() ?? 'ACTIVE',
      createdAt: json['created_at']?.toString() ?? json['createdAt']?.toString(),
      members: memberList,
      isUserOwner: json['isUserOwner'] == true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'group_id': groupId,
      'group_name': groupName,
      'subject': subject,
      'owner_discord_user_id': ownerDiscordUserId,
      'owner_username': ownerUsername,
      'status': status,
      'created_at': createdAt,
      'members': members.map((m) => m.toJson()).toList(),
      'isUserOwner': isUserOwner,
    };
  }
}
