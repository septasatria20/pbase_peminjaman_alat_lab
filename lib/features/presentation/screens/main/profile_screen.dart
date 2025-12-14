import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:pbase_peminjaman_alat_lab/features/presentation/providers/auth_provider.dart';
import 'package:pbase_peminjaman_alat_lab/features/presentation/screens/auth/login_screen.dart' hide themeGradient;
import 'package:pbase_peminjaman_alat_lab/features/presentation/screens/main/edit_profile_screen.dart';
import 'package:pbase_peminjaman_alat_lab/features/presentation/style/color.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        title: const Text(
          'Profil',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        flexibleSpace: Container(
          decoration: const BoxDecoration(gradient: themeGradient),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Consumer<AuthProvider>(
        builder: (context, authProvider, child) {
          final user = authProvider.currentUser;
          final email = user?.email ?? authProvider.firebaseUser?.email ?? '';
          final name = user?.name ?? 'User';

          return SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              children: [
                const SizedBox(height: 20),
                Container(
                  padding: const EdgeInsets.all(4),
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: themeGradient,
                  ),
                  child: Container(
                    padding: const EdgeInsets.all(32),
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.person_rounded,
                      size: 64,
                      color: primaryColor,
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                Text(
                  name,
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: textPrimary,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  email,
                  style: const TextStyle(fontSize: 14, color: textSecondary),
                ),
                const SizedBox(height: 40),

                _buildProfileMenuItem(
                  context,
                  icon: Icons.person_outline_rounded,
                  title: 'Edit Profil',
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => const EditProfileScreen(),
                      ),
                    );
                  },
                ),
                _buildProfileMenuItem(
                  context,
                  icon: Icons.help_outline_rounded,
                  title: 'Bantuan',
                  onTap: () {
                    showDialog(
                      context: context,
                      builder: (context) => AlertDialog(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        title: const Row(
                          children: [
                            Icon(Icons.help_outline, color: primaryColor),
                            SizedBox(width: 8),
                            Text('Pusat Bantuan'),
                          ],
                        ),
                        content: const Text(
                          'Untuk bantuan lebih lanjut, silakan hubungi:\n\n'
                          'Email: admin@polinema.ac.id\n'
                          'Telp: (0341) 123456\n\n'
                          'Jam Operasional:\n'
                          'Senin - Jumat: 08.00 - 16.00 WIB',
                        ),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.of(context).pop(),
                            child: const Text('Tutup'),
                          ),
                        ],
                      ),
                    );
                  },
                ),
                const SizedBox(height: 16),
                _buildProfileMenuItem(
                  context,
                  icon: Icons.logout_rounded,
                  title: 'Keluar',
                  textColor: errorColor,
                  iconColor: errorColor,
                  onTap: () => _showLogoutDialog(context),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildProfileMenuItem(
    BuildContext context, {
    required IconData icon,
    required String title,
    required VoidCallback onTap,
    Color? textColor,
    Color? iconColor,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: (iconColor ?? primaryColor).withOpacity(0.1),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, color: iconColor ?? primaryColor, size: 22),
        ),
        title: Text(
          title,
          style: TextStyle(
            fontWeight: FontWeight.w600,
            color: textColor ?? textPrimary,
            fontSize: 15,
          ),
        ),
        trailing: Icon(Icons.chevron_right_rounded, color: borderColor),
        onTap: onTap,
      ),
    );
  }

  void _showLogoutDialog(BuildContext context) {
    final authProvider = context.read<AuthProvider>();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Konfirmasi Logout'),
        content: const Text('Apakah Anda yakin ingin keluar?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            onPressed: () async {
              await authProvider.signOut();
              if (context.mounted) {
                Navigator.of(context).pop();
                Navigator.of(context).pushReplacement(
                  MaterialPageRoute(builder: (_) => const LoginScreen()),
                );
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: errorColor,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              elevation: 0,
            ),
            child: const Text('Keluar'),
          ),
        ],
      ),
    );
  }
}
