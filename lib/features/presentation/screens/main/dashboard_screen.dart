import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:pbase_peminjaman_alat_lab/features/domain/entities/history.dart';
import 'package:pbase_peminjaman_alat_lab/features/presentation/screens/main/peminjaman_screen.dart';
import 'package:pbase_peminjaman_alat_lab/features/presentation/screens/main/edit_profile_screen.dart';
import 'package:pbase_peminjaman_alat_lab/features/presentation/screens/chat/chat_screen.dart';

import 'package:provider/provider.dart';
import 'package:pbase_peminjaman_alat_lab/features/presentation/providers/alat_provider.dart';
import 'package:pbase_peminjaman_alat_lab/features/presentation/providers/auth_provider.dart';
import 'package:pbase_peminjaman_alat_lab/features/presentation/providers/history_provider.dart';
import 'package:pbase_peminjaman_alat_lab/features/presentation/style/color.dart';
import 'package:pbase_peminjaman_alat_lab/features/presentation/screens/auth/login_screen.dart' hide themeGradient;
import 'package:pbase_peminjaman_alat_lab/features/presentation/screens/main/detail_alat_screen.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

final Map<String, Map<String, dynamic>> ruangStyle = {
  "BA": {
    "color": Color(0xFFE0F2FE),
    "text": Color(0xFF0C4A6E),
    "icon": Icons.business_center,
  },
  "IS": {
    "color": Color(0xFFE5E7EB),
    "text": Color(0xFF374151),
    "icon": Icons.computer,
  },
  "NCS": {
    "color": Color(0xFFFFEDD5),
    "text": Color(0xFF9A3412),
    "icon": Icons.shield,
  },
  "SE": {
    "color": Color(0xFFEDE9FE),
    "text": Color(0xFF5B21B6),
    "icon": Icons.code,
  },
  "STUDIO": {
    "color": Color(0xFFFCE7F3),
    "text": Color(0xFF9D174D),
    "icon": Icons.video_camera_back,
  },
};

class _DashboardScreenState extends State<DashboardScreen> {
  String _searchQuery = "";
  String _kategoriTerpilih = "semua";
  String _ruangTerpilih = "semua";
  String _statusTerpilih = "semua";
  int _selectedIndex = 0;

  final Map<String, IconData> _kategoriList = {
    "komponen": Icons.memory,
    "perangkat": Icons.laptop,
    "kabel": Icons.cable,
    "lainnya": Icons.more_horiz,
  };

  final List<String> _ruangList = ["semua", "BA", "IS", "NCS", "SE", "STUDIO"];

  final List<String> _statusList = [
    "semua",
    "diajukan",
    "disetujui",
    "dikembalikan",
    "ditolak",
  ];

  // Filter tab "Riwayat Lengkap"
  final List<String> _statusListHistory = ["semua", "dikembalikan", "ditolak"];

  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      final alatProvider = context.read<AlatProvider>();
      final historyProvider = context.read<HistoryProvider>();
      final authProvider = context.read<AuthProvider>();

      alatProvider.fetchAlatStream();

      final userId =
          authProvider.currentUser?.id ?? authProvider.firebaseUser?.uid;
      if (userId != null) {
        // ignore: avoid_print
        print("[DashboardScreen] Fetching history for user ID: $userId");
        historyProvider.fetchUserHistory(userId);
      } else {
        // ignore: avoid_print
        print(
          "[DashboardScreen] No user ID available for fetching history.",
        );
      }
    });
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;

      if (_selectedIndex == 1) {
        final authProvider = context.read<AuthProvider>();
        final historyProvider = context.read<HistoryProvider>();
        final userId =
            authProvider.currentUser?.id ?? authProvider.firebaseUser?.uid;
        if (userId != null) {
          historyProvider.fetchUserHistory(userId);
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: _selectedIndex == 0
          ? null
          : AppBar(
              title: Text(
                _getAppBarTitle(),
                style: const TextStyle(
                  color: Colors.black87,
                  fontWeight: FontWeight.bold,
                ),
              ),
              backgroundColor: Colors.white,
              elevation: 0,
              centerTitle: true,
              actions: [
                IconButton(
                  icon: const Icon(Icons.logout, color: Colors.redAccent),
                  tooltip: 'Keluar',
                  onPressed: () => _showLogoutDialog(context),
                ),
              ],
            ),
      body: _getSelectedContent(),

      bottomNavigationBar: BottomNavigationBar(
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home_rounded),
            label: 'Beranda',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.history_rounded),
            label: 'Riwayat',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_rounded),
            label: 'Profil',
          ),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: primaryColor,
        unselectedItemColor: textSecondary,
        onTap: _onItemTapped,
        type: BottomNavigationBarType.fixed,
        backgroundColor: Colors.white,
        elevation: 8,
        selectedLabelStyle: const TextStyle(
          fontWeight: FontWeight.w600,
          fontSize: 12,
        ),
      ),
    );
  }

  String _getAppBarTitle() {
    switch (_selectedIndex) {
      case 0:
        return 'Inventaris Lab';
      case 1:
        return 'Riwayat Peminjaman';
      case 2:
        return 'Profil';
      default:
        return 'SIMPEL';
    }
  }

  Widget _getSelectedContent() {
    switch (_selectedIndex) {
      case 0:
        return _buildHomeContent();
      case 1:
        return _buildRiwayatContent();
      case 2:
        return _buildProfileContent();
      default:
        return _buildHomeContent();
    }
  }

  // Update Dialog Logout Button Style
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
            child: const Text('Batal', style: TextStyle(color: Colors.grey)),
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
              backgroundColor: Colors.redAccent,
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

  // Update Dialog Kembali Alat Style
  void _showKembaliDialog(BuildContext context, HistoryEntity history) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: primaryColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(
                Icons.assignment_return_rounded,
                color: primaryColor,
              ),
            ),
            const SizedBox(width: 12),
            const Expanded(
              child: Text('Pengembalian', style: TextStyle(fontSize: 18)),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Apakah Anda ingin mengajukan pengembalian alat ini?'),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.grey[50],
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey[200]!),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(
                        Icons.location_on_outlined,
                        size: 16,
                        color: Colors.grey,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        'Lab: ${history.lab}',
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Jatuh Tempo: ${DateFormat('dd MMM yyyy').format(history.tanggalKembali)}',
                    style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.amber.shade50,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.amber.shade200),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.info_outline,
                    size: 16,
                    color: Colors.amber.shade800,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Admin akan memvalidasi pengembalian Anda',
                      style: TextStyle(
                        fontSize: 11,
                        color: Colors.amber.shade900,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Batal', style: TextStyle(color: Colors.grey)),
          ),
          Container(
            decoration: BoxDecoration(
              gradient: themeGradient,
              borderRadius: BorderRadius.circular(12),
            ),
            child: ElevatedButton(
              onPressed: () async {
                Navigator.of(context).pop();
                await _handleKembaliAlat(context, history.id);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.transparent,
                shadowColor: Colors.transparent,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text('Ajukan Pengembalian'),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _handleKembaliAlat(
    BuildContext context,
    String peminjamanId,
  ) async {
    try {
      final historyProvider = context.read<HistoryProvider>();

      if (context.mounted) {
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (context) => AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                CircularProgressIndicator(color: primaryColor),
                const SizedBox(height: 16),
                const Text('Mengirim pengajuan...'),
              ],
            ),
          ),
        );
      }

      await historyProvider.updateStatusToReturned(peminjamanId);

      if (context.mounted) {
        Navigator.of(context).pop();

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Row(
              children: [
                Icon(Icons.check_circle, color: Colors.white),
                SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Pengajuan pengembalian berhasil! Menunggu validasi admin.',
                  ),
                ),
              ],
            ),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 4),
          ),
        );

        final authProvider = context.read<AuthProvider>();
        final userId =
            authProvider.currentUser?.id ?? authProvider.firebaseUser?.uid;
        if (userId != null) {
          await historyProvider.fetchUserHistory(userId);
        }
      }
    } catch (e) {
      if (context.mounted) {
        Navigator.of(context).pop();

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.error, color: Colors.white),
                const SizedBox(width: 8),
                Expanded(child: Text('Gagal mengajukan pengembalian: $e')),
              ],
            ),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 3),
          ),
        );
      }
    }
  }

  Widget _buildWelcomeCard(AuthProvider authProvider) {
    final userName = authProvider.currentUser?.name ?? 'Loading...';
    final userEmail = authProvider.currentUser?.email ?? '';

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(
        24,
        48,
        24,
        32,
      ),
      decoration: const BoxDecoration(
        gradient: themeGradient,
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(32),
          bottomRight: Radius.circular(32),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Halo, $userName ",
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    userEmail,
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.white.withOpacity(0.9),
                    ),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.all(2),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.3),
                  shape: BoxShape.circle,
                ),
                child: CircleAvatar(
                  backgroundColor: Colors.white,
                  radius: 24,
                  child: Text(
                    userName.isNotEmpty ? userName[0].toUpperCase() : 'U',
                    style: const TextStyle(
                      color: primaryColor,
                      fontWeight: FontWeight.bold,
                      fontSize: 20,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return Container(
      decoration: BoxDecoration(
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: TextFormField(
        decoration: InputDecoration(
          hintText: "Cari alat laboratorium...",
          hintStyle: TextStyle(color: Colors.grey[400]),
          prefixIcon: const Icon(Icons.search_rounded, color: primaryColor),
          fillColor: Colors.white,
          filled: true,
          contentPadding: const EdgeInsets.symmetric(vertical: 16),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide.none,
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide.none,
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: const BorderSide(color: primaryColor, width: 1.5),
          ),
        ),
        onChanged: (value) {
          setState(() {
            _searchQuery = value.toLowerCase();
          });
        },
      ),
    );
  }

  Widget _buildStatusList() {
    return SizedBox(
      height: 45,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: _statusList.length,
        itemBuilder: (context, index) {
          final status = _statusList[index];
          final isActive = _statusTerpilih == status;

          return InkWell(
            borderRadius: BorderRadius.circular(25),
            onTap: () => setState(() => _statusTerpilih = status),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              margin: const EdgeInsets.only(right: 10),
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 0),
              decoration: BoxDecoration(
                gradient: isActive ? themeGradient : null,
                color: isActive ? null : Colors.white,
                borderRadius: BorderRadius.circular(25),
                border: isActive ? null : Border.all(color: Colors.grey[200]!),
                boxShadow: isActive
                    ? [
                        BoxShadow(
                          color: primaryColor.withOpacity(0.3),
                          blurRadius: 8,
                          offset: const Offset(0, 4),
                        ),
                      ]
                    : [],
              ),
              child: Center(
                child: Text(
                  status[0].toUpperCase() + status.substring(1),
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: isActive ? Colors.white : Colors.grey[600],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildKategoriCard(String key, IconData icon, String nama) {
    bool isActive = (_kategoriTerpilih == key);

    return InkWell(
      onTap: () => setState(() => _kategoriTerpilih = key),
      borderRadius: BorderRadius.circular(12),
      child: Container(
        width: 80,
        margin: const EdgeInsets.only(right: 12),
        decoration: BoxDecoration(
          color: isActive ? primaryColor : Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: isActive ? null : Border.all(color: Colors.grey[200]!),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 32, color: isActive ? Colors.white : primaryColor),
            const SizedBox(height: 6),
            Text(
              nama,
              style: TextStyle(
                color: isActive ? Colors.white : Colors.black87,
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAlatGrid(List<dynamic> alatList) {
    if (alatList.isEmpty) {
      return Center(
        child: Column(
          children: [
            const SizedBox(height: 48),
            CircularProgressIndicator(color: primaryColor),
            const SizedBox(height: 16),
            Text(
              'Memuat data alat...',
              style: TextStyle(color: Colors.grey[600]),
            ),
          ],
        ),
      );
    }

    // Filter logic remains same
    final alatFiltered = alatList.where((alat) {
      final kategori = alat.kategori.toLowerCase();
      final nama = alat.nama.toLowerCase();
      final cocokKategori = _kategoriTerpilih == "semua"
          ? true
          : kategori == _kategoriTerpilih.toLowerCase();
      final cocokRuang = _ruangTerpilih == "semua"
          ? true
          : alat.ruang.toLowerCase() == _ruangTerpilih.toLowerCase();
      final cocokCari = _searchQuery.isEmpty
          ? true
          : nama.contains(_searchQuery);
      return cocokKategori && cocokCari && cocokRuang;
    }).toList();

    if (alatFiltered.isEmpty) {
      return Center(
        child: Column(
          children: [
            const SizedBox(height: 48),
            Icon(Icons.search_off_rounded, size: 64, color: Colors.grey[300]),
            const SizedBox(height: 16),
            Text(
              'Tidak ada alat ditemukan',
              style: TextStyle(fontSize: 16, color: Colors.grey[500]),
            ),
          ],
        ),
      );
    }

    return GridView.builder(
      physics: const NeverScrollableScrollPhysics(),
      shrinkWrap: true,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
        childAspectRatio:
            0.75,
      ),
      itemCount: alatFiltered.length,
      itemBuilder: (context, index) {
        final alat = alatFiltered[index];
        final bool isTersedia =
            alat.status.toLowerCase() == 'tersedia' && alat.jumlah > 0;

        return InkWell(
          onTap: () {
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (context) => DetailAlatScreen(alatId: alat.id),
              ),
            );
          },
          borderRadius: BorderRadius.circular(20),
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.04),
                  blurRadius: 12,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Image Section
                Expanded(
                  flex:
                      5,
                  child: Stack(
                    children: [
                      ClipRRect(
                        borderRadius: const BorderRadius.vertical(
                          top: Radius.circular(20),
                        ),
                        child: alat.gambar != null
                            ? Image.network(
                                alat.gambar,
                                width: double.infinity,
                                height: double.infinity,
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) =>
                                    _buildPlaceholderImage(
                                      isTersedia,
                                      alat.kategori,
                                    ),
                              )
                            : _buildPlaceholderImage(isTersedia, alat.kategori),
                      ),
                      Positioned(
                        top: 8,
                        right: 8,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.9),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.inventory_2_outlined,
                                size: 12,
                                color: Colors.grey[700],
                              ),
                              const SizedBox(width: 4),
                              Text(
                                '${alat.jumlah}',
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.grey[800],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                // Content Section
                Expanded(
                  flex:
                      4,
                  child: Padding(
                    padding: const EdgeInsets.all(
                      10.0,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        // Nama alat & lab chip
                        Flexible(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                alat.nama,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  color: isTersedia
                                      ? Colors.black87
                                      : Colors.grey[600]!,
                                  fontWeight: FontWeight.w600,
                                  fontSize: 13,
                                ),
                              ),
                              const SizedBox(height: 4),
                              ruangChip(alat.ruang),
                            ],
                          ),
                        ),
                        // Status badge di bawah
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.symmetric(vertical: 5),
                          decoration: BoxDecoration(
                            color: isTersedia
                                ? const Color(0xFFDCFCE7)
                                : const Color(0xFFFEE2E2),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Center(
                            child: Text(
                              isTersedia
                                  ? 'Tersedia'
                                  : 'Tidak Tersedia',
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                                color: isTersedia
                                    ? const Color(0xFF166534)
                                    : const Color(0xFF991B1B),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildPlaceholderImage(bool isTersedia, String kategori) {
    return Container(
      width: double.infinity,
      height: double.infinity,
      decoration: BoxDecoration(
        color: isTersedia ? primaryColor.withOpacity(0.1) : Colors.grey[100],
      ),
      child: Icon(
        _kategoriList[kategori.toLowerCase()] ?? Icons.widgets_rounded,
        size: 40,
        color: isTersedia ? primaryColor : Colors.grey[400],
      ),
    );
  }

  Widget _buildHomeContent() {
    return Consumer2<AuthProvider, AlatProvider>(
      builder: (context, authProvider, alatProvider, child) {
        final alatList = alatProvider.alatList;

        final List<DropdownMenuItem<String>> kategoriItems =
            <DropdownMenuItem<String>>[
              const DropdownMenuItem<String>(
                value: "semua",
                child: Text("Semua"),
              ),
              ..._kategoriList.entries.map((entry) {
                return DropdownMenuItem<String>(
                  value: entry.key,
                  child: Row(
                    children: [
                      Icon(entry.value, size: 18, color: primaryColor),
                      const SizedBox(width: 8),
                      Text(entry.key[0].toUpperCase() + entry.key.substring(1)),
                    ],
                  ),
                );
              }).toList(),
            ];

        final List<DropdownMenuItem<String>> ruangItems = _ruangList
            .map(
              (ruang) => DropdownMenuItem<String>(
                value: ruang,
                child: Text(ruang.toUpperCase()),
              ),
            )
            .toList();

        return SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildWelcomeCard(authProvider),

              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 24),
                    _buildSearchBar(),
                    const SizedBox(height: 24),

                    // Filters
                    Row(
                      children: [
                        Expanded(
                          child: _buildModernDropdown(
                            "Kategori",
                            _kategoriTerpilih,
                            kategoriItems,
                            (val) => setState(() => _kategoriTerpilih = val!),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: _buildModernDropdown(
                            "Laboratorium",
                            _ruangTerpilih,
                            ruangItems,
                            (val) => setState(() => _ruangTerpilih = val!),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),

                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          "Daftar Alat",
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    _buildFloatingButton(context),
                    const SizedBox(height: 16),
                    _buildAlatGrid(alatList),
                    const SizedBox(height: 80),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildModernDropdown(
    String label,
    String value,
    List<DropdownMenuItem<String>> items,
    Function(String?) onChanged,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: Colors.grey[600],
          ),
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey[200]!),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.02),
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: value,
              isExpanded: true,
              icon: const Icon(
                Icons.keyboard_arrow_down_rounded,
                color: primaryColor,
              ),
              items: items,
              onChanged: onChanged,
              style: const TextStyle(
                color: Colors.black87,
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
              dropdownColor: Colors.white,
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildProfileContent() {
    return Consumer<AuthProvider>(
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
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                email,
                style: TextStyle(fontSize: 14, color: Colors.grey[500]),
              ),
              const SizedBox(height: 40),

              _buildProfileMenuItem(
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
                icon: Icons.history_rounded,
                title: 'Riwayat Peminjaman',
                onTap: () => setState(() => _selectedIndex = 1),
              ),
              _buildProfileMenuItem(
                icon: Icons.help_outline_rounded,
                title: 'Bantuan',
                onTap: () {
                  // Dialog logic remains same
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
                        'Untuk bantuan lebih lanjut, silakan hubungi:\n\nEmail: admin@polinema.ac.id\nTelp: (0341) 123456\n\nJam Operasional:\nSenin - Jumat: 08.00 - 16.00 WIB',
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
                icon: Icons.logout_rounded,
                title: 'Keluar',
                textColor: Colors.redAccent,
                iconColor: Colors.redAccent,
                onTap: () => _showLogoutDialog(context),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _highlightText(String fullText, String query, bool isTersedia) {
    if (query.isEmpty) {
      return Text(
        fullText,
        maxLines: 2,
        overflow: TextOverflow.ellipsis,
        style: TextStyle(
          color: isTersedia ? Colors.black87 : Colors.grey[600]!,
          fontWeight: FontWeight.w600,
          fontSize: 14,
        ),
      );
    }

    final lowerText = fullText.toLowerCase();
    final lowerQuery = query.toLowerCase();

    final startIndex = lowerText.indexOf(lowerQuery);
    if (startIndex == -1) {
      return Text(
        fullText,
        maxLines: 2,
        overflow: TextOverflow.ellipsis,
        style: TextStyle(
          color: isTersedia ? Colors.black87 : Colors.grey[600]!,
          fontWeight: FontWeight.w600,
          fontSize: 14,
        ),
      );
    }

    final endIndex = startIndex + lowerQuery.length;

    return RichText(
      maxLines: 2,
      overflow: TextOverflow.ellipsis,
      text: TextSpan(
        children: [
          TextSpan(
            text: fullText.substring(0, startIndex),
            style: const TextStyle(
              color: Colors.black87,
              fontWeight: FontWeight.w600,
              fontSize: 14,
            ),
          ),
          TextSpan(
            text: fullText.substring(startIndex, endIndex),
            style: const TextStyle(
              color: primaryColor,
              fontWeight: FontWeight.bold,
              fontSize: 14,
            ),
          ),
          TextSpan(
            text: fullText.substring(endIndex),
            style: const TextStyle(
              color: Colors.black87,
              fontWeight: FontWeight.w600,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  /// Map Firebase status to filter status
  bool _statusMatches(String firebaseStatus, String filterStatus) {
    final fbStatus = firebaseStatus.toLowerCase();
    final filter = filterStatus.toLowerCase();

    if (filter == "diajukan" &&
        (fbStatus == "diajukan" || fbStatus == "menunggu persetujuan")) {
      return true;
    }

    if (filter == "disetujui" &&
        (fbStatus == "disetujui" ||
            fbStatus == "menunggu validasi pengembalian")) {
      return true;
    }

    if (filter == "dikembalikan" && fbStatus == "dikembalikan") {
      return true;
    }
    if (filter == "ditolak" && fbStatus == "ditolak") {
      return true;
    }
    return false;
  }

  Widget _buildRiwayatContent() {
    final historyProvider = Provider.of<HistoryProvider>(context);
    final historyList = historyProvider.state;

    return DefaultTabController(
      length: 2,
      child: Column(
        children: [
          Container(
            color: Colors.white,
            child: const TabBar(
              labelColor: primaryColor,
              unselectedLabelColor: Colors.grey,
              indicatorColor: primaryColor,
              tabs: [
                Tab(text: 'Aktif'),
                Tab(text: 'Riwayat Lengkap'),
              ],
            ),
          ),
          Expanded(
            child: TabBarView(
              children: [
                _buildRiwayatAktif(historyList),
                _buildRiwayatLengkap(historyList),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Aktif: diajukan / menunggu persetujuan / disetujui / menunggu validasi pengembalian
  Widget _buildRiwayatAktif(List<HistoryEntity> historyList) {
    final activeList = historyList.where((h) {
      final status = h.status.toLowerCase();
      return status == 'menunggu persetujuan' ||
          status == 'diajukan' ||
          status == 'disetujui' ||
          status == 'menunggu validasi pengembalian';
    }).toList();

    final filteredList = activeList.where((history) {
      if (_statusTerpilih == "semua") return true;
      return _statusMatches(history.status, _statusTerpilih);
    }).toList();

    if (activeList.isEmpty) {
      return _buildEmptyRiwayat();
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Filter Status",
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          _buildStatusList(),
          const SizedBox(height: 24),
          if (filteredList.isEmpty)
            _buildEmptyRiwayat()
          else
            _buildHistoryListView(filteredList, showReturnButton: true),
        ],
      ),
    );
  }

  // Lengkap: dikembalikan / ditolak
  Widget _buildRiwayatLengkap(List<HistoryEntity> historyList) {
    final completeList = historyList.where((h) {
      final status = h.status.toLowerCase();
      return status == 'dikembalikan' || status == 'ditolak';
    }).toList();

    final filteredList = completeList.where((history) {
      if (_statusTerpilih == "semua") return true;
      final status = history.status.toLowerCase();
      final filter = _statusTerpilih.toLowerCase();
      if (filter == "dikembalikan" && status == "dikembalikan") return true;
      if (filter == "ditolak" && status == "ditolak") return true;
      return false;
    }).toList();

    if (completeList.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: _buildEmptyRiwayat(),
        ),
      );
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            height: 60,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: _statusListHistory.length,
              itemBuilder: (context, index) {
                final status = _statusListHistory[index];
                final isActive = _statusTerpilih == status;

                return InkWell(
                  borderRadius: BorderRadius.circular(14),
                  onTap: () => setState(() => _statusTerpilih = status),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    margin: const EdgeInsets.only(right: 12),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 18,
                      vertical: 12,
                    ),
                    decoration: BoxDecoration(
                      gradient: isActive ? themeGradient : null,
                      color: isActive ? null : Colors.white,
                      borderRadius: BorderRadius.circular(14),
                      border: isActive
                          ? null
                          : Border.all(color: Colors.grey[300]!),
                      boxShadow: isActive
                          ? [
                              BoxShadow(
                                color: primaryColor.withOpacity(0.25),
                                blurRadius: 6,
                                offset: const Offset(0, 3),
                              ),
                            ]
                          : [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.05),
                                blurRadius: 3,
                                offset: const Offset(0, 2),
                              ),
                            ],
                    ),
                    child: Center(
                      child: Text(
                        status[0].toUpperCase() + status.substring(1),
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: isActive ? Colors.white : Colors.black87,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 24),
          if (filteredList.isEmpty)
            Center(
              child: Padding(
                padding: const EdgeInsets.all(32),
                child: Text(
                  'Tidak ada riwayat dengan status ini',
                  style: TextStyle(color: Colors.grey[600]),
                ),
              ),
            )
          else
            _buildHistoryListView(filteredList, showReturnButton: false),
        ],
      ),
    );
  }

  Widget _buildEmptyRiwayat() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(32),
            decoration: BoxDecoration(
              color: primaryColor.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.history_rounded,
              size: 80,
              color: primaryColor.withOpacity(0.5),
            ),
          ),
          const SizedBox(height: 24),
          const Text(
            'Belum Ada Riwayat',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Riwayat peminjaman akan muncul di sini',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 14, color: Colors.grey[600]),
          ),
        ],
      ),
    );
  }

  Widget _buildHistoryListView(
    List<HistoryEntity> filteredList, {
    required bool showReturnButton,
  }) {
    return ListView.builder(
      physics: const NeverScrollableScrollPhysics(),
      shrinkWrap: true,
      itemCount: filteredList.length,
      itemBuilder: (context, index) {
        final history = filteredList[index];
        final labStyle =
            ruangStyle[history.lab] ??
            {
              "color": Colors.grey[300],
              "text": Colors.black,
              "icon": Icons.location_on,
            };
        final statusLower = history.status.toLowerCase();

        // Color logic for status badge
        Color statusColor;
        String statusText;
        if (statusLower == 'disetujui') {
          statusColor = Colors.green;
          statusText = 'Disetujui';
        } else if (statusLower == 'ditolak') {
          statusColor = Colors.red;
          statusText = 'Ditolak';
        } else if (statusLower == 'dikembalikan') {
          statusColor = primaryColor;
          statusText = 'Selesai';
        } else if (statusLower == 'menunggu validasi pengembalian') {
          statusColor = Colors.orange;
          statusText = 'Validasi Kembali';
        } else {
          statusColor = Colors.orange;
          statusText = 'Diajukan';
        }

        return Container(
          margin: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.03),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: (labStyle["color"] as Color).withOpacity(
                              0.5,
                            ),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Icon(
                            labStyle["icon"] as IconData,
                            color: labStyle["text"] as Color,
                            size: 20,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Text(
                          "Lab ${history.lab}",
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.grey[800],
                          ),
                        ),
                      ],
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: statusColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        statusText,
                        style: TextStyle(
                          fontSize: 12,
                          color: statusColor,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 16),
                  child: Divider(height: 1),
                ),

                // Dates Row
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Pinjam",
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey[500],
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            DateFormat('dd MMM').format(history.tanggalPinjam),
                            style: const TextStyle(fontWeight: FontWeight.w600),
                          ),
                        ],
                      ),
                    ),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Kembali",
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey[500],
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            DateFormat('dd MMM').format(history.tanggalKembali),
                            style: const TextStyle(fontWeight: FontWeight.w600),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // Alat List Preview with FutureBuilder
                ...history.alat.map((item) {
                  final alatId = (item['id'] ?? '').toString();
                  final qty = item['jumlah'] ?? 0;

                  return FutureBuilder<DocumentSnapshot>(
                    future: FirebaseFirestore.instance
                        .collection('alat')
                        .doc(alatId)
                        .get(),
                    builder: (context, snapshot) {
                      String alatName = 'Loading...';

                      if (snapshot.connectionState == ConnectionState.done) {
                        if (snapshot.hasData && snapshot.data!.exists) {
                          final data =
                              (snapshot.data!.data()
                                  as Map<String, dynamic>?) ??
                              {};
                          alatName = data['nama'] ?? 'Tanpa Nama';
                        } else {
                          alatName = 'Tidak ditemukan';
                        }
                      }

                      return Padding(
                        padding: const EdgeInsets.only(bottom: 8.0),
                        child: Row(
                          children: [
                            const Icon(
                              Icons.circle,
                              size: 6,
                              color: Colors.grey,
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                '$alatName: $qty unit',
                                style: TextStyle(
                                  fontSize: 13,
                                  color: Colors.grey[700],
                                ),
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  );
                }).toList(),

                // Action Buttons
                if (showReturnButton && statusLower == 'disetujui') ...[
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () => _showKembaliDialog(context, history),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor: primaryColor,
                        elevation: 0,
                        side: const BorderSide(color: primaryColor),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                      child: const Text('Ajukan Pengembalian'),
                    ),
                  ),
                ],

                // Chat Button
                if (statusLower == 'disetujui' ||
                    statusLower == 'menunggu persetujuan' ||
                    statusLower == 'diajukan')
                  Padding(
                    padding: const EdgeInsets.only(top: 12),
                    child: InkWell(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => ChatScreen(
                              peminjamanId: history.id,
                              otherUserName: 'Admin Lab ${history.lab}',
                              otherUserRole: 'admin',
                            ),
                          ),
                        );
                      },
                      child: const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.chat_bubble_outline_rounded,
                            size: 16,
                            color: Colors.grey,
                          ),
                          SizedBox(width: 8),
                          Text(
                            "Hubungi Admin",
                            style: TextStyle(fontSize: 13, color: Colors.grey),
                          ),
                        ],
                      ),
                    ),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildProfileMenuItem({
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
            color: textColor ?? Colors.black87,
            fontSize: 15,
          ),
        ),
        trailing: Icon(Icons.chevron_right_rounded, color: Colors.grey[300]),
        onTap: onTap,
      ),
    );
  }

  Widget ruangChip(String kode) {
    final style =
        ruangStyle[kode] ??
        {
          "color": Colors.grey[300],
          "text": Colors.black,
          "icon": Icons.location_on,
        };

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 8,
        vertical: 4,
      ), // Kurangi padding
      decoration: BoxDecoration(
        color: style["color"] as Color,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            style["icon"] as IconData,
            size: 12,
            color: style["text"] as Color,
          ),
          const SizedBox(width: 4),
          Text(
            kode.toUpperCase(),
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.bold,
              color: style["text"] as Color,
            ),
          ),
        ],
      ),
    );
  }
}

Widget _buildFloatingButton(BuildContext context) {
  return Container(
    width: double.infinity,
    decoration: BoxDecoration(
      gradient: themeGradient,
      borderRadius: BorderRadius.circular(16),
      boxShadow: [
        BoxShadow(
          color: primaryColor.withOpacity(0.3),
          blurRadius: 12,
          offset: const Offset(0, 6),
        ),
      ],
    ),
    child: ElevatedButton(
      onPressed: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => PeminjamanScreen()),
        );
      },
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.transparent,
        shadowColor: Colors.transparent,
        padding: const EdgeInsets.symmetric(vertical: 16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
      child: const Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.add_circle_outline_rounded, color: Colors.white),
          SizedBox(width: 10),
          Text(
            "Ajukan Peminjaman Baru",
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ],
      ),
    ),
  );
}
