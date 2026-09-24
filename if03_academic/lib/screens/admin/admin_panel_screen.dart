import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_colors.dart';
import '../../models/account_request.dart';
import '../../models/user.dart';
import '../../providers/admin_provider.dart';
import '../../widgets/app_card.dart';

class AdminPanelScreen extends StatefulWidget {
  const AdminPanelScreen({super.key});

  @override
  State<AdminPanelScreen> createState() => _AdminPanelScreenState();
}

class _AdminPanelScreenState extends State<AdminPanelScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final p = Provider.of<AdminProvider>(context, listen: false);
      p.fetchRequests();
      p.fetchUsers();
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _showApproveConfirm(AccountRequest request) {
    showDialog(
      context: context,
      builder: (dialogCtx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Konfirmasi Persetujuan'),
        content: Text('Setujui akun untuk "${request.name}" (@${request.username})?\n\nPengguna akan segera dapat login ke aplikasi.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogCtx).pop(),
            child: const Text('BATAL'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.success),
            onPressed: () async {
              Navigator.of(dialogCtx).pop();
              try {
                final msg = await Provider.of<AdminProvider>(context, listen: false).approveRequest(request.id);
                if (!mounted) return;
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text(msg), backgroundColor: AppColors.success),
                );
              } catch (e) {
                if (!mounted) return;
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text(e.toString()), backgroundColor: AppColors.error),
                );
              }
            },
            child: const Text('SETUJUI'),
          ),
        ],
      ),
    );
  }

  void _showRejectDialog(AccountRequest request) {
    final reasonCtrl = TextEditingController(text: 'Data Discord ID tidak cocok dengan server kelas.');
    showDialog(
      context: context,
      builder: (dialogCtx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Tolak Permohonan Akun'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Berikan alasan penolakan untuk @${request.username}:', style: const TextStyle(fontSize: 13)),
            const SizedBox(height: 10),
            TextField(
              controller: reasonCtrl,
              maxLines: 2,
              decoration: const InputDecoration(
                hintText: 'Alasan penolakan...',
                border: OutlineInputBorder(),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogCtx).pop(),
            child: const Text('BATAL'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.error),
            onPressed: () async {
              Navigator.of(dialogCtx).pop();
              try {
                final msg = await Provider.of<AdminProvider>(context, listen: false).rejectRequest(
                  request.id,
                  reason: reasonCtrl.text.trim(),
                );
                if (!mounted) return;
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text(msg), backgroundColor: AppColors.warning),
                );
              } catch (e) {
                if (!mounted) return;
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text(e.toString()), backgroundColor: AppColors.error),
                );
              }
            },
            child: const Text('TOLAK'),
          ),
        ],
      ),
    );
  }

  void _showChangeRoleDialog(User user) {
    String selectedRole = user.role;

    showDialog(
      context: context,
      builder: (dialogCtx) => StatefulBuilder(
        builder: (context, setModalState) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: Text('Ubah Role ${user.name}'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              RadioListTile<String>(
                title: const Text('MAHASISWA'),
                value: 'MAHASISWA',
                groupValue: selectedRole,
                onChanged: (v) => setModalState(() => selectedRole = v!),
              ),
              RadioListTile<String>(
                title: const Text('ADMIN'),
                value: 'ADMIN',
                groupValue: selectedRole,
                onChanged: (v) => setModalState(() => selectedRole = v!),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogCtx).pop(),
              child: const Text('BATAL'),
            ),
            ElevatedButton(
              onPressed: () async {
                Navigator.of(dialogCtx).pop();
                try {
                  final msg = await Provider.of<AdminProvider>(context, listen: false).updateUserRole(
                    user.id,
                    selectedRole,
                  );
                  if (!mounted) return;
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text(msg), backgroundColor: AppColors.success),
                  );
                } catch (e) {
                  if (!mounted) return;
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text(e.toString()), backgroundColor: AppColors.error),
                  );
                }
              },
              child: const Text('SIMPAN'),
            ),
          ],
        ),
      ),
    );
  }

  void _showDeleteUserConfirm(User user) {
    showDialog(
      context: context,
      builder: (dialogCtx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Hapus Pengguna'),
        content: Text('Yakin ingin menghapus pengguna "${user.name}" (@${user.username})?\nTindakan ini tidak dapat dibatalkan.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogCtx).pop(),
            child: const Text('BATAL'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.error),
            onPressed: () async {
              Navigator.of(dialogCtx).pop();
              try {
                final msg = await Provider.of<AdminProvider>(context, listen: false).deleteUser(user.id);
                if (!mounted) return;
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text(msg), backgroundColor: AppColors.warning),
                );
              } catch (e) {
                if (!mounted) return;
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text(e.toString()), backgroundColor: AppColors.error),
                );
              }
            },
            child: const Text('HAPUS'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final adminProvider = Provider.of<AdminProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('🛡️ Admin Panel IF03'),
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: AppColors.primary,
          tabs: [
            Tab(text: 'Permohonan (${adminProvider.pendingRequests.length})'),
            Tab(text: 'Pengguna (${adminProvider.users.length})'),
          ],
        ),
      ),
      body: adminProvider.isLoading
          ? const Center(child: CircularProgressIndicator())
          : TabBarView(
              controller: _tabController,
              children: [
                _buildRequestsTab(adminProvider),
                _buildUsersTab(adminProvider),
              ],
            ),
    );
  }

  Widget _buildRequestsTab(AdminProvider provider) {
    if (provider.requests.isEmpty) {
      return const Center(child: Text('Belum ada permohonan akun masuk.'));
    }

    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: provider.requests.length,
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final req = provider.requests[index];
        return AppCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    req.name,
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  _buildStatusBadge(req.status),
                ],
              ),
              const SizedBox(height: 4),
              Text(
                '@${req.username}',
                style: const TextStyle(fontSize: 13, color: Colors.grey, fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 10),
              const Divider(height: 1),
              const SizedBox(height: 10),

              // Discord Info with Copy Button
              Row(
                children: [
                  const Icon(Icons.discord, size: 16, color: Color(0xFF5865F2)),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      '${req.discordUsername} (${req.discordUserId})',
                      style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.copy, size: 16, color: Colors.grey),
                    tooltip: 'Salin Discord ID',
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                    onPressed: () {
                      Clipboard.setData(ClipboardData(text: req.discordUserId));
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Discord ID disalin'), duration: Duration(seconds: 1)),
                      );
                    },
                  ),
                ],
              ),

              if (req.rejectionReason != null && req.isRejected) ...[
                const SizedBox(height: 6),
                Text(
                  'Alasan ditolak: ${req.rejectionReason}',
                  style: const TextStyle(fontSize: 11, color: AppColors.error, fontStyle: FontStyle.italic),
                ),
              ],

              // Action buttons if pending
              if (req.isPending) ...[
                const SizedBox(height: 14),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        style: OutlinedButton.styleFrom(
                          foregroundColor: AppColors.error,
                          side: const BorderSide(color: AppColors.error),
                          padding: const EdgeInsets.symmetric(vertical: 8),
                        ),
                        onPressed: () => _showRejectDialog(req),
                        child: const Text('TOLAK', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.success,
                          padding: const EdgeInsets.symmetric(vertical: 8),
                        ),
                        onPressed: () => _showApproveConfirm(req),
                        child: const Text('SETUJUI', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                      ),
                    ),
                  ],
                ),
              ],
            ],
          ),
        );
      },
    );
  }

  Widget _buildUsersTab(AdminProvider provider) {
    if (provider.users.isEmpty) {
      return const Center(child: Text('Tidak ada pengguna terdaftar.'));
    }

    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: provider.users.length,
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final user = provider.users[index];
        final isAdmin = user.isAdmin;

        return AppCard(
          child: Row(
            children: [
              CircleAvatar(
                backgroundColor: isAdmin ? AppColors.primary : Colors.grey[400],
                child: Icon(
                  isAdmin ? Icons.admin_panel_settings : Icons.person,
                  color: Colors.white,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      user.name,
                      style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '@${user.username} • Discord: ${user.discordUsername}',
                      style: const TextStyle(fontSize: 11, color: Colors.grey),
                    ),
                    const SizedBox(height: 4),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: (isAdmin ? AppColors.primary : Colors.grey).withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        user.role,
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          color: isAdmin ? AppColors.primary : Colors.grey[700],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              PopupMenuButton<String>(
                onSelected: (val) {
                  if (val == 'role') {
                    _showChangeRoleDialog(user);
                  } else if (val == 'delete') {
                    _showDeleteUserConfirm(user);
                  }
                },
                itemBuilder: (context) => [
                  const PopupMenuItem(
                    value: 'role',
                    child: Row(
                      children: [
                        Icon(Icons.swap_horiz, size: 18),
                        SizedBox(width: 8),
                        Text('Ubah Role'),
                      ],
                    ),
                  ),
                  const PopupMenuItem(
                    value: 'delete',
                    child: Row(
                      children: [
                        Icon(Icons.delete_outline, size: 18, color: AppColors.error),
                        SizedBox(width: 8),
                        Text('Hapus Akun', style: TextStyle(color: AppColors.error)),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildStatusBadge(String status) {
    Color color;
    String label = status;
    switch (status.toUpperCase()) {
      case 'APPROVED':
        color = AppColors.success;
        label = 'DISETUJUI';
        break;
      case 'REJECTED':
        color = AppColors.error;
        label = 'DITOLAK';
        break;
      case 'PENDING':
      default:
        color = AppColors.warning;
        label = 'MENUNGGU';
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        label,
        style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: color),
      ),
    );
  }
}
