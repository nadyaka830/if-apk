import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../services/account_request_service.dart';

class AccountRequestScreen extends StatefulWidget {
  const AccountRequestScreen({super.key});

  @override
  State<AccountRequestScreen> createState() => _AccountRequestScreenState();
}

class _AccountRequestScreenState extends State<AccountRequestScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _discordIdController = TextEditingController();
  final TextEditingController _discordUsernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();

  final AccountRequestService _service = AccountRequestService();

  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  bool _isLoading = false;

  @override
  void dispose() {
    _nameController.dispose();
    _usernameController.dispose();
    _discordIdController.dispose();
    _discordUsernameController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  void _showDiscordIdHelp() {
    showDialog(
      context: context,
      builder: (dialogCtx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Row(
          children: [
            Icon(Icons.discord, color: Color(0xFF5865F2)),
            SizedBox(width: 8),
            Text('Cara Cek Discord User ID', style: TextStyle(fontSize: 16)),
          ],
        ),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Discord User ID berupa 17-19 digit angka unik akun Anda (bukan username biasa).',
              style: TextStyle(fontSize: 13, height: 1.4),
            ),
            SizedBox(height: 12),
            Text('Langkah-langkah:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
            SizedBox(height: 6),
            Text('1. Buka aplikasi Discord (HP / PC).', style: TextStyle(fontSize: 12)),
            Text('2. Masuk ke Pengaturan Akun (User Settings) > Lanjutan (Advanced).', style: TextStyle(fontSize: 12)),
            Text('3. Aktifkan opsi "Mode Pengembang" (Developer Mode).', style: TextStyle(fontSize: 12)),
            Text('4. Buka profil akun Anda, klik titik tiga (...) lalu pilih "Salin ID Pengguna" (Copy User ID).', style: TextStyle(fontSize: 12)),
            Text('5. Tempelkan (paste) angka tersebut ke formulir ini.', style: TextStyle(fontSize: 12)),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogCtx).pop(),
            child: const Text('MENGERTI'),
          ),
        ],
      ),
    );
  }

  Future<void> _handleSubmit() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    FocusScope.of(context).unfocus();
    setState(() => _isLoading = true);

    try {
      final message = await _service.submitAccountRequest(
        username: _usernameController.text,
        name: _nameController.text,
        password: _passwordController.text,
        discordUserId: _discordIdController.text,
        discordUsername: _discordUsernameController.text,
      );

      if (!mounted) return;
      setState(() => _isLoading = false);

      // Tampilkan Dialog Sukses
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (dialogCtx) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: const Row(
            children: [
              Icon(Icons.check_circle, color: AppColors.success, size: 28),
              SizedBox(width: 8),
              Text('Permohonan Terkirim', style: TextStyle(fontSize: 16)),
            ],
          ),
          content: Text(
            message,
            style: const TextStyle(fontSize: 13, height: 1.4),
          ),
          actions: [
            ElevatedButton(
              onPressed: () {
                Navigator.of(dialogCtx).pop();
                Navigator.of(context).pop(); // Kembali ke halaman login
              },
              child: const Text('KEMBALI KE LOGIN'),
            ),
          ],
        ),
      );
    } catch (e) {
      if (!mounted) return;
      setState(() => _isLoading = false);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e.toString()),
          backgroundColor: AppColors.error,
          behavior: SnackBarBehavior.floating,
          duration: const Duration(seconds: 4),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Permohonan Akun'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Banner Informasi
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.pad(BorderSide(color: AppColors.primary.withValues(alpha: 0.2))),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.info_outline, color: AppColors.primary, size: 22),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          'Akun IF03 Academic khusus untuk mahasiswa kelas IF03. Permohonan akan diverifikasi oleh Admin kelas.',
                          style: TextStyle(
                            fontSize: 12,
                            color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 20),

                // Nama Lengkap
                _buildLabel('Nama Lengkap (Sesuai Presensi/KTM)', isDark),
                TextFormField(
                  controller: _nameController,
                  textInputAction: TextInputAction.next,
                  decoration: const InputDecoration(
                    hintText: 'Contoh: Budi Santoso',
                    prefixIcon: Icon(Icons.badge_outlined, size: 20),
                  ),
                  validator: (v) => (v == null || v.trim().isEmpty) ? 'Nama lengkap wajib diisi' : null,
                ),

                const SizedBox(height: 16),

                // Username
                _buildLabel('Username (Untuk Login APK)', isDark),
                TextFormField(
                  controller: _usernameController,
                  textInputAction: TextInputAction.next,
                  decoration: const InputDecoration(
                    hintText: 'Contoh: budi_santoso',
                    prefixIcon: Icon(Icons.person_outline, size: 20),
                  ),
                  validator: (v) {
                    if (v == null || v.trim().isEmpty) return 'Username wajib diisi';
                    if (v.trim().length < 3) return 'Username minimal 3 karakter';
                    if (!RegExp(r'^[a-zA-Z0-9_]+$').hasMatch(v.trim())) {
                      return 'Hanya boleh huruf, angka, dan underscore (_)';
                    }
                    return null;
                  },
                ),

                const SizedBox(height: 16),

                // Discord User ID (with help button)
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _buildLabel('Discord User ID (17-19 Digit Angka)', isDark),
                    GestureDetector(
                      onTap: _showDiscordIdHelp,
                      child: const Text(
                        'Cara Cek ID?',
                        style: TextStyle(
                          fontSize: 12,
                          color: AppColors.primary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                TextFormField(
                  controller: _discordIdController,
                  keyboardType: TextInputType.number,
                  textInputAction: TextInputAction.next,
                  decoration: const InputDecoration(
                    hintText: 'Contoh: 891234567890123456',
                    prefixIcon: Icon(Icons.discord, size: 20, color: Color(0xFF5865F2)),
                  ),
                  validator: (v) {
                    if (v == null || v.trim().isEmpty) return 'Discord User ID wajib diisi';
                    if (!RegExp(r'^\d{17,19}$').hasMatch(v.trim())) {
                      return 'Harus berupa 17-19 digit angka';
                    }
                    return null;
                  },
                ),

                const SizedBox(height: 16),

                // Discord Username
                _buildLabel('Discord Username / Handle', isDark),
                TextFormField(
                  controller: _discordUsernameController,
                  textInputAction: TextInputAction.next,
                  decoration: const InputDecoration(
                    hintText: 'Contoh: budi#1234 atau budisantoso',
                    prefixIcon: Icon(Icons.alternate_email, size: 20),
                  ),
                  validator: (v) => (v == null || v.trim().isEmpty) ? 'Discord username wajib diisi' : null,
                ),

                const SizedBox(height: 16),

                // Password
                _buildLabel('Password', isDark),
                TextFormField(
                  controller: _passwordController,
                  obscureText: _obscurePassword,
                  textInputAction: TextInputAction.next,
                  decoration: InputDecoration(
                    hintText: 'Minimal 6 karakter',
                    prefixIcon: const Icon(Icons.lock_outline, size: 20),
                    suffixIcon: IconButton(
                      icon: Icon(_obscurePassword ? Icons.visibility_off_outlined : Icons.visibility_outlined, size: 20),
                      onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                    ),
                  ),
                  validator: (v) {
                    if (v == null || v.isEmpty) return 'Password wajib diisi';
                    if (v.length < 6) return 'Password minimal 6 karakter';
                    return null;
                  },
                ),

                const SizedBox(height: 16),

                // Konfirmasi Password
                _buildLabel('Konfirmasi Password', isDark),
                TextFormField(
                  controller: _confirmPasswordController,
                  obscureText: _obscureConfirmPassword,
                  textInputAction: TextInputAction.done,
                  decoration: InputDecoration(
                    hintText: 'Ketik ulang password',
                    prefixIcon: const Icon(Icons.lock_outline, size: 20),
                    suffixIcon: IconButton(
                      icon: Icon(_obscureConfirmPassword ? Icons.visibility_off_outlined : Icons.visibility_outlined, size: 20),
                      onPressed: () => setState(() => _obscureConfirmPassword = !_obscureConfirmPassword),
                    ),
                  ),
                  validator: (v) {
                    if (v != _passwordController.text) return 'Password tidak cocok';
                    return null;
                  },
                ),

                const SizedBox(height: 28),

                // Tombol Submit
                ElevatedButton(
                  onPressed: _isLoading ? null : _handleSubmit,
                  child: _isLoading
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                        )
                      : const Text(
                          'KIRIM PERMOHONAN AKUN',
                          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                        ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLabel(String text, bool isDark) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
        ),
      ),
    );
  }
}
