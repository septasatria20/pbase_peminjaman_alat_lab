import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

import '../../providers/auth_provider.dart';
import '../../providers/alat_provider.dart';
import '../../providers/history_provider.dart';
import '../../providers/chat_provider.dart';
import '../../style/color.dart';

import '../auth/login_screen.dart';
import '../main/edit_profile_screen.dart';
import '../chat/chat_screen.dart';

import 'widgets/edit_peminjaman_dialog.dart';
import '../../../../core/constants/lab_constants.dart';
import '../../../../core/constants/chat_templates.dart';
import 'add_edit_alat_screen.dart';

class AdminDashboardScreen extends StatefulWidget {
  const AdminDashboardScreen({Key? key}) : super(key: key);

  @override
  State<AdminDashboardScreen> createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends State<AdminDashboardScreen> {
  int _selectedIndex = 0;

  final Map<String, Map<String, dynamic>> ruangStyle = {
    "BA": {
      "color": const Color(0xFFE0F2FE),
      "text": const Color(0xFF0C4A6E),
      "icon": Icons.business_center,
    },
    "IS": {
      "color": const Color(0xFFE5E7EB),
      "text": const Color(0xFF374151),
      "icon": Icons.computer,
    },
    "NCS": {
      "color": const Color(0xFFFFEDD5),
      "text": const Color(0xFF9A3412),
      "icon": Icons.shield,
    },
    "SE": {
      "color": const Color(0xFFEDE9FE),
      "text": const Color(0xFF5B21B6),
      "icon": Icons.code,
    },
    "STUDIO": {
      "color": const Color(0xFFFCE7F3),
      "text": const Color(0xFF9D174D),
      "icon": Icons.video_camera_back,
    },
  };

  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      final alatProvider = context.read<AlatProvider>();
      final historyProvider = context.read<HistoryProvider>();
      final authProvider = context.read<AuthProvider>();

      alatProvider.fetchAlatStream();

      // Fetch history konfirmasi (akan difilter di UI berdasarkan lab admin)
      final adminLab = authProvider.userLab ?? 'BA';
      historyProvider.fetchHistoryKonfirmasiPeminjaman();

      // ignore: avoid_print
      print('🔍 [AdminDashboard] Fetching data for lab: $adminLab');
    });
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;

      // Refresh history data when navigating to Peminjaman tab
      if (_selectedIndex == 2) {
        final historyProvider = context.read<HistoryProvider>();
        final authProvider = context.read<AuthProvider>();
        final adminLab = authProvider.userLab ?? 'BA';

        historyProvider.fetchHistoryKonfirmasiPeminjaman();
        // ignore: avoid_print
        print('🔄 [AdminDashboard] Refreshing peminjaman data for lab: $adminLab');
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: Text(
          _getAppBarTitle(),
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w600,
          ),
        ),
        backgroundColor: colorMaroon,
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout, color: Colors.white),
            tooltip: 'Keluar',
            onPressed: () => _showLogoutDialog(context),
          ),
        ],
      ),
      floatingActionButton: _selectedIndex == 1
          ? FloatingActionButton.extended(
              onPressed: () async {
                final result = await Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const AddEditAlatScreen()),
                );

                if (!mounted) return;

                // Refresh list if alat was added
                if (result == true) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Data berhasil disimpan'),
                      backgroundColor: Colors.green,
                    ),
                  );
                }
              },
              backgroundColor: colorMaroon,
              foregroundColor: Colors.white,
              icon: const Icon(Icons.add, color: Colors.white),
              label: const Text(
                'Tambah Alat',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                ),
              ),
            )
          : null,
      body: _getSelectedContent(),
      bottomNavigationBar: BottomNavigationBar(
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.dashboard_outlined),
            activeIcon: Icon(Icons.dashboard),
            label: 'Dashboard',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.inventory_outlined),
            activeIcon: Icon(Icons.inventory),
            label: 'Kelola Alat',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.assignment_outlined),
            activeIcon: Icon(Icons.assignment),
            label: 'Peminjaman',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_outline),
            activeIcon: Icon(Icons.person),
            label: 'Profil',
          ),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: colorMaroon,
        unselectedItemColor: Colors.grey,
        onTap: _onItemTapped,
        type: BottomNavigationBarType.fixed,
        backgroundColor: Colors.white,
        elevation: 8,
        selectedLabelStyle: const TextStyle(
          fontWeight: FontWeight.w600,
          fontSize: 11,
        ),
        unselectedLabelStyle: const TextStyle(fontSize: 11),
        selectedFontSize: 11,
        unselectedFontSize: 11,
      ),
    );
  }

  String _getAppBarTitle() {
    switch (_selectedIndex) {
      case 0:
        return 'Dashboard Admin';
      case 1:
        return 'Kelola Alat';
      case 2:
        return 'Peminjaman';
      case 3:
        return 'Profil';
      default:
        return 'SIMPEL Admin';
    }
  }

  Widget _getSelectedContent() {
    switch (_selectedIndex) {
      case 0:
        return _buildDashboardContent();
      case 1:
        return _buildKelolaAlatContent();
      case 2:
        return _buildPeminjamanContent();
      case 3:
        return _buildProfileContent();
      default:
        return _buildDashboardContent();
    }
  }

  void _showLogoutDialog(BuildContext context) {
    final authProvider = context.read<AuthProvider>();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
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
              if (!context.mounted) return;

              Navigator.of(context).pop();
              Navigator.of(context).pushReplacement(
                MaterialPageRoute(builder: (_) => const LoginScreen()),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: colorMaroon,
              foregroundColor: Colors.white,
            ),
            child: const Text('Keluar'),
          ),
        ],
      ),
    );
  }

  // ----------------------------
  // TAB 1: DASHBOARD
  // ----------------------------
  Widget _buildDashboardContent() {
    return Consumer2<AuthProvider, AlatProvider>(
      builder: (context, authProvider, alatProvider, child) {
        final adminLab = authProvider.userLab ?? 'BA';
        final labName = LabConstants.getLabName(adminLab);
        final adminName = authProvider.currentUser?.name ?? 'Admin';

        // Filter alat by admin's lab
        final labAlat =
            alatProvider.alatList.where((alat) => alat.ruang == adminLab).toList();

        final totalAlat = labAlat.length;
        final totalStok = labAlat.fold<int>(0, (sum, alat) => sum + alat.jumlah);

        // Fix: tersedia hanya jika stok > 0
        final alatTersedia = labAlat
            .where((a) => a.status.toLowerCase() == 'tersedia' && a.jumlah > 0)
            .length;

        final alatDipinjam =
            labAlat.where((a) => a.status.toLowerCase() == 'dipinjam').length;

        return SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Welcome Card
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [colorMaroon, colorMaroonDark],
                  ),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Selamat datang, $adminName!',
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      labName,
                      style: const TextStyle(
                        fontSize: 16,
                        color: Colors.white70,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              const Text(
                'Statistik Lab',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),

              Row(
                children: [
                  Expanded(
                    child: _buildStatCard(
                      title: 'Total Alat',
                      value: '$totalAlat',
                      icon: Icons.inventory,
                      color: Colors.blue,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildStatCard(
                      title: 'Total Stok',
                      value: '$totalStok',
                      icon: Icons.format_list_numbered,
                      color: Colors.purple,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              Row(
                children: [
                  Expanded(
                    child: _buildStatCard(
                      title: 'Tersedia',
                      value: '$alatTersedia',
                      icon: Icons.check_circle,
                      color: Colors.green,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildStatCard(
                      title: 'Dipinjam',
                      value: '$alatDipinjam',
                      icon: Icons.pending_actions,
                      color: Colors.orange,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              const Text(
                'Quick Actions',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),

              Row(
                children: [
                  Expanded(
                    child: _buildQuickAction(
                      title: 'Tambah Alat',
                      icon: Icons.add_box,
                      color: colorMaroon,
                      onTap: () async {
                        final result = await Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) => const AddEditAlatScreen(),
                          ),
                        );

                        if (!mounted) return;

                        if (result == true) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('✅ Alat berhasil ditambahkan'),
                              backgroundColor: Colors.green,
                            ),
                          );
                        }
                      },
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildQuickAction(
                      title: 'Validasi',
                      icon: Icons.approval,
                      color: Colors.blue,
                      onTap: () => setState(() => _selectedIndex = 2),
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

  Widget _buildStatCard({
    required String title,
    required String value,
    required IconData icon,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: color, size: 24),
          ),
          const SizedBox(height: 12),
          Text(
            value,
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          const SizedBox(height: 4),
          Text(title, style: TextStyle(fontSize: 13, color: Colors.grey[600])),
        ],
      ),
    );
  }

  Widget _buildQuickAction({
    required String title,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        height: 56,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withOpacity(0.3)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: color, size: 22),
            const SizedBox(width: 8),
            Flexible(
              child: Text(
                title,
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: color,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ----------------------------
  // TAB 2: KELOLA ALAT
  // ----------------------------
  Widget _buildKelolaAlatContent() {
    return Consumer2<AuthProvider, AlatProvider>(
      builder: (context, authProvider, alatProvider, child) {
        final adminLab = authProvider.userLab ?? 'BA';
        final labAlat =
            alatProvider.alatList.where((alat) => alat.ruang == adminLab).toList();

        if (labAlat.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.inventory_2_outlined, size: 80, color: Colors.grey[400]),
                const SizedBox(height: 16),
                const Text(
                  'Belum ada alat',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Text(
                  'Tambahkan alat dengan tombol + di bawah',
                  style: TextStyle(color: Colors.grey[600]),
                ),
              ],
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: labAlat.length,
          itemBuilder: (context, index) {
            final alat = labAlat[index];
            final isTersedia =
                alat.status.toLowerCase() == 'tersedia' && alat.jumlah > 0;

            return Container(
              margin: const EdgeInsets.only(bottom: 12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey[200]!),
              ),
              child: ListTile(
                contentPadding: const EdgeInsets.all(16),
                leading: alat.gambar != null
                    ? ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                        child: Image.network(
                          alat.gambar!,
                          width: 60,
                          height: 60,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return Container(
                              width: 60,
                              height: 60,
                              decoration: BoxDecoration(
                                color: isTersedia
                                    ? colorMaroonLight.withOpacity(0.1)
                                    : Colors.grey[100],
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Icon(
                                Icons.inventory,
                                color: isTersedia ? colorMaroon : Colors.grey,
                                size: 30,
                              ),
                            );
                          },
                        ),
                      )
                    : Container(
                        width: 60,
                        height: 60,
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: isTersedia
                              ? colorMaroonLight.withOpacity(0.1)
                              : Colors.grey[100],
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Icon(
                          Icons.inventory,
                          color: isTersedia ? colorMaroon : Colors.grey,
                          size: 30,
                        ),
                      ),
                title: Text(
                  alat.nama,
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 4),
                    Text('Stok: ${alat.jumlah} | Kategori: ${alat.kategori}'),
                    const SizedBox(height: 4),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: isTersedia ? Colors.green.shade50 : Colors.red.shade50,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        isTersedia ? 'Tersedia' : 'Tidak Tersedia',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: isTersedia ? Colors.green : Colors.red,
                        ),
                      ),
                    ),
                  ],
                ),
                trailing: PopupMenuButton(
                  icon: Icon(Icons.more_vert, color: Colors.grey[600]),
                  itemBuilder: (context) => const [
                    PopupMenuItem(
                      value: 'edit',
                      child: Row(
                        children: [
                          Icon(Icons.edit, size: 20, color: colorMaroon),
                          SizedBox(width: 8),
                          Text('Edit'),
                        ],
                      ),
                    ),
                    PopupMenuItem(
                      value: 'delete',
                      child: Row(
                        children: [
                          Icon(Icons.delete, size: 20, color: Colors.red),
                          SizedBox(width: 8),
                          Text('Hapus'),
                        ],
                      ),
                    ),
                  ],
                  onSelected: (value) {
                    if (value == 'edit') {
                      _handleEdit(alat);
                    } else if (value == 'delete') {
                      _handleDelete(alat);
                    }
                  },
                ),
              ),
            );
          },
        );
      },
    );
  }

  Future<void> _handleEdit(dynamic alat) async {
    final result = await Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => AddEditAlatScreen(alat: alat)),
    );

    if (!mounted) return;

    if (result == true) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Alat berhasil diupdate'),
          backgroundColor: Colors.green,
        ),
      );
    }
  }

  Future<void> _handleDelete(dynamic alat) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Konfirmasi Hapus'),
        content: Text('Apakah Anda yakin ingin menghapus "${alat.nama}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text('Hapus'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        await FirebaseFirestore.instance.collection('alat').doc(alat.id).delete();

        if (!mounted) return;

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('✅ Alat berhasil dihapus'),
            backgroundColor: Colors.green,
          ),
        );
      } catch (e) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }

  // ----------------------------
  // TAB 3: PEMINJAMAN
  // ----------------------------
  Widget _buildPeminjamanContent() {
    return DefaultTabController(
      length: 4,
      child: Column(
        children: [
          Container(
            color: Colors.white,
            child: const TabBar(
              labelColor: colorMaroon,
              unselectedLabelColor: Colors.grey,
              indicatorColor: colorMaroon,
              isScrollable: true,
              tabs: [
                Tab(text: 'Menunggu Konfirmasi'),
                Tab(text: 'Sedang Dipinjam'),
                Tab(text: 'Validasi Pengembalian'),
                Tab(text: 'Riwayat Lengkap'),
              ],
            ),
          ),
          Expanded(
            child: TabBarView(
              children: [
                _buildPeminjamanMenunggu(),
                _buildPeminjamanSedangDipinjam(),
                _buildValidasiPengembalian(),
                _buildRiwayatLengkapAdmin(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPeminjamanMenunggu() {
    final historyProvider = Provider.of<HistoryProvider>(context);
    final authProvider = Provider.of<AuthProvider>(context);
    final adminLab = authProvider.userLab ?? 'BA';

    final historyKonfirmasiList = historyProvider.historyKonfirmasi
        .where((h) => h.lab == adminLab)
        .toList();

    if (historyKonfirmasiList.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(32),
              decoration: BoxDecoration(
                color: colorMaroonLight.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.assignment_outlined,
                size: 80,
                color: colorMaroon.withOpacity(0.5),
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'Tidak Ada Peminjaman',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: colorMaroonDark,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Belum ada peminjaman yang menunggu konfirmasi',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 14, color: Colors.grey[600]),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: historyKonfirmasiList.length,
      itemBuilder: (context, index) {
        final history = historyKonfirmasiList[index];

        return FutureBuilder<DocumentSnapshot>(
          future: FirebaseFirestore.instance.collection('users').doc(history.userId).get(),
          builder: (context, userSnapshot) {
            String userName = 'Loading...';
            String userEmail = '';

            if (userSnapshot.hasData && userSnapshot.data!.exists) {
              final userData = userSnapshot.data!.data() as Map<String, dynamic>;
              userName = userData['name'] ?? 'Unknown User';
              userEmail = userData['email'] ?? '';
            }

            return _buildPeminjamanCard(
              history,
              userName: userName,
              userEmail: userEmail,
              isKonfirmasi: true,
            );
          },
        );
      },
    );
  }

  Widget _buildPeminjamanSedangDipinjam() {
    final authProvider = Provider.of<AuthProvider>(context);
    final adminLab = authProvider.userLab ?? 'BA';

    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('peminjaman')
          .where('lab', isEqualTo: adminLab)
          .where('status', isEqualTo: 'disetujui')
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator(color: colorMaroon));
        }

        if (snapshot.hasError) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.error_outline, size: 64, color: Colors.red),
                const SizedBox(height: 16),
                Text(
                  'Error: ${snapshot.error}',
                  style: const TextStyle(color: Colors.red),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          );
        }

        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.all(32),
                  decoration: BoxDecoration(
                    color: colorMaroonLight.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.check_circle_outline,
                    size: 80,
                    color: Colors.green.withOpacity(0.5),
                  ),
                ),
                const SizedBox(height: 24),
                const Text(
                  'Tidak Ada Peminjaman Aktif',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: colorMaroonDark,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Belum ada alat yang sedang dipinjam',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                ),
              ],
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: snapshot.data!.docs.length,
          itemBuilder: (context, index) {
            final doc = snapshot.data!.docs[index];
            final data = (doc.data() as Map<String, dynamic>?) ?? {};

            final userId = (data['userId'] ?? '').toString();

            return FutureBuilder<DocumentSnapshot>(
              future: FirebaseFirestore.instance.collection('users').doc(userId).get(),
              builder: (context, userSnapshot) {
                String userName = 'Loading...';
                String userEmail = '';

                if (userSnapshot.connectionState == ConnectionState.waiting) {
                  return Card(
                    margin: const EdgeInsets.symmetric(vertical: 8),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Center(child: CircularProgressIndicator(color: colorMaroon)),
                    ),
                  );
                }

                if (userSnapshot.hasData && userSnapshot.data!.exists) {
                  final userData = userSnapshot.data!.data() as Map<String, dynamic>;
                  userName = userData['name'] ?? 'Unknown User';
                  userEmail = userData['email'] ?? '';
                }

                return _buildPeminjamanCardDipinjam(doc.id, data, userName, userEmail);
              },
            );
          },
        );
      },
    );
  }

  // ----------------------------
  // TAB 3: VALIDASI PENGEMBALIAN (FIX: METHOD MISSING)
  // ----------------------------
  Widget _buildValidasiPengembalian() {
    final authProvider = Provider.of<AuthProvider>(context);
    final adminLab = authProvider.userLab ?? 'BA';

    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('peminjaman')
          .where('lab', isEqualTo: adminLab)
          .where('status', isEqualTo: 'menunggu validasi pengembalian')
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator(color: colorMaroon));
        }

        if (snapshot.hasError) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.error_outline, size: 64, color: Colors.red),
                const SizedBox(height: 16),
                Text(
                  'Error: ${snapshot.error}',
                  style: const TextStyle(color: Colors.red),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          );
        }

        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.all(32),
                  decoration: BoxDecoration(
                    color: Colors.orange.withOpacity(0.08),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.assignment_return_outlined,
                    size: 80,
                    color: Colors.orange.withOpacity(0.6),
                  ),
                ),
                const SizedBox(height: 24),
                const Text(
                  'Tidak Ada Pengembalian',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: colorMaroonDark,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Belum ada pengajuan pengembalian yang perlu divalidasi',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                ),
              ],
            ),
          );
        }

        final docs = snapshot.data!.docs;

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: docs.length,
          itemBuilder: (context, index) {
            final doc = docs[index];
            final data = (doc.data() as Map<String, dynamic>?) ?? {};
            final userId = (data['userId'] ?? '').toString();

            return FutureBuilder<DocumentSnapshot>(
              future: FirebaseFirestore.instance.collection('users').doc(userId).get(),
              builder: (context, userSnapshot) {
                String userName = 'Loading...';
                String userEmail = '';

                if (userSnapshot.hasData && userSnapshot.data!.exists) {
                  final userData = userSnapshot.data!.data() as Map<String, dynamic>;
                  userName = userData['name'] ?? 'Unknown User';
                  userEmail = userData['email'] ?? '';
                }

                return _buildValidasiPengembalianCard(
                  peminjamanId: doc.id,
                  data: data,
                  userName: userName,
                  userEmail: userEmail,
                );
              },
            );
          },
        );
      },
    );
  }

  Widget _buildValidasiPengembalianCard({
    required String peminjamanId,
    required Map<String, dynamic> data,
    required String userName,
    required String userEmail,
  }) {
    final lab = (data['lab'] ?? '').toString();
    final labStyle = ruangStyle[lab] ??
        {
          "color": Colors.grey[300],
          "text": Colors.black,
          "icon": Icons.location_on,
        };

    final tanggalPinjam = _parseFlexibleDate(data['tanggalPinjam']);
    final tanggalKembali = _parseFlexibleDate(data['tanggalKembali']);

    final alatItems = (data['alat'] as List?) ?? const [];

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8),
      color: Colors.orange.shade50,
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header + chat
            Row(
              children: [
                Icon(labStyle["icon"], color: labStyle["text"], size: 24),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    "Lab: $lab",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: labStyle["text"],
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.chat_bubble_outline),
                  color: colorMaroon,
                  tooltip: 'Chat dengan peminjam',
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ChatScreen(
                          peminjamanId: peminjamanId,
                          otherUserName: userName,
                          otherUserRole: 'user',
                        ),
                      ),
                    );
                  },
                ),
              ],
            ),
            const SizedBox(height: 12),

            // User info
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey.shade300),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: colorMaroon.withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.person, color: colorMaroon, size: 22),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Peminjam:',
                          style: TextStyle(
                            fontSize: 11,
                            color: Colors.grey,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          userName,
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          userEmail,
                          style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),

            // Dates
            SizedBox(
              width: double.infinity,
              child: Card(
                color: Colors.white,
                child: Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text("Tanggal Pinjam: ${DateFormat('dd-MM-yyyy').format(tanggalPinjam)}"),
                      Text("Tanggal Kembali: ${DateFormat('dd-MM-yyyy').format(tanggalKembali)}"),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 8),

            // Badge
            Row(
              children: [
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                  decoration: BoxDecoration(
                    color: Colors.orange.shade700,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Text(
                    'Menunggu Validasi',
                    style: TextStyle(
                      fontSize: 13,
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 12),
            const Text(
              "Alat:",
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),

            ...alatItems.map((item) {
              final itemMap = (item as Map?)?.cast<String, dynamic>() ?? <String, dynamic>{};
              final alatId = (itemMap['id'] ?? '').toString();
              final qty = itemMap['jumlah'] ?? 0;

              return FutureBuilder<DocumentSnapshot>(
                future: FirebaseFirestore.instance.collection('alat').doc(alatId).get(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Card(
                      margin: EdgeInsets.only(bottom: 8),
                      child: ListTile(
                        leading: SizedBox(
                          width: 50,
                          height: 50,
                          child: Center(child: CircularProgressIndicator(strokeWidth: 2)),
                        ),
                        title: Text('Loading...'),
                      ),
                    );
                  }

                  if (!snapshot.hasData || !snapshot.data!.exists) {
                    return const Card(
                      margin: EdgeInsets.only(bottom: 8),
                      child: ListTile(
                        leading: Icon(Icons.error_outline, size: 50),
                        title: Text('Data tidak ditemukan'),
                      ),
                    );
                  }

                  final alatData = (snapshot.data!.data() as Map<String, dynamic>?) ?? {};

                  return Card(
                    margin: const EdgeInsets.only(bottom: 8),
                    child: ListTile(
                      leading: alatData['gambar'] != null
                          ? ClipRRect(
                              borderRadius: BorderRadius.circular(8),
                              child: Image.network(
                                alatData['gambar'],
                                width: 50,
                                height: 50,
                                fit: BoxFit.cover,
                                errorBuilder: (_, __, ___) =>
                                    const Icon(Icons.inventory, size: 50),
                              ),
                            )
                          : const Icon(Icons.inventory, size: 50),
                      title: Text(alatData['nama'] ?? 'Tanpa Nama'),
                      subtitle: Text('Jumlah: $qty'),
                    ),
                  );
                },
              );
            }).toList(),

            const SizedBox(height: 12),

            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () => _showTolakPengembalianDialog(peminjamanId),
                    icon: const Icon(Icons.cancel),
                    label: const Text('Tolak'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () => _showTerimaPengembalianDialog(peminjamanId),
                    icon: const Icon(Icons.check_circle),
                    label: const Text('Terima'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // ----------------------------
  // CARD: SEDANG DIPINJAM
  // ----------------------------
  Widget _buildPeminjamanCardDipinjam(
    String docId,
    Map<String, dynamic> data,
    String userName,
    String userEmail,
  ) {
    final lab = (data['lab'] ?? '').toString();
    final labStyle = ruangStyle[lab] ??
        {
          "color": Colors.grey[300],
          "text": Colors.black,
          "icon": Icons.location_on,
        };

    final tanggalPinjam = _parseFlexibleDate(data['tanggalPinjam']);
    final tanggalKembali = _parseFlexibleDate(data['tanggalKembali']);
    final alatItems = (data['alat'] as List?) ?? const [];

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8),
      color: Colors.green.shade50,
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header Lab
            Row(
              children: [
                Icon(labStyle["icon"], color: labStyle["text"], size: 24),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    "Lab: $lab",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: labStyle["text"],
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.chat_bubble_outline),
                  color: colorMaroon,
                  tooltip: 'Chat dengan peminjam',
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ChatScreen(
                          peminjamanId: docId,
                          otherUserName: userName,
                          otherUserRole: 'user',
                        ),
                      ),
                    );
                  },
                ),
              ],
            ),
            const SizedBox(height: 12),

            // Info Peminjam
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey.shade300),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: colorMaroon.withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.person, color: colorMaroon, size: 24),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Peminjam:',
                          style: TextStyle(
                            fontSize: 11,
                            color: Colors.grey,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          userName,
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          userEmail,
                          style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),

            // Tanggal
            SizedBox(
              width: double.infinity,
              child: Card(
                color: Colors.white,
                child: Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text("Tanggal Pinjam: ${DateFormat('dd-MM-yyyy').format(tanggalPinjam)}"),
                      Text("Tanggal Kembali: ${DateFormat('dd-MM-yyyy').format(tanggalKembali)}"),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 8),

            Row(
              children: [
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: Colors.green,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Text(
                    'Sedang Dipinjam',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            const Text(
              "Alat:",
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black87),
            ),
            const SizedBox(height: 8),

            ...alatItems.map((item) {
              final itemMap = (item as Map?)?.cast<String, dynamic>() ?? <String, dynamic>{};
              final alatId = (itemMap['id'] ?? '').toString();
              final qty = itemMap['jumlah'] ?? 0;

              return FutureBuilder<DocumentSnapshot>(
                future: FirebaseFirestore.instance.collection('alat').doc(alatId).get(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Card(
                      margin: EdgeInsets.only(bottom: 8),
                      child: ListTile(
                        leading: SizedBox(
                          width: 50,
                          height: 50,
                          child: Center(child: CircularProgressIndicator(strokeWidth: 2)),
                        ),
                        title: Text('Loading...'),
                      ),
                    );
                  }

                  if (!snapshot.hasData || !snapshot.data!.exists) {
                    return const Card(
                      margin: EdgeInsets.only(bottom: 8),
                      child: ListTile(
                        leading: Icon(Icons.error_outline, size: 50),
                        title: Text('Data tidak ditemukan'),
                      ),
                    );
                  }

                  final alatData = (snapshot.data!.data() as Map<String, dynamic>?) ?? {};

                  return Card(
                    margin: const EdgeInsets.only(bottom: 8),
                    child: ListTile(
                      leading: alatData['gambar'] != null
                          ? ClipRRect(
                              borderRadius: BorderRadius.circular(8),
                              child: Image.network(
                                alatData['gambar'],
                                width: 50,
                                height: 50,
                                fit: BoxFit.cover,
                                errorBuilder: (_, __, ___) =>
                                    const Icon(Icons.inventory, size: 50),
                              ),
                            )
                          : const Icon(Icons.inventory, size: 50),
                      title: Text(alatData['nama'] ?? 'Tanpa Nama'),
                      subtitle: Text('Jumlah: $qty'),
                    ),
                  );
                },
              );
            }).toList(),
          ],
        ),
      ),
    );
  }

  // ----------------------------
  // CARD: MENUNGGU KONFIRMASI (Provider Entity)
  // ----------------------------
  Widget _buildPeminjamanCard(
    dynamic history, {
    required String userName,
    required String userEmail,
    required bool isKonfirmasi,
  }) {
    final labStyle = ruangStyle[history.lab] ??
        {
          "color": Colors.grey[300],
          "text": Colors.black,
          "icon": Icons.location_on,
        };

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8),
      color: colorMaroonLight,
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(labStyle["icon"], color: labStyle["text"], size: 24),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    "Lab: ${history.lab}",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: labStyle["text"],
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.chat_bubble_outline),
                  color: colorMaroon,
                  tooltip: 'Chat dengan peminjam',
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ChatScreen(
                          peminjamanId: history.id,
                          otherUserName: userName,
                          otherUserRole: 'user',
                        ),
                      ),
                    );
                  },
                ),
              ],
            ),
            const SizedBox(height: 12),

            // Info peminjam
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey.shade300),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: colorMaroon.withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.person, color: colorMaroon, size: 24),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Peminjam:',
                          style: TextStyle(
                            fontSize: 11,
                            color: Colors.grey,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          userName,
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          userEmail,
                          style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),

            // Tanggal
            SizedBox(
              width: double.infinity,
              child: Card(
                color: Colors.white,
                child: Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Tanggal Pinjam: ${DateFormat('dd-MM-yyyy').format(history.tanggalPinjam)}",
                      ),
                      Text(
                        "Tanggal Kembali: ${DateFormat('dd-MM-yyyy').format(history.tanggalKembali)}",
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 8),

            // Alasan
            SizedBox(
              width: double.infinity,
              child: Card(
                color: Colors.white,
                child: Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Text("Alasan: ${history.alasan}"),
                ),
              ),
            ),
            const SizedBox(height: 12),

            const Text(
              "Alat:",
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),

            ...history.alat.map((item) {
              final itemMap = (item as Map?)?.cast<String, dynamic>() ?? <String, dynamic>{};
              final alatId = (itemMap['id'] ?? '').toString();
              final qty = itemMap['jumlah'] ?? 0;

              return FutureBuilder<DocumentSnapshot>(
                future: FirebaseFirestore.instance.collection('alat').doc(alatId).get(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Card(
                      margin: EdgeInsets.only(bottom: 8),
                      child: ListTile(
                        leading: SizedBox(
                          width: 50,
                          height: 50,
                          child: Center(child: CircularProgressIndicator(strokeWidth: 2)),
                        ),
                        title: Text('Loading...'),
                      ),
                    );
                  }

                  if (!snapshot.hasData || !snapshot.data!.exists) {
                    return const Card(
                      margin: EdgeInsets.only(bottom: 8),
                      child: ListTile(
                        leading: Icon(Icons.error_outline, size: 50),
                        title: Text('Data tidak ditemukan'),
                      ),
                    );
                  }

                  final alatData = (snapshot.data!.data() as Map<String, dynamic>?) ?? {};

                  return Card(
                    margin: const EdgeInsets.only(bottom: 8),
                    child: ListTile(
                      leading: alatData['gambar'] != null
                          ? ClipRRect(
                              borderRadius: BorderRadius.circular(8),
                              child: Image.network(
                                alatData['gambar'],
                                width: 50,
                                height: 50,
                                fit: BoxFit.cover,
                                errorBuilder: (_, __, ___) =>
                                    const Icon(Icons.inventory, size: 50),
                              ),
                            )
                          : const Icon(Icons.inventory, size: 50),
                      title: Text(alatData['nama'] ?? 'Tanpa Nama'),
                      subtitle: Text('Jumlah: $qty'),
                    ),
                  );
                },
              );
            }).toList(),
            const SizedBox(height: 16),

            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () => _showTolakDialog(history.id),
                    icon: const Icon(Icons.cancel),
                    label: const Text('Tolak'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () => _showSetujuDialogWithEdit(history),
                    icon: const Icon(Icons.check_circle),
                    label: const Text('Setujui'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // ----------------------------
  // SETUJU + EDIT (DIALOG)
  // ----------------------------
  void _showSetujuDialogWithEdit(dynamic history) async {
    final editedAlat = await showDialog<List<Map<String, dynamic>>>(
      context: context,
      builder: (context) => EditPeminjamanDialog(
        peminjamanId: history.id,
        alatList: history.alat,
      ),
    );

    if (editedAlat == null || !mounted) return;

    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Konfirmasi Peminjaman'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Setujui peminjaman dengan item berikut?'),
            const SizedBox(height: 12),
            ...editedAlat.map((item) {
              final alatId = (item['id'] ?? '').toString();
              final qty = item['jumlah'] ?? 0;

              return FutureBuilder<DocumentSnapshot>(
                future: FirebaseFirestore.instance.collection('alat').doc(alatId).get(),
                builder: (context, snapshot) {
                  if (!snapshot.hasData || !snapshot.data!.exists) {
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 4),
                      child: Text('• (alat tidak ditemukan) : $qty unit',
                          style: const TextStyle(fontSize: 13)),
                    );
                  }
                  final data = (snapshot.data!.data() as Map<String, dynamic>?) ?? {};
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 4),
                    child: Text(
                      '• ${data['nama'] ?? 'Tanpa Nama'}: $qty unit',
                      style: const TextStyle(fontSize: 13),
                    ),
                  );
                },
              );
            }).toList(),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.blue.shade50,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.blue.shade200),
              ),
              child: Row(
                children: [
                  Icon(Icons.info_outline, size: 16, color: Colors.blue.shade700),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Syarat & ketentuan akan dikirim otomatis ke peminjam via chat',
                      style: TextStyle(fontSize: 11, color: Colors.blue.shade900),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green,
              foregroundColor: Colors.white,
            ),
            child: const Text('Setujui'),
          ),
        ],
      ),
    );

    if (confirm != true || !mounted) return;

    try {
      // Loading
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CircularProgressIndicator(color: colorMaroon),
              const SizedBox(height: 16),
              const Text('Memproses persetujuan...'),
            ],
          ),
        ),
      );

      // Update alat list
      await FirebaseFirestore.instance.collection('peminjaman').doc(history.id).update({
        'alat': editedAlat,
        'updatedAt': FieldValue.serverTimestamp(),
      });

      // Approve
      final historyProvider = context.read<HistoryProvider>();
      await historyProvider.konfirmasiPeminjaman(history.id);

      // Auto send chat
      final chatProvider = context.read<ChatProvider>();
      final authProvider = context.read<AuthProvider>();
      final adminId =
          authProvider.currentUser?.id ?? authProvider.firebaseUser?.uid ?? '';
      final adminName = authProvider.currentUser?.name ?? 'Admin Lab';

      final message = ChatTemplates.getApprovalMessage(history.lab);

      await chatProvider.sendMessage(
        peminjamanId: history.id,
        senderId: adminId,
        senderName: adminName,
        senderRole: 'admin',
        message: message,
      );

      // Refresh provider list (menunggu konfirmasi)
      await historyProvider.fetchHistoryKonfirmasiPeminjaman();

      if (!mounted) return;

      Navigator.of(context).pop(); // close loading

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Row(
            children: [
              Icon(Icons.check_circle, color: Colors.white),
              SizedBox(width: 8),
              Expanded(
                child: Text('✅ Peminjaman disetujui & syarat dikirim ke peminjam'),
              ),
            ],
          ),
          backgroundColor: Colors.green,
          duration: Duration(seconds: 4),
        ),
      );
    } catch (e) {
      if (!mounted) return;

      Navigator.of(context).pop(); // close loading (if open)

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('❌ Gagal: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  // ----------------------------
  // TOLAK PEMINJAMAN (DIALOG)
  // ----------------------------
  void _showTolakDialog(String peminjamanId) {
    final alasanController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Row(
          children: [
            Icon(Icons.cancel, color: Colors.red),
            SizedBox(width: 8),
            Text('Tolak Peminjaman'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Masukkan alasan penolakan:'),
            const SizedBox(height: 16),
            TextField(
              controller: alasanController,
              maxLines: 3,
              decoration: InputDecoration(
                hintText: 'Contoh: Alat sedang dalam perbaikan',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.orange.shade50,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.orange.shade200),
              ),
              child: Row(
                children: [
                  Icon(Icons.info_outline, size: 16, color: Colors.orange.shade700),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Pesan penolakan akan dikirim ke peminjam via chat',
                      style: TextStyle(fontSize: 11, color: Colors.orange.shade900),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            onPressed: () async {
              if (alasanController.text.trim().isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Alasan tidak boleh kosong'),
                    backgroundColor: Colors.red,
                  ),
                );
                return;
              }

              Navigator.pop(context);

              // Loading
              showDialog(
                context: context,
                barrierDismissible: false,
                builder: (context) => AlertDialog(
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  content: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      CircularProgressIndicator(color: colorMaroon),
                      const SizedBox(height: 16),
                      const Text('Memproses penolakan...'),
                    ],
                  ),
                ),
              );

              try {
                final reason = alasanController.text.trim();

                await FirebaseFirestore.instance.collection('peminjaman').doc(peminjamanId).update({
                  'status': 'ditolak',
                  'alasanPenolakan': reason,
                  'updatedAt': FieldValue.serverTimestamp(),
                });

                // Auto send rejection chat
                final chatProvider = context.read<ChatProvider>();
                final authProvider = context.read<AuthProvider>();
                final historyProvider = context.read<HistoryProvider>();

                final adminId =
                    authProvider.currentUser?.id ?? authProvider.firebaseUser?.uid ?? '';
                final adminName = authProvider.currentUser?.name ?? 'Admin Lab';

                final message = ChatTemplates.getRejectionMessage(reason);

                await chatProvider.sendMessage(
                  peminjamanId: peminjamanId,
                  senderId: adminId,
                  senderName: adminName,
                  senderRole: 'admin',
                  message: message,
                );

                // Refresh provider list
                await historyProvider.fetchHistoryKonfirmasiPeminjaman();

                if (!context.mounted) return;

                Navigator.pop(context); // close loading

                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('✅ Peminjaman ditolak & alasan dikirim ke peminjam'),
                    backgroundColor: Colors.green,
                  ),
                );
              } catch (e) {
                if (!context.mounted) return;

                Navigator.pop(context); // close loading

                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('❌ Error: $e'),
                    backgroundColor: Colors.red,
                  ),
                );
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text('Tolak'),
          ),
        ],
      ),
    );
  }

  // ----------------------------
  // TERIMA PENGEMBALIAN (DIALOG)
  // ----------------------------
  void _showTerimaPengembalianDialog(String peminjamanId) {
    final notesController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Row(
          children: [
            Icon(Icons.check_circle, color: Colors.green),
            SizedBox(width: 8),
            Text('Terima Pengembalian'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Apakah semua alat sudah dikembalikan dengan lengkap?'),
            const SizedBox(height: 16),
            TextField(
              controller: notesController,
              maxLines: 3,
              decoration: InputDecoration(
                hintText: 'Catatan (opsional)',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);

              try {
                final historyProvider = context.read<HistoryProvider>();
                final notes = notesController.text.trim().isEmpty ? null : notesController.text.trim();

                await historyProvider.confirmReturn(peminjamanId, notes: notes);

                // Auto send validation chat
                final chatProvider = context.read<ChatProvider>();
                final authProvider = context.read<AuthProvider>();

                final adminId =
                    authProvider.currentUser?.id ?? authProvider.firebaseUser?.uid ?? '';
                final adminName = authProvider.currentUser?.name ?? 'Admin Lab';

                final message = ChatTemplates.getReturnValidationMessage(true, notes);

                await chatProvider.sendMessage(
                  peminjamanId: peminjamanId,
                  senderId: adminId,
                  senderName: adminName,
                  senderRole: 'admin',
                  message: message,
                );

                if (!mounted) return;

                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('✅ Pengembalian diterima & konfirmasi dikirim'),
                    backgroundColor: Colors.green,
                  ),
                );
              } catch (e) {
                if (!mounted) return;
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('❌ Error: $e'),
                    backgroundColor: Colors.red,
                  ),
                );
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green,
              foregroundColor: Colors.white,
            ),
            child: const Text('Terima'),
          ),
        ],
      ),
    );
  }

  // ----------------------------
  // TOLAK PENGEMBALIAN (DIALOG)
  // ----------------------------
  void _showTolakPengembalianDialog(String peminjamanId) {
    final reasonController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Row(
          children: [
            Icon(Icons.cancel, color: Colors.red),
            SizedBox(width: 8),
            Text('Tolak Pengembalian'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Masukkan alasan penolakan:'),
            const SizedBox(height: 16),
            TextField(
              controller: reasonController,
              maxLines: 3,
              decoration: InputDecoration(
                hintText: 'Contoh: Alat tidak lengkap / rusak',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            onPressed: () async {
              if (reasonController.text.trim().isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Alasan tidak boleh kosong'),
                    backgroundColor: Colors.red,
                  ),
                );
                return;
              }

              Navigator.pop(context);

              try {
                final reason = reasonController.text.trim();
                final historyProvider = context.read<HistoryProvider>();

                await historyProvider.rejectReturn(peminjamanId, reason);

                // Auto send chat
                final chatProvider = context.read<ChatProvider>();
                final authProvider = context.read<AuthProvider>();

                final adminId =
                    authProvider.currentUser?.id ?? authProvider.firebaseUser?.uid ?? '';
                final adminName = authProvider.currentUser?.name ?? 'Admin Lab';

                final message = ChatTemplates.getReturnValidationMessage(false, reason);

                await chatProvider.sendMessage(
                  peminjamanId: peminjamanId,
                  senderId: adminId,
                  senderName: adminName,
                  senderRole: 'admin',
                  message: message,
                );

                if (!mounted) return;

                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('✅ Pengembalian ditolak & alasan dikirim'),
                    backgroundColor: Colors.orange,
                  ),
                );
              } catch (e) {
                if (!mounted) return;
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('❌ Error: $e'),
                    backgroundColor: Colors.red,
                  ),
                );
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text('Tolak'),
          ),
        ],
      ),
    );
  }

  // ----------------------------
  // TAB 4: RIWAYAT LENGKAP ADMIN
  // ----------------------------
  Widget _buildRiwayatLengkapAdmin() {
    final authProvider = Provider.of<AuthProvider>(context);
    final adminLab = authProvider.userLab ?? 'BA';

    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('peminjaman')
          .where('lab', isEqualTo: adminLab)
          .where('status', whereIn: ['dikembalikan', 'ditolak'])
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator(color: colorMaroon));
        }

        if (snapshot.hasError) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.error_outline, size: 64, color: Colors.red),
                const SizedBox(height: 16),
                Text(
                  'Error: ${snapshot.error}',
                  style: const TextStyle(color: Colors.red),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          );
        }

        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.all(32),
                  decoration: BoxDecoration(
                    color: colorMaroonLight.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.history,
                    size: 80,
                    color: colorMaroon.withOpacity(0.5),
                  ),
                ),
                const SizedBox(height: 24),
                const Text(
                  'Belum Ada Riwayat',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: colorMaroonDark,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Riwayat peminjaman yang selesai akan muncul di sini',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                ),
              ],
            ),
          );
        }

        // Fix: copy list before sorting
        final docs = List<QueryDocumentSnapshot>.from(snapshot.data!.docs);

        docs.sort((a, b) {
          final aData = (a.data() as Map<String, dynamic>?) ?? {};
          final bData = (b.data() as Map<String, dynamic>?) ?? {};

          final aTime = aData['updatedAt'] as Timestamp?;
          final bTime = bData['updatedAt'] as Timestamp?;

          if (aTime == null && bTime == null) return 0;
          if (aTime == null) return 1;
          if (bTime == null) return -1;
          return bTime.compareTo(aTime);
        });

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: docs.length,
          itemBuilder: (context, index) {
            final doc = docs[index];
            final data = (doc.data() as Map<String, dynamic>?) ?? {};
            final userId = (data['userId'] ?? '').toString();

            return FutureBuilder<DocumentSnapshot>(
              future: FirebaseFirestore.instance.collection('users').doc(userId).get(),
              builder: (context, userSnapshot) {
                String userName = 'Loading...';
                String userEmail = '';

                if (userSnapshot.hasData && userSnapshot.data!.exists) {
                  final userData = userSnapshot.data!.data() as Map<String, dynamic>;
                  userName = userData['name'] ?? 'Unknown User';
                  userEmail = userData['email'] ?? '';
                }

                return _buildRiwayatLengkapCard(doc.id, data, userName, userEmail);
              },
            );
          },
        );
      },
    );
  }

  Widget _buildRiwayatLengkapCard(
    String docId,
    Map<String, dynamic> data,
    String userName,
    String userEmail,
  ) {
    final status = (data['status'] ?? '').toString();
    final isDikembalikan = status.toLowerCase() == 'dikembalikan';

    final lab = (data['lab'] ?? '').toString();
    final labStyle = ruangStyle[lab] ??
        {
          "color": Colors.grey[300],
          "text": Colors.black,
          "icon": Icons.location_on,
        };

    final tanggalPinjam = _parseFlexibleDate(data['tanggalPinjam']);
    final tanggalKembali = _parseFlexibleDate(data['tanggalKembali']);
    final alatItems = (data['alat'] as List?) ?? const [];

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8),
      color: isDikembalikan ? Colors.blue.shade50 : Colors.red.shade50,
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header with status
            Row(
              children: [
                Icon(labStyle["icon"], color: labStyle["text"], size: 24),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    "Lab: $lab",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: labStyle["text"],
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: isDikembalikan ? Colors.blue : Colors.red,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    status.isEmpty ? '-' : (status[0].toUpperCase() + status.substring(1)),
                    style: const TextStyle(
                      fontSize: 12,
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // User info
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey.shade300),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: colorMaroon.withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.person, color: colorMaroon, size: 20),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          userName,
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                        ),
                        Text(
                          userEmail,
                          style: TextStyle(fontSize: 11, color: Colors.grey[600]),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),

            // Dates
            Row(
              children: [
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Dipinjam', style: TextStyle(fontSize: 10, color: Colors.grey)),
                        Text(
                          DateFormat('dd MMM yyyy').format(tanggalPinjam),
                          style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Jatuh Tempo', style: TextStyle(fontSize: 10, color: Colors.grey)),
                        Text(
                          DateFormat('dd MMM yyyy').format(tanggalKembali),
                          style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),

            if (isDikembalikan && data['returnNotes'] != null) ...[
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Catatan Pengembalian:', style: TextStyle(fontSize: 10, color: Colors.grey)),
                    Text('${data['returnNotes']}', style: const TextStyle(fontSize: 12)),
                  ],
                ),
              ),
            ],

            if (!isDikembalikan && data['alasanPenolakan'] != null) ...[
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Alasan Penolakan:', style: TextStyle(fontSize: 10, color: Colors.grey)),
                    Text('${data['alasanPenolakan']}', style: const TextStyle(fontSize: 12)),
                  ],
                ),
              ),
            ],

            const SizedBox(height: 12),
            ExpansionTile(
              tilePadding: EdgeInsets.zero,
              title: const Text(
                'Lihat Detail Alat',
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
              ),
              children: [
                ...alatItems.map((item) {
                  final itemMap = (item as Map?)?.cast<String, dynamic>() ?? <String, dynamic>{};
                  final alatId = (itemMap['id'] ?? '').toString();
                  final qty = itemMap['jumlah'] ?? 0;

                  return FutureBuilder<DocumentSnapshot>(
                    future: FirebaseFirestore.instance.collection('alat').doc(alatId).get(),
                    builder: (context, snapshot) {
                      if (!snapshot.hasData || !snapshot.data!.exists) return const SizedBox();

                      final alatData = (snapshot.data!.data() as Map<String, dynamic>?) ?? {};

                      return Card(
                        margin: const EdgeInsets.only(bottom: 8),
                        child: ListTile(
                          contentPadding: const EdgeInsets.all(8),
                          leading: alatData['gambar'] != null
                              ? ClipRRect(
                                  borderRadius: BorderRadius.circular(6),
                                  child: Image.network(
                                    alatData['gambar'],
                                    width: 40,
                                    height: 40,
                                    fit: BoxFit.cover,
                                    errorBuilder: (_, __, ___) =>
                                        const Icon(Icons.inventory, size: 40),
                                  ),
                                )
                              : const Icon(Icons.inventory, size: 40),
                          title: Text(alatData['nama'] ?? 'Tanpa Nama', style: const TextStyle(fontSize: 13)),
                          subtitle: Text('Jumlah: $qty', style: const TextStyle(fontSize: 11)),
                        ),
                      );
                    },
                  );
                }).toList(),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // ----------------------------
  // TAB 4: PROFIL
  // ----------------------------
  Widget _buildProfileContent() {
    return Consumer<AuthProvider>(
      builder: (context, authProvider, child) {
        final user = authProvider.currentUser;
        final isLoading = user == null;

        return Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (isLoading)
                Center(child: CircularProgressIndicator(color: colorMaroon))
              else ...[
                const Text(
                  'Profil',
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.black87),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    CircleAvatar(
                      radius: 40,
                      backgroundColor: colorMaroon,
                      child: Text(
                        ((user?.name ?? 'A').isNotEmpty ? (user!.name![0]) : 'A'),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            user?.name ?? 'Admin',
                            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: Colors.black87),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            user?.email ?? 'admin@example.com',
                            style: TextStyle(fontSize: 14, color: Colors.grey[700]),
                          ),
                          const SizedBox(height: 4),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                            decoration: BoxDecoration(
                              color: colorMaroon,
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: Text(
                              (user?.role ?? 'admin') == 'admin' ? 'Admin Lab' : 'Pengguna',
                              style: const TextStyle(fontSize: 12, color: Colors.white, fontWeight: FontWeight.w500),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),

                // Lab Info (FIXED: removed user?.ruang)
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.grey[200]!),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Informasi Lab',
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black87),
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          const Icon(Icons.business_center, color: colorMaroon, size: 28),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              'Lab ${user?.lab ?? 'Tidak Diketahui'}',
                              style: const TextStyle(fontSize: 16, color: Colors.black54, fontWeight: FontWeight.w500),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => const EditProfileScreen()),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: colorMaroon,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        child: const Text('Edit Profil', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () => _showLogoutDialog(context),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        child: const Text('Keluar', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
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

  // ----------------------------
  // HELPERS
  // ----------------------------
  DateTime _parseFlexibleDate(dynamic value) {
    try {
      if (value is Timestamp) return value.toDate();
      if (value is DateTime) return value;
      if (value is String && value.isNotEmpty) return DateTime.parse(value);
    } catch (_) {
      // ignore
    }
    return DateTime.now();
  }
}
