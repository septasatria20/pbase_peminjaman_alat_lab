import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:pbase_peminjaman_alat_lab/features/presentation/providers/alat_provider.dart';
import 'package:pbase_peminjaman_alat_lab/features/presentation/style/color.dart';
import 'package:pbase_peminjaman_alat_lab/features/presentation/screens/ai/ai_helper_screen.dart';
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
  Widget build(BuildContext context) {
    final alatProvider = Provider.of<AlatProvider>(context);
    alatProvider.fetchAlatStream();

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text("Inventaris Lab"),
        backgroundColor: Colors.white,
        elevation: 1,
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
      body: Consumer<AlatProvider>(
        builder: (context, provider, child) {
          final alatList = provider.alatList;

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildWelcomeCard(),
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

  Widget _buildWelcomeCard() {
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
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Selamat datang, Qusnul!",
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          SizedBox(height: 4),
          Text(
            "Siap untuk meminjam alat hari ini?",
            style: TextStyle(fontSize: 15, color: Colors.white70),
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
