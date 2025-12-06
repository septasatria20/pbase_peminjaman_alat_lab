import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:pbase_peminjaman_alat_lab/features/presentation/screens/main/konfirmasi_peminjaman.dart';

import 'package:provider/provider.dart';
import 'package:pbase_peminjaman_alat_lab/features/presentation/providers/alat_provider.dart';
import 'package:pbase_peminjaman_alat_lab/features/presentation/providers/auth_provider.dart';
import 'package:pbase_peminjaman_alat_lab/features/presentation/style/color.dart';
import 'package:pbase_peminjaman_alat_lab/features/presentation/screens/ai/ai_helper_screen.dart';
import 'package:pbase_peminjaman_alat_lab/features/presentation/screens/auth/login_screen.dart';
import 'package:pbase_peminjaman_alat_lab/features/presentation/screens/main/detail_alat_screen.dart';

class PeminjamanScreen extends StatefulWidget {
  const PeminjamanScreen({super.key});

  @override
  State<PeminjamanScreen> createState() => _PeminjamanScreenState();
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

class _PeminjamanScreenState extends State<PeminjamanScreen> {
  String _searchQuery = "";
  String _kategoriTerpilih = "semua";
  String _ruangTerpilih = "BA";
  Map<String, int> _selectedItems = {}; 

  final Map<String, IconData> _kategoriList = {
    "komponen": Icons.memory,
    "perangkat": Icons.laptop,
    "kabel": Icons.cable,
    "lainnya": Icons.more_horiz,
  };

  final List<String> _ruangList = ["BA", "IS", "NCS", "SE", "STUDIO"];

  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      final alatProvider = context.read<AlatProvider>();
      alatProvider.fetchAlatStream();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: Text('Peminjaman Alat Lab'),
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
      body: Column(
        children: [
          Expanded(child: _getSelectedContent()),
          if (_selectedItems.isNotEmpty) _buildBottomSlider(),
        ],
      ),
    );
  }

  Widget _getSelectedContent() {
    return _buildHomeContent();
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
            "hai, $userName pilih alat yang ingin kamu pinjam",
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 4),
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
          final isDisabled =
              _selectedItems.isNotEmpty && _ruangTerpilih != ruang;

          return GestureDetector(
            onTap: isDisabled
                ? () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          'Anda cuma bisa meminjam dari ruangan yang sama',
                        ),
                      ),
                    );
                  }
                : () {
                    setState(() {
                      _ruangTerpilih = ruang;
                    });
                  },
            child: Container(
              margin: const EdgeInsets.only(right: 12),
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
              decoration: BoxDecoration(
                color: isActive ? colorMaroon : Colors.white,
                borderRadius: BorderRadius.circular(14),
                border: isActive ? null : Border.all(color: Colors.grey[300]!),
                boxShadow: isActive
                    ? [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 6,
                          offset: const Offset(0, 3),
                        ),
                      ]
                    : [],
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
        final int selectedCount = _selectedItems[alat.id] ?? 0;

        return InkWell(
          onTap: () {},
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
                  const SizedBox(height: 8),
                  if (selectedCount > 0)
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        IconButton(
                          icon: Icon(Icons.remove),
                          onPressed: () {
                            setState(() {
                              if (selectedCount > 1) {
                                _selectedItems[alat.id] = selectedCount - 1;
                              } else {
                                _selectedItems.remove(alat.id);
                              }
                            });
                          },
                        ),
                        Text('$selectedCount'),
                        IconButton(
                          icon: Icon(Icons.add),
                          onPressed: () {
                            setState(() {
                              if (selectedCount < alat.jumlah) {
                                _selectedItems[alat.id] = selectedCount + 1;
                              }
                            });
                          },
                        ),
                      ],
                    )
                  else
                    ElevatedButton(
                      onPressed: () {
                        setState(() {
                          _selectedItems[alat.id] = 1;
                        });
                      },
                      child: Text('Pinjam'),
                    ),
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
              _buildAlatGrid(alatList),
            ],
          ),
        );
      },
    );
  }

  Widget _buildBottomSlider() {
    final totalItems = _selectedItems.values.fold(
      0,
      (sum, count) => sum + count,
    );

    return Container(
      padding: const EdgeInsets.all(16),
      color: Colors.white,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            '$totalItems items',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => FormPeminjamanScreen(
                    selectedItems: _selectedItems,
                    activeRoom: _ruangTerpilih,
                  ),
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: colorMaroon,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: Text('Lanjut Peminjaman'),
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

