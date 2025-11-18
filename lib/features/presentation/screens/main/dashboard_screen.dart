import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:pbase_peminjaman_alat_lab/features/presentation/providers/alat_provider.dart';
import 'package:pbase_peminjaman_alat_lab/features/presentation/providers/auth_provider.dart';
import 'package:pbase_peminjaman_alat_lab/features/presentation/style/color.dart';
import 'package:pbase_peminjaman_alat_lab/features/presentation/screens/ai/ai_helper_screen.dart';
import 'package:pbase_peminjaman_alat_lab/features/presentation/screens/auth/login_screen.dart';
import 'package:pbase_peminjaman_alat_lab/features/presentation/screens/main/detail_alat_screen.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  String _searchQuery = "";
  String _kategoriTerpilih = "semua";

  final Map<String, IconData> _kategoriList = {
    "komponen": Icons.memory,
    "perangkat": Icons.laptop,
    "kabel": Icons.cable,
    "lainnya": Icons.more_horiz,
  };

  @override
  void initState() {
    super.initState();
    // Fetch alat data only once when screen loads
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
        title: const Text("Inventaris Lab"),
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
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.of(context).push(
            MaterialPageRoute(builder: (context) => const AiHelperScreen()),
          );
        },
        backgroundColor: colorMaroon,
        foregroundColor: Colors.white,
        child: const Icon(Icons.assistant),
      ),
      body: Consumer2<AuthProvider, AlatProvider>(
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
                  "Daftar Alat",
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 12),
                _buildAlatGrid(alatList),
              ],
            ),
          );
        },
      ),
    );
  }

  void _showLogoutDialog(BuildContext context) {
    final authProvider = context.read<AuthProvider>();
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
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
    final userEmail = authProvider.currentUser?.email ?? 
                      authProvider.firebaseUser?.email ?? '';

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

      final cocokCari = _searchQuery.isEmpty
          ? true
          : nama.contains(_searchQuery);

      return cocokKategori && cocokCari;
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
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey[600],
              ),
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
                      _kategoriList[alat.kategori] ?? Icons.widgets,
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
}
