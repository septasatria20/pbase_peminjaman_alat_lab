import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:pbase_peminjaman_alat_lab/features/presentation/screens/main/peminjaman_screen.dart';
import 'package:pbase_peminjaman_alat_lab/features/presentation/screens/main/edit_profile_screen.dart';

import 'package:provider/provider.dart';
import 'package:pbase_peminjaman_alat_lab/features/presentation/providers/alat_provider.dart';
import 'package:pbase_peminjaman_alat_lab/features/presentation/providers/auth_provider.dart';
import 'package:pbase_peminjaman_alat_lab/features/presentation/providers/history_provider.dart';
import 'package:pbase_peminjaman_alat_lab/features/presentation/style/color.dart';
import 'package:pbase_peminjaman_alat_lab/features/presentation/screens/ai/ai_helper_screen.dart';
import 'package:pbase_peminjaman_alat_lab/features/presentation/screens/auth/login_screen.dart';
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
  int _selectedIndex = 0;

  final Map<String, IconData> _kategoriList = {
    "komponen": Icons.memory,
    "perangkat": Icons.laptop,
    "kabel": Icons.cable,
    "lainnya": Icons.more_horiz,
  };

  final List<String> _ruangList = ["semua", "BA", "IS", "NCS", "SE", "STUDIO"];

  @override
  void initState() {
    super.initState();
    // Fetch alat data only once when screen loads
    Future.microtask(() {
      final alatProvider = context.read<AlatProvider>();
      final authProvider = context.read<AuthProvider>();
      final historyProvider = context.read<HistoryProvider>();

      // Fetch alat data
      alatProvider.fetchAlatStream();

      // Fetch user history
      final userId =
          authProvider.currentUser?.id ?? authProvider.firebaseUser?.uid;
      if (userId != null) {
        print("🔍 [DashboardScreen] Fetching history for user ID: $userId");
        historyProvider.fetchUserHistory(userId);
      } else {
        print(
          "⚠️ [DashboardScreen] No user ID available for fetching history.",
        );
      }
    });
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
      if (_selectedIndex == 1) {
        // Fetch user history when navigating to the Riwayat tab
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
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: Text(_getAppBarTitle()),
        backgroundColor: Colors.white,
        elevation: 1,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: 'Keluar',
            onPressed: () => _showLogoutDialog(context),
          ),
        ],
      ),
      floatingActionButton: _selectedIndex == 0
          ? FloatingActionButton(
              heroTag: 'ai_helper_fab', // Add unique heroTag
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => const AiHelperScreen(),
                  ),
                );
              },
              backgroundColor: colorMaroon,
              foregroundColor: Colors.white,
              child: const Icon(Icons.assistant),
            )
          : null,
      body: _getSelectedContent(),
      bottomNavigationBar: BottomNavigationBar(
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home_outlined),
            activeIcon: Icon(Icons.home),
            label: 'Beranda',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.history_outlined),
            activeIcon: Icon(Icons.history),
            label: 'Riwayat',
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
          fontSize: 12,
        ),
        unselectedLabelStyle: const TextStyle(fontSize: 12),
        selectedFontSize: 12,
        unselectedFontSize: 12,
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
              if (context.mounted) {
                Navigator.of(context).pop();
                Navigator.of(context).pushReplacement(
                  MaterialPageRoute(builder: (_) => const LoginScreen()),
                );
              }
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

  Widget _buildWelcomeCard(AuthProvider authProvider) {
    final userName = authProvider.currentUser?.name ?? 'Loading...';
    final userEmail =
        authProvider.currentUser?.email ??
        authProvider.firebaseUser?.email ??
        '';

    // Debug logs
    print('=== Dashboard Welcome Card ===');
    print('Current User Name: ${authProvider.currentUser?.name}');
    print('Current User Email: ${authProvider.currentUser?.email}');
    print('Firebase User Email: ${authProvider.firebaseUser?.email}');
    print('=============================');

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [colorMaroon, colorMaroonDark],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Selamat datang, $userName!",
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            userEmail,
            style: const TextStyle(fontSize: 14, color: Colors.white60),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return TextFormField(
      decoration: InputDecoration(
        hintText: "Cari alat...",
        prefixIcon: const Icon(Icons.search),
        fillColor: Colors.white,
        filled: true,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
      ),
      onChanged: (value) {
        setState(() {
          _searchQuery = value.toLowerCase();
        });
      },
    );
  }

  Widget _buildCategoryList() {
    return SizedBox(
      height: 90,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: _kategoriList.length + 1,
        itemBuilder: (context, index) {
          if (index == 0) {
            return _buildKategoriCard(
              "semua",
              Icons.dashboard_outlined,
              "Semua",
            );
          }
          String kategori = _kategoriList.keys.elementAt(index - 1);
          IconData icon = _kategoriList.values.elementAt(index - 1);
          String nama = kategori[0].toUpperCase() + kategori.substring(1);
          return _buildKategoriCard(kategori, icon, nama);
        },
      ),
    );
  }

  Widget _buildRuangList() {
    return SizedBox(
      height: 60,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: _ruangList.length,
        itemBuilder: (context, index) {
          final ruang = _ruangList[index];
          final isActive = _ruangTerpilih == ruang;

          return InkWell(
            borderRadius: BorderRadius.circular(14),
            onTap: () => setState(() => _ruangTerpilih = ruang),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              margin: const EdgeInsets.only(right: 12),
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
              decoration: BoxDecoration(
                color: isActive ? colorMaroon : Colors.white,
                borderRadius: BorderRadius.circular(14),
                border: isActive ? null : Border.all(color: Colors.grey[300]!),
                boxShadow: isActive
                    ? [
                        BoxShadow(
                          color: colorMaroon.withOpacity(0.25),
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
                  ruang.toUpperCase(),
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
          color: isActive ? colorMaroon : Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: isActive ? null : Border.all(color: Colors.grey[200]!),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 32, color: isActive ? Colors.white : colorMaroon),
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

  Widget ruangChip(String kode) {
    final style =
        ruangStyle[kode] ??
        {
          "color": Colors.grey[300],
          "text": Colors.black,
          "icon": Icons.location_on,
        };

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: style["color"],
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(style["icon"], size: 16, color: style["text"]),
          const SizedBox(width: 6),
          Text(
            kode.toUpperCase(),
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: style["text"],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAlatGrid(List<dynamic> alatList) {
    // Show loading if list is empty
    if (alatList.isEmpty) {
      return Center(
        child: Column(
          children: [
            const SizedBox(height: 48),
            CircularProgressIndicator(color: colorMaroon),
            const SizedBox(height: 16),
            Text(
              'Memuat data alat...',
              style: TextStyle(color: Colors.grey[600]),
            ),
          ],
        ),
      );
    }

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

    // Show message if filtered list is empty
    if (alatFiltered.isEmpty) {
      return Center(
        child: Column(
          children: [
            const SizedBox(height: 48),
            Icon(Icons.search_off, size: 64, color: Colors.grey[400]),
            const SizedBox(height: 16),
            Text(
              'Tidak ada alat ditemukan',
              style: TextStyle(fontSize: 16, color: Colors.grey[600]),
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
        childAspectRatio: 0.8,
      ),
      itemCount: alatFiltered.length,
      itemBuilder: (context, index) {
        final alat = alatFiltered[index];
        final bool isTersedia = alat.status.toLowerCase() == 'tersedia';

        return InkWell(
          onTap: () {
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (context) => DetailAlatScreen(alatId: alat.id),
              ),
            );
          },
          borderRadius: BorderRadius.circular(12),
          child: Card(
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
              side: BorderSide(color: Colors.grey[200]!),
            ),
            color: Colors.white,
            child: Padding(
              padding: const EdgeInsets.all(12.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 50,
                    height: 50,
                    decoration: BoxDecoration(
                      color: isTersedia ? colorMaroonLight : Colors.grey[100],
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(
                      _kategoriList[alat.kategori.toLowerCase()] ??
                          Icons.widgets,
                      size: 28,
                      color: isTersedia ? colorMaroon : Colors.grey[400],
                    ),
                  ),
                  const Spacer(),
                  // Highlight hasil pencarian
                  _highlightText(alat.nama, _searchQuery, isTersedia),
                  const SizedBox(height: 4),
                  Text(
                    'Stok: ${alat.jumlah}',
                    style: TextStyle(
                      fontSize: 13,
                      color: isTersedia ? Colors.black54 : Colors.red,
                    ),
                  ),
                  const SizedBox(height: 6),
                  ruangChip(alat.ruang),
                ],
              ),
            ),
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
            style: TextStyle(color: Colors.black87),
          ),
          TextSpan(
            text: fullText.substring(startIndex, endIndex),
            style: const TextStyle(
              color: colorMaroon,
              fontWeight: FontWeight.bold,
            ),
          ),
          TextSpan(
            text: fullText.substring(endIndex),
            style: TextStyle(color: Colors.black87),
          ),
        ],
      ),
    );
  }

  Widget _buildHomeContent() {
    return Consumer2<AuthProvider, AlatProvider>(
      builder: (context, authProvider, alatProvider, child) {
        final alatList = alatProvider.alatList;

        return SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildWelcomeCard(authProvider),
              const SizedBox(height: 24),
              _buildSearchBar(),
              const SizedBox(height: 24),
              const Text(
                "Kategori",
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),
              _buildCategoryList(),
              const SizedBox(height: 24),
              const Text(
                "Laboratorium",
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),
              _buildRuangList(),
              const SizedBox(height: 24),
              const Text(
                "Daftar Alat",
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),
              _buildFloatingButton(context),

              const SizedBox(height: 12),
              _buildAlatGrid(alatList),
            ],
          ),
        );
      },
    );
  }

  Widget _buildProfileContent() {
    return Consumer<AuthProvider>(
      builder: (context, authProvider, child) {
        final user = authProvider.currentUser;
        final email = user?.email ?? authProvider.firebaseUser?.email ?? '';
        final name = user?.name ?? 'User';

        return SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              const SizedBox(height: 20),
              // Profile Avatar
              Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: LinearGradient(
                    colors: [colorMaroon, colorMaroonDark],
                  ),
                ),
                child: Container(
                  padding: const EdgeInsets.all(32),
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(Icons.person, size: 64, color: colorMaroon),
                ),
              ),
              const SizedBox(height: 24),
              Text(
                name,
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: colorMaroonDark,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                email,
                style: TextStyle(fontSize: 14, color: Colors.grey[600]),
              ),
              const SizedBox(height: 32),

              // Profile Menu
              _buildProfileMenuItem(
                icon: Icons.person_outline,
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
                icon: Icons.history,
                title: 'Riwayat Peminjaman',
                onTap: () {
                  setState(() {
                    _selectedIndex = 1; // Navigate to history tab
                  });
                },
              ),
              _buildProfileMenuItem(
                icon: Icons.help_outline,
                title: 'Bantuan',
                onTap: () {
                  showDialog(
                    context: context,
                    builder: (context) => AlertDialog(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      title: Row(
                        children: const [
                          Icon(Icons.help_outline, color: colorMaroon),
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
                icon: Icons.logout,
                title: 'Keluar',
                textColor: Colors.red,
                iconColor: Colors.red,
                onTap: () => _showLogoutDialog(context),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildRiwayatContent() {
    final historyProvider = Provider.of<HistoryProvider>(context);
    final historyList = historyProvider.state;

    if (historyList.isEmpty) {
      return _buildEmptyRiwayat();
    }

    return ListView.builder(
      itemCount: historyList.length,
      itemBuilder: (context, index) {
        final history = historyList[index];

        final labStyle =
            ruangStyle[history.lab] ??
            {
              "color": Colors.grey[300],
              "text": Colors.black,
              "icon": Icons.location_on,
            };

        return Card(
          margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
          color: colorMaroonLight,
          elevation: 4,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(labStyle["icon"], color: labStyle["text"], size: 24),
                    const SizedBox(width: 8),
                    Text(
                      "Lab: ${history.lab}",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: labStyle["text"],
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 8),

                // ============================
                // Card Tanggal (FULL WIDTH)
                // ============================
                SizedBox(
                  width: double.infinity,
                  child: Card(
                    color: Colors.white,
                    elevation: 3,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(12.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Tanggal Pinjam: ${DateFormat('dd-MM-yyyy').format(history.tanggalPinjam)}",
                            style: const TextStyle(fontSize: 14),
                          ),
                          Text(
                            "Tanggal Kembali: ${DateFormat('dd-MM-yyyy').format(history.tanggalKembali)}",
                            style: const TextStyle(fontSize: 14),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 8),

                // ============================
                // Card Alasan (FULL WIDTH)
                // ============================
                SizedBox(
                  width: double.infinity,
                  child: Card(
                    color: Colors.white,
                    elevation: 3,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(12.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Alasan: ${history.alasan}",
                            style: const TextStyle(
                              fontSize: 14,
                              color: Colors.black,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 8),

                // ============================
                // Card Status (KE KANAN)
                // ============================
                Row(
                  children: [
                    const Spacer(),
                    Card(
                      color: history.status.toLowerCase() == 'disetujui'
                          ? Colors.green
                          : history.status.toLowerCase() == 'ditolak'
                          ? Colors.red
                          : Colors.orange,
                      elevation: 3,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          vertical: 8,
                          horizontal: 16,
                        ),
                        child: Text(
                          history.status,
                          style: const TextStyle(
                            fontSize: 14,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 12),

                const Text(
                  "Alat:",
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),

                const SizedBox(height: 8),

                // ============================
                // List Alat
                // ============================
                ...history.alat.map((item) {
                  return FutureBuilder<DocumentSnapshot>(
                    future: FirebaseFirestore.instance
                        .collection('alat')
                        .doc(item['id'])
                        .get(),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(child: CircularProgressIndicator());
                      }

                      if (!snapshot.hasData || !snapshot.data!.exists) {
                        return const Text(
                          "Data alat tidak ditemukan.",
                          style: TextStyle(color: Colors.grey),
                        );
                      }

                      final alatData =
                          snapshot.data!.data() as Map<String, dynamic>;

                      return Card(
                        margin: const EdgeInsets.only(bottom: 8),
                        child: ListTile(
                          leading: alatData['gambar'] != null
                              ? Image.network(
                                  alatData['gambar'],
                                  width: 50,
                                  height: 50,
                                  fit: BoxFit.cover,
                                )
                              : const Icon(Icons.image_not_supported, size: 50),
                          title: Text(
                            alatData['nama'] ?? 'Tanpa Nama',
                            style: const TextStyle(fontSize: 14),
                          ),
                          subtitle: Text(
                            'Jumlah: ${item['jumlah']}',
                            style: const TextStyle(fontSize: 12),
                          ),
                        ),
                      );
                    },
                  );
                }).toList(),
              ],
            ),
          ),
        );
      },
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
            'Riwayat peminjaman akan muncul di sini',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 14, color: Colors.grey[600]),
          ),
        ],
      ),
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
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: ListTile(
        leading: Icon(icon, color: iconColor ?? colorMaroon),
        title: Text(
          title,
          style: TextStyle(
            fontWeight: FontWeight.w500,
            color: textColor ?? Colors.black87,
          ),
        ),
        trailing: Icon(Icons.chevron_right, color: Colors.grey[400]),
        onTap: onTap,
      ),
    );
  }
}

Widget _buildFloatingButton(BuildContext context) {
  return SizedBox(
    width: MediaQuery.of(context).size.width * 0.9,
    child: FloatingActionButton.extended(
      heroTag: 'peminjaman_fab', // Add unique heroTag
      onPressed: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => PeminjamanScreen()),
        );
      },
      backgroundColor: colorMaroon,
      elevation: 4,
      label: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.touch_app_rounded, color: Colors.white),
          const SizedBox(width: 10),
          const Text(
            "Ajukan Peminjaman",
            style: TextStyle(fontSize: 16, color: Colors.white),
          ),
        ],
      ),
    ),
  );
}
