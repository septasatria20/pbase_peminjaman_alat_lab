import 'package:flutter/material.dart';
import 'package:pbase_peminjaman_alat_lab/constants/constants.dart';
import 'package:pbase_peminjaman_alat_lab/screens/auth/login_screen.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  // Fungsi untuk logout
  void _logout(BuildContext context) {
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (context) => const LoginScreen()),
      (Route<dynamic> route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Profil Pengguna"),
        backgroundColor: Colors.white,
        elevation: 1,
      ),
      backgroundColor: Colors.grey[50],
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            // --- KARTU PROFIL PENGGUNA ---
            Container(
              padding: const EdgeInsets.all(24.0),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.grey[200]!),
              ),
              child: Column(
                children: [
                  // Avatar
                  Container(
                    width: 90,
                    height: 90,
                    decoration: const BoxDecoration(
                      color: colorMaroon,
                      shape: BoxShape.circle,
                    ),
                    child: const Center(
                      child: Text(
                        "QD",
                        style: TextStyle(
                          fontSize: 36,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    "Qusnul Diah Mawanti",
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    "mahasiswa@polinema.ac.id",
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.black54,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // --- MENU PENGATURAN ---
            _buildProfileMenu(
              context: context,
              icon: Icons.person_outline,
              text: "Edit Profil",
              onTap: () {
                // TODO: Navigasi ke halaman edit profil
              },
            ),
            _buildProfileMenu(
              context: context,
              icon: Icons.help_outline,
              text: "Pusat Bantuan",
              onTap: () {},
            ),

            // --- TOMBOL LOGOUT ---
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                icon: const Icon(Icons.logout, color: colorMaroon),
                label: const Text('Logout'),
                onPressed: () => _logout(context),
                style: ElevatedButton.styleFrom(
                  foregroundColor: colorMaroon,
                  backgroundColor: const Color(0xFFFFF0F0),
                  elevation: 0,
                  side: BorderSide(color: Colors.red[100]!),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Widget helper untuk membuat tombol menu
  Widget _buildProfileMenu({
    required BuildContext context,
    required IconData icon,
    required String text,
    required VoidCallback onTap,
  }) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: Colors.grey[200]!),
      ),
      color: Colors.white,
      margin: const EdgeInsets.only(bottom: 12.0),
      child: ListTile(
        leading: Icon(icon, color: Colors.black54),
        title: Text(text, style: const TextStyle(fontWeight: FontWeight.w500)),
        trailing: const Icon(Icons.chevron_right, color: Colors.grey),
        onTap: onTap,
      ),
    );
  }
}

