import 'package:flutter/material.dart';
import 'package:pbase_peminjaman_alat_lab/features/presentation/style/color.dart';

// Data model sederhana untuk riwayat
class _HistoryItem {
  final String namaAlat;
  final String tanggal;
  final String status;  
  final IconData icon;

  const _HistoryItem({
    required this.namaAlat,
    required this.tanggal,
    required this.status,
    required this.icon,
  });
}

class HistoryScreen extends StatelessWidget {
  const HistoryScreen({super.key});

  // Data simulasi riwayat peminjaman
  final List<_HistoryItem> _historyList = const [
    _HistoryItem(
      namaAlat: "Proyektor InFocus",
      tanggal: "10 Nov 2025 - 12 Nov 2025",
      status: "Disetujui",
      icon: Icons.videocam_outlined,
    ),
    _HistoryItem(
      namaAlat: "Arduino Uno R3 Kit",
      tanggal: "3 Nov 2025 - 5 Nov 2025",
      status: "Diajukan",
      icon: Icons.memory,
    ),
    _HistoryItem(
      namaAlat: "Kabel VGA (5 Meter)",
      tanggal: "1 Okt 2025 - 2 Okt 2025",
      status: "Selesai",
      icon: Icons.cable,
    ),
    _HistoryItem(
      namaAlat: "Laptop Dell (Unit 05)",
      tanggal: "28 Sep 2025 - 29 Sep 2025",
      status: "Ditolak",
      icon: Icons.laptop_chromebook,
    ),
  ];

  // Fungsi untuk mendapatkan warna status
  Color _getStatusColor(String status) {
    switch (status) {
      case 'Disetujui':
        return Colors.green[700]!;
      case 'Diajukan':
        return Colors.orange[700]!;
      case 'Ditolak':
        return Colors.red[700]!;
      default: // Selesai
        return Colors.grey[600]!;
    }
  }

  // Fungsi untuk mendapatkan warna latar belakang ikon
  Color _getIconBgColor(String status) {
    switch (status) {
      case 'Disetujui':
        return Colors.green[50]!;
      case 'Diajukan':
        return Colors.orange[50]!;
      case 'Ditolak':
        return Colors.red[50]!;
      default: 
        return Colors.grey[100]!;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text("Riwayat Peminjaman"),
        backgroundColor: Colors.white,
        elevation: 1,
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _historyList.length,
        itemBuilder: (context, index) {
          final item = _historyList[index];
          return _buildHistoryCard(context, item);
        },
      ),
    );
  }

  // Widget untuk satu kartu riwayat
  Widget _buildHistoryCard(BuildContext context, _HistoryItem item) {
    final statusColor = _getStatusColor(item.status);
    final iconBgColor = _getIconBgColor(item.status);

    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: Colors.grey[200]!),
      ),
      color: Colors.white,
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                // Ikon
                Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    color: iconBgColor,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(item.icon, color: statusColor, size: 28),
                ),
                const SizedBox(width: 16),
                // Info
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        item.namaAlat,
                        style: const TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        item.tanggal,
                        style: const TextStyle(
                          fontSize: 13,
                          color: Colors.black54,
                        ),
                      ),
                    ],
                  ),
                ),
                // Status
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: statusColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    item.status,
                    style: TextStyle(
                      color: statusColor,
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                ),
              ],
            ),

            // --- FITUR: TOMBOL PENGEMBALIAN ---
           
            if (item.status == 'Disetujui')
              Column(
                children: [
                  const Divider(height: 32),
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton(
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        side: const BorderSide(color: colorMaroon),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      onPressed: () {
                        //dialog konfirmasi
                        showDialog(
                          context: context,
                          builder: (ctx) => AlertDialog(
                            title: const Text("Konfirmasi Pengembalian"),
                            content: Text(
                              "Apakah Anda yakin ingin mengajukan pengembalian untuk ${item.namaAlat}?",
                            ),
                            actions: [
                              TextButton(
                                child: const Text("Batal"),
                                onPressed: () => Navigator.of(ctx).pop(),
                              ),
                              ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: colorMaroon,
                                  foregroundColor: Colors.white,
                                ),
                                child: const Text("Ya, Ajukan"),
                                onPressed: () {
                                 
                                  
                                  Navigator.of(ctx).pop();
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text(
                                        "Pengajuan pengembalian terkirim!",
                                      ),
                                      backgroundColor: Colors.green,
                                    ),
                                  );
                                },
                              ),
                            ],
                          ),
                        );
                      },
                      child: const Text(
                        "Ajukan Pengembalian",
                        style: TextStyle(
                          color: colorMaroon,
                          fontWeight: FontWeight.bold,
                        ),
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
}
