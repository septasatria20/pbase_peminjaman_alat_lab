import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pbase_peminjaman_alat_lab/features/presentation/style/color.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'form_peminjaman_screen.dart';

// Provider Firebase Firestore
final firestoreProvider = Provider<FirebaseFirestore>((ref) {
  return FirebaseFirestore.instance;
});

class DetailAlatScreen extends ConsumerWidget {
  final String alatId;

  const DetailAlatScreen({super.key, required this.alatId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final firestore = ref.watch(firestoreProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text("Detail Alat"),
        backgroundColor: Colors.white,
        elevation: 1,
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
                style: TextStyle(color: Colors.grey),
              ),
            );
          }

          final data = snapshot.data!.data() as Map<String, dynamic>;
          final isTersedia =
              (data['status']?.toString().toLowerCase() == 'tersedia');

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // --- Gambar alat ---
                ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: data['gambar'] != null &&
                          data['gambar'].toString().isNotEmpty
                      ? Image.network(
                          data['gambar'],
                          height: 200,
                          width: double.infinity,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) =>
                              const Icon(
                            Icons.broken_image,
                            size: 100,
                            color: Colors.grey,
                          ),
                        )
                      : Container(
                          height: 200,
                          color: Colors.grey[200],
                          child: const Icon(
                            Icons.image_not_supported,
                            size: 80,
                            color: Colors.grey,
                          ),
                        ),
                ),
                const SizedBox(height: 16),

                // --- Nama alat ---
                Text(
                  data['nama'] ?? 'Tanpa nama',
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),

                // --- Kategori dan status ---
                Row(
                  children: [
                    Chip(
                      label: Text(
                        data['kategori'] ?? 'Tidak diketahui',
                        style: const TextStyle(color: Colors.white),
                      ),
                      backgroundColor: colorMaroon,
                    ),
                    const SizedBox(width: 10),
                    Chip(
                      label: Text(
                        data['status'] ?? 'Tidak diketahui',
                        style: TextStyle(
                          color: isTersedia ? Colors.white : Colors.black,
                        ),
                      ),
                      backgroundColor:
                          isTersedia ? Colors.green : Colors.grey[300],
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // --- Jumlah stok ---
                Row(
                  children: [
                    const Icon(Icons.inventory_2_outlined, color: colorMaroon),
                    const SizedBox(width: 8),
                    Text(
                      "Stok tersedia: ${data['jumlah'] ?? '-'}",
                      style: const TextStyle(fontSize: 16),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // --- Deskripsi alat ---
                const Text(
                  "Deskripsi",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Text(
                  data['deskripsi']?.toString().trim().isNotEmpty == true
                      ? data['deskripsi']
                      : 'Belum ada deskripsi untuk alat ini.',
                  style: const TextStyle(fontSize: 15, color: Colors.black87),
                ),
                const SizedBox(height: 24),

                // --- Tombol Pinjam ---
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: isTersedia
                        ? () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => FormPeminjamanScreen(
                                  namaAlat: data['nama'],
                                  iconPath: '',
                                ),
                              ),
                            );
                          }
                        : null,
                    style: ElevatedButton.styleFrom(
                      backgroundColor:
                          isTersedia ? colorMaroon : Colors.grey[300],
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                      elevation: isTersedia ? 4 : 0,
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.assignment_turned_in,
                          color: isTersedia ? Colors.white : Colors.black87,
                        ),
                        const SizedBox(width: 10),
                        Text(
                          isTersedia ? "Ajukan Peminjaman" : "Tidak Tersedia",
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: isTersedia ? Colors.white : Colors.black87,
                            fontSize: 16,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
