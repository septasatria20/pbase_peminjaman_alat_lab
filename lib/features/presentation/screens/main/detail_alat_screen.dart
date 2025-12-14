import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:pbase_peminjaman_alat_lab/features/presentation/style/color.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

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
      backgroundColor: backgroundColor,
      appBar: AppBar(
        title: const Text(
          "Detail Alat",
          style: TextStyle(fontWeight: FontWeight.w600, color: textPrimary),
        ),
        backgroundColor: cardColor,
        elevation: 0.6,
        iconTheme: const IconThemeData(color: textPrimary),
      ),

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
                style: TextStyle(color: textSecondary),
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
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(18),
                  child: Image.network(
                    data['gambar'] ?? '',
                    height: 220,
                    width: double.infinity,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => Container(
                      height: 200,
                      color: borderColor,
                      child: const Icon(Icons.broken_image, size: 80),
                    ),
                  ),
                ),

                const SizedBox(height: 24),

                Text(
                  data['nama'] ?? 'Tanpa Nama',
                  style: const TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.w800,
                    color: textPrimary,
                  ),
                ),

                const SizedBox(height: 14),

                Row(
                  children: [
                    _chip(Icons.devices, data['kategori'], primaryColor),
                    const SizedBox(width: 8),
                    _chip(
                      isTersedia ? Icons.check_circle : Icons.cancel,
                      data['status'],
                      isTersedia ? successColor : textSecondary,
                    ),
                    const SizedBox(width: 8),
                    _chip(Icons.location_on, ruangKode, primaryColor),
                  ],
                ),

                const SizedBox(height: 28),

                _infoCard(Icons.apartment, ruangNama, ruangDeskripsi),
                const SizedBox(height: 16),
                _infoCard(
                  Icons.inventory_2,
                  "Stok tersedia: ${data['jumlah'] ?? '-'}",
                  "",
                ),
                const SizedBox(height: 16),
                _infoCard(
                  Icons.info_outline,
                  "Deskripsi Alat",
                  data['deskripsi']?.toString().trim().isNotEmpty == true
                      ? data['deskripsi']
                      : "Belum ada deskripsi alat.",
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _chip(IconData icon, String? text, Color color) {
    return Chip(
      avatar: Icon(icon, color: Colors.white, size: 16),
      label: Text(text ?? '', style: const TextStyle(color: Colors.white)),
      backgroundColor: color,
    );
  }

  Widget _infoCard(IconData icon, String title, String content) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
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
                backgroundColor: primaryColor.withOpacity(0.15),
                child: Icon(icon, color: primaryColor),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
              ),
            ],
          ),
          if (content.isNotEmpty) ...[
            const SizedBox(height: 10),
            Text(content, style: const TextStyle(color: textSecondary)),
          ],
        ],
      ),
    );
  }
}
