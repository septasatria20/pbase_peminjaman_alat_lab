import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:pbase_peminjaman_alat_lab/features/presentation/style/color.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'konfirmasi_peminjaman.dart';

final Map<String, Map<String, String>> ruangInfo = {
  "BA": {
    "nama": "Lab Analisa Bisnis",
    "deskripsi":
        "Lab untuk analisis bisnis, pengolahan data, dan riset sistem operasi.",
  },
  "IS": {
    "nama": "Lab Sistem Informasi",
    "deskripsi":
        "Lab pemrograman, basis data, dan pengembangan perangkat lunak.",
  },
  "NCS": {
    "nama": "Lab Jaringan & Keamanan Siber",
    "deskripsi": "Lab jaringan, keamanan siber, dan perangkat jaringan.",
  },
  "SE": {
    "nama": "Lab Rekayasa Perangkat Lunak",
    "deskripsi":
        "Lab pengembangan aplikasi, testing, dan project software engineering.",
  },
  "STUDIO": {
    "nama": "Lab Self Learning",
    "deskripsi": "Ruang perekaman, desain grafis, editing video dan animasi.",
  },
};

class DetailAlatScreen extends StatelessWidget {
  final String alatId;

  const DetailAlatScreen({super.key, required this.alatId});

  @override
  Widget build(BuildContext context) {
    final firestore = Provider.of<FirebaseFirestore>(context);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text("Detail Alat"),
        backgroundColor: Colors.white,
        elevation: 0.4,
      ),

      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,

      body: FutureBuilder<DocumentSnapshot>(
        future: firestore.collection('alat').doc(alatId).get(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || !snapshot.data!.exists) {
            return const Center(
              child: Text(
                "Data alat tidak ditemukan.",
                style: TextStyle(color: Colors.grey),
              ),
            );
          }

          final data = snapshot.data!.data() as Map<String, dynamic>;
          final isTersedia =
              (data['status']?.toString().toLowerCase() == 'tersedia');

          final ruangKode = data['ruang'] ?? '';
          final ruangNama = ruangInfo[ruangKode]?['nama'] ?? ruangKode;
          final ruangDeskripsi = ruangInfo[ruangKode]?['deskripsi'] ?? '';

          return SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Hero(
                  tag: "alatImage_$alatId",
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(18),
                    child: Image.network(
                      data['gambar'] ?? '',
                      height: 220,
                      width: double.infinity,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => Container(
                        height: 200,
                        color: Colors.grey[200],
                        child: const Icon(Icons.broken_image, size: 80),
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 24),

                // --- Nama alat ---
                Text(
                  data['nama'] ?? 'Tanpa Nama',
                  style: const TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.w900,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 10),
                const SizedBox(height: 10),
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      _chipIcon(Icons.devices, data['kategori'], colorMaroon),
                      const SizedBox(width: 8),
                      _chipIcon(
                        isTersedia ? Icons.check_circle : Icons.cancel,
                        data['status'],
                        isTersedia ? Colors.green : Colors.grey,
                      ),
                      const SizedBox(width: 8),
                      _chipIcon(
                        Icons.location_on,
                        ruangKode,
                        const Color(0xFF2563EB),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 30),
                _cardSection(
                  icon: Icons.apartment_rounded,
                  title: ruangNama,
                  content: ruangDeskripsi,
                ),
                const SizedBox(height: 20),
                _cardSection(
                  icon: Icons.inventory_2_rounded,
                  title: "Stok tersedia: ${data['jumlah'] ?? '-'}",
                  content: "",
                ),
                const SizedBox(height: 20),
                _cardSection(
                  icon: Icons.info_outline,
                  title: "Deskripsi Alat",
                  content:
                      data['deskripsi']?.toString().trim().isNotEmpty == true
                      ? data['deskripsi']
                      : "Belum ada deskripsi untuk alat ini.",
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _chipIcon(IconData icon, String? text, Color color) {
    return Chip(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      avatar: Icon(icon, color: Colors.white, size: 18),
      label: Text(text ?? '', style: const TextStyle(color: Colors.white)),
      backgroundColor: color,
    );
  }

  Widget _cardSection({
    required IconData icon,
    required String title,
    required String content,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 22,
                backgroundColor: colorMaroon.withOpacity(0.15),
                child: Icon(icon, size: 22, color: colorMaroon),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),

          if (content.isNotEmpty) ...[
            const SizedBox(height: 10),
            Text(
              content,
              style: const TextStyle(
                fontSize: 15,
                height: 1.4,
                color: Colors.black87,
              ),
            ),
          ],
        ],
      ),
    );
  }
}
